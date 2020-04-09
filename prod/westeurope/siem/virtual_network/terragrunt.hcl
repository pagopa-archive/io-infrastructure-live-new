dependency "resource_group_siem" {
  config_path = "../resource_group"

  mock_outputs = {
    resource_group_name = "fixture"
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_virtual_network?ref=v2.0.1"
}

inputs = {
  name                = "siem"
  resource_group_name = dependency.resource_group_siem.outputs.resource_name
  address_space       = ["10.10.0.0/22"]
}
