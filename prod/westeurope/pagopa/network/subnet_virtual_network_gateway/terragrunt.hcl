dependency "resource_group" {
  config_path = "../../resource_group"

  mock_outputs = {
    resource_group_name = "fixture"
  }
}

dependency "virtual_network" {
  config_path = "../virtual_network"

  mock_outputs = {
    resource_group_name = "fixture"
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_subnet?ref=update-azurerm-v2.87.0"
}

# Important !!
# It is mandatory that the associated subnet is named GatewaySubnet.
# Therefore, each virtual network can contain at most a single Virtual Network Gateway.
# https://www.terraform.io/docs/providers/azurerm/r/virtual_network_gateway.html

inputs = {
  name                 = "GatewaySubnet"
  virtual_network_name = dependency.virtual_network.outputs.resource_name
  resource_group_name  = dependency.resource_group.outputs.resource_name
  address_prefix       = "10.250.1.160/28"
}
