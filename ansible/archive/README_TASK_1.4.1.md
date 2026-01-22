# Task 1.4.1 - Create Mail System Directory Structure

## Overview

This task creates the essential directory structure for the mail server system and PostgreSQL database container. It establishes the foundation for mail storage and database persistence.

## What Gets Created

### Mail System Directories

```
/var/mail/
├── vmail/          # Virtual mail storage (user mailboxes in Maildir format)
├── queue/          # Postfix mail queue (incoming/outgoing)
└── backups/        # Local backups of mail data
```

### PostgreSQL Container Directories

```
/opt/postgres/
├── data/           # PostgreSQL data directory (Docker volume mount)
├── wal_archive/    # Write-Ahead Log archives for point-in-time recovery
└── backups/        # Database dumps and backup scripts
```

## Prerequisites

- **Completed Tasks:** Task 1.3.1 (System Hardening)
- **Access:** VPN connection established, SSH access as phalkonadmin
- **Environment Variables Set:**
  ```bash
  export ANSIBLE_HOST=10.100.0.25
  export ANSIBLE_REMOTE_PORT=2288
  export ANSIBLE_REMOTE_USER=phalkonadmin
  export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
  ```

## Files Included

1. **task_1.4.1.yml** - Task wrapper playbook
2. **playbooks/create_mail_directories.yml** - Reusable directory creation playbook

## Usage

### Standard Execution

```bash
./run_task.sh 1.4.1
```

### Dry-Run (Check Mode)

```bash
./run_task.sh 1.4.1 --check
```

### Direct Ansible Execution

```bash
ansible-playbook task_1.4.1.yml
```

## What This Task Does

1. **Creates Mail Storage Structure**
   - Creates `/var/mail` base directory
   - Creates subdirectories for vmail, queue, and backups
   - Sets initial permissions to 0755 with root:root ownership

2. **Creates PostgreSQL Structure**
   - Creates `/opt/postgres` base directory
   - Creates data, wal_archive, and backups subdirectories
   - Prepares volume mount points for Docker container

3. **Verifies Directory Creation**
   - Checks that all directories exist
   - Validates directories are properly created
   - Reports any creation failures

4. **Provides Next Steps**
   - Displays summary of created directories
   - Shows current ownership and permissions
   - Lists requirements for Task 1.4.2

## Expected Output

```
TASK [Display task completion summary] *****************************************
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
```

## Verification

After running the task, verify the directory structure on the server:

```bash
# SSH to the server
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25

# Check mail directories
sudo ls -la /var/mail/
# Expected output:
# drwxr-xr-x  5 root root 4096 Jan 12 10:00 .
# drwxr-xr-x 14 root root 4096 Jan 12 09:55 ..
# drwxr-xr-x  2 root root 4096 Jan 12 10:00 backups
# drwxr-xr-x  2 root root 4096 Jan 12 10:00 queue
# drwxr-xr-x  2 root root 4096 Jan 12 10:00 vmail

# Check PostgreSQL directories
sudo ls -la /opt/postgres/
# Expected output:
# drwxr-xr-x  5 root root 4096 Jan 12 10:00 .
# drwxr-xr-x  3 root root 4096 Jan 12 10:00 ..
# drwxr-xr-x  2 root root 4096 Jan 12 10:00 backups
# drwxr-xr-x  2 root root 4096 Jan 12 10:00 data
# drwxr-xr-x  2 root root 4096 Jan 12 10:00 wal_archive

# Verify directory existence
sudo test -d /var/mail/vmail && echo "✓ vmail directory exists"
sudo test -d /var/mail/queue && echo "✓ queue directory exists"
sudo test -d /var/mail/backups && echo "✓ backups directory exists"
sudo test -d /opt/postgres/data && echo "✓ postgres data directory exists"
sudo test -d /opt/postgres/wal_archive && echo "✓ postgres wal_archive directory exists"
sudo test -d /opt/postgres/backups && echo "✓ postgres backups directory exists"
```

## Current State vs. Final State

### After Task 1.4.1 (Current)
```
/var/mail/vmail/      - Owner: root:root,    Mode: 0755
/var/mail/queue/      - Owner: root:root,    Mode: 0755
/var/mail/backups/    - Owner: root:root,    Mode: 0755
/opt/postgres/data/   - Owner: root:root,    Mode: 0755
/opt/postgres/wal_archive/ - Owner: root:root, Mode: 0755
/opt/postgres/backups/     - Owner: root:root, Mode: 0755
```

### After Task 1.4.2 (Target)
```
/var/mail/vmail/      - Owner: vmail:vmail,      Mode: 0750
/var/mail/queue/      - Owner: vmail:vmail,      Mode: 0750
/var/mail/backups/    - Owner: vmail:vmail,      Mode: 0750
/opt/postgres/data/   - Owner: postgres:postgres, Mode: 0700
/opt/postgres/wal_archive/ - Owner: postgres:postgres, Mode: 0750
/opt/postgres/backups/     - Owner: postgres:postgres, Mode: 0750
```

## PostgreSQL Container Notes

The directories created in `/opt/postgres/` will be mounted into the PostgreSQL Docker container:

- **Container Image:** `postgres:17-alpine`
- **Container User:** postgres (UID 999 - standard PostgreSQL container UID)
- **Volume Mounts:**
  ```yaml
  volumes:
    - /opt/postgres/data:/var/lib/postgresql/data
    - /opt/postgres/wal_archive:/var/lib/postgresql/wal_archive
  ```
- **Network Binding:** VPN IP only (10.100.0.25:5432)
- **Access Control:** Only accessible from VPN network

The postgres system user (UID 999) will be created in Task 1.4.2 to match the container's UID, ensuring proper file permissions for volume mounts.

## Troubleshooting

### Issue: Permission Denied

**Symptom:**
```
fatal: [mail_server]: FAILED! => {"msg": "Permission denied"}
```

**Solution:**
- Ensure you're using `become: yes` in the playbook (already configured)
- Verify phalkonadmin has sudo privileges: `sudo -l`
- Check NOPASSWD sudo configuration: `sudo cat /etc/sudoers.d/90-nopasswd-sudo`

### Issue: Directory Already Exists

**Symptom:**
```
changed: [mail_server]  # Should be "ok" not "changed"
```

**Solution:**
- This is normal behavior - Ansible ensures directories exist
- If directories existed before, task shows as "ok" (idempotent)
- If created new, task shows as "changed"

### Issue: Ansible Connection Fails

**Symptom:**
```
fatal: [mail_server]: UNREACHABLE!
```

**Solution:**
```bash
# Verify environment variables are set
echo $ANSIBLE_HOST          # Should be: 10.100.0.25
echo $ANSIBLE_REMOTE_PORT   # Should be: 2288
echo $ANSIBLE_REMOTE_USER   # Should be: phalkonadmin

# Test SSH connection manually
ssh -p 2288 -o IdentitiesOnly=yes -i $ANSIBLE_PRIVATE_KEY_FILE $ANSIBLE_REMOTE_USER@$ANSIBLE_HOST

# Verify VPN is active
ping -c 3 10.100.0.25
```

## Next Steps

After completing Task 1.4.1, proceed to:

**Task 1.4.2: Set proper permissions and ownership for directories**
- Create `vmail` system user (UID 5000)
- Create `postgres` system user (UID 999)
- Set correct ownership on all directories
- Configure appropriate permissions (750/700)

## Integration with Mail System

These directories will be used by:

1. **Postfix** - Uses `/var/mail/queue/` for mail queue management
2. **Dovecot** - Uses `/var/mail/vmail/` for Maildir storage
3. **PostgreSQL** - Uses `/opt/postgres/data/` for database files
4. **Backup Scripts** - Uses `/var/mail/backups/` and `/opt/postgres/backups/`
5. **WAL Archiving** - Uses `/opt/postgres/wal_archive/` for point-in-time recovery

## Security Considerations

- All directories created with minimal permissions (0755)
- Root ownership prevents unauthorized access before proper users created
- PostgreSQL data directory will be restricted to 0700 in Task 1.4.2
- VPN-only access ensures no external exposure of database

## References

- Planning Document: Section 5.1 (Planned Filesystem Layout)
- Tasks Document: Task 1.4.1 specification
- Next Task: Task 1.4.2 (Permissions and Ownership)
