# Terraform Outputs and State Files - Testing Guide

## Where Terraform Stores Output Data

Terraform outputs are stored in the **Terraform State File** (`terraform.tfstate`), not in a separate output file.

### State File Location

```
your-project/
├── terraform.tfstate          ← All outputs are stored here
├── terraform.tfstate.backup   ← Previous state (backup)
├── .terraform/                ← Provider plugins and modules
├── main.tf
├── variables.tf
└── outputs.tf
```

## Understanding Terraform State

### What is terraform.tfstate?

- **JSON file** containing complete infrastructure state
- Includes **all resource attributes**
- Contains **all output values**
- **Sensitive data** (like passwords) is stored in plain text
- **Never commit to version control** (use .gitignore)

### Example State Structure

```json
{
  "version": 4,
  "terraform_version": "1.0.0",
  "serial": 1,
  "outputs": {
    "main_ip": {
      "value": "123.45.67.89",
      "type": "string"
    },
    "default_password": {
      "value": "super_secret_password",
      "type": "string",
      "sensitive": true
    }
  },
  "resources": [...]
}
```

## How to Access Outputs

### Method 1: View All Outputs (Formatted)

```bash
terraform output
```

**Output:**
```
default_password = <sensitive>
disk = 80
instance_id = "abc123-def456"
instance_label = "cucho1.phalkons.com"
main_ip = "123.45.67.89"
os = "Ubuntu 22.04 x64"
ram = 4096
region = "dfw"
status = "active"
vcpu_count = 2
```

### Method 2: View Specific Output

```bash
# Non-sensitive output
terraform output main_ip
# Output: "123.45.67.89"

# Sensitive output (will show the value)
terraform output default_password
# Output: <sensitive>

# Use -raw to get actual value
terraform output -raw default_password
# Output: super_secret_password
```

### Method 3: View All Outputs as JSON

```bash
terraform output -json
```

**Output:**
```json
{
  "default_password": {
    "sensitive": true,
    "type": "string",
    "value": "super_secret_password"
  },
  "instance_id": {
    "sensitive": false,
    "type": "string",
    "value": "abc123-def456"
  },
  "main_ip": {
    "sensitive": false,
    "type": "string",
    "value": "123.45.67.89"
  }
}
```

### Method 4: View Specific Output (Raw, for Scripts)

```bash
terraform output -raw main_ip
# Output: 123.45.67.89 (no quotes, suitable for scripts)
```

## Test Scripts Provided

### 1. test_save_outputs.sh (Comprehensive)

**Purpose:** Save all outputs to a well-formatted text file for testing

**Features:**
- ✅ Organized sections (Instance Info, Hardware, Credentials)
- ✅ Includes SSH connection command
- ✅ JSON format for automation
- ✅ Console summary

**Usage:**
```bash
chmod +x test_save_outputs.sh
./test_save_outputs.sh
# Creates: terraform_outputs_test.txt

# Or specify custom filename
./test_save_outputs.sh my_outputs.txt
```

**Output File Structure:**
```
================================================================================
                        TERRAFORM OUTPUTS - TEST FILE
================================================================================
Generated: 2024-12-18 20:30:00

INSTANCE INFORMATION
-------------------
Instance ID       : abc123-def456
Instance Label    : cucho1.phalkons.com
Main IP Address   : 123.45.67.89
...

CREDENTIALS (SENSITIVE)
----------------------
Default Password  : super_secret_password

SSH CONNECTION
--------------
SSH Command       : ssh root@123.45.67.89
...
```

### 2. save_outputs_simple.sh (Quick & Simple)

**Purpose:** Quick dump of all outputs for testing

**Features:**
- ✅ Simple and fast
- ✅ Multiple formats (formatted, raw, JSON)
- ✅ Easy to grep specific values

**Usage:**
```bash
chmod +x save_outputs_simple.sh
./save_outputs_simple.sh
# Creates: outputs.txt

# Or specify custom filename
./save_outputs_simple.sh test.txt
```

**Output File Structure:**
```
================================================================================
                           TERRAFORM OUTPUTS
================================================================================
Generated: Thu Dec 18 20:30:00 CST 2024

=== ALL OUTPUTS (Formatted) ===
default_password = <sensitive>
instance_id = "abc123-def456"
main_ip = "123.45.67.89"
...

=== INDIVIDUAL VALUES (Raw) ===
instance_id: abc123-def456
main_ip: 123.45.67.89
default_password: super_secret_password
...

=== JSON FORMAT ===
{...full JSON output...}
```

## Testing Workflow

### Step 1: Apply Your Terraform Configuration

```bash
# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply
# Type: yes
```

This creates `terraform.tfstate` with all outputs.

### Step 2: Verify State File Exists

```bash
ls -la terraform.tfstate
# Should show the file with recent timestamp
```

### Step 3: Test Output Commands

```bash
# View all outputs
terraform output

# View specific output
terraform output main_ip

# View sensitive output
terraform output -raw default_password
```

### Step 4: Save Outputs for Testing

```bash
# Method A: Use test script (comprehensive)
./test_save_outputs.sh my_test.txt

# Method B: Use simple script
./save_outputs_simple.sh outputs.txt

# Method C: Manual save
terraform output > outputs_manual.txt
terraform output -json > outputs.json
```

### Step 5: Test SSH Connection

```bash
# Get IP from output
IP=$(terraform output -raw main_ip)

# Get password
PASS=$(terraform output -raw default_password)

# Connect
ssh root@${IP}
# Enter password when prompted
```

## Common Output Testing Scenarios

### Scenario 1: Test if Instance is Accessible

```bash
#!/bin/bash
IP=$(terraform output -raw main_ip)
ping -c 3 ${IP}
```

### Scenario 2: Automated SSH Command

```bash
#!/bin/bash
IP=$(terraform output -raw main_ip)
PASS=$(terraform output -raw default_password)

# Using sshpass (install first: apt-get install sshpass)
sshpass -p "${PASS}" ssh -o StrictHostKeyChecking=no root@${IP} 'hostname'
```

### Scenario 3: Save to Environment Variables

```bash
#!/bin/bash
export VULTR_IP=$(terraform output -raw main_ip)
export VULTR_PASS=$(terraform output -raw default_password)
export VULTR_ID=$(terraform output -raw instance_id)

echo "Exported variables:"
echo "  VULTR_IP=${VULTR_IP}"
echo "  VULTR_ID=${VULTR_ID}"
```

### Scenario 4: Create Connection Info File

```bash
#!/bin/bash
cat > connection_info.txt << EOF
Server: $(terraform output -raw instance_label)
IP: $(terraform output -raw main_ip)
Username: root
Password: $(terraform output -raw default_password)

SSH Command:
ssh root@$(terraform output -raw main_ip)
EOF

cat connection_info.txt
```

## Important Security Notes

### ⚠️ Security Warnings

1. **State file contains sensitive data** - Never commit `terraform.tfstate` to Git
2. **Output files contain passwords** - Delete test output files after use
3. **Use .gitignore** - Ensure sensitive files are ignored

### Recommended .gitignore

```gitignore
# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl

# Sensitive outputs
outputs.txt
outputs*.txt
*outputs*.txt
terraform_outputs*.txt
connection_info.txt
*.json

# Environment files
.env
terraform.tfvars

# Backups
*.backup
*.bak
```

### Secure Output Handling

```bash
# Save outputs with restricted permissions
./test_save_outputs.sh secure_outputs.txt
chmod 600 secure_outputs.txt  # Only owner can read/write

# Securely delete when done
shred -u secure_outputs.txt  # Overwrite and delete
# or
rm -P secure_outputs.txt     # Securely delete (macOS)
```

## Troubleshooting

### Issue: "No terraform.tfstate file found"

**Problem:** Haven't run `terraform apply` yet

**Solution:**
```bash
terraform apply
```

### Issue: "terraform: command not found"

**Problem:** Terraform not installed or not in PATH

**Solution:**
```bash
# Check if installed
which terraform

# Install if needed (Linux)
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### Issue: "Error loading state"

**Problem:** State file is corrupted

**Solution:**
```bash
# Try to restore from backup
cp terraform.tfstate.backup terraform.tfstate

# Or recreate by importing existing resources
terraform import vultr_instance.server <instance-id>
```

### Issue: Output shows "<sensitive>"

**Problem:** Output is marked as sensitive

**Solution:**
```bash
# Use -raw flag to show actual value
terraform output -raw default_password
```

### Issue: Can't find specific output

**Problem:** Output name doesn't exist or misspelled

**Solution:**
```bash
# List all available outputs
terraform output

# Check outputs.tf file
cat outputs.tf
```

## Quick Reference Commands

```bash
# View all outputs (formatted)
terraform output

# View all outputs (JSON)
terraform output -json

# View specific output
terraform output main_ip

# View sensitive output (raw value)
terraform output -raw default_password

# Save all to file
terraform output > outputs.txt

# Save JSON to file
terraform output -json > outputs.json

# Use in script
IP=$(terraform output -raw main_ip)

# Check if state exists
ls -la terraform.tfstate

# View state directly (not recommended, use output instead)
cat terraform.tfstate | jq '.outputs'
```

## Integration with Scripts

### Bash Script Example

```bash
#!/bin/bash

# Check if state exists
if [ ! -f "terraform.tfstate" ]; then
    echo "Error: No state file. Run terraform apply first."
    exit 1
fi

# Get outputs
IP=$(terraform output -raw main_ip 2>/dev/null)
PASSWORD=$(terraform output -raw default_password 2>/dev/null)
LABEL=$(terraform output -raw instance_label 2>/dev/null)

# Validate
if [ -z "$IP" ]; then
    echo "Error: Could not get IP address"
    exit 1
fi

# Use the data
echo "Connecting to ${LABEL} at ${IP}..."
ssh root@${IP}
```

### Python Script Example

```python
#!/usr/bin/env python3
import subprocess
import json

def get_terraform_outputs():
    """Get all terraform outputs as dictionary"""
    result = subprocess.run(
        ['terraform', 'output', '-json'],
        capture_output=True,
        text=True
    )
    
    if result.returncode != 0:
        raise Exception("Failed to get terraform outputs")
    
    outputs = json.loads(result.stdout)
    
    # Extract just the values
    return {k: v['value'] for k, v in outputs.items()}

# Usage
outputs = get_terraform_outputs()
print(f"IP: {outputs['main_ip']}")
print(f"Password: {outputs['default_password']}")
```

## Summary

### Key Takeaways

1. ✅ Outputs are stored in `terraform.tfstate` (JSON format)
2. ✅ Use `terraform output` commands to access them
3. ✅ Test scripts provided save outputs to text files
4. ✅ State files contain sensitive data - protect them
5. ✅ Use `-raw` flag for script-friendly output
6. ✅ Never commit state files or output files to Git

### Quick Testing Steps

```bash
# 1. Apply terraform
terraform apply

# 2. Test output access
terraform output

# 3. Save for testing
./test_save_outputs.sh test.txt

# 4. View the file
cat test.txt

# 5. Test SSH
ssh root@$(terraform output -raw main_ip)

# 6. Clean up
rm test.txt
```

Now you can easily test and access your Terraform outputs! 🎉
