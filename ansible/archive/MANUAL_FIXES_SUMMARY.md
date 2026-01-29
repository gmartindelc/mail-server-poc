# Manual Server Fixes - Session 2026-01-26/29
## Dovecot 2.4 Mail Delivery Configuration

### Overview
During Task 2.2.5 testing, mail delivery failed due to Dovecot 2.4 configuration issues on Debian 13. The following manual fixes were applied directly on the server that MUST be incorporated into the Ansible playbooks.

---

## Critical Fixes Required

### Fix 1: Remove Conflicting Mail Settings from 10-mail.conf

**File:** `/etc/dovecot/conf.d/10-mail.conf`

**Problem:** Default mail_home and mail_path settings override SQL userdb query results

**Manual Fix Applied:**
```bash
sudo sed -i 's/^mail_driver = mbox/#mail_driver = mbox/' /etc/dovecot/conf.d/10-mail.conf
sudo sed -i 's/^mail_home = /#mail_home = /' /etc/dovecot/conf.d/10-mail.conf
sudo sed -i 's/^mail_inbox_path = /#mail_inbox_path = /' /etc/dovecot/conf.d/10-mail.conf
sudo sed -i 's/^mail_path = /#mail_path = /' /etc/dovecot/conf.d/10-mail.conf
```

**Ansible Equivalent:**
```yaml
- name: Remove conflicting mail settings from 10-mail.conf
  ansible.builtin.lineinfile:
    path: /etc/dovecot/conf.d/10-mail.conf
    regexp: "{{ item }}"
    state: absent
  loop:
    - '^mail_driver\s*=\s*mbox'
    - '^mail_home\s*='
    - '^mail_inbox_path\s*='
    - '^mail_path\s*='
```

---

### Fix 2: Remove auth_username_format from LMTP

**File:** `/etc/dovecot/conf.d/20-lmtp.conf`

**Problem:** `auth_username_format = %{user | username | lower}` strips domain from email addresses, causing "User doesn't exist" errors

**Manual Fix Applied:**
```bash
sudo sed -i 's/^  auth_username_format = /#  auth_username_format = /' /etc/dovecot/conf.d/20-lmtp.conf
```

**Ansible Equivalent:**
```yaml
- name: Remove auth_username_format from LMTP protocol
  ansible.builtin.replace:
    path: /etc/dovecot/conf.d/20-lmtp.conf
    regexp: '^\s+auth_username_format\s*=.*$'
    replace: '#  auth_username_format = %{user | username | lower}  # DISABLED: Strips domain'
```

**Why This Matters:**
- Database stores full email: `testuser1@phalkons.com`
- LMTP was transforming to: `testuser1`
- Database lookup failed: no user named just `testuser1`

---

### Fix 3: Add mail_driver to dovecot.conf

**File:** `/etc/dovecot/dovecot.conf`

**Problem:** Without mail_driver, Dovecot cannot initialize mail storage

**Manual Fix Applied:**
```bash
sudo bash -c 'cat >> /etc/dovecot/dovecot.conf << "EOF"

# Mail storage driver
mail_driver = maildir
EOF
'
```

**Ansible Equivalent:**
```yaml
- name: Add mail_driver setting to dovecot.conf
  ansible.builtin.blockinfile:
    path: /etc/dovecot/dovecot.conf
    marker: "# {mark} ANSIBLE MANAGED - Mail Storage Driver"
    block: |
      mail_driver = maildir
```

---

### Fix 4: Add 'home' Field to userdb SQL Query

**File:** `/etc/dovecot/conf.d/10-auth.conf`

**Problem:** Dovecot 2.4 requires 'home' field in userdb query, even for virtual users

**Error Message:**
```
Failed to initialize user: Namespace inbox: mail_storage settings: 
Failed to parse configuration: Failed to expand mail_path setting variables: 
Setting used home directory (%h) but there is no mail_home and userdb didn't return it
```

**Manual Fix Applied:**
```bash
sudo sed -i "s@query = SELECT 'maildir:/var/mail/vmail/' || maildir AS mail, 5000 AS uid, 5000 AS gid FROM mailbox@query = SELECT 'maildir:/var/mail/vmail/' || maildir AS mail, 5000 AS uid, 5000 AS gid, '/var/mail/vmail/' || maildir AS home FROM mailbox@" /etc/dovecot/conf.d/10-auth.conf
```

**Ansible Equivalent:**
```yaml
- name: Create auth-sql.conf.ext with home field
  ansible.builtin.copy:
    dest: /etc/dovecot/conf.d/auth-sql.conf.ext
    content: |
      passdb sql {
        query = SELECT username AS user, password FROM mailbox WHERE username = '%{user}' AND active = true
      }
      
      userdb sql {
        # MUST include 'home' field for Dovecot 2.4
        query = SELECT 'maildir:{{ mail_vmail_dir }}/' || maildir AS mail, 
                       {{ vmail_uid }} AS uid, 
                       {{ vmail_gid }} AS gid, 
                       '{{ mail_vmail_dir }}/' || maildir AS home 
                FROM mailbox 
                WHERE username = '%{user}' AND active = true
        
        iterate_query = SELECT username AS user FROM mailbox WHERE active = true
      }
```

---

## Maildir Path Structure (Dovecot 2.4)

**Database maildir column contains:**
```
phalkons.com/testuser1/
```

**SQL query constructs:**
```
maildir:/var/mail/vmail/phalkons.com/testuser1/
```

**Dovecot 2.4 creates actual mailbox at:**
```
/var/mail/vmail/phalkons.com/testuser1/Maildir/
├── new/      # New unread messages
├── cur/      # Current/read messages
└── tmp/      # Temporary files
```

**Key Point:** Dovecot automatically adds the `/Maildir/` subdirectory. This is **correct** behavior.

---

## Testing and Verification

### After Applying All Fixes:

```bash
# 1. Test user lookup
sudo doveadm user testuser1@phalkons.com
# Should show:
#   mail = maildir:/var/mail/vmail/phalkons.com/testuser1/
#   home = /var/mail/vmail/phalkons.com/testuser1/

# 2. Test authentication
sudo doveadm auth test testuser1@phalkons.com TestPass123!
# Should show: auth succeeded

# 3. Send test email
echo "Test" | mail -s "Test" testuser1@phalkons.com

# 4. Check delivery (note the /Maildir/new/ path)
sudo ls -la /var/mail/vmail/phalkons.com/testuser1/Maildir/new/
# Should show delivered message files

# 5. Check logs
sudo journalctl -u dovecot --since "1 minute ago" | grep -i lmtp
# Should show: "saved mail to INBOX"
```

---

## Files to Update

### 1. install_dovecot.yml
Add all 4 fixes above to the playbook

### 2. test_mail_system.yml
Update all mailbox path checks from:
```yaml
{{ mail_vmail_dir }}/{{ mail_test_domain }}/testuser1/new
```
To:
```yaml
{{ mail_vmail_dir }}/{{ mail_test_domain }}/testuser1/Maildir/new
```

### 3. Documentation Updates
- Update README_TASK_2.2.2.md with Dovecot 2.4 requirements
- Document the nested Maildir/ structure
- Add troubleshooting section for common Dovecot 2.4 issues

---

## Summary of Changes

| File | Change | Reason |
|------|--------|--------|
| `/etc/dovecot/conf.d/10-mail.conf` | Comment out mail_driver, mail_home, mail_path | Override SQL query results |
| `/etc/dovecot/conf.d/20-lmtp.conf` | Comment out auth_username_format | Strips domain from virtual users |
| `/etc/dovecot/dovecot.conf` | Add mail_driver = maildir | Required for mail storage init |
| `/etc/dovecot/conf.d/10-auth.conf` | Add 'home' to userdb query | Required by Dovecot 2.4 |
| `test_mail_system.yml` | Update paths to include /Maildir/ | Dovecot 2.4 path structure |

---

## Root Cause Analysis

**Why these issues occurred:**

1. **Dovecot 2.4 breaking changes** - Different from Dovecot 2.3 that Ansible playbooks were written for
2. **Debian 13 defaults** - Ships with conflicting default settings
3. **Virtual user configuration** - Dovecot 2.4 handles virtual users differently than system users
4. **Documentation gaps** - Official Dovecot 2.4 docs don't clearly explain these requirements

**Lessons Learned:**

1. Always test on exact target OS version (Debian 13 != Debian 12)
2. Virtual user config needs special attention in Dovecot 2.4
3. SQL query results must match Dovecot 2.4 expectations exactly
4. LMTP protocol settings can override global auth settings

---

## Automation Priority

**HIGH PRIORITY** - These fixes must be in install_dovecot.yml before Task 2.2.2 is considered complete.

Without these fixes:
- ❌ Mail delivery fails
- ❌ LMTP returns "User doesn't exist"
- ❌ Test suite fails at 88% instead of 100%
- ❌ Production deployment would be broken

With these fixes:
- ✅ Mail delivery works perfectly
- ✅ Virtual users authenticate correctly
- ✅ LMTP delivers to correct Maildir
- ✅ Test suite passes at 100%
