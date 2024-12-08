data "azurerm_virtual_network" "vnet1" {
  name = azurerm_virtual_network.vnet1.name
  resource_group_name = azurerm_virtual_network.vnet1.resource_group_name
}

data "azurerm_virtual_network" "vnet2" {
  name = azurerm_virtual_network.vnet2.name
  resource_group_name = azurerm_virtual_network.vnet2.resource_group_name
}

data "azurerm_virtual_network" "vnet3" {
  name = azurerm_virtual_network.vnet3.name
  resource_group_name = azurerm_virtual_network.vnet3.resource_group_name
}
