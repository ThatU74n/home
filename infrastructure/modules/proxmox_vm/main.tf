resource "proxmox_virtual_environment_vm" "this" {
  name      = var.proxmox_vm_name
  node_name = "pve"
  vm_id     = var.proxmox_vm_id
  operating_system {
    type = "l26"
  }
  cpu {
    cores = var.proxmox_vm_cpu_cores
    type  = "host"
  }
  memory {
    dedicated = var.proxmox_vm_memory_dedicated
  }
  disk {
    size         = var.proxmox_vm_disk_size
    interface    = "scsi0"
    datastore_id = "local-lvm"
    iothread     = true

  }
  network_device {
    model  = "virtio"
    bridge = "vmbr0"
    mtu    = "1500"
  }
  clone {
    vm_id = var.proxmox_vm_template_id
    full  = false
  }
  agent {
    enabled = true
  }
  initialization {
    ip_config {
      ipv4 {
        address = var.cloud_init_ipv4_address
        gateway = var.cloud_init_ipv4_gateway
      }
    }
    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }
    user_account {
      username = var.cloud_init_user_account_username
      keys     = var.cloud_init_user_account_public_keys
    }
    # Additional configurations
  }
  tags = var.tags
}



