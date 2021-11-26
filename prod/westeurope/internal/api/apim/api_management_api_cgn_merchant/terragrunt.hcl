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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_api_management_api?ref=update-azurerm-v2.87.0"
}

inputs = {
  name                  = "io-cgn-merchant-api"
  resource_group_name   = dependency.resource_group.outputs.resource_name
  api_management_name   = dependency.api_management.outputs.name
  revision              = "1"
  display_name          = "IO CGN MERCHANT API"
  description           = "CGN MERCHANT API for IO platform."
  host                  = "api.io.italia.it"
  path                  = "api/v1/merchant/cgn"
  protocols             = ["http", "https"]
  swagger_json_template = file("swagger.json.tmpl")
  policy_xml            = file("policy.xml")

}
