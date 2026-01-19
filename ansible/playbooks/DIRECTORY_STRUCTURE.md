# Directory Structure - Mail Server Playbooks

## Current Structure

```
improved_playbooks/
├── ansible.cfg                          # Ansible configuration
├── inventory.yml                        # Server inventory
├── group_vars/
│   └── all.yml                         # Variables (cucho1.phalkons.com)
│
├── playbooks/
│   # Task Wrappers (call other playbooks)
│   ├── task_1_5_1.yml                  # Configure UFW firewall
│   ├── task_2_2_1.yml                  # Install Postfix
│   ├── task_2_2_2.yml                  # Install Dovecot
│   ├── task_2_2_3.yml                  # Install OpenDKIM
│   ├── task_2_2_4.yml                  # Test mail system
│   │
│   # Implementation Playbooks (actual work)
│   ├── configure_ufw_firewall.yml      # UFW firewall logic
│   ├── install_postfix.yml             # Postfix installation logic
│   ├── install_dovecot.yml             # Dovecot installation logic
│   ├── install_opendkim.yml            # OpenDKIM installation logic
│   ├── test_mail_system.yml            # Testing logic
│   │
│   # Rollback Playbooks
│   ├── rollback_postfix.yml            # Restore Postfix config
│   ├── rollback_dovecot.yml            # Restore Dovecot config
│   ├── rollback_opendkim.yml           # Restore OpenDKIM config
│   │
│   # Documentation
│   └── README_UFW.md                   # UFW firewall guide
│
├── README.md                            # Main documentation
├── QUICKSTART.md                        # Quick start guide
└── IMPROVEMENTS_SUMMARY.md              # Changelog

Total: 13 playbooks + 4 docs
```

## Playbook Categories

### Task Wrappers (run with ./run_task.sh)
These are thin wrappers that include the implementation playbooks:

- `task_1_5_1.yml` → includes `configure_ufw_firewall.yml`
- `task_2_2_1.yml` → includes `install_postfix.yml`
- `task_2_2_2.yml` → includes `install_dovecot.yml`
- `task_2_2_3.yml` → includes `install_opendkim.yml`
- `task_2_2_4.yml` → includes `test_mail_system.yml`

### Implementation Playbooks (can be included or run directly)
These do the actual work and can be reused:

- `configure_ufw_firewall.yml` - Firewall configuration
- `install_postfix.yml` - Postfix MTA setup
- `install_dovecot.yml` - Dovecot IMAP setup
- `install_opendkim.yml` - DKIM email signing
- `test_mail_system.yml` - Comprehensive testing

### Rollback Playbooks (disaster recovery)
These restore configurations from backups:

- `rollback_postfix.yml` - Restore Postfix
- `rollback_dovecot.yml` - Restore Dovecot
- `rollback_opendkim.yml` - Restore OpenDKIM

## Usage Patterns

### Pattern 1: Using Task Wrappers (Recommended)
```bash
# Runs task wrapper which includes implementation playbook
./run_task.sh 1.5.1  # Configure firewall
./run_task.sh 2.2.1  # Install Postfix
./run_task.sh 2.2.2  # Install Dovecot
```

### Pattern 2: Direct Playbook Execution
```bash
# Run implementation playbook directly
ansible-playbook playbooks/install_postfix.yml
ansible-playbook playbooks/test_mail_system.yml
```

### Pattern 3: Including in Other Playbooks
```yaml
# From another playbook, include these:
- name: Setup mail server
  hosts: mail_servers
  tasks:
    - include_tasks: install_postfix.yml
    - include_tasks: install_dovecot.yml
    - include_tasks: install_opendkim.yml
```

### Pattern 4: Rollback Operations
```bash
# If something goes wrong, restore configs
ansible-playbook playbooks/rollback_postfix.yml
ansible-playbook playbooks/rollback_dovecot.yml
```

## File Relationships

```
task_1_5_1.yml
    └─> includes: configure_ufw_firewall.yml
            └─> configures: UFW rules, rate limiting, VPN isolation

task_2_2_1.yml
    └─> includes: install_postfix.yml
            ├─> reads: group_vars/all.yml (postgres credentials)
            ├─> creates: /etc/postfix/*.cf
            └─> connects to: PostgreSQL (virtual_domains, virtual_users)

task_2_2_2.yml
    └─> includes: install_dovecot.yml
            ├─> reads: group_vars/all.yml (postgres credentials)
            ├─> creates: /etc/dovecot/conf.d/*.conf
            └─> connects to: PostgreSQL (virtual_users for auth)

task_2_2_3.yml
    └─> includes: install_opendkim.yml
            ├─> creates: /etc/opendkim/*.conf
            ├─> generates: DKIM keys
            └─> documents: DNS records → /root/dns_records.txt

task_2_2_4.yml
    └─> includes: test_mail_system.yml
            ├─> tests: Postfix, Dovecot, OpenDKIM
            ├─> sends: Test email
            ├─> calculates: Health score
            └─> generates: /root/mail_system_test_report.txt
```

## Configuration Flow

```
1. Variables: group_vars/all.yml
   ↓
2. Inventory: inventory.yml (defines mail_servers)
   ↓
3. Task Wrapper: task_*.yml (orchestrates)
   ↓
4. Implementation: install_*.yml or configure_*.yml (does work)
   ↓
5. Output: Configuration files, logs, reports
```

## Benefits of This Structure

✅ **No nested directories** - All playbooks in `playbooks/`
✅ **Clear naming** - `task_*` vs `install_*` vs `rollback_*`
✅ **Reusable** - Implementation playbooks can be included anywhere
✅ **Maintainable** - Easy to find and edit playbooks
✅ **Standard** - Follows Ansible best practices

## Quick Reference

| Task | Wrapper | Implementation | Purpose |
|------|---------|----------------|---------|
| 1.5.1 | task_1_5_1.yml | configure_ufw_firewall.yml | Firewall |
| 2.2.1 | task_2_2_1.yml | install_postfix.yml | SMTP |
| 2.2.2 | task_2_2_2.yml | install_dovecot.yml | IMAP |
| 2.2.3 | task_2_2_3.yml | install_opendkim.yml | DKIM |
| 2.2.4 | task_2_2_4.yml | test_mail_system.yml | Testing |

---

**Note:** All playbooks reference `group_vars/all.yml` for variables
**Note:** All playbooks target hosts defined in `inventory.yml`
