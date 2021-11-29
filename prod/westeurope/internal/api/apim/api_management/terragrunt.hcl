/*
  DEPRECATED !!!
  Use instead: https://github.com/pagopa/io-infra
*/

dependency "functions_admin_r3" {
  config_path = "../../functions_admin_r3/function_app"
}

dependency "functions_services_r3" {
  config_path = "../../functions_services_r3/function_app"
}

dependency "functions_public_r3" {
  config_path = "../../functions_public_r3/function_app"
}

dependency "functions_bonusapi" {
  config_path = "../../functions_bonusapi_r3/function_app"
}

dependency "functions_iopayportal" {
  config_path = "../../functions_iopayportal/function_app"
}

dependency "functions_eucovidcert" {
  config_path = "../../../../eucovidcert/functions_eucovidcert/function_app"
}

# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

# Common
dependency "virtual_network" {
  config_path = "../../../../common/virtual_network"
}

dependency "key_vault" {
  config_path = "../../../../common/key_vault"
}

dependency "application_insights" {
  config_path = "../../../../common/application_insights"
}

# support
dependency "functions_backoffice" {
  config_path = "../../../../support/functions_backoffice/function_app"
}

# CGN
dependency "functions_cgnmerchant" {
  config_path = "../../../../cgn/functions_cgn_merchant/function_app"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_api_management?ref=v4.0.0"
}

inputs = {
  name                      = "api"
  resource_group_name       = dependency.resource_group.outputs.resource_name
  publisher_name            = "IO"
  publisher_email           = "io-apim@pagopa.it"
  notification_sender_email = "io-apim@pagopa.it"
  sku_name                  = "Premium_1"

  virtual_network_info = {
    resource_group_name   = dependency.virtual_network.outputs.resource_group_name
    name                  = dependency.virtual_network.outputs.resource_name
    subnet_address_prefix = "10.0.101.0/24"
  }

  named_values_map = {
    io-fn3-admin-url          = "https://${dependency.functions_admin_r3.outputs.default_hostname}"
    io-fn3-public-url         = "https://${dependency.functions_public_r3.outputs.default_hostname}"
    io-fn3-services-url       = "https://${dependency.functions_services_r3.outputs.default_hostname}"
    io-functions-bonusapi-url = "https://${dependency.functions_bonusapi.outputs.default_hostname}"
    io-fn3-backoffice-url     = "https://${dependency.functions_backoffice.outputs.default_hostname}"
    io-fn-pay-portal-url      = "https://${dependency.functions_iopayportal.outputs.default_hostname}"
    io-fn-cgnmerchant-url     = "https://${dependency.functions_cgnmerchant.outputs.default_hostname}"
    io-fn3-eucovidcert-url    = "https://${dependency.functions_eucovidcert.outputs.default_hostname}"
  }

  named_values_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      apigad-gad-client-certificate-verified-header = "apigad-GAD-CLIENT-CERTIFICATE-VERIFIED-HEADER"
      io-fn3-admin-key                              = "fn3admin-KEY-APIM"
      io-fn3-public-key                             = "fn3public-KEY-APIM"
      io-fn3-services-key                           = "fn3services-KEY-APIM"
      io-functions-bonusapi-key                     = "funcbonusapi-KEY-APIM"
      io-fn3-backoffice-key                         = "fn3backoffice-KEY-APIM"
      io-fn-pay-portal-key                          = "io-fn-pay-portal-KEY-APIM"
      io-fn-cgnmerchant-key                         = "io-fn-cgnmerchant-KEY-APIM"
      io-fn3-eucovidcert-key                        = "io-fn3-eucovidcert-KEY-APIM"
      io-mit-voucher-clientid                       = "io-mit-voucher-clientid-KEY-APIM"
    }
  }

  custom_domains = {
    key_vault_id     = dependency.key_vault.outputs.id
    certificate_name = "api-internal-io-italia-it"
    domains = [
      {
        name    = "api-internal.io.italia.it"
        default = true
      }
    ]
  }

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key
}
