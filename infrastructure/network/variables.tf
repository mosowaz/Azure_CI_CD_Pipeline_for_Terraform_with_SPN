variable "location1" {
  type = string
  default = "canadacentral" 
}

variable "location2" {
  type = string
  default = "canadaeast" 
}

variable "lab_tag" {
  default = "hub-spoke"
}

variable "vnet1" { 
  type = object({
    address_space = string
    vnet_name     = string
    address_prefixes = string
  })
  default = {
    address_space = "10.0.0.0/16"
    vnet_name     = "vnet-1"
    address_prefixes = "10.0.1.0/24"
  }
}

variable "vnet2" { 
  type = object({
    address_space = string
    vnet_name     = string
    address_prefixes = string
  })
  default = {
    address_space = "172.16.0.0/16"
    vnet_name     = "vnet-2"
    address_prefixes = "172.16.1.0/24"
  }
}

variable "vnet3" { 
  type = object({
    address_space = string
    vnet_name     = string
    address_prefixes = string
  })
  default = {
    address_space = "192.168.0.0/16"
    vnet_name     = "vnet-3"
    address_prefixes = "192.168.1.0/24"
  }
}