##########
## WARNING 
## THIS RESOURCE HAS BEEN DEPRECATED. USE INSTEAD https://github.com/pagopa/io-infra/blob/main/src/core/cgn.tf
#########

dependency "resource_group" {
  config_path = "../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_redis_cache?ref=v4.0.0"
}

inputs = {
  name                  = "cgn-std"
  resource_group_name   = dependency.resource_group.outputs.resource_name
  capacity              = 1
  enable_non_ssl_port   = false
  family                = "C"
  sku_name              = "Standard"
  enable_authentication = true

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
    name       = "redis-cgn"
    lock_level = "CanNotDelete"
    notes      = null
  }
}
