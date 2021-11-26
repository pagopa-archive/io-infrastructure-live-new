/*
  DEPRECATED !!!
  Use instead: https://github.com/pagopa/io-infra
*/

dependency "resource_group" {
  config_path = "../resource_group"

}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_dns_zone?ref=v4.0.0"
}

inputs = {
  name                = "io.italia.it"
  resource_group_name = dependency.resource_group.outputs.resource_name
  environment         = "infra"
}
