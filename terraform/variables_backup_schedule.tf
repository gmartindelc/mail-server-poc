# Additional Variables for Backup Schedule Configuration
# Add these to your existing variables.tf file

variable "backup_schedule_type" {
  description = "Backup schedule type: daily, weekly, monthly, daily_alt_even, daily_alt_odd"
  type        = string
  default     = "weekly"

  validation {
    condition     = contains(["daily", "weekly", "monthly", "daily_alt_even", "daily_alt_odd"], var.backup_schedule_type)
    error_message = "Backup schedule type must be one of: daily, weekly, monthly, daily_alt_even, daily_alt_odd"
  }
}

variable "backup_schedule_hour" {
  description = "Hour of day to run backups (0-23, UTC timezone)"
  type        = number
  default     = 5

  validation {
    condition     = var.backup_schedule_hour >= 0 && var.backup_schedule_hour <= 23
    error_message = "Backup schedule hour must be between 0 and 23"
  }
}

variable "backup_schedule_dow" {
  description = "Day of week for weekly backups (0=Sunday, 1=Monday, ..., 6=Saturday). Only used for weekly backups."
  type        = number
  default     = 0

  validation {
    condition     = var.backup_schedule_dow >= 0 && var.backup_schedule_dow <= 6
    error_message = "Day of week must be between 0 (Sunday) and 6 (Saturday)"
  }
}

variable "enable_ipv6" {
  description = "Enable IPv6 networking"
  type        = bool
  default     = false
}
