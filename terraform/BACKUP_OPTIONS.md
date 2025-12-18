# Vultr Backup Schedule Options

Complete guide to configuring automatic backups for Vultr instances in Terraform.

## 📋 Table of Contents

- [Available Backup Types](#available-backup-types)
- [Configuration Parameters](#configuration-parameters)
- [Detailed Examples](#detailed-examples)
- [Use Case Recommendations](#use-case-recommendations)
- [UTC Timezone Conversion](#utc-timezone-conversion)
- [Complete Configuration Examples](#complete-configuration-examples)
- [Cost Considerations](#cost-considerations)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## Available Backup Types

Vultr supports five different backup schedule types:

| Type | Description | Frequency | When to Use |
|------|-------------|-----------|-------------|
| `daily` | Daily backups | Once every day at specified hour | Production servers, critical applications |
| `weekly` | Weekly backups | Once per week on specified day | Development/staging, cost optimization |
| `monthly` | Monthly backups | Once per month on 1st day | Long-term archives, compliance |
| `daily_alt_even` | Alternating daily (even) | Every 2 days (2nd, 4th, 6th, etc.) | Moderate protection, reduced cost |
| `daily_alt_odd` | Alternating daily (odd) | Every 2 days (1st, 3rd, 5th, etc.) | Moderate protection, reduced cost |

---

## Configuration Parameters

### Required Parameters

All backup schedules require three parameters:

| Parameter | Type | Range | Description |
|-----------|------|-------|-------------|
| `type` | string | See types above | Backup frequency type |
| `hour` | number | 0-23 | Hour of day to run backup (24-hour format, UTC) |
| `dow` | number | 0-6 | Day of week (0=Sunday, 6=Saturday) |

### Day of Week Values

| Value | Day |
|-------|-----|
| `0` | Sunday |
| `1` | Monday |
| `2` | Tuesday |
| `3` | Wednesday |
| `4` | Thursday |
| `5` | Friday |
| `6` | Saturday |

**Note:** The `dow` parameter is only used for `weekly` backups, but **must be specified** for all backup types.

---

## Detailed Examples

### 1. Daily Backups

**Scenario:** Backup every day at 2 AM UTC

```hcl
backups_schedule {
  type = "daily"
  hour = 2        # 2:00 AM UTC
  dow  = 0        # Not used for daily, but required
}
```

**Backup Pattern:**
```
Day 1: ✓ Backup at 2 AM
Day 2: ✓ Backup at 2 AM
Day 3: ✓ Backup at 2 AM
...
```

**Best For:**
- Production databases
- Critical web applications
- E-commerce sites
- Mail servers

---

### 2. Weekly Backups

**Scenario:** Backup every Sunday at 3 AM UTC

```hcl
backups_schedule {
  type = "weekly"
  hour = 3        # 3:00 AM UTC
  dow  = 0        # Sunday
}
```

**Backup Pattern:**
```
Sunday:    ✓ Backup at 3 AM
Monday:    ✗ No backup
Tuesday:   ✗ No backup
Wednesday: ✗ No backup
Thursday:  ✗ No backup
Friday:    ✗ No backup
Saturday:  ✗ No backup
```

**Other Weekly Examples:**

```hcl
# Every Friday at 10 PM UTC (weekend backup)
backups_schedule {
  type = "weekly"
  hour = 22
  dow  = 5
}

# Every Wednesday at midnight UTC (mid-week backup)
backups_schedule {
  type = "weekly"
  hour = 0
  dow  = 3
}
```

**Best For:**
- Development servers
- Staging environments
- Low-change applications
- Cost-conscious deployments

---

### 3. Monthly Backups

**Scenario:** Backup on the 1st of every month at midnight UTC

```hcl
backups_schedule {
  type = "monthly"
  hour = 0        # Midnight UTC
  dow  = 0        # Not used for monthly, but required
}
```

**Backup Pattern:**
```
January 1:   ✓ Backup at midnight
February 1:  ✓ Backup at midnight
March 1:     ✓ Backup at midnight
...
```

**Best For:**
- Archive servers
- Long-term data retention
- Compliance requirements
- Rarely-changing systems

---

### 4. Daily Alternating - Even Days

**Scenario:** Backup every even-numbered day at 3 AM UTC

```hcl
backups_schedule {
  type = "daily_alt_even"
  hour = 3        # 3:00 AM UTC
  dow  = 0        # Not used, but required
}
```

**Backup Pattern:**
```
Day 1:  ✗ No backup (odd)
Day 2:  ✓ Backup at 3 AM (even)
Day 3:  ✗ No backup (odd)
Day 4:  ✓ Backup at 3 AM (even)
Day 5:  ✗ No backup (odd)
Day 6:  ✓ Backup at 3 AM (even)
...
```

**Best For:**
- Production with moderate change rate
- Cost optimization while maintaining protection
- Balance between daily and weekly backups

---

### 5. Daily Alternating - Odd Days

**Scenario:** Backup every odd-numbered day at 3 AM UTC

```hcl
backups_schedule {
  type = "daily_alt_odd"
  hour = 3        # 3:00 AM UTC
  dow  = 0        # Not used, but required
}
```

**Backup Pattern:**
```
Day 1:  ✓ Backup at 3 AM (odd)
Day 2:  ✗ No backup (even)
Day 3:  ✓ Backup at 3 AM (odd)
Day 4:  ✗ No backup (even)
Day 5:  ✓ Backup at 3 AM (odd)
Day 6:  ✗ No backup (even)
...
```

**Best For:**
- Complementing another server with `daily_alt_even`
- Load distribution across multiple servers
- Moderate protection with cost savings

---

## Use Case Recommendations

### Production Database Server (High Priority)

```hcl
resource "vultr_instance" "db_production" {
  # ... other config ...
  
  backups = "enabled"
  
  backups_schedule {
    type = "daily"
    hour = 2        # 2 AM UTC (low traffic time)
    dow  = 0
  }
}
```

**Why:** Maximum protection with daily recovery points

---

### E-commerce Website (Critical)

```hcl
resource "vultr_instance" "ecommerce" {
  # ... other config ...
  
  backups = "enabled"
  
  backups_schedule {
    type = "daily"
    hour = 4        # 4 AM UTC (after daily processing)
    dow  = 0
  }
}
```

**Why:** Daily backups after nightly batch processes

---

### Development Server (Non-Critical)

```hcl
resource "vultr_instance" "dev_server" {
  # ... other config ...
  
  backups = "enabled"
  
  backups_schedule {
    type = "weekly"
    hour = 22       # Friday night
    dow  = 5        # Friday
  }
}
```

**Why:** Cost-effective, captures weekly work

---

### Mail Server (Important)

```hcl
resource "vultr_instance" "mail_server" {
  # ... other config ...
  
  backups = "enabled"
  
  backups_schedule {
    type = "daily"
    hour = 3        # 3 AM UTC
    dow  = 0
  }
}
```

**Why:** Daily protection for important communications

---

### Static Content Server (Low Priority)

```hcl
resource "vultr_instance" "static_cdn" {
  # ... other config ...
  
  backups = "enabled"
  
  backups_schedule {
    type = "weekly"
    hour = 0
    dow  = 0        # Sunday midnight
  }
}
```

**Why:** Infrequent changes, weekly is sufficient

---

### Archive/Compliance Server

```hcl
resource "vultr_instance" "archive" {
  # ... other config ...
  
  backups = "enabled"
  
  backups_schedule {
    type = "monthly"
    hour = 0        # 1st of month, midnight
    dow  = 0
  }
}
```

**Why:** Long-term retention, minimal changes

---

### Load-Balanced Web Server (Multiple Instances)

```hcl
# Server 1 - Even days
resource "vultr_instance" "web_01" {
  # ... other config ...
  
  backups = "enabled"
  
  backups_schedule {
    type = "daily_alt_even"
    hour = 2
    dow  = 0
  }
}

# Server 2 - Odd days
resource "vultr_instance" "web_02" {
  # ... other config ...
  
  backups = "enabled"
  
  backups_schedule {
    type = "daily_alt_odd"
    hour = 2
    dow  = 0
  }
}
```

**Why:** Distributed backup load, continuous coverage

---

## UTC Timezone Conversion

⚠️ **IMPORTANT:** All backup times are in **UTC timezone**, not your local timezone.

### Common Timezone Conversions

#### If You Want Backups at Midnight Local Time:

| Your Timezone | UTC Offset | Set hour to | Example |
|---------------|------------|-------------|---------|
| HST (Hawaii) | UTC-10 | `10` | Midnight HST = 10 AM UTC |
| PST (Pacific) | UTC-8 | `8` | Midnight PST = 8 AM UTC |
| MST (Mountain) | UTC-7 | `7` | Midnight MST = 7 AM UTC |
| CST (Central) | UTC-6 | `6` | Midnight CST = 6 AM UTC |
| EST (Eastern) | UTC-5 | `5` | Midnight EST = 5 AM UTC |
| GMT (London) | UTC+0 | `0` | Midnight GMT = Midnight UTC |
| CET (Central Europe) | UTC+1 | `23` | Midnight CET = 11 PM UTC (prev day) |
| IST (India) | UTC+5:30 | `18` or `19` | Midnight IST ≈ 6:30 PM UTC (prev day) |
| JST (Japan) | UTC+9 | `15` | Midnight JST = 3 PM UTC (prev day) |
| AEST (Sydney) | UTC+10 | `14` | Midnight AEST = 2 PM UTC (prev day) |

#### If You Want Backups at 2 AM Local Time:

| Your Timezone | Set hour to |
|---------------|-------------|
| PST | `10` |
| MST | `9` |
| CST | `8` |
| EST | `7` |
| GMT | `2` |
| CET | `1` |
| IST | `20` or `21` |
| JST | `17` |
| AEST | `16` |

### Quick Conversion Formula

```
UTC Hour = (Local Hour - Timezone Offset) % 24

Example (PST, UTC-8):
Local Time: 2 AM PST
UTC Hour = (2 - (-8)) % 24 = 10
Result: Set hour = 10
```

### Online Converters

- **Time.is**: https://time.is/UTC
- **TimeZoneConverter**: https://www.timeanddate.com/worldclock/converter.html
- **World Time Buddy**: https://www.worldtimebuddy.com/

---

## Complete Configuration Examples

### Basic Configuration (Fixed Schedule)

```hcl
# main.tf
resource "vultr_instance" "server" {
  plan     = var.plan_id
  region   = var.region_id
  os_id    = var.os_id
  label    = var.label
  hostname = var.hostname
  tags     = var.tags

  # Enable backups with fixed schedule
  backups = "enabled"
  
  backups_schedule {
    type = "daily"
    hour = 2
    dow  = 0
  }

  enable_ipv6 = false
  ssh_key_ids = [data.vultr_ssh_key.existing.id]
}
```

---

### Flexible Configuration (Variable-Based)

```hcl
# variables.tf
variable "enable_backups" {
  description = "Enable automatic backups"
  type        = bool
  default     = true
}

variable "backup_schedule_type" {
  description = "Backup schedule type"
  type        = string
  default     = "daily"
  
  validation {
    condition = contains([
      "daily", 
      "weekly", 
      "monthly", 
      "daily_alt_even", 
      "daily_alt_odd"
    ], var.backup_schedule_type)
    error_message = "Invalid backup schedule type"
  }
}

variable "backup_schedule_hour" {
  description = "Hour of day to run backups (0-23, UTC)"
  type        = number
  default     = 2
  
  validation {
    condition     = var.backup_schedule_hour >= 0 && var.backup_schedule_hour <= 23
    error_message = "Hour must be between 0 and 23"
  }
}

variable "backup_schedule_dow" {
  description = "Day of week for weekly backups (0=Sunday, 6=Saturday)"
  type        = number
  default     = 0
  
  validation {
    condition     = var.backup_schedule_dow >= 0 && var.backup_schedule_dow <= 6
    error_message = "Day of week must be between 0 and 6"
  }
}

# main.tf
resource "vultr_instance" "server" {
  plan     = var.plan_id
  region   = var.region_id
  os_id    = var.os_id
  label    = var.label
  hostname = var.hostname
  tags     = var.tags

  # Enable backups conditionally
  backups = var.enable_backups ? "enabled" : "disabled"
  
  # Add backup schedule only when backups are enabled
  dynamic "backups_schedule" {
    for_each = var.enable_backups ? [1] : []
    content {
      type = var.backup_schedule_type
      hour = var.backup_schedule_hour
      dow  = var.backup_schedule_dow
    }
  }

  enable_ipv6 = false
  ssh_key_ids = [data.vultr_ssh_key.existing.id]
}

# terraform.tfvars
enable_backups       = true
backup_schedule_type = "daily"
backup_schedule_hour = 2
backup_schedule_dow  = 0
```

---

### Multi-Environment Configuration

```hcl
# environments/production.tfvars
enable_backups       = true
backup_schedule_type = "daily"
backup_schedule_hour = 2
backup_schedule_dow  = 0

# environments/staging.tfvars
enable_backups       = true
backup_schedule_type = "weekly"
backup_schedule_hour = 22
backup_schedule_dow  = 5

# environments/development.tfvars
enable_backups       = false
backup_schedule_type = "daily"
backup_schedule_hour = 0
backup_schedule_dow  = 0
```

---

## Cost Considerations

### Backup Pricing

- **First backup**: Usually **FREE**
- **Additional backups**: May incur charges
- **Snapshot storage**: Separate from backups
- **Retention**: Automatic based on subscription

### Cost Optimization Strategies

| Strategy | Backup Type | Cost Impact | Protection Level |
|----------|-------------|-------------|------------------|
| Maximum Protection | `daily` | Higher | Excellent |
| Balanced | `daily_alt_even/odd` | Medium | Good |
| Cost-Effective | `weekly` | Lower | Moderate |
| Minimal | `monthly` | Lowest | Basic |

### Recommendations by Budget

**High Budget (Enterprise):**
```hcl
type = "daily"
```

**Medium Budget (Small Business):**
```hcl
type = "daily_alt_even"  # or "daily_alt_odd"
```

**Low Budget (Startup/Dev):**
```hcl
type = "weekly"
```

**Compliance Only:**
```hcl
type = "monthly"
```

---

## Best Practices

### ✅ DO:

1. **Choose appropriate backup type** for your use case
2. **Set backups during low-traffic hours**
3. **Use UTC time** - avoid local timezone confusion
4. **Test restores regularly** - backups are useless if you can't restore
5. **Document your backup schedule** in your infrastructure docs
6. **Use variables** for flexibility across environments
7. **Monitor backup success** through Vultr dashboard
8. **Consider compliance requirements** (GDPR, HIPAA, etc.)

### ❌ DON'T:

1. **Don't use local timezone** - always convert to UTC
2. **Don't over-backup** - daily might be overkill for static content
3. **Don't under-backup** - weekly might be too infrequent for production DBs
4. **Don't ignore costs** - more frequent = potentially higher costs
5. **Don't forget to test restores**
6. **Don't set backups during peak hours** - can impact performance
7. **Don't assume backups are working** - verify regularly

---

## Troubleshooting

### Common Issues

#### Error: "backups_schedule is required"

**Problem:**
```
Error: Backups are set to enabled please provide a backups_schedule
```

**Solution:**
Add the `backups_schedule` block when `backups = "enabled"`

```hcl
backups = "enabled"

backups_schedule {
  type = "daily"
  hour = 2
  dow  = 0
}
```

---

#### Error: "Invalid value for hour"

**Problem:**
```
Error: Invalid value for hour: must be between 0 and 23
```

**Solution:**
Use 24-hour format (0-23), not 12-hour format

```hcl
# ❌ Wrong
hour = 25

# ✅ Correct
hour = 1  # 1 AM
```

---

#### Error: "Invalid value for dow"

**Problem:**
```
Error: Invalid value for dow: must be between 0 and 6
```

**Solution:**
Use 0-6 for days (0=Sunday, 6=Saturday)

```hcl
# ❌ Wrong
dow = 7

# ✅ Correct
dow = 0  # Sunday
```

---

#### Backups Running at Wrong Time

**Problem:** Backups run at unexpected hours

**Solution:** Remember all times are UTC, not local time

```hcl
# If you want 2 AM EST (UTC-5)
# 2 AM EST = 7 AM UTC
hour = 7
```

---

#### Can't Disable Backups

**Problem:** Want to disable backups but getting errors

**Solution:** Use dynamic block with conditional

```hcl
backups = var.enable_backups ? "enabled" : "disabled"

dynamic "backups_schedule" {
  for_each = var.enable_backups ? [1] : []
  content {
    type = var.backup_schedule_type
    hour = var.backup_schedule_hour
    dow  = var.backup_schedule_dow
  }
}
```

Then set:
```hcl
enable_backups = false
```

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│                   VULTR BACKUP OPTIONS                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  TYPES:                                                     │
│    • daily           → Every day                            │
│    • weekly          → Once per week                        │
│    • monthly         → Once per month                       │
│    • daily_alt_even  → Every even day                       │
│    • daily_alt_odd   → Every odd day                        │
│                                                             │
│  PARAMETERS:                                                │
│    • type  → Backup frequency                               │
│    • hour  → 0-23 (UTC 24-hour format)                      │
│    • dow   → 0-6 (0=Sunday, 6=Saturday)                     │
│                                                             │
│  COMMON PATTERNS:                                           │
│    Production DB    → type="daily", hour=2                  │
│    Dev Server       → type="weekly", hour=22, dow=5         │
│    Archive          → type="monthly", hour=0                │
│                                                             │
│  REMEMBER:                                                  │
│    ⚠️  All times are UTC!                                   │
│    ⚠️  All three parameters required!                       │
│    ⚠️  Test your restores!                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Additional Resources

- **Vultr Backup Documentation**: https://www.vultr.com/docs/vultr-backups/
- **Vultr Pricing**: https://www.vultr.com/pricing/
- **Terraform Vultr Provider**: https://registry.terraform.io/providers/vultr/vultr/latest/docs/resources/instance
- **UTC Time Converter**: https://www.timeanddate.com/worldclock/converter.html
- **Cron Expression Generator**: https://crontab.guru/

---

## Document Version

- **Version**: 1.0
- **Last Updated**: 2024-12-18
- **Provider Version**: Vultr Terraform Provider v2.x

---

## Need Help?

If you're still unsure which backup type to choose, consider:

1. **How critical is your data?** → More critical = more frequent backups
2. **How often does it change?** → More changes = more frequent backups
3. **What's your budget?** → Less budget = less frequent backups
4. **What are your compliance requirements?** → May dictate minimum frequency
5. **Can you afford data loss?** → Time between backups = potential data loss

**General Rule:** When in doubt, start with `daily` backups and adjust based on actual needs and costs.
