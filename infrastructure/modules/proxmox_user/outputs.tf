output "user_id" {
  value = proxmox_virtual_environment_user.this.user_id
}

output "token_key" {
  value = var.user_token_name != null ? proxmox_user_token.this.token_name : null
}

output "token_secret" {
  value = var.user_token_name != null ? proxmox_user_token.this.value : null
}
