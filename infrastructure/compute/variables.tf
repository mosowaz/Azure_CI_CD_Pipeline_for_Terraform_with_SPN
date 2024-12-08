variable "location1" {
  type    = string
  default = "canadacentral"
}

variable "location2" {
  type    = string
  default = "canadaeast"
}

variable "mypassword" {
  sensitive = true
}

variable "spokes-vm" {
  type = map(object({
    name           = string
    size           = string
    admin_username = string
    rg_name        = string
    rg_location    = string
    public_key     = string  # environment variable to be passed from pipeline (key vault)
    private_ip     = string
    private_key    = string  # environment variable to be passed from pipeline (key vault)
  }))
  default = {
    "spoke1" = {
      name           = "spoke1-vm"
      size           = "Standard_B1s"
      admin_username = "adminuser"
      rg_name        = azurerm_resource_group.rg2.name
      rg_location    = azurerm_resource_group.rg2.location
      public_key     = var.sp1-sshkey-pub
      private_ip     = "172.16.1.12"
      private_key    = var.sp1-sshkey
    }
    "spoke2" = {
      name           = "spoke2-vm"
      size           = "Standard_B1s"
      admin_username = "adminuser"
      rg_name        = azurerm_resource_group.rg1.name
      rg_location    = azurerm_resource_group.rg1.location
      public_key     = var.sp2-sshkey-pub
      private_ip     = "192.168.1.13"
      private_key    = var.sp2-sshkey
    }
  }
}

variable "hub-vm" {
  type = object({
    name           = string
    size           = string
    admin_username = string
    public_key     = string  
    private_ip     = string
    private_key    = string  # environment variable to be passed from pipeline (key vault)
  })
  default = {
    name           = "hub-vm"
    size           = "Standard_B1s"
    admin_username = "adminuser"
    private_ip     = "10.0.1.11"
    public_key     = var.hub-sshkey-pub
    private_key    = var.hub-sshkey
  }
}

variable "hub-sshkey" {}      # environment variable to be passed from pipeline (key vault)
variable "hub-sshkey-pub" {}       # environment variable to be passed from pipeline (key vault)
variable "sp1-sshkey" {}   # environment variable to be passed from pipeline (key vault)
variable "sp1-sshkey-pub" {}    # environment variable to be passed from pipeline (key vault)
variable "sp2-sshkey" {}   # environment variable to be passed from pipeline (key vault)
variable "sp2-sshkey-pub" {}    # environment variable to be passed from pipeline (key vault)