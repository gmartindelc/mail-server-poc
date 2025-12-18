variable "vultr_api_key" {
  description = "Vultr API key"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "Name of the existing SSH key in Vultr account"
  type        = string
}

variable "plan_id" {
  description = "Plan ID for the VPS (e.g., vc2-1c-1gb, vc2-2c-4gb)"
  type        = string
  default     = "vc2-2c-4gb"
}

variable "region_id" {
  description = "Region ID where the VPS will be created (e.g., ewr for New Jersey)"
  type        = string
}

variable "os_id" {
  description = "Operating System ID (e.g., 387 for Ubuntu 22.04, 1743 for Ubuntu 24.04)"
  type        = number
}

variable "hostname" {
  description = "Hostname for the VPS"
  type        = string
}

variable "label" {
  description = "Label for the VPS in Vultr dashboard"
  type        = string
}

variable "tags" {
  description = "Tags for the VPS"
  type        = list(string)
  default     = []
}

variable "enable_backups" {
  description = "Enable automatic backups"
  type        = bool
  default     = true
}

# Future: For multiple instance creation
variable "instance_count" {
  description = "Number of instances to create (for future use)"
  type        = number
  default     = 1
}
