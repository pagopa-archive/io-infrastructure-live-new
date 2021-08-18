# Io infrastructure live

This repository contains the full set of [terragunt](https://terragrunt.gruntwork.io/) modules useful to build the **cloud infrastructure** which hosts the backend applications of the [mobile app IO](https://io.italia.it/).
In this case the public cloud provider is [Azure](https://azure.microsoft.com/).

The terragrunt code works in close relationship with terraform modules stored in this separate repository: [io-infrastructure-modules-new](https://github.com/pagopa/io-infrastructure-modules-new)

## Requirements

In order to mange the suitable version of terraform and terragrunt it is strongly recommended to install the following tools:

* [tfenv](https://github.com/tfutils/tfenv): **Terraform** version manager inspired by rbenv.
* [tgenv](https://github.com/cunymatthieu/tgenv): **Terragrunt** version manager inspired by tfenv.

Once these tools have been installed, install the terraform version and terragrunt version shown in:
 * .terraform-version
 * .terragrunt-version


```
$ git clone https://github.com/pagopa/io-infrastructure-live-new.git
$ cd io-infrastructure-live-new/
$ cat .terraform-version
0.13.3

$ # Install terraform
$ tfenv install 0.13.3

$ cat .terragrunt-version
0.25.1

$ # Install terragrunt
$ tgenv install 0.25.1
```

### Important !!!

Do not work with a terraform version other than the one set in the file __.terraform-version__.

## Start building the infrastructure

It's possible to start building the infrastructure with __terragrunt plan-all__ and __terragrunt apply-all__ commands, but it's better to create one resource at a time starting with the simplest resources that do not have dependencies like the Resource Group.

### Initialize

```
$ cd prod/westeurope/common/resource_group/
$ terragrunt init
[terragrunt] [/io-infrastructure-live-new/prod/westeurope/common/resource_group] 2020/12/20 17:14:09 Running command: terraform --version
[terragrunt] 2020/12/20 17:14:10 Terraform version: 0.13.3
[terragrunt] 2020/12/20 17:14:10 Reading Terragrunt config file at /io-infrastructure-live-new/prod/westeurope/common/resource_group/terragrunt.hcl
.............
.............

Initializing the backend...

Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "2.36.0"...
- Using hashicorp/azurerm v2.36.0 from the shared cache directory

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.
$
```

### Apply changes

```
$ terragrunt apply
[terragrunt] 2020/12/20 17:19:06 Running command: terraform apply
Acquiring state lock. This may take a few moments...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.resource_group will be created
  + resource "azurerm_resource_group" "resource_group" {
      + id       = (known after apply)
      + location = "westeurope"
      + name     = "io-p-rg-common"
      + tags     = {
          + "environment" = "prod"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
(
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

To go deeper in terraform **workflow** please refer to the [official documentation](https://www.terraform.io/guides/core-workflow.html).

## Install custom provider

Due an issue on function app module we need to use a custom provider https://github.com/hashicorp/terraform-provider-azurerm/pull/10494

```sh
### This script works only for MacOS
wget "https://github.com/pagopa/terraform-provider-azurerm/releases/download/2.46-beta.1/terraform-provider-azurerm-darwin-amd64"

mkdir -p ${HOME}/.terraform.d/plugin-cache/registry.terraform.io/hashicorp/azurerm/2.46.1/darwin_amd64/

rm -rf ${HOME}/.terraform.d/plugin-cache/registry.terraform.io/hashicorp/azurerm/2.46.1/darwin_amd64/terraform-provider-azurerm_v2.46.1_x5

mv terraform-provider-azurerm-darwin-amd64 ${HOME}/.terraform.d/plugin-cache/registry.terraform.io/hashicorp/azurerm/2.46.1/darwin_amd64/terraform-provider-azurerm_v2.46.1_x5

### First plan will fail, you need to authorize terraform-provider-azurerm_v2.46.1_x5 execution in
### System Preferences -> Security & Privacy -> General -> Allow apps downloaded from
```
