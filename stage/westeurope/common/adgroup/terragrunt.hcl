# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azuread_group?ref=v0.0.16"
}

inputs = {
  name = "common"
}
