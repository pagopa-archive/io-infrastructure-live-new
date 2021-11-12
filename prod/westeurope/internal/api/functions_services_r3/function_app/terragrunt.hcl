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

dependency "subnet_pendpoints" {
  config_path = "../../../../common/subnet_pendpoints"
}

dependency "private_dns_zone_blob" {
  config_path = "../../../../common/private_dns_zones/privatelink-blob-core-windows-net/zone"
}

dependency "private_dns_zone_queue" {
  config_path = "../../../../common/private_dns_zones/privatelink-queue-core-windows-net/zone"
}

dependency "private_dns_zone_table" {
  config_path = "../../../../common/private_dns_zones/privatelink-table-core-windows-net/zone"
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v3.0.17"
}

locals {
  commonvars                   = read_terragrunt_config(find_in_parent_folders("commonvars.hcl"))
  app_insights_ips_west_europe = local.commonvars.locals.app_insights_ips_west_europe
  opt_out_email_switch_date    = local.commonvars.locals.opt_out_email_switch_date
  ff_opt_in_email_enabled      = local.commonvars.locals.ff_opt_in_email_enabled
}

inputs = {
  name                = "services"
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

  # temp, disable advanced_threat_protection_enable asap
  storage_account_info = {
    account_tier                      = "Standard"
    account_replication_type          = "LRS"
    access_tier                       = "Hot"
    advanced_threat_protection_enable = true
  }

  runtime_version = "~3"
  
  health_check_path = "api/info"

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

    COSMOSDB_URI  = dependency.cosmosdb_account.outputs.endpoint
    COSMOSDB_KEY  = dependency.cosmosdb_account.outputs.primary_master_key
    COSMOSDB_NAME = dependency.cosmosdb_database.outputs.name
    // TODO: Rename to STORAGE_CONNECTION_STRING
    QueueStorageConnection = dependency.storage_account.outputs.primary_connection_string
    MESSAGE_CONTAINER_NAME = dependency.storage_container_message-content.outputs.name
    // TODO: Rename to SUBSCRIPTIONSFEEDBYDAY_TABLE_NAME
    SUBSCRIPTIONS_FEED_TABLE = dependency.storage_table_subscriptionsfeedbyday.outputs.name

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

    SLOT_TASK_HUBNAME = "ProductionTaskHub"

    IO_FUNCTIONS_ADMIN_BASE_URL       = "http://api-internal.io.italia.it"
    DEFAULT_SUBSCRIPTION_PRODUCT_NAME = "io-services-api"

    // setting to true all the webhook message content will be disabled
    FF_DISABLE_WEBHOOK_MESSAGE_CONTENT = "true"

    OPT_OUT_EMAIL_SWITCH_DATE = local.opt_out_email_switch_date
    FF_OPT_IN_EMAIL_ENABLED   = local.ff_opt_in_email_enabled

    # this app settings is required to solve the issue:
    # https://github.com/terraform-providers/terraform-provider-azurerm/issues/10499
    WEBSITE_CONTENTSHARE = "io-p-fn3-services-content"
    WEBSITE_PROACTIVE_AUTOHEAL_ENABLED = "True"
    # AzureFunctionsJobHost__extensions__durableTask__storageProvider__partitionCount = "16"
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
    }
  }

  durable_function = {
    enable                     = true
    private_endpoint_subnet_id = dependency.subnet_pendpoints.outputs.id
    private_dns_zone_blob_ids  = [dependency.private_dns_zone_blob.outputs.id]
    private_dns_zone_queue_ids = [dependency.private_dns_zone_queue.outputs.id]
    private_dns_zone_table_ids = [dependency.private_dns_zone_table.outputs.id]
    queues                     = [
      "message-created",
      "message-processed",
      "notification-created-email",
      "notification-created-webhook",
    ]
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_apimapi.outputs.id,
    dependency.subnet_fn3eucovidcert.outputs.id,
  ]

  allowed_ips = local.app_insights_ips_west_europe

  subnet_id = dependency.subnet.outputs.id
}
