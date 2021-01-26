output "public_ip" {
  value = azurerm_linux_virtual_machine.this.public_ip_address
}

output "ssh_connection" {
  value = "ssh azureuser@${azurerm_linux_virtual_machine.this.public_ip_address} -i ${path.module}/tmp/id_rsa_azure -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
}

output "fetch_kubeconfig" {
  value = "scp -i ${path.module}/tmp/id_rsa_azure -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null azureuser@${azurerm_linux_virtual_machine.this.public_ip_address}:/tmp/admin.kubeconfig ./kubeconfig"
}