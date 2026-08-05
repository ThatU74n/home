variable "proxmox_api_endpoint" {
  type     = string
  nullable = false
}

variable "proxmox_api_token" {
  type      = string
  nullable  = false
  sensitive = true
}
