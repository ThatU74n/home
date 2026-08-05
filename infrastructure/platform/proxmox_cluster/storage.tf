resource "proxmox_download_file" "opnsense_iso" {
  for_each = toset(["pve1"])

  content_type            = "iso"
  datastore_id            = "local"
  node_name               = each.value
  decompression_algorithm = "bz2"
  overwrite               = true

  url       = "https://pkg.opnsense.org/releases/26.7/OPNsense-26.7-dvd-amd64.iso.bz2"
  file_name = "OPNsense-26.7-dvd-amd64.iso"
}

resource "proxmox_download_file" "debian_13_iso" {
  for_each = toset(["pve2"])

  content_type = "iso"
  datastore_id = "local"
  node_name    = each.value
  overwrite    = true

  url       = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.6.0-amd64-netinst.iso"
  file_name = "debian-13.6.0-adm64-netinst.iso"
}

