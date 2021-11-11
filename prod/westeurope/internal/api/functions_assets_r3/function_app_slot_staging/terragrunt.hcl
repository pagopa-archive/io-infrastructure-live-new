dependency "function_app" {
  config_path = "../function_app"
}

dependency "cosmosdb_account" {
  config_path = "../../cosmosdb/account"
}

dependency "cosmosdb_database" {
  config_path = "../../cosmosdb/database"
}

dependency "storage_account" {
  config_path = "../../storage/account"
}

dependency "storage_account_assets" {
  config_path = "../../../../common/cdn/storage_account_assets"
}

dependency "storage_account_logs" {
  config_path = "../../../../operations/storage_account_logs/account"
}

# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

# Common
dependency "virtual_network" {
  config_path = "../../../../common/virtual_network"
}

dependency "application_insights" {
  config_path = "../../../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../../../common/key_vault"
}

dependency "subnet" {
  config_path = "../subnet"
}

dependency "subnet_azure_devops" {
  config_path = "../../../../common/subnet_azure_devops"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app_slot?ref=v4.0.1"
}

inputs = {
  name                       = "staging"
  resource_group_name        = dependency.resource_group.outputs.resource_name
  function_app_name          = dependency.function_app.outputs.name
  function_app_resource_name = dependency.function_app.outputs.resource_name
  app_service_plan_id        = dependency.function_app.outputs.app_service_plan_id
  storage_account_name       = dependency.function_app.outputs.storage_account.name
  storage_account_access_key = dependency.function_app.outputs.storage_account.primary_access_key

  runtime_version = "~3"

  health_check_path = "info"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "node"
    WEBSITE_NODE_DEFAULT_VERSION   = "14.16.0"
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    FUNCTIONS_WORKER_PROCESS_COUNT = 4
    NODE_ENV                       = "production"

    # DNS and VNET configuration to use private endpoint
    WEBSITE_DNS_SERVER     = "168.63.129.16"
    WEBSITE_VNET_ROUTE_ALL = 1

    APPINSIGHTS_SAMPLING_PERCENTAGE = "5"

    COSMOSDB_URI  = dependency.cosmosdb_account.outputs.endpoint
    COSMOSDB_KEY  = dependency.cosmosdb_account.outputs.primary_master_key
    COSMOSDB_NAME = dependency.cosmosdb_database.outputs.name

    CachedStorageConnection = dependency.storage_account.outputs.primary_connection_string

    AssetsStorageConnection = dependency.storage_account_assets.outputs.primary_connection_string

    // Keepalive fields are all optionals
    FETCH_KEEPALIVE_ENABLED             = "true"
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL   = "110000"
    FETCH_KEEPALIVE_MAX_SOCKETS         = "40"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"

    SLOT_TASK_HUBNAME           = "StagingTaskHub"
    STATIC_WEB_ASSETS_ENDPOINT  = dependency.storage_account_assets.outputs.primary_web_host
    STATIC_BLOB_ASSETS_ENDPOINT = dependency.storage_account_assets.outputs.primary_blob_host
    // Disable functions

    # this app settings is required to solve the issue:
    # https://github.com/terraform-providers/terraform-provider-azurerm/issues/10499
    WEBSITE_CONTENTSHARE = "staging-content"
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
