locals {
  local_public_key = trimspace(file("~/.ssh/id_ed25519.pub"))
}

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
  source = "../../modules/proxmox_compute/"

  id        = 200
  name      = "opnsense"
  node_name = "pve1"
  type      = "vm"
  tags      = ["firewall"]

  compute = {
    cpu_cores        = 2
    memory_dedicated = 4096
  }
  storage = [{
    size         = 56
    interface    = "scsi0"
    datastore_id = "local-lvm"
    iothread     = true
  }]
  network = [
    {
      bridge = "vmbr0"
      model  = "virtio"
      mtu    = "1500"
    },
    {
      bridge = "vmbr1"
      model  = "virtio"
      mtu    = "1500"
    }
  ]

  vm_setting = {
    enable_agent = false
    os_type      = "other"
  }
}

module "pve01_box_step_ca" {
  source = "../../modules/proxmox_compute"

  id        = 201
  name      = "step-ca"
  node_name = "pve1"
  type      = "lxc"
  tags      = ["ca"]

  compute = {
    cpu_cores        = 1
    memory_dedicated = 512
    memory_swap      = 512
  }
  storage = [{
    size = 4
  }]
  network = [{
    name   = "eth0"
    model  = "virtio"
    bridge = "vmbr1"
  }]

  init = {
    enabled           = true
    ipv4_address      = "192.168.10.5/24"
    ipv4_gateway      = "192.168.10.1"
    dns_servers       = ["192.168.10.1"]
    user_account_keys = [local.local_public_key]
  }

  lxc_setting = {
    os_type       = "debian"
    template_id   = "local:vztmpl/debian-13-standard_13.6-1_amd64.tar.zst"
    unprivileged  = true
    start_on_boot = true
    features = {
      nesting = true
    }
  }
}

# Configure PVE 02 
# Workloads:
# - 1 Gitea 2 cores / 4 GB 
# - 1 k8s controlplane 2 cores / 4GB 
# - 2 k8s Worker 4 cores / 8 GB 
module "pve02_control_plane" {
  source = "../../modules/proxmox_compute"

  count     = 1
  id        = 150 + count.index
  name      = "control-plane-${count.index + 1}"
  node_name = "pve2"
  type      = "vm"
  tags      = ["control_plane"]

  compute = {
    cpu_cores        = 4
    memory_dedicated = 8192
  }
  storage = [{
    size         = 50
    interface    = "scsi0"
    datastore_id = "local-lvm"
    iothread     = true
  }]
  network = [{
    bridge = "vmbr0"
    model  = "virtio"
    mtu    = 1500
  }]

  init = {
    enabled           = true
    ipv4_address      = "192.168.10.5${count.index + 1}/24"
    ipv4_gateway      = "192.168.10.1"
    dns_servers       = ["1.1.1.1", "8.8.8.8"]
    user_account_name = "k-u74n"
    user_account_keys = [local.local_public_key]
  }
  vm_setting = {
    enable_agent = true
    os_type      = "l26"
    template = {
      id        = data.proxmox_vm.pve02_debian_13_template.id
      node_name = "pve2"
    }
  }
}

module "pve02_worker_node" {
  source = "../../modules/proxmox_compute"

  count     = 1
  id        = 160 + count.index
  name      = "worker-node-${count.index + 1}"
  node_name = "pve2"
  type      = "vm"
  tags      = ["worker"]

  compute = {
    cpu_cores        = 8
    memory_dedicated = 16384
  }
  storage = [{
    size         = 50
    interface    = "scsi0"
    datastore_id = "local-lvm"
    iothread     = true
  }]
  network = [{
    bridge = "vmbr0"
    model  = "virtio"
    mtu    = 1500
  }]

  init = {
    enabled           = true
    ipv4_address      = "192.168.10.6${count.index + 1}/24"
    ipv4_gateway      = "192.168.10.1"
    dns_servers       = ["1.1.1.1", "8.8.8.8"]
    user_account_name = "k-u74n"
    user_account_keys = [local.local_public_key]
  }
  vm_setting = {
    enable_agent = true
    os_type      = "l26"
    template = {
      id        = data.proxmox_vm.pve02_debian_13_template.id
      node_name = "pve2"
    }
  }
}

# Configure PVE 03
