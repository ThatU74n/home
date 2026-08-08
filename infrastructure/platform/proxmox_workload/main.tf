locals {
  local_public_key = trimspace(file("~/.ssh/id_ed25519.pub"))
}

# data "terraform_remote_state" "proxmox_cluster" {
#   backend = "s3"
#   config = {
#     bucket = "terraform-u74n"
#     key    = "proxmox-cluster/terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }

# Customized OPNSense template with automation user
# data "proxmox_virtual_environment_vm" "pve01_opnsense_template" {
#   node_name = "pve01"
#   vm_id     = 100
# }

# data "proxmox_virtual_environment_vm" "pve01_debian_13_template" {
#   node_name = "pve01"
#   vm_id     = 105
# }

data "proxmox_vm" "pve02_debian_13_template" {
  id        = 501
  node_name = "pve2"
}


# Configure PVE 01 
# Workloads:  
#   - 1 OPNSense 
#   - 1 k8s worker  4GB 
module "pve01_box_opnsense" {
  source    = "../../modules/proxmox_vm"
  node_name = "pve1"
  id        = 200

  is_clone_from_template = false
  os_type                = "other"

  vm_name             = "opnsense"
  vm_cpu_cores        = 2
  vm_memory_dedicated = 4096
  vm_disk_size        = 56
  vm_network_devices = [
    {
      # WAN
      bridge = "vmbr0"
      model  = "virtio"
      mtu    = "1500"
    },
    {
      # LAN
      bridge = "vmbr1"
      model  = "virtio"
      mtu    = "1500"
    }
  ]

  enable_agent      = false
  enable_cloud_init = false

  tags = ["firewall"]
}

module "pve01_box_step_ca" {
  source    = "../../modules/proxmox_lxc"
  node_name = "pve1"
  name      = "step-ca"
  id        = 201

  lxc_type             = "debian"
  lxc_template_file_id = "local:vztmpl/debian-13-standard_13.6-1_amd64.tar.zst"

  lxc_cpu_cores                = 1
  lxc_disk_size                = 4
  lxc_memory_dedicated         = 512
  lxc_memory_swap              = 512
  lxc_network_interface_name   = "eth0"
  lxc_network_interface_bridge = "vmbr1"
  lxc_network_ipv4_address     = "192.168.10.5/24"
  lxc_network_ipv4_gateway     = "192.168.10.1"
  lxc_network_dns_server       = ["192.168.10.1"]

  init_user_account_public_keys = [local.local_public_key]

  tags = ["ca"]
}

# Configure PVE 02 
# Workloads:
# - 1 Gitea 2 cores / 4 GB 
# - 1 k8s controlplane 2 cores / 4GB 
# - 2 k8s Worker 4 cores / 8 GB 
module "pve02_control_plane" {
  source    = "../../modules/proxmox_vm"
  node_name = "pve2"
  count     = 1
  id        = 150 + count.index


  is_clone_from_template = true
  vm_template_id         = data.proxmox_vm.pve02_debian_13_template.id
  os_type                = "l26"

  vm_name             = "control-plane-${count.index + 1}"
  vm_cpu_cores        = 4
  vm_memory_dedicated = 8192
  vm_disk_size        = 50

  enable_agent                        = true
  enable_cloud_init                   = true
  cloud_init_ipv4_address             = "192.168.10.5${count.index + 1}/24"
  cloud_init_ipv4_gateway             = "192.168.10.1"
  cloud_init_user_account_username    = "k-u74n"
  cloud_init_user_account_public_keys = [local.local_public_key]

  tags = ["control_plane"]
}

module "pve02_worker_node" {
  source    = "../../modules/proxmox_vm"
  node_name = "pve2"
  count     = 1
  id        = 160 + count.index


  is_clone_from_template = true
  vm_template_id         = data.proxmox_vm.pve02_debian_13_template.id
  os_type                = "l26"

  vm_name             = "worker-node-${count.index + 1}"
  vm_cpu_cores        = 8
  vm_memory_dedicated = 16384
  vm_disk_size        = 50

  enable_agent                        = true
  enable_cloud_init                   = true
  cloud_init_ipv4_address             = "192.168.10.6${count.index + 1}/24"
  cloud_init_ipv4_gateway             = "192.168.10.1"
  cloud_init_user_account_username    = "k-u74n"
  cloud_init_user_account_public_keys = [local.local_public_key]

  tags = ["worker"]
}



# Configure PVE 03
