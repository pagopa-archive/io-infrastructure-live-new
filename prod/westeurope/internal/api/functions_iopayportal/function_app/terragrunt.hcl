dependency "subnet" {
  config_path = "../subnet"
}

# External
dependency "app_service_pagopaproxyprod" {
  config_path = "../../../../external/pagopaproxyprod/app_service"
}

dependency "app_service_pagopaproxytest" {
  config_path = "../../../../external/pagopaproxytest/app_service"
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

dependency "storage_account_iopay" {
  config_path = "../../../../common/cdn/storage_account_iopay"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v3.0.3"
}

inputs = {
  name                = "iopayportal"
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
    WEBSITE_NODE_DEFAULT_VERSION   = "12.18.0"
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    FUNCTIONS_WORKER_PROCESS_COUNT = 4
    NODE_ENV                       = "production"

    # DNS configuration to use private dns zones
    // TODO: Use private dns zone https://www.pivotaltracker.com/story/show/173102678
    //WEBSITE_DNS_SERVER     = "168.63.129.16"
    //WEBSITE_VNET_ROUTE_ALL = 1

    SERVICES_API_URL = "http://api-internal.io.italia.it/"

    // PAGOPA : endpoints use to call pagopa-proxy service : getPaymentInfo, activatePayment, getActivationStatus
    IO_PAGOPA_PROXY_PROD_BASE_URL = "https://${dependency.app_service_pagopaproxyprod.outputs.default_site_hostname}"
    IO_PAGOPA_PROXY_TEST_BASE_URL = "https://${dependency.app_service_pagopaproxytest.outputs.default_site_hostname}"
    PAGOPA_BASE_PATH              = "/pagopa/api/v1"

    // Keepalive fields are all optionals
    FETCH_KEEPALIVE_ENABLED             = "true"
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL   = "110000"
    FETCH_KEEPALIVE_MAX_SOCKETS         = "40"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"

    // Mailup groups and lists
    MAILUP_ALLOWED_GROUPS = "30,31,32,21,29"
    MAILUP_ALLOWED_LISTS  = "2,4"

    SLOT_TASK_HUBNAME = "ProductionTaskHub"

    # this app settings is required to solve the issue:
    # https://github.com/terraform-providers/terraform-provider-azurerm/issues/10499
    WEBSITE_CONTENTSHARE = "io-p-func-iopayportal-content"

    IO_PAY_CHALLENGE_RESUME_URL = "https://io-p-cdnendpoint-iopay.azureedge.net/response.html?id=idTransaction"
    IO_PAY_ORIGIN               = "https://io-p-cdnendpoint-iopay.azureedge.net"
    IO_PAY_XPAY_REDIRECT        = "https://io-p-cdnendpoint-iopay.azureedge.net//response.html?id=_id_&resumeType=_resumeType_&_queryParams_"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      RECAPTCHA_SECRET = "newsletter-GOOGLE-RECAPTCHA-SECRET"
      # Mailup account:
      MAILUP_CLIENT_ID = "newsletter-MAILUP-CLIENT-ID"
      MAILUP_SECRET    = "newsletter-MAILUP-SECRET"
      MAILUP_USERNAME  = "newsletter-MAILUP-USERNAME"
      MAILUP_PASSWORD  = "newsletter-MAILUP-PASSWORD"
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_apimapi.outputs.id
  ]

  subnet_id = dependency.subnet.outputs.id
}
