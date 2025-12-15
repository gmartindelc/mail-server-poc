# terraform/terraform.tfvars
# Server-specific configuration for Mail Server PoC

# Server specifications (from Vultr_specs.md)
server_plan = "vc2-2c-4gb"
hostname    = "cucho1.phalkons.com"
region      = "Dallas"
os_name     = "Debian 13 x64 (Trixie)"

# Instance configuration
label = "mail-server-poc"
tags  = ["mail-server", "poc", "production", "terraform-managed"]

# Note: vultr_api_key and ssh_public_key are loaded from .env
