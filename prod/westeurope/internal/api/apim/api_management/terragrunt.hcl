dependency "functions_test" {
  config_path = "../../functions_test/function_app"
}

dependency "functions_services" {
  config_path = "../../functions_services/function_app"
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_api_management?ref=v0.0.42"
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
    io-functions-test-url = "https://${dependency.functions_test.outputs.default_hostname}"
    io-functions-test-key = dependency.functions_test.outputs.default_key

    io-functions-services-url = "https://${dependency.functions_services.outputs.default_hostname}"
    io-functions-services-key = dependency.functions_services.outputs.default_key
  }

  named_values_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      apigad-gad-client-certificate-verified-header = "apigad-GAD-CLIENT-CERTIFICATE-VERIFIED-HEADER"
    }
  }

  custom_domains = {
    key_vault_id     = dependency.key_vault.outputs.id
    certificate_name = "prod-io-italia-it"
    domains = [
      {
        name    = "api.prod.io.italia.it"
        default = true
      },
      {
        name    = "api-gad.prod.io.italia.it"
        default = false
      }
    ]
  }

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key
}
