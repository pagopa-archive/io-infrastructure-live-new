dependency "resource_group" {
  config_path = "../resource_group"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_dns_caa_record?ref=v2.0.18"
}

inputs = {
  name                = "io.italia.it"
  resource_group_name = dependency.resource_group.outputs.resource_name
  zone_name           = "io.italia.it"
  ttl                 = 300

  records = [{
    flags = 0
    tag   = "issue"
    value = "io.italia.it"
  }]
}
