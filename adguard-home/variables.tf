variable "proxmox_node_name" {
  type        = string
  description = "Proxmox node name for the AdGuard Home container"
  default     = "pve"
}

variable "adguard_vmid" {
  type        = number
  description = "LXC VM ID for AdGuard Home"
  default     = 110
}

variable "adguard_hostname" {
  type        = string
  description = "Hostname for the AdGuard Home container"
  default     = "adguard"
}

variable "adguard_ip" {
  type        = string
  description = "Static IPv4 address for the AdGuard Home container in CIDR notation"
  default     = "192.168.64.50/24"
}

variable "adguard_gateway" {
  type        = string
  description = "IPv4 gateway for the AdGuard Home container"
  default     = "192.168.64.1"
}

variable "adguard_dns_servers" {
  type        = list(string)
  description = "DNS servers for the container during initialization"
  default     = ["1.1.1.1", "8.8.8.8"]
}

variable "adguard_storage" {
  type        = string
  description = "Proxmox storage ID for the AdGuard Home container root disk"
  default     = "local-lvm"
}

variable "adguard_template_datastore" {
  type        = string
  description = "Datastore to download the Debian LXC template into"
  default     = "local"
}

variable "adguard_template_url" {
  type        = string
  description = "URL of the Debian 13 LXC cloud image archive to use for the container template"
  default     = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.tar.xz"
}
