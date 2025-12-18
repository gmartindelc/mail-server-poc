# Terraform variables file
# Copy this to terraform.tfvars and fill in your values

# SSH Key (existing in your Vultr account)
ssh_key_name = "LC02 Vultr"

# VPS Configuration
plan_id   = "vc2-2c-4gb" # 2 vCPU, 4GB RAM
region_id = "dfw"        # New Jersey
os_id     = 2625         # Ubuntu 24.04 LTS

# Server Details
hostname = "cucho1.phalkons.com"
label    = "cucho1.phalkons.com"

# Tags (optional)
tags = ["production", "mail-server", "terraform"]

# Backups
enable_backups = true

# Future: Instance count
# instance_count = 1
