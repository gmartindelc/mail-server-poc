# Task 2.1.4 Quick Reference

## One-Line Execution

```bash
export ANSIBLE_HOST=10.100.0.25 ANSIBLE_REMOTE_PORT=2288 ANSIBLE_REMOTE_USER=phalkonadmin ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common && ansible-playbook -i "${ANSIBLE_HOST}," -e "ansible_port=${ANSIBLE_REMOTE_PORT}" -e "ansible_user=${ANSIBLE_REMOTE_USER}" --private-key="${ANSIBLE_PRIVATE_KEY_FILE}" task_2.1.4.yml
```

## What Gets Verified

| Component | Check | Expected Result |
|-----------|-------|-----------------|
| Container | Running status | "Up" in status |
| Container | Health check | "healthy" |
| Network | VPN binding | 10.100.0.25:5432 |
| Postfix | Authentication | ✓ Connected |
| Dovecot | Authentication | ✓ Connected |
| SOGo | Authentication | ✓ Connected |
| Mailadmin | Authentication | ✓ Connected |
| Tables | Existence | 3 tables present |
| Views | Existence | 1 view present |
| Functions | Existence | 1 function present |
| Auth | Correct password | ✓ Accepted |
| Auth | Wrong password | ✗ Rejected |
| Backups | File count | ≥1 backup |
| WAL | Archive status | Enabled |
| Cron | Backup job | Configured |

## Generated Files

```
/opt/mail_server/postgres/connection_info/connection_guide.md
/opt/mail_server/postgres/connection_strings/*.env (4 files)
/opt/mail_server/postgres/verification_reports/verification_*.md
```

## Post-Verification Commands

```bash
# View connection guide
sudo cat /opt/mail_server/postgres/connection_info/connection_guide.md

# View verification report
sudo ls -lh /opt/mail_server/postgres/verification_reports/

# Test service connection
source /opt/mail_server/postgres/connection_strings/postfix.env
docker exec mailserver-postgres psql -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT COUNT(*) FROM virtual_domains;"
```

## Success Indicators

```
✓ Container Status: Running and Healthy
✓ Network Binding: VPN-only (10.100.0.25:5432)
✓ Service Users: 4/4 authenticated
✓ Database Schema: Complete
✓ Authentication: Working correctly
✓ Backups: Available and verified
✓ Task Group 2.1: 100% Complete
```

## Files in This Task

```
task_2.1.4.yml                              # Task wrapper
playbooks/verify_postgresql_complete.yml    # Main verification logic
templates/connection_strings_doc.j2         # Connection guide template
templates/service_env.j2                    # Service environment template
templates/verification_report.j2            # Report template
README_TASK_2.1.4.md                        # Full documentation
QUICK_REFERENCE_2.1.4.md                    # This file
```

## Next Task

**Task Group 2.2: Postfix MTA Installation**
- Install Postfix mail server
- Configure PostgreSQL integration
- Set up virtual domain routing
