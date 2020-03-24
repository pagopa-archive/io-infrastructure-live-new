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

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v0.0.46"
}

inputs = {
  name                = "admin"
  resource_group_name = dependency.resource_group.outputs.resource_name

  virtual_network_info = {
    resource_group_name   = dependency.virtual_network.outputs.resource_group_name
    name                  = dependency.virtual_network.outputs.resource_name
    subnet_address_prefix = "10.0.102.0/24"
  }

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    NODE_ENV                     = "production"

    COSMOSDB_URI  = dependency.cosmosdb_account.outputs.endpoint
    COSMOSDB_KEY  = dependency.cosmosdb_account.outputs.primary_master_key
    COSMOSDB_NAME = dependency.cosmosdb_database.outputs.name

    StorageConnection = dependency.storage_account.outputs.primary_connection_string

    AssetsStorageConnection = dependency.storage_account_assets.outputs.primary_connection_string

    AZURE_APIM                = "io-p-apim-api"
    AZURE_APIM_HOST           = "api-internal.io.italia.it"
    AZURE_APIM_RESOURCE_GROUP = "io-p-rg-internal"

  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      LOGOS_URL = "cdn-ASSETS-URL"

      AZURE_SUBSCRIPTION_ID = "common-AZURE-SUBSCRIPTION-ID"

      ADB2C_TENANT_ID  = "adb2c-TENANT-NAME"
      ADB2C_CLIENT_ID  = "devportal-CLIENT-ID"
      ADB2C_CLIENT_KEY = "devportal-CLIENT-SECRET"

      SERVICE_PRINCIPAL_CLIENT_ID = "ad-APPCLIENT-APIM-ID"
      SERVICE_PRINCIPAL_SECRET    = "ad-APPCLIENT-APIM-SECRET"
      SERVICE_PRINCIPAL_TENANT_ID = "common-AZURE-TENANT-ID"
    }
  }
}
