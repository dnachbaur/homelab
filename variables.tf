variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox endpoint"
}

variable "proxmox_api_token" {
  type        = string
  description = "Proxmox API token"
  sensitive   = true
}
