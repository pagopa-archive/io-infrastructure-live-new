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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_redis_cache?ref=v0.0.23"
}

inputs = {
  name                = "cache"
  resource_group_name = dependency.resource_group_common.outputs.resource_name

  capacity              = 2
  family                = "C"
  sku_name              = "Standard"
  enable_non_ssl_port   = false
}
