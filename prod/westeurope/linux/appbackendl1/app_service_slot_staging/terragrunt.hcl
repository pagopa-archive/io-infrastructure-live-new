dependency "app_service" {
  config_path = "../app_service"
}

dependency "subnet" {
  config_path = "../subnet"
}

dependency "subnet_azure_devops" {
  config_path = "../../../common/subnet_azure_devops"
}

# Internal
dependency "resource_group" {
  config_path = "../../resource_group"
}

# App Backend Api
dependency "functions_app1_r3" {
  config_path = "../../../functions_app1/functions_app1_r3/function_app"
}

# Bonus Api
dependency "functions_bonus" {
  config_path = "../../../internal/api/functions_bonus/function_app"
}

# Cgn Api
dependency "functions_cgn" {
  config_path = "../../../cgn/functions_cgn/function_app"
}

# EUCovidCert Api
dependency "functions_eucovidcert" {
  config_path = "../../../eucovidcert/functions_eucovidcert/function_app"
}

# Push notifications origin
dependency "subnet_fn3services" {
  config_path = "../../../internal/api/functions_services_r3/subnet"
}

# Session endpoints allowed origin
dependency "subnet_funcadmin_r3" {
  config_path = "../../../internal/api/functions_admin_r3/subnet"
}

# External
dependency "app_service_pagopaproxyprod" {
  config_path = "../../../external/pagopaproxyprod/app_service"
}

dependency "app_service_pagopaproxytest" {
  config_path = "../../../external/pagopaproxytest/app_service"
}

# Common
dependency "application_insights" {
  config_path = "../../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../../common/key_vault"
}

dependency "virtual_network" {
  config_path = "../../../common/virtual_network"
}

dependency "redis" {
  config_path = "../../../common/redis/redis_cache"
}

dependency "notification_hub" {
  config_path = "../../../common/notification_hub"
}

dependency "storage_account_logs" {
  config_path = "../../../operations/storage_account_logs/account"
}

dependency "storage_queue_spid_logs" {
  config_path = "../../../operations/storage_queue_spid_logs"
}

dependency "storage_queue_users_login" {
  config_path = "../../../operations/storage_queue_users_login"
}

dependency "notification_queue" {
  config_path = "../../../internal/api/storage_notifications/queue_push-notifications"
}

dependency "notification_storage_account" {
  config_path = "../../../internal/api/storage_notifications/account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  testusersvars      = read_terragrunt_config(find_in_parent_folders("testusersvars.hcl"))
  external_resources = read_terragrunt_config(find_in_parent_folders("external_resources.tf"))
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service_slot?ref=v4.0.0"
}

inputs = {
  name                = "staging"
  resource_group_name = dependency.resource_group.outputs.resource_name
  app_service_name    = dependency.app_service.outputs.name
  app_service_id      = dependency.app_service.outputs.id
  app_service_plan_id = dependency.app_service.outputs.app_service_plan_id

  app_enabled         = true
  client_cert_enabled = false
  https_only          = false

  linux_fx_version = "NODE|14-lts"
  app_command_line = "node /home/site/wwwroot/src/server.js"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "1"
    WEBSITE_VNET_ROUTE_ALL   = "1"
    WEBSITE_DNS_SERVER       = "168.63.129.16"

    // ENVIRONMENT
    NODE_ENV = "production"

    FETCH_KEEPALIVE_ENABLED = "true"
    // see https://github.com/MicrosoftDocs/azure-docs/issues/29600#issuecomment-607990556
    // and https://docs.microsoft.com/it-it/azure/app-service/app-service-web-nodejs-best-practices-and-troubleshoot-guide#scenarios-and-recommendationstroubleshooting
    // FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL should not exceed 120000 (app service socket timeout)
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL = "110000"
    // (FETCH_KEEPALIVE_MAX_SOCKETS * number_of_node_processes) should not exceed 160 (max sockets per VM)
    FETCH_KEEPALIVE_MAX_SOCKETS         = "128"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"

    // SPID
    SAML_CALLBACK_URL                      = "https://app-backend.io.italia.it/assertionConsumerService"
    SAML_LOGOUT_CALLBACK_URL               = "https://app-backend.io.italia.it/slo"
    SAML_ISSUER                            = "https://app-backend.io.italia.it"
    SAML_ATTRIBUTE_CONSUMING_SERVICE_INDEX = "0"
    SAML_ACCEPTED_CLOCK_SKEW_MS            = "2000"
    IDP_METADATA_URL                       = "https://registry.SPID.gov.it/metadata/idp/spid-entities-idps.xml"
    IDP_METADATA_REFRESH_INTERVAL_SECONDS  = "864000" # 10 days

    // CIE
    CIE_METADATA_URL = "https://idserver.servizicie.interno.gov.it:443/idp/shibboleth"

    // AUTHENTICATION
    AUTHENTICATION_BASE_PATH  = ""
    TOKEN_DURATION_IN_SECONDS = "2592000"

    // FUNCTIONS
    API_URL             = "http://${dependency.functions_app1_r3.outputs.default_hostname}/api/v1"
    BONUS_API_URL       = "http://${dependency.functions_bonus.outputs.default_hostname}/api/v1"
    CGN_API_URL         = "http://${dependency.functions_cgn.outputs.default_hostname}/api/v1"
    CGN_OPERATOR_SEARCH_API_URL = "https://cgnonboardingportal-p-os.azurewebsites.net/api/v1"
    EUCOVIDCERT_API_URL = "http://${dependency.functions_eucovidcert.outputs.default_hostname}/api/v1"

    // EXPOSED API
    API_BASE_PATH             = "/api/v1"
    BONUS_API_BASE_PATH       = "/api/v1"
    CGN_API_BASE_PATH         = "/api/v1/cgn"
    CGN_OPERATOR_SEARCH_API_BASE_PATH = "/api/v1/cgn-operator-search"    
    EUCOVIDCERT_API_BASE_PATH = "/api/v1/eucovidcert"
    MIT_VOUCHER_API_BASE_PATH = "/api/v1/mitvoucher/auth"

    // REDIS
    REDIS_URL      = dependency.redis.outputs.hostname
    REDIS_PORT     = dependency.redis.outputs.ssl_port
    REDIS_PASSWORD = dependency.redis.outputs.primary_access_key

    // PUSH NOTIFICATIONS
    ALLOW_NOTIFY_IP_SOURCE_RANGE = "${dependency.subnet_fn3services.outputs.address_prefix}"

    // LOCK / UNLOCK SESSION ENDPOINTS
    ALLOW_SESSION_HANDLER_IP_SOURCE_RANGE = dependency.subnet_funcadmin_r3.outputs.address_prefix

    // PAGOPA
    PAGOPA_API_URL_PROD = "https://${dependency.app_service_pagopaproxyprod.outputs.default_site_hostname}"
    PAGOPA_API_URL_TEST = "https://${dependency.app_service_pagopaproxytest.outputs.default_site_hostname}"
    PAGOPA_BASE_PATH    = "/pagopa/api/v1"

    // MYPORTAL
    MYPORTAL_BASE_PATH = "/myportal/api/v1"

    // MIT_VOUCHER JWT
    JWT_MIT_VOUCHER_TOKEN_ISSUER="app-backend.io.italia.it"
    JWT_MIT_VOUCHER_TOKEN_EXPIRATION=1200
    PECSERVER_TOKEN_ISSUER = "app-backend.io.italia.it"

    // BPD
    BPD_BASE_PATH = "/bpd/api/v1"

    // ZENDESK
    ZENDESK_BASE_PATH = "/api/backend/zendesk/v1"
    JWT_ZENDESK_SUPPORT_TOKEN_ISSUER = "app-backend.io.italia.it"
    JWT_ZENDESK_SUPPORT_TOKEN_EXPIRATION = 1200

    SPID_LOG_QUEUE_NAME                = dependency.storage_queue_spid_logs.outputs.name
    SPID_LOG_STORAGE_CONNECTION_STRING = dependency.storage_account_logs.outputs.primary_connection_string

    NOTIFICATIONS_QUEUE_NAME                = dependency.notification_queue.outputs.name
    NOTIFICATIONS_STORAGE_CONNECTION_STRING = dependency.notification_storage_account.outputs.primary_connection_string

    // USERSLOGIN
    USERS_LOGIN_STORAGE_CONNECTION_STRING = dependency.storage_account_logs.outputs.primary_connection_string
    USERS_LOGIN_QUEUE_NAME                = dependency.storage_queue_users_login.outputs.name

    // Feature flags
    FF_BONUS_ENABLED          = 1
    FF_CGN_ENABLED            = 1
    FF_EUCOVIDCERT_ENABLED    = 1
    FF_MIT_VOUCHER_ENABLED    = 1
    FF_USER_AGE_LIMIT_ENABLED = 1
    TEST_LOGIN_FISCAL_CODES   = local.testusersvars.locals.test_users

    # No downtime on slots swap
    WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG = 1

    JWT_SUPPORT_TOKEN_ISSUER     = "app-backend.io.italia.it"
    JWT_SUPPORT_TOKEN_EXPIRATION = 1209600

    // PECSERVER
    PECSERVER_URL="https://poc.pagopa.poste.it"
    PECSERVER_BASE_PATH=""
    //
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      // SPID
      SAML_CERT = "appbackend-SAML-CERT"
      SAML_KEY  = "appbackend-SAML-KEY"

      // FUNCTIONS
      API_KEY             = "funcapp-KEY-APPBACKEND"
      BONUS_API_KEY       = "funcbonus-KEY-APPBACKEND"
      CGN_API_KEY         = "funccgn-KEY-APPBACKEND"
      CGN_OPERATOR_SEARCH_API_KEY = "funccgnoperatorsearch-KEY-APPBACKEND"
      EUCOVIDCERT_API_KEY = "funceucovidcert-KEY-APPBACKEND"

      // PUSH NOTIFICATIONS
      PRE_SHARED_KEY = "appbackend-PRE-SHARED-KEY"

      // PAGOPA
      ALLOW_PAGOPA_IP_SOURCE_RANGE = "appbackend-ALLOW-PAGOPA-IP-SOURCE-RANGE"

      // TEST LOGIN
      TEST_LOGIN_PASSWORD = "appbackend-TEST-LOGIN-PASSWORD"

      // MYPORTAL
      ALLOW_MYPORTAL_IP_SOURCE_RANGE = "appbackend-ALLOW-MYPORTAL-IP-SOURCE-RANGE"

      // BPD
      ALLOW_BPD_IP_SOURCE_RANGE         = "appbackend-ALLOW-BPD-IP-SOURCE-RANGE"
      JWT_SUPPORT_TOKEN_PRIVATE_RSA_KEY = "appbackend-JWT-SUPPORT-TOKEN-PRIVATE-RSA-KEY"

      // CGN BETA
      TEST_CGN_FISCAL_CODES             = "appbackend-TEST-CGN-FISCAL-CODES"

      // MIT_VOUCHER JWT
      JWT_MIT_VOUCHER_TOKEN_PRIVATE_ES_KEY  = "appbackend-mitvoucher-JWT-PRIVATE-ES-KEY"
      JWT_MIT_VOUCHER_TOKEN_AUDIENCE        = "appbackend-mitvoucher-JWT-AUDIENCE"

      // ZENDESK
      ALLOW_ZENDESK_IP_SOURCE_RANGE="appbackend-ALLOW-ZENDESK-IP-SOURCE-RANGE"
      JWT_ZENDESK_SUPPORT_TOKEN_SECRET="appbackend-JWT-ZENDESK-SUPPORT-TOKEN-SECRET"

      // PECSERVER
      PECSERVER_TOKEN_SECRET="appbackend-PECSERVER-TOKEN-SECRET"
      //
    }
  }

  // TODO: Add ip restriction
  allowed_ips = []

  allowed_subnets = [
    dependency.subnet_fn3services.outputs.id,
    dependency.subnet_funcadmin_r3.outputs.id,
    dependency.subnet_azure_devops.outputs.id,
    local.external_resources.locals.subnets.io-p-appgateway-snet,
    local.external_resources.locals.subnets.apimapi,
  ]

  subnet_id = dependency.subnet.outputs.id

  application_logs = {
    key_vault_id             = dependency.key_vault.outputs.id
    key_vault_secret_sas_url = "logs-APPBACKEND-SAS-URL"
    level                    = "Information"
    retention_in_days        = 90
  }
}
