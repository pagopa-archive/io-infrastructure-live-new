dependency "subnet" {
  config_path = "../subnet"
}

dependency "cosmosdb_private_account" {
  config_path = "../../cosmosdb/account"
}

dependency "cosmosdb_private_database" {
  config_path = "../../cosmosdb/database"
}

# Internal
dependency "resource_group" {
  config_path = "../../resource_group"
}

# Common
dependency "virtual_network" {
  config_path = "../../virtual_network"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v3.0.3"
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

  application_insights_instrumentation_key = "NA"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME     = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "12.18.0"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    NODE_ENV                     = "production"

    COSMOSDB_PRIVATE_URI  = dependency.cosmosdb_private_account.outputs.endpoint
    COSMOSDB_PRIVATE_KEY  = dependency.cosmosdb_private_account.outputs.primary_master_key
    COSMOSDB_PRIVATE_NAME = dependency.cosmosdb_private_database.outputs.name

    SLOT_TASK_HUBNAME = "ProductionTaskHub"

    # DNS and VNET configuration to use private endpoint
    WEBSITE_DNS_SERVER     = "168.63.129.16"
    WEBSITE_VNET_ROUTE_ALL = 1

    # this app settings is required to solve the issue:
    # https://github.com/terraform-providers/terraform-provider-azurerm/issues/10499
    WEBSITE_CONTENTSHARE = "io-p-fn3-private"
  }

  app_settings_secrets = {
    key_vault_id = "dummy"
    map = {
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id
  ]

  subnet_id = dependency.subnet.outputs.id
}
