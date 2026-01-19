# Terraform — Vultr VPS for Mail Server PoC

Purpose
- Provision a Vultr VPS (Debian/Ubuntu/etc.) for the Mail Server PoC with parameterized plans/regions/OS and secure credential handling.
- Provide wrapper scripts for initialization, deployment, and output/credential extraction.

Contents
- Terraform config (provider, variables, resources, outputs)
- Helper scripts: initialization, deployment (minimal/enhanced), outputs/credentials saving
- Resource documentation generators for Vultr plans/regions/OS

Directory Structure
```
terraform/
├── main.tf                         # Instance resource
├── provider.tf                     # Vultr provider config
├── variables.tf                    # Core variable definitions
├── variables_backup_schedule.tf    # Optional backup scheduling variables
├── outputs.tf                      # Outputs (incl. Vault JSON)
├── terraform.tfvars-example        # Example variable values
├── terraform.tfvars.example-with-backups
├── terraform.tfvars                # Your values (create this)
├── init.sh                         # Minimal init script
├── deploy.sh                       # Minimal deploy script
├── deploy_enhanced.sh              # Enhanced deploy with credential extraction
├── save_outputs.sh                 # Save outputs to JSON (Vault)
├── save_outputs_simple.sh          # Simple outputs saver
├── save_credentials.sh             # Secure credentials file writer
├── test_save_outputs.sh            # Test harness for outputs scripts
├── README.md                       # This file
├── README_UPDATE_SUMMARY.md        # Notes about README updates
├── SECURE_CREDENTIAL_HANDLING.md   # Security behavior for credentials
├── VULTR_PROVIDER_V2_CHANGES.md    # Provider migration notes
├── TERRAFORM_OUTPUTS_TESTING.md    # Outputs testing notes
├── CREDENTIAL_EXTRACTION.md        # Credential extraction guide
├── BACKUP_OPTIONS.md               # Backup scheduling options
├── PLAN_IDS.md                     # Vultr plan reference (generated)
├── REGION_CODES.md                 # Vultr regions reference (generated)
├── OS_IDS.md                       # Vultr OS reference (generated)
├── scripts/                        # Doc-update utilities
│   ├── vultr_resource_retriever.py
│   ├── vultr_resource_retriever.sh
│   ├── update_vultr_docs.py
│   ├── update_vultr_docs.sh
│   └── examples.py
└── (state files) terraform.tfstate, terraform.tfstate.backup
```

Prerequisites
- Vultr account + API key with permissions
- Terraform >= 1.0
- SSH key already uploaded to your Vultr account (referenced by name)
- Bash + coreutils; Python 3 if using doc update scripts

Environment and Variables
1) Environment (.env in repo root)
- Create ../.env (copy .env-example at repo root if present) and set:
```
export TF_VAR_vultr_api_key="YOUR_VULTR_API_KEY"
```
- Load before running: `source ../.env`

2) Terraform variables (terraform.tfvars)
- Copy example and adjust:
```
cp terraform.tfvars-example terraform.tfvars
```
- Edit terraform.tfvars (example):
```
ssh_key_name   = "My Vultr Key"
plan_id        = "vc2-2c-4gb"
region_id      = "ewr"
os_id          = 1743  # Ubuntu 24.04 LTS (see OS_IDS.md)
hostname       = "mailserver-poc-01"
label          = "Mail Server PoC"
tags           = ["mail", "poc", "terraform"]
enable_backups = true
```
- Reference files for IDs: PLAN_IDS.md, REGION_CODES.md, OS_IDS.md

Quick Start
Option A — Wrapper scripts
- Initialize (optional safe checks):
```
cd terraform
./init.sh
```
- Deploy (minimal):
```
./deploy.sh
```
- Deploy (enhanced with credential extraction and summary):
```
./deploy_enhanced.sh
```
Notes:
- Scripts validate presence of main.tf, terraform.tfvars, and ../.env
- Enhanced script loads TF_VAR_vultr_api_key and writes a secure credentials file in the repo root named "<hostname>.secret" with format: `ip,password` (0600 perms)

Option B — Raw Terraform
```
cd terraform
source ../.env
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

Outputs and Credentials
- Show all outputs:
```
terraform output
```
- Show specific outputs:
```
terraform output -raw main_ip
terraform output -raw default_password   # sensitive
```
- Save outputs (Vault JSON):
```
./save_outputs.sh secrets.json
# or
terraform output -raw vault_secret_json > secrets.json
```
- Secure credential handling (recommended workflow):
  - After enhanced deploy, credentials are stored in ../<hostname>.secret
  - File format: `ip,password` — permissions 600
  - Connect via:
```
ssh root@$(cut -d',' -f1 ../<hostname>.secret)
```
  - See SECURE_CREDENTIAL_HANDLING.md for details and safe patterns

Resource Documentation Updates (Plans/Regions/OS)
- Retrieve latest Vultr resources and update markdown references:
```
cd terraform/scripts
python3 vultr_resource_retriever.py
cd ..
python3 update_vultr_docs.py           # adds/updates PLAN_IDS.md, REGION_CODES.md, OS_IDS.md
```
- Bash equivalents are available (.sh)
- See README_UPDATE_SUMMARY.md for context; scripts/QUICK_REFERENCE.md for cheatsheet

Configuration Details
- Provider (provider.tf): uses var.vultr_api_key, sets rate_limit/retry_limit
- Instance (main.tf):
  - Uses plan_id, region_id, os_id, label, hostname, tags
  - Backups: `enable_backups = true` toggles backups; a weekly schedule block is configured (hour=5 UTC). See BACKUP_OPTIONS.md and variables_backup_schedule.tf for additional control if you extend the config.
  - SSH key attachment resolved via `data "vultr_ssh_key"` by name (ssh_key_name)
  - IPv6 disabled by default (enable_ipv6 variable available for extensions)
- Variables (variables.tf): core inputs
- Outputs (outputs.tf): instance details + `vault_secret_json` for secret stores

Common Workflows
- Display credentials file path and connect:
```
cat ../<hostname>.secret
ssh root@$(cut -d',' -f1 ../<hostname>.secret)
```
- Save Vault secret:
```
terraform output -raw vault_secret_json > vault_secret.json
# vault kv put secret/vultr/instances/<name> @vault_secret.json
```
- Destroy resources:
```
terraform destroy -var-file="terraform.tfvars"
```

Troubleshooting
- Provider v2.x breaking change — `enable_private_network` removed
  - Use VPC resources instead if needed; see VULTR_PROVIDER_V2_CHANGES.md
- API key not loaded
```
echo $TF_VAR_vultr_api_key
source ../.env
```
- SSH key not found in Vultr
```
# Check via CLI
vultr-cli ssh-key list
# Or via API
curl -s -H "Authorization: Bearer $TF_VAR_vultr_api_key" https://api.vultr.com/v2/ssh-keys
```
- Plan/region availability
```
vultr-cli plans list --region ewr
vultr-cli regions availability ewr
```

Security Best Practices
- Do not commit .env, terraform.tfvars, or any *.secret files
- Secrets should be stored in a secret manager (Vault, etc.)
- Rotate API keys periodically
- Replace default root password immediately after first login
- Prefer SSH key auth; disable password SSH once configured

Notes & Extensions
- variables_backup_schedule.tf includes optional vars to refine backup schedules (type/hour/dow). The current main.tf includes a weekly schedule example; extend as needed.
- TERRAFORM_OUTPUTS_TESTING.md and CREDENTIAL_EXTRACTION.md contain advanced usage/testing patterns.

Support & References
- Vultr Terraform Provider: https://registry.terraform.io/providers/vultr/vultr/latest
- Vultr API: https://www.vultr.com/api/
- Terraform Docs: https://www.terraform.io/docs
- HashiCorp Vault: https://www.vaultproject.io/
