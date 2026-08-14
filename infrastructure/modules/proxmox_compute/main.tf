resource "proxmox_virtual_environment_vm" "this" {
  count = var.type == "vm" ? 1 : 0

  vm_id     = var.id
  name      = var.name
  node_name = var.node_name
  tags      = var.tags

  operating_system {
    type = var.vm_setting.os_type
  }
  dynamic "clone" {
    for_each = var.vm_setting.template != null ? [1] : []
    content {
      vm_id        = var.vm_setting.template.id
      node_name    = var.vm_setting.template.node_name
      datastore_id = var.vm_setting.template.datastore_id
      full         = false
    }
  }
  agent {
    enabled = var.vm_setting.enable_agent
  }

  cpu {
    type  = "host"
    cores = var.compute.cpu_cores
  }
  memory {
    dedicated = var.compute.memory_dedicated
  }

  dynamic "disk" {
    for_each = var.storage
    content {
      size         = disk.value.size
      interface    = disk.value.interface
      datastore_id = disk.value.datastore_id
      iothread     = disk.value.iothread
    }
  }

  dynamic "network_device" {
    for_each = var.network
    content {
      bridge = network_device.value.bridge
      model  = network_device.value.model
      mtu    = network_device.value.mtu
    }
  }

  dynamic "initialization" {
    for_each = var.init != null && var.init.enabled == true ? [1] : []
    content {
      ip_config {
        ipv4 {
          address = var.init.ipv4_address
          gateway = var.init.ipv4_gateway
        }
      }
      dns {
        servers = var.init.dns_servers
      }
      user_account {
        username = var.init.user_account_name
        keys     = var.init.user_account_keys
      }
    }
  }

  lifecycle {
    ignore_changes = [clone]
  }
}

resource "proxmox_virtual_environment_container" "this" {
  count = var.type == "lxc" ? 1 : 0

  vm_id     = var.id
  node_name = var.node_name
  tags      = var.tags

  operating_system {
    template_file_id = var.lxc_setting.template_id
    type             = var.lxc_setting.os_type
  }

  cpu {
    cores = var.compute.cpu_cores
  }
  memory {
    dedicated = var.compute.memory_dedicated
    swap      = var.compute.memory_swap
  }

  dynamic "disk" {
    for_each = var.storage
    content {
      size         = disk.value.size
      datastore_id = disk.value.datastore_id
    }
  }

  dynamic "network_interface" {
    for_each = var.network
    content {
      name   = network_interface.value.name
      bridge = network_interface.value.bridge
    }
  }

  dynamic "initialization" {
    for_each = var.init.enabled == true ? [1] : []
    content {
      hostname = var.name
      ip_config {
        ipv4 {
          address = var.init.ipv4_address
          gateway = var.init.ipv4_gateway
        }
      }
      dns {
        servers = var.init.dns_servers
      }
      user_account {
        keys = var.init.user_account_keys
      }
    }
  }

  unprivileged  = var.lxc_setting.unprivileged
  start_on_boot = var.lxc_setting.start_on_boot
  features {
    fuse    = var.lxc_setting.features.fuse
    nesting = var.lxc_setting.features.nesting
    keyctl  = var.lxc_setting.features.keyctl
    mount   = var.lxc_setting.features.mount
    mknod   = var.lxc_setting.features.mknod
  }
}
