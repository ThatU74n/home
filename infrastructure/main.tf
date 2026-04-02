locals {
  local_public_key = trimspace(file("~/.ssh/id_ed25519.pub"))
}

# OS Template 
data "proxmox_virtual_environment_vm" "debian_13_template" {
  node_name = "pve"
  vm_id     = 100
}

module "gitea_vm" {
  source = "./modules/proxmox_vm"

  proxmox_vm_template_id = data.proxmox_virtual_environment_vm.debian_13_template.vm_id

  proxmox_vm_name             = "gitea-server"
  proxmox_vm_id               = 200
  proxmox_vm_cpu_cores        = 2
  proxmox_vm_memory_dedicated = 4096
  proxmox_vm_disk_size        = 25

  cloud_init_ipv4_address             = "192.168.1.20/24"
  cloud_init_ipv4_gateway             = "192.168.1.1"
  cloud_init_user_account_username    = "gitea"
  cloud_init_user_account_public_keys = [local.local_public_key]

  tags = ["gitea"]
}


module "control_plane" {
  source = "./modules/proxmox_vm"
  count  = 1

  proxmox_vm_template_id = data.proxmox_virtual_environment_vm.debian_13_template.vm_id

  proxmox_vm_name             = "control-plane-${count.index + 1}"
  proxmox_vm_id               = 150 + count.index
  proxmox_vm_cpu_cores        = 4
  proxmox_vm_memory_dedicated = 8192
  proxmox_vm_disk_size        = 200

  cloud_init_ipv4_address             = "192.168.1.5${count.index + 1}/24"
  cloud_init_ipv4_gateway             = "192.168.1.1"
  cloud_init_user_account_username    = "k-u74n"
  cloud_init_user_account_public_keys = [local.local_public_key]

  tags = ["control_plane"]
}

module "worker_node" {
  source = "./modules/proxmox_vm"
  count  = 1

  proxmox_vm_template_id = data.proxmox_virtual_environment_vm.debian_13_template.vm_id

  proxmox_vm_name             = "worker-node-${count.index + 1}"
  proxmox_vm_id               = 160 + count.index
  proxmox_vm_cpu_cores        = 8
  proxmox_vm_memory_dedicated = 16384
  proxmox_vm_disk_size        = 300

  cloud_init_ipv4_address             = "192.168.1.6${count.index + 1}/24"
  cloud_init_ipv4_gateway             = "192.168.1.1"
  cloud_init_user_account_username    = "k-u74n"
  cloud_init_user_account_public_keys = [local.local_public_key]

  tags = ["worker"]
}
