resource "azurerm_resource_group" "rg1" {
  name     = data.azurerm_resource_group.rg1.name
  location = data.azurerm_resource_group.rg1.location
  tags = {
    resource = data.azurerm_resource_group.rg1.tags
  }
}

resource "azurerm_resource_group" "rg2" {
  name     = data.azurerm_resource_group.rg2.name
  location = data.azurerm_resource_group.rg2.location
  tags = {
    resource = data.azurerm_resource_group.rg2.tags
  }
}

resource "azurerm_network_interface" "spoke-nic" {
  for_each = tomap({
    spoke1 = {
      name       = "${data.azurerm_subnet.subnet2.name}-nic"
      location   = azurerm_resource_group.rg2.location
      rg_name    = azurerm_resource_group.rg2.name
      subnet_id  = data.azurerm_subnet.subnet2.subnet_id
      private_ip = var.spokes-vm.spoke1.private_ip
      public_ip_address_id = data.azurerm_public_ip.spoke1_pub_ip.id
    }
    spoke2 = {
      name       = "${data.azurerm_subnet.subnet3.name}-nic"
      location   = azurerm_resource_group.rg1.location
      rg_name    = azurerm_resource_group.rg1.name
      subnet_id  = data.azurerm_subnet.subnet3.subnet_id
      private_ip = var.spokes-vm.spoke2.private_ip
      public_ip_address_id = data.azurerm_public_ip.spoke2_pub_ip.id
    }
  })
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.private_ip
    public_ip_address_id          = each.value.public_ip_address_id
  }
}

resource "azurerm_public_ip" "hub_pub_ip" {
  name                = "hub-pub-ip"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "spoke1_pub_ip" {
  name                = "spoke1-pub-ip"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "spoke2_pub_ip" {
  name                = "spoke2-pub-ip"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "hub-nic" {
  name                  = "${data.azurerm_subnet.subnet1.name}-nic"
  location              = azurerm_resource_group.rg1.location
  resource_group_name   = azurerm_resource_group.rg1.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet1.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.hub-vm.private_ip
    public_ip_address_id          = data.azurerm_public_ip.hub_pub_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "spokes-vm" {
  for_each            = var.spokes-vm
  name                = each.value.name
  resource_group_name = each.value.rg_name
  location            = each.value.rg_location
  size                = each.value.size
  admin_username      = each.value.admin_username
  network_interface_ids = [
    data.azurerm_network_interface.spoke-nic[each.key].id
  ]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo -e \\n"10.0.1.11 hub-vm"\\n >> /etc/hosts
              echo -e "172.16.1.12 spoke1-vm"\\n >> /etc/hosts
              echo -e "192.168.1.13 spoke2-vm"\\n >> /etc/hosts
              EOF
  )

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = file(each.value.public_key)
  }
  #admin_password = var.mypassword
  #disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  connection {
    type        = "ssh"
    user        = self.admin_username
    private_key = file(each.value.private_key)
    host        = self.public_ip_address
  }
}

resource "azurerm_linux_virtual_machine" "hub-vm" {
  depends_on          = [data.azurerm_network_interface.hub-nic, data.azurerm_public_ip.hub_pub_ip]
  name                = var.hub-vm.name
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  size                = var.hub-vm.size
  admin_username      = var.hub-vm.admin_username
  network_interface_ids = [
    data.azurerm_network_interface.hub-nic.id
  ]

  # Enable IP forwarding on the NVA by uncommenting the line as shown below
  user_data = base64encode(<<-EOF
              #!/bin/bash
              sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
              echo -e \\n"10.0.1.11 hub-vm"\\n >> /etc/hosts
              echo -e "172.16.1.12 spoke1-vm"\\n >> /etc/hosts
              echo -e "192.168.1.13 spoke2-vm"\\n >> /etc/hosts
              EOF
  )

  admin_ssh_key {
    username   = var.hub-vm.admin_username
    public_key = file(var.hub-vm.public_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  connection {
    type        = "ssh"
    user        = self.admin_username
    private_key = file(var.hub-vm.private_key)
    host        = self.public_ip_address
  }
}