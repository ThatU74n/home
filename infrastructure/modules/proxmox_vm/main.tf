# TODO: wait for proxmox_cloned_vm to be out of experimental
# - check again in proxmox v1.0
# - proxmox_virtual_environment_vm is marked as deprecated, switch from proxmox_virtual_environment_vm to proxmox_vm in v1.0 

resource "proxmox_virtual_environment_vm" "this" {
  node_name = var.node_name

  name  = var.vm_name
  vm_id = var.vm_id
  operating_system {
    type = var.os_type
  }
  cpu {
    cores = var.vm_cpu_cores
    type  = "host"
  }
  memory {
    dedicated = var.vm_memory_dedicated
  }
  disk {
    size         = var.vm_disk_size
    interface    = "scsi0"
    datastore_id = "local-lvm"
    iothread     = true
  }

  dynamic "network_device" {
    for_each = var.vm_network_devices
    content {
      bridge = network_device.value.bridge
      model  = network_device.value.model
      mtu    = network_device.value.mtu
    }
  }

  dynamic "clone" {
    for_each = var.vm_template_id != null ? [1] : []
    content {
      vm_id = var.vm_template_id
      full  = false
    }
  }
  agent {
    enabled = var.enable_agent
  }
  dynamic "initialization" {
    for_each = var.enable_cloud_init ? [1] : []
    content {
      interface = "ide2"
      ip_config {
        ipv4 {
          address = var.cloud_init_ipv4_address
          gateway = var.cloud_init_ipv4_gateway
        }
      }
      dns {
        servers = var.cloud_init_dns_servers
      }

      user_account {
        username = var.cloud_init_user_account_username
        keys     = var.cloud_init_user_account_public_keys
      }
    }
  }

  tags = var.tags
}

