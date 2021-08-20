dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "virtual_network" {
  config_path = "../../virtual_network"
}

dependency "subnet" {
  config_path = "../subnet"
}

dependency "subnet_pendpoints" {
  config_path = "../../subnet_pendpoints"
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

dependency "cosmosdb_private_account" {
  config_path = "../../cosmosdb/account"
}

dependency "cosmosdb_private_database" {
  config_path = "../../cosmosdb/database"
}

dependency "storage_private" {
  config_path = "../../storage/account"
}

dependency "application_insights" {
  config_path = "../../application_insights"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=fn-app-private-storage"
}

locals {
  commonvars                   = read_terragrunt_config(find_in_parent_folders("commonvars.hcl"))
  app_insights_ips_west_europe = local.commonvars.locals.app_insights_ips_west_europe
}

inputs = {
  name                = "private"
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

  runtime_version = "~3"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key
  
  health_check_path = "api/v1/info"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "12.18.0"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    NODE_ENV                     = "production"

    COSMOSDB_URI  = dependency.cosmosdb_private_account.outputs.endpoint
    COSMOSDB_KEY  = dependency.cosmosdb_private_account.outputs.primary_master_key
    COSMOSDB_NAME = dependency.cosmosdb_private_database.outputs.name

    QueueStorageConnection = dependency.storage_private.outputs.primary_connection_string
  }

  app_settings_secrets = {
    key_vault_id = "dummy"
    map = {
    }
  }

  storage_durable_function_private_endpoint = {
    subnet_id                  = dependency.subnet_pendpoints.outputs.id
    private_dns_zone_blob_ids  = [dependency.private_dns_zone_blob.outputs.id]
    private_dns_zone_queue_ids = [dependency.private_dns_zone_queue.outputs.id]
    private_dns_zone_table_ids = [dependency.private_dns_zone_table.outputs.id]
  }

  # allowed_ips = local.app_insights_ips_west_europe

  subnet_id = dependency.subnet.outputs.id
}
