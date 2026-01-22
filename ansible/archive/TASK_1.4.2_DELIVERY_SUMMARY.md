# Task 1.4.2 Delivery Summary

## Task Information

- **Task ID:** 1.4.2
- **Task Name:** Set Proper Permissions and Ownership for Directories
- **Status:** ✅ Ready for Execution
- **Estimated Duration:** 20 minutes
- **Dependencies:** Task 1.4.1 (Directory structure created) - Completed
- **Assigned To:** GMCE
- **Created On:** 2025-01-12

## Deliverables

### Ansible Playbooks (2 files)

1. **task_1.4.2.yml** - Task wrapper playbook
   - Location: ansible/playbooks/
   - Purpose: Entry point for Task 1.4.2 execution
   - Includes: Reference to reusable playbook

2. **configure_directory_permissions.yml** - Reusable permissions configuration playbook
   - Location: ansible/playbooks/
   - Purpose: Core logic for user creation and permission configuration
   - Features:
     - Creates vmail user (UID 5000)
     - Creates postgres user (UID 999)
     - Sets ownership on all directories
     - Configures permissions (750/700)
     - Comprehensive verification
     - Idempotent (safe to run multiple times)

### Documentation (1 file)

3. **README_TASK_1.4.2.md** - Complete task documentation
   - Overview and purpose
   - User creation details
   - Permission configuration rationale
   - Docker volume mount compatibility
   - Verification procedures
   - Troubleshooting guide
   - Security considerations

## What This Task Accomplishes

### System Users Created

**vmail (UID 5000):**
```
User: vmail
UID: 5000
GID: 5000
Shell: /usr/sbin/nologin
Home: /var/mail/vmail
Purpose: Virtual mail storage owner
```

**postgres (UID 999):**
```
User: postgres
UID: 999
GID: 999
Shell: /usr/sbin/nologin
Home: /opt/postgres
Purpose: PostgreSQL container file access
```

### Ownership Configuration

**Mail Directories (vmail:vmail):**
```
/var/mail/vmail/
/var/mail/queue/
/var/mail/backups/
```

**PostgreSQL Directories (postgres:postgres):**
```
/opt/postgres/data/
/opt/postgres/wal_archive/
/opt/postgres/backups/
```

### Permissions Configuration

| Directory | Owner | Group | Mode | Octal | Purpose |
|-----------|-------|-------|------|-------|---------|
| /var/mail/vmail/ | vmail | vmail | rwxr-x--- | 750 | Mail storage |
| /var/mail/queue/ | vmail | vmail | rwxr-x--- | 750 | Mail queue |
| /var/mail/backups/ | vmail | vmail | rwxr-x--- | 750 | Mail backups |
| /opt/postgres/data/ | postgres | postgres | rwx------ | 700 | DB data (strict) |
| /opt/postgres/wal_archive/ | postgres | postgres | rwxr-x--- | 750 | WAL archives |
| /opt/postgres/backups/ | postgres | postgres | rwxr-x--- | 750 | DB backups |

## State Transition

### Before Task 1.4.2
```
System Users:
  vmail: ✗ Does not exist
  postgres: ✗ Does not exist

Directory Ownership (all root:root):
  /var/mail/vmail/ → root:root, 0755
  /var/mail/queue/ → root:root, 0755
  /var/mail/backups/ → root:root, 0755
  /opt/postgres/data/ → root:root, 0755
  /opt/postgres/wal_archive/ → root:root, 0755
  /opt/postgres/backups/ → root:root, 0755
```

### After Task 1.4.2
```
System Users:
  vmail: ✓ UID 5000, nologin, mail storage owner
  postgres: ✓ UID 999, nologin, container-compatible

Directory Ownership (properly configured):
  /var/mail/vmail/ → vmail:vmail, 0750
  /var/mail/queue/ → vmail:vmail, 0750
  /var/mail/backups/ → vmail:vmail, 0750
  /opt/postgres/data/ → postgres:postgres, 0700
  /opt/postgres/wal_archive/ → postgres:postgres, 0750
  /opt/postgres/backups/ → postgres:postgres, 0750
```

## Critical Design Decisions

### Why UID 5000 for vmail?
- Avoids system UID range (< 1000)
- Avoids regular user UID range (1000-59999)
- Common practice for service accounts (5000-5999)
- No conflicts with standard system users

### Why UID 999 for postgres?
- **Critical:** Matches standard PostgreSQL Docker container UID
- Container runs as UID 999 inside
- Host directories must be owned by UID 999
- Enables Docker volume mounts to work properly
- Standard across all PostgreSQL official images

### Why 700 for PostgreSQL data?
- PostgreSQL **requires** data directory to be 700
- Refuses to start if group/world readable
- Security requirement in PostgreSQL documentation
- Prevents unauthorized access to database files

### Why 750 for other directories?
- Owner: Full access (rwx)
- Group: Read and execute (for backups/monitoring)
- Others: No access (security)
- Balance between security and functionality

### Why /usr/sbin/nologin?
- Security best practice
- Prevents interactive login
- Users are service accounts only
- Processes can still run as these users

## Usage

### Prerequisites Check

```bash
# Verify Task 1.4.1 completed
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25 \
  "sudo ls -ld /var/mail/vmail /opt/postgres/data"
# Should show directories exist with root:root ownership

# Verify environment variables set
echo $ANSIBLE_HOST          # Should be: 10.100.0.25
echo $ANSIBLE_REMOTE_PORT   # Should be: 2288
```

### Installation

```bash
# Navigate to ansible directory
cd /path/to/mail-server-poc/ansible

# Copy files to playbooks directory
cp /path/to/task_1.4.2.yml playbooks/
cp /path/to/configure_directory_permissions.yml playbooks/
```

### Execution

```bash
# Standard execution
./run_task.sh 1.4.2

# With verbose output
./run_task.sh 1.4.2 -v

# Check mode (dry-run)
./run_task.sh 1.4.2 --check
```

### Verification

```bash
# SSH to server
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25

# Verify users
id vmail     # Should show uid=5000
id postgres  # Should show uid=999

# Verify ownership and permissions
sudo ls -ld /var/mail/vmail /var/mail/queue /var/mail/backups
sudo ls -ld /opt/postgres/data /opt/postgres/wal_archive /opt/postgres/backups

# Quick verification script
sudo stat -c "%U:%G %a %n" /var/mail/vmail /var/mail/queue /var/mail/backups \
  /opt/postgres/data /opt/postgres/wal_archive /opt/postgres/backups
```

Expected output:
```
vmail:vmail 750 /var/mail/vmail
vmail:vmail 750 /var/mail/queue
vmail:vmail 750 /var/mail/backups
postgres:postgres 700 /opt/postgres/data
postgres:postgres 750 /opt/postgres/wal_archive
postgres:postgres 750 /opt/postgres/backups
```

## Integration Points

### With Task 2.1.1 (PostgreSQL Container)
The postgres user (UID 999) enables:
- Docker container to access `/opt/postgres/data`
- Container process (UID 999) matches host owner (UID 999)
- Volume mounts work without permission issues

### With Future Mail Services (Task 3.x)
The vmail user enables:
- Postfix to deliver mail to `/var/mail/vmail/`
- Dovecot to read mailboxes from `/var/mail/vmail/`
- Proper isolation from system users

### With Backup Scripts (Future)
The 750 permissions enable:
- Backup processes to read directories (group access)
- Monitoring scripts to check disk usage
- While maintaining security (no world access)

## Expected Outcome

After successful execution:

1. ✅ vmail user created with UID 5000
2. ✅ postgres user created with UID 999
3. ✅ Mail directories owned by vmail:vmail with 750 permissions
4. ✅ PostgreSQL directories owned by postgres:postgres
5. ✅ PostgreSQL data directory has 700 permissions
6. ✅ PostgreSQL WAL/backup directories have 750 permissions
7. ✅ All ownership and permissions verified
8. ✅ System ready for Task 1.4.3 (Disk Quotas)

## Success Criteria

- [x] Task wrapper playbook created (task_1.4.2.yml)
- [x] Reusable playbook created (configure_directory_permissions.yml)
- [x] Documentation created (README_TASK_1.4.2.md)
- [ ] Task executed successfully on server
- [ ] Users created with correct UIDs
- [ ] Ownership set correctly on all directories
- [ ] Permissions configured correctly
- [ ] Ready to proceed to Task 1.4.3

## File Installation Checklist

- [ ] task_1.4.2.yml → ansible/playbooks/
- [ ] configure_directory_permissions.yml → ansible/playbooks/
- [ ] (Optional) README_TASK_1.4.2.md → ansible/

## Notes

- **Idempotency:** Safe to run multiple times - checks for existing users
- **No Secrets:** No sensitive information in playbooks
- **Follows Patterns:** Consistent with Task 1.4.1 structure
- **Well Documented:** Complete rationale and troubleshooting
- **Docker Compatible:** UID 999 matches container standard

## Common Issues and Solutions

### Issue: UID already in use
**Solution:** Check `getent passwd 999` - if another user has UID 999, either remove that user or adjust PostgreSQL container UID (more complex)

### Issue: PostgreSQL container can't write to data directory
**Solution:** Verify `ls -ln /opt/postgres/data` shows UID 999 as owner

### Issue: Permission denied errors
**Solution:** Ensure phalkonadmin has sudo privileges: `sudo -l`

## Next Actions

1. **Review** the playbooks and documentation
2. **Install** files in ansible/playbooks/ directory
3. **Execute** task using ./run_task.sh 1.4.2
4. **Verify** user creation and permissions on server
5. **Proceed** to Task 1.4.3 (Configure Disk Quotas)

## Related Documents

- **tasks.md** - Task 1.4.2 specification
- **planning.md** - Section 5.1 (Filesystem Layout)
- **README_TASK_1.4.1.md** - Previous task documentation
- **PostgreSQL Docker Docs** - UID 999 standard

## Questions to Consider

**Q: Why not use UID 1000 for vmail?**  
A: UID 1000 is typically the first regular user account (already used by phalkonadmin in this case). Service accounts should use higher UIDs to avoid conflicts.

**Q: Can I change postgres UID to something else?**  
A: Not recommended. While possible, it requires building custom PostgreSQL containers. UID 999 is the standard.

**Q: Why can't postgres be 755 like everything else?**  
A: PostgreSQL specifically requires 700 on data directory for security. This is enforced by the database - it won't start with looser permissions.

**Q: What if I need to change ownership later?**  
A: Simply re-run Task 1.4.2 - it's idempotent and will reset ownership/permissions.

---

**Delivered By:** Claude (AI Assistant)  
**Delivery Date:** 2025-01-12  
**Project:** Mail Server Cluster PoC  
**Milestone:** 1.4 - Directory Structure & Storage  
**Status:** Ready for execution ✅
