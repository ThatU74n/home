mock_provider "proxmox" {}

run "required_cloud_init_when_enable_cloud_init_is_true" {
  command = plan

  variables {
    node_name         = "test"
    vm_name           = "test"
    vm_id             = 1
    vm_template_id    = 1
    enable_cloud_init = true
    enable_agent      = false

    cloud_init_dns_servers              = null
    cloud_init_user_account_public_keys = null
  }

  expect_failures = [
    var.cloud_init_ipv4_address,
    var.cloud_init_ipv4_gateway,
    var.cloud_init_dns_servers,
    var.cloud_init_user_account_username,
    var.cloud_init_user_account_public_keys
  ]
}

run "valid_ip_v4_address" {
  command = plan

  variables {
    node_name         = "test"
    vm_name           = "test"
    vm_id             = 1
    vm_template_id    = 1
    enable_cloud_init = true
    enable_agent      = false

    cloud_init_ipv4_address             = "123.123.123.123/33"
    cloud_init_ipv4_gateway             = "257.257.257.257/24"
    cloud_init_dns_servers              = ["1.1.1.1", "8.8.8.8"]
    cloud_init_user_account_username    = "username"
    cloud_init_user_account_public_keys = [""]
  }

  expect_failures = [
    var.cloud_init_ipv4_address,
    var.cloud_init_ipv4_gateway
  ]
}

