# Vultr Terraform Provider v2.x Changes

## Fixed Error

**Error:** `unexpected attribute, enable_private_network is not expected here` on line 35

**Root Cause:** The `enable_private_network` attribute was deprecated and removed in Vultr Terraform Provider version 2.x.

## What Changed

### Removed Attribute
```hcl
# ❌ This no longer works in provider v2.x
enable_private_network = false
```

### Migration to VPC

In Vultr provider v2.x, private networking has been replaced with **VPC (Virtual Private Cloud)** functionality. If you need private networking, you should now use:

```hcl
# ✅ New way: Use VPC in provider v2.x
resource "vultr_vpc" "my_vpc" {
  region   = var.region_id
  v4_subnet = "10.0.0.0"
  v4_subnet_mask = 24
}

resource "vultr_instance" "server" {
  plan     = var.plan_id
  region   = var.region_id
  os_id    = var.os_id
  
  # Attach instance to VPC
  vpc_ids = [vultr_vpc.my_vpc.id]
  
  # ... other settings
}
```

## Fixed main.tf

The corrected `main.tf` now looks like:

```hcl
resource "vultr_instance" "server" {
  plan     = var.plan_id
  region   = var.region_id
  os_id    = var.os_id
  label    = var.label
  hostname = var.hostname
  tags     = var.tags

  # Enable automatic backups
  backups = var.enable_backups ? "enabled" : "disabled"

  # Disable IPv6
  enable_ipv6 = false

  # Attach SSH key
  ssh_key_ids = [data.vultr_ssh_key.existing.id]
}
```

## Other Deprecated Attributes in v2.x

Here are other attributes that changed or were removed in provider v2.x:

| v1.x Attribute | v2.x Change | Alternative |
|----------------|-------------|-------------|
| `enable_private_network` | ❌ Removed | Use `vpc_ids` with `vultr_vpc` resource |
| `private_network_ids` | ❌ Removed | Use `vpc_ids` |
| `network_ids` | ❌ Removed | Use `vpc_ids` |
| `firewall_group_id` | ✅ Still works | No change |
| `enable_ipv6` | ✅ Still works | No change |
| `backups` | ✅ Still works | No change |

## If You Need Private Networking

If you actually need private networking for your mail server (e.g., for database connections), here's how to add it:

### Step 1: Add VPC Resource

Create a new file `vpc.tf` or add to `main.tf`:

```hcl
# Create VPC for private networking
resource "vultr_vpc" "mail_server_vpc" {
  region         = var.region_id
  description    = "Private network for mail server"
  v4_subnet      = "10.0.0.0"
  v4_subnet_mask = 24
}
```

### Step 2: Attach Instance to VPC

Update `main.tf`:

```hcl
resource "vultr_instance" "server" {
  plan     = var.plan_id
  region   = var.region_id
  os_id    = var.os_id
  label    = var.label
  hostname = var.hostname
  tags     = var.tags

  backups     = var.enable_backups ? "enabled" : "disabled"
  enable_ipv6 = false
  
  # Attach to VPC for private networking
  vpc_ids = [vultr_vpc.mail_server_vpc.id]

  ssh_key_ids = [data.vultr_ssh_key.existing.id]
}
```

### Step 3: Update variables.tf (if needed)

```hcl
variable "enable_vpc" {
  description = "Enable VPC for private networking"
  type        = bool
  default     = false
}

variable "vpc_subnet" {
  description = "VPC subnet (e.g., 10.0.0.0)"
  type        = string
  default     = "10.0.0.0"
}

variable "vpc_subnet_mask" {
  description = "VPC subnet mask"
  type        = number
  default     = 24
}
```

### Step 4: Conditional VPC

If you want VPC to be optional:

```hcl
# vpc.tf
resource "vultr_vpc" "mail_server_vpc" {
  count          = var.enable_vpc ? 1 : 0
  region         = var.region_id
  description    = "Private network for mail server"
  v4_subnet      = var.vpc_subnet
  v4_subnet_mask = var.vpc_subnet_mask
}

# main.tf
resource "vultr_instance" "server" {
  # ... other settings ...
  
  # Conditionally attach to VPC
  vpc_ids = var.enable_vpc ? [vultr_vpc.mail_server_vpc[0].id] : []
  
  # ... rest of settings ...
}
```

## Testing the Fix

After making these changes:

```bash
# Initialize/update provider
terraform init -upgrade

# Validate configuration
terraform validate

# Plan to see changes
terraform plan

# Apply if everything looks good
terraform apply
```

## Provider Version Upgrade Notes

If you're upgrading from v1.x to v2.x:

1. **Backup your state**: `terraform state pull > backup.tfstate`
2. **Review the changelog**: https://github.com/vultr/terraform-provider-vultr/releases
3. **Update provider version**: Change `version = "~> 2.0"` in your config
4. **Remove deprecated attributes**: Like `enable_private_network`
5. **Test in a non-production environment first**
6. **Run `terraform plan`** to see what will change
7. **Apply carefully**: Some resources may need to be recreated

## Additional Resources

- **Vultr Provider v2.x Documentation**: https://registry.terraform.io/providers/vultr/vultr/latest/docs
- **VPC Resource Documentation**: https://registry.terraform.io/providers/vultr/vultr/latest/docs/resources/vpc
- **Instance Resource Documentation**: https://registry.terraform.io/providers/vultr/vultr/latest/docs/resources/instance
- **Migration Guide**: https://github.com/vultr/terraform-provider-vultr/blob/master/MIGRATION.md

## Summary

✅ **Fixed:** Removed `enable_private_network` attribute (line 35)  
✅ **Reason:** Deprecated in provider v2.x  
✅ **Alternative:** Use VPC resources if private networking is needed  
✅ **Your config:** Now works with Vultr provider v2.x  

The fixed configuration will work correctly with no private networking. If you need private networking in the future, follow the VPC setup instructions above.
