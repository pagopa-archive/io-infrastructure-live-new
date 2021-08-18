dependency "resource_group" {
  config_path = "../../../resource_group"
}

dependency "storage_account" {
  config_path = "../account"
}

# Common
dependency "subnet_pendpoints" {
  config_path = "../../../../common/subnet_pendpoints"
}

dependency "private_dns_zone" {
  config_path = "../../../../common/private_dns_zones/privatelink-blob-core-windows-net/zone"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_private_endpoint?ref=v3.0.10"
}

inputs = {
  name                = "${dependency.storage_account.outputs.resource_name}-blob-endpoint"
  resource_group_name = dependency.resource_group.outputs.resource_name
  subnet_id           = dependency.subnet_pendpoints.outputs.id

  private_service_connection = {
    name                           = "${dependency.storage_account.outputs.resource_name}-blob"
    private_connection_resource_id = dependency.storage_account.outputs.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_ids = [dependency.private_dns_zone.outputs.id]
}