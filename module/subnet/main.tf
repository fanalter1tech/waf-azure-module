resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = "subnet-${each.value.name}-prod-001"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = "${each.value.address_prefixes}"
}