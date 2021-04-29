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
  name = "func-services-cache"

  resource_group_name     = dependency.resource_group.outputs.resource_name
  application_insights_id = dependency.application_insights.outputs.id
  # test disabled: so far the info page requires the authorization key we don't want to put in web tests.
  enabled       = true
  geo_locations = ["emea-nl-ams-azr"]

  url = format("https://%s/api/v1/info", dependency.function_app.outputs.default_hostname)
}
