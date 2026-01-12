# Task 1.4.3 - Prepare Disk Quota System

## Overview

This task prepares the disk quota system for the mail server using a **documentation-based approach** suitable for the PoC phase. Quota tools are installed and enablement scripts are created, but quotas are NOT activated yet to avoid filesystem modifications during testing.

## Approach: Documentation-Based (PoC Phase)

### Why This Approach?

**PoC Phase Considerations:**
- Single-user testing environment
- No immediate risk of storage abuse
- Filesystem modification not needed yet
- Can be enabled quickly when transitioning to production

**What This Task Does:**
- ✅ Installs quota management tools
- ✅ Creates enablement scripts
- ✅ Documents the process thoroughly
- ✅ Checks current filesystem status
- ❌ Does NOT modify `/etc/fstab`
- ❌ Does NOT enable quotas yet

### When to Enable Quotas

Enable quotas when:
- Moving from PoC to production
- Adding multiple users to the system
- Storage management becomes critical
- Per-user accountability required

## What This Task Creates

### 1. Installed Tools

- **quota** - Quota management utilities
- **quotatool** - Quota manipulation tool

### 2. Scripts Created (`/opt/mail_server/scripts/quota/`)

**enable_quotas.sh** - One-time quota enablement
```bash
# Automated script that:
# - Backups /etc/fstab
# - Adds usrquota mount option
# - Remounts filesystem
# - Initializes quota database
# - Enables quotas
# - Sets default limits
```

**check_quotas.sh** - Check quota status
```bash
# Usage:
sudo /opt/mail_server/scripts/quota/check_quotas.sh        # All quotas
sudo /opt/mail_server/scripts/quota/check_quotas.sh vmail  # Specific user
```

**set_quota.sh** - Set user quotas
```bash
# Usage: set_quota.sh <username> <soft_mb> <hard_mb>
sudo /opt/mail_server/scripts/quota/set_quota.sh vmail 900 1024
```

### 3. Documentation

**README.md** - Complete quota documentation
- Current system status
- Enablement procedures
- Management commands
- Troubleshooting guide

## Prerequisites

- **Completed Tasks:** Task 1.4.2 (Users and permissions configured)
- **Access:** VPN connection established, SSH access as phalkonadmin
- **Environment Variables Set:**
  ```bash
  export ANSIBLE_HOST=10.100.0.25
  export ANSIBLE_REMOTE_PORT=2288
  export ANSIBLE_REMOTE_USER=phalkonadmin
  export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
  ```

## Files Included

1. **task_1.4.3.yml** - Task wrapper playbook
2. **prepare_disk_quotas.yml** - Reusable quota preparation playbook

## Usage

### Standard Execution

```bash
./run_task.sh 1.4.3
```

### Check Mode

```bash
./run_task.sh 1.4.3 --check
```

Check mode works well for this task as it only installs packages and creates files.

## Expected Output

```yaml
PLAY [Task 1.4.3 - Prepare Disk Quota System] *****************************

TASK [Install quota management tools] *************************************
changed: [mail_server]

TASK [Create quota scripts directory] *************************************
changed: [mail_server]

TASK [Check current filesystem for /var/mail] *****************************
ok: [mail_server]

TASK [Check if quotas are already enabled] ********************************
ok: [mail_server]

TASK [Create quota enablement script] *************************************
changed: [mail_server]

TASK [Create quota monitoring script] *************************************
changed: [mail_server]

TASK [Create quota management script] *************************************
changed: [mail_server]

TASK [Create quota documentation] *****************************************
changed: [mail_server]

TASK [Display task completion summary] ************************************
ok: [mail_server] => {
    "msg": [
        "==========================================",
        "Task 1.4.3 - Quota System Prepared",
        "==========================================",
        "",
        "Status: ✅ Tools installed and scripts created",
        ...
    ]
}

PLAY RECAP ****************************************************************
mail_server                : ok=10   changed=7    unreachable=0    failed=0
```

## Post-Execution Verification

### Verify Installation

```bash
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25

# Check quota tools installed
which quota quotacheck quotaon
# Should show: /usr/sbin/quota, /usr/sbin/quotacheck, /usr/sbin/quotaon

# Check scripts created
ls -la /opt/mail_server/scripts/quota/
# Should show: enable_quotas.sh, check_quotas.sh, set_quota.sh, README.md

# Read the documentation
sudo cat /opt/mail_server/scripts/quota/README.md

# Check current quota status (not enabled yet)
sudo /opt/mail_server/scripts/quota/check_quotas.sh
# Should show: "❌ Quotas are NOT enabled on /var/mail"
```

## Enabling Quotas (When Ready)

### Option 1: Automated Script (Recommended)

When you're ready to enable quotas in production:

```bash
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25

# Run the enablement script
sudo /opt/mail_server/scripts/quota/enable_quotas.sh

# The script will:
# 1. Backup /etc/fstab
# 2. Add usrquota mount option
# 3. Remount filesystem
# 4. Initialize quota database
# 5. Enable quotas
# 6. Set default limits for vmail user (900MB soft, 1GB hard)

# Verify quotas are enabled
sudo /opt/mail_server/scripts/quota/check_quotas.sh
```

### Option 2: Manual Process

If you prefer manual control:

```bash
# 1. Backup fstab
sudo cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d)

# 2. Edit /etc/fstab (add usrquota to mount options)
sudo nano /etc/fstab
# Find line with /var/mail mount point
# Add usrquota to options (e.g., defaults,usrquota)

# 3. Remount filesystem
sudo mount -o remount /

# 4. Initialize quota database
sudo quotacheck -cum /var/mail

# 5. Enable quotas
sudo quotaon /var/mail

# 6. Set default quota for vmail
sudo /opt/mail_server/scripts/quota/set_quota.sh vmail 900 1024
```

## Managing Quotas (After Enablement)

### Check Quota Status

```bash
# Check if quotas are enabled
sudo quotaon -p /var/mail

# View all quotas
sudo repquota -u /var/mail

# View specific user
sudo quota -u vmail
```

### Set User Quotas

```bash
# Set quota for a user (soft: 900MB, hard: 1GB)
sudo /opt/mail_server/scripts/quota/set_quota.sh username 900 1024

# Set quota for vmail user
sudo /opt/mail_server/scripts/quota/set_quota.sh vmail 900 1024
```

### Monitor Usage

```bash
# Generate quota report
sudo repquota -u /var/mail

# Find users over quota
sudo repquota -u /var/mail | grep +

# Check specific user
sudo /opt/mail_server/scripts/quota/check_quotas.sh vmail
```

## Typical Quota Configuration

For a mail server with 80GB storage and ~100 users:

```
Per user limits:
- Soft limit: 900 MB (warning threshold)
- Hard limit: 1024 MB (1 GB absolute maximum)
- Grace period: 7 days to reduce usage below soft limit

Capacity planning:
- Total theoretical: 100 users × 1GB = 100 GB
- Available storage: 80 GB
- Expected overhead: ~20%
- Safe capacity: ~80 users at full quota
```

## State Transition

### Before Task 1.4.3
```
Quota Tools: ❌ Not installed
Scripts: ❌ Don't exist
Documentation: ❌ Not available
Quotas: ❌ Not enabled
```

### After Task 1.4.3
```
Quota Tools: ✅ Installed (quota, quotatool)
Scripts: ✅ Created in /opt/mail_server/scripts/quota/
  - enable_quotas.sh
  - check_quotas.sh
  - set_quota.sh
Documentation: ✅ README.md created
Quotas: ⏸️ Ready to enable (not active yet - PoC phase)
```

### After Running enable_quotas.sh (Future)
```
/etc/fstab: ✅ Modified with usrquota option
Filesystem: ✅ Remounted with quota support
Quota DB: ✅ Initialized
Quotas: ✅ Enabled and enforced
Default Limits: ✅ Set for vmail user
```

## Integration Points

### With Dovecot (Task 3.x)
Once quotas are enabled, Dovecot will:
- Enforce quota limits automatically
- Reject mail when user over quota
- Report quota usage in IMAP

### With Postfix (Task 3.x)
Once quotas are enabled, Postfix will:
- Check quota before delivery
- Bounce mail if user over quota
- Log quota-related rejections

### With Monitoring (Future)
Scripts can be integrated with:
- Nagios/Zabbix for quota monitoring
- Wazuh for quota violation alerts
- Cron for daily quota reports

## Troubleshooting

### Issue: quota command not found

**Solution:**
```bash
# Reinstall quota tools
sudo apt-get update
sudo apt-get install quota quotatool
```

### Issue: Scripts not executable

**Solution:**
```bash
sudo chmod +x /opt/mail_server/scripts/quota/*.sh
```

### Issue: Quotas not working after enabling

**Solution:**
```bash
# Rebuild quota database
sudo quotaoff /var/mail
sudo quotacheck -cum /var/mail
sudo quotaon /var/mail
```

### Issue: Wrong filesystem type

**Solution:**
```bash
# Check filesystem type
df -T /var/mail

# ext4: Use usrquota mount option (this approach)
# xfs: Use different quota system (requires different commands)
```

## Why Not Enable Now?

**PoC Phase Reasons:**
1. **Single User:** Only testing with one or two users
2. **No Risk:** No storage abuse expected during testing
3. **Flexibility:** Easier to test without quota constraints
4. **Simplicity:** One less thing to debug during PoC
5. **Reversible:** Can enable anytime with one script

**Production Reasons to Enable:**
1. **Multiple Users:** Many users sharing storage
2. **Accountability:** Need per-user limits
3. **Stability:** Prevent one user from affecting others
4. **Management:** Track and control storage usage

## Security Considerations

- Scripts require root privileges (properly secured)
- Quota database files protected (only root can modify)
- Scripts include input validation
- Backup of fstab created before modification

## Next Steps

After completing Task 1.4.3:

1. **Verify scripts are accessible:**
   ```bash
   ls -la /opt/mail_server/scripts/quota/
   ```

2. **Read the documentation:**
   ```bash
   sudo cat /opt/mail_server/scripts/quota/README.md
   ```

3. **Update tasks.md** - Mark Task 1.4.3 complete ✅

4. **Proceed to Milestone 2: Database Layer Implementation**
   - Task 2.1.1: Create PostgreSQL Docker Compose configuration
   - Task 2.1.2: Configure PostgreSQL for mail server authentication
   - Task 2.1.3: Configure PostgreSQL backups and WAL archiving
   - Task 2.1.4: Verify PostgreSQL container and connectivity

## References

- **Planning Document:** Section 5.1 (Filesystem Layout)
- **Tasks Document:** Task 1.4.3 specification
- **Previous Tasks:** Task 1.4.1 (Directories), Task 1.4.2 (Permissions)
- **Linux Quota Documentation:** `man quota`, `man quotactl`, `man quotacheck`

---

**Task Status:** ✅ Ready for Execution  
**Approach:** Documentation-based (PoC phase)  
**Risk Level:** Low (only installs tools and creates scripts)  
**Reversible:** Yes (no system modifications)  
**Check Mode:** Fully supported
