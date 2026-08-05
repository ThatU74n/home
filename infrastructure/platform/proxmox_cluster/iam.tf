# resource "proxmox_virtual_environment_role" "name" {
#   role_id = ""
#
#   privileges = [
#     "Realm.AllocateUser"
#
#   ]
# }
#
# module "svc_acc_terraform" {
#   source          = "../../modules/proxmox_user"
#   user_id         = "terraform"
#   user_token_name = "automation"
#   acl = [
#     {
#       path    = ""
#       role_id = ""
#     }
#
#   ]
# }
#
# module "svc_acc_ansible" {
#   source          = "../../modules/proxmox_user"
#   user_id         = "ansible"
#   user_token_name = "automation"
#   acl = [
#     {
#       path    = "/vms"
#       role_id = "PVEVMUser"
#     }
#
#   ]
# }
