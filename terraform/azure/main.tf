# Create a resource group
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Create virtual network
resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  tags = var.tags
}

# Create subnet
resource "azurerm_subnet" "this" {
  name                 = "default-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public ip
resource "azurerm_public_ip" "this" {
  name                = "${var.vm_hostname}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"

  tags = var.tags
}

# Create network security group
resource "azurerm_network_security_group" "this" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Kubernetes"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Create network interface
resource "azurerm_network_interface" "this" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "nic-configuration"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = var.vm_hostname
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${path.module}/tmp/id_rsa_azure.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  custom_data = local.custom_data

  tags = var.tags

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "azureuser"
      host        = self.public_ip_address
      timeout     = "10m"
      private_key = file("${path.module}/tmp/id_rsa_azure")
    }
    inline = [
      "sudo time cloud-init status -w -l",
      "sudo cp /etc/kubernetes/admin.kubeconfig /tmp/admin.kubeconfig",
      "sudo sed -i \"s/${self.private_ip_address}/${self.public_ip_address}/g\" /tmp/admin.kubeconfig",
      "sudo chmod 777 /tmp/admin.kubeconfig"
    ]
  }

  provisioner "local-exec" {
    command    = "scp -i ${path.module}/tmp/id_rsa_azure -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null azureuser@${self.public_ip_address}:/tmp/admin.kubeconfig ./tmp/kube-config.txt"
    on_failure = continue
  }
}

locals {
  custom_data = filebase64("${path.module}/custom_data.sh")
}
