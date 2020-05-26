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

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v2.0.24"
}

inputs = {
  name                = "bonus"
  resource_group_name = dependency.resource_group.outputs.resource_name

  app_service_plan_info = {
    kind     = "elastic"
    sku_tier = "ElasticPremium"
    sku_size = "EP3"
  }

  runtime_version = "~3"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "node"
    WEBSITE_NODE_DEFAULT_VERSION   = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    FUNCTIONS_WORKER_PROCESS_COUNT = 4
    NODE_ENV                       = "production"

    # No downtime on slots swap
    WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG = 1

    # DNS configuration to use private dns zones
    WEBSITE_DNS_SERVER     = "168.63.129.16"
    WEBSITE_VNET_ROUTE_ALL = 1

    COSMOSDB_BONUS_URI           = dependency.cosmosdb_bonus_account.outputs.endpoint
    COSMOSDB_BONUS_KEY           = dependency.cosmosdb_bonus_account.outputs.primary_master_key
    COSMOSDB_BONUS_DATABASE_NAME = dependency.cosmosdb_bonus_database.outputs.name

    // Keepalive fields are all optionals
    FETCH_KEEPALIVE_ENABLED             = "true"
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL   = "110000"
    FETCH_KEEPALIVE_MAX_SOCKETS         = "40"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_appbackend.outputs.id
  ]

  subnet_id = dependency.subnet.outputs.id
}
