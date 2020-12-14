dependency "subnet" {
  config_path = "../subnet"
}

dependency "cosmosdb_api_account" {
  config_path = "../../../internal/api/cosmosdb/account"
}

dependency "cosmosdb_api_database" {
  config_path = "../../../internal/api/cosmosdb/database"
}

# Internal
dependency "resource_group" {
  config_path = "../../resource_group"
}

# Common
dependency "virtual_network" {
  config_path = "../../../common/virtual_network"
}

dependency "application_insights" {
  config_path = "../../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../../common/key_vault"
}

dependency "redis" {
  config_path = "../../../common/redis/redis_cache"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v2.1.10"
}

inputs = {
  name                = "pm"
  resource_group_name = dependency.resource_group.outputs.resource_name


  resources_prefix = {
    function_app     = "fn3"
    app_service_plan = "fn3"
    storage_account  = "fn3"
  }

  app_service_plan_info = {
    kind     = "elastic"
    sku_tier = "ElasticPremium"
    sku_size = "EP1"
  }

  runtime_version = "~3"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  pre_warmed_instance_count = 5

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "12.18.0"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    NODE_ENV                     = "production"

    QueueStorageConnection = dependency.storage_account.outputs.primary_connection_string
    
    // REDIS
    REDIS_URL      = dependency.redis.outputs.hostname
    REDIS_PORT     = dependency.redis.outputs.ssl_port
    REDIS_PASSWORD = dependency.redis.outputs.primary_access_key

    COSMOSDB_API_URI  = dependency.cosmosdb_api_account.outputs.endpoint
    COSMOSDB_API_KEY  = dependency.cosmosdb_api_account.outputs.primary_master_key
    COSMOSDB_API_NAME = dependency.cosmosdb_api_database.outputs.name

    SLOT_TASK_HUBNAME = "ProductionTaskHub"

    WEBSITE_VNET_ROUTE_ALL = 1
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id
  ]

  subnet_id = dependency.subnet.outputs.id
}
