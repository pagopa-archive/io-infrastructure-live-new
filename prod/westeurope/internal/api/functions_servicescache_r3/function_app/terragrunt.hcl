dependency "subnet" {
  config_path = "../subnet"
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

dependency "storage_account_assets" {
  config_path = "../../../../common/cdn/storage_account_assets"
}

dependency "storage_container_user-data-download" {
  config_path = "../../storage_user-data-download/container_user-data-download"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v3.0.3"
}

locals {
  commonvars                   = read_terragrunt_config(find_in_parent_folders("commonvars.hcl"))
  app_insights_ips_west_europe = local.commonvars.locals.app_insights_ips_west_europe
}

inputs = {
  name                = "servicescache"
  resource_group_name = dependency.resource_group.outputs.resource_name

  resources_prefix = {
    function_app     = "fn3"
    app_service_plan = "fn3"
    storage_account  = "fn3"
  }

  runtime_version = "~3"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "12.18.0"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    NODE_ENV                     = "production"

    COSMOSDB_URI               = dependency.cosmosdb_account.outputs.endpoint
    COSMOSDB_KEY               = dependency.cosmosdb_account.outputs.primary_master_key
    COSMOSDB_NAME              = dependency.cosmosdb_database.outputs.name
    COSMOSDB_CONNECTION_STRING = dependency.cosmosdb_account.outputs.connection_strings[0]

    StorageConnection = dependency.storage_account.outputs.primary_connection_string

    AssetsStorageConnection = dependency.storage_account_assets.outputs.primary_connection_string

    // Disabled functions
    "AzureWebJobs.UpdateVisibleServicesCache.Disabled" = "1"
    "AzureWebJobs.UpdateVisibleServicesCacheOrchestrator.Disabled" = "1"
    "AzureWebJobs.UpdateVisibleServicesCacheActivity.Disabled" = "1"

    SLOT_TASK_HUBNAME = "ProductionTaskHub"

    # it is required due to this issue: https://github.com/terraform-providers/terraform-provider-azurerm/issues/10499
    # at the time we applied these chages the value is the following.
    WEBSITE_CONTENTSHARE = "io-p-fn3-admin-content"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
  ]

  allowed_ips = local.app_insights_ips_west_europe

  subnet_id = dependency.subnet.outputs.id
}
