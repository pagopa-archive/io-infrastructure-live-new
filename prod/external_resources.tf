locals {
  subnets = {
    # https://github.com/pagopa/io-infra/blob/main/src/core/appgateway.tf#L13
    io-p-appgateway-snet  = "/subscriptions/ec285037-c673-4f58-b594-d7c480da4e8b/resourceGroups/io-p-rg-common/providers/Microsoft.Network/virtualNetworks/io-p-vnet-common/subnets/io-p-appgateway-snet"
    # https://github.com/pagopa/io-infra/blob/main/src/core/apim.tf#L2
    apimapi               = "/subscriptions/ec285037-c673-4f58-b594-d7c480da4e8b/resourceGroups/io-p-rg-common/providers/Microsoft.Network/virtualNetworks/io-p-vnet-common/subnets/apimapi"
    # https://github.com/pagopa/io-infra/blob/main/src/core/function_publiceventdispatcher.tf#L14
    fnpblevtdispatcherout = "/subscriptions/ec285037-c673-4f58-b594-d7c480da4e8b/resourceGroups/io-p-rg-common/providers/Microsoft.Network/virtualNetworks/io-p-vnet-common/subnets/fnpblevtdispatcherout"
  }
}
