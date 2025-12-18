# Vultr VPS Terraform Configuration

This Terraform configuration creates a Vultr VPS instance with parameterized settings including plan type, hostname, region, OS, labels, and tags.

## Features

- ✅ Parameterized VPS creation using Vultr plan/region/OS codes
- ✅ Automatic backups enabled
- ✅ SSH key integration (uses existing key)
- ✅ Outputs IP address and root password
- ✅ Saves outputs in JSON format for HashiCorp Vault
- ✅ Secure credential management via .env file
- 🔄 Automated scripts to update documentation with latest Vultr resources
- 🔜 Support for multiple instance creation (prepared for future use)

## Prerequisites

1. **Vultr Account**: Sign up at [vultr.com](https://www.vultr.com)
2. **Vultr API Key**: Generate from [Vultr API Settings](https://my.vultr.com/settings/#settingsapi)
3. **SSH Key**: Already uploaded to your Vultr account
4. **Terraform**: Install from [terraform.io](https://www.terraform.io/downloads)

## File Structure

```
.
├── main.tf                    # Main VPS resource configuration
├── provider.tf                # Vultr provider configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example   # Example variables file
├── .env.example              # Example environment variables
├── save_outputs.sh           # Script to save outputs for Vault
├── .gitignore                # Git ignore rules
├── PLAN_IDS.md               # Reference: Vultr plan IDs
├── REGION_CODES.md           # Reference: Vultr region codes
├── OS_IDS.md                 # Reference: Vultr OS IDs
├── scripts/                  # Utility scripts for documentation
│   ├── vultr_resource_retriever.py    # Fetch latest Vultr resources
│   ├── vultr_resource_retriever.sh    # Bash version of retriever
│   ├── update_vultr_docs.py           # Update markdown docs from CSV
│   ├── update_vultr_docs.sh           # Bash version of updater
│   └── examples.py                     # Usage examples
└── README.md                 # This file
```

## Setup Instructions

### 1. Clone or Download Files

Download all files to your project directory.

### 2. Configure Environment Variables

Copy the example .env file and add your Vultr API key:

```bash
cp .env.example .env
nano .env  # or use your preferred editor
```

Edit `.env` and replace with your actual API key:
```bash
export TF_VAR_vultr_api_key="YOUR_ACTUAL_API_KEY_HERE"
```

### 3. Configure Terraform Variables

Copy the example tfvars file:

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # or use your preferred editor
```

Edit `terraform.tfvars` with your desired configuration:

```hcl
ssh_key_name = "my-existing-key"  # Name of your SSH key in Vultr
plan_id      = "vc2-2c-4gb"       # 2 vCPU, 4GB RAM
region_id    = "ewr"               # New Jersey
os_id        = 1743                # Ubuntu 24.04 LTS

hostname     = "production-web-01"
label        = "Production Web Server"
tags         = ["production", "web", "terraform"]

enable_backups = true
```

**Reference Files for IDs:**
- See `PLAN_IDS.md` for available plan codes
- See `REGION_CODES.md` for region codes
- See `OS_IDS.md` for operating system IDs

### 4. Load Environment Variables

```bash
source .env
# or
export $(cat .env | xargs)
```

### 5. Initialize Terraform

```bash
terraform init
```

### 6. Review the Plan

```bash
terraform plan
```

### 7. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted to create the resources.

## Viewing Outputs

### Display All Outputs

```bash
terraform output
```

### Display Specific Output

```bash
# Show IP address
terraform output main_ip

# Show root password (sensitive)
terraform output default_password
```

### Save Outputs for HashiCorp Vault

The configuration includes a special output formatted for Vault:

```bash
# Save to JSON file
./save_outputs.sh my_instance.json

# Or manually
terraform output -raw vault_secret_json > secrets.json
```

### Upload to HashiCorp Vault

```bash
# Using the JSON file
vault kv put secret/vultr/instances/my-instance @secrets.json

# Or manually specify each field
vault kv put secret/vultr/instances/my-instance \
  instance_id=$(terraform output -raw instance_id) \
  main_ip=$(terraform output -raw main_ip) \
  default_password=$(terraform output -raw default_password) \
  hostname=$(terraform output -raw instance_label)
```

## Connecting to Your VPS

Once created, connect via SSH:

```bash
ssh root@$(terraform output -raw main_ip)
```

Or use the password if needed:

```bash
# Display password
terraform output default_password
```

## Managing Multiple Instances (Future)

The configuration is prepared for multiple instance creation. To enable:

1. Uncomment the `count` parameter in `main.tf`
2. Set `instance_count` in your `terraform.tfvars`
3. Adjust outputs to handle multiple instances

## Common Plan Configurations

| Plan ID | vCPU | RAM | Storage | Bandwidth |
|---------|------|-----|---------|-----------|
| vc2-1c-1gb | 1 | 1GB | 25GB SSD | 1TB |
| vc2-2c-4gb | 2 | 4GB | 80GB SSD | 3TB |
| vc2-4c-8gb | 4 | 8GB | 160GB SSD | 4TB |
| vhf-2c-4gb | 2 | 4GB | 128GB NVMe | 3TB |

See `PLAN_IDS.md` for complete list.

## Popular Regions

| Code | Location |
|------|----------|
| ewr | New Jersey (NY Metro) |
| lax | Los Angeles |
| sjc | Silicon Valley |
| fra | Frankfurt |
| lhr | London |
| sgp | Singapore |
| syd | Sydney |

See `REGION_CODES.md` for complete list.

## Common Operating Systems

| OS ID | Operating System |
|-------|-----------------|
| 1743 | Ubuntu 24.04 LTS |
| 387 | Ubuntu 22.04 LTS |
| 2340 | Debian 12 |
| 1869 | Rocky Linux 9 |
| 2275 | Windows Server 2022 |

See `OS_IDS.md` for complete list.

## Scripts Folder

The `scripts/` directory contains utility scripts for maintaining and updating the Vultr resource documentation.

### 📥 Resource Retrieval Scripts

**Purpose:** Fetch the latest available plans, regions, and OS IDs from Vultr API

```bash
# Python version (recommended)
cd scripts
python3 vultr_resource_retriever.py

# Bash version
./vultr_resource_retriever.sh
```

**Output:** Creates timestamped CSV files with current Vultr resources:
- `vultr_plans_YYYYMMDD_HHMMSS.csv`
- `vultr_regions_YYYYMMDD_HHMMSS.csv`
- `vultr_os_YYYYMMDD_HHMMSS.csv`

### 📝 Documentation Update Scripts

**Purpose:** Generate/update the markdown documentation files from CSV data

```bash
# Python version (recommended) - deletes CSV files after processing
python3 update_vultr_docs.py

# Keep CSV files for reference
python3 update_vultr_docs.py --keep-csv

# Bash version
./update_vultr_docs.sh
```

**Output:** Updates documentation files:
- `PLAN_IDS.md` - All available server plans and pricing
- `REGION_CODES.md` - All data center locations
- `OS_IDS.md` - All operating system options

**Note:** By default, CSV files are automatically deleted after updating documentation. Use `--keep-csv` flag to preserve them.

### 🔄 Complete Update Workflow

To refresh all documentation with the latest Vultr resources:

```bash
# Method 1: Two-step process
cd scripts
python3 vultr_resource_retriever.py  # Fetch latest data
cd ..
python3 update_vultr_docs.py          # Update docs & cleanup CSVs

# Method 2: One-line command
cd scripts && python3 vultr_resource_retriever.py && cd .. && python3 update_vultr_docs.py
```

### 📚 Script Documentation

For detailed documentation on the scripts:
- See `scripts/README.md` - Resource retriever documentation
- See `scripts/UPDATE_DOCS_README.md` - Documentation updater guide
- See `scripts/QUICK_REFERENCE.md` - Quick reference cheat sheet

### ⚙️ Requirements

**Python scripts:**
```bash
pip install requests
```

**Bash scripts:**
- `curl` (required)
- `jq` (optional, for CSV conversion)

### 💡 When to Update Documentation

Update the documentation when:
- ✅ Vultr launches new server plans
- ✅ New regions become available
- ✅ New OS images are added
- ✅ Pricing changes
- ✅ Monthly/quarterly maintenance schedule

### 🤖 Automation Options

**Cron job (weekly updates):**
```bash
# Add to crontab
0 2 * * 0 cd /path/to/terraform && cd scripts && python3 vultr_resource_retriever.py && cd .. && python3 update_vultr_docs.py
```

**GitHub Actions:** See `scripts/UPDATE_DOCS_README.md` for CI/CD examples

## Troubleshooting

### Vultr Provider v2.x Changes

**Error:** `unexpected attribute, enable_private_network is not expected here`

**Fix:** The `enable_private_network` attribute was removed in provider v2.x. If you need private networking, use VPC resources instead. See `VULTR_PROVIDER_V2_CHANGES.md` for detailed migration guide.

```hcl
# ❌ Old way (v1.x) - no longer works
enable_private_network = false

# ✅ New way (v2.x) - use VPC if needed
vpc_ids = [vultr_vpc.my_vpc.id]
```

### API Key Issues

```bash
# Verify API key is loaded
echo $TF_VAR_vultr_api_key

# Re-source the .env file
source .env
```

### SSH Key Not Found

```bash
# List your SSH keys in Vultr
vultr-cli ssh-key list

# Or check via API
curl -X GET "https://api.vultr.com/v2/ssh-keys" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

### Region/Plan Not Available

Some plans may not be available in all regions. Check availability:

```bash
vultr-cli plans list --region ewr
vultr-cli regions availability ewr
```

## Cleaning Up

To destroy the created resources:

```bash
terraform destroy
```

## Security Best Practices

1. ✅ Never commit `.env` or `terraform.tfvars` to version control
2. ✅ Use `.gitignore` (provided) to exclude sensitive files
3. ✅ Store secrets in HashiCorp Vault or similar secret management
4. ✅ Rotate API keys regularly
5. ✅ Use strong SSH keys (Ed25519 or RSA 4096-bit)
6. ✅ Change the default root password immediately after first login
7. ✅ Consider using Vultr firewall rules for additional security

## Additional Resources

- [Vultr API Documentation](https://www.vultr.com/api/)
- [Vultr Terraform Provider](https://registry.terraform.io/providers/vultr/vultr/latest/docs)
- [Terraform Documentation](https://www.terraform.io/docs)
- [HashiCorp Vault](https://www.vaultproject.io/)

## License

This configuration is provided as-is for use with Vultr infrastructure.

## Support

For Terraform provider issues: [Vultr Terraform Provider GitHub](https://github.com/vultr/terraform-provider-vultr)
For Vultr platform issues: [Vultr Support](https://www.vultr.com/support/)
