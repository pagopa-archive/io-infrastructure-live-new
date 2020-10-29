dependency "resource_group" {
  config_path = "../resource_group"
}

dependency "network_ddos_protection_plan" {
  config_path = "../../common/network_ddos_protection_plan"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_virtual_network?ref=v2.1.5"
}

inputs = {
  name                = "support"
  resource_group_name = dependency.resource_group.outputs.resource_name
  address_space       = ["10.20.0.0/24"]

  ddos_protection_plan = {
    id     = dependency.network_ddos_protection_plan.outputs.id
    enable = true
  }
}
