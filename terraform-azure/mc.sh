#!/bin/bash
# ${var.vm_admin_username}@${azurerm_public_ip.mcnode.ip_address}
ssh -i verticatf.sshkey -o stricthostkeychecking=false `terraform output vm_admin_username`@`terraform output mcnode_ip_address`

