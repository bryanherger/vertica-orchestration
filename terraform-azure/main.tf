# adapted from examples at https://github.com/terraform-providers/terraform-provider-azurerm/tree/mcnode/examples/virtual-machines/spark-and-cassandra-on-centos
# and https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/examples/virtual-machines/2-vms-loadbalancer-lbrules

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

resource "azurerm_availability_set" "avset" {
  name                         = "${var.dns_name}avset"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_public_ip" "lbpip" {
  name                = "${var.unique_prefix}_ip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.lb_ip_dns_name}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name}"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.unique_prefix}_subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_prefix}"
}

resource "azurerm_lb" "lb" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  name                = "${var.unique_prefix}lb"
  location            = "${var.location}"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.lbpip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "BackendPool1"
}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 5433
  backend_port                   = 5433
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 5433
  interval_in_seconds = 60
  number_of_probes    = 2
}

resource "azurerm_network_interface" "nic" {
  name                = "nic${count.index}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  count               = "${var.vm_number_of_servernodes}"

  ip_configuration {
    name                                    = "ipconfig${count.index}"
    subnet_id                               = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation           = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.vm_servernode_name_prefix}${count.index}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  location              = "${azurerm_resource_group.rg.location}"
  vm_size               = "${var.vm_servernode_vm_size}"
  count                 = "${var.vm_number_of_servernodes}"
  availability_set_id   = "${azurerm_availability_set.avset.id}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  
  storage_image_reference {
    publisher = "${var.os_image_publisher}"
    offer     = "${var.os_image_offer}"
    sku       = "${var.os_version}"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.vm_servernode_name_prefix}${count.index}"
    admin_username = "${var.vm_admin_username}"
  }

  storage_os_disk {
    name              = "${var.vm_servernode_name_prefix}osdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
       key_data = "${file("./verticatf.sshkey.pub")}"
       path = "/home/${var.vm_admin_username}/.ssh/authorized_keys"
    }
  }
}

#*** MC node VM stuff***#
resource "azurerm_public_ip" "mcnode" {
  name                         = "${var.public_ip_mcnode_name}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  allocation_method = "Static"
}

resource "azurerm_network_interface" "mcnode" {
  name                      = "${var.nic_mcnode_name}"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.mcnode.id}"
  depends_on                = ["azurerm_virtual_network.vnet", "azurerm_public_ip.mcnode", "azurerm_network_security_group.mcnode"]

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.mcnode.id}"
  }
}

# **********************  NETWORK SECURITY GROUPS ********************** #
resource "azurerm_network_security_group" "mcnode" {
  name                = "${var.nsg_mcnode_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  security_rule {
    name                       = "ssh"
    description                = "Allow SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http_webui_mcnode"
    description                = "Allow Web UI Access to MC"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5450"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_machine" "mcnode" {
  name                  = "${var.vm_mcnode_name}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  location              = "${azurerm_resource_group.rg.location}"
  vm_size               = "${var.vm_mcnode_vm_size}"
  network_interface_ids = ["${azurerm_network_interface.mcnode.id}"]

  storage_image_reference {
    publisher = "${var.os_image_publisher}"
    offer     = "${var.os_image_offer}"
    sku       = "${var.os_version}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm_mcnode_name}osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.vm_mcnode_name}"
    admin_username = "${var.vm_admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
       key_data = "${file("./verticatf.sshkey.pub")}"
       path = "/home/${var.vm_admin_username}/.ssh/authorized_keys"
    }
  }

  connection {
    host = "${azurerm_public_ip.mcnode.ip_address}"
    user = "${var.vm_admin_username}"
    type = "ssh"
    private_key = "${file("verticatf.sshkey")}"
  }

  provisioner "file" {
    source      = "verticatf.sshkey.pub"
    destination = "/home/${var.vm_admin_username}/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    source      = "verticatf.sshkey"
    destination = "/home/${var.vm_admin_username}/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "list2csv.py"
    destination = "/home/${var.vm_admin_username}/list2csv.py"
  }

  provisioner "file" {
    source      = "azure-install-vertica.sh"
    destination = "/home/${var.vm_admin_username}/azure-install-vertica.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y dialog wget git ansible nano",
      "sudo mkdir -p /vertica/tmp",
      "sudo chmod -R 755 /vertica",
      "sudo chmod -R 777 /vertica/tmp",
      "chmod 600 /home/${var.vm_admin_username}/.ssh/*",
      "sudo mkdir -p /root/.ssh",
      "sudo cp /home/${var.vm_admin_username}/.ssh/* /root/.ssh/"
    ]
  }

  provisioner "file" {
    source      = "rpm/"
    destination = "/vertica/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y /vertica/tmp/vertica-console*.rpm",
      "sudo rm /vertica/tmp/vertica-console*.rpm",
      "bash /home/${var.vm_admin_username}/azure-install-vertica.sh ${var.vm_servernode_name_prefix} ${var.vm_number_of_servernodes} ${var.vm_admin_username}"
    ]
  }
}
