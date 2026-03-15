variable "tags" {
  type    = list(string)
  default = []
}
variable "proxmox_vm_name" {
  type = string
}
variable "proxmox_vm_id" {
  type = number
}
variable "proxmox_vm_cpu_cores" {
  type    = number
  default = 2
}
variable "proxmox_vm_memory_dedicated" {
  type    = number
  default = 2048
}
variable "proxmox_vm_disk_size" {
  type    = number
  default = 50
}
variable "proxmox_vm_template_id" {
  type = number
}

variable "cloud_init_ipv4_address" {
  type    = string
  default = "192.168.1.2"
}
variable "cloud_init_ipv4_gateway" {
  type    = string
  default = "192.168.1.1"
}
variable "cloud_init_user_account_username" {
  type    = string
  default = "admin"
}
variable "cloud_init_user_account_public_keys" {
  type    = list(string)
  default = []
}
variable "cloud_init_user_data_file_id" {
  type     = string
  default  = null
  nullable = true
}

