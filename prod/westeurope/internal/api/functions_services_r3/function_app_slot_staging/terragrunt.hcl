dependency "function_app" {
  config_path = "../function_app"
}

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

dependency "storage_container_message-content" {
  config_path = "../../storage/container_message-content"
}

dependency "storage_table_subscriptionsfeedbyday" {
  config_path = "../../storage/table_subscriptionsfeedbyday"
}

# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

dependency "subnet_apimapi" {
  config_path = "../../../api/apim/subnet"
}

dependency "subnet_fn3eucovidcert" {
  config_path = "../../../../eucovidcert/functions_eucovidcert/subnet"
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

dependency "subnet_azure_devops" {
  config_path = "../../../../common/subnet_azure_devops"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app_slot?ref=v4.0.0"
}

locals {
  commonvars                   = read_terragrunt_config(find_in_parent_folders("commonvars.hcl"))
  opt_out_email_switch_date    = local.commonvars.locals.opt_out_email_switch_date
  ff_opt_in_email_enabled      = local.commonvars.locals.ff_opt_in_email_enabled
}

inputs = {
  name                                               = "staging"
  resource_group_name                                = dependency.resource_group.outputs.resource_name
  function_app_name                                  = dependency.function_app.outputs.name
  function_app_resource_name                         = dependency.function_app.outputs.resource_name
  app_service_plan_id                                = dependency.function_app.outputs.app_service_plan_id
  storage_account_name                               = dependency.function_app.outputs.storage_account.name
  storage_account_access_key                         = dependency.function_app.outputs.storage_account.primary_access_key
  storage_account_durable_function_connection_string = dependency.function_app.outputs.storage_account_durable_function.primary_connection_string

  runtime_version = "~3"

  health_check_path = "api/info"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "node"
    WEBSITE_NODE_DEFAULT_VERSION   = "14.16.0"
    FUNCTIONS_WORKER_PROCESS_COUNT = 4
    NODE_ENV                       = "production"

    PROCESSING_MESSAGE_CONTAINER_NAME       = "processing-messages"
    MESSAGE_CREATED_QUEUE_NAME              = "message-created"
    MESSAGE_PROCESSED_QUEUE_NAME            = "message-processed"
    NOTIFICATION_CREATED_EMAIL_QUEUE_NAME   = "notification-created-email"
    NOTIFICATION_CREATED_WEBHOOK_QUEUE_NAME = "notification-created-webhook"

    COSMOSDB_URI  = dependency.cosmosdb_account.outputs.endpoint
    COSMOSDB_KEY  = dependency.cosmosdb_account.outputs.primary_master_key
    COSMOSDB_NAME = dependency.cosmosdb_database.outputs.name

    MESSAGE_CONTENT_STORAGE_CONNECTION_STRING = dependency.storage_account.outputs.primary_connection_string
    MESSAGE_CONTAINER_NAME                    = dependency.storage_container_message-content.outputs.name
    
    SUBSCRIPTION_FEED_STORAGE_CONNECTION_STRING = dependency.storage_account.outputs.primary_connection_string
    SUBSCRIPTIONS_FEED_TABLE                    = dependency.storage_table_subscriptionsfeedbyday.outputs.name

    MAIL_FROM = "IO - l'app dei servizi pubblici <no-reply@io.italia.it>"
    // we keep this while we wait for new app version to be deployed
    MAIL_FROM_DEFAULT = "IO - l'app dei servizi pubblici <no-reply@io.italia.it>"

    // Keepalive fields are all optionals
    FETCH_KEEPALIVE_ENABLED             = "true"
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL   = "110000"
    FETCH_KEEPALIVE_MAX_SOCKETS         = "40"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"

    IO_FUNCTIONS_ADMIN_BASE_URL       = "http://api-app.internal.io.pagopa.it"
    APIM_BASE_URL                     = "https://api-app.internal.io.pagopa.it"
    DEFAULT_SUBSCRIPTION_PRODUCT_NAME = "io-services-api"

    // setting to true all the webhook message content will be disabled
    FF_DISABLE_WEBHOOK_MESSAGE_CONTENT = "true"

    OPT_OUT_EMAIL_SWITCH_DATE = local.opt_out_email_switch_date
    FF_OPT_IN_EMAIL_ENABLED   = local.ff_opt_in_email_enabled

    # setting to allow the retrieve of the payment status from payment-updater
    FF_PAYMENT_STATUS_ENABLED = "true"

    // minimum app version that introduces read status opt-out
    // NOTE: right now is set to a non existing version, since it's not yet deployed
    // This way we can safely deploy fn-services without enabling ADVANCED functionalities
    MIN_APP_VERSION_WITH_READ_AUTH = "2.14.0"


    WEBSITE_PROACTIVE_AUTOHEAL_ENABLED = "True"
    # AzureFunctionsJobHost__extensions__durableTask__storageProvider__partitionCount = "16"

    # Disabled functions on slot - trigger, queue and timer
    # mark this configurations as slot settings
    "AzureWebJobs.CreateNotification.Disabled"     = "1"
    "AzureWebJobs.EmailNotification.Disabled"      = "1"
    "AzureWebJobs.OnFailedProcessMessage.Disabled" = "1"
    "AzureWebJobs.ProcessMessage.Disabled"         = "1"
    "AzureWebJobs.WebhookNotification.Disabled"    = "1"

    TTL_FOR_USER_NOT_FOUND = 300 // 5 minutes 
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      MAILUP_USERNAME                        = "common-MAILUP-USERNAME"
      MAILUP_SECRET                          = "common-MAILUP-SECRET"
      WEBHOOK_CHANNEL_URL                    = "appbackend-WEBHOOK-CHANNEL-URL"
      SANDBOX_FISCAL_CODE                    = "io-SANDBOX-FISCAL-CODE"
      EMAIL_NOTIFICATION_SERVICE_BLACKLIST   = "io-EMAIL-SERVICE-BLACKLIST-ID"
      WEBHOOK_NOTIFICATION_SERVICE_BLACKLIST = "io-NOTIFICATION-SERVICE-BLACKLIST-ID"
      IO_FUNCTIONS_ADMIN_API_TOKEN           = "apim-IO-SERVICE-KEY"
      APIM_SUBSCRIPTION_KEY                  = "apim-IO-SERVICE-KEY"
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_apimapi.outputs.id,
    dependency.subnet_fn3eucovidcert.outputs.id,
    dependency.subnet_azure_devops.outputs.id,
  ]

  subnet_id       = dependency.subnet.outputs.id
  function_app_id = dependency.function_app.outputs.id
}
