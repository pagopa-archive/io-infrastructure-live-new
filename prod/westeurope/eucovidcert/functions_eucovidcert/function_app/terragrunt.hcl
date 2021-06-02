dependency "resource_group" {
  config_path = "../../resource_group"
}

# Subnet
dependency "subnet" {
  config_path = "../subnet"
}

dependency "subnet_apimapi" {
  config_path = "../../../internal/api/apim/subnet/"
}

dependency "subnet_appbackendl1" {
  config_path = "../../../linux/appbackendl1/subnet"
}

dependency "subnet_appbackendl2" {
  config_path = "../../../linux/appbackendl2/subnet"
}


dependency "functions_services" {
  config_path = "../../../internal/api/functions_services_r3/function_app"
}

# Common
dependency "application_insights" {
  config_path = "../../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../../common/key_vault"
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
  testusersvars                = read_terragrunt_config(find_in_parent_folders("testusersvars.hcl"))
  app_insights_ips_west_europe = local.commonvars.locals.app_insights_ips_west_europe
  service_api_url              = local.commonvars.locals.service_api_url
}

inputs = {
  name                = "eucovidcert"
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

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "node"
    WEBSITE_NODE_DEFAULT_VERSION   = "14.16.0"
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    FUNCTIONS_WORKER_PROCESS_COUNT = 4
    NODE_ENV                       = "production"

    // Keepalive fields are all optionals
    FETCH_KEEPALIVE_ENABLED             = "true"
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL   = "110000"
    FETCH_KEEPALIVE_MAX_SOCKETS         = "40"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"

    DGC_UAT_FISCAL_CODES   = local.testusersvars.locals.test_users_eu_covid_cert_flat
    LOAD_TEST_FISCAL_CODES = local.testusersvars.locals.test_users_internal_load_flat

    DGC_UAT_URL       = "TBD"
    DGC_LOAD_TEST_URL = "TBD"
    DGC_PROD_URL      = "TBD"
    
    SLOT_TASK_HUBNAME = "ProductionTaskHub"

    APPINSIGHTS_SAMPLING_PERCENTAGE = 5

    # this app settings is required to solve the issue:
    # https://github.com/terraform-providers/terraform-provider-azurerm/issues/10499
    WEBSITE_CONTENTSHARE = "io-p-fn3-eucovidcert-content"

    # ----

    FNSERVICES_API_URL = "http://${dependency.functions_services.outputs.default_hostname}/api/v1"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
        DGC_PROD_CLIENT_CERT        = "eucovidcert-DGC-PROD-CLIENT-CERT"
        DGC_PROD_CLIENT_KEY         = "eucovidcert-DGC-PROD-CLIENT-KEY"
        DGC_UAT_CLIENT_CERT         = "eucovidcert-DGC-UAT-CLIENT-CERT"
        DGC_UAT_CLIENT_KEY          = "eucovidcert-DGC-UAT-CLIENT-KEY"
        FNSERVICES_API_KEY          = "fn3services-KEY-EUCOVIDCERT"
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_apimapi.outputs.id,
    dependency.subnet_appbackendl1.outputs.id,
    dependency.subnet_appbackendl2.outputs.id,
  ]

  allowed_ips = local.app_insights_ips_west_europe

  subnet_id = dependency.subnet.outputs.id
}

