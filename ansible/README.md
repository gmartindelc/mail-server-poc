# Ansible Automation for Mail Server PoC

## Overview

Ansible playbooks for automating the setup and configuration of the Mail Server Proof of Concept. This repository contains reusable playbooks and task-specific wrappers for systematic server deployment.

## Directory Structure

```
ansible/
├── ansible.cfg                    # Ansible configuration
├── inventory.yml                  # Dynamic inventory using credentials file
├── run_task.sh                    # Run task-specific playbooks
├── run_reusable.sh                # Run reusable playbooks directly
├── run_all_tasks.sh               # Run all tasks in sequence
├── README.md                      # This file
└── playbooks/                     # All playbooks
    ├── task_1.2.1.yml            # Task 1.2.1: Configure passwordless sudo
    ├── task_1.2.2.yml            # Task 1.2.2: Remove linuxuser
    ├── task_1.2.3.yml            # Task 1.2.3: Create phalkonadmin user
    ├── modify_sudoers_nopasswd.yml    # Reusable: Configure sudo without password
    ├── remove_user.yml                # Reusable: Remove system users
    ├── create_admin_user.yml          # Reusable: Create admin users
    ├── setup_ssh_key_auth.yml         # Reusable: Configure SSH key authentication
    └── test_ssh_connection.yml        # Reusable: Test SSH connections
```

## Prerequisites

- Ansible installed on control node
- SSH access to target server
- Credentials file: `../cucho1.phalkons.com.secret` (format: `ip,password`)

## Quick Start

### 1. Run Individual Tasks

```bash
# Run specific task (e.g., Task 1.2.1)
./run_task.sh 1.2.1

# Run with verbose output
./run_task.sh 1.2.1 -v

# Run with specific tags
./run_task.sh 1.2.1 --tags "sudoers"
```

### 2. Run All Tasks in Sequence

```bash
./run_all_tasks.sh
```

### 3. Use Reusable Playbooks Directly

```bash
# Create an admin user with custom parameters
./run_reusable.sh create_admin_user.yml \
  -e "admin_username=myadmin admin_fullname='My Admin'"

# Remove a specific user
./run_reusable.sh remove_user.yml \
  -e "user_name=olduser"
```

## Available Tasks

### Current Task Sequence

1. **Task 1.2.1** - Configure passwordless sudo for sudo group
2. **Task 1.2.2** - Remove default linuxuser
3. **Task 1.2.3** - Create phalkonadmin user with sudo privileges

### Reusable Playbooks

- `modify_sudoers_nopasswd.yml` - Enable passwordless sudo for sudo group
- `remove_user.yml` - Remove users completely (home directory included)
- `create_admin_user.yml` - Create admin users with customizable parameters
- `setup_ssh_key_auth.yml` - Configure SSH key authentication
- `test_ssh_connection.yml` - Test SSH key-based connections

## Configuration

### Inventory

The inventory dynamically reads server credentials from:

- File: `../cucho1.phalkons.com.secret`
- Format: `ip_address,root_password`

### Custom Variables

Each reusable playbook accepts variables for customization:

```bash
# Example: Create admin user with custom settings
./run_reusable.sh create_admin_user.yml \
  -e "admin_username=customuser \
      admin_fullname='Custom Admin' \
      admin_groups=['sudo','docker'] \
      credential_output_file='./my_creds.secret'"
```

## Security Notes

- Credentials are stored in a file with restricted permissions (600)
- Passwordless sudo is configured for initial setup only
- SSH password authentication is disabled after key setup
- All playbooks are idempotent (safe to run multiple times)

## Troubleshooting

### Common Issues

1. **Connection Failed**

   ```bash
   # Test SSH connectivity manually
   ssh root@$(cut -d',' -f1 ../cucho1.phalkons.com.secret)
   ```

2. **Playbook Not Found**

   ```bash
   # List available playbooks
   ls playbooks/*.yml
   ```

3. **Permission Denied**
   ```bash
   # Ensure credential file has correct permissions
   chmod 600 ../cucho1.phalkons.com.secret
   ```

### Debug Mode

```bash
# Enable verbose output
./run_task.sh 1.2.1 -vvv

# Check Ansible facts
ansible -i inventory.yml mail_server -m setup
```

## Development

### Adding New Tasks

1. Create reusable playbook in `playbooks/` (e.g., `install_docker.yml`)
2. Create task wrapper in `playbooks/task_X.X.X.yml`
3. Update `run_all_tasks.sh` with new task number
4. Test with `./run_task.sh X.X.X`

### Best Practices

- Keep reusable playbooks generic and parameterized
- Use meaningful variable names with defaults
- Include tags for selective execution
- Add validation tasks where applicable
- Document required variables in playbook headers

## Related Documentation

- [Project Planning](../planning.md)
- [Task Tracking](../tasks.md)
- [Session Logs](../session_logs/)

## Support

For issues or questions, refer to:

1. Check existing session logs
2. Review playbook documentation
3. Test with `--check` flag first
4. Use `-v` flag for detailed output

---

_Last Updated: $(date +%Y-%m-%d)_  
_Project: Mail Server Cluster PoC_
