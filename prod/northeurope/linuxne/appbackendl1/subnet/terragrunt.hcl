# Common
dependency "virtual_network" {
  config_path = "../../../../westeurope/common/virtual_network"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_subnet?ref=v2.1.0"
}

inputs = {
  name = "appbackendl1ne"

  resource_group_name  = dependency.virtual_network.outputs.resource_group_name
  virtual_network_name = dependency.virtual_network.outputs.resource_name
  address_prefix       = "10.0.162.0/24"

  delegation = {
    name = "default"

    service_delegation = {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  service_endpoints = [
    "Microsoft.Web"
  ]
}
