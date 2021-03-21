dependency "api_management" {
  config_path = "../api_management"
}

# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_api_management_api?ref=v3.0.0"
}

inputs = {
  name                  = "io-payportal-api"
  resource_group_name   = dependency.resource_group.outputs.resource_name
  api_management_name   = dependency.api_management.outputs.name
  revision              = "1"
  display_name          = "IO PAYPORTAL API"
  description           = "PAYPORTAL API for pagoPA platform."
  host                  = "api.io.italia.it"
  path                  = "api/payportal/v1"
  protocols             = ["http", "https"]
  swagger_json_template = file("swagger.json.tmpl")
  policy_xml            = file("policy.xml")

  subscription_required = false

}
