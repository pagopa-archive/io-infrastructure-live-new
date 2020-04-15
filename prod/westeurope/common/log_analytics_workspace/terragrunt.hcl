dependency "resource_group" {
  config_path = "../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  #source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_log_analytics_workspace?ref=v2.0.1"
  source = "../../../../../io-infrastructure-modules-new/azurerm_log_analytics_workspace"
}

inputs = {
  name                = "common"
  resource_group_name = dependency.resource_group.outputs.resource_name
  retention_in_days   = 90
}
