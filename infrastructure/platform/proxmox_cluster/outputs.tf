output "opnsense_iso_ids" {
  value = {
    for key, value in proxmox_download_file.opnsense_iso : key => value.id
  }
}

output "debian_iso_ids" {
  value = {
    for key, value in proxmox_download_file.debian_13_iso : key => value.id
  }
}
