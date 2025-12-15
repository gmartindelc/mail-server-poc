# terraform/variables.tf

variable "vultr_api_key" {
  description = "Vultr API Key for authentication"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for instance authentication"
  type        = string
  sensitive   = true
}

variable "server_plan" {
  description = "Vultr server plan type"
  type        = string
  default     = "vc2-2c-4gb"
}

variable "hostname" {
  description = "Hostname for the server"
  type        = string
  default     = "cucho.phalkons.com"
}

variable "region" {
  description = "Geographic region for deployment"
  type        = string
  default     = "Dallas"
}

variable "os_name" {
  description = "Operating system name and version"
  type        = string
  default     = "Debian 13 x64 (Bookworm)"
}

variable "label" {
  description = "Label for the instance"
  type        = string
  default     = "mail-server-poc"
}

variable "tags" {
  description = "Tags for resource organization"
  type        = list(string)
  default     = ["mail-server", "poc", "production", "terraform-managed"]
}
