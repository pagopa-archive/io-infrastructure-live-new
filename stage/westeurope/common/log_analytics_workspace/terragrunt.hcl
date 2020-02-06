# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_log_analytics_workspace?ref=v0.0.4"
}

dependency "resource_group" {
  config_path = "../resource_group"
}

inputs = {
  name                = "common"
  resource_group_name = dependency.resource_group.outputs.resource_name 
}
