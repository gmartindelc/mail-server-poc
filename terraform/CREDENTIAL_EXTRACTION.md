# Deployment and Credential Extraction Scripts

Documentation for automated deployment and credential management scripts.

## Scripts Overview

| Script | Purpose | Output |
|--------|---------|--------|
| `deploy.sh` | Deploy infrastructure with credential extraction | `hostname.secret` in parent directory |
| `deploy_enhanced.sh` | Enhanced deployment with logging and summaries | `.secret` file + `deployment_info.txt` |
| `save_credentials.sh` | Standalone credential extraction | `hostname.secret` in parent directory |

---

## Credential File Format

### File: `hostname.secret`

**Location:** Parent directory (one level up from terraform/)

**Format:**
```
ip,password
```

**Example:**
```
123.45.67.89,super_secret_password_here
```

**Permissions:** `600` (owner read/write only)

---

## Script 1: deploy.sh (Updated)

### Purpose
Deploy Vultr instance and automatically extract credentials to `.secret` file.

### Features
- ✅ Prerequisite checks
- ✅ Configuration review
- ✅ Automatic credential extraction
- ✅ Creates `hostname.secret` in parent directory

### Usage

```bash
cd terraform
chmod +x deploy.sh
./deploy.sh
```

### What It Does

1. Checks for required files (`main.tf`, `terraform.tfvars`, `.env`)
2. Loads environment variables
3. Shows configuration for review
4. Asks for confirmation
5. Runs `terraform apply`
6. Extracts IP and password
7. Creates `../hostname.secret` with format: `ip,password`
8. Sets file permissions to 600
9. Displays credentials and SSH command

### Output Example

```
==================================================
Extracting credentials...
==================================================
✅ Credentials saved to: ../cucho1.phalkons.com.secret

Credentials:
  Hostname: cucho1.phalkons.com
  IP      : 123.45.67.89
  Password: super_secret_pass

SSH Command:
  ssh root@123.45.67.89

⚠️  Keep cucho1.phalkons.com.secret secure - contains sensitive data!

Check all outputs with: terraform output
```

### Files Created

```
mail-server-poc/
├── cucho1.phalkons.com.secret    ← Created here
└── terraform/
    ├── deploy.sh                  ← Script location
    ├── terraform.tfstate
    └── ...
```

---

## Script 2: deploy_enhanced.sh (Comprehensive)

### Purpose
Enhanced deployment script with better error handling, logging, and reporting.

### Features
- ✅ Colored output for better readability
- ✅ Comprehensive error checking
- ✅ Deployment logging to `deploy.log`
- ✅ Creates `hostname.secret` (ip,password format)
- ✅ Creates `deployment_info.txt` (human-readable summary)
- ✅ Next steps guidance
- ✅ Security reminders

### Usage

```bash
cd terraform
chmod +x deploy_enhanced.sh
./deploy_enhanced.sh
```

### What It Does

1. Checks all prerequisites with detailed messages
2. Loads and validates environment variables
3. Shows configuration review
4. Confirms deployment
5. Initializes Terraform if needed
6. Deploys with logging to `deploy.log`
7. Extracts credentials
8. Creates two files:
   - `../hostname.secret` (machine-readable: ip,password)
   - `../deployment_info.txt` (human-readable summary)
9. Displays comprehensive summary
10. Shows next steps

### Output Example

```
==================================================
  Deployment Summary
==================================================

Hostname       : cucho1.phalkons.com
IP Address     : 123.45.67.89
Root Password  : super_secret_pass
Credentials    : ../cucho1.phalkons.com.secret

✓ Deployment Complete!

==================================================
  Next Steps
==================================================

1. Connect to your server:
   ssh root@123.45.67.89

2. Change the root password immediately:
   passwd

3. View all outputs:
   terraform output

4. Credentials are saved in:
   ../cucho1.phalkons.com.secret
   Format: ip,password

⚠️  SECURITY REMINDERS:
  • Change the root password on first login
  • Keep cucho1.phalkons.com.secret secure
  • Do not commit .secret files to version control
  • Consider using SSH keys instead of password authentication
```

### Files Created

```
mail-server-poc/
├── cucho1.phalkons.com.secret    ← Credentials (ip,password)
├── deployment_info.txt            ← Readable summary
└── terraform/
    ├── deploy_enhanced.sh         ← Script location
    ├── deploy.log                 ← Deployment log
    ├── terraform.tfstate
    └── ...
```

---

## Script 3: save_credentials.sh (Standalone)

### Purpose
Extract credentials from existing Terraform state without redeploying.

### Features
- ✅ Works with existing `terraform.tfstate`
- ✅ Colored output
- ✅ Comprehensive validation
- ✅ Creates `hostname.secret` in parent directory
- ✅ Sets secure permissions (600)

### Usage

```bash
cd terraform
chmod +x save_credentials.sh
./save_credentials.sh
```

### When to Use

- After manual `terraform apply`
- To regenerate `.secret` file if deleted
- To extract credentials without full deployment
- For testing credential extraction

### Output Example

```
==================================================
  Extracting Terraform Credentials
==================================================

ℹ Extracting outputs from Terraform state...
ℹ Creating credentials file: ../cucho1.phalkons.com.secret
✓ Credentials saved successfully!

==================================================
  Credentials Summary
==================================================
Hostname : cucho1.phalkons.com
IP       : 123.45.67.89
Password : super_secret_pass
File     : ../cucho1.phalkons.com.secret

==================================================

ℹ File format: ip,password
ℹ File permissions: 600 (owner read/write only)

⚠️  SECURITY REMINDER:
  • This file contains sensitive credentials
  • Keep it secure and do not commit to version control
  • Delete after use or store in a secure location

✓ SSH Connection Command:
  ssh root@123.45.67.89

ℹ File contents:
123.45.67.89,super_secret_pass
```

---

## Using the Credential File

### Reading the File

**Bash:**
```bash
# Read the entire file
cat ../cucho1.phalkons.com.secret

# Extract IP
IP=$(cut -d',' -f1 ../cucho1.phalkons.com.secret)

# Extract password
PASSWORD=$(cut -d',' -f2 ../cucho1.phalkons.com.secret)

# Use in script
IFS=',' read -r IP PASSWORD < ../cucho1.phalkons.com.secret
echo "IP: $IP"
echo "Password: $PASSWORD"
```

**Python:**
```python
#!/usr/bin/env python3

# Read credentials file
with open('../cucho1.phalkons.com.secret', 'r') as f:
    content = f.read().strip()
    ip, password = content.split(',')

print(f"IP: {ip}")
print(f"Password: {password}")
```

**PowerShell:**
```powershell
# Read credentials file
$content = Get-Content "../cucho1.phalkons.com.secret"
$ip, $password = $content -split ','

Write-Host "IP: $ip"
Write-Host "Password: $password"
```

### Automated SSH Connection

```bash
#!/bin/bash

# Read credentials
IFS=',' read -r IP PASSWORD < ../cucho1.phalkons.com.secret

# Connect (requires sshpass)
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no root@$IP

# Or just show the command
echo "ssh root@$IP"
```

### Ansible Inventory Integration

```bash
#!/bin/bash

# Read credentials
IFS=',' read -r IP PASSWORD < ../cucho1.phalkons.com.secret

# Create Ansible inventory
cat > inventory.ini << EOF
[mail_servers]
mail-server ansible_host=$IP ansible_user=root ansible_password=$PASSWORD

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

echo "Inventory created: inventory.ini"
```

---

## File Permissions and Security

### Automatic Security

All scripts automatically set secure permissions on `.secret` files:

```bash
chmod 600 hostname.secret
```

This means:
- **6** (owner): read + write
- **0** (group): no access
- **0** (others): no access

### Verify Permissions

```bash
ls -la ../*.secret
# Should show: -rw------- (600)
```

### Change Permissions Manually

```bash
# Make it read-only for owner
chmod 400 ../hostname.secret

# Make it readable by owner only
chmod 600 ../hostname.secret

# Make it completely private
chmod 000 ../hostname.secret
```

---

## Security Best Practices

### ✅ DO:

1. **Change root password immediately** after first login
2. **Use SSH keys** instead of password authentication
3. **Delete .secret files** after copying to secure location
4. **Store in password manager** or HashiCorp Vault
5. **Keep backups encrypted**
6. **Use .gitignore** to prevent accidental commits

### ❌ DON'T:

1. **Don't commit** `.secret` files to version control
2. **Don't share** via unencrypted channels (email, Slack, etc.)
3. **Don't leave** files with default password for long
4. **Don't use** the same password for multiple servers
5. **Don't store** in shared/public directories

---

## .gitignore Configuration

Add to your `.gitignore`:

```gitignore
# Credential files
*.secret

# Deployment logs
deployment_info.txt
deploy.log

# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl

# Environment
.env
terraform.tfvars

# Backups
*.backup
*.bak
```

---

## Workflow Examples

### Standard Workflow

```bash
# 1. Configure your variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Set up environment
cp .env.example .env
nano .env

# 3. Deploy (automatically creates .secret file)
cd terraform
./deploy.sh

# 4. Connect
IP=$(cut -d',' -f1 ../cucho1.phalkons.com.secret)
ssh root@$IP

# 5. Change password on first login
passwd

# 6. Secure the credentials
mv ../cucho1.phalkons.com.secret ~/secure_location/
```

### Testing Workflow

```bash
# 1. Deploy
./deploy.sh

# 2. Test credential extraction
./save_credentials.sh

# 3. Verify file
cat ../cucho1.phalkons.com.secret

# 4. Test SSH connection
IP=$(cut -d',' -f1 ../cucho1.phalkons.com.secret)
ping -c 3 $IP
ssh root@$IP
```

### Automation Workflow

```bash
# 1. Deploy with enhanced script
./deploy_enhanced.sh

# 2. Read credentials into script
IFS=',' read -r IP PASSWORD < ../cucho1.phalkons.com.secret

# 3. Use in automation
ansible-playbook -i "$IP," setup.yml \
  --extra-vars "ansible_password=$PASSWORD"

# 4. Clean up
shred -u ../cucho1.phalkons.com.secret
```

---

## Troubleshooting

### Issue: "No terraform.tfstate file found"

**Problem:** Credentials can't be extracted without state file

**Solution:**
```bash
terraform apply  # Deploy first
./save_credentials.sh
```

### Issue: "Failed to extract hostname/IP/password"

**Problem:** Outputs not defined or Terraform apply failed

**Solution:**
```bash
# Check outputs are defined
cat outputs.tf

# Manually check what's available
terraform output

# Try to get specific output
terraform output -raw main_ip
```

### Issue: "Permission denied"

**Problem:** Can't write to parent directory

**Solution:**
```bash
# Check write permissions
ls -la ..

# Or save to current directory instead
SECRET_FILE="${HOSTNAME}.secret"
```

### Issue: ".secret file contains wrong data"

**Problem:** File format incorrect

**Solution:**
```bash
# Check file contents
cat ../hostname.secret

# Should be: ip,password
# Should NOT have spaces, quotes, or extra lines

# Recreate
rm ../hostname.secret
./save_credentials.sh
```

---

## Advanced Usage

### Multiple Environments

```bash
# Production
./deploy.sh
mv ../cucho1.phalkons.com.secret ../prod.secret

# Staging  
./deploy.sh
mv ../cucho2.phalkons.com.secret ../staging.secret

# Development
./deploy.sh
mv ../cucho3.phalkons.com.secret ../dev.secret
```

### Backup Credentials

```bash
#!/bin/bash
# backup_credentials.sh

BACKUP_DIR="$HOME/secure_backups/vultr"
mkdir -p "$BACKUP_DIR"

# Copy with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
cp ../*.secret "$BACKUP_DIR/backup_${TIMESTAMP}.secret"

# Encrypt (optional)
gpg -c "$BACKUP_DIR/backup_${TIMESTAMP}.secret"
rm "$BACKUP_DIR/backup_${TIMESTAMP}.secret"

echo "Backup encrypted: $BACKUP_DIR/backup_${TIMESTAMP}.secret.gpg"
```

### Upload to Vault

```bash
#!/bin/bash
# upload_to_vault.sh

IFS=',' read -r IP PASSWORD < ../cucho1.phalkons.com.secret
HOSTNAME=$(terraform output -raw instance_label)

vault kv put "secret/vultr/${HOSTNAME}" \
  ip="$IP" \
  password="$PASSWORD" \
  deployed="$(date)"

echo "Credentials uploaded to Vault: secret/vultr/${HOSTNAME}"

# Securely delete local file
shred -u ../cucho1.phalkons.com.secret
```

---

## Summary

### Quick Reference

```bash
# Deploy and extract credentials
./deploy.sh

# Extract credentials only
./save_credentials.sh

# Enhanced deployment
./deploy_enhanced.sh

# Read credentials
cat ../hostname.secret
IFS=',' read -r IP PASSWORD < ../hostname.secret

# Connect
ssh root@$IP

# Secure delete
shred -u ../hostname.secret
```

### File Locations

```
project/
├── hostname.secret          ← Credentials (ip,password)
├── deployment_info.txt      ← Readable summary
└── terraform/
    ├── deploy.sh            ← Basic deployment
    ├── deploy_enhanced.sh   ← Enhanced deployment
    ├── save_credentials.sh  ← Extract only
    └── terraform.tfstate    ← Terraform state
```

Now you have automated credential extraction integrated into your deployment! 🎉
