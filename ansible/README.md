> **Note:** Older, obsolete documentation has been moved to the `ansible/archive` and `docs/archive` directories for historical reference. This README is the current single source of truth.

# Improved Mail Server Playbooks for Debian 13
# Mail Server PoC - Complete Implementation Guide

**Comprehensive documentation for all tasks from 1.2 through 2.2**

---

## 📊 Overall Status

**Milestone 1:** Environment Setup - **100% Complete (17/17 tasks)**  
**Milestone 2:** Mail Server Core - **60% Complete (6/10 tasks)**

```
Progress: ████████████████████░░░░░ 68% (23/33 tasks)
```

| Task Group | Tasks | Status | Description |
|-----------|-------|--------|-------------|
| **1.2** | 7 | ✅ 100% | User administration, SSH, Docker |
| **1.3** | 5 | ✅ 100% | System hardening, VPN, fail2ban |
| **1.4** | 3 | ✅ 100% | Directory structure & permissions |
| **1.5** | 1 | ⏭️ 0% | UFW firewall (optional) |
| **2.1** | 4 | ✅ 75% | PostgreSQL deployment & schema |
| **2.2** | 5 | ✅ 60% | Mail services & SSL |

**Next Task:** 2.2.4 - Generate Let's Encrypt SSL Certificates

---

## 🖥️ System Configuration

```yaml
Server: cucho1.phalkons.com
Public IP: 45.32.207.84
VPN IP: 10.100.0.25 (WireGuard)
Domain: phalkons.com
OS: Debian 13.3 (Trixie)

Services:
  PostgreSQL: 10.100.0.25:5432 (VPN-only) ✅
  Postfix: ports 25, 587 ✅
  Dovecot: ports 143, 993 ✅
  OpenDKIM: milter port 8891 ✅

Test Account:
  Email: testuser1@phalkons.com
  Password: TestPass123!
  Maildir: /var/mail/vmail/phalkons.com/testuser1/
```

---

# 📖 Task Documentation

Below is complete documentation for all tasks from 1.2 through 2.2, with verification steps for each.

---

# MILESTONE 1: Environment Setup ✅

## Task Group 1.2: System User Administration ✅

### Task 1.2.1: Modify Sudoers (NOPASSWD) ✅

**Run:** `./run_task.sh 1.2.1`

**What it does:** Adds NOPASSWD to sudo group

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25 'sudo ls'  # No password prompt
cat /etc/sudoers.d/sudo_nopasswd  # Shows NOPASSWD rule
```

---

### Task 1.2.2: Remove linuxuser ✅

**Run:** `./run_task.sh 1.2.2`

**What it does:** Removes default linuxuser account

**Verify:**
```bash
id linuxuser  # Expected: no such user
```

---

### Task 1.2.3: Create phalkonadmin User ✅

**Run:** `./run_task.sh 1.2.3`

**What it does:** Creates phalkonadmin user (UID 1000)

**Verify:**
```bash
id phalkonadmin
# Expected: uid=1000(phalkonadmin) gid=1000(phalkonadmin) groups=1000(phalkonadmin),27(sudo)
```

---

### Task 1.2.4: Configure SSH Key Authentication ✅

**Run:** `./run_task.sh 1.2.4`

**What it does:** Sets up key-based SSH, disables password auth

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25  # Should connect with key
grep "PasswordAuthentication" /etc/ssh/sshd_config  # Should be "no"
```

---

### Task 1.2.5: Test SSH Connection ✅

**Run:** `./run_task.sh 1.2.5`

**What it does:** Validates SSH connectivity

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25 'hostname && whoami && sudo whoami'
# Expected: cucho1, phalkonadmin, root
```

---

### Task 1.2.6: Install Docker ✅

**Run:** `./run_task.sh 1.2.6`

**What it does:** Installs Docker & Docker Compose

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25 'docker --version && docker compose version && docker ps'
# All should work without sudo
```

---

### Task 1.2.7: Cleanup and Verification ✅

**Run:** `./run_task.sh 1.2.7`

**What it does:** Final cleanup and verification

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25 'id -u'  # Expected: 1000
```

---

## Task Group 1.3: System Hardening ✅

### Task 1.3.1: Basic System Hardening ✅

**Run:** `./run_task.sh 1.3.1`

**What it does:** SSH hardening, auto-updates, sysctl hardening

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25 'sudo sshd -T | grep "permitrootlogin\|passwordauthentication"'
# Both should be "no"
systemctl status unattended-upgrades  # Should be active
```

---

### Task 1.3.2: Install WireGuard VPN ✅

**Run:** `./run_task.sh 1.3.2`

**What it does:** Sets up WireGuard VPN (10.100.0.25/24)

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25 'sudo wg show'  # Shows wg0 interface
ip addr show wg0  # Shows 10.100.0.25/24
ping 10.100.0.25  # Should respond
```

---

### Task 1.3.3: Verify Network Interfaces ✅

**Run:** `./run_task.sh 1.3.3`

**What it does:** Validates network configuration

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25 'ip addr'  # Shows eth0, wg0, lo
```

---

### Task 1.3.4: Restrict SSH to VPN Only ✅

**Run:** `./run_task.sh 1.3.4`

**What it does:** SSH listens ONLY on VPN IP

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25 'sudo sshd -T | grep listenaddress'
# Expected: listenaddress 10.100.0.25

ssh phalkonadmin@45.32.207.84  # Should FAIL
ssh phalkonadmin@10.100.0.25   # Should work
```

⚠️ **WARNING:** After this, SSH is ONLY via VPN

---

### Task 1.3.5: Install fail2ban ✅

**Run:** `./run_task.sh 1.3.5`

**What it does:** Installs fail2ban for SSH protection

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25 'sudo fail2ban-client status sshd'
# Shows SSH jail active
```

---

## Task Group 1.4: Directory Structure ✅

### Task 1.4.1: Create Mail Directories ✅

**Run:** `./run_task.sh 1.4.1`

**What it does:** Creates mail and database directory structure

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25 'ls -la /var/mail/ /opt/postgres/ /opt/mail_server/'
# Shows vmail/, queue/, backups/, data/, etc.
```

---

### Task 1.4.2: Set Directory Permissions ✅

**Run:** `./run_task.sh 1.4.2`

**What it does:** Creates vmail/postgres users, sets permissions

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25 'id vmail && id postgres'
# vmail: uid=5000, postgres: uid=999

ls -ld /var/mail/vmail  # drwx------ vmail vmail
```

---

### Task 1.4.3: Prepare Disk Quotas ✅

**Run:** `./run_task.sh 1.4.3`

**What it does:** Installs quota tools (not enabled)

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25 'which quotacheck'
# Shows path if installed
```

---

# MILESTONE 2: Mail Server Core 🔄

## Task Group 2.1: PostgreSQL Database ✅

### Task 2.1.1: Deploy PostgreSQL Container ✅

**Run:** `./run_task.sh 2.1.1`

**What it does:** Deploys PostgreSQL 17 container on VPN IP

**Verify:**
```bash
ssh phalkonadmin@10.100.0.25 'docker ps | grep postgres'
# Shows mailserver-postgres running

docker exec mailserver-postgres pg_isready
# Expected: accepting connections

docker exec mailserver-postgres psql -U postgres -c "SELECT version();"
# Shows PostgreSQL 17
```

**Container:** mailserver-postgres (10.100.0.25:5432)

---

### Task 2.1.2: Configure Mail Database Schema ✅

**Run:** `./run_task.sh 2.1.2`

**What it does:** Creates tables, users, test data

**Verify:**
```bash
# Check tables
docker exec mailserver-postgres psql -U postgres -d mailserver -c "\dt"
# Expected: domain, mailbox, alias

# Check test domain
docker exec mailserver-postgres psql -U postgres -d mailserver -c "SELECT domain FROM domain;"
# Expected: phalkons.com

# Check test user
docker exec mailserver-postgres psql -U postgres -d mailserver -c "SELECT username FROM mailbox;"
# Expected: testuser1@phalkons.com
```

**Schema:** domain, mailbox, alias tables  
**Users:** postfix_user, dovecot_user, sogo_user  
**Test data:** phalkons.com domain, testuser1@phalkons.com

---

### Task 2.1.3: Configure Database Backups ⏭️

**Status:** Skipped for PoC

---

### Task 2.1.4: Verify PostgreSQL Setup ✅

**Run:** `./run_task.sh 2.1.4`

**What it does:** Comprehensive database verification

**Verify:**
```bash
# Automatic verification in playbook
./run_task.sh 2.1.4

# Manual check
docker exec mailserver-postgres psql -U postgres -d mailserver -c "
SELECT 'Tables' as check, COUNT(*)::text FROM information_schema.tables WHERE table_schema='public'
UNION ALL SELECT 'Users', COUNT(*)::text FROM pg_roles WHERE rolname IN ('postfix_user','dovecot_user','sogo_user');"
```

---

## Task Group 2.2: Mail Services ✅ (3/5 complete)

### Task 2.2.1: Install Postfix MTA ✅ COMPLETE

**Run:** `./run_task.sh 2.2.1`

**What it does:** Installs Postfix with PostgreSQL integration

**Verify:**
```bash
# Service status
sudo systemctl status postfix  # active (running)

# Ports
sudo ss -tlnp | grep -E ":(25|587)"
# Expected: master on both ports

# Database lookups
sudo postmap -q phalkons.com pgsql:/etc/postfix/pgsql-virtual-mailbox-domains.cf
# Expected: phalkons.com

sudo postmap -q testuser1@phalkons.com pgsql:/etc/postfix/pgsql-virtual-mailbox-maps.cf
# Expected: testuser1@phalkons.com

# Mail queue
mailq  # Should be empty

# SMTP test
telnet localhost 25
# Type: EHLO localhost
# Expected: 250-cucho1.phalkons.com
```

**Config:**
- `/etc/postfix/main.cf`
- `/etc/postfix/pgsql-virtual-mailbox-domains.cf`
- `/etc/postfix/pgsql-virtual-mailbox-maps.cf`

**Ports:** 25 (SMTP), 587 (Submission)

---

### Task 2.2.2: Install Dovecot IMAP ✅ COMPLETE

**Run:** `./run_task.sh 2.2.2`

**What it does:** Installs Dovecot 2.4 with inline SQL auth

**Verify:**
```bash
# Service status
sudo systemctl status dovecot  # active (running)

# Ports
sudo ss -tlnp | grep dovecot
# Expected: Ports 143 and 993

# Authentication
sudo doveadm auth test testuser1@phalkons.com TestPass123!
# Expected: passdb: testuser1@phalkons.com auth succeeded

# LMTP socket
sudo ls -la /var/run/dovecot/lmtp
# Should exist

# IMAP test
openssl s_client -connect localhost:993 -quiet
# Type: a login testuser1@phalkons.com TestPass123!
# Expected: a OK Logged in
```

**Critical Dovecot 2.4 Config:**

`/etc/dovecot/conf.d/10-auth.conf`:
```
sql_driver = pgsql

pgsql localhost {
  parameters {
    user = dovecot_user
    password = [generated]
    dbname = mailserver
    host = 10.100.0.25
  }
}

passdb sql {
  query = SELECT username AS user, password FROM mailbox WHERE username = '%{user}' AND active = true
}

userdb sql {
  query = SELECT 'maildir:/var/mail/vmail/' || maildir AS mail, 5000 AS uid, 5000 AS gid FROM mailbox WHERE username = '%{user}' AND active = true
}
```

**Ports:** 143 (IMAP), 993 (IMAPS)

---

### Task 2.2.3: Configure OpenDKIM ✅ COMPLETE

**Run:** `./run_task.sh 2.2.3`

**What it does:** Sets up DKIM signing for emails

**Verify:**
```bash
# Service status
sudo systemctl status opendkim  # active (running)

# View public key
sudo cat /etc/opendkim/keys/phalkons.com/mail.txt

# View DNS records
sudo cat /root/dns_records.txt

# Test config
sudo opendkim -n  # Configuration OK

# Test key (will fail until DNS configured)
sudo opendkim-testkey -d phalkons.com -s mail -vvv

# Postfix integration
sudo postconf | grep milter
# Should show opendkim milter settings
```

**DNS Records Required:**

View with: `sudo cat /root/dns_records.txt`

Add to DNS:
1. **DKIM**: `mail._domainkey.phalkons.com` TXT record
2. **SPF**: `phalkons.com` TXT `v=spf1 mx ip4:45.32.207.84 -all`
3. **DMARC**: `_dmarc.phalkons.com` TXT `v=DMARC1; p=none; rua=mailto:postmaster@phalkons.com`

**Test DNS:**
```bash
# After adding DNS (wait 5-15 min):
dig mail._domainkey.phalkons.com TXT +short

# Retest key
sudo opendkim-testkey -d phalkons.com -s mail -vvv
# Expected: "key secure" or "key OK"
```

**Config:**
- `/etc/opendkim/KeyTable` - Key locations
- `/etc/opendkim/SigningTable` - Signing rules
- `/etc/opendkim/keys/phalkons.com/mail.private` - Private key

---

### Task 2.2.4: Generate Let's Encrypt SSL ⏭️ NEXT

**Status:** Ready to run

**Run:** `./run_task.sh 2.2.4`

**What it will do:**
- Install certbot
- Generate SSL for cucho1.phalkons.com & mail.phalkons.com
- Update Postfix & Dovecot configs
- Setup auto-renewal

**Prerequisites:**
```bash
# Ensure DNS A records exist:
dig cucho1.phalkons.com A +short  # 45.32.207.84
dig mail.phalkons.com A +short     # 45.32.207.84
```

**Current:** Self-signed certificates (ssl-cert-snakeoil)  
**After:** Let's Encrypt certificates

---

### Task 2.2.5: End-to-End Testing ⏭️ PLANNED

**Status:** Not started

**Run:** `./run_task.sh 2.2.5`

**What it will test:**
- Service status (all services)
- Database connectivity
- Authentication
- Ports (25, 587, 143, 993)
- Mail delivery (SMTP → LMTP → Maildir)
- DKIM signing
- SSL/TLS
- System health score (0-100%)

**Report:** `/root/mail_system_test_report.txt`

---

# 🔍 Complete System Verification

## Quick Health Check

```bash
ssh phalkonadmin@10.100.0.25 'bash -s' << 'EOF'
echo "=== System Health ===" 

echo "1. PostgreSQL:"
docker ps --filter name=mailserver-postgres --format "{{.Status}}"

echo "2. Services:"
systemctl is-active postfix dovecot opendkim

echo "3. Ports:"
ss -tlnp | grep -E ":(25|587|143|993|5432|8891)" | awk '{print $4}'

echo "4. Database:"
docker exec mailserver-postgres psql -U postgres -d mailserver -c "SELECT COUNT(*) FROM domain;" -t

echo "5. Postfix Lookup:"
postmap -q phalkons.com pgsql:/etc/postfix/pgsql-virtual-mailbox-domains.cf

echo "6. Dovecot Auth:"
doveadm auth test testuser1@phalkons.com TestPass123! 2>&1 | grep "auth "

echo "=== Complete ==="
EOF
```

---

# 🐛 Troubleshooting

## Postfix Can't Connect to Database

```bash
# Test connection
docker exec mailserver-postgres psql -U postfix_user -d mailserver -h 10.100.0.25 -c "SELECT 1;"

# Check config
sudo grep "hosts" /etc/postfix/pgsql-*.cf  # Should be 10.100.0.25

# Test lookup
sudo postmap -q phalkons.com pgsql:/etc/postfix/pgsql-virtual-mailbox-domains.cf
```

## Dovecot Authentication Fails

```bash
# Test auth
sudo doveadm auth test testuser1@phalkons.com TestPass123!

# Check user exists
docker exec mailserver-postgres psql -U postgres -d mailserver -c "SELECT username FROM mailbox WHERE username='testuser1@phalkons.com';"

# Generate new password
HASH=$(sudo doveadm pw -s SHA512-CRYPT -p 'TestPass123!')
echo $HASH

# Update password
docker exec mailserver-postgres psql -U postgres -d mailserver -c "UPDATE mailbox SET password='$HASH' WHERE username='testuser1@phalkons.com';"
```

## OpenDKIM Won't Start

```bash
# Check config
sudo opendkim -n

# Check logs
sudo journalctl -u opendkim -n 50 --no-pager

# Verify KeyTable format
sudo cat /etc/opendkim/KeyTable
# Expected: mail._domainkey.phalkons.com phalkons.com:mail:/etc/opendkim/keys/phalkons.com/mail.private

# Check PID directory
sudo ls -la /run/opendkim/
# If missing:
sudo mkdir -p /run/opendkim && sudo chown opendkim:opendkim /run/opendkim
sudo systemctl restart opendkim
```

## Email Not Delivering

```bash
# Check queue
mailq

# Check logs
sudo tail -50 /var/log/mail.log

# Test SMTP
telnet localhost 25
# EHLO localhost

# Check LMTP socket
sudo ls -la /var/run/dovecot/lmtp

# Send test email
echo "Test" | mail -s "Test" testuser1@phalkons.com

# Check mailbox
sudo ls -la /var/mail/vmail/phalkons.com/testuser1/new/
```

---

# 💾 Database Management

## View Data

```bash
# Domains
docker exec mailserver-postgres psql -U postgres -d mailserver -c "SELECT domain, active FROM domain;"

# Mailboxes
docker exec mailserver-postgres psql -U postgres -d mailserver -c "SELECT username, name, active FROM mailbox;"

# Aliases
docker exec mailserver-postgres psql -U postgres -d mailserver -c "SELECT address, goto FROM alias;"
```

## Add New User

```bash
# Generate password
HASH=$(sudo doveadm pw -s SHA512-CRYPT -p 'YourPassword')

# Insert user
docker exec mailserver-postgres psql -U postgres -d mailserver -c "
INSERT INTO mailbox (username, password, name, maildir, active) 
VALUES ('newuser@phalkons.com', '$HASH', 'New User', 'phalkons.com/newuser/', true);"

# Test
sudo doveadm auth test newuser@phalkons.com YourPassword
```

## Add Domain

```bash
docker exec mailserver-postgres psql -U postgres -d mailserver -c "
INSERT INTO domain (domain, active) VALUES ('newdomain.com', true);"

# Verify
sudo postmap -q newdomain.com pgsql:/etc/postfix/pgsql-virtual-mailbox-domains.cf
```

---

# 🔄 Backup & Recovery

## Create Backup

```bash
BACKUP_DIR="/var/mail/backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Configs
sudo tar czf "$BACKUP_DIR/configs.tar.gz" /etc/postfix /etc/dovecot /etc/opendkim

# Mail
sudo tar czf "$BACKUP_DIR/vmail.tar.gz" /var/mail/vmail

# Database
docker exec mailserver-postgres pg_dump -U postgres mailserver | gzip > "$BACKUP_DIR/mailserver.sql.gz"
```

## Restore

```bash
# Configs
sudo tar xzf /path/to/configs.tar.gz -C /

# Mail
sudo tar xzf /path/to/vmail.tar.gz -C /

# Database
gunzip < /path/to/mailserver.sql.gz | docker exec -i mailserver-postgres psql -U postgres mailserver

# Restart
sudo systemctl restart postfix dovecot opendkim
```

---

# 📊 Performance Monitoring

```bash
# Queue size
mailq | grep -c "^[A-F0-9]"

# Connections
sudo doveadm who

# Database size
docker exec mailserver-postgres psql -U postgres -c "SELECT pg_size_pretty(pg_database_size('mailserver'));"

# Disk usage
df -h /var/mail/vmail

# Memory
free -h
```

---

# ✅ Next Steps

1. **Add DNS Records** ⚠️ CRITICAL
   ```bash
   sudo cat /root/dns_records.txt
   ```

2. **Run Task 2.2.4** - SSL Certificates
   ```bash
   ./run_task.sh 2.2.4
   ```

3. **Run Task 2.2.5** - End-to-End Testing
   ```bash
   ./run_task.sh 2.2.5
   ```

4. **Test with Real Email**
   - Send email to Gmail
   - Receive email from Gmail
   - Check DKIM signatures

5. **Production Hardening**
   - Change DMARC to p=quarantine
   - Enable UFW (Task 1.5.1)
   - Add production accounts
   - Setup monitoring

---

# 📚 Quick Reference

```bash
# Connect
ssh phalkonadmin@10.100.0.25

# Services
sudo systemctl status postfix dovecot opendkim

# Logs
sudo tail -f /var/log/mail.log
sudo journalctl -u postfix -f

# Queue
mailq

# Auth test
sudo doveadm auth test testuser1@phalkons.com TestPass123!

# Database lookups
sudo postmap -q phalkons.com pgsql:/etc/postfix/pgsql-virtual-mailbox-domains.cf

# PostgreSQL
docker exec mailserver-postgres psql -U postgres -d mailserver

# Restart
sudo systemctl restart postfix dovecot opendkim

# Ports
sudo ss -tlnp | grep -E ":(25|587|143|993)"
```

---

**Version:** 4.0 Complete Reference  
**Server:** cucho1.phalkons.com (45.32.207.84 / 10.100.0.25)  
**Updated:** January 22, 2026  
**Status:** 68% Complete (23/33 tasks)  
**Next:** Task 2.2.4 - Let's Encrypt SSL Certificates
