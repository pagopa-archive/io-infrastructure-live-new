dependency "cosmosdb_bonus_account" {
  config_path = "../account"
}

dependency "private_endpoint" {
  config_path = "../private_endpoint"
}

dependency "resource_group" {
  config_path = "../../../resource_group"
}

# Common
dependency "resource_group_common" {
  config_path = "../../../../common/resource_group"
}

dependency "private_dns_zone" {
  config_path = "../../../../common/private_dns_zones/privatelink-documents-azure-com/zone"
}


# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_private_dns_a_record?ref=v2.1.0"
}

inputs = {
  resource_group_name = dependency.resource_group_common.outputs.resource_name
  zone_name           = dependency.private_dns_zone.outputs.name[0]
  name                = dependency.cosmosdb_bonus_account.outputs.name
  ttl                 = 3600
  records             = dependency.private_endpoint.outputs.private_ip_address
}
