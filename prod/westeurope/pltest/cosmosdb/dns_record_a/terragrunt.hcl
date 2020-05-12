# DSN private Zone 
dependency "resource_group" {
  config_path = "../../resource_group"
}

dependency "private_endpoint" {
  config_path = "../private_endpoint"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_private_dns_a_record?ref=v2.0.23"
}

inputs = {
  resource_group_name = dependency.resource_group.outputs.resource_name
  zone_name           = "privatelink.documents.azure.com"
  name                = "io-p-cosmos-pltest"
  ttl                 = 300
  records             = dependency.private_endpoint.outputs.private_ip_address
}
