dependency "function_app" {
  config_path = "../function_app"
}

dependency "subnet" {
  config_path = "../subnet"
}

dependency "cosmosdb_bonus_account" {
  config_path = "../../cosmosdb_bonus/account"
}

dependency "cosmosdb_bonus_database" {
  config_path = "../../cosmosdb_bonus/database"
}

# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

dependency "subnet_appbackend" {
  config_path = "../../../appbackend/subnet"
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

dependency "storage_account_bonus" {
  config_path = "../../storage_bonus/account"
}

dependency "storage_table_bonusleasebindings" {
  config_path = "../../storage_bonus/table_bonusleasebindings"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app_slot?ref=v2.0.37"
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

  pre_warmed_instance_count = 5

  auto_swap_slot_name = "production"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "node"
    WEBSITE_NODE_DEFAULT_VERSION   = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    FUNCTIONS_WORKER_PROCESS_COUNT = 4
    NODE_ENV                       = "production"

    # DNS configuration to use private dns zones
    // TODO: Use private dns zone https://www.pivotaltracker.com/story/show/173102678
    //WEBSITE_DNS_SERVER     = "168.63.129.16"
    //WEBSITE_VNET_ROUTE_ALL = 1

    COSMOSDB_BONUS_URI           = dependency.cosmosdb_bonus_account.outputs.endpoint
    COSMOSDB_BONUS_KEY           = dependency.cosmosdb_bonus_account.outputs.primary_master_key
    COSMOSDB_BONUS_DATABASE_NAME = dependency.cosmosdb_bonus_database.outputs.name
    COSMOSDB_CONNECTION_STRING   = dependency.cosmosdb_bonus_account.outputs.connection_strings[0]

    // Keepalive fields are all optionals
    FETCH_KEEPALIVE_ENABLED             = "true"
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL   = "110000"
    FETCH_KEEPALIVE_MAX_SOCKETS         = "40"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"

    SLOT_TASK_HUBNAME = "StagingTaskHub"

    BONUS_LEASE_BINDINGS_TABLE_NAME = dependency.storage_table_bonusleasebindings.outputs.name

    # Storage account connection string:
    BONUS_STORAGE_CONNECTION_STRING = dependency.storage_account_bonus.outputs.primary_connection_string

    SERVICES_API_URL = "http://api-internal.io.italia.it/"

    # Disabled functions on slot
    #"AzureWebJobs.FunctionName.Disabled" = "1"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      INPS_SERVICE_CERT = "io-INPS-BONUS-CERT"
      INPS_SERVICE_KEY  = "io-INPS-BONUS-KEY"

      ADE_SERVICE_CERT = "io-ADE-BONUS-CERT"
      ADE_SERVICE_KEY  = "io-ADE-BONUS-KEY"
      ADE_HMAC_SECRET  = "io-ADE-HMAC-SECRET"

      INPS_SERVICE_ENDPOINT = "io-INPS-BONUS-ENDPOINT"
      ADE_SERVICE_ENDPOINT  = "io-ADE-BONUS-ENDPOINT"
      SERVICES_API_KEY      = "apim-BONUSVACANZE-SERVICE-KEY"
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_appbackend.outputs.id
  ]

  subnet_id       = dependency.subnet.outputs.id
  function_app_id = dependency.function_app.outputs.id
}
