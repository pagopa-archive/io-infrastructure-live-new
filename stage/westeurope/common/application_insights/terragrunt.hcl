dependency "resource_group_common" {
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_application_insights?ref=v0.0.3"
}

inputs = {
  name                = "common"
  resource_group_name = dependency.resource_group_common.outputs.resource_name
}
