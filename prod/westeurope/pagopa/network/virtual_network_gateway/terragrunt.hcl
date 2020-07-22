dependency "resource_group" {
  config_path = "../../resource_group"

  mock_outputs = {
    resource_group_name = "fixture"
  }
}

dependency "subnet_vngw" {
  config_path = "../subnet_virtual_network_gateway"

  mock_outputs = {
    reosurce_name       = "fixture"
    resource_group_name = "fixture"
  }
}

dependency "key_vault_common" {
  config_path = "../../../common/key_vault"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_virtual_network_gateway?ref=v2.0.33"
}

inputs = {
  name                        = "pagopa"
  public_ip_allocation_method = "Dynamic"
  public_ip_sku               = "Basic"
  subnet_id                   = dependency.subnet_vngw.outputs.id
  resource_group_name         = dependency.resource_group.outputs.resource_name

  ip_configurations = [{
    name                          = "vnetGatewayConfig"
    private_ip_address_allocation = "Dynamic"
  }]

  sku      = "VpnGw1"
  type     = "Vpn"
  vpn_type = "RouteBased"


  # Local Network Gateway
  local_network_gateway_name = "pagopa"
  gateway_address            = "185.91.56.6"
  gateway_address_space      = ["10.250.1.128/27"]
  bgp_settings               = []

  # Network Connection Gateway
  connection_type             = "IPsec"
  key_vault_id                = dependency.key_vault_common.outputs.id
  vpn_connection_sercret_name = "pagopa-VPN-SHARED-KEY"

}
