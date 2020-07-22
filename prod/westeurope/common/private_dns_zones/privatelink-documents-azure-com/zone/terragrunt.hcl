# DNS Zone
dependency "resource_group" {
  config_path = "../../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_private_dns_zone?ref=v2.0.33"
}

inputs = {
  name                = "privatelink.documents.azure.com"
  resource_group_name = dependency.resource_group.outputs.resource_name
}
