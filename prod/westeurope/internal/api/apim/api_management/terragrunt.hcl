dependency "functions_test" {
  config_path = "../../functions_test/function_app"
}

dependency "functions_admin" {
  config_path = "../../functions_admin/function_app"
}

dependency "functions_services_r3" {
  config_path = "../../functions_services_r3/function_app"
}

dependency "functions_public" {
  config_path = "../../functions_public/function_app"
}

dependency "functions_public_r3" {
  config_path = "../../functions_public_r3/function_app"
}

dependency "functions_bonusapi" {
  config_path = "../../functions_bonusapi_r3/function_app"
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

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_api_management?ref=v2.0.25"
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
    io-functions-admin-url    = "http://${dependency.functions_admin.outputs.default_hostname}"
    io-functions-public-url   = "http://${dependency.functions_public.outputs.default_hostname}"
    io-fn3-public-url         = "http://${dependency.functions_public_r3.outputs.default_hostname}"
    io-functions-test-url     = "http://${dependency.functions_test.outputs.default_hostname}"
    io-fn3-services-url       = "http://${dependency.functions_services_r3.outputs.default_hostname}"
    io-functions-bonusapi-url = "http://${dependency.functions_bonusapi.outputs.default_hostname}"
  }

  named_values_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      apigad-gad-client-certificate-verified-header = "apigad-GAD-CLIENT-CERTIFICATE-VERIFIED-HEADER"
      io-functions-admin-key                        = "funcadmin-KEY-APIM"
      io-functions-public-key                       = "funcpublic-KEY-APIM"
      io-fn3-public-key                             = "fn3public-KEY-APIM"
      io-functions-test-key                         = "functest-KEY-APIM"
      io-fn3-services-key                           = "fn3services-KEY-APIM"
      io-functions-bonusapi-key                     = "funcbonusapi-KEY-APIM"
    }
  }

  custom_domains = {
    key_vault_id     = dependency.key_vault.outputs.id
    certificate_name = "io-italia-it"
    domains = [
      {
        name    = "api-internal.io.italia.it"
        default = true
      }
    ]
  }

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key
}
