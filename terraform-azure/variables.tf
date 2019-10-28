variable "resource_group" {
  description = "Resource group name into which your Vertica deployment will go."
  default = "verticatf"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default     = "centralus"
}

variable "unique_prefix" {
  description = "This prefix is used for names which need to be globally unique."
  default = "verticatf"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_D1_v2"
}

variable "nsg_mcnode_name" {
  description = "The name of the network security group for mcnode"
  default     = "nsg-mcnode"
}

variable "vm_mcnode_vm_size" {
  description = "VM size for mcnode Vertica node.  This VM can be sized smaller. Allowed values: Standard_D1_v2, Standard_D2_v2, Standard_D3_v2, Standard_D4_v2, Standard_D5_v2, Standard_D11_v2, Standard_D12_v2, Standard_D13_v2, Standard_D14_v2, Standard_A8, Standard_A9, Standard_A10, Standard_A11"
  default     = "Standard_D1_v2"
}

variable "vm_number_of_servernodes" {
  description = "Number of VMs to create to support the servernodes.  Each servernode is created on it's own VM.  Minimum of 2 & Maximum of 200 VMs. min = 2, max = 200"
  default     = 2
}

variable "vm_servernode_vm_size" {
  description = "VM size for servernode Vertica nodes.  This VM should be sized based on workloads. Allowed values: Standard_D1_v2, Standard_D2_v2, Standard_D3_v2, Standard_D4_v2, Standard_D5_v2, Standard_D11_v2, Standard_D12_v2, Standard_D13_v2, Standard_D14_v2, Standard_A8, Standard_A9, Standard_A10, Standard_A11"
  default     = "Standard_D1_v2"
}

variable "vm_admin_username" {
  description = "Specify an admin username that should be used to login to the VM. Min length: 1"
  default = "verticatf"
}

variable "os_image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "OpenLogic"
}

variable "os_image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "CentOS"
}

variable "os_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "7.5"
}

variable "api_version" {
  default = "2015-06-15"
}

variable "nic_mcnode_name" {
  description = "The name of the network interface card for mcnode"
  default     = "nic-vertica-mcnode"
}

variable "nic_mcnode_node_ip" {
  description = "The private IP address used by the mcnode's network interface card"
  default     = "10.0.0.5"
}

variable "nic_servernode_name_prefix" {
  description = "The prefix used to constitute the servernode/agents' names"
  default     = "nic-servernode-"
}

variable "nic_servernode_node_ip_prefix" {
  description = "The prefix of the private IP address used by the network interface card of the servernode/agent nodes"
  default     = "10.0.1."
}

variable "public_ip_mcnode_name" {
  description = "The name of the mcnode node's public IP address"
  default     = "public-ip-mcnode"
}

variable "public_ip_servernode_name_prefix" {
  description = "The prefix to the servernode/agent nodes' IP address names"
  default     = "public-ip-servernode-"
}

variable "vm_mcnode_name" {
  description = "The name of Vertica's mcnode virtual machine"
  default     = "vertica-mcnode"
}

variable "vm_mcnode_os_disk_name" {
  description = "The name of the os disk used by Vertica's mcnode virtual machine"
  default     = "vmmcnodeOSDisk"
}

variable "vm_servernode_name_prefix" {
  description = "The name prefix used by Vertica's servernode/agent nodes"
  default     = "vertica-servernode-"
}

variable "vm_servernode_os_disk_name_prefix" {
  description = "The prefix used to constitute the names of the os disks used by the servernode/agent nodes"
  default     = "vmservernodeOSDisk-"
}

variable "availability_servernode_name" {
  description = "The name of the availability set for the servernode/agent machines"
  default     = "availability-servernode"
}

#*** LOAD BALANCER VARS ***#
variable "hostname" {
  description = "VM name referenced also in storage-related names."
  default = "verticatf"
}

variable "dns_name" {
  description = " Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
  default = "verticatf"
}

variable "lb_ip_dns_name" {
  description = "DNS for Load Balancer IP"
  default = "verticatf"
}

variable "virtual_network_name" {
  description = "The name for the virtual network."
  default     = "vnet"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}
