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

dependency "storage_table_cardexpiration" {
  config_path = "../../storage_cgn/table_cardexpiration"
}

dependency "storage_table_eycacardexpiration" {
  config_path = "../../storage_cgn/table_eycacardexpiration"
}

# Common
dependency "subnet_pendpoints" {
  config_path = "../../../common/subnet_pendpoints"
}

dependency "private_dns_zone_blob" {
  config_path = "../../../common/private_dns_zones/privatelink-blob-core-windows-net/zone"
}

dependency "private_dns_zone_queue" {
  config_path = "../../../common/private_dns_zones/privatelink-queue-core-windows-net/zone"
}

dependency "private_dns_zone_table" {
  config_path = "../../../common/private_dns_zones/privatelink-table-core-windows-net/zone"
}

dependency "virtual_network" {
  config_path = "../../../common/virtual_network"
}

dependency "application_insights" {
  config_path = "../../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../../common/key_vault"
}

# linux
dependency "subnet_appbackendl1" {
  config_path = "../../../linux/appbackendl1/subnet"
}

dependency "subnet_appbackendl2" {
  config_path = "../../../linux/appbackendl2/subnet"
}

dependency "subnet_appbackendli" {
  config_path = "../../../linux/appbackendli/subnet"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v4.0.0"
}

locals {
  commonvars                   = read_terragrunt_config(find_in_parent_folders("commonvars.hcl"))
  external_resources           = read_terragrunt_config(find_in_parent_folders("external_resources.tf"))
  app_insights_ips_west_europe = local.commonvars.locals.app_insights_ips_west_europe
  cet_time_zone_win            = local.commonvars.locals.cet_time_zone_win
  service_api_url              = local.commonvars.locals.service_api_url
}

inputs = {
  name                = "cgn"
  resource_group_name = dependency.resource_group.outputs.resource_name

  app_service_plan_info = {
    kind     = "elastic"
    sku_tier = "ElasticPremium"
    sku_size = "EP1"
  }

  runtime_version = "~3"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "node"
    WEBSITE_NODE_DEFAULT_VERSION   = "14.16.0"
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    FUNCTIONS_WORKER_PROCESS_COUNT = 4
    NODE_ENV                       = "production"

    COSMOSDB_CGN_URI           = dependency.cosmosdb_cgn_account.outputs.endpoint
    COSMOSDB_CGN_KEY           = dependency.cosmosdb_cgn_account.outputs.primary_master_key
    COSMOSDB_CGN_DATABASE_NAME = dependency.cosmosdb_cgn_database.outputs.name
    COSMOSDB_CONNECTION_STRING = dependency.cosmosdb_cgn_account.outputs.connection_strings[0]
    // Keepalive fields are all optionals<
    FETCH_KEEPALIVE_ENABLED             = "true"
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL   = "110000"
    FETCH_KEEPALIVE_MAX_SOCKETS         = "40"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"


    #SLOT_TASK_HUBNAME = "ProductionTaskHub"

    CGN_EXPIRATION_TABLE_NAME  = dependency.storage_table_cardexpiration.outputs.name
    EYCA_EXPIRATION_TABLE_NAME = dependency.storage_table_eycacardexpiration.outputs.name

    # Storage account connection string:
    CGN_STORAGE_CONNECTION_STRING = dependency.storage_account_cgn.outputs.primary_connection_string

    SERVICES_API_URL = local.service_api_url


    WEBSITE_TIME_ZONE = local.cet_time_zone_win
    EYCA_API_BASE_URL = "https://ccdb.eyca.org/api"

    // REDIS
    REDIS_URL      = dependency.redis.outputs.hostname
    REDIS_PORT     = dependency.redis.outputs.ssl_port
    REDIS_PASSWORD = dependency.redis.outputs.primary_access_key

    OTP_TTL_IN_SECONDS = 600

    CGN_UPPER_BOUND_AGE  = 36
    EYCA_UPPER_BOUND_AGE = 31

    CGN_CARDS_DATA_BACKUP_CONTAINER_NAME = "cgn-legalbackup-blob"
    CGN_CARDS_DATA_BACKUP_FOLDER_NAME    = "cgn"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      SERVICES_API_KEY           = "apim-CGN-SERVICE-KEY"
      EYCA_API_USERNAME          = "funccgn-EYCA-API-USERNAME"
      EYCA_API_PASSWORD          = "funccgn-EYCA-API-PASSWORD"
      CGN_SERVICE_ID             = "funccgn-CGN-SERVICE-ID"
      CGN_DATA_BACKUP_CONNECTION = "cgn-legalbackup-storage-connection-string"
    }
  }

  durable_function = {
    enable                     = true
    private_endpoint_subnet_id = dependency.subnet_pendpoints.outputs.id
    private_dns_zone_blob_ids  = [dependency.private_dns_zone_blob.outputs.id]
    private_dns_zone_queue_ids = [dependency.private_dns_zone_queue.outputs.id]
    private_dns_zone_table_ids = [dependency.private_dns_zone_table.outputs.id]
    containers                 = []
    queues                     = []
    blobs_retention_days       = 0
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_appbackendl1.outputs.id,
    dependency.subnet_appbackendl2.outputs.id,
    dependency.subnet_appbackendli.outputs.id,
    local.external_resources.locals.subnets.apimapi,
  ]

  allowed_ips = local.app_insights_ips_west_europe

  subnet_id = dependency.subnet.outputs.id
}
