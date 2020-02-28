dependency "resource_group" {
  config_path = "../resource_group"
}

dependency "virtual_network" {
  config_path = "../../common/virtual_network"
}

dependency "application_insights" {
  config_path = "../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../common/key_vault"
}

// TODO: Rename with apim
dependency "apim" {
  config_path = "../../common/apim"
}

dependency "cosmosdb_account" {
  config_path = "../cosmosdb/account"
}

dependency "cosmosdb_database" {
  config_path = "../cosmosdb/database"
}

dependency "storage_account" {
  config_path = "../storage/account"
}

dependency "storage_container_message-content" {
  config_path = "../storage/container_message-content"
}

dependency "storage_table_subscriptionsfeedbyday" {
  config_path = "../storage/table_subscriptionsfeedbyday"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v0.0.22"
}

inputs = {
  name                = "admin"
  resource_group_name = dependency.resource_group.outputs.resource_name

  virtual_network_info = {
    resource_group_name   = dependency.virtual_network.outputs.resource_group_name
    name                  = dependency.virtual_network.outputs.resource_name
    subnet_address_prefix = "10.0.202.0/24"
  }

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    WEBSITE_HTTPSCALEV2_ENABLED  = "1"

    COSMOSDB_URI                 = dependency.cosmosdb_account.outputs.endpoint
    COSMOSDB_KEY                 = dependency.cosmosdb_account.outputs.primary_master_key
    COSMOSDB_NAME                = dependency.cosmosdb_database.outputs.name
    // TODO: Rename to STORAGE_CONNECTION_STRING
    QueueStorageConnection       = dependency.storage_account.outputs.primary_connection_string
    MESSAGE_CONTAINER_NAME       = dependency.storage_container_message-content.outputs.name
    // TODO Rename to SUBSCRIPTIONSFEEDBYDAY_TABLE_NAME
    SUBSCRIPTIONS_FEED_TABLE     = dependency.storage_table_subscriptionsfeedbyday.outputs.name
    MAIL_FROM                    = "IO - l'app dei servizi pubblici <no-reply@io.italia.it>"
    LOGOS_URL                    = "https://assets.dev.io.italia.it"
    FUNCTION_APP_EDIT_MODE       = "readonly"
    FUNCTIONS_EXTENSION_VERSION  = "~2"
    // TODO: Rename with apim
    AZURE_APIM                   = dependency.apim.outputs.name
    AZURE_APIM_RESOURCE_GROUP    = dependency.apim.outputs.resource_group_name
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      MAILUP_USERNAME             = "common-MAILUP-USERNAME"
      MAILUP_SECRET               = "common-MAILUP-SECRET"
      WEEBHOOK_CHANNEL_URL        = "app-backend-WEBHOOK-CHANNEL-URL"
      // TODO Rename secrets keys
      StorageConnection           = "fn2-commons-sa-appdata-primary-connection-string"
      LogosStorageConnection      = "fn2-commons-sa-assets-primary-connection-string"
      SERVICE_PRINCIPAL_CLIENT_ID = "fn2-admin-service-principal-client-id"
      SERVICE_PRINCIPAL_SECRET    = "fn2-admin-service-principal-secret"
      SERVICE_PRINCIPAL_TENANT_ID = "fn2-admin-service-principal-tenant-id"
      AZURE_SUBSCRIPTION_ID       = "fn2-admin-azure-subscription-id"
    }
  }
}
