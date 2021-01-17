variable "location" {
  description = "location"
  type        = string
}

variable "resource_group_name" {
  description = "resource group name"
  type        = string
}

variable "virtual_network" {
  description = "virtual network name"
  type        = string
}

variable "vm_hostname" {
  description = "vm hostname"
  type        = string
}

variable "nsg_name" {
  description = "network security group name"
  type        = string
}

variable "nic_name" {
  description = "network interface name"
  type        = string
}


variable "tags" {
  description = "The tags to associate resource."
  type        = map(string)

  default = {
    tag1 = ""
    tag2 = ""
  }
}