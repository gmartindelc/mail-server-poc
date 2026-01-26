# Mail Server Variables Reference

## Overview

All playbooks use variables from `group_vars/all.yml` to avoid hardcoding values. This ensures:
- ✅ Easy adaptation to different environments
- ✅ Single source of truth for configuration
- ✅ No hardcoded IPs or domains in playbooks
- ✅ Reusable across multiple deployments

---

## Variable Categories

### 1. Server Network Configuration

```yaml
mail_server_public_ip: "45.32.207.84"      # Public IP address
mail_server_vpn_ip: "10.100.0.25"          # VPN IP (WireGuard)
mail_server_vpn_network: "10.100.0.0/24"   # VPN subnet
```

**Usage in playbooks:**
- DNS verification checks
- Firewall rules
- PostgreSQL connection (uses VPN IP)

### 2. Server Identity

```yaml
mail_server_hostname: "cucho1.phalkons.com"  # Primary hostname
mail_server_domain: "phalkons.com"            # Domain name
mail_server_alias: "mail.phalkons.com"        # Mail server alias
```

**Usage in playbooks:**
- SSL certificate generation (CN and SAN)
- Postfix myhostname
- DNS record verification
- DKIM key generation

### 3. Database Configuration

```yaml
postgres_host: "{{ mail_server_vpn_ip }}"  # Uses VPN IP
postgres_port: 5432
postgres_db: "mailserver"
postgres_container_name: "mailserver-postgres"

# Service users
postgres_postfix_user: "postfix_user"
postgres_dovecot_user: "dovecot_user"
postgres_sogo_user: "sogo_user"
```

**Usage in playbooks:**
- Database connections
- Credential retrieval
- Service user creation
- Connection string generation

### 4. SSL/TLS Configuration

```yaml
ssl_cert_path: "/etc/ssl/certs/ssl-cert-snakeoil.pem"  # Current cert
ssl_key_path: "/etc/ssl/private/ssl-cert-snakeoil.key"  # Current key
letsencrypt_enabled: false                               # Updated by Task 2.2.4
letsencrypt_email: "postmaster@{{ mail_server_domain }}"  # LE contact email
```

**Updated by Task 2.2.4:**
```yaml
ssl_cert_path: "/etc/letsencrypt/live/{{ postfix_myhostname }}/fullchain.pem"
ssl_key_path: "/etc/letsencrypt/live/{{ postfix_myhostname }}/privkey.pem"
letsencrypt_enabled: true
```

### 5. Directory Paths

```yaml
mail_vmail_dir: "/var/mail/vmail"
mail_queue_dir: "/var/mail/queue"
mail_backup_dir: "/var/mail/backups"
postgres_data_dir: "/opt/postgres/data"
mail_server_config_dir: "/opt/mail_server"
```

**Usage in playbooks:**
- Directory creation
- Permission setting
- Service configuration

### 6. Service Configuration

```yaml
# Postfix
postfix_myhostname: "{{ mail_server_hostname }}"
postfix_mydomain: "{{ mail_server_domain }}"

# Dovecot
dovecot_protocols: "imap lmtp"
dovecot_mail_location: "maildir:{{ mail_vmail_dir }}/%d/%n"

# OpenDKIM
opendkim_socket: "inet:8891@localhost"
dkim_selector: "mail"
```

### 7. Test User Configuration

```yaml
mail_test_username: "testuser1"
mail_test_password: "TestPass123!"
mail_test_email: "{{ mail_test_username }}@{{ mail_server_domain }}"
```

---

## How Variables Are Used in Playbooks

### Example 1: DNS Verification

**Before (hardcoded):**
```yaml
- command: dig +short cucho1.phalkons.com
```

**After (variable):**
```yaml
- command: dig +short {{ postfix_myhostname }}
```

### Example 2: Certificate Generation

**Before (hardcoded):**
```yaml
certbot certonly -d cucho1.phalkons.com -d mail.phalkons.com
```

**After (variable):**
```yaml
certbot certonly 
  -d {{ postfix_myhostname }} 
  -d {{ mail_server_alias | default('mail.' + postfix_mydomain) }}
```

### Example 3: Database Connection

**Before (hardcoded):**
```yaml
hosts: 10.100.0.25
```

**After (variable):**
```yaml
hosts: {{ postgres_host }}
```

---

## Adapting to a New Environment

To deploy to a different server, simply update `group_vars/all.yml`:

```yaml
# Example: New server "cucho2"
mail_server_public_ip: "203.0.113.42"        # New IP
mail_server_vpn_ip: "10.100.0.26"            # New VPN IP
mail_server_hostname: "cucho2.phalkons.com"  # New hostname
mail_server_domain: "phalkons.com"            # Same or different domain
mail_server_alias: "mail2.phalkons.com"      # New alias
```

All playbooks will automatically use the new values.

---

## Variable Precedence

Ansible uses this precedence (highest to lowest):

1. **Extra vars** (`-e` on command line)
2. **Task vars**
3. **Block vars**
4. **Role and include vars**
5. **Set_facts / registered vars**
6. **Group vars** (our `all.yml`) ← We use this
7. **Host vars**
8. **Defaults**

Our variables in `group_vars/all.yml` can be overridden by:
```bash
ansible-playbook playbooks/task_2.2.4.yml -e "mail_server_hostname=test.example.com"
```

---

## Variable Files Structure

```
ansible/
├── group_vars/
│   └── all.yml                    # All environment variables
├── host_vars/
│   └── mail_server.yml            # Server-specific overrides (optional)
└── playbooks/
    └── [playbooks use variables]
```

---

## Best Practices

### ✅ DO

- Use variables for all environment-specific values
- Use descriptive variable names
- Document variables with comments
- Use variable composition (e.g., `{{ var1 }}/{{ var2 }}`)
- Use defaults with filters (e.g., `{{ var | default('value') }}`)

### ❌ DON'T

- Hardcode IP addresses in playbooks
- Hardcode domain names in playbooks
- Hardcode paths that might change
- Use variables for constant values (e.g., port 80 is always 80)

---

## Variable Naming Convention

```yaml
# Pattern: <service>_<attribute>_<detail>
mail_server_public_ip        # mail_server = service, public = attribute, ip = detail
postgres_host               # postgres = service, host = attribute
postfix_myhostname          # postfix = service, myhostname = attribute
ssl_cert_path               # ssl = service, cert = type, path = attribute
```

---

## Testing Variable Substitution

Test that variables are correctly substituted:

```bash
# View final configuration after variable substitution
ansible-playbook playbooks/task_2.2.4.yml --check -vv | grep -A5 "certbot certonly"

# View all variables for a host
ansible -m debug -a "var=hostvars[inventory_hostname]" mail_server
```

---

## Environment-Specific Variable Files

For multiple environments (dev, staging, prod):

```
ansible/
├── group_vars/
│   ├── all.yml              # Common to all environments
│   ├── development.yml      # Dev overrides
│   ├── staging.yml          # Staging overrides
│   └── production.yml       # Production overrides
└── inventory/
    ├── development          # Dev inventory
    ├── staging              # Staging inventory
    └── production           # Production inventory
```

Usage:
```bash
# Deploy to production
ansible-playbook -i inventory/production playbooks/task_2.2.4.yml

# Deploy to staging
ansible-playbook -i inventory/staging playbooks/task_2.2.4.yml
```

---

## Validating Variables

Create a validation playbook:

```yaml
# playbooks/validate_variables.yml
- hosts: mail_server
  gather_facts: no
  tasks:
    - name: Display all mail server variables
      debug:
        msg:
          - "Public IP: {{ mail_server_public_ip }}"
          - "VPN IP: {{ mail_server_vpn_ip }}"
          - "Hostname: {{ mail_server_hostname }}"
          - "Domain: {{ mail_server_domain }}"
          - "Alias: {{ mail_server_alias }}"
          - "PostgreSQL Host: {{ postgres_host }}"
          - "SSL Cert: {{ ssl_cert_path }}"
          - "LE Email: {{ letsencrypt_email }}"
```

Run:
```bash
ansible-playbook playbooks/validate_variables.yml
```

---

## Summary

**All playbooks now use variables from `group_vars/all.yml`:**

- ✅ No hardcoded IP addresses
- ✅ No hardcoded domain names
- ✅ No hardcoded paths (except standard system paths)
- ✅ Easy to adapt to new environments
- ✅ Single source of truth
- ✅ Fully repeatable and maintainable

**To deploy to a new environment:**
1. Update `group_vars/all.yml` with new values
2. Run playbooks - they automatically use new values
3. No playbook modifications needed
