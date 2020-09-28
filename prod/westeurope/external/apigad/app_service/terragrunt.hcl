dependency "subnet" {
  config_path = "../subnet"
}

dependency "resource_group" {
  config_path = "../../resource_group"
}

// Common
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_app_service?ref=v2.1.0"

  after_hook "check_slots" {
    commands     = ["apply"]
    execute      = ["echo", "Remember to do check also the app_service slots!"]
    run_on_error = true
  }
}

inputs = {
  name                = "apigad"
  resource_group_name = dependency.resource_group.outputs.resource_name

  app_service_plan_info = {
    kind     = "Windows"
    sku_tier = "PremiumV2"
    sku_size = "P3v2"
  }

  app_enabled         = true
  client_cert_enabled = false
  https_only          = true

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    GAD_PROXY_CHANGE_ORIGIN      = "true"

    DISABLE_CLIENT_CERTIFICATE_VERIFICATION = "true"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      GAD_CA_CERTIFICATE_BASE64              = "io-PAGOPA-INTERNAL-CA-CERT"
      GAD_CLIENT_CERTIFICATE_VERIFIED_HEADER = "apigad-GAD-CLIENT-CERTIFICATE-VERIFIED-HEADER"
      GAD_PROXY_TARGET                       = "apigad-GAD-PROXY-TARGET"
    }
  }

  // TODO: Add ip restriction
  allowed_ips = []

  subnet_id = dependency.subnet.outputs.id
}
