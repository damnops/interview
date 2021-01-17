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
    public_key = file("${path.module}/id_rsa_azure.pub")
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
      private_key = file("${path.module}/id_rsa_azure")
    }
    inline = [
      "sudo time cloud-init status -w -l",
      "sudo cp /etc/kubernetes/admin.kubeconfig /tmp/admin.kubeconfig",
      "sudo sed -i \"s/${self.private_ip_address}/${self.public_ip_address}/g\" /tmp/admin.kubeconfig",
      "sudo chmod 777 /tmp/admin.kubeconfig"
    ]
  }

  provisioner "local-exec" {
    command    = "scp -i ${path.module}/id_rsa_azure -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null azureuser@${self.public_ip_address}:/tmp/admin.kubeconfig ./kubeconfig"
    on_failure = continue
  }
}

locals {
  custom_data = "IyEvYmluL2Jhc2gKc3VkbyAtaQpleHBvcnQgTENfQUxMPSJlbl9VUy5VVEYtOCIKZXhwb3J0IExDX0NUWVBFPSJlbl9VUy5VVEYtOCIKCndnZXQgaHR0cDovL2FydGlmYWN0LnNwbHVuay5vcmcuY24veXEvcmVsZWFzZXMvZG93bmxvYWQvdjQuMy4yL3lxX2xpbnV4X2FtZDY0IC1PIC91c3IvYmluL3lxCmNobW9kICt4IC91c3IvYmluL3lxCgpzc2gta2V5Z2VuIC10IHJzYSAtUCAiIiAtZiB+Ly5zc2gvaWRfcnNhCmNhdCB+Ly5zc2gvaWRfcnNhLnB1YiA+PiB+Ly5zc2gvYXV0aG9yaXplZF9rZXlzCgphcHQtZ2V0IHVwZGF0ZQphcHQtZ2V0IGluc3RhbGwgZ2l0IG1ha2UgcHl0aG9uMyBweXRob24zLXBpcCBzc2hwYXNzIGN1cmwgcnN5bmMgLXkKCnBpcDMgaW5zdGFsbCAtLXVwZ3JhZGUgcGlwCnBpcDMgaW5zdGFsbCBhbnNpYmxlPT0yLjEwLjQKCmdpdCBjbG9uZSBodHRwczovL2dpdGVlLmNvbS90b2MtbGliL2t1YmUtYW5zaWJsZS5naXQgL3Vzci9sb2NhbC9zcmMva3ViZS1hbnNpYmxlCnB1c2hkIC91c3IvbG9jYWwvc3JjL2t1YmUtYW5zaWJsZQpjcCBncm91cF92YXJzL3RlbXBsYXRlLnltbCBncm91cF92YXJzL2FsbC55bWwKClBVQkxJQ19JUD0kKGN1cmwgLXMgd3d3LnB1Ynl1bi5jb20vZHluZG5zL2dldGlwKQp5cSBldmFsIC0taW5wbGFjZSAiKC5rdWJlcm5ldGVzLnNzbC5leHRlbnNpb24uWzBdKSA9IFwiJFBVQkxJQ19JUFwiIiBncm91cF92YXJzL2FsbC55bWwKCnlxIGV2YWwgLS1pbnBsYWNlICcoLmFuc2libGVfcHl0aG9uX2ludGVycHJldGVyKSA9ICIvdXNyL2Jpbi9weXRob24zIicgZ3JvdXBfdmFycy9hbGwueW1sCnlxIGV2YWwgLS1pbnBsYWNlICcoLmt1YmVybmV0ZXMua3ViZWxldC5wb2RfaW5mcmFfY29udGFpbmVyX2ltYWdlKSA9ICJrOHMuZ2NyLmlvL3BhdXNlOjMuMiInIGdyb3VwX3ZhcnMvYWxsLnltbAp5cSBldmFsIC0taW5wbGFjZSAnKC5rdWJlcm5ldGVzLnNldHRpbmdzLm1hc3Rlcl9ydW5fcG9kKSA9ICJ0cnVlIicgZ3JvdXBfdmFycy9hbGwueW1sCgpQUklWQVRFX0lQPSQoaG9zdG5hbWUgLWkpCgojIGluaXQgaW52ZW50b3J5IGZpbGUKZWNobyAiW21hc3Rlcl0iID4gaW52ZW50b3J5L2hvc3RzCmVjaG8gIiRQUklWQVRFX0lQIiA+PiBpbnZlbnRvcnkvaG9zdHMKZWNobyAiW3dvcmtlcl0iID4+IGludmVudG9yeS9ob3N0cwplY2hvICJba3ViZXJuZXRlczpjaGlsZHJlbl0iID4+IGludmVudG9yeS9ob3N0cwplY2hvICJtYXN0ZXIiID4+IGludmVudG9yeS9ob3N0cwplY2hvICJ3b3JrZXIiID4+IGludmVudG9yeS9ob3N0cwoKbWFrZSBpbnN0YWxsIERPV05MT0FEX1dBWT1xaW5pdSB8IHRlZSAvdG1wL2t1YmUtYW5zaWJsZS5sb2cKcG9wZAo="
}
