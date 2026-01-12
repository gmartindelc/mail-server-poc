# Task 1.4.2 - Quick Reference

## One-Line Summary
Creates vmail (UID 5000) and postgres (UID 999) users, then sets proper ownership and permissions on all directories.

## Quick Start

```bash
# Verify Task 1.4.1 completed
ssh -p $ANSIBLE_REMOTE_PORT -i $ANSIBLE_PRIVATE_KEY_FILE $ANSIBLE_REMOTE_USER@$ANSIBLE_HOST \
  "sudo ls -ld /var/mail/vmail /opt/postgres/data"

# Execute task
./run_task.sh 1.4.2
```

## What Gets Changed

```
Users Created:
  vmail (UID 5000)    → Virtual mail storage owner
  postgres (UID 999)  → PostgreSQL container user

Ownership & Permissions:
  /var/mail/vmail/      → vmail:vmail, 750
  /var/mail/queue/      → vmail:vmail, 750
  /var/mail/backups/    → vmail:vmail, 750
  /opt/postgres/data/   → postgres:postgres, 700 (strict!)
  /opt/postgres/wal_archive/ → postgres:postgres, 750
  /opt/postgres/backups/     → postgres:postgres, 750
```

## Quick Verify

```bash
ssh -p $ANSIBLE_REMOTE_PORT -i $ANSIBLE_PRIVATE_KEY_FILE $ANSIBLE_REMOTE_USER@$ANSIBLE_HOST << 'EOF'
  id vmail | grep "uid=5000" && echo "✓ vmail" || echo "✗ vmail"
  id postgres | grep "uid=999" && echo "✓ postgres" || echo "✗ postgres"
  sudo stat -c "%U:%G %a %n" /var/mail/vmail /opt/postgres/data
EOF
```

## Key Points

- **UID 5000:** Avoids conflicts with system/user UIDs
- **UID 999:** **Critical** - matches PostgreSQL Docker container standard
- **700 on data/:** **Required** by PostgreSQL for security
- **750 on others:** Owner full access, group read/execute, others none

## Next Task
Task 1.4.3: Configure disk quotas for /var/mail/vmail/

## Files
- `task_1.4.2.yml` - Task wrapper
- `configure_directory_permissions.yml` - User creation & permissions logic
- `README_TASK_1.4.2.md` - Full documentation
