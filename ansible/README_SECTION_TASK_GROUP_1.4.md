# Task Group 1.4 - README Section
# Add this section to your main ansible/README.md file

---

## Task Group 1.4: Directory Structure & Storage

**Status:** 🚧 In Progress (2 of 3 tasks complete)  
**Duration:** ~40 minutes total  
**Prerequisites:** Task Group 1.3 (System Hardening) complete

### Overview

Task Group 1.4 creates and configures the directory structure required for the mail server and PostgreSQL database. This includes creating directories, setting up system users, configuring ownership and permissions, and establishing disk quotas.

### Tasks in This Group

#### ✅ Task 1.4.1: Create Mail System Directory Structure
**Status:** Complete  
**Duration:** ~5 minutes  
**Files:** `playbooks/task_1.4.1.yml`, `playbooks/create_mail_directories.yml`

**What it does:**
- Creates mail storage directories: `/var/mail/vmail/`, `/var/mail/queue/`, `/var/mail/backups/`
- Creates PostgreSQL directories: `/opt/postgres/data/`, `/opt/postgres/wal_archive/`, `/opt/postgres/backups/`
- Initial ownership: `root:root`
- Initial permissions: `0755`
- All directories verified to exist

**Directories created:**
```
/var/mail/
├── vmail/          # Virtual mail storage (Maildir format)
├── queue/          # Postfix mail queue
└── backups/        # Mail system backups

/opt/postgres/
├── data/           # PostgreSQL database files (Docker volume)
├── wal_archive/    # Write-Ahead Log archives
└── backups/        # Database dumps and backup scripts
```

**Execution:**
```bash
./run_task.sh 1.4.1
```

**Verification:**
```bash
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25 \
  "sudo ls -la /var/mail/ /opt/postgres/"
```

**Notes:**
- Check mode has limitations (directories not actually created, verification fails)
- Safe to run without check mode - only creates directories
- Idempotent - safe to run multiple times

---

#### ✅ Task 1.4.2: Set Proper Permissions and Ownership
**Status:** Complete  
**Duration:** ~10 minutes  
**Files:** `playbooks/task_1.4.2.yml`, `playbooks/configure_directory_permissions.yml`

**What it does:**
- Creates `vmail` system user (UID 5000) for mail storage
- Creates `postgres` system user (UID 999) for PostgreSQL container compatibility
- Sets ownership on mail directories: `vmail:vmail`
- Sets ownership on PostgreSQL directories: `postgres:postgres`
- Configures permissions:
  - Mail directories: `750` (rwxr-x---)
  - PostgreSQL data: `700` (rwx------) - PostgreSQL security requirement
  - PostgreSQL WAL/backups: `750` (rwxr-x---)

**System users created:**
```
vmail:
  UID: 5000
  GID: 5000
  Shell: /usr/sbin/nologin (no login capability)
  Home: /var/mail/vmail
  Purpose: Virtual mail storage owner

postgres:
  UID: 999 (matches PostgreSQL Docker container standard)
  GID: 999
  Shell: /usr/sbin/nologin (no login capability)
  Home: /opt/postgres
  Purpose: PostgreSQL container file access
```

**Final directory state:**
```
/var/mail/vmail/      → vmail:vmail, 0750
/var/mail/queue/      → vmail:vmail, 0750
/var/mail/backups/    → vmail:vmail, 0750
/opt/postgres/data/   → postgres:postgres, 0700 (strict - required by PostgreSQL)
/opt/postgres/wal_archive/ → postgres:postgres, 0750
/opt/postgres/backups/     → postgres:postgres, 0750
```

**Execution:**
```bash
# Check mode works perfectly for this task!
./run_task.sh 1.4.2 --check  # Preview changes

# Apply changes
./run_task.sh 1.4.2
```

**Verification:**
```bash
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25 << 'EOF'
  # Verify users
  id vmail      # Should show uid=5000
  id postgres   # Should show uid=999
  
  # Verify ownership and permissions
  sudo stat -c "%U:%G %a %n" /var/mail/vmail /var/mail/queue /var/mail/backups
  sudo stat -c "%U:%G %a %n" /opt/postgres/data /opt/postgres/wal_archive /opt/postgres/backups
EOF
```

**Expected output:**
```
vmail:vmail 750 /var/mail/vmail
vmail:vmail 750 /var/mail/queue
vmail:vmail 750 /var/mail/backups
postgres:postgres 700 /opt/postgres/data
postgres:postgres 750 /opt/postgres/wal_archive
postgres:postgres 750 /opt/postgres/backups
```

**Notes:**
- ✅ **Check mode fully supported** - unlike Task 1.4.1
- UID 999 for postgres is **critical** - matches PostgreSQL container standard
- 700 permissions on data directory **required** by PostgreSQL
- Idempotent - safe to run multiple times

**Why these UIDs?**
- **UID 5000 (vmail):** Avoids conflicts with system UIDs (< 1000) and regular user UIDs (1000-59999)
- **UID 999 (postgres):** Standard UID used by PostgreSQL Docker containers - must match for volume mounts to work

**Docker volume mount compatibility:**
When PostgreSQL container starts, it mounts `/opt/postgres/data` as `/var/lib/postgresql/data`. The container process runs as UID 999, which matches our host postgres user (UID 999), enabling proper file access.

---

#### ⏳ Task 1.4.3: Configure Disk Quotas
**Status:** Pending  
**Duration:** ~25 minutes (estimated)  
**Dependencies:** Task 1.4.2

**What it will do:**
- Enable filesystem quotas on `/var/mail/vmail/`
- Configure per-user quota limits
- Set up quota enforcement
- Prevent mailbox storage abuse

---

### Task Group 1.4 - Quick Execution

To run all Task 1.4 tasks sequentially (once Task 1.4.3 is created):

```bash
# Optional: Run all Task Group 1.4 tasks
./run_all_tasks_1.4.sh
```

This script will:
- Check environment variables are set
- Verify VPN connectivity
- Run tasks 1.4.1, 1.4.2, and 1.4.3 in sequence
- Show progress and status for each task
- Provide comprehensive summary at end

### Environment Variables (Required)

After Task Group 1.3, all access is VPN-only:

```bash
export ANSIBLE_HOST=10.100.0.25
export ANSIBLE_REMOTE_PORT=2288
export ANSIBLE_REMOTE_USER=phalkonadmin
export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
```

### Integration Points

**Task Group 1.4 prepares infrastructure for:**

1. **Task 2.1.1 (PostgreSQL Container):**
   - `/opt/postgres/data/` ready for database volume mount
   - postgres user (UID 999) matches container UID
   - Permissions configured correctly (700 for data directory)

2. **Task 3.x (Mail Services):**
   - `/var/mail/vmail/` ready for Maildir storage
   - `/var/mail/queue/` ready for Postfix queue
   - vmail user (UID 5000) ready for Postfix/Dovecot

3. **Backup Scripts (Future):**
   - `/var/mail/backups/` for mail backups
   - `/opt/postgres/backups/` for database dumps
   - Proper permissions for backup processes

### Security Considerations

1. **No Login Shells:**
   - Both vmail and postgres use `/usr/sbin/nologin`
   - Cannot SSH or login interactively
   - Only processes/services can use these accounts

2. **Minimal Permissions:**
   - PostgreSQL data: 700 (owner only)
   - Other directories: 750 (owner + group, no world access)
   - Follows principle of least privilege

3. **UID Isolation:**
   - Service accounts (5000-5999 range)
   - Separated from system accounts (< 1000)
   - Separated from user accounts (1000-59999)

### Troubleshooting

#### Issue: Task 1.4.1 fails in check mode
**Solution:** This is expected behavior. Run without `--check`:
```bash
./run_task.sh 1.4.1  # Safe - only creates directories
```

#### Issue: Task 1.4.2 - "User already exists"
**Solution:** Task checks for existing users. If UID mismatch:
```bash
sudo userdel vmail    # Remove old user
./run_task.sh 1.4.2   # Recreate with correct UID
```

#### Issue: PostgreSQL container can't access data directory
**Solution:** Verify postgres user has UID 999:
```bash
id postgres  # Should show uid=999
sudo ls -ln /opt/postgres/data  # Should show UID 999 as owner
```

#### Issue: Permission denied when setting ownership
**Solution:** Ensure sudo privileges:
```bash
sudo -l  # Verify phalkonadmin can sudo
```

### Task Group 1.4 Summary

After completing all tasks in this group:

```
✅ Directory structure created and ready
✅ System users created (vmail, postgres)
✅ Ownership configured correctly
✅ Permissions set appropriately
✅ Disk quotas configured (pending Task 1.4.3)
✅ Ready for Milestone 2 (Database Layer)
```

**Total Time:** ~40 minutes  
**Files Created:** 6 playbooks, documentation  
**System State:** Directory infrastructure ready for mail services and PostgreSQL

---

### Next Milestone

**Milestone 2: Database Layer Implementation (Task Group 2.1)**
- Task 2.1.1: Create PostgreSQL Docker Compose configuration
- Task 2.1.2: Configure PostgreSQL for mail server authentication
- Task 2.1.3: Configure PostgreSQL backups and WAL archiving
- Task 2.1.4: Verify PostgreSQL container and connectivity

---
