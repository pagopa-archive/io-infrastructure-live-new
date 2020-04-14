# Configure common remote state
remote_state {
  backend = "azurerm"

  config = {
    resource_group_name  = "${get_env("IO_TERRAFORM_BACKEND_RG", "io-infra-rg")}"
    storage_account_name = "${get_env("IO_TERRAFORM_BACKEND_SA", "ioinfrastterraform")}"
    container_name       = "${get_env("IO_TERRAFORM_BACKEND_CNT", "tfstate")}"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

locals {
  default_yaml_path = find_in_parent_folders("empty.yaml")
}

inputs = merge(
  yamldecode(
    file(find_in_parent_folders("global.yaml", local.default_yaml_path)),
  ),
  yamldecode(
    file(find_in_parent_folders("env.yaml", local.default_yaml_path)),
  ),
  yamldecode(
    file(find_in_parent_folders("region.yaml", local.default_yaml_path)),
  )
)
