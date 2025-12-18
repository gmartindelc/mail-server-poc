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

# Backups Configuration
enable_backups = true

# Backup Schedule Options (only used if enable_backups = true)
# Type options: "daily", "weekly", "monthly", "daily_alt_even", "daily_alt_odd"
backup_schedule_type = "weekly"

# Hour to run backups (0-23, UTC timezone)
# Example: 2 = 2:00 AM UTC
backup_schedule_hour = 5

# Day of week for weekly backups (0=Sunday, 1=Monday, ..., 6=Saturday)
# Only used when backup_schedule_type = "weekly"
backup_schedule_dow = 0

# Future: Instance count
# instance_count = 1
