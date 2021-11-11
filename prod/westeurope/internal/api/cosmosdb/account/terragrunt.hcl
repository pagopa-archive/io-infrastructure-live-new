# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

dependency "subnet_fn_admin" {
  config_path = "../../functions_admin_r3/subnet"
}

dependency "subnet_fn_app1" {
  config_path = "../../../../functions_app1/functions_app1_r3/subnet"
}

dependency "subnet_fn_app2" {
  config_path = "../../functions_app2_r3/subnet"
}

dependency "subnet_fn_appasync" {
  config_path = "../../functions_app_async/subnet"
}

dependency "subnet_fn_assets" {
  config_path = "../../functions_assets_r3/subnet"
}

dependency "subnet_fn_public" {
  config_path = "../../functions_public_r3/subnet"
}

dependency "subnet_fn_services" {
  config_path = "../../functions_services_r3/subnet"
}

dependency "subnet_fn_servicescache" {
  config_path = "../../functions_servicescache_r3/subnet"
}

dependency "subnet_fn_slackbot" {
  config_path = "../../../../operations/functions_slackbot/subnet"
}

# Operation logic app.

dependency "logic_app_privacy_get_profiles" {
  config_path = "../../../../operations/logic-apps/logic-app-privacy-get-profiles"
}

dependency "logic_app_privacy_upsert_user_data_processing" {
  config_path = "../../../../operations/logic-apps/logic-app-privacy-upsert-user-data-processing"
}

# only backup ips, probably not needed
# locals {
#   other_azure_ips = "13.69.67.192,40.74.26.40,40.74.27.106,40.74.27.92,52.148.245.13"
# }

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cosmosdb_account?ref=v4.0.1"
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

  ip_range = format("%s,%s",
    join(",", dependency.logic_app_privacy_get_profiles.outputs.connector_outbound_ip_addresses),
    join(",", dependency.logic_app_privacy_upsert_user_data_processing.outputs.connector_outbound_ip_addresses)
  )

  # IMPORTANT: with private endpoint enabled virtual_network_subnet not take any effect
  allowed_virtual_network_subnet_ids = [
    dependency.subnet_fn_admin.outputs.id,
    dependency.subnet_fn_app1.outputs.id,
    dependency.subnet_fn_app2.outputs.id,
    dependency.subnet_fn_appasync.outputs.id,
    dependency.subnet_fn_assets.outputs.id,
    dependency.subnet_fn_public.outputs.id,
    dependency.subnet_fn_services.outputs.id,
    dependency.subnet_fn_servicescache.outputs.id,
    dependency.subnet_fn_slackbot.outputs.id,
  ]

  lock = {
    name       = "cosmos-api"
    lock_level = "CanNotDelete"
    notes      = null
  }
}
