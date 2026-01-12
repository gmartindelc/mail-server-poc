# Task 1.4.1 - Quick Reference

## One-Line Summary
Creates mail storage and PostgreSQL container directories with root ownership.

## Quick Start

```bash
# Set environment (if not already set)
export ANSIBLE_HOST=10.100.0.25
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common

# Run task
./run_task.sh 1.4.1
```

## What Gets Created

```
/var/mail/vmail/               → Mail storage (root:root, 0755)
/var/mail/queue/               → Mail queue (root:root, 0755)
/var/mail/backups/             → Mail backups (root:root, 0755)
/opt/postgres/data/            → DB data volume (root:root, 0755)
/opt/postgres/wal_archive/     → DB WAL archives (root:root, 0755)
/opt/postgres/backups/         → DB backups (root:root, 0755)
```

## Quick Verify

```bash
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25 \
  "sudo ls -ld /var/mail/vmail /var/mail/queue /var/mail/backups /opt/postgres/data /opt/postgres/wal_archive /opt/postgres/backups"
```

## Next Task
Task 1.4.2: Set permissions and ownership (create vmail/postgres users)

## Files
- `task_1.4.1.yml` - Task wrapper
- `playbooks/create_mail_directories.yml` - Directory creation logic
- `README_TASK_1.4.1.md` - Full documentation
