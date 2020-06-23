dependency "api_management" {
  config_path = "../api_management"
}

dependency "api_management_product_io-bonusvacanze-api" {
  config_path = "../api_management_product_io-bonusvacanze-api"
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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_api_management_api?ref=v2.0.25"
}

inputs = {
  name                  = "io-bonusvacanze-api"
  resource_group_name   = dependency.resource_group.outputs.resource_name
  api_management_name   = dependency.api_management.outputs.name
  revision              = "1"
  display_name          = "IO BONUS VACANZE API"
  description           = "BONUS VACANZE API for IO platform."
  host                  = "api.io.italia.it"
  path                  = "api/bonus-vacanze/v1"
  protocols             = ["http"]
  swagger_json_template = file("swagger.json.tmpl")
  policy_xml            = file("policy.xml")

  product_ids = [
    dependency.api_management_product_io-bonusvacanze-api.outputs.product_id
  ]
}
