# Improved Mail Server Playbooks for Debian 13

Production-ready Ansible playbooks for deploying a complete mail server stack (Postfix + Dovecot + OpenDKIM) on Debian 13 with PostgreSQL backend.

## Directory Structure

```
ansible/
├── ansible.cfg                          # Your Ansible configuration
├── inventory.yml                        # Your dynamic inventory
├── group_vars/
│   └── all.yml                         # Your variables (already configured)
├── playbooks/
│   ├── task_1_5_1.yml                  # Task: Configure UFW firewall
│   ├── task_2_2_1.yml                  # Task: Install Postfix
│   ├── task_2_2_2.yml                  # Task: Install Dovecot
│   ├── task_2_2_3.yml                  # Task: Install OpenDKIM
│   ├── task_2_2_4.yml                  # Task: Test mail system
│   ├── configure_ufw_firewall.yml      # UFW firewall configuration
│   ├── install_postfix.yml             # Postfix installation
│   ├── install_dovecot.yml             # Dovecot installation
│   ├── install_opendkim.yml            # OpenDKIM installation
│   ├── test_mail_system.yml            # System testing
│   ├── rollback_postfix.yml            # Rollback Postfix configuration
│   ├── rollback_dovecot.yml            # Rollback Dovecot configuration
│   ├── rollback_opendkim.yml           # Rollback OpenDKIM configuration
│   └── README_UFW.md                   # UFW firewall documentation
├── README.md                            # This file
└── IMPROVEMENTS_SUMMARY.md              # What was improved
```

## What's New in These Improved Playbooks

### Key Enhancements
✅ **Pre-flight validation** - Checks OS requirements (Debian 13+)
✅ **Improved idempotency** - Safe to run multiple times
✅ **Standardized password retrieval** - Robust Python-based parsing
✅ **Better error handling** - Retries and clear failure messages
✅ **Rollback capability** - Easy recovery from issues
✅ **Health scoring** - 0-100% automated system health assessment
✅ **Performance metrics** - Tracks mail delivery times
✅ **Comprehensive testing** - Validates all components
✅ **Enhanced documentation** - Inline help and examples

## Your Current Configuration

Based on your `group_vars/all.yml`:

- **Server:** cucho1.phalkons.com (45.32.207.84)
- **VPN IP:** 10.100.0.25
- **Domain:** phalkons.com
- **Test Domain:** testdomain.local
- **PostgreSQL:** Running at 10.100.0.25:5432 (database: mailserver)
- **Mail Directory:** /var/mail/vmail
- **Credentials File:** /root/postgres_service_users.txt

## Prerequisites

### System Requirements
- Debian 13 (Trixie) installed on cucho1.phalkons.com ✅
- PostgreSQL 17 running (via your container setup) ✅
- Variables configured in `group_vars/all.yml` ✅
- Credentials in `/root/postgres_service_users.txt` ✅

### Required on Control Machine
```bash
# Already have Ansible if you're using run_task.sh
ansible --version
```

## Quick Start

### Using Your run_task.sh Script (Recommended)

If you have a `run_task.sh` wrapper script:

```bash
# Run tasks in order:
./run_task.sh 2.2.1  # Install Postfix
./run_task.sh 2.2.2  # Install Dovecot  
./run_task.sh 2.2.3  # Install OpenDKIM
./run_task.sh 2.2.4  # Test everything
```

### Using Ansible Directly

```bash
# Set environment variables (if not using run_task.sh):
export MAIL_SERVER_IP="45.32.207.84"
export MAIL_SERVER_PASS="your_password"
export ANSIBLE_REMOTE_PORT="2288"  # If using custom SSH port
export ANSIBLE_REMOTE_USER="phalkonadmin"  # If using custom user
export ANSIBLE_PRIVATE_KEY_FILE="~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common"

# Run tasks:
ansible-playbook playbooks/task_2_2_1.yml
ansible-playbook playbooks/task_2_2_2.yml
ansible-playbook playbooks/task_2_2_3.yml
ansible-playbook playbooks/task_2_2_4.yml
```

### Using VPN Connection (Internal Network)

```bash
# Override to use VPN IP instead of public IP:
export ANSIBLE_HOST="10.100.0.25"

ansible-playbook playbooks/task_2_2_1.yml
```

## Base System Tasks (Task Groups 1.2–1.5)

These tasks prepare the OS, users, security, directories, and firewall. Run in order.

### Task Group 1.2 — System User Administration

Run with wrapper:
```bash
./run_task.sh 1.2.1  # Modify sudoers (NOPASSWD)
./run_task.sh 1.2.2  # Remove linuxuser
./run_task.sh 1.2.3  # Create admin user (phalkonadmin)
./run_task.sh 1.2.4  # Setup SSH key authentication
./run_task.sh 1.2.5  # Test SSH connection
./run_task.sh 1.2.6  # Install Docker (compose)
./run_task.sh 1.2.7  # Cleanup and verification
```
Or directly with Ansible:
```bash
ansible-playbook playbooks/task_1.2.1.yml
ansible-playbook playbooks/task_1.2.2.yml
ansible-playbook playbooks/task_1.2.3.yml
ansible-playbook playbooks/task_1.2.4.yml
ansible-playbook playbooks/task_1.2.5.yml
ansible-playbook playbooks/task_1.2.6.yml
ansible-playbook playbooks/task_1.2.7.yml
```

### Task Group 1.3 — System Hardening

Run with wrapper:
```bash
./run_task.sh 1.3.1  # Basic hardening (SSH, UFW base, auto-updates)
./run_task.sh 1.3.2  # WireGuard VPN install/config
./run_task.sh 1.3.3  # Verify network interfaces
./run_task.sh 1.3.4  # SSH depends on VPN + VPN-only SSH
./run_task.sh 1.3.5  # Install and configure fail2ban
```
Or directly with Ansible:
```bash
ansible-playbook playbooks/task_1.3.1.yml
ansible-playbook playbooks/task_1.3.2.yml
ansible-playbook playbooks/task_1.3.3.yml
ansible-playbook playbooks/task_1.3.4.yml
ansible-playbook playbooks/task_1.3.5.yml
```

### Task Group 1.4 — Directory Structure & Storage

Run with wrapper:
```bash
./run_task.sh 1.4.1  # Create mail and postgres directories
./run_task.sh 1.4.2  # Set permissions and ownerships
./run_task.sh 1.4.3  # Prepare quota tools (documentation approach)
```
Or directly with Ansible:
```bash
ansible-playbook playbooks/task_1.4.1.yml
ansible-playbook playbooks/task_1.4.2.yml
ansible-playbook playbooks/task_1.4.3.yml
```

### Task Group 1.5 — Firewall Configuration (UFW)

Run with wrapper:
```bash
./run_task.sh 1.5.1  # Configure UFW firewall
```
Or directly with Ansible:
```bash
ansible-playbook playbooks/task_1_5_1.yml
```

## Database Layer Tasks (Task Group 2.1)

Run with wrapper:
```bash
./run_task.sh 2.1.1  # Deploy PostgreSQL container (vpn-only)
./run_task.sh 2.1.2  # Configure mail database (domain/mailbox/alias)
./run_task.sh 2.1.3  # Configure backups + WAL
./run_task.sh 2.1.4  # Verify container, users, schema, backups
```
Or directly with Ansible:
```bash
ansible-playbook playbooks/task_2.1.1.yml
ansible-playbook playbooks/task_2.1.2.yml
ansible-playbook playbooks/task_2.1.3.yml
ansible-playbook playbooks/task_2.1.4.yml
```

## Detailed Usage

### Task 2.2.1: Install Postfix

Installs and configures Postfix MTA with PostgreSQL virtual domains.

```bash
./run_task.sh 2.2.1

# Or directly:
ansible-playbook playbooks/task_2_2_1.yml

# With verbose output:
ansible-playbook playbooks/task_2_2_1.yml -vv

# Check mode (dry run):
ansible-playbook playbooks/task_2_2_1.yml --check
```

**What it does:**
- ✅ Validates Debian 13
- ✅ Installs Postfix + postfix-pgsql
- ✅ Configures PostgreSQL virtual domains
- ✅ Sets up submission port (587)
- ✅ Creates mail directories
- ✅ Tests database connectivity

### Task 2.2.2: Install Dovecot

Installs Dovecot 2.4 with PostgreSQL authentication (Debian 13 specific).

```bash
./run_task.sh 2.2.2

# Or directly:
ansible-playbook playbooks/task_2_2_2.yml
```

**What it does:**
- ✅ Installs dovecot-pgsql (critical for Debian 13!)
- ✅ Configures SQL authentication with named sections
- ✅ Sets up LMTP for Postfix integration
- ✅ Configures Maildir format
- ✅ Tests authentication

**Important Dovecot 2.4 Changes Handled:**
1. Named sections: `passdb sql {}` (not anonymous)
2. Inline SQL config (no external dovecot-sql.conf.ext)
3. Comments out `auth_username_format = %u`
4. Uses `%{user}` variable syntax
5. Uses mailbox schema with maildir path stored in mailbox.maildir

### Task 2.2.3: Install OpenDKIM

Sets up DKIM signing for email authentication.

```bash
./run_task.sh 2.2.3

# Or directly:
ansible-playbook playbooks/task_2_2_3.yml
```

**What it does:**
- ✅ Installs OpenDKIM
- ✅ Generates DKIM keys for your domain
- ✅ Integrates with Postfix
- ✅ Documents DNS records needed

**After running, check:**
```bash
# DNS records saved on server:
ssh cucho1.phalkons.com "cat /root/dns_records.txt"
ssh cucho1.phalkons.com "cat /root/dns_records_quick.txt"
```

### Task 2.2.4: Test Mail System

Comprehensive end-to-end testing with health scoring.

```bash
./run_task.sh 2.2.4

# Or directly:
ansible-playbook playbooks/task_2_2_4.yml
```

**What it tests:**
- ✅ Service status (Postfix, Dovecot, OpenDKIM)
- ✅ Database connectivity
- ✅ Authentication mechanisms
- ✅ Port availability (25, 587, 993)
- ✅ Mail delivery (SMTP → Dovecot)
- ✅ DKIM signing
- ✅ **Overall health score (0-100%)**

**Output example:**
```
🎯 OVERALL HEALTH: 95% - EXCELLENT ✓✓✓
   (9/9 checks passed)

Service Status:
  Postfix:  RUNNING ✓
  Dovecot:  RUNNING ✓
  OpenDKIM: RUNNING ✓

Test Results:
  Mail Delivery: PASS ✓ (1 msg in ~3s)
  DKIM Signing:  ACTIVE ✓

📄 Full report: /root/mail_system_test_report.txt
```

### Rollback Procedures

If something goes wrong:

```bash
# Rollback Postfix:
ansible-playbook playbooks/rollback_postfix.yml

# Rollback Dovecot:
ansible-playbook playbooks/rollback_dovecot.yml

# Rollback OpenDKIM:
ansible-playbook playbooks/rollback_opendkim.yml
```

**What rollback does:**
- ✅ Restores original configuration from backups
- ✅ Backs up current config before rollback
- ✅ Removes Ansible-managed blocks
- ✅ Restarts services
- ✅ Validates configuration

## DNS Configuration

After running Task 2.2.3, you need to add DNS records for:
- **SPF** - Authorizes your server to send mail
- **DKIM** - Cryptographic email authentication
- **DMARC** - Policy for handling unauthenticated mail
- **MX** - Mail exchange server
- **PTR** - Reverse DNS (configure via Vultr)

**View DNS records:**
```bash
ssh cucho1.phalkons.com "cat /root/dns_records.txt"
```

**Quick copy-paste format:**
```bash
ssh cucho1.phalkons.com "cat /root/dns_records_quick.txt"
```

## Your Variables Explained

Your `group_vars/all.yml` is already configured with:

```yaml
# Network (your actual values)
mail_server_public_ip: "45.32.207.84"      # Public IP for DNS
mail_server_vpn_ip: "10.100.0.25"          # Internal VPN IP
mail_server_hostname: "cucho1.phalkons.com"

# Database (PostgreSQL container)
postgres_host: "10.100.0.25"               # VPN IP
postgres_db: "mailserver"                  # Database name
postgres_dovecot_user: "dovecot_user"      # Dovecot DB user
postgres_postfix_user: "postfix_user"      # Postfix DB user

# Mail Storage
mail_vmail_dir: "/var/mail/vmail"          # Where emails are stored
vmail_uid: 5000                            # Mail user UID
vmail_gid: 5000                            # Mail user GID

# Credentials
postgres_credentials_file: "/root/postgres_service_users.txt"

# SSL (self-signed for now)
ssl_cert_path: "/etc/ssl/certs/ssl-cert-snakeoil.pem"
ssl_key_path: "/etc/ssl/private/ssl-cert-snakeoil.key"

# Test User
mail_test_username: "testuser1"
mail_test_domain: "testdomain.local"
mail_test_password: "TestPass123!"
```

## Troubleshooting

### Common Issues

**Issue: "Failed to retrieve password"**
```bash
# Check your credentials file on server:
ssh cucho1.phalkons.com "cat /root/postgres_service_users.txt"

# Should contain sections like:
# Postfix (Mail Routing):
#   Username: postfix_user
#   Password: your_password_here
#
# Dovecot (IMAP/POP3 Authentication):
#   Username: dovecot_user  
#   Password: another_password_here
```

**Issue: "Dovecot authentication failed"**
```bash
# SSH to server and test:
ssh cucho1.phalkons.com

# Check if dovecot-pgsql is installed (critical!):
dpkg -l | grep dovecot-pgsql

# Test authentication:
doveadm auth test testuser1@testdomain.local TestPass123!

# Check logs:
journalctl -u dovecot -n 50
```

**Issue: "Mail not delivering"**
```bash
# SSH to server:
ssh cucho1.phalkons.com

# Check mail logs:
tail -f /var/log/mail.log

# Check Postfix queue:
mailq

# Test database connectivity:
postmap -q testdomain.local pgsql:/etc/postfix/pgsql-virtual-mailbox-domains.cf
```

**Issue: "Connection refused"**
```bash
# Check if using correct connection method:

# After Task 1.3.4, use VPN IP:
export ANSIBLE_HOST="10.100.0.25"

# After Task 1.3.2, use custom SSH port and user:
export ANSIBLE_REMOTE_PORT="2288"
export ANSIBLE_REMOTE_USER="phalkonadmin"
export ANSIBLE_PRIVATE_KEY_FILE="~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common"
```

### Service Management on Server

```bash
# SSH to server:
ssh cucho1.phalkons.com

# Check service status:
systemctl status postfix dovecot opendkim

# View logs:
tail -f /var/log/mail.log
journalctl -u postfix -f
journalctl -u dovecot -f
journalctl -u opendkim -f

# Restart services:
systemctl restart postfix
systemctl restart dovecot
systemctl restart opendkim
```

### Re-running Playbooks

All playbooks are idempotent and safe to re-run:

```bash
# Re-run any task:
./run_task.sh 2.2.2  # Example: re-configure Dovecot

# Re-test system:
./run_task.sh 2.2.4
```

## Advanced Usage

### Running Specific Tags

```bash
# Run only DKIM configuration:
ansible-playbook playbooks/task_2_2_3.yml --tags dkim

# Run only authentication configuration:
ansible-playbook playbooks/task_2_2_3.yml --tags authentication
```

### Override Variables

```bash
# Override specific variables:
ansible-playbook playbooks/task_2_2_1.yml \
  -e "postfix_myhostname=mail2.phalkons.com" \
  -e "mail_test_domain=phalkons.com"
```

### Verbose Output

```bash
# See all details:
ansible-playbook playbooks/task_2_2_1.yml -vvv

# See what changed:
ansible-playbook playbooks/task_2_2_1.yml -v
```

## PostgreSQL Database Requirements

Your PostgreSQL database (`mailserver`) should have these tables:

### Required Tables

**1. domain** - Mail domains
```sql
CREATE TABLE domain (
    domain VARCHAR(255) PRIMARY KEY,
    description TEXT,
    aliases INTEGER DEFAULT 0,
    mailboxes INTEGER DEFAULT 0,
    maxquota BIGINT DEFAULT 0,
    quota BIGINT DEFAULT 0,
    transport VARCHAR(255) DEFAULT 'virtual',
    backupmx BOOLEAN DEFAULT false,
    active BOOLEAN DEFAULT true,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**2. mailbox** - Email accounts  
```sql
CREATE TABLE mailbox (
    username VARCHAR(255) PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    maildir VARCHAR(255) NOT NULL,
    quota BIGINT DEFAULT 0,
    local_part VARCHAR(255),
    domain VARCHAR(255),
    active BOOLEAN DEFAULT true,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mailbox_domain FOREIGN KEY (domain) REFERENCES domain(domain) ON DELETE CASCADE
);
```

**3. alias** - Email aliases
```sql
CREATE TABLE alias (
    address VARCHAR(255) PRIMARY KEY,
    goto TEXT NOT NULL,
    domain VARCHAR(255),
    active BOOLEAN DEFAULT true,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_alias_domain FOREIGN KEY (domain) REFERENCES domain(domain) ON DELETE CASCADE
);
```

### Test User Setup

```sql
-- Add test domain
INSERT INTO domain (domain, active) 
VALUES ('testdomain.local', true);

-- Add test user (password: TestPass123!)
-- Generate password with: doveadm pw -s SHA512-CRYPT
INSERT INTO mailbox (username, password, name, maildir, domain, local_part, active)
VALUES (
    'testuser1@testdomain.local',
    '{SHA512-CRYPT}$6$...',  -- Your hashed password
    'Test User',
    'testdomain.local/testuser1/',
    'testdomain.local',
    'testuser1',
    true
);
```

## Security Considerations

### Best Practices
1. ✅ Strong passwords in PostgreSQL
2. ✅ Firewall configured (ufw/iptables)
3. ✅ VPN for internal communication (10.100.0.0/24)
4. ✅ Custom SSH port (2288) and user (phalkonadmin)
5. ⚠️ Replace self-signed SSL cert with Let's Encrypt in production
6. ⚠️ Configure fail2ban for brute-force protection
7. ⚠️ Set DMARC policy to "p=reject" after testing

### Firewall Rules on Server

```bash
ssh cucho1.phalkons.com

# Allow mail ports:
ufw allow 25/tcp comment "SMTP"
ufw allow 587/tcp comment "Submission"
ufw allow 993/tcp comment "IMAPS"

# Check status:
ufw status
```

## Backup Strategy

**Critical files to backup:**
- Configuration: `/etc/postfix/`, `/etc/dovecot/`, `/etc/opendkim/`
- Mail data: `/var/mail/vmail/`
- Database: `pg_dump mailserver`
- Credentials: `/root/postgres_service_users.txt`

**Automated backup:**
```bash
# On server, create backup script:
cat > /root/backup-mail.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/var/mail/backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"
tar czf "$BACKUP_DIR/configs.tar.gz" /etc/postfix /etc/dovecot /etc/opendkim
tar czf "$BACKUP_DIR/vmail.tar.gz" /var/mail/vmail
docker exec mailserver-postgres pg_dump -U postgres mailserver | gzip > "$BACKUP_DIR/maildb.sql.gz"
EOF

chmod +x /root/backup-mail.sh
```

## Performance Tuning

For high-volume servers, consider in `group_vars/all.yml`:
```yaml
# Add these to group_vars/all.yml for production:
postfix_smtpd_client_connection_rate_limit: 100
postfix_smtpd_client_message_rate_limit: 100
dovecot_mail_max_userip_connections: 50
```

## Support

### Getting Help
1. Review IMPROVEMENTS_SUMMARY.md for what changed
2. Check `/var/log/mail.log` on server for errors
3. Run test playbook: `./run_task.sh 2.2.4`
4. Review test report: `ssh cucho1.phalkons.com "cat /root/mail_system_test_report.txt"`

### Reporting Issues
Include:
- Task that failed (e.g., 2.2.2)
- Output with `-vv` flag
- Service logs from server
- Test report if available

## What's Next

After successful deployment:

1. ✅ Add real domains to PostgreSQL
2. ✅ Configure DNS records (see `/root/dns_records.txt`)
3. ✅ Replace self-signed SSL with Let's Encrypt
4. ✅ Set up SOGo webmail (if needed)
5. ✅ Configure monitoring
6. ✅ Set up automated backups
7. ✅ Test with external email services

---

**Version:** 2.0 (Enhanced for Your Setup)  
**Server:** cucho1.phalkons.com (45.32.207.84)  
**Last Updated:** January 2026  
**Tested On:** Debian 13 (Trixie) with Dovecot 2.4.1, Postfix 3.10.4, PostgreSQL 17
