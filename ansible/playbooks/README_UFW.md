# UFW Firewall Configuration - Task 1.5.1

## Purpose

Configure UFW (Uncomplicated Firewall) according to the network architecture defined in `planning.md` Section 3.2.

## Network Security Model

Based on `planning.md`, the mail server uses a **defense-in-depth** approach:

### Public Services (accessible from anywhere)
- **Port 25** (SMTP) - Inbound mail from internet
- **Port 587** (SMTP Submission) - Authenticated outbound mail
- **Port 465** (SMTPS) - Legacy submission over SSL
- **Port 80** (HTTP) - Let's Encrypt certificate validation only

### VPN-Only Services (10.100.0.0/24)
- **Port 993** (IMAPS) - Email client access
- **Port 5432** (PostgreSQL) - Database access
- **Port 2288** (SSH) - Administrative access
- **Port 443** (HTTPS) - SOGo webmail

### Default Policies
- **Incoming:** DENY (explicit allow only)
- **Outgoing:** ALLOW (services can reach internet)
- **Routed:** DENY (no packet forwarding)

## Usage

### Run the Task

```bash
# Using run_task.sh:
./run_task.sh 1.5.1

# Or directly:
ansible-playbook playbooks/task_1_5_1.yml
```

### Verify Configuration

```bash
# On server:
ssh phalkonadmin@cucho1.phalkons.com -p 2288

# Check UFW status:
sudo ufw status verbose

# View numbered rules:
sudo ufw status numbered

# View saved configuration:
sudo cat /root/ufw_firewall_config.txt
```

## What the Playbook Does

1. ✅ Installs UFW if not present
2. ✅ Sets default policies (deny incoming, allow outgoing)
3. ✅ Allows loopback interface
4. ✅ Configures public mail services (25, 587, 465, 80)
5. ✅ Configures VPN-only services (993, 5432, 2288, 443)
6. ✅ Applies rate limiting on SSH and SMTP Submission
7. ✅ Enables UFW and ensures it starts at boot
8. ✅ Saves configuration summary to `/root/ufw_firewall_config.txt`

## Testing After Configuration

### Test Public Services

```bash
# From any internet connection:

# Test SMTP:
telnet cucho1.phalkons.com 25

# Test SMTP Submission:
telnet cucho1.phalkons.com 587

# Test HTTP:
curl http://cucho1.phalkons.com
```

### Test VPN-Only Services

```bash
# From VPN-connected machine (10.100.0.0/24):

# Test IMAPS:
openssl s_client -connect 10.100.0.25:993 -starttls imap

# Test PostgreSQL:
telnet 10.100.0.25 5432

# Test SSH:
ssh phalkonadmin@10.100.0.25 -p 2288

# Test HTTPS (SOGo):
curl https://10.100.0.25
```

### Test that VPN-Only Services are Blocked from Public

```bash
# From internet (not on VPN) - these should FAIL:

# Should timeout (blocked):
telnet cucho1.phalkons.com 993

# Should timeout (blocked):
telnet cucho1.phalkons.com 5432

# Should timeout (blocked):
telnet cucho1.phalkons.com 2288
```

## Customization

### Optional Variables

You can customize the firewall by setting these variables in `group_vars/all.yml` or on command line:

```yaml
# Enable/disable SMTPS (port 465)
allow_smtps: true  # default: true

# Allow HTTPS from public internet (not recommended)
allow_public_https: false  # default: false

# Allow WireGuard port (if not already configured)
allow_wireguard_port: false  # default: false

# Allow Wazuh agent ports
allow_wazuh: false  # default: false

# Reset UFW to default state before configuring
ufw_reset: false  # default: false, use with caution!
```

### Override on Command Line

```bash
ansible-playbook playbooks/task_1_5_1.yml \
  -e "allow_smtps=false" \
  -e "allow_wazuh=true"
```

## Manual UFW Management

### Add a Rule

```bash
# Allow from specific IP:
sudo ufw allow from 203.0.113.50 to any port 22

# Allow from VPN network:
sudo ufw allow from 10.100.0.0/24 to any port 8080

# Allow specific port from anywhere:
sudo ufw allow 8080/tcp
```

### Delete a Rule

```bash
# Show numbered rules:
sudo ufw status numbered

# Delete rule by number:
sudo ufw delete 5

# Or delete by specification:
sudo ufw delete allow 8080/tcp
```

### Temporarily Disable

```bash
# Disable firewall:
sudo ufw disable

# Re-enable:
sudo ufw enable
```

## Compliance with Planning.md

This firewall configuration implements **Section 3.2: Service Binding Strategy** from `planning.md`:

| Service            | Port | Binding    | ✅ Implemented |
|--------------------|------|------------|---------------|
| SMTP (inbound)     | 25   | Public IP  | ✅ Yes        |
| SMTP Submission    | 587  | Public IP  | ✅ Yes        |
| SMTPS              | 465  | Public IP  | ✅ Yes        |
| IMAPS              | 993  | VPN only   | ✅ Yes        |
| PostgreSQL         | 5432 | VPN only   | ✅ Yes        |
| SOGo Web           | 443  | VPN only   | ✅ Yes        |
| SSH                | 2288 | VPN only   | ✅ Yes        |

## Security Notes

### Rate Limiting

The playbook applies rate limiting to prevent brute force attacks:

- **SSH (2288):** Limited connections per IP
- **SMTP Submission (587):** Limited to prevent spam

UFW will automatically block IPs that exceed connection limits.

### VPN Network Trust

The configuration trusts the entire VPN network (`10.100.0.0/24`). Ensure:
- ✅ Only authorized devices can connect to VPN
- ✅ VPN authentication is strong
- ✅ VPN logs are monitored
- ✅ Unused VPN clients are removed

### Logging

UFW logs are in:
```bash
/var/log/ufw.log
```

To enable more verbose logging:
```bash
sudo ufw logging on
sudo ufw logging high  # or: low, medium, high, full
```

## Troubleshooting

### Service Not Accessible

**Problem:** Can't connect to a service that should be allowed

**Solution:**
```bash
# Check if UFW is blocking:
sudo ufw status verbose

# Check if service is listening:
sudo ss -tlnp | grep [PORT]

# Check UFW logs:
sudo tail -f /var/log/ufw.log

# Temporarily disable UFW to test:
sudo ufw disable
# Test connection
sudo ufw enable
```

### VPN Services Accessible from Internet

**Problem:** Services that should be VPN-only are accessible from internet

**Solution:**
```bash
# Check rules:
sudo ufw status numbered

# Verify VPN network setting:
grep "mail_server_vpn_network" /path/to/group_vars/all.yml

# Check service binding:
sudo ss -tlnp
# Services should bind to 10.100.0.25, not 0.0.0.0
```

### Accidentally Locked Out

**Problem:** Can't SSH to server after enabling UFW

**Solution:**
```bash
# If you have console access (Vultr control panel):
1. Access server via Vultr web console
2. Disable UFW: sudo ufw disable
3. Fix SSH rule: sudo ufw allow from 10.100.0.0/24 to any port 2288
4. Re-enable: sudo ufw enable

# Prevention:
- Always test SSH from VPN before logging out
- Keep console access handy
- Use serial console if needed
```

## Integration with Other Components

### Postfix

Postfix binds to:
- `0.0.0.0:25` - Public SMTP
- `0.0.0.0:587` - Public Submission
- `0.0.0.0:465` - Public SMTPS (optional)

UFW allows these ports from anywhere.

### Dovecot

Dovecot should bind to:
- `10.100.0.25:993` - VPN-only IMAPS

UFW allows port 993 only from `10.100.0.0/24`.

### PostgreSQL

PostgreSQL container should bind to:
- `10.100.0.25:5432` - VPN-only

UFW allows port 5432 only from `10.100.0.0/24`.

### SOGo

SOGo (via Nginx) should bind to:
- `10.100.0.25:443` - VPN-only HTTPS

UFW allows port 443 only from `10.100.0.0/24`.

## Next Steps

After configuring UFW:

1. ✅ **Run Task 2.1.1** - Deploy PostgreSQL container
2. ✅ **Verify** - PostgreSQL is only accessible from VPN
3. ✅ **Run Task 2.2.1** - Install Postfix
4. ✅ **Verify** - SMTP ports are accessible from internet
5. ✅ **Run Task 2.2.2** - Install Dovecot
6. ✅ **Verify** - IMAPS is only accessible from VPN

---

**Based on:** planning.md Section 3.2 - Service Binding Strategy
**Security Model:** Defense-in-depth with VPN isolation
**Compliance:** Follows mail server architecture requirements
