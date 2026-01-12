# Task 1.4.2 - Set Proper Permissions and Ownership

## Overview

This task creates system users and configures proper ownership and permissions on the directories created in Task 1.4.1, preparing them for use by mail services and PostgreSQL container.

## What This Task Does

### 1. Creates System Users

**vmail user (UID 5000):**
- Purpose: Owns virtual mail storage
- UID: 5000 (avoids system UID conflicts)
- Shell: /usr/sbin/nologin (security - no login)
- Home: /var/mail/vmail
- Groups: vmail (primary)

**postgres user (UID 999):**
- Purpose: PostgreSQL container file access
- UID: 999 (standard PostgreSQL container UID)
- Shell: /usr/sbin/nologin (security - no login)
- Home: /opt/postgres
- Groups: postgres (primary)

### 2. Sets Ownership

**Mail directories → vmail:vmail:**
- /var/mail/vmail/
- /var/mail/queue/
- /var/mail/backups/

**PostgreSQL directories → postgres:postgres:**
- /opt/postgres/data/
- /opt/postgres/wal_archive/
- /opt/postgres/backups/

### 3. Configures Permissions

**Mail directories: 750 (rwxr-x---):**
- Owner (vmail): Read, write, execute
- Group (vmail): Read, execute
- Others: No access

**PostgreSQL data: 700 (rwx------):**
- Owner (postgres): Read, write, execute
- Group: No access
- Others: No access
- Required by PostgreSQL for security

**PostgreSQL WAL/backups: 750 (rwxr-x---):**
- Owner (postgres): Read, write, execute
- Group (postgres): Read, execute
- Others: No access

## Prerequisites

- **Completed Tasks:** Task 1.4.1 (Directory structure created)
- **Access:** VPN connection established, SSH access as phalkonadmin
- **Environment Variables Set:**
  ```bash
  export ANSIBLE_HOST=10.100.0.25
  export ANSIBLE_REMOTE_PORT=2288
  export ANSIBLE_REMOTE_USER=phalkonadmin
  export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
  ```

## Files Included

1. **task_1.4.2.yml** - Task wrapper playbook
2. **configure_directory_permissions.yml** - Reusable permissions configuration playbook

## Usage

### Recommended Workflow

**Note on Check Mode:** While this task attempts to support check mode, there are limitations because users are simulated but not actually created, causing subsequent ownership changes to fail. 

**Recommended approach:**
```bash
# This task is safe and idempotent - run directly
./run_task.sh 1.4.2
```

**If you want to preview (with limitations):**
```bash
# Check mode will show:
# ✓ Which users would be created
# ✗ Ownership changes will fail (users don't exist in dry-run)
./run_task.sh 1.4.2 --check
```

### Standard Execution

```bash
./run_task.sh 1.4.2
```

### Dry-Run (Check Mode - Limited Support)

```bash
./run_task.sh 1.4.2 --check
```

**Check mode limitations for this task:**
- ✅ Shows which users would be created
- ❌ Users aren't actually created (simulation only)
- ❌ Ownership changes fail (users don't exist)
- ❌ Verification steps fail

**This is expected behavior** - in check mode, users are simulated but subsequent tasks that reference those users will fail because they don't actually exist on the system.

**Expected check mode output:**
```yaml
TASK [Display check mode warning]
ok: [mail_server] => 
  msg:
  - "⚠️  CHECK MODE LIMITATION"
  - "Ownership and verification tasks will fail (expected behavior)."

TASK [Create vmail system user (UID 5000)]
changed: [mail_server]  # Simulated

TASK [Set ownership on mail directories]
failed: [mail_server]  # Expected - users don't exist in check mode
```

**Recommendation:** This task is safe and idempotent - run directly without `--check`.

### Direct Ansible Execution

```bash
ansible-playbook playbooks/task_1.4.2.yml
```

## Expected Output

```yaml
PLAY [Task 1.4.2 - Set Permissions and Ownership] *****************************

TASK [Check if vmail user already exists] *************************************
ok: [mail_server]

TASK [Check if postgres user already exists] **********************************
ok: [mail_server]

TASK [Create vmail system user (UID 5000)] ************************************
changed: [mail_server]

TASK [Create postgres system user (UID 999)] **********************************
changed: [mail_server]

TASK [Display user creation status] *******************************************
ok: [mail_server] => {
    "msg": [
        "User Creation Status:",
        "  vmail: Created",
        "  postgres: Created"
    ]
}

TASK [Verify vmail user UID] **************************************************
ok: [mail_server]

TASK [Verify postgres user UID] ***********************************************
ok: [mail_server]

TASK [Set ownership on mail directories] **************************************
changed: [mail_server] => (item=/var/mail/vmail)
changed: [mail_server] => (item=/var/mail/queue)
changed: [mail_server] => (item=/var/mail/backups)

TASK [Set ownership on PostgreSQL directories] ********************************
changed: [mail_server] => (item=/opt/postgres/data)
changed: [mail_server] => (item=/opt/postgres/wal_archive)
changed: [mail_server] => (item=/opt/postgres/backups)

TASK [Set permissions on mail directories (750)] ******************************
changed: [mail_server] => (item=/var/mail/vmail)
changed: [mail_server] => (item=/var/mail/queue)
changed: [mail_server] => (item=/var/mail/backups)

TASK [Set permissions on PostgreSQL data directory (700)] *********************
changed: [mail_server]

TASK [Set permissions on PostgreSQL WAL and backup directories (750)] *********
changed: [mail_server] => (item=/opt/postgres/wal_archive)
changed: [mail_server] => (item=/opt/postgres/backups)

TASK [Display task completion summary] ****************************************
ok: [mail_server] => {
    "msg": [
        "==========================================",
        "Task 1.4.2 - Permissions Configuration Complete",
        "==========================================",
        ...
    ]
}

PLAY RECAP ********************************************************************
mail_server                : ok=18   changed=9    unreachable=0    failed=0
```

## Post-Execution Verification

### Verify on Server

```bash
# SSH to the server
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25

# Check users were created
id vmail
# Expected: uid=5000(vmail) gid=5000(vmail) groups=5000(vmail)

id postgres
# Expected: uid=999(postgres) gid=999(postgres) groups=999(postgres)

# Check mail directory ownership and permissions
sudo ls -ld /var/mail/vmail /var/mail/queue /var/mail/backups
# Expected output:
# drwxr-x--- 2 vmail vmail 4096 Jan 12 XX:XX /var/mail/vmail
# drwxr-x--- 2 vmail vmail 4096 Jan 12 XX:XX /var/mail/queue
# drwxr-x--- 2 vmail vmail 4096 Jan 12 XX:XX /var/mail/backups

# Check PostgreSQL directory ownership and permissions
sudo ls -ld /opt/postgres/data /opt/postgres/wal_archive /opt/postgres/backups
# Expected output:
# drwx------ 2 postgres postgres 4096 Jan 12 XX:XX /opt/postgres/data
# drwxr-x--- 2 postgres postgres 4096 Jan 12 XX:XX /opt/postgres/wal_archive
# drwxr-x--- 2 postgres postgres 4096 Jan 12 XX:XX /opt/postgres/backups

# Verify numeric UIDs
ls -ln /var/mail/ | grep vmail
# Should show UID 5000

ls -ln /opt/postgres/ | grep data
# Should show UID 999
```

### Automated Verification Script

```bash
#!/bin/bash
# Verification script for Task 1.4.2

echo "=== User Verification ==="
id vmail | grep "uid=5000" && echo "✓ vmail UID correct" || echo "✗ vmail UID incorrect"
id postgres | grep "uid=999" && echo "✓ postgres UID correct" || echo "✗ postgres UID incorrect"

echo ""
echo "=== Mail Directory Verification ==="
for dir in vmail queue backups; do
    if sudo stat -c "%U:%G %a" /var/mail/$dir | grep -q "vmail:vmail 750"; then
        echo "✓ /var/mail/$dir: vmail:vmail 750"
    else
        echo "✗ /var/mail/$dir: incorrect ownership/permissions"
    fi
done

echo ""
echo "=== PostgreSQL Directory Verification ==="
if sudo stat -c "%U:%G %a" /opt/postgres/data | grep -q "postgres:postgres 700"; then
    echo "✓ /opt/postgres/data: postgres:postgres 700"
else
    echo "✗ /opt/postgres/data: incorrect ownership/permissions"
fi

for dir in wal_archive backups; do
    if sudo stat -c "%U:%G %a" /opt/postgres/$dir | grep -q "postgres:postgres 750"; then
        echo "✓ /opt/postgres/$dir: postgres:postgres 750"
    else
        echo "✗ /opt/postgres/$dir: incorrect ownership/permissions"
    fi
done
```

## State Transition

### Before Task 1.4.2
```
Users:
  vmail: Does not exist
  postgres: Does not exist

/var/mail/vmail/      → root:root, 0755
/var/mail/queue/      → root:root, 0755
/var/mail/backups/    → root:root, 0755
/opt/postgres/data/   → root:root, 0755
/opt/postgres/wal_archive/ → root:root, 0755
/opt/postgres/backups/     → root:root, 0755
```

### After Task 1.4.2
```
Users:
  vmail: uid=5000, gid=5000, shell=/usr/sbin/nologin
  postgres: uid=999, gid=999, shell=/usr/sbin/nologin

/var/mail/vmail/      → vmail:vmail, 0750
/var/mail/queue/      → vmail:vmail, 0750
/var/mail/backups/    → vmail:vmail, 0750
/opt/postgres/data/   → postgres:postgres, 0700
/opt/postgres/wal_archive/ → postgres:postgres, 0750
/opt/postgres/backups/     → postgres:postgres, 0750
```

## Why These Settings?

### UID Selection

**vmail (UID 5000):**
- Avoids conflict with system UIDs (typically < 1000)
- Avoids conflict with regular user UIDs (typically 1000-59999)
- Common practice for service accounts in 5000-5999 range

**postgres (UID 999):**
- Standard UID used by PostgreSQL Docker containers
- **Critical:** Must match container UID for volume mounts to work
- Container runs as UID 999 inside, must own files outside

### Permission Levels

**750 (rwxr-x---):**
- Owner: Full control (read, write, execute)
- Group: Read and execute (for backup scripts, monitoring)
- Others: No access (security)
- Used for: Mail dirs, PostgreSQL WAL/backups

**700 (rwx------):**
- Owner: Full control
- Group: No access
- Others: No access
- Used for: PostgreSQL data directory
- **Required:** PostgreSQL refuses to start if data directory is group/world accessible

### No Login Shells

Both users have `/usr/sbin/nologin`:
- Security best practice
- Prevents interactive login
- Users are service accounts only
- Still allows process/daemon to run as user

## Docker Volume Mount Compatibility

When PostgreSQL container starts, it will mount `/opt/postgres/data` as `/var/lib/postgresql/data` inside the container.

**Inside container:**
- Process runs as user `postgres` (UID 999)
- Needs to read/write files in `/var/lib/postgresql/data`

**Outside container (host):**
- Directory `/opt/postgres/data` mounted into container
- Must be owned by UID 999 on host
- Our `postgres` user (UID 999) provides this

**Result:** Container's postgres process (UID 999) can access host's files (owned by UID 999).

## Check Mode Compatibility

**⚠️ This task has LIMITED check mode support**

Check mode can preview user creation but has inherent limitations:

### The Check Mode Limitation

1. **User Module:** Simulates user creation (shows "changed")
2. **But:** Users don't actually exist on the system
3. **Result:** Subsequent tasks that reference users (ownership changes) fail
4. **This is expected Ansible behavior** - not a bug in the playbook

### What You'll See in Check Mode

| Operation | Check Mode Behavior |
|-----------|---------------------|
| Create users | ✅ Shows "changed" (simulated) |
| Verify UIDs | ❌ Fails - users don't exist |
| Set ownership | ❌ Fails - can't chown to non-existent users |
| Set permissions | ❌ Skipped - previous task failed |
| Verification | ❌ Skipped - previous tasks failed |

### Recommended Practice

**Just run it directly** - this task is safe and idempotent:
```bash
# Safe to run - only creates users and sets permissions
./run_task.sh 1.4.2
```

**Why it's safe:**
- User module is idempotent (won't recreate existing users)
- File module is idempotent (won't change if already correct)
- No destructive operations
- Can be run multiple times safely

### If You Insist on Check Mode

If you want to preview, understand you'll see failures:
```bash
./run_task.sh 1.4.2 --check
# Expected: User creation "changed", ownership tasks fail
# This is NORMAL and EXPECTED behavior
```

## Troubleshooting

### Issue: "User already exists" errors

**Symptom:**
```
fatal: [mail_server]: FAILED! => {"msg": "useradd: user 'vmail' already exists"}
```

**Solution:**
The playbook checks for existing users before creating them. If you see this error, the user exists but with wrong UID. To fix:
```bash
# Delete existing user
sudo userdel vmail
# Or force with specific UID
sudo usermod -u 5000 vmail
```

### Issue: "Permission denied" when setting ownership

**Symptom:**
```
fatal: [mail_server]: FAILED! => {"msg": "chown: changing ownership of '/var/mail/vmail': Operation not permitted"}
```

**Solution:**
- Ensure running with `become: yes` (already configured)
- Check phalkonadmin has sudo privileges: `sudo -l`

### Issue: PostgreSQL container can't access data directory

**Symptom:**
```
postgres container: initdb: error: could not change permissions of directory "/var/lib/postgresql/data": Operation not permitted
```

**Solution:**
- Verify postgres user has UID 999: `id postgres`
- Verify data directory owned by postgres: `ls -ln /opt/postgres/data`
- Re-run Task 1.4.2 to fix permissions

### Issue: UID already in use

**Symptom:**
```
useradd: UID 999 is not unique
```

**Solution:**
Another user already has UID 999. Check:
```bash
getent passwd 999
```
If it's not postgres, either delete that user or choose different UID (requires updating containers too).

## Security Considerations

### No Login Capability
- Both users have `/usr/sbin/nologin` shell
- Cannot SSH or login interactively
- Can only run processes/services

### Minimal Permissions
- Others have no access to any directories
- Group access only where needed (backups, monitoring)
- PostgreSQL data has strictest permissions (700)

### UID Isolation
- UIDs chosen to avoid conflicts
- Service accounts separated from user accounts
- Container UID matches host UID for security

## Integration Points

### With Postfix (Task 3.x)
Postfix will run as `vmail` user when delivering mail to `/var/mail/vmail/`

### With Dovecot (Task 3.x)
Dovecot will access mailboxes as `vmail` user

### With PostgreSQL Container (Task 2.1.1)
Container will mount `/opt/postgres/data` and run as UID 999

### With Backup Scripts (Future)
Backup scripts can read from directories (group access via 750 permissions)

## Next Steps

After completing Task 1.4.2, proceed to:

**Task 1.4.3: Configure disk quotas for /var/mail/vmail/**
- Set filesystem quotas
- Configure per-user limits
- Enable quota enforcement
- Prevent mailbox storage abuse

## References

- **Planning Document:** Section 5.1 (Filesystem Layout)
- **Tasks Document:** Task 1.4.2 specification
- **Previous Task:** Task 1.4.1 (Directory Structure)
- **Next Task:** Task 1.4.3 (Disk Quotas)
- **PostgreSQL Docker:** UID 999 standard documented in official postgres:alpine image
