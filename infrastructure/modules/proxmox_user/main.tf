resource "proxmox_virtual_environment_user" "this" {
  user_id = var.user_id
  comment = "Provisioned by Terraform"
}

resource "proxmox_user_token" "this" {
  count = var.user_token_name != null ? 1 : 0

  user_id               = proxmox_virtual_environment_user.this.id
  token_name            = var.user_token_name
  comment               = "Provisioned by Terraform"
  privileges_separation = false
}

resource "proxmox_acl" "this" {
  for_each = { for acl in var.acl : "${acl.path}/${acl.role_id}" => acl }

  user_id   = proxmox_virtual_environment_user.this.id
  propagate = false
  path      = each.value.path
  role_id   = each.value.role_id
}
