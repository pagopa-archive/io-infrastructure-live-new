dependency "resource_group" {
  config_path = "../resource_group"

  mock_outputs = {
    resource_name = "mock_resource_name"
  }

}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_dns_zone?ref=v2.1.25"
}

inputs = {
  name                = "io.italia.it"
  resource_group_name = dependency.resource_group.outputs.resource_name
}
