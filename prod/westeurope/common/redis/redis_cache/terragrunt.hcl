dependency "subnet" {
  config_path = "../subnet"
}

dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_redis_cache?ref=v2.0.1"
}

inputs = {
  name                  = "common"
  resource_group_name   = dependency.resource_group.outputs.resource_name
  capacity              = 1
  shard_count           = 1
  enable_non_ssl_port   = false
  subnet_id             = dependency.subnet.outputs.id
  family                = "P"
  sku_name              = "Premium"
  enable_authentication = true

  // TODO: Enable backup
}
