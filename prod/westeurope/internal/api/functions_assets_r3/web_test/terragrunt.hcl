# Common
dependency "application_insights" {
  config_path = "../../../../common/application_insights"
}

dependency "resource_group" {
  config_path = "../../../../common/resource_group"
}

dependency "function_app" {
  config_path = "../function_app"
}


# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_application_insights_web_test?ref=v3.0.3"
}

inputs = {
  name = "func-assets"

  resource_group_name     = dependency.resource_group.outputs.resource_name
  application_insights_id = dependency.application_insights.outputs.id
  enabled                 = true
  geo_locations           = ["emea-nl-ams-azr"]

  url = format("https://%s/info", dependency.function_app.outputs.default_hostname)
}
