terraform {
  required_version = ">= 1.0"
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.0"
    }
  }
}

# Data source to fetch the existing SSH key
data "vultr_ssh_key" "existing" {
  filter {
    name   = "name"
    values = [var.ssh_key_name]
  }
}

# Create the VPS instance
resource "vultr_instance" "server" {
  plan     = var.plan_id
  region   = var.region_id
  os_id    = var.os_id
  label    = var.label
  hostname = var.hostname
  tags     = var.tags

  # Enable automatic backups with schedule
  backups = var.enable_backups ? "enabled" : "disabled"

  # Backup schedule (required when backups are enabled)
  # Runs daily backups at 2 AM UTC with 7-day retention
  dynamic "backups_schedule" {
    for_each = var.enable_backups ? [1] : []
    content {
      type = "weekly"
      hour = 5
      dow  = 0 # Not used for daily backups, but required
    }
  }

  # Disable IPv6
  enable_ipv6 = false

  # Attach SSH key
  ssh_key_ids = [data.vultr_ssh_key.existing.id]

  # Optional: Script ID for startup script
  # script_id = var.script_id
}
