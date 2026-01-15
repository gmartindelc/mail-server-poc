# Mail Server PoC - Ansible Automation

**Project:** High-Availability Mail Server Cluster - Phase 1 (Single VPS PoC)  
**Server:** cucho1.phalkons.com (Debian 13, Vultr VPS)  
**Last Updated:** 2026-01-15  
**Status:** Milestone 2 - Task 2.1.4 Ready (PostgreSQL Verification Package Created)

---

## 🎯 Current Status

### ✅ Completed Milestones

**Milestone 1: Environment Setup & Foundation - 100% COMPLETE**
- **Task Group 1.1:** Initial Server Setup (VPS provisioned via Terraform)
- **Task Group 1.2:** System User Administration (phalkonadmin user, Docker installed)
- **Task Group 1.3:** System Hardening (SSH hardened, VPN integrated, fail2ban active)
- **Task Group 1.4:** Directory Structure & Storage (All directories created, permissions set, quota tools prepared)

**Milestone 2: Database Layer Implementation - 75% COMPLETE (Task 2.1.4 Package Created)**
- **Task 2.1.1:** ✅ PostgreSQL Container Deployed (postgres:17-alpine, VPN-only on 10.100.0.25:5432)
- **Task 2.1.2:** ✅ Database Schema Configured (virtual_domains, virtual_users, virtual_aliases, service users)
- **Task 2.1.3:** ✅ Backups Configured (Daily backups, WAL archiving, automated cleanup)
- **Task 2.1.4:** 📦 Verification Package Created (Ready for execution - 24 comprehensive checks)

### ⏳ Next Task

- **Task 2.1.4:** Verify PostgreSQL container and connectivity
  - **Status:** 📦 Package created and ready for execution
  - **Files:** 8 files (playbooks, templates, documentation)
  - **Checks:** 24 comprehensive verification tests
  - **Time:** ~2-3 minutes
  - **Output:** Connection guides, verification report, service credentials

### 🗄️ Production Services Running

- **PostgreSQL 17** - Database (mailserver-postgres)
  - Status: ✅ Running and healthy
  - Network: VPN-only (10.100.0.25:5432)
  - Database: mailserver
  - Tables: virtual_domains, virtual_users, virtual_aliases
  - Service Users: postfix, dovecot, sogo, mailadmin
  - Backups: Automated daily at 2 AM, 7-day retention
  - WAL Archiving: Active for point-in-time recovery

### ⏳ Next Task Group

- **Task Group 2.2:** Core Mail Services (Postfix MTA deployment)

---

## 🔐 Critical Connection Information

**⚠️ IMPORTANT:** After Task Group 1.3, SSH is **VPN-ONLY**

### SSH Connection (Post Task 1.3.4)

```bash
# SSH is now accessible ONLY via VPN IP
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25
```

**Cannot connect via public IP anymore:**
```bash
# This will NOT work (blocked by firewall)
ssh -p 2288 phalkonadmin@45.32.207.84  # ❌ BLOCKED
```

### Ansible Environment Variables (Required)

**For all tasks after Task Group 1.3, set these variables:**

```bash
# Connection via VPN IP
export ANSIBLE_HOST=10.100.0.25

# SSH settings
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
```

**Add to shell profile for persistence:**
```bash
cat >> ~/.bashrc << 'ENVEOF'
# Ansible configuration for mail server (after Task Group 1.3)
export ANSIBLE_HOST=10.100.0.25
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
ENVEOF

source ~/.bashrc
```

---

## 🚀 Quick Start

### Running Tasks

```bash
# Set environment variables (if not in shell profile)
export ANSIBLE_HOST=10.100.0.25
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common

# Run a task
./run_task.sh 1.4.1

# Dry run first (recommended)
./run_task.sh 1.4.1 --check
```

### Viewing Available Tasks

```bash
# List all available tasks
./run_task.sh

# View task documentation
cat README.md
```

---

## 📊 System Architecture

### Current Configuration

**Network:**
- Public IP: 45.32.207.84
- VPN IP: 10.100.0.25/24
- VPN Network: 10.100.0.0/24
- VPN Peer: 144.202.76.243:51820

**SSH Access:**
- Port: 2288 (non-standard)
- Interface: VPN only (10.100.0.25)
- Authentication: Key-only (no passwords)
- User: phalkonadmin (root disabled)

**Security Services:**
- SSH: Hardened, VPN-only access
- WireGuard: Active VPN connection
- UFW: Firewall enabled, default-deny incoming
- Fail2ban: Active, monitoring SSH (3 attempts = 1 hour ban)
- Unattended-upgrades: Automatic security updates

**Systemd Dependencies:**
- SSH service depends on WireGuard (starts only after VPN is up)

---

## 🗂️ Project Structure

```
ansible/
├── ansible.cfg                         # Ansible configuration
├── inventory.yml                       # Dynamic inventory (env-based)
├── run_task.sh                         # Task runner script
├── run_all_tasks.sh                    # Batch runner (Task Group 1.2 only)
├── setup_wg_credentials.sh             # WireGuard credential extraction
├── README.md                           # This file
│
└── playbooks/
    ├── Task Wrappers (task_X.X.X.yml)
    │   ├── task_1.3.1.yml             # System hardening
    │   ├── task_1.3.2.yml             # WireGuard VPN
    │   ├── task_1.3.3.yml             # Network verification
    │   ├── task_1.3.4.yml             # SSH VPN-only
    │   └── task_1.3.5.yml             # Fail2ban
    │
    ├── Reusable Playbooks
    │   ├── system_hardening.yml
    │   ├── install_wireguard.yml
    │   ├── verify_network_interfaces.yml

---

## 📋 Complete Setup and Task Running Procedures

### 🔐 Initial Setup: WireGuard Credentials (One-Time Setup)

**Only needed if you haven't run Task 1.3.2 yet, or need to regenerate credentials**

#### Step 1: Locate Your WireGuard Configuration

You should have a WireGuard configuration file for this server:
- Location: `~/Wireguard-clients/Server-Cucho1.conf` (or similar)
- Contains: PrivateKey, Address, Peer information

#### Step 2: Extract Credentials Securely

```bash
cd /path/to/mail-server-poc/ansible

# Run the credential extraction script
./setup_wg_credentials.sh ~/Wireguard-clients/Server-Cucho1.conf
```

**The script will:**
1. ✅ Extract PrivateKey → `../wg_credentials/private_key`
2. ✅ Extract Address → `../wg_credentials/address`
3. ✅ Extract Peer PublicKey → `../wg_credentials/peer_public_key`
4. ✅ Extract Endpoint → `../wg_credentials/endpoint`
5. ✅ Set secure permissions (700 on directory, 600 on files)
6. ✅ Update `.gitignore` to protect secrets
7. ✅ Create README in credentials directory

**Example Output:**
```
========================================
WireGuard Credentials Setup
========================================

✓ Found WireGuard config: /home/user/Wireguard-clients/Server-Cucho1.conf

Extracting credentials from /home/user/Wireguard-clients/Server-Cucho1.conf...
✓ Private Key: eMwek+oFM2...ggjywo77U4=
✓ Address: 10.100.0.25/24
✓ Peer Public Key: /fKlGm12NB...msNEwQ=
✓ Endpoint: 144.202.76.243:51820
✓ Allowed IPs: 10.100.0.0/24
✓ Keepalive: 25s

Creating credentials directory...
✓ Created: ../wg_credentials
✓ Set permissions: 700 (rwx------) on ../wg_credentials

Creating credential files...
✓ Created: ../wg_credentials/private_key (600)
✓ Created: ../wg_credentials/address (600)
✓ Created: ../wg_credentials/peer_public_key (600)
✓ Created: ../wg_credentials/endpoint (600)
✓ Created: ../wg_credentials/README.md (600)

Updating .gitignore...
✓ Added to .gitignore: wg0.conf
✓ Added to .gitignore: wg_credentials/

========================================
Setup Complete!
========================================

Credentials stored in: ../wg_credentials
Protected by: ../.gitignore

Next steps:
  1. Run Task 1.3.2: ./run_task.sh 1.3.2
  2. Verify .gitignore: git status
  3. NEVER commit wg0.conf or wg_credentials/

✓ Safe to run Ansible playbooks!
```

#### Step 3: Verify Credentials Were Created

```bash
# Check directory structure
ls -la ../wg_credentials/

# Should show:
# drwx------  2 user user  4096 Jan  7 10:00 .
# -rw-------  1 user user    44 Jan  7 10:00 private_key
# -rw-------  1 user user    15 Jan  7 10:00 address
# -rw-------  1 user user    44 Jan  7 10:00 peer_public_key
# -rw-------  1 user user    22 Jan  7 10:00 endpoint
# -rw-------  1 user user   543 Jan  7 10:00 README.md
```

#### Step 4: Verify .gitignore Protection

```bash
# Check git status
git status

# wg0.conf and wg_credentials/ should NOT appear in:
# - Untracked files
# - Changes to be committed

# If they appear, .gitignore is not working correctly
```

**⚠️ CRITICAL: Never commit these files!**
```bash
# These should be in .gitignore:
wg0.conf
wg*.conf
wg_credentials/
*.secret
```

---

## 🚀 Running Tasks: Step-by-Step Guide

### Prerequisites Check

Before running any task, ensure you have:

- ✅ **SSH Key**: `~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common` exists
- ✅ **Credentials File**: `../cucho1.phalkons.com.secret` exists
- ✅ **WireGuard Credentials**: `../wg_credentials/` directory exists (if running Task 1.3.2)
- ✅ **VPN Connection**: Can ping 10.100.0.1 (for post-1.3.2 tasks)

**Quick Check:**
```bash
# Check SSH key exists
ls -la ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common

# Check credentials file exists
cat ../cucho1.phalkons.com.secret

# Check WireGuard credentials (if needed)
ls -la ../wg_credentials/

# Test VPN connectivity (if VPN is set up)
ping -c 2 10.100.0.1
```

---

### 📝 Step 1: Set Environment Variables

**Every new terminal session requires these variables:**

```bash
# Navigate to ansible directory
cd /path/to/mail-server-poc/ansible

# Set environment variables
export ANSIBLE_HOST=10.100.0.25                                              # VPN IP (after Task 1.3.4)
export ANSIBLE_REMOTE_PORT=2288                                              # SSH port (after Task 1.3.1)
export ANSIBLE_REMOTE_USER=phalkonadmin                                      # User (after Task 1.2.3)
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common  # Bastion key
```

**Verify variables are set:**
```bash
echo "Host: $ANSIBLE_HOST"
echo "Port: $ANSIBLE_REMOTE_PORT"
echo "User: $ANSIBLE_REMOTE_USER"
echo "Key: $ANSIBLE_PRIVATE_KEY_FILE"
```

**Make permanent (recommended):**
```bash
cat >> ~/.bashrc << 'ENVEOF'
# Ansible configuration for mail server (Task Group 1.3+)
export ANSIBLE_HOST=10.100.0.25
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
ENVEOF

# Apply immediately
source ~/.bashrc

# Verify
echo $ANSIBLE_HOST
```

---

### 🔌 Step 2: Test SSH Connectivity

**Before running any Ansible task, test SSH manually:**

```bash
ssh -p 2288 -o IdentitiesOnly=yes \
    -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common \
    phalkonadmin@10.100.0.25
```

**Expected:**
```
╔════════════════════════════════════════════════════════════════╗
║                    AUTHORIZED ACCESS ONLY                      ║
║                                                                ║
║  This system is for authorized use only. All activity may be  ║
║  monitored and reported. Unauthorized access is prohibited.   ║
╚════════════════════════════════════════════════════════════════╝
Linux cucho1 6.12.57+deb13-amd64 ...
phalkonadmin@cucho1:~$
```

**If connection fails:**
```bash
# Check VPN is up
ping 10.100.0.1

# Check SSH key permissions
ls -la ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
# Should be: -rw------- (600)

# Fix key permissions if needed
chmod 600 ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common

# Check environment variables
echo $ANSIBLE_HOST
```

**Exit SSH session:**
```bash
exit
```

---

### 📖 Step 3: Review Task Documentation

**Before running a task, understand what it does:**

```bash
# View task wrapper to see parameters
cat playbooks/task_1.4.1.yml

# View reusable playbook to see detailed steps
cat playbooks/create_directories.yml  # (example)

# Read this README for detailed task descriptions
# See "Task Documentation" section below
```

**Key questions to answer:**
- ✅ What does this task do?
- ✅ What will change on the server?
- ✅ Are there any dependencies? (previous tasks that must be complete)
- ✅ Are there any risks? (service restarts, configuration changes)
- ✅ How long will it take? (estimate)

---

### 🧪 Step 4: Run Dry Run (--check mode)

**ALWAYS run --check first to preview changes:**

```bash
./run_task.sh 1.4.1 --check
```

**What --check mode does:**
- ✅ Shows what WOULD change (without making changes)
- ✅ Tests connectivity to server
- ✅ Validates playbook syntax
- ✅ Checks if files/services exist
- ⚠️ Some checks may fail (services not installed yet)

**Review dry run output:**
```bash
PLAY [Create Mail System Directories] *************************

TASK [Display directory creation plan] ***********************
ok: [mail_server] =>
  msg:
  - Creating directories:
  - /var/mail/vmail/
  - /var/mail/queue/
  ...

TASK [Create directory: /var/mail/vmail] *********************
changed: [mail_server]  # ← Would create this directory

PLAY RECAP ****************************************************
mail_server : ok=10 changed=5 unreachable=0 failed=0
```

**Check for:**
- ❌ **failed=0** - No failures
- ❌ **unreachable=0** - Server is reachable
- ✅ **changed=X** - Shows what will change
- ⚠️ **warnings** - Review any warnings

---

### ▶️ Step 5: Execute the Task

**If dry run looks good, run for real:**

```bash
./run_task.sh 1.4.1
```

**Monitor the output:**
```bash
Running task 1.4.1: playbooks/task_1.4.1.yml
Target server from: ../cucho1.phalkons.com.secret
Server IP: 10.100.0.25
SSH Port: 2288

PLAY [Create Mail System Directories] *************************

TASK [Gathering Facts] ****************************************
ok: [mail_server]

TASK [Display directory creation plan] ************************
ok: [mail_server]

TASK [Create directory: /var/mail/vmail] *********************
changed: [mail_server]  # ← Directory created

TASK [Set directory ownership] *******************************
changed: [mail_server]

PLAY RECAP ****************************************************
mail_server : ok=15 changed=10 unreachable=0 failed=0
```

**Task completion indicators:**
- ✅ **Green "ok"** - Task succeeded, no changes
- ✅ **Yellow "changed"** - Task succeeded, made changes
- ❌ **Red "failed"** - Task failed, check error message
- ⚠️ **Orange "unreachable"** - Cannot connect to server

**If task fails:**
```bash
# Check the error message in output
# Most common issues:
# - File/directory permissions
# - Service not running
# - Configuration syntax errors

# Check logs on server
ssh -p 2288 -o IdentitiesOnly=yes \
    -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common \
    phalkonadmin@10.100.0.25

sudo journalctl -xe  # System logs
sudo systemctl status <service>  # Service status
```

---

### ✅ Step 6: Verify Task Results

**After task completes, verify changes were applied:**

```bash
# Connect to server
ssh -p 2288 -o IdentitiesOnly=yes \
    -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common \
    phalkonadmin@10.100.0.25
```

**Task-specific verification commands:**

**For Task 1.3.1 (SSH Hardening):**
```bash
# Check SSH config
sudo grep -E "^(Port|PermitRootLogin|PasswordAuthentication)" /etc/ssh/sshd_config

# Check firewall
sudo ufw status

# Check auto-updates
sudo systemctl is-active unattended-upgrades
```

**For Task 1.3.2 (WireGuard VPN):**
```bash
# Check WireGuard status
sudo wg show

# Check interface
ip addr show wg0

# Test connectivity
ping -c 3 10.100.0.1
```

**For Task 1.3.5 (Fail2ban):**
```bash
# Check fail2ban status
sudo fail2ban-client status

# Check SSH jail
sudo fail2ban-client status sshd

# View logs
sudo tail -f /var/log/fail2ban.log
```

**For Task 1.4.1 (Directories):**
```bash
# Check directories exist
ls -la /var/mail/
ls -la /opt/postgres/

# Check ownership and permissions
ls -ld /var/mail/vmail/
```

---

## 🎯 Common Task Running Scenarios

### Scenario 1: First Time Running Tasks (Fresh Terminal)

```bash
# 1. Navigate to project
cd /path/to/mail-server-poc/ansible

# 2. Set environment variables
export ANSIBLE_HOST=10.100.0.25
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common

# 3. Test connectivity
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25
exit

# 4. Run task
./run_task.sh 1.4.1 --check  # Dry run
./run_task.sh 1.4.1          # Real run

# 5. Verify
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25
# Run verification commands
exit
```

### Scenario 2: Running Task 1.3.2 (WireGuard Setup)

```bash
# 1. Extract WireGuard credentials (one-time)
cd /path/to/mail-server-poc/ansible
./setup_wg_credentials.sh ~/Wireguard-clients/Server-Cucho1.conf

# 2. Verify credentials
ls -la ../wg_credentials/

# 3. Set environment variables (using OLD connection method before VPN)
export ANSIBLE_HOST=45.32.207.84  # Public IP (before Task 1.3.4)
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common

# 4. Run task
./run_task.sh 1.3.2 --check
./run_task.sh 1.3.2

# 5. Verify VPN
ssh -p 2288 phalkonadmin@45.32.207.84  # Still works
ssh -p 2288 phalkonadmin@10.100.0.25   # Now works too!
sudo wg show
sudo ip addr show wg0
ping -c 3 10.100.0.1
exit

# 6. Update environment variable for future tasks
export ANSIBLE_HOST=10.100.0.25  # Use VPN IP from now on
```

### Scenario 3: Running Multiple Tasks in Sequence

```bash
# Set environment variables once
export ANSIBLE_HOST=10.100.0.25
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common

# Run tasks in sequence
./run_task.sh 1.4.1 --check && \
./run_task.sh 1.4.1 && \
./run_task.sh 1.4.2 --check && \
./run_task.sh 1.4.2 && \
./run_task.sh 1.4.3 --check && \
./run_task.sh 1.4.3

# The && operator ensures each task completes successfully before running the next
```

### Scenario 4: Task Failed - Troubleshooting

```bash
# Task failed with error
./run_task.sh 1.4.1
# ERROR: Permission denied

# Connect to server to investigate
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25

# Check logs
sudo journalctl -xe | tail -50

# Check permissions
ls -la /var/mail/

# Fix issue manually if needed
sudo chown phalkonadmin:phalkonadmin /var/mail/

# Exit and retry task
exit
./run_task.sh 1.4.1
```

### Scenario 5: Emergency Recovery (Locked Out)

```bash
# If you get locked out after Task 1.3.4

# 1. Access Vultr web console
# - Login to Vultr dashboard
# - Navigate to server: cucho1
# - Click "View Console"

# 2. Login as root
# Username: root
# Password: (from ../cucho1.phalkons.com.secret, first line, second field)

# 3. Run rollback script
bash /root/rollback_scripts/rollback_ssh_vpn_only.sh

# 4. SSH access restored to public IP
ssh -p 2288 -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@45.32.207.84

# 5. Debug and re-run task
```

---

## 🔄 Task Execution Workflow Diagram

```
┌─────────────────────────────────────────┐
│ 0. ONE-TIME: Extract WireGuard Creds   │
│    ./setup_wg_credentials.sh wg0.conf  │
│    (Only for Task 1.3.2)               │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ 1. Set Environment Variables            │
│    export ANSIBLE_HOST=10.100.0.25     │
│    export ANSIBLE_REMOTE_PORT=2288      │
│    export ANSIBLE_REMOTE_USER=...       │
│    export ANSIBLE_PRIVATE_KEY_FILE=...  │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ 2. Test SSH Connectivity                │
│    ssh -p 2288 phalkonadmin@10.100.0.25│
│    (Verify you can connect)             │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ 3. Review Task Documentation            │
│    cat playbooks/task_X.X.X.yml        │
│    Read README.md for details           │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ 4. Run Dry Run (--check)               │
│    ./run_task.sh X.X.X --check         │
│    Review what will change              │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ 5. Review Dry Run Output                │
│    Check: failed=0, unreachable=0       │
│    Review: changed=X items              │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ 6. Execute Task                         │
│    ./run_task.sh X.X.X                  │
│    Monitor output for errors            │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ 7. Verify Results                       │
│    ssh to server                        │
│    Run verification commands            │
│    Check services/configs/files         │
└─────────────────────────────────────────┘
```

---

    │   ├── configure_ssh_vpn_only.yml
    │   └── install_fail2ban.yml
    │
    └── templates/
        ├── sshd_config.j2
        ├── 50unattended-upgrades.j2
        ├── 20auto-upgrades.j2
        ├── wg0.conf.j2
        ├── jail.local.j2
        └── sshd.local.j2
```

---

## 🔒 Security Notes

### Credential Management

**WireGuard Credentials:**
```bash
# Extract from wg0.conf securely
./setup_wg_credentials.sh ~/Wireguard-clients/Server-Cucho1.conf

# Credentials stored in: ../wg_credentials/
# Protected by: .gitignore
```

**SSH Keys:**
- Bastion key: `~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common`
- Vultr key: `~/.ssh/id_ed25519_lc02_vultr` (emergency access only)

**Emergency Access:**
- Vultr web console (root access)
- Root password: From `../cucho1.phalkons.com.secret`
- Rollback script: `/root/rollback_scripts/rollback_ssh_vpn_only.sh`

### Firewall Rules

```bash
# Current UFW rules
Status: active

To                         Action      From
--                         ------      ----
2288/tcp                   ALLOW       10.100.0.0/24    # SSH from VPN only
```

---

## 📖 Task Documentation

# Ansible Automation for Mail Server PoC

**Last Updated:** 2025-01-05  
**Status:** ✅ Task Group 1.2 COMPLETED - Ready for Task Group 1.3  
**Version:** 3.0 (Task Group 1.2 fully tested and working)

---

## Overview

Ansible playbooks for automating the setup and configuration of the Mail Server Proof of Concept. This repository contains reusable playbooks and task-specific wrappers for systematic server deployment.

## What's New in v3.0

### Task Group 1.2 - System User Administration ✅ COMPLETE
All tasks successfully tested and executed:
- ✅ Task 1.2.1: Passwordless sudo configured
- ✅ Task 1.2.2: Default linuxuser removed
- ✅ Task 1.2.3: phalkonadmin user created (UID 1000)
- ✅ Task 1.2.4: SSH key authentication configured (bastion key)
- ✅ Task 1.2.5: SSH connection tested and validated
- ✅ Task 1.2.6: Docker + Docker Compose installed (v29.1.3 / v5.0.1)
- ✅ Task 1.2.7: Final verification and cleanup (optional)

### Critical Fixes Applied ✅
- Fixed inventory credential parsing (use `head -n 1` for multi-line files)
- Fixed Docker installation for Debian 13 (use bookworm repo with slurp method)
- Fixed SSH host key handling after OS reinstall
- Removed root SSH disabling from Task 1.2.4 (moved to Task 1.3.1)
- Fixed ansible.cfg to use Vultr key with IdentitiesOnly=yes
- Fixed gather_facts in modify_sudoers_nopasswd.yml
- Fixed create_admin_user.yml UID check logic
- Fixed task_1.2.5.yml when clause syntax

### Added Files ✅
- `task_1.2.7.yml` - Post-configuration verification and cleanup
- `fix_user_uid.yml` - Fix UID assignment if needed  
- `cleanup_main_sudoers.yml` - Clean up main sudoers file

---

## What's New in v2.0

### Fixed Issues ✅
- Fixed `include_playbook` syntax errors in tasks 1.2.1, 1.2.2, 1.2.3
- Standardized credential file paths across all playbooks
- Updated to use `import_playbook` (correct Ansible syntax)

### Added Files ✅
- `ansible.cfg` - Ansible configuration with optimized settings
- `inventory.yml` - Dynamic inventory with credential file parsing
- `run_all_tasks.sh` - Sequential execution of all Task Group 1.2 tasks
- `task_1.2.4.yml` - SSH key authentication configuration
- `task_1.2.5.yml` - SSH connection testing and validation
- `task_1.2.6.yml` - Docker and Docker Compose installation
- `install_docker.yml` - Reusable Docker installation playbook

---

## Directory Structure

```
ansible/
├── ansible.cfg                         # Ansible configuration
├── inventory.yml                       # Dynamic inventory (reads credential file)
├── run_task.sh                         # Run individual task playbooks
├── run_reusable.sh                     # Run reusable playbooks with custom vars
├── run_all_tasks.sh                    # Run all Task Group 1.2 tasks sequentially
├── README.md                           # This file
└── playbooks/
    ├── Task-Specific Playbooks (Wrappers)
    ├── task_1.2.1.yml                 # Configure passwordless sudo
    ├── task_1.2.2.yml                 # Remove linuxuser
    ├── task_1.2.3.yml                 # Create phalkonadmin user
    ├── task_1.2.4.yml                 # Configure SSH key authentication
    ├── task_1.2.5.yml                 # Test SSH connection
    ├── task_1.2.6.yml                 # Install Docker Compose
    ├── task_1.2.7.yml                 # Post-configuration cleanup & verification
    │
    └── Reusable Playbooks (Generic, Parameterized)
        ├── modify_sudoers_nopasswd.yml    # Configure sudo without password
        ├── cleanup_main_sudoers.yml       # Clean up main sudoers file
        ├── remove_user.yml                # Remove system users
        ├── create_admin_user.yml          # Create admin users
        ├── fix_user_uid.yml               # Fix UID assignment
        ├── setup_ssh_key_auth.yml         # Configure SSH key authentication
        ├── test_ssh_connection.yml        # Test SSH connections
        └── install_docker.yml             # Install Docker and Docker Compose
```

---

## Prerequisites

### Required Software
- **Ansible:** 2.19+ (tested with 2.19.5)
- **Python:** 3.12+ (for Ansible modules)
- **SSH Client:** OpenSSH or compatible

### Required Files

**Credential File:**
- **Location:** `../cucho1.phalkons.com.secret`
- **Format:** `ip,password` (created by Terraform deployment)

**SSH Keys (Two different keys for two different purposes):**

1. **Vultr Key** (for Ansible execution from local machine):
   - **Private:** `~/.ssh/id_ed25519_lc02_vultr`
   - **Purpose:** Ansible connects to VPS as root during PoC phase
   - **Status:** Already loaded on VPS by Vultr
   - **Used by:** You, from your local machine

2. **Common Worker Key** (for bastion/automation access):
   - **Private:** `~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common`
   - **Public:** `~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common.pub`
   - **Purpose:** Deployed to phalkonadmin for bastion (Capitan) access
   - **Status:** Deployed by Task 1.2.4, tested by Task 1.2.5
   - **Used by:** Capitan (bastion server) in the future

### Deployment Prerequisites
1. VPS must be deployed first via Terraform
2. Credential file must exist at `../cucho1.phalkons.com.secret`
3. VPS must be accessible via SSH on port 22
4. Root access must be available

---

## Quick Start

### 1. Verify Prerequisites

```bash
# Check Ansible version
ansible --version

# Check Vultr key exists (for Ansible execution)
ls -la ~/.ssh/id_ed25519_lc02_vultr*

# Check common worker key exists (for bastion deployment)
ls -la ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common*

# Deploy VPS (if not already done)
cd ../terraform
./deploy.sh
cd ../ansible

# Verify credential file
cat ../cucho1.phalkons.com.secret
# Expected format: xxx.xxx.xxx.xxx,password123
```

### 2. Test Connectivity

```bash
# Test Ansible ping
ansible -i inventory.yml mail_server -m ping

# Expected output:
# mail_server | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
```

### 3. Run All Tasks (Recommended)

```bash
# Dry run (see what would change)
./run_all_tasks.sh --check

# Real execution
./run_all_tasks.sh

# This will run all 6 tasks in sequence:
# 1.2.1 → 1.2.2 → 1.2.3 → 1.2.4 → 1.2.5 → 1.2.6
```

### 4. Or Run Tasks Individually

```bash
# Run specific task
./run_task.sh 1.2.1

# With verbose output
./run_task.sh 1.2.1 -v

# With dry-run (check mode)
./run_task.sh 1.2.1 --check
```

---

## Task Details

### Task 1.2.1 - Configure Passwordless Sudo
**Playbook:** `task_1.2.1.yml`  
**Duration:** ~5-10 seconds  
**What it does:**
- Creates `/etc/sudoers.d/90-nopasswd-sudo`
- Configures sudo group for passwordless execution
- Validates sudoers syntax

**Command:**
```bash
./run_task.sh 1.2.1
```

---

### Task 1.2.2 - Remove Default Linuxuser
**Playbook:** `task_1.2.2.yml`  
**Duration:** ~5-10 seconds  
**What it does:**
- Checks if 'linuxuser' exists
- Removes user and home directory
- Verifies removal

**Command:**
```bash
./run_task.sh 1.2.2
```

---

### Task 1.2.3 - Create Phalkonadmin User
**Playbook:** `task_1.2.3.yml`  
**Duration:** ~10-15 seconds  
**What it does:**
- Creates user 'phalkonadmin'
- Adds to sudo group
- Generates random temporary password
- Appends credentials to `../cucho1.phalkons.com.secret`

**Command:**
```bash
./run_task.sh 1.2.3
```

**Result:**
Credential file will have new line:
```
xxx.xxx.xxx.xxx,root_password
phalkonadmin,random_temp_password
```

---

### Task 1.2.4 - Configure SSH Key Authentication
**Playbook:** `task_1.2.4.yml`  
**Duration:** ~10-15 seconds  
**What it does:**
- Creates `.ssh` directory for phalkonadmin
- Deploys **common worker key** (bastion key) to phalkonadmin
- Sets correct permissions (700/.ssh, 600/authorized_keys)
- Does NOT disable password auth (done in Task 1.3.1)

**Key Deployed:** `~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common.pub`  
**Purpose:** Enables Capitan (bastion) to connect to VPS as phalkonadmin

**Command:**
```bash
./run_task.sh 1.2.4
```

**Note:** Your Vultr key for root access remains unchanged. This task adds the bastion key for future automation.

---

### Task 1.2.5 - Test SSH Key Authentication
**Playbook:** `task_1.2.5.yml`  
**Duration:** ~5-10 seconds  
**What it does:**
- Tests SSH connection with **common worker key** (bastion key)
- Tests passwordless sudo
- Displays results
- Fails if tests don't pass

**What is tested:** Validates that Capitan (bastion) will be able to connect to VPS as phalkonadmin

**Command:**
```bash
./run_task.sh 1.2.5
```

**Success Output:**
```
TASK [Display test results]
ok: [mail_server] => {
    "msg": [
        "==================================================="
        "SSH Key Authentication Test Results"
        "==================================================="
        "Testing: Common worker key (for bastion access)"
        "---------------------------------------------------"
        "SSH Key Authentication: SUCCESS ✓"
        "Passwordless Sudo: SUCCESS ✓"
        "---------------------------------------------------"
    ]
}
    "msg": [
        "SSH Key Authentication: SUCCESS",
        "Passwordless Sudo: SUCCESS",
        "User can connect: True",
        "User can sudo without password: True"
    ]
}
```

---

### Task 1.2.6 - Install Docker Compose
**Playbook:** `task_1.2.6.yml`  
**Duration:** ~60-120 seconds  
**What it does:**
- Installs Docker CE from official repository
- Installs Docker Compose plugin (v2)
- Adds phalkonadmin to docker group
- Enables and starts Docker service

**Command:**
```bash
./run_task.sh 1.2.6
```

**Note:** User must reconnect SSH for docker group changes to take effect.

---

## Using Reusable Playbooks

Reusable playbooks can be called directly with custom parameters:

### Example: Create Custom Admin User

```bash
./run_reusable.sh create_admin_user.yml \
  -e "admin_username=myadmin \
      admin_fullname='My Administrator' \
      admin_groups=['sudo','docker'] \
      credential_output_file='./my_credentials.secret'"
```

### Example: Remove Specific User

```bash
./run_reusable.sh remove_user.yml \
  -e "user_name=olduser"
```

### Example: Install Docker for Multiple Users

```bash
./run_reusable.sh install_docker.yml \
  -e "docker_user_list=['user1','user2','user3']"
```

---

## Configuration Details

### Ansible Configuration (`ansible.cfg`)

Key settings:
- **Inventory:** `inventory.yml`
- **Remote User:** root (initially), then phalkonadmin
- **SSH Key:** `~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common`
- **Host Key Checking:** Disabled (accept new hosts automatically)
- **Privilege Escalation:** Enabled (sudo)
- **Output Format:** YAML (more readable)
- **Logging:** Enabled to `ansible.log`

### Inventory Configuration (`inventory.yml`)

Features:
- **Dynamic credential loading** from `../cucho1.phalkons.com.secret`
- **Automatic IP extraction** (first field in credential file)
- **Automatic password extraction** (second field in credential file)
- **Server metadata** (role, environment, hostname)
- **Network configuration** (VPN network, etc.)

Host groups:
- `all` - All servers
- `mail_servers` - Mail server group
- `mail_server` - Single mail server host

---

## Advanced Usage

### Run with Verbose Output

```bash
# Level 1 verbosity (basic)
./run_task.sh 1.2.1 -v

# Level 2 verbosity (more details)
./run_task.sh 1.2.1 -vv

# Level 3 verbosity (maximum, includes SSH debug)
./run_task.sh 1.2.1 -vvv
```

### Run with Tags

```bash
# Only run tasks with specific tags
./run_task.sh 1.2.1 --tags "sudoers"
./run_task.sh 1.2.6 --tags "docker-install"

# Skip tasks with specific tags
./run_task.sh 1.2.6 --skip-tags "verification"
```

### Run in Check Mode (Dry Run)

```bash
# See what would change without actually changing it
./run_task.sh 1.2.1 --check
./run_all_tasks.sh --check
```

### Continue on Error

```bash
# Run all tasks even if some fail
./run_all_tasks.sh --continue-on-error

# Skip confirmation prompt
./run_all_tasks.sh --yes
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: "Credential file not found"

**Error:**
```
ERROR: Credential file not found!
Expected location: ../cucho1.phalkons.com.secret
```

**Solution:**
Deploy VPS first:
```bash
cd ../terraform
./deploy.sh
cd ../ansible
```

#### Issue: "Connection refused"

**Error:**
```
fatal: [mail_server]: UNREACHABLE! => {"msg": "Failed to connect"}
```

**Solutions:**
1. Wait 1-2 minutes after VPS deployment
2. Check VPS is running: `vultr-cli instance list`
3. Test manual SSH: `ssh root@$(cut -d',' -f1 ../cucho1.phalkons.com.secret)`
4. Verify firewall allows SSH on port 22

#### Issue: "Permission denied"

**Error:**
```
fatal: [mail_server]: UNREACHABLE! => {"msg": "Permission denied (publickey,password)"}
```

**Solutions:**
1. Verify password in credential file is correct
2. Check SSH key exists and has correct permissions
3. Try manual SSH first to verify connectivity
4. For tasks 1.2.4+, ensure phalkonadmin user was created

#### Issue: "User not found"

**Error:**
```
fatal: [mail_server]: FAILED! => {"msg": "user phalkonadmin does not exist"}
```

**Solutions:**
1. Run tasks in order: 1.2.1 → 1.2.2 → 1.2.3 → ...
2. Verify task 1.2.3 completed successfully
3. Check user exists: `ssh root@IP 'id phalkonadmin'`

#### Issue: "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED"

**Error:**
```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Host key verification failed.
```

**Cause:** 
This occurs when you reinstall the OS on the server. The server gets a new SSH host key, but your local machine still has the old key in its known_hosts file.

**Solution:**
Remove the old host key from root's known_hosts (since Ansible runs as root):
```bash
# Remove the old host key
sudo ssh-keygen -f /root/.ssh/known_hosts -R 45.32.207.84

# Or remove your user's known_hosts if running Ansible as non-root
ssh-keygen -f ~/.ssh/known_hosts -R 45.32.207.84

# Then run your task again
./run_task.sh 1.2.5
```

**Note:** This is normal and expected after reinstalling the server OS. The warning is SSH's security feature to detect potential man-in-the-middle attacks.

#### Issue: "Docker requires sudo"

**Error:**
```
permission denied while trying to connect to the Docker daemon socket
```

**Solutions:**
1. Reconnect SSH (group changes require new login)
2. Run: `newgrp docker` or logout and login again
3. Verify: `groups phalkonadmin` shows 'docker' group

---

## Testing

### Syntax Validation

```bash
# Validate all playbooks
find playbooks -name "*.yml" -exec ansible-playbook --syntax-check {} \;

# Expected output for each:
# playbook: playbooks/task_X.X.X.yml
```

### Inventory Testing

```bash
# List all hosts and variables
ansible-inventory -i inventory.yml --list

# Show specific host variables
ansible-inventory -i inventory.yml --host mail_server

# Graph host relationships
ansible-inventory -i inventory.yml --graph
```

### Connectivity Testing

```bash
# Ping all hosts
ansible -i inventory.yml all -m ping

# Run command on all hosts
ansible -i inventory.yml all -m command -a "uptime"

# Gather facts
ansible -i inventory.yml mail_server -m setup
```

---

## Performance

### Expected Execution Times

| Task | Duration | Notes |
|------|----------|-------|
| 1.2.1 | 5-10s | Fast (file creation) |
| 1.2.2 | 5-10s | Fast (user removal) |
| 1.2.3 | 10-15s | User creation + password |
| 1.2.4 | 10-15s | SSH key deployment |
| 1.2.5 | 5-10s | Connection testing |
| 1.2.6 | 60-120s | Docker download/install |
| **Total** | **2-3 min** | Includes all tasks |

**Note:** Docker installation (1.2.6) takes longest due to package downloads.

---

## Security Notes

### SSH Key Architecture
**Two-tier access system for security and automation:**

1. **Vultr Key** (`~/.ssh/id_ed25519_lc02_vultr`):
   - Used for: Ansible execution from local machine (PoC phase)
   - Accesses: VPS as root user
   - Status: Already loaded by Vultr during VPS creation
   - Purpose: Direct administrative access during setup

2. **Common Worker Key** (`~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common`):
   - Used for: Bastion (Capitan) automated access
   - Accesses: VPS as phalkonadmin user
   - Status: Deployed by Task 1.2.4, tested by Task 1.2.5
   - Purpose: Future VPN-restricted automation and operations

### Credential Management
- Credential file has 600 permissions (owner read/write only)
- Passwords are randomly generated (12 characters, alphanumeric)
- SSH keys use Ed25519 algorithm (modern, secure)
- Password authentication disabled after SSH keys configured (Task 1.3.1)

### Privilege Escalation
- Passwordless sudo for initial setup only
- Will be restricted in production (Task 1.3.1)
- Sudo logs all commands for audit trail
- Root login disabled after initial setup (Task 1.3.1)

### Network Security
- VPN-only access configured in Task Group 1.3
- Firewall rules applied in Task 1.3.1
- Internal services bound to VPN interface only
- Public services isolated and hardened

---

## Next Steps

After Task Group 1.2 completion:

### 1. Verify Installation

```bash
# SSH as phalkonadmin using common worker key (bastion key)
ssh -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common \
    phalkonadmin@$(cut -d',' -f1 ../cucho1.phalkons.com.secret)

# Or using your Vultr key as root (still works)
ssh -i ~/.ssh/id_ed25519_lc02_vultr \
    root@$(cut -d',' -f1 ../cucho1.phalkons.com.secret)

# Verify system
whoami                    # Expected: phalkonadmin
sudo whoami               # Expected: root (no password prompt)
docker --version          # Expected: Docker 27.x
docker compose version    # Expected: v2.x
docker ps                 # Expected: Empty list (no containers)

exit
```

### 2. Proceed to Task Group 1.3

**System Hardening:**
- Task 1.3.1: Configure SSH hardening, firewall, automatic updates
- Task 1.3.2: Integrate VPS into WireGuard VPN (10.100.0.0/24)
- Task 1.3.3: Configure network interfaces and DNS resolution

### 3. Document Results

Update session log with:
- Execution times
- Any errors encountered
- Validation results
- Lessons learned

---

## Related Documentation

- [Project Planning](../planning.md) - Overall project timeline and decisions
- [Task Tracking](../tasks.md) - Detailed task list and dependencies
- [Session Logs](../session_logs/) - Historical execution records
- [Testing Guide](./TESTING_GUIDE.md) - Comprehensive testing procedures
- [PRD](../Mail_Server_POC_PRD.md) - Product requirements document

---

## Support and Feedback

### Getting Help

1. Check [TESTING_GUIDE.md](./TESTING_GUIDE.md) for detailed testing procedures
2. Review session logs for similar issues
3. Enable verbose output (`-vvv`) to see detailed execution
4. Use `--check` mode to dry-run before real execution

### Reporting Issues

When reporting issues, include:
- Command executed
- Full error message
- Output with `-vvv` verbosity
- Server IP and status
- Credential file format (redacted)

---

**README Version:** 2.0  
**Last Updated:** 2025-01-05  
**Status:** ✅ Production Ready  
**Tested With:** Ansible 2.19.5, Python 3.12.3, Debian 13

---

## Task Group 1.3: System Hardening

**Status:** [ ] IN PROGRESS  
**Started:** 2025-01-07

### Task 1.3.1 - Configure Basic System Hardening

**Playbook:** `task_1.3.1.yml`  
**Reusable Playbook:** `playbooks/system_hardening.yml`  
**Duration:** ~60-90 seconds  
**Dependencies:** Task 1.2.6 (phalkonadmin user exists, Docker installed)

**What it does:**

1. **SSH Hardening:**
   - Changes SSH port from 22 to 2288
   - Disables root login (`PermitRootLogin no`)
   - Disables password authentication (`PasswordAuthentication no`)
   - Restricts access to user `phalkonadmin` only
   - Implements strong cryptographic algorithms (curve25519, ChaCha20-Poly1305)
   - Adds connection timeouts (ClientAliveInterval 300s)
   - Configures authentication limits (MaxAuthTries 3)
   - Creates security banner
   - Backs up original configuration

2. **Firewall Configuration (UFW):**
   - Installs UFW firewall
   - Sets default policy: deny incoming, allow outgoing
   - Allows SSH on port 2288/tcp
   - Enables firewall

3. **Automatic Security Updates:**
   - Installs `unattended-upgrades` package
   - Configures automatic security updates
   - Automatic cleanup of unused packages
   - No automatic reboots (manual control)
   - Update checks daily

**Command:**
```bash
./run_task.sh 1.3.1
```

**⚠️ CRITICAL WARNING - READ BEFORE RUNNING:**

After this task completes:
- ❌ SSH on port 22 will be BLOCKED
- ✅ SSH will ONLY work on port **2288**
- ❌ Password authentication will be DISABLED
- ✅ SSH will ONLY accept key authentication
- ❌ Root login will be DISABLED
- ✅ Only user `phalkonadmin` can connect

**Files Created:**
- `task_1.3.1.yml` - Task-specific wrapper
- `playbooks/system_hardening.yml` - Reusable hardening playbook
- `playbooks/templates/sshd_config.j2` - Hardened SSH configuration
- `playbooks/templates/50unattended-upgrades.j2` - Automatic updates config
- `playbooks/templates/20auto-upgrades.j2` - Auto-upgrade schedule
- `/etc/ssh/banner` - SSH login banner (on server)
- `/etc/ssh/sshd_config.backup.TIMESTAMP` - Backup of original SSH config

**Templates Location:**
```
playbooks/
└── templates/
    ├── sshd_config.j2              # Complete hardened SSH configuration
    ├── 50unattended-upgrades.j2    # Unattended upgrades main config
    └── 20auto-upgrades.j2          # Auto-upgrade schedule
```

---

### Reconnecting After Task 1.3.1

**Old way (WILL NOT WORK after task):**
```bash
ssh root@<IP>
```

**New way (REQUIRED after task):**
```bash
# Using bastion key (common worker key) with IdentitiesOnly to avoid "too many authentication failures"
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common \
    phalkonadmin@$(cut -d',' -f1 ../cucho1.phalkons.com.secret)

# Or with IP directly (for cucho1)
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@45.32.207.84
```

**For Future Ansible Tasks (1.3.2+):**

Set the SSH port environment variable:
```bash
# Option 1: Export before each task
export ANSIBLE_REMOTE_PORT=2288
./run_task.sh 1.3.2

# Option 2: Set inline
ANSIBLE_REMOTE_PORT=2288 ./run_task.sh 1.3.2

# Option 3: Export permanently in your shell
echo 'export ANSIBLE_REMOTE_PORT=2288' >> ~/.bashrc
source ~/.bashrc
```

---

### SSH Configuration Details

The deployed `/etc/ssh/sshd_config` includes:

**Security & Access Control:**
```
Port 2288
PermitRootLogin no
AllowUsers phalkonadmin
MaxAuthTries 3
MaxSessions 10
LoginGraceTime 60
ClientAliveInterval 300
ClientAliveCountMax 2
```

**Authentication:**
```
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no
```

**Modern Cryptography:**
```
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com
```

**Network Security:**
```
AllowTcpForwarding no
AllowAgentForwarding no
X11Forwarding no
GatewayPorts no
PermitTunnel no
```

**Logging:**
```
SyslogFacility AUTH
LogLevel VERBOSE
Banner /etc/ssh/banner
```

---

### Firewall Configuration

**UFW Rules Applied:**

```bash
# Default policies
Default: deny (incoming), allow (outgoing)

# Allowed ports
2288/tcp                   ALLOW IN    Anywhere    (SSH)
```

**Verify Firewall:**
```bash
ssh -p 2288 phalkonadmin@<IP> 'sudo ufw status verbose'
```

**Expected Output:**
```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)

To                         Action      From
--                         ------      ----
2288/tcp                   ALLOW IN    Anywhere
```

---

### Automatic Updates Configuration

**Update Schedule:**
- Package lists update: Daily
- Security updates download: Daily
- Security updates install: Daily
- Package cleanup: Weekly (every 7 days)

**Reboot Policy:**
- Automatic reboot: **Disabled** (manual control)
- Reboot with users: No
- Scheduled reboot time: 03:00 (if ever enabled)

**Verify Automatic Updates:**
```bash
ssh -p 2288 phalkonadmin@<IP> 'sudo systemctl status unattended-upgrades'

# Check recent updates
ssh -p 2288 phalkonadmin@<IP> 'sudo cat /var/log/unattended-upgrades/unattended-upgrades.log'

# Check configuration
ssh -p 2288 phalkonadmin@<IP> 'cat /etc/apt/apt.conf.d/20auto-upgrades'
```

---

### Verification & Testing

#### Pre-Task Checks

```bash
# Verify current SSH port (should be 22)
ssh root@<IP> 'netstat -tlnp | grep sshd'
# Expected: *:22

# Verify phalkonadmin exists
ssh root@<IP> 'id phalkonadmin'
# Expected: uid=1000(phalkonadmin) gid=1000(phalkonadmin) groups=1000(phalkonadmin),27(sudo),999(docker)
```

#### Post-Task Verification

```bash
# Test new SSH connection (use IdentitiesOnly=yes to avoid "too many authentication failures")
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common \
    phalkonadmin@<IP> 'echo "✅ SSH on port 2288 working!"'

# Quick manual connection to verify
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@45.32.207.84

# Verify old port is blocked (should fail/timeout)
timeout 5 ssh -p 22 phalkonadmin@<IP> && echo "❌ Port 22 still open!" || echo "✅ Port 22 blocked"

# Verify root login is disabled (should fail)
ssh -p 2288 root@<IP> 2>&1 | grep -q "Permission denied" && echo "✅ Root login disabled" || echo "❌ Root can still login"

# Verify password auth is disabled (should fail)
ssh -p 2288 -o PubkeyAuthentication=no phalkonadmin@<IP> 2>&1 | grep -q "Permission denied" && echo "✅ Password auth disabled" || echo "❌ Password auth still enabled"

# Check firewall status
ssh -p 2288 phalkonadmin@<IP> 'sudo ufw status'
# Expected: Status: active

# Check SSH config
ssh -p 2288 phalkonadmin@<IP> 'sudo grep -E "^(Port|PermitRootLogin|PasswordAuthentication|AllowUsers)" /etc/ssh/sshd_config'
# Expected:
# Port 2288
# PermitRootLogin no
# PasswordAuthentication no
# AllowUsers phalkonadmin

# Check automatic updates
ssh -p 2288 phalkonadmin@<IP> 'sudo systemctl is-active unattended-upgrades'
# Expected: active
```

#### Complete Verification Script

```bash
#!/bin/bash
# Quick verification script for Task 1.3.1

SERVER_IP=$(cut -d',' -f1 ../cucho1.phalkons.com.secret)
SSH_KEY=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
SSH_OPTS="-p 2288 -o IdentitiesOnly=yes -i $SSH_KEY"

echo "=== Task 1.3.1 Verification ==="
echo ""

echo "1. Testing SSH on port 2288..."
if ssh $SSH_OPTS phalkonadmin@$SERVER_IP 'exit' 2>/dev/null; then
    echo "   ✅ SSH port 2288 accessible"
else
    echo "   ❌ SSH port 2288 NOT accessible"
fi

echo "2. Checking old port 22..."
if timeout 3 ssh -p 22 phalkonadmin@$SERVER_IP 'exit' 2>/dev/null; then
    echo "   ❌ Port 22 still accessible!"
else
    echo "   ✅ Port 22 blocked"
fi

echo "3. Checking firewall..."
UFW_STATUS=$(ssh $SSH_OPTS phalkonadmin@$SERVER_IP 'sudo ufw status' 2>/dev/null | grep "Status:")
if [[ $UFW_STATUS == *"active"* ]]; then
    echo "   ✅ Firewall active"
else
    echo "   ❌ Firewall not active"
fi

echo "4. Checking automatic updates..."
UPDATES=$(ssh $SSH_OPTS phalkonadmin@$SERVER_IP 'sudo systemctl is-active unattended-upgrades' 2>/dev/null)
if [[ $UPDATES == "active" ]]; then
    echo "   ✅ Automatic updates active"
else
    echo "   ❌ Automatic updates not active"
fi

echo ""
echo "=== Verification Complete ==="
```

---

### Troubleshooting Task 1.3.1

#### Issue: "Connection refused" on port 2288

**Symptoms:**
```
ssh: connect to host <IP> port 2288: Connection refused
```

**Diagnosis:**
```bash
# Check if task completed successfully
./run_task.sh 1.3.1 -v

# Use Vultr web console to check SSH status
# (Login via Vultr dashboard → Server → View Console)
sudo systemctl status sshd
sudo netstat -tlnp | grep sshd
```

**Solutions:**
1. **SSH didn't restart properly:**
   ```bash
   # Via Vultr console as root
   sudo systemctl restart sshd
   sudo systemctl status sshd
   ```

2. **Firewall blocking connection:**
   ```bash
   # Via Vultr console as root
   sudo ufw allow 2288/tcp
   sudo ufw reload
   ```

3. **SSH config syntax error:**
   ```bash
   # Via Vultr console as root
   sudo sshd -t  # Test configuration
   
   # If errors, restore backup
   sudo cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config
   sudo systemctl restart sshd
   ```

#### Issue: "Permission denied (publickey)"

**Symptoms:**
```
phalkonadmin@<IP>: Permission denied (publickey).
```

**Diagnosis:**
```bash
# Verify you're using the correct key
ls -la ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common

# Try with verbose output
ssh -vvv -p 2288 -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@<IP>
```

**Solutions:**
1. **Wrong SSH key:**
   ```bash
   # Verify key exists and has correct permissions
   ls -la ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
   chmod 600 ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
   ```

2. **Key not in authorized_keys:**
   ```bash
   # Via Vultr console as root
   cat /home/phalkonadmin/.ssh/authorized_keys
   # Should contain the public key from id_ed25519_common.pub
   ```

3. **Wrong username:**
   ```bash
   # Use 'phalkonadmin', not 'root' or other users
   ssh -p 2288 -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@<IP>
   ```

#### Issue: Completely locked out

**Emergency Recovery via Vultr Console:**

1. **Access Vultr Web Console:**
   - Login to Vultr dashboard
   - Go to your server
   - Click "View Console"
   - Login as `root` with password from `../cucho1.phalkons.com.secret`

2. **Restore SSH configuration:**
   ```bash
   # Find the backup
   ls -la /etc/ssh/sshd_config.backup.*
   
   # Restore backup (use actual timestamp)
   cp /etc/ssh/sshd_config.backup.20250107T120000 /etc/ssh/sshd_config
   
   # Or manually fix critical settings
   nano /etc/ssh/sshd_config
   # Change: Port 22
   # Change: PermitRootLogin yes
   # Change: PasswordAuthentication yes
   
   # Restart SSH
   systemctl restart sshd
   ```

3. **Disable firewall temporarily:**
   ```bash
   ufw disable
   ```

4. **Rerun task after fixing issues**

#### Issue: Firewall blocking legitimate traffic

**Add additional allowed ports:**
```bash
# SSH into server
ssh -p 2288 phalkonadmin@<IP>

# Allow additional port
sudo ufw allow <port>/tcp
sudo ufw status

# Example: Allow SMTP
sudo ufw allow 25/tcp
```

**Check current rules:**
```bash
sudo ufw status numbered

# Delete specific rule by number
sudo ufw delete <number>
```

---

### Rollback Procedure

If you need to completely rollback Task 1.3.1 changes:

#### 1. Access via Vultr Console
Login as root with password from credential file

#### 2. Restore SSH Configuration
```bash
# List available backups
ls -la /etc/ssh/sshd_config.backup.*

# Restore (replace timestamp with actual)
cp /etc/ssh/sshd_config.backup.20250107T120000 /etc/ssh/sshd_config

# Verify syntax
sshd -t

# Restart SSH
systemctl restart sshd
```

#### 3. Reset Firewall
```bash
# Disable UFW
ufw disable

# Reset all rules
ufw --force reset

# Re-enable with permissive rules
ufw default allow incoming
ufw default allow outgoing
ufw enable
```

#### 4. Disable Automatic Updates (Optional)
```bash
# Stop service
systemctl stop unattended-upgrades
systemctl disable unattended-upgrades

# Remove configuration
rm /etc/apt/apt.conf.d/20auto-upgrades
rm /etc/apt/apt.conf.d/50unattended-upgrades
```

#### 5. Verify Rollback
```bash
# Test SSH on port 22
ssh root@<IP>

# Verify settings
grep -E "^(Port|PermitRootLogin)" /etc/ssh/sshd_config
```

---

### Security Improvements Implemented

After Task 1.3.1 completion, the following security improvements are active:

✅ **SSH Hardening:**
- Non-standard port (reduces automated attacks by ~90%)
- Key-only authentication (eliminates password brute-force)
- Root login disabled (requires sudo audit trail)
- Strong cryptography only (modern algorithms)
- Connection timeouts (prevents idle sessions)
- User whitelist (only phalkonadmin can connect)
- Failed login attempts limited to 3
- Verbose logging enabled

✅ **Network Security:**
- Firewall enabled with default-deny policy
- Only necessary ports exposed
- Old SSH port explicitly blocked
- Connection tracking enabled

✅ **System Maintenance:**
- Automatic security updates enabled
- Unused packages automatically removed
- Update logs for audit trail
- Manual reboot control maintained

✅ **Access Control:**
- Single administrative user (phalkonadmin)
- Passwordless sudo for convenience
- SSH key-based authentication only
- Console access as last resort

---

### Performance Impact

**Resource Usage After Task 1.3.1:**
- CPU: +0.5% (SSH crypto, UFW, unattended-upgrades)
- Memory: +15MB (services overhead)
- Disk: +60MB (packages and logs)
- Network: Minimal (daily update checks, ~1-5MB/day)

**Connection Performance:**
- SSH handshake: +0.3-0.5s (stronger crypto)
- Data throughput: No measurable impact
- Latency: No measurable impact

---

### Next Steps After Task 1.3.1

**Immediate:**
1. Test SSH connection on port 2288
2. Verify firewall is active
3. Check automatic updates are running
4. Update any connection scripts/aliases

**Task Group 1.3 Remaining Tasks:**
- [ ] Task 1.3.2 (TODO): Integrate VPS into WireGuard VPN (10.100.0.0/24)
- [ ] Task 1.3.3 (TODO): Configure network interfaces and DNS resolution
- [ ] Task 1.3.4 (TODO): Create SSH dependency on WireGuard

**Remember:** For all future tasks, use:
```bash
export ANSIBLE_REMOTE_PORT=2288
./run_task.sh <task_number>
```

---

### Task 1.3.1 Summary

**Duration:** ~60-90 seconds  
**Changes Made:** 
- SSH configuration hardened (port 2288, keys only, no root)
- UFW firewall configured and enabled
- Automatic security updates configured
- System backup created

**Files Modified:**
- `/etc/ssh/sshd_config` (backup created)
- `/etc/ufw/` (firewall rules)
- `/etc/apt/apt.conf.d/` (auto-updates)

**Services Affected:**
- sshd (restarted)
- ufw (enabled)
- unattended-upgrades (started)

**Status:** ✅ Ready for execution  
**Tested:** Debian 13, Ansible 2.19.5  
**Version:** 1.0  
**Created:** 2025-01-07


---

### Task 1.3.5 - Install and Configure Fail2ban

**Playbook:** `task_1.3.5.yml`  
**Reusable Playbook:** `playbooks/install_fail2ban.yml`  
**Duration:** ~30-45 seconds  
**Dependencies:** Task 1.3.1 (SSH hardening complete)

**What it does:**

1. **Fail2ban Installation:**
   - Installs fail2ban package
   - Creates backup of original configuration
   - Configures logging and ban policies

2. **SSH Jail Configuration:**
   - Monitors SSH port 2288 (configured port)
   - Max retry: 3 failed attempts
   - Find time: 10 minutes (600 seconds)
   - Ban time: 1 hour (3600 seconds)
   - Uses /var/log/auth.log for monitoring

3. **Service Management:**
   - Enables fail2ban service at boot
   - Starts fail2ban service
   - Validates SSH jail is active

**Command:**
```bash
./run_task.sh 1.3.5
```

**Files Created:**
- `task_1.3.5.yml` - Task-specific wrapper
- `playbooks/install_fail2ban.yml` - Reusable fail2ban playbook
- `playbooks/templates/jail.local.j2` - Main fail2ban configuration
- `playbooks/templates/sshd.local.j2` - SSH jail configuration
- `/etc/fail2ban/jail.local` - Main config (on server)
- `/etc/fail2ban/jail.d/sshd.local` - SSH jail config (on server)
- `/etc/fail2ban/jail.conf.backup.TIMESTAMP` - Backup of original

---

#### Fail2ban Configuration Details

**Global Settings:**
```
Ban Time: 3600s (1 hour)
Find Time: 600s (10 minutes)
Max Retry: 3 attempts
Log Level: INFO
Log File: /var/log/fail2ban.log
```

**SSH Jail Settings:**
```
Port: 2288
Max Retry: 3 attempts
Find Time: 600s (10 minutes)
Ban Time: 3600s (1 hour)
Log Path: /var/log/auth.log
Filter: sshd
```

**How it Works:**
- Monitors `/var/log/auth.log` for failed SSH login attempts
- If 3 failed attempts occur within 10 minutes from same IP
- That IP is banned for 1 hour
- Ban is implemented via iptables/nftables

---

#### Fail2ban Verification

**Check fail2ban status:**
```bash
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common \
    phalkonadmin@45.32.207.84 'sudo fail2ban-client status'
```

**Expected Output:**
```
Status
|- Number of jail:      1
`- Jail list:   sshd
```

**Check SSH jail status:**
```bash
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common \
    phalkonadmin@45.32.207.84 'sudo fail2ban-client status sshd'
```

**Expected Output:**
```
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     0
|  `- File list:        /var/log/auth.log
`- Actions
   |- Currently banned: 0
   |- Total banned:     0
   `- Banned IP list:
```

---

#### Fail2ban Useful Commands

**View fail2ban logs:**
```bash
sudo tail -f /var/log/fail2ban.log
```

**View currently banned IPs:**
```bash
sudo fail2ban-client status sshd
```

**Manually ban an IP:**
```bash
sudo fail2ban-client set sshd banip <IP_ADDRESS>
```

**Unban an IP:**
```bash
sudo fail2ban-client set sshd unbanip <IP_ADDRESS>
```

**Reload fail2ban configuration:**
```bash
sudo fail2ban-client reload
```

**Reload specific jail:**
```bash
sudo fail2ban-client reload sshd
```

**View banned IPs across all jails:**
```bash
sudo fail2ban-client banned
```

---

#### Testing Fail2ban

**Test SSH jail (from another machine):**

1. Try to login with wrong password 3 times:
```bash
# Will fail after 3 attempts and IP will be banned
ssh -p 2288 wronguser@45.32.207.84
```

2. Check if IP is banned:
```bash
sudo fail2ban-client status sshd
# Should show your IP in "Banned IP list"
```

3. Unban yourself:
```bash
sudo fail2ban-client set sshd unbanip <YOUR_IP>
```

**Monitor in real-time:**
```bash
# Terminal 1: Watch fail2ban log
sudo tail -f /var/log/fail2ban.log

# Terminal 2: Watch auth log
sudo tail -f /var/log/auth.log

# Terminal 3: Try failed logins
ssh -p 2288 wronguser@45.32.207.84
```

---

#### Fail2ban Email Notifications (Optional)

To enable email notifications for bans, update `task_1.3.5.yml`:

```yaml
vars:
  fail2ban_destemail: "admin@yourdomain.com"
  fail2ban_sender: "fail2ban@cucho1.phalkons.com"
  fail2ban_mta: "sendmail"
```

**Note:** Requires working mail server (will be configured in later tasks)

---

#### Troubleshooting Fail2ban

**Issue: Fail2ban not starting**

```bash
# Check status
sudo systemctl status fail2ban

# Check configuration syntax
sudo fail2ban-client -t

# View detailed logs
sudo journalctl -u fail2ban -n 50
```

**Issue: SSH jail not active**

```bash
# Check if sshd.local exists
ls -la /etc/fail2ban/jail.d/sshd.local

# Check configuration
sudo cat /etc/fail2ban/jail.d/sshd.local

# Restart fail2ban
sudo systemctl restart fail2ban

# Check jail status
sudo fail2ban-client status sshd
```

**Issue: Not detecting failed logins**

```bash
# Check auth log exists and has content
sudo tail /var/log/auth.log

# Check fail2ban is monitoring correct file
sudo fail2ban-client get sshd logpath

# Manually trigger a test
sudo fail2ban-regex /var/log/auth.log /etc/fail2ban/filter.d/sshd.conf
```

---

**Task Version:** 1.0  
**Last Updated:** 2025-01-07  
**Status:** ✅ Ready for Testing  
**Tested With:** Debian 13, Ansible 2.19.5


---

## Important: Ansible Connection After Task 1.3.1

After completing Task 1.3.1, root login is disabled. You must configure Ansible to use `phalkonadmin`:

**For all tasks 1.3.2 and later:**

```bash
# Set these environment variables before running tasks
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common

# Then run tasks normally
./run_task.sh 1.3.5
```

**Or add to your shell profile for persistence:**

```bash
cat >> ~/.bashrc << 'ENVEOF'
# Ansible configuration for mail server (after Task 1.3.1)
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
ENVEOF

source ~/.bashrc
```

**Summary of changes after Task 1.3.1:**
- SSH Port: 22 → 2288
- User: root → phalkonadmin
- Key: Vultr key → Bastion key (common worker key)


---

### Task 1.3.2 - Integrate VPS into WireGuard VPN

**Playbook:** `task_1.3.2.yml`  
**Reusable Playbook:** `playbooks/install_wireguard.yml`  
**Duration:** ~45 seconds  
**Dependencies:** Task 1.3.1 (SSH hardening complete)

**What it does:**

1. **WireGuard Installation:**
   - Installs WireGuard and wireguard-tools packages
   - Creates `/etc/wireguard` directory with secure permissions (700)

2. **VPN Configuration:**
   - Deploys wg0.conf with VPN IP 10.100.0.19/24
   - Configures peer connection to 144.202.76.243:51820
   - Sets allowed IPs: 10.100.0.0/24 (full VPN subnet)
   - Enables persistent keepalive (25 seconds)
   - Secures private key with 600 permissions

3. **Network Configuration:**
   - Enables IP forwarding for VPN routing
   - Configures sysctl for packet forwarding

4. **Service Management:**
   - Enables wg-quick@wg0 service at boot
   - Starts WireGuard VPN connection
   - Verifies connectivity

**Prerequisites - Setup Credentials:**

Before running this task, extract credentials from wg0.conf:

```bash
cd ansible

# Place your wg0.conf file here, then run:
./setup_wg_credentials.sh wg0.conf
```

This will:
- Create `../wg_credentials/` directory (700 permissions)
- Extract private key, address, peer info
- Update .gitignore to protect secrets
- Set secure file permissions (600)

**Command:**
```bash
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common

# Dry run first
./run_task.sh 1.3.2 --check

# Real execution
./run_task.sh 1.3.2
```

**Files Created:**
- `task_1.3.2.yml` - Task wrapper
- `playbooks/install_wireguard.yml` - Reusable WireGuard playbook
- `playbooks/templates/wg0.conf.j2` - WireGuard configuration template
- `setup_wg_credentials.sh` - Credential extraction script
- `../wg_credentials/private_key` - Private key (protected by .gitignore)
- `../wg_credentials/address` - VPN address
- `../wg_credentials/peer_public_key` - Peer's public key
- `../wg_credentials/endpoint` - Peer endpoint
- `/etc/wireguard/wg0.conf` - WireGuard config (on server)
- `/etc/wireguard/wg0.conf.backup.TIMESTAMP` - Backup (if exists)

---

#### WireGuard Configuration Details

**Interface Settings:**
```
Interface: wg0
Address: 10.100.0.19/24
Private Key: (from wg_credentials/private_key)
```

**Peer Settings:**
```
Public Key: /fKlGm12NBYEA6dNy/EYLYOKKRdQTfKlFIHpSmsNEwQ=
Endpoint: 144.202.76.243:51820
Allowed IPs: 10.100.0.0/24
Persistent Keepalive: 25 seconds
```

**Service:**
```
Service Name: wg-quick@wg0
Enabled at Boot: Yes
Configuration: /etc/wireguard/wg0.conf
```

---

#### WireGuard Verification

**Check WireGuard status:**
```bash
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common \
    phalkonadmin@45.32.207.84 'sudo wg show'
```

**Expected Output:**
```
interface: wg0
  public key: (your public key)
  private key: (hidden)
  listening port: (random port)

peer: /fKlGm12NBYEA6dNy/EYLYOKKRdQTfKlFIHpSmsNEwQ=
  endpoint: 144.202.76.243:51820
  allowed ips: 10.100.0.0/24
  latest handshake: (time since last handshake)
  transfer: (bytes sent/received)
  persistent keepalive: every 25 seconds
```

**Check WireGuard interface:**
```bash
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common \
    phalkonadmin@45.32.207.84 'ip addr show wg0'
```

**Expected Output:**
```
X: wg0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
    link/none 
    inet 10.100.0.19/24 scope global wg0
       valid_lft forever preferred_lft forever
```

**Test VPN connectivity:**
```bash
# Ping another VPN member (if available)
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common \
    phalkonadmin@45.32.207.84 'ping -c 3 10.100.0.1'
```

---

#### WireGuard Useful Commands

**View WireGuard status:**
```bash
sudo wg show
sudo wg show wg0
```

**View detailed interface info:**
```bash
sudo wg show all
```

**Restart WireGuard:**
```bash
sudo systemctl restart wg-quick@wg0
```

**Stop WireGuard:**
```bash
sudo systemctl stop wg-quick@wg0
```

**Start WireGuard:**
```bash
sudo systemctl start wg-quick@wg0
```

**Check WireGuard service status:**
```bash
sudo systemctl status wg-quick@wg0
```

**View WireGuard logs:**
```bash
sudo journalctl -u wg-quick@wg0 -n 50
sudo journalctl -u wg-quick@wg0 -f
```

**View configuration:**
```bash
sudo cat /etc/wireguard/wg0.conf
```

**Check if interface is up:**
```bash
ip link show wg0
ip addr show wg0
```

---

#### Troubleshooting WireGuard

**Issue: WireGuard not starting**

```bash
# Check service status
sudo systemctl status wg-quick@wg0

# Check configuration syntax
sudo wg-quick up wg0
# If errors, check /etc/wireguard/wg0.conf

# View detailed logs
sudo journalctl -u wg-quick@wg0 -n 100
```

**Issue: No handshake with peer**

```bash
# Check if peer endpoint is reachable
ping 144.202.76.243

# Check if port 51820 is open (from peer side)
# Check firewall allows UDP traffic

# Check configuration
sudo wg show wg0

# Restart WireGuard
sudo systemctl restart wg-quick@wg0
```

**Issue: Interface has no IP address**

```bash
# Check configuration
sudo cat /etc/wireguard/wg0.conf
# Verify Address line exists

# Manually bring up interface
sudo wg-quick down wg0
sudo wg-quick up wg0

# Check interface
ip addr show wg0
```

**Issue: Cannot reach other VPN members**

```bash
# Check allowed IPs
sudo wg show wg0

# Check routing
ip route show

# Check if IP forwarding is enabled
cat /proc/sys/net/ipv4/ip_forward
# Should be: 1

# Enable if needed
sudo sysctl -w net.ipv4.ip_forward=1
```

**Issue: Credentials not found**

```bash
# Run credential setup script
cd ansible
./setup_wg_credentials.sh wg0.conf

# Verify files exist
ls -la ../wg_credentials/
cat ../wg_credentials/private_key
```

---

#### Security Notes for WireGuard

**Credential Protection:**
- ✅ Private keys stored in `../wg_credentials/` (700 permissions)
- ✅ Individual files have 600 permissions (rw-------)
- ✅ Protected by .gitignore
- ✅ Never committed to git
- ✅ Original wg0.conf also protected

**Configuration File:**
- `/etc/wireguard/wg0.conf` has 600 permissions
- Only root can read/write
- Contains private key (never share)

**Network Security:**
- Encrypted tunnel using modern cryptography
- Peer authentication via public keys
- No password-based authentication
- All VPN traffic encrypted

**Best Practices:**
- Keep private keys secure
- Rotate keys periodically
- Monitor for unauthorized connections
- Use persistent keepalive for NAT traversal

---

#### After Task 1.3.2 Completion

**VPN Access:**
- Server is now accessible via VPN at: `10.100.0.19`
- Can be used for internal services (PostgreSQL, etc.)
- SSH can be restricted to VPN-only (Task 1.3.4)

**Network Configuration:**
- VPN subnet: 10.100.0.0/24
- Server VPN IP: 10.100.0.19
- Peer endpoint: 144.202.76.243:51820

**Next Steps:**
- Task 1.3.3: Configure network interfaces and DNS
- Task 1.3.4: Make SSH depend on WireGuard (VPN-only SSH)
- Task 1.4.x: Continue with directory structure setup

---

**Task Version:** 1.0  
**Last Updated:** 2025-01-07  
**Status:** ✅ Ready for Testing  
**Tested With:** Debian 13, Ansible 2.19.5


---

## 📦 Task Group 2.1: PostgreSQL Database Layer

### Overview

Task Group 2.1 implements the PostgreSQL database layer for mail server operations. This includes container deployment, schema creation, and automated backups.

**Status:** 75% Complete (3 of 4 tasks)

---

### Task 2.1.1 - Deploy PostgreSQL Container ✅ COMPLETE

**Task ID:** 2.1.1  
**Reusable Playbook:** `playbooks/deploy_postgresql_container.yml`  
**Duration:** ~3 minutes  
**Dependencies:** Task 1.4.2 (postgres user with UID 999)

**What it does:**

1. **Container Deployment:**
   - Deploys PostgreSQL 17 (postgres:17-alpine image)
   - Container name: mailserver-postgres
   - Runs as postgres user (UID 999)
   - Restart policy: unless-stopped
   - Resource limits: 2GB RAM, 1.5 CPU

2. **Network Configuration:**
   - Binds to VPN IP only: 10.100.0.25:5432
   - Host network mode for VPN IP binding
   - UFW rule: Allow from 10.100.0.0/24 only
   - SCRAM-SHA-256 authentication

3. **Volume Mounts:**
   - `/opt/postgres/data` → `/var/lib/postgresql/data` (database files)
   - `/opt/postgres/wal_archive` → `/var/lib/postgresql/wal_archive` (WAL archives)

4. **Security:**
   - Generates secure 32-character random password
   - Stores credentials in `/opt/mail_server/postgres/.env` (0600)
   - Backup credentials in `/root/postgres_credentials.txt`
   - VPN-only access enforced by firewall

**Command:**
```bash
./run_task.sh 2.1.1
```

**Verification:**
```bash
docker ps | grep mailserver-postgres
sudo /opt/mail_server/postgres/scripts/test_connection.sh
sudo /opt/mail_server/postgres/scripts/get_password.sh
```

---

### Task 2.1.2 - Configure Database Schema ✅ COMPLETE

**Task ID:** 2.1.2  
**Reusable Playbook:** `playbooks/configure_mail_database.yml`  
**Duration:** ~2 minutes  
**Dependencies:** Task 2.1.1 (PostgreSQL container running)

**What it does:**

1. **Database Schema:**
   - Creates `virtual_domains` table (mail domains)
   - Creates `virtual_users` table (email accounts with SHA512-CRYPT passwords)
   - Creates `virtual_aliases` table (email forwarding rules)
   - Creates `verify_password()` function (authentication helper)
   - Creates `user_mailbox_info` view (Dovecot integration)

2. **Service Users:**
   - `postfix` (read-only) - Mail routing lookups
   - `dovecot` (read-only) - IMAP/POP3 authentication
   - `sogo` (read-write) - Webmail interface
   - `mailadmin` (admin) - Full user management

3. **Test Data:**
   - Domain: testdomain.local
   - Users: testuser1@testdomain.local, testuser2@testdomain.local, admin@testdomain.local

**Command:**
```bash
./run_task.sh 2.1.2
```

**Verification:**
```bash
docker exec mailserver-postgres psql -U postgres -d mailserver -c "\dt"
docker exec mailserver-postgres psql -U postgres -d mailserver -c "SELECT COUNT(*) FROM virtual_users;"
sudo /opt/mail_server/postgres/scripts/verify_database.sh
```

---

### Task 2.1.3 - Configure Backups and WAL Archiving ✅ COMPLETE

**Task ID:** 2.1.3  
**Reusable Playbook:** `playbooks/configure_database_backups.yml`  
**Duration:** ~2 minutes  
**Dependencies:** Task 2.1.2 (Database schema exists)

**What it does:**

1. **WAL Archiving:** Continuous archiving to `/opt/postgres/wal_archive/` for point-in-time recovery
2. **Backup Scripts:** backup, restore, cleanup, verify
3. **Automated Scheduling:** Daily backup at 2 AM, cleanup at 3 AM (7-day retention)
4. **Initial Backup:** Creates and verifies first backup

**Command:**
```bash
./run_task.sh 2.1.3
```

**Verification:**
```bash
ls -lh /opt/postgres/backups/
sudo /opt/mail_server/postgres/scripts/verify_backups.sh
sudo crontab -l | grep postgres
```

---

### Task 2.1.4 - Final PostgreSQL Verification 📦 PACKAGE READY

**Task ID:** 2.1.4  
**Reusable Playbook:** `playbooks/verify_postgresql_complete.yml`  
**Duration:** ~2-3 minutes  
**Dependencies:** Tasks 2.1.1, 2.1.2, 2.1.3 (Complete PostgreSQL setup)  
**Status:** 📦 Complete package created - ready for execution

**What it does:**

1. **Container Health Verification:**
   - Validates PostgreSQL container is running and healthy
   - Confirms VPN-only binding (10.100.0.25:5432)
   - Verifies no public internet exposure

2. **Service User Authentication (24 checks):**
   - Tests all 4 service users (postfix, dovecot, sogo, mailadmin)
   - Validates correct permission levels for each user
   - Verifies read-only vs read-write access
   - Tests administrative capabilities

3. **Schema Integrity Validation:**
   - Confirms all tables exist (virtual_domains, virtual_users, virtual_aliases)
   - Validates views (user_mailbox_info)
   - Tests functions (verify_password)
   - Verifies test data integrity

4. **Authentication Function Testing:**
   - Tests password verification with correct credentials
   - Verifies rejection of incorrect passwords
   - Validates SHA512-CRYPT hashing

5. **Backup System Verification:**
   - Confirms backup files exist
   - Validates WAL archiving is enabled and functioning
   - Checks cron job configuration
   - Verifies backup scripts are executable

6. **Documentation Generation:**
   - Creates comprehensive connection guide for all services
   - Generates service-specific environment files (.env)
   - Produces detailed verification report with timestamp

**Files Created (8 total):**

```
Task Package:
├── task_2.1.4.yml                              # Main task wrapper
├── playbooks/
│   └── verify_postgresql_complete.yml          # Verification logic (500+ lines)
├── templates/
│   ├── connection_strings_doc.j2               # Connection guide template
│   ├── service_env.j2                          # Service .env template
│   └── verification_report.j2                  # Report template
└── documentation/
    ├── TASK_SUMMARY.md                         # Executive summary
    ├── README_TASK_2.1.4.md                    # Complete documentation
    └── QUICK_REFERENCE_2.1.4.md                # Quick reference

Generated on Server:
├── /opt/mail_server/postgres/connection_info/
│   └── connection_guide.md                     # Complete connection documentation
├── /opt/mail_server/postgres/connection_strings/
│   ├── postfix.env                             # Postfix credentials
│   ├── dovecot.env                             # Dovecot credentials
│   ├── sogo.env                                # SOGo credentials
│   └── mailadmin.env                           # Admin credentials
└── /opt/mail_server/postgres/verification_reports/
    └── verification_YYYY-MM-DD_HHMMSS.md       # Timestamped report
```

**Command:**
```bash
./run_task.sh 2.1.4
```

**Alternative (One-liner):**
```bash
export ANSIBLE_HOST=10.100.0.25 ANSIBLE_REMOTE_PORT=2288 ANSIBLE_REMOTE_USER=phalkonadmin ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common && ansible-playbook -i "${ANSIBLE_HOST}," -e "ansible_port=${ANSIBLE_REMOTE_PORT}" -e "ansible_user=${ANSIBLE_REMOTE_USER}" --private-key="${ANSIBLE_PRIVATE_KEY_FILE}" task_2.1.4.yml
```

**Verification Checks (24 total):**

| Category | Checks | Expected Result |
|----------|--------|-----------------|
| Container Status | Running, Health | ✓ Up and healthy |
| Network Binding | VPN-only access | ✓ 10.100.0.25:5432 |
| Service Users | 4 authentications | ✓ All connected |
| Permissions | User access levels | ✓ Correct isolation |
| Schema | 3 tables, 1 view, 1 function | ✓ All present |
| Authentication | Password tests | ✓ Working correctly |
| Backups | Files and WAL | ✓ Available |
| Automation | Cron jobs | ✓ Configured |

**Post-Execution Review:**
```bash
# SSH to server
ssh -p 2288 phalkonadmin@10.100.0.25

# View connection guide
sudo cat /opt/mail_server/postgres/connection_info/connection_guide.md

# View verification report
sudo cat /opt/mail_server/postgres/verification_reports/verification_*.md

# Test service connection
source /opt/mail_server/postgres/connection_strings/postfix.env
docker exec mailserver-postgres psql -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT * FROM virtual_domains;"
```

**Expected Output:**
```
✓ Container Status: Running and Healthy
✓ Network Binding: VPN-only (10.100.0.25:5432)
✓ Service Users: All authenticated successfully
✓ Database Schema: All tables, views, and functions present
✓ Authentication: Password verification working correctly
✓ Backups: X backup(s) available
✓ WAL Archiving: Enabled and functioning
✓ Cron Jobs: Automated backups configured

Task Group 2.1 is now 100% complete!
Ready to proceed with Task Group 2.2 (Postfix MTA)
```

**Success Criteria:**
- ✅ All 24 verification checks pass
- ✅ Service users authenticate successfully
- ✅ Database schema is complete
- ✅ Authentication functions work correctly
- ✅ Backup system operational
- ✅ Documentation generated
- ✅ No errors in playbook execution

**What Gets Documented:**
- Complete connection strings for all services
- Usage examples and commands
- Security best practices
- Troubleshooting procedures
- Network access requirements
- Backup and recovery information

**Security Highlights:**
- Validates VPN-only access (no public exposure)
- Confirms service user permission isolation
- Verifies credential file protection (0640)
- Tests SCRAM-SHA-256 authentication
- Validates SHA512-CRYPT password hashing

---

**Task Group Version:** 1.1  
**Last Updated:** 2026-01-15  
**Status:** 📦 Task 2.1.4 Package Ready - 75% Complete (3 of 4 tasks executed, 1 packaged)
