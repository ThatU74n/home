locals {
  kea_dhcpv4_subnet = {
    subnet = "192.168.10.0/24"
    dns_servers = [
      "192.168.10.1",
      "1.1.1.1"
    ]
    pools = [
      "192.168.10.100 - 192.168.10.200"
    ]
  }
  unbound_host_overrides = [
    {
      description = "K8s Cilium gateway wild card"
      hostname    = "*"
      domain      = "k8s.u74n.internal"
      server      = "192.168.10.49"
      type        = "A"
    },
    {
      description = "OPNSense"
      hostname    = "opnsense"
      domain      = "u74n.internal"
      server      = "192.168.10.1"
      type        = "A"
    },
    {
      description = "CA Server"
      hostname    = "ca"
      domain      = "u74n.internal"
      server      = "192.168.10.5"
      type        = "A"
    },
    {
      description = "Proxmox"
      hostname    = "proxmox"
      domain      = "u74n.internal"
      server      = "192.168.10.11"
      type        = "A"
    },
    {
      description = "Gitea"
      hostname    = "gitea"
      domain      = "u74n.internal"
      server      = "192.168.10.20"
      type        = "A"
    }
  ]
  dns_zones = [
  ]
}

resource "opnsense_kea_dhcpv4_subnet" "opnsense_dhcp_pool" {
  description = "DHCP Pool"

  subnet      = local.kea_dhcpv4_subnet.subnet
  dns_servers = local.kea_dhcpv4_subnet.dns_servers
  pools       = local.kea_dhcpv4_subnet.pools
}

resource "opnsense_unbound_host_override" "opnsense_unbound_host_overrides" {
  for_each = { for record in local.unbound_host_overrides : "${record.hostname}.${record.domain}" => record }

  description = each.value.description
  hostname    = each.value.hostname
  domain      = each.value.domain
  server      = each.value.server
  type        = each.value.type
}

resource "opnsense_unbound_forward" "dns_zone" {
  for_each = { for record in local.dns_zones : "${record.domain}" => record }

  enabled     = each.value.enabled
  domain      = each.value.domain
  server_ip   = each.value.server_ip
  server_port = each.value.server_port
}
