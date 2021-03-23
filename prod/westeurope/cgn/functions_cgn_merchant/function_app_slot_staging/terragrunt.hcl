dependency "function_app" {
  config_path = "../function_app"
}

dependency "subnet" {
  config_path = "../subnet"
}

# cgn
dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "cosmosdb_cgn_account" {
  config_path = "../../cosmosdb/account"
}

dependency "cosmosdb_cgn_database" {
  config_path = "../../cosmosdb/database"
}

dependency "storage_account_cgn" {
  config_path = "../../storage_cgn/account"
}

dependency "redis" {
  config_path = "../../redis/redis_cache"
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

dependency "subnet_azure_devops" {
  config_path = "../../../common/subnet_azure_devops"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app_slot?ref=v3.0.3"
}

inputs = {
  name                       = "staging"
  resource_group_name        = dependency.resource_group.outputs.resource_name
  function_app_name          = dependency.function_app.outputs.name
  function_app_resource_name = dependency.function_app.outputs.resource_name
  app_service_plan_id        = dependency.function_app.outputs.app_service_plan_id
  storage_account_name       = dependency.function_app.outputs.storage_account.name
  storage_account_access_key = dependency.function_app.outputs.storage_account.primary_access_key


  app_service_plan_info = {
    kind     = "elastic"
    sku_tier = "ElasticPremium"
    sku_size = "EP1"
  }

  runtime_version = "~3"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "node"
    WEBSITE_NODE_DEFAULT_VERSION   = "12.18.0"
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    FUNCTIONS_WORKER_PROCESS_COUNT = 4
    NODE_ENV                       = "production"

    COSMOSDB_CGN_URI           = dependency.cosmosdb_cgn_account.outputs.endpoint
    COSMOSDB_CGN_KEY           = dependency.cosmosdb_cgn_account.outputs.primary_master_key
    COSMOSDB_CGN_DATABASE_NAME = dependency.cosmosdb_cgn_database.outputs.name
    COSMOSDB_CONNECTION_STRING = dependency.cosmosdb_cgn_account.outputs.connection_strings[0]
    // Keepalive fields are all optionals
    FETCH_KEEPALIVE_ENABLED             = "true"
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL   = "110000"
    FETCH_KEEPALIVE_MAX_SOCKETS         = "40"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"


    SLOT_TASK_HUBNAME = "ProductionTaskHub"

    # Storage account connection string:
    CGN_STORAGE_CONNECTION_STRING = dependency.storage_account_cgn.outputs.primary_connection_string

    # this app settings is required to solve the issue:
    # https://github.com/terraform-providers/terraform-provider-azurerm/issues/10499
    WEBSITE_CONTENTSHARE = "staging-content"

    // REDIS
    REDIS_URL      = dependency.redis.outputs.hostname
    REDIS_PORT     = dependency.redis.outputs.ssl_port
    REDIS_PASSWORD = dependency.redis.outputs.primary_access_key
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_azure_devops.outputs.id,
  ]

  subnet_id       = dependency.subnet.outputs.id
  function_app_id = dependency.function_app.outputs.id
}
