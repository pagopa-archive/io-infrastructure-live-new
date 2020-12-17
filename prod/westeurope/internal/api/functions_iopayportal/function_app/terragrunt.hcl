dependency "subnet" {
  config_path = "../subnet"
}

# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

dependency "subnet_apimapi" {
  config_path = "../../../api/apim/subnet"
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v2.1.10"
}

inputs = {
  name                = "iopayportalapi"
  resource_group_name = dependency.resource_group.outputs.resource_name

  app_service_plan_info = {
    kind     = "elastic"
    sku_tier = "ElasticPremium"
    sku_size = "EP1"
  }

  runtime_version = "~3"

  pre_warmed_instance_count = 2

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

    REDEEMED_REQUESTS_CONTAINER_NAME = "redeemed-requests"

    SERVICES_API_URL = "http://api-internal.io.italia.it/"

    // Keepalive fields are all optionals
    FETCH_KEEPALIVE_ENABLED             = "true"
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL   = "110000"
    FETCH_KEEPALIVE_MAX_SOCKETS         = "40"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"

    SLOT_TASK_HUBNAME = "ProductionTaskHub"

    APPINSIGHTS_SAMPLING_PERCENTAGE = "100"
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_apimapi.outputs.id
  ]

  subnet_id = dependency.subnet.outputs.id
}
