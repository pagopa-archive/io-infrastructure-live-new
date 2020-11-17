# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

dependency "subnet_fn_admin" {
  config_path = "../../functions_admin_r3/subnet"
}

dependency "subnet_fn_app" {
  config_path = "../../functions_app_r3/subnet"
}

dependency "subnet_fn_assets" {
  config_path = "../../functions_assets_r3/subnet"
}

dependency "subnet_fn_public" {
  config_path = "../../functions_public_r3/subnet"
}

dependency "subnet_fn_service" {
  config_path = "../../functions_services_r3/subnet"
}

# Operation logic app.

dependency "logic_app_get_profiles" {
  config_path = "../../../../operations/logic-apps/logic-app-privacy-get-profiles"
}

dependency "logic_app_privacy_upsert_user_data_processing" {
  config_path = "../../../../operations/logic-apps/logic-app-privacy-upsert-user-data-processing"
}


locals {
  fn3_slackbot_outbound_ips = "23.97.147.242,13.69.61.42,137.117.159.137,104.47.161.199,104.47.157.240"
  other_azure_ips           = "13.69.67.192,40.74.26.40,40.74.27.106,40.74.27.92,52.148.245.13"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cosmosdb_account?ref=v2.1.11"
}

inputs = {
  name                = "api"
  resource_group_name = dependency.resource_group.outputs.resource_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy = {
    consistency_level       = "Session"
    max_interval_in_seconds = null
    max_staleness_prefix    = null
  }

  main_geo_location_location = "westeurope"

  additional_geo_locations = [
    {
      location          = "northeurope"
      failover_priority = 1
    }
  ]

  is_virtual_network_filter_enabled = true

  ip_range = format("%s,%s,%s,%s",
    local.fn3_slackbot_outbound_ips,
    local.other_azure_ips,
    join(",", dependency.logic_app_get_profiles.outputs.workflow_outbound_ip_addresses),
    join(",", dependency.logic_app_privacy_upsert_user_data_processing.outputs.workflow_outbound_ip_addresses)
  )

  allowed_virtual_network_subnet_ids = [
    dependency.subnet_fn_admin.outputs.id,
    dependency.subnet_fn_app.outputs.id,
    dependency.subnet_fn_assets.outputs.id,
    dependency.subnet_fn_public.outputs.id,
    dependency.subnet_fn_service.outputs.id,
  ]
}
