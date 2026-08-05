variable "node_name" {
  type     = string
  nullable = false
}

variable "os_type" {
  type     = string
  nullable = true
  default  = "l26"

  validation {
    condition     = contains(["l26", "other"], var.os_type)
    error_message = "os_type must be one of: l26 (Linux), other (FreeBSD)."
  }
}

variable "vm_name" {
  type     = string
  nullable = false
}

variable "vm_id" {
  type     = number
  nullable = false
}

variable "is_clone_from_template" {
  type    = bool
  default = false
}

variable "vm_template_id" {
  type     = number
  nullable = true
  default  = null

  validation {
    condition     = !var.is_clone_from_template || var.vm_template_id != null
    error_message = "vm_template_id is requied when is_clone_from_template is true."
  }
}

variable "vm_cpu_cores" {
  type     = number
  nullable = true
  default  = 2
}

variable "vm_memory_dedicated" {
  type     = number
  nullable = true
  default  = 2048
}

variable "vm_disk_size" {
  type     = number
  nullable = true
  default  = 50
}

variable "vm_network_devices" {
  type = list(
    object({
      bridge = string
      model  = optional(string)
      mtu    = optional(string)
    })
  )
  nullable = true
  default = [{
    model  = "virtio"
    bridge = "vmbr0"
    mtu    = "1500"
  }]
}

variable "enable_cloud_init" {
  type     = bool
  nullable = false
  default  = false
}

variable "cloud_init_ipv4_address" {
  type     = string
  nullable = true
  default  = null

  validation {
    condition     = !var.enable_cloud_init || var.cloud_init_ipv4_address != null
    error_message = "cloud_init_ipv4_address is required when enable_cloud_init is true."
  }

  validation {
    condition     = var.cloud_init_ipv4_address == null || can(cidrhost(var.cloud_init_ipv4_address, 0))
    error_message = "cloud_init_ipv4_address must be in CIDR notation."
  }
}

variable "cloud_init_ipv4_gateway" {
  type     = string
  nullable = true
  default  = null

  validation {
    condition     = !var.enable_cloud_init || var.cloud_init_ipv4_gateway != null
    error_message = "cloud_init_ipv4_gateway is required when enable_cloud_init is true."
  }
}

variable "cloud_init_dns_servers" {
  type     = list(string)
  nullable = true
  default = [
    "1.1.1.1",
    "8.8.8.8"
  ]

  validation {
    condition     = !var.enable_cloud_init || var.cloud_init_dns_servers != null
    error_message = "cloud_init_dns_servers is required when enable_cloud_init is true."
  }


}

variable "cloud_init_user_account_username" {
  type     = string
  nullable = true
  default  = null

  validation {
    condition     = !var.enable_cloud_init || var.cloud_init_user_account_username != null
    error_message = "cloud_init_user_account_username is required when enable_cloud_init is true."
  }
}
variable "cloud_init_user_account_public_keys" {
  type     = list(string)
  nullable = true
  default  = []

  validation {
    condition     = !var.enable_cloud_init || var.cloud_init_user_account_public_keys != null
    error_message = "cloud_init_user_account_public_keys is required when enable_cloud_init is true"
  }
}

variable "enable_agent" {
  type     = bool
  nullable = false
  default  = false
}
variable "tags" {
  type    = list(string)
  default = []
}
