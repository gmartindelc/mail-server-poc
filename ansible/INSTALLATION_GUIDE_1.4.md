# Task 1.4.1 - Installation Guide

## Overview

This guide will help you install and execute Task 1.4.1: Create Mail System Directory Structure.

## Files Included

```
task_1.4.1/
├── task_1.4.1.yml                      # Task wrapper (place in ansible root)
├── create_mail_directories.yml         # Reusable playbook (place in ansible/playbooks/)
├── README_TASK_1.4.1.md               # Detailed documentation
├── TASK_1.4.1_DELIVERY_SUMMARY.md     # Delivery summary
└── TASK_1.4.1_QUICK_REFERENCE.md      # Quick reference
```

## Installation Steps

### Step 1: Navigate to Your Ansible Directory

```bash
cd /path/to/mail-server-poc/ansible
```

### Step 2: Install Task Files

```bash
# Both files go in the playbooks directory
cp /path/to/task_1.4.1/task_1.4.1.yml playbooks/
cp /path/to/task_1.4.1/create_mail_directories.yml playbooks/

# (Optional) Copy documentation files to ansible root
cp /path/to/task_1.4.1/README_TASK_1.4.1.md .
cp /path/to/task_1.4.1/TASK_1.4.1_DELIVERY_SUMMARY.md .
cp /path/to/task_1.4.1/TASK_1.4.1_QUICK_REFERENCE.md .
```

### Step 3: Verify File Placement

```bash
# Check both task files are in playbooks directory
ls -l playbooks/task_1.4.1.yml
ls -l playbooks/create_mail_directories.yml

# Your directory structure should now look like:
# ansible/
# ├── playbooks/
# │   ├── task_1.4.1.yml                ← New file
# │   ├── create_mail_directories.yml   ← New file
# │   ├── task_1.3.1.yml
# │   ├── system_hardening.yml
# │   ├── install_wireguard.yml
# │   └── ... (other playbooks)
# ├── ansible.cfg
# ├── inventory.yml
# └── run_task.sh
```

## Pre-Execution Checklist

Before running the task, verify:

- [ ] **Environment Variables Set:**
  ```bash
  export ANSIBLE_HOST=10.100.0.25
  export ANSIBLE_REMOTE_PORT=2288
  export ANSIBLE_REMOTE_USER=phalkonadmin
  export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
  ```

- [ ] **VPN Connection Active:**
  ```bash
  ping -c 3 10.100.0.25
  ```

- [ ] **SSH Access Working:**
  ```bash
  ssh -p 2288 -o IdentitiesOnly=yes -i $ANSIBLE_PRIVATE_KEY_FILE $ANSIBLE_REMOTE_USER@$ANSIBLE_HOST "echo 'SSH OK'"
  ```

- [ ] **Previous Tasks Completed:**
  - Task 1.3.1 (System Hardening) ✅
  - Task 1.3.2 (WireGuard VPN) ✅
  - Task 1.3.3 (Network Interfaces) ✅
  - Task 1.3.4 (SSH VPN-Only) ✅
  - Task 1.3.5 (Fail2ban) ✅

## Execution

### Method 1: Using run_task.sh (Recommended)

```bash
# Dry-run first (check mode)
./run_task.sh 1.4.1 --check

# If dry-run looks good, execute for real
./run_task.sh 1.4.1
```

### Method 2: Direct Ansible Execution

```bash
# Dry-run
ansible-playbook task_1.4.1.yml --check

# Execute
ansible-playbook task_1.4.1.yml
```

### Method 3: With Verbose Output

```bash
# For debugging or detailed output
ansible-playbook task_1.4.1.yml -v   # verbose
ansible-playbook task_1.4.1.yml -vv  # more verbose
ansible-playbook task_1.4.1.yml -vvv # debug level
```

## Expected Output

When successful, you should see:

```yaml
PLAY [Task 1.4.1 - Create Mail System Directory Structure] ********************

TASK [Gathering Facts] *********************************************************
ok: [mail_server]

TASK [Include directory creation playbook] ************************************
included: playbooks/create_mail_directories.yml for mail_server

TASK [Create mail storage base directory] *************************************
changed: [mail_server]

TASK [Create mail system subdirectories] **************************************
changed: [mail_server] => (item=/var/mail/vmail)
changed: [mail_server] => (item=/var/mail/queue)
changed: [mail_server] => (item=/var/mail/backups)

TASK [Create PostgreSQL base directory] ***************************************
changed: [mail_server]

TASK [Create PostgreSQL container volume mount directories] ******************
changed: [mail_server] => (item=/opt/postgres/data)
changed: [mail_server] => (item=/opt/postgres/wal_archive)
changed: [mail_server] => (item=/opt/postgres/backups)

TASK [Verify all mail directories exist] **************************************
ok: [mail_server] => (item=/var/mail/vmail)
ok: [mail_server] => (item=/var/mail/queue)
ok: [mail_server] => (item=/var/mail/backups)

TASK [Verify all PostgreSQL directories exist] ********************************
ok: [mail_server] => (item=/opt/postgres/data)
ok: [mail_server] => (item=/opt/postgres/wal_archive)
ok: [mail_server] => (item=/opt/postgres/backups)

TASK [Assert all mail directories were created successfully] *****************
ok: [mail_server] => (item=/var/mail/vmail)
ok: [mail_server] => (item=/var/mail/queue)
ok: [mail_server] => (item=/var/mail/backups)

TASK [Assert all PostgreSQL directories were created successfully] ***********
ok: [mail_server] => (item=/opt/postgres/data)
ok: [mail_server] => (item=/opt/postgres/wal_archive)
ok: [mail_server] => (item=/opt/postgres/backups)

TASK [Display task completion summary] ****************************************
ok: [mail_server] => {
    "msg": [
        "==========================================",
        "Task 1.4.1 - Directory Creation Complete",
        "==========================================",
        "",
        "Mail System Directories:",
        "  ✓ /var/mail/vmail/          (Virtual mail storage)",
        "  ✓ /var/mail/queue/          (Mail queue)",
        "  ✓ /var/mail/backups/        (Mail system backups)",
        "",
        "PostgreSQL Container Directories:",
        "  ✓ /opt/postgres/data/       (PostgreSQL data volume)",
        "  ✓ /opt/postgres/wal_archive/ (PostgreSQL WAL archives)",
        "  ✓ /opt/postgres/backups/    (PostgreSQL dump backups)",
        ...
    ]
}

PLAY RECAP ********************************************************************
mail_server                : ok=11   changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## Post-Execution Verification

### Verify on Server

```bash
# SSH to the server
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25

# Check mail directories
sudo ls -la /var/mail/

# Check PostgreSQL directories
sudo ls -la /opt/postgres/

# Verify all directories exist
for dir in /var/mail/vmail /var/mail/queue /var/mail/backups \
           /opt/postgres/data /opt/postgres/wal_archive /opt/postgres/backups; do
    if sudo test -d "$dir"; then
        echo "✓ $dir exists"
    else
        echo "✗ $dir MISSING"
    fi
done
```

Expected output:
```
✓ /var/mail/vmail exists
✓ /var/mail/queue exists
✓ /var/mail/backups exists
✓ /opt/postgres/data exists
✓ /opt/postgres/wal_archive exists
✓ /opt/postgres/backups exists
```

### Check Ownership and Permissions

```bash
# Current state (after Task 1.4.1)
sudo ls -ld /var/mail/vmail /var/mail/queue /var/mail/backups
sudo ls -ld /opt/postgres/data /opt/postgres/wal_archive /opt/postgres/backups

# All should show:
# drwxr-xr-x 2 root root 4096 Jan 12 XX:XX /path/to/directory
```

## Troubleshooting

### Issue: "Connection timeout"

**Solution:**
```bash
# Check VPN status
ping -c 3 10.100.0.25

# If VPN down, check WireGuard on server
ssh -p 2288 ... "sudo systemctl status wg-quick@wg0"
```

### Issue: "Permission denied"

**Solution:**
```bash
# Verify sudo access
ssh -p 2288 ... "sudo -l"

# Should show NOPASSWD for all commands
```

### Issue: "Directory already exists" (not an error)

This is normal! The task is idempotent:
- First run: creates directories (changed)
- Subsequent runs: verifies existence (ok)

### Issue: "Task failed" or "Playbook error"

```bash
# Run with verbose output to see details
ansible-playbook task_1.4.1.yml -vvv

# Check ansible log
tail -f ansible.log
```

## What's Next?

After successfully completing Task 1.4.1:

1. **Update tasks.md:**
   - Mark Task 1.4.1 as complete ✅
   - Add completion date
   - Note any observations

2. **Proceed to Task 1.4.2:**
   - Create vmail user (UID 5000)
   - Create postgres user (UID 999)
   - Set ownership on directories
   - Configure permissions

3. **Update Documentation:**
   - Add Task 1.4.1 section to README.md
   - Document any issues encountered
   - Note verification results

## Quick Command Reference

```bash
# Set environment variables
export ANSIBLE_HOST=10.100.0.25
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common

# Execute task
./run_task.sh 1.4.1

# Verify on server
ssh -p 2288 -o IdentitiesOnly=yes -i $ANSIBLE_PRIVATE_KEY_FILE $ANSIBLE_REMOTE_USER@$ANSIBLE_HOST \
  "sudo ls -la /var/mail/ /opt/postgres/"
```

## Support

For issues or questions:
1. Check README_TASK_1.4.1.md for detailed troubleshooting
2. Review TASK_1.4.1_QUICK_REFERENCE.md for quick commands
3. Consult session_2025-01-07.md for patterns from previous tasks

---

**Ready to Execute:** Yes ✅  
**Estimated Time:** 5 minutes  
**Risk Level:** Low (only creates directories)  
**Reversible:** Yes (directories can be removed if needed)
