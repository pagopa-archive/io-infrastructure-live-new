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
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_application_insights_web_test?ref=update-azurerm-v2.87.0"
}

inputs = {
  name = "func-bonus"

  resource_group_name     = dependency.resource_group.outputs.resource_name
  application_insights_id = dependency.application_insights.outputs.id
  # TODO: enable the web test when the function auth level is anonymous for the info api.
  enabled       = false
  geo_locations = ["emea-nl-ams-azr"]

  url = format("https://%s/v1/bonus/info", dependency.function_app.outputs.default_hostname)
}
