variable "id" {
  description = "Proxmox VM or LXC's id."
  type        = number
  nullable    = false
}

variable "node_name" {
  description = "The node this workload runs on. Default: pve."
  type        = string
  nullable    = false
  default     = "pve"
}

variable "name" {
  description = "The name of the workload."
  type        = string
  nullable    = false
}

variable "type" {
  description = "The type of the workload. Enum: vm, lxc"
  type        = string
  nullable    = false

  validation {
    error_message = "Variable type must be in 'vm', 'lxc'."
    condition     = contains(["vm", "lxc"], var.type)
  }
}

variable "tags" {
  description = "The workload's tags"
  type        = list(string)
  nullable    = true
  default     = []
}

variable "compute" {
  description = "The workload's compute settings."
  type = object({
    cpu_cores        = optional(number, 2),
    memory_dedicated = optional(number, 2048),
    memory_swap      = optional(number),
  })
  nullable = false
  default = {
  }

  validation {
    error_message = "value"
    condition     = var.compute.cpu_cores > 0
  }
  validation {
    error_message = "value"
    condition     = var.compute.memory_dedicated > 0
  }
}

variable "storage" {
  description = "The workload's storage settings."
  type = list(
    object({
      size         = optional(number, 50)
      interface    = optional(string, "scsi0")
      datastore_id = optional(string, "local-lvm")
      iothread     = optional(bool, true)
    })
  )
  nullable = false
  default  = [{}]
}

variable "network" {
  description = "The workload's network settings."
  type = list(
    object({
      bridge = optional(string, "vmbr0")
      model  = optional(string, "virtio")
      mtu    = optional(string, "1500")
      name   = optional(string, "eth0") # LXC only
    })
  )
  nullable = false
  default  = [{}]
}

variable "init" {
  description = "The workload's initialization settings."
  type = object({
    enabled           = bool
    ipv4_address      = optional(string)
    ipv4_gateway      = optional(string)
    dns_servers       = optional(list(string), [])
    user_account_name = optional(string)
    user_account_keys = optional(list(string))
  })
  nullable = true
  default  = null
}

variable "vm_setting" {
  description = "Additional setting for Proxmox VM."
  type = object({
    os_type      = string
    enable_agent = bool
    template = optional(
      object({
        id           = number
        node_name    = optional(string, "pve")
        datastore_id = optional(string, "local-lvm")
      })
    )
  })
  nullable = true
  default  = null

  validation {
    error_message = "Variable vm_setting is required when type is 'vm'."
    condition     = var.type != "vm" || var.vm_setting != null
  }
}

variable "lxc_setting" {
  description = "Additional setting for Proxmox LXC."
  type = object({
    os_type       = string
    template_id   = string
    unprivileged  = bool
    start_on_boot = optional(bool, true)
    features = object({
      nesting = optional(bool, false)
      fuse    = optional(bool, false)
      keyctl  = optional(bool, false)
      mount   = optional(list(string))
      mknod   = optional(bool, false)
    })
  })
  nullable = true
  default  = null

  validation {
    error_message = "Variable lxc_setting is required when type is 'lxc'."
    condition     = var.type != "lxc" || var.lxc_setting != null
  }
}
