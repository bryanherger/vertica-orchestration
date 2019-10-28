output "hostname" {
  value = "${var.hostname}"
}

output "vertica_fqdn" {
  value = "${azurerm_public_ip.lbpip.fqdn}"
}

output "resource_group" {
  value = "${var.resource_group}"
}

output "vm_admin_username" {
  value = "${var.vm_admin_username}"
}

output "mcnode_ip_address" {
  value = "${azurerm_public_ip.mcnode.ip_address}"
}

output "mcnode_ssh_command" {
  value = "ssh ${var.vm_admin_username}@${azurerm_public_ip.mcnode.ip_address}"
}

output "mcnode_web_ui_public_ip" {
  value = "https://${azurerm_public_ip.mcnode.ip_address}:5450/webui"
}
