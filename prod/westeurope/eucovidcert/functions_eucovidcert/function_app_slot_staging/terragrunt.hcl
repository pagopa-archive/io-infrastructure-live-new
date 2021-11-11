dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "function_app" {
  config_path = "../function_app"
}

dependency "subnet" {
  config_path = "../subnet"
}

dependency "storage_account_eucovidcert" {
  config_path = "../../storage_eucovidcert/account"
}

dependency "storage_account_eucovidcert_queue_notify-new-profile" {
  config_path = "../../storage_eucovidcert/queue_notify-new-profile"
}

dependency "storage_account_eucovidcert_table_trace_notify-new-profile" {
  config_path = "../../storage_eucovidcert/table-trace-notify-new-profile"
}


# Internal
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

dependency "storage_account_apievents" {
  config_path = "../../../internal/api/storage_apievents/account"
}

dependency "storage_account_apievents_queue_eucovidcert-profile-created" {
  config_path = "../../../internal/api/storage_apievents/queue_eucovidcert-profile-created"
}

# Common
dependency "application_insights" {
  config_path = "../../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../../common/key_vault"
}

dependency "subnet_azure_devops" {
  config_path = "../../../common/subnet_azure_devops"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app_slot?ref=v4.0.1"
}

locals {
  commonvars                   = read_terragrunt_config(find_in_parent_folders("commonvars.hcl"))
  external_resources           = read_terragrunt_config(find_in_parent_folders("external_resources.tf"))
  testusersvars                = read_terragrunt_config(find_in_parent_folders("testusersvars.hcl"))
  app_insights_ips_west_europe = local.commonvars.locals.app_insights_ips_west_europe
}

inputs = {
  name                       = "staging"
  resource_group_name        = dependency.resource_group.outputs.resource_name
  function_app_name          = dependency.function_app.outputs.name
  function_app_resource_name = dependency.function_app.outputs.resource_name
  app_service_plan_id        = dependency.function_app.outputs.app_service_plan_id
  storage_account_name       = dependency.function_app.outputs.storage_account.name
  storage_account_access_key = dependency.function_app.outputs.storage_account.primary_access_key

  pre_warmed_instance_count = 1

  resources_prefix = {
    function_app     = "fn3"
    app_service_plan = "fn3"
    storage_account  = "fn3"
  }

  runtime_version = "~3"

  health_check_path = "api/v1/info"

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

    DGC_UAT_FISCAL_CODES = local.testusersvars.locals.test_users_eu_covid_cert_flat
    # we need test_users_store_review_flat because app IO reviewers must read a valid certificate response
    LOAD_TEST_FISCAL_CODES = join(",", [local.testusersvars.locals.test_users_store_review_flat,
    local.testusersvars.locals.test_users_internal_load_flat])

    DGC_UAT_URL       = "https://servizi-pnval.dgc.gov.it"
    DGC_LOAD_TEST_URL = "https://io-p-fn3-mockdgc.azurewebsites.net"
    DGC_PROD_URL      = "https://servizi-pn.dgc.gov.it"

    // Events configs
    EventsQueueStorageConnection                    = dependency.storage_account_apievents.outputs.primary_connection_string
    EUCOVIDCERT_PROFILE_CREATED_QUEUE_NAME          = dependency.storage_account_apievents_queue_eucovidcert-profile-created.outputs.name
    QueueStorageConnection                          = dependency.storage_account_eucovidcert.outputs.primary_connection_string
    EUCOVIDCERT_NOTIFY_NEW_PROFILE_QUEUE_NAME       = dependency.storage_account_eucovidcert_queue_notify-new-profile.outputs.name
    TableStorageConnection                          = dependency.storage_account_eucovidcert.outputs.primary_connection_string
    EUCOVIDCERT_TRACE_NOTIFY_NEW_PROFILE_TABLE_NAME = dependency.storage_account_eucovidcert_table_trace_notify-new-profile.outputs.name

    SLOT_TASK_HUBNAME = "StagingTaskHub"

    APPINSIGHTS_SAMPLING_PERCENTAGE = 5

    // Disable listener functions
    "AzureWebJobs.NotifyNewProfileToDGC.Disabled" = "1"
    "AzureWebJobs.OnProfileCreatedEvent.Disabled" = "1"

    # this app settings is required to solve the issue:
    # https://github.com/terraform-providers/terraform-provider-azurerm/issues/10499
    WEBSITE_CONTENTSHARE = "staging-content"

    # ----
    FNSERVICES_API_URL     = "https://${dependency.functions_services.outputs.default_hostname}/api/v1"
    WEBSITE_VNET_ROUTE_ALL = 1
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      DGC_PROD_CLIENT_CERT      = "eucovidcert-DGC-PROD-CLIENT-CERT"
      DGC_PROD_CLIENT_KEY       = "eucovidcert-DGC-PROD-CLIENT-KEY"
      DGC_PROD_SERVER_CA        = "eucovidcert-DGC-PROD-SERVER-CA"
      DGC_UAT_CLIENT_CERT       = "eucovidcert-DGC-UAT-CLIENT-CERT"
      DGC_UAT_CLIENT_KEY        = "eucovidcert-DGC-UAT-CLIENT-KEY"
      DGC_UAT_SERVER_CA         = "eucovidcert-DGC-UAT-SERVER-CA"
      DGC_LOAD_TEST_CLIENT_KEY  = "eucovidcert-DGC-LOAD-TEST-CLIENT-KEY"
      DGC_LOAD_TEST_CLIENT_CERT = "eucovidcert-DGC-LOAD-TEST-CLIENT-CERT"
      DGC_LOAD_TEST_SERVER_CA   = "eucovidcert-DGC-LOAD-TEST-SERVER-CA"
      FNSERVICES_API_KEY        = "fn3services-KEY-EUCOVIDCERT"
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_apimapi.outputs.id,
    dependency.subnet_azure_devops.outputs.id,
    dependency.subnet_appbackendl1.outputs.id,
    dependency.subnet_appbackendl2.outputs.id,
    local.external_resources.locals.subnets.fnpblevtdispatcherout,
    local.external_resources.locals.subnets.apimapi,
  ]

  allowed_ips = local.app_insights_ips_west_europe

  subnet_id       = dependency.subnet.outputs.id
  function_app_id = dependency.function_app.outputs.id
}

