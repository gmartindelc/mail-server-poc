# Bulk Add Mail Users - Quick Start Guide

## CSV File Format

Create a CSV file with this format (no header row):

```csv
email,password,full_name
john@phalkons.com,SecurePass123!,John Doe
jane@phalkons.com,MyPassword456!,Jane Smith
alice@phalkons.com,AlicePass789!,Alice Johnson
bob@phalkons.com,BobSecure321!,Bob Williams
```

**Important:**
- No header row
- Three columns: email, password, full_name
- Use commas as separators
- Passwords should be strong (12+ characters)
- Names can contain spaces and special characters

## Usage

### Step 1: Create your CSV file

```bash
cd ~/dev/gmartin@phalkons/mail-server-poc/ansible

# Create users.csv
cat > users.csv << 'EOF'
john@phalkons.com,SecurePass123!,John Doe
jane@phalkons.com,MyPassword456!,Jane Smith
alice@phalkons.com,AlicePass789!,Alice Johnson
EOF
```

### Step 2: Copy playbooks to your project

```bash
cp ~/Downloads/bulk_add_mail_users.yml playbooks/
cp ~/Downloads/add_single_user.yml playbooks/
```

### Step 3: Run the bulk add playbook

```bash
# Default (looks for users.csv in current directory)
ansible-playbook playbooks/bulk_add_mail_users.yml

# Or specify custom CSV file path
ansible-playbook playbooks/bulk_add_mail_users.yml -e "csv_file=~/my_users.csv"

# Or use absolute path
ansible-playbook playbooks/bulk_add_mail_users.yml -e "csv_file=/home/gmartin/dev/gmartin@phalkons/mail-server-poc/ansible/users.csv"
```

## Example CSV Files

### Example 1: Basic Users
```csv
john@phalkons.com,Pass1234!,John Doe
jane@phalkons.com,Pass5678!,Jane Smith
```

### Example 2: Users with Complex Names
```csv
maria@phalkons.com,SecurePass1!,María García
jean-pierre@phalkons.com,MyPass123!,Jean-Pierre Dubois
o'brien@phalkons.com,SafePass789!,Patrick O'Brien
```

### Example 3: Department Accounts
```csv
sales@phalkons.com,SalesTeam2026!,Sales Department
support@phalkons.com,Support2026!,Customer Support
info@phalkons.com,Info2026!,General Information
```

## CSV File Creation Tools

### From Excel/Google Sheets
1. Create spreadsheet with columns: email, password, full_name
2. File → Save As → CSV (Comma delimited)
3. **Important:** Remove header row before saving

### From Command Line
```bash
# Create CSV with multiple users
cat > users.csv << 'EOF'
user1@phalkons.com,Password1!,User One
user2@phalkons.com,Password2!,User Two
user3@phalkons.com,Password3!,User Three
EOF
```

### From Python Script
```python
#!/usr/bin/env python3
import csv

users = [
    {'email': 'john@phalkons.com', 'password': 'Pass123!', 'name': 'John Doe'},
    {'email': 'jane@phalkons.com', 'password': 'Pass456!', 'name': 'Jane Smith'},
]

with open('users.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    for user in users:
        writer.writerow([user['email'], user['password'], user['name']])
```

## Features

### ✅ What the Playbook Does
- Validates email format
- Checks if domain exists in database
- Skips users that already exist (no duplicates)
- Generates secure password hashes
- Creates mailbox directories with correct permissions
- Creates Maildir structure (new/cur/tmp)
- Tests authentication for each user
- Provides detailed success/failure report

### ⚠️ Safety Features
- Won't overwrite existing users
- Validates domains before adding users
- Provides detailed error messages
- Tracks successful and failed additions
- No-log for passwords (security)

## Troubleshooting

### "Domain not found"
Make sure the domain exists in the database first:
```bash
ssh phalkonadmin@10.100.0.25
sudo docker exec mailserver-postgres psql -U postgres -d mailserver \
  -c "SELECT domain, active FROM domain;"
```

### "User already exists"
The playbook skips existing users automatically. Check:
```bash
sudo docker exec mailserver-postgres psql -U postgres -d mailserver \
  -c "SELECT username, name FROM mailbox;"
```

### CSV Parsing Errors
- Make sure there are no extra commas
- Names with commas should be quoted: `"Last, First"`
- No blank lines in CSV
- Use UTF-8 encoding for special characters

## Verification

After running, verify users were created:

```bash
ssh phalkonadmin@10.100.0.25

# Check database
sudo docker exec mailserver-postgres psql -U postgres -d mailserver \
  -c "SELECT username, name, active, created FROM mailbox ORDER BY created DESC;"

# Test authentication
sudo doveadm auth test john@phalkons.com Pass1234!

# Check mailboxes
sudo ls -la /var/mail/vmail/phalkons.com/

# Send test email
echo "Welcome" | mail -s "Test" john@phalkons.com
```

## Example Run Output

```
PLAY [Bulk Add Email Users from CSV]
TASK [Display number of users to add]
ok: [mail_server] => 
  msg: Found 5 user(s) in CSV file

TASK [Process each user] ********
changed: [mail_server] => (item=john@phalkons.com)
changed: [mail_server] => (item=jane@phalkons.com)
ok: [mail_server] => (item=bob@phalkons.com)  # Already exists

TASK [Display completion summary]
ok: [mail_server] => 
  msg:
  - ==========================================
  - Bulk User Creation Complete
  - ==========================================
  - Total users processed: 5
  - Successful: 4
  - Failed: 0
  - Successfully added:
  -   - john@phalkons.com
  -   - jane@phalkons.com
  -   - alice@phalkons.com
  -   - maria@phalkons.com
  - ==========================================
```

## Password Security Tips

### Good Passwords
- ✅ `MyStr0ng!P@ssw0rd`
- ✅ `C0mplex#Pass123!`
- ✅ `Secure$2026Mail!`

### Avoid
- ❌ `password123` (too simple)
- ❌ `12345678` (sequential)
- ❌ `qwerty` (keyboard pattern)

### Generate Random Passwords
```bash
# Generate 10 random passwords
for i in {1..10}; do
  openssl rand -base64 12 | tr -d "=+/" | cut -c1-16
done
```

## Advanced: Generate CSV from Existing List

```bash
# From list of names and emails
cat > generate_users.sh << 'EOF'
#!/bin/bash
# Format: email,auto-generated-password,name

generate_password() {
  openssl rand -base64 12 | tr -d "=+/" | cut -c1-12
}

echo "john.doe@phalkons.com,$(generate_password),John Doe"
echo "jane.smith@phalkons.com,$(generate_password),Jane Smith"
echo "alice.jones@phalkons.com,$(generate_password),Alice Jones"
EOF

chmod +x generate_users.sh
./generate_users.sh > users.csv
```

## Integration with Other Systems

### Import from LDAP
```bash
# Export from LDAP, convert to CSV
ldapsearch -x -b "ou=users,dc=company,dc=com" "(objectClass=person)" mail cn | \
  grep -E "^(mail|cn):" | \
  paste -d, - - | \
  sed 's/mail: //; s/cn: //' > users.csv
```

### Import from Active Directory
Export users from AD, then convert to CSV format matching our schema.

---

## Files Overview

1. **bulk_add_mail_users.yml** - Main playbook
2. **add_single_user.yml** - Task file (called by main playbook)
3. **users.csv** - Your user data (create this)

All three files should be in the `playbooks/` directory.
