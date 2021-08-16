# Common
dependency "virtual_network" {
  config_path = "../../virtual_network"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_subnet?ref=v3.0.3"
}

inputs = {
  name = "dns-forwarder"

  resource_group_name                            = dependency.virtual_network.outputs.resource_group_name
  virtual_network_name                           = dependency.virtual_network.outputs.resource_name
  address_prefix                                 = "10.0.252.0/29"
  enforce_private_link_endpoint_network_policies = true

  delegation = {
    name = "delegation"
    service_delegation = {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

}
