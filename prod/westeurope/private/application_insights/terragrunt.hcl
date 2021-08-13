dependency "resource_group" {
  config_path = "../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_application_insights?ref=v3.0.3"
}

inputs = {
  name                = "private"
  resource_group_name = dependency.resource_group.outputs.resource_name
}
