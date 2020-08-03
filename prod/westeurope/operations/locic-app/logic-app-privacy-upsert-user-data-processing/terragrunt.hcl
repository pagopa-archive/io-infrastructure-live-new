dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  # source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_logic_app?ref=v2.0.34"
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_logic_app?ref=174140521-add-logic-app-module"
}

inputs = {
  name                = "privacy-upsert-user-data-processing"
  resource_group_name = dependency.resource_group.outputs.resource_name
}
