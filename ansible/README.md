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
