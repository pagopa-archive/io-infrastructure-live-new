dependency "subnet" {
  config_path = "../subnet"
}

dependency "storage_account" {
  config_path = "../storage_account"
}

dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_redis_cache?ref=v3.0.0"
}

inputs = {
  name                  = "common"
  resource_group_name   = dependency.resource_group.outputs.resource_name
  capacity              = 2
  shard_count           = 3
  enable_non_ssl_port   = false
  subnet_id             = dependency.subnet.outputs.id
  family                = "P"
  sku_name              = "Premium"
  enable_authentication = true

  backup_configuration = {
    frequency                 = 60
    max_snapshot_count        = 1
    storage_connection_string = dependency.storage_account.outputs.primary_blob_connection_string
  }

  patch_schedules = [{
    day_of_week    = "Sunday"
    start_hour_utc = 23
    },
    {
      day_of_week    = "Monday"
      start_hour_utc = 23
    },
    {
      day_of_week    = "Tuesday"
      start_hour_utc = 23
    },
    {
      day_of_week    = "Wednesday"
      start_hour_utc = 23
    },
    {
      day_of_week    = "Thursday"
      start_hour_utc = 23
    },
  ]

  lock = {
    name       = "redis-common"
    lock_level = "CanNotDelete"
    notes      = null
  }

}
