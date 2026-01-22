# Quick Start Guide - Mail Server Setup

## Your Configuration

- **Server:** cucho1.phalkons.com
- **Public IP:** 45.32.207.84
- **VPN IP:** 10.100.0.25
- **Domain:** phalkons.com
- **PostgreSQL:** Running at 10.100.0.25:5432 (database: mailserver)

## Before You Start

### ✅ Prerequisites Checklist

- [ ] Debian 13 installed on cucho1.phalkons.com
- [ ] PostgreSQL 17 container running
- [ ] Database `mailserver` created
- [ ] Database users created: `postfix_user`, `dovecot_user`
- [ ] Credentials saved in `/root/postgres_service_users.txt`
- [ ] Tables created: `domain`, `mailbox`, `alias`
- [ ] Test user added to database
- [ ] VPN connection established (10.100.0.0/24)
- [ ] SSH access configured (port 2288, user phalkonadmin)

### ✅ Files in Place

Your Ansible setup should have:
```
ansible/
├── ansible.cfg              # ✅ Your config
├── inventory.yml            # ✅ Your inventory
├── group_vars/
│   └── all.yml             # ✅ Your variables
└── playbooks/
    ├── task_2_2_1.yml      # ✅ Install Postfix
    ├── task_2_2_2.yml      # ✅ Install Dovecot
    ├── task_2_2_3.yml      # ✅ Install OpenDKIM
    ├── task_2_2_4.yml      # ✅ Test system
    └── reusable/           # ✅ Reusable playbooks
```

## Step-by-Step Installation

### Step 1: Verify Your Environment

```bash
# Check you can connect to server:
ssh phalkonadmin@45.32.207.84 -p 2288 -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common

# Or via VPN:
ssh phalkonadmin@10.100.0.25 -p 2288 -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common

# Exit and return to control machine
exit
```

### Step 2: Set Environment Variables

```bash
# Required for run_task.sh:
export MAIL_SERVER_IP="45.32.207.84"
export MAIL_SERVER_PASS="your_root_password"  # If still needed

# After Task 1.3.2:
export ANSIBLE_REMOTE_PORT="2288"
export ANSIBLE_REMOTE_USER="phalkonadmin"
export ANSIBLE_PRIVATE_KEY_FILE="~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common"

# To use VPN (optional):
export ANSIBLE_HOST="10.100.0.25"
```

### Step 3: Install Postfix (Task 2.2.1)

```bash
# Using run_task.sh:
./run_task.sh 2.2.1

# Or directly:
cd ansible
ansible-playbook playbooks/task_2_2_1.yml

# Expected output:
# ✓ Postfix installed
# ✓ PostgreSQL integration configured
# ✓ Ports 25 and 587 listening
```

**What to verify:**
```bash
# On server:
ssh phalkonadmin@cucho1.phalkons.com -p 2288

# Check Postfix status:
sudo systemctl status postfix

# Test database lookup:
sudo postmap -q testdomain.local pgsql:/etc/postfix/pgsql-virtual-mailbox-domains.cf
# Should return: 1

exit
```

### Step 4: Install Dovecot (Task 2.2.2)

```bash
# Using run_task.sh:
./run_task.sh 2.2.2

# Or directly:
ansible-playbook playbooks/task_2_2_2.yml

# Expected output:
# ✓ Dovecot 2.4 installed
# ✓ dovecot-pgsql package installed (critical!)
# ✓ SQL authentication configured
# ✓ Port 993 listening
```

**What to verify:**
```bash
# On server:
ssh phalkonadmin@cucho1.phalkons.com -p 2288

# Check Dovecot status:
sudo systemctl status dovecot

# Test authentication:
sudo doveadm auth test testuser1@testdomain.local TestPass123!
# Should show: passdb: testuser1@testdomain.local auth succeeded

exit
```

### Step 5: Install OpenDKIM (Task 2.2.3)

```bash
# Using run_task.sh:
./run_task.sh 2.2.3

# Or directly:
ansible-playbook playbooks/task_2_2_3.yml

# Expected output:
# ✓ OpenDKIM installed
# ✓ DKIM keys generated
# ✓ DNS records documented
```

**What to do next:**
```bash
# On server, view DNS records:
ssh phalkonadmin@cucho1.phalkons.com -p 2288
sudo cat /root/dns_records.txt
sudo cat /root/dns_records_quick.txt
exit

# Add these DNS records to your DNS provider for:
# - phalkons.com
# - testdomain.local (if publicly accessible)
```

### Step 6: Test Everything (Task 2.2.4)

```bash
# Using run_task.sh:
./run_task.sh 2.2.4

# Or directly:
ansible-playbook playbooks/task_2_2_4.yml

# Expected output:
# 🎯 OVERALL HEALTH: 90%+ - EXCELLENT ✓✓✓
# All services running
# Mail delivery working
```

**What to verify:**
```bash
# View full test report on server:
ssh phalkonadmin@cucho1.phalkons.com -p 2288
sudo cat /root/mail_system_test_report.txt
exit
```

## Verification Checklist

After all tasks complete:

### Services Running
```bash
ssh phalkonadmin@cucho1.phalkons.com -p 2288
sudo systemctl status postfix dovecot opendkim
```

All should show: **Active: active (running)**

### Ports Listening
```bash
sudo ss -tlnp | grep -E ':(25|587|993)'
```

Should show:
- **Port 25** - SMTP (Postfix)
- **Port 587** - Submission (Postfix)
- **Port 993** - IMAPS (Dovecot)

### Database Connectivity
```bash
# Test Postfix can read domains:
sudo postmap -q testdomain.local pgsql:/etc/postfix/pgsql-virtual-mailbox-domains.cf

# Test Postfix can read users:
sudo postmap -q testuser1@testdomain.local pgsql:/etc/postfix/pgsql-virtual-mailbox-maps.cf

# Test Dovecot authentication:
sudo doveadm auth test testuser1@testdomain.local TestPass123!
```

### Mail Delivery Test
```bash
# Send test email:
echo "Test email body" | mail -s "Test Subject" testuser1@testdomain.local

# Check if delivered:
sudo ls -la /var/mail/vmail/testdomain.local/testuser1/new/

# Should see email file(s)
```

### DKIM Signing
```bash
# Check a delivered email for DKIM signature:
sudo cat /var/mail/vmail/testdomain.local/testuser1/new/* | grep -i "DKIM-Signature"

# Should show: DKIM-Signature: v=1; a=rsa-sha256; ...
```

## Common Issues and Solutions

### Issue 1: Can't Connect to Server

**Problem:** Connection refused or timeout

**Solution:**
```bash
# Verify environment variables:
echo $ANSIBLE_HOST
echo $ANSIBLE_REMOTE_PORT
echo $ANSIBLE_REMOTE_USER

# Should be:
# ANSIBLE_HOST: 10.100.0.25 (VPN) or 45.32.207.84 (public)
# ANSIBLE_REMOTE_PORT: 2288
# ANSIBLE_REMOTE_USER: phalkonadmin

# Test SSH manually:
ssh -p 2288 phalkonadmin@10.100.0.25 -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
```

### Issue 2: Password Retrieval Failed

**Problem:** "Failed to retrieve valid Dovecot password"

**Solution:**
```bash
# On server, check credentials file format:
ssh phalkonadmin@cucho1.phalkons.com -p 2288
sudo cat /root/postgres_service_users.txt

# Should contain:
# Postfix (Mail Routing):
#   Username: postfix_user
#   Password: actual_password_here
#
# Dovecot (IMAP/POP3 Authentication):
#   Username: dovecot_user
#   Password: actual_password_here

# If missing, recreate the file with proper format
```

### Issue 3: Dovecot Won't Start

**Problem:** Dovecot service fails to start

**Solution:**
```bash
# On server:
ssh phalkonadmin@cucho1.phalkons.com -p 2288

# Check what's wrong:
sudo journalctl -u dovecot -n 50 --no-pager

# Common fixes:

# 1. Check if dovecot-pgsql is installed:
dpkg -l | grep dovecot-pgsql
# If not: sudo apt install dovecot-pgsql

# 2. Test configuration syntax:
sudo doveconf -n

# 3. Check auth_username_format is commented:
sudo grep "auth_username_format" /etc/dovecot/conf.d/10-auth.conf
# Should show: #auth_username_format = %u

# 4. Re-run playbook:
exit
ansible-playbook playbooks/task_2_2_2.yml
```

### Issue 4: Mail Not Delivering

**Problem:** Test emails don't appear in mailbox

**Solution:**
```bash
# On server:
ssh phalkonadmin@cucho1.phalkons.com -p 2288

# 1. Check mail logs:
sudo tail -n 100 /var/log/mail.log | grep -i error

# 2. Check Postfix queue:
sudo mailq

# 3. Verify mailbox directory exists:
sudo ls -la /var/mail/vmail/testdomain.local/testuser1/
# Should have: new/ cur/ tmp/ directories

# 4. Check permissions:
sudo ls -ld /var/mail/vmail/
# Should be: drwxr-x--- vmail vmail

# 5. Test database lookup:
sudo postmap -q testdomain.local pgsql:/etc/postfix/pgsql-virtual-mailbox-domains.cf
sudo postmap -q testuser1@testdomain.local pgsql:/etc/postfix/pgsql-virtual-mailbox-maps.cf
```

### Issue 5: Health Score Below 90%

**Problem:** Test playbook shows health score below 90%

**Solution:**
```bash
# View detailed report:
ssh phalkonadmin@cucho1.phalkons.com -p 2288
sudo cat /root/mail_system_test_report.txt

# Look for failed checks and fix them individually
# Then re-run test:
exit
ansible-playbook playbooks/task_2_2_4.yml
```

## Rollback if Needed

If something goes wrong with any component:

```bash
# Rollback Postfix:
ansible-playbook playbooks/rollback_postfix.yml

# Rollback Dovecot:
ansible-playbook playbooks/rollback_dovecot.yml

# Rollback OpenDKIM:
ansible-playbook playbooks/rollback_opendkim.yml

# Then fix the issue and re-run the installation task
```

## DNS Configuration (After Task 2.2.3)

### Required DNS Records for phalkons.com

Add these to your DNS provider (GoDaddy, Cloudflare, etc.):

1. **MX Record**
   ```
   Type: MX
   Name: @
   Priority: 10
   Value: cucho1.phalkons.com
   TTL: 3600
   ```

2. **A Record for Mail Server**
   ```
   Type: A
   Name: cucho1
   Value: 45.32.207.84
   TTL: 3600
   ```

3. **SPF Record**
   ```
   Type: TXT
   Name: @
   Value: v=spf1 ip4:45.32.207.84 -all
   TTL: 3600
   ```

4. **DKIM Record**
   ```
   Get from server: sudo cat /root/dns_records_quick.txt
   Copy the DKIM record exactly as shown
   ```

5. **DMARC Record**
   ```
   Type: TXT
   Name: _dmarc
   Value: v=DMARC1; p=quarantine; rua=mailto:postmaster@phalkons.com
   TTL: 3600
   ```

6. **PTR Record (Reverse DNS)**
   ```
   Configure in Vultr control panel:
   IP: 45.32.207.84
   Points to: cucho1.phalkons.com
   ```

### Verify DNS After 15 Minutes

```bash
# Check DNS propagation:
dig phalkons.com MX
dig phalkons.com TXT
dig mail._domainkey.phalkons.com TXT
dig _dmarc.phalkons.com TXT
dig -x 45.32.207.84

# Test DKIM:
ssh phalkonadmin@cucho1.phalkons.com -p 2288
sudo opendkim-testkey -d phalkons.com -s mail -vvv
```

## Next Steps

After successful installation:

1. ✅ **Test Email Delivery**
   - Send email from Gmail to testuser1@testdomain.local
   - Check /var/mail/vmail/testdomain.local/testuser1/new/

2. ✅ **Add Real Domains**
   - Add phalkons.com to PostgreSQL `domain` table
   - Add real users to `mailbox` table

3. ✅ **Replace SSL Certificate**
   - Install certbot
   - Get Let's Encrypt certificate for cucho1.phalkons.com
   - Update `group_vars/all.yml` with new paths

4. ✅ **Set Up Monitoring**
   - Configure health checks
   - Set up log monitoring
   - Create backup automation

5. ✅ **Test with External Services**
   - Send to Gmail, Outlook, etc.
   - Check mail-tester.com score
   - Verify SPF/DKIM/DMARC

## Support

**View logs on server:**
```bash
ssh phalkonadmin@cucho1.phalkons.com -p 2288
sudo tail -f /var/log/mail.log
```

**Re-run tests anytime:**
```bash
ansible-playbook playbooks/task_2_2_4.yml
```

**Check service status:**
```bash
ssh phalkonadmin@cucho1.phalkons.com -p 2288
sudo systemctl status postfix dovecot opendkim
```

---

**Your Setup:** cucho1.phalkons.com (45.32.207.84 / VPN 10.100.0.25)
**Ready to Deploy!** 🚀
