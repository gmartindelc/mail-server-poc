# Task 2.1.4: Final PostgreSQL Database Verification

## Overview

This task performs comprehensive verification of the PostgreSQL database layer to ensure all components are properly configured, secure, and operational before proceeding to mail service deployment.

## Purpose

- Validate container health and network binding
- Test all service user authentication and permissions
- Verify database schema integrity
- Validate authentication functions
- Confirm backup and WAL archiving systems
- Document connection strings for all services
- Generate verification report

## Prerequisites

- Task 2.1.1: PostgreSQL container deployed
- Task 2.1.2: Database schema configured
- Task 2.1.3: Backups and WAL archiving configured
- VPN access to server (10.100.0.25)
- SSH access configured

## What This Task Does

### 1. Container Health Verification
- Checks PostgreSQL container is running
- Validates container health status
- Confirms VPN-only binding (10.100.0.25:5432)
- Verifies no public exposure

### 2. Service User Authentication
Tests each service user:
- **postfix**: Mail routing (read-only)
- **dovecot**: IMAP/POP3 authentication (read-only)
- **sogo**: Webmail operations (read-write)
- **mailadmin**: Administrative tasks (full access)

### 3. Schema Integrity Checks
- Validates all required tables exist
- Confirms views are present and functional
- Tests authentication functions
- Verifies test data integrity

### 4. Authentication Function Testing
- Tests password verification with correct credentials
- Verifies rejection of incorrect passwords
- Validates SHA512-CRYPT hashing

### 5. Backup System Validation
- Confirms backup files exist
- Validates WAL archiving is enabled
- Checks cron job configuration
- Verifies backup scripts are executable

### 6. Documentation Generation
- Creates connection string guide
- Generates service-specific environment files
- Produces comprehensive verification report

## Files Created

### Playbooks
```
task_2.1.4.yml                              # Main task wrapper
playbooks/verify_postgresql_complete.yml    # Comprehensive verification playbook
```

### Templates
```
templates/connection_strings_doc.j2         # Connection guide template
templates/service_env.j2                    # Service environment template
templates/verification_report.j2            # Verification report template
```

### Generated on Server
```
/opt/mail_server/postgres/connection_info/
  └── connection_guide.md                   # Complete connection documentation

/opt/mail_server/postgres/connection_strings/
  ├── postfix.env                           # Postfix connection variables
  ├── dovecot.env                           # Dovecot connection variables
  ├── sogo.env                              # SOGo connection variables
  └── mailadmin.env                         # Admin connection variables

/opt/mail_server/postgres/verification_reports/
  └── verification_YYYY-MM-DD_HHMMSS.md     # Timestamped verification report
```

## Execution

### Environment Setup
```bash
# Set required environment variables
export ANSIBLE_HOST=10.100.0.25
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
```

### Run Task
```bash
# Execute verification
ansible-playbook -i "${ANSIBLE_HOST}," \
  -e "ansible_port=${ANSIBLE_REMOTE_PORT}" \
  -e "ansible_user=${ANSIBLE_REMOTE_USER}" \
  --private-key="${ANSIBLE_PRIVATE_KEY_FILE}" \
  task_2.1.4.yml
```

### Alternative: Using run_task.sh
```bash
./run_task.sh 2.1.4
```

## Verification Checks

The playbook performs the following checks:

1. **Container Status** ✓
   - Container is running
   - Health status is "healthy"

2. **Network Binding** ✓
   - PostgreSQL listening on 10.100.0.25:5432
   - VPN-only access enforced

3. **Service Authentication** ✓
   - All 4 service users connect successfully
   - Permissions match design specifications

4. **Schema Integrity** ✓
   - 3 tables present (virtual_domains, virtual_users, virtual_aliases)
   - 1 view present (user_mailbox_info)
   - 1 function present (verify_password)

5. **Authentication Function** ✓
   - Correct passwords accepted
   - Incorrect passwords rejected

6. **Backup System** ✓
   - At least one backup file exists
   - WAL archiving is enabled
   - Cron jobs are configured
   - Scripts are executable

## Expected Output

### Success Indicators
```
PLAY RECAP ********************************************************
server_ip              : ok=XX   changed=X    unreachable=0    failed=0

✓ Container Status: Running and Healthy
✓ Network Binding: VPN-only (10.100.0.25:5432)
✓ Service Users: All authenticated successfully
✓ Database Schema: All tables, views, and functions present
✓ Authentication: Password verification working correctly
✓ Backups: X backup(s) available
✓ WAL Archiving: Enabled and functioning
✓ Cron Jobs: Automated backups configured

Task Group 2.1 is now 100% complete!
```

### Generated Files
```
Connection Guide:
  /opt/mail_server/postgres/connection_info/connection_guide.md

Service Credentials:
  /opt/mail_server/postgres/connection_strings/postfix.env
  /opt/mail_server/postgres/connection_strings/dovecot.env
  /opt/mail_server/postgres/connection_strings/sogo.env
  /opt/mail_server/postgres/connection_strings/mailadmin.env

Verification Report:
  /opt/mail_server/postgres/verification_reports/verification_YYYY-MM-DD_HHMMSS.md
```

## Post-Verification Tasks

### Review Documentation
```bash
# SSH to server
ssh -p 2288 phalkonadmin@10.100.0.25

# View connection guide
sudo cat /opt/mail_server/postgres/connection_info/connection_guide.md

# View verification report
sudo cat /opt/mail_server/postgres/verification_reports/verification_*.md | less
```

### Test Service Connections
```bash
# Test Postfix user
source /opt/mail_server/postgres/connection_strings/postfix.env
docker exec mailserver-postgres psql -U postfix -d mailserver -c "SELECT * FROM virtual_domains;"

# Test Dovecot user
source /opt/mail_server/postgres/connection_strings/dovecot.env
docker exec mailserver-postgres psql -U dovecot -d mailserver -c "SELECT email FROM user_mailbox_info;"
```

### Verify Backup System
```bash
# Run manual backup
sudo /opt/mail_server/postgres/scripts/backup_database.sh

# Verify backups
sudo /opt/mail_server/postgres/scripts/verify_backups.sh

# Check cron jobs
sudo crontab -l | grep postgres
```

## Troubleshooting

### Container Not Running
```bash
# Check container status
docker ps -a | grep mailserver-postgres

# View container logs
docker logs mailserver-postgres

# Restart container
cd /opt/mail_server/postgres && sudo ./scripts/manage.sh restart
```

### Authentication Failed
```bash
# Verify credentials file exists
sudo ls -la /root/postgres_service_users.txt

# Check service user in database
docker exec mailserver-postgres psql -U postgres -d mailserver -c "\du"

# Reset service user password (if needed)
# Re-run task 2.1.2
```

### Connection Refused
```bash
# Check VPN is connected
ping 10.100.0.25

# Check PostgreSQL is listening
sudo ss -tlnp | grep 5432

# Check UFW rules
sudo ufw status | grep 5432
```

### Schema Missing
```bash
# Check database exists
docker exec mailserver-postgres psql -U postgres -c "\l"

# Check tables
docker exec mailserver-postgres psql -U postgres -d mailserver -c "\dt"

# Re-run schema creation if needed
# Re-run task 2.1.2
```

## Security Considerations

1. **Credential Protection**
   - All password files have 0640 permissions (root readable only)
   - Service users have minimal necessary permissions
   - No credentials in version control

2. **Network Isolation**
   - PostgreSQL bound to VPN interface only
   - No public internet access
   - UFW restricts connections to VPN subnet

3. **Audit Trail**
   - Verification reports timestamped
   - All tests logged
   - Service user activities trackable

## Integration Points

### Postfix Integration (Task Group 2.2)
```ini
# Postfix will use these connection settings
hosts = 10.100.0.25
user = postfix
password = [from postfix.env]
dbname = mailserver
```

### Dovecot Integration (Task Group 2.3)
```conf
# Dovecot will use these connection settings
driver = pgsql
connect = host=10.100.0.25 dbname=mailserver user=dovecot password=[from dovecot.env]
```

### SOGo Integration (Task Group 2.4)
```plist
# SOGo will use these connection settings
SOGoProfileURL = "postgresql://sogo:[password]@10.100.0.25:5432/mailserver/[table]"
```

## Success Criteria

- ✅ All verification checks pass
- ✅ Service users authenticate successfully
- ✅ Database schema is complete
- ✅ Authentication functions work correctly
- ✅ Backup system is operational
- ✅ Documentation is generated
- ✅ No errors in playbook execution

## Next Steps

After successful completion:

1. **Review verification report**
   ```bash
   sudo cat /opt/mail_server/postgres/verification_reports/verification_*.md
   ```

2. **Update project documentation**
   - Mark Task 2.1.4 as complete in tasks.md
   - Update session log
   - Note Task Group 2.1 is 100% complete

3. **Proceed to Task Group 2.2**
   - Postfix MTA installation
   - PostgreSQL integration for virtual domains
   - Mail routing configuration

## Maintenance

### Regular Verification
Run this verification after:
- PostgreSQL updates
- Schema changes
- Password rotations
- System migrations
- Monthly health checks

### Monitoring
Monitor these metrics:
- Container health status
- Database connection count
- Backup file count and size
- WAL archive growth
- Query performance

## Related Documentation

- Task 2.1.1: PostgreSQL Container Deployment
- Task 2.1.2: Database Schema Configuration
- Task 2.1.3: Backup and WAL Archiving
- Connection Guide: Generated by this task
- PostgreSQL Documentation: /opt/mail_server/postgres/README.md

---

**Task Status:** Ready for Execution  
**Estimated Time:** 2-3 minutes  
**Risk Level:** Low (read-only verification)  
**Rollback Required:** No (no changes made to system)
