# Internal
dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "subnet_fn_private" {
  config_path = "../../functions_private_r3/subnet"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_cosmosdb_account?ref=v3.0.3"
}

inputs = {
  name                = "private"
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

  allowed_virtual_network_subnet_ids = [
    dependency.subnet_fn_private.outputs.id,
  ]
}
