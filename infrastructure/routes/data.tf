data "azurerm_resource_group" "rg1" {
  name = "rg-${var.location1}"
}

data "azurerm_resource_group" "rg2" {
  name = "rg-${var.location2}"
}

data "azurerm_subnet" "subnet1" {
  name                 = "vnet-1-subnet"
  virtual_network_name = "vnet-1"
  resource_group_name  = data.azurerm_resource_group.rg1.name
}

data "azurerm_subnet" "subnet2" {
  name                 = "vnet-2-subnet"
  virtual_network_name = "vnet-2"
  resource_group_name  = data.azurerm_resource_group.rg2.name
}

data "azurerm_subnet" "subnet3" {
  name                 = "vnet-3-subnet"
  virtual_network_name = "vnet-3"
  resource_group_name  = data.azurerm_resource_group.rg1.name
}

data "azurerm_network_security_group" "hub-nsg" {
  name                = azurerm_network_security_group.hub-nsg.name
  resource_group_name = azurerm_resource_group.rg1.name
}

data "azurerm_network_security_group" "spokes-nsg" {
  name                = azurerm_network_security_group.spokes-nsg.name
  resource_group_name = azurerm_resource_group.rg1.name
}

data "azurerm_route_table" "spoke1-2" {
  name                = azurerm_route_table.spoke1-2.name
  resource_group_name = azurerm_resource_group.rg2.name
}

data "azurerm_route_table" "spoke2-1" {
  name                = azurerm_route_table.spoke2-1.name
  resource_group_name = azurerm_resource_group.rg1.name
}