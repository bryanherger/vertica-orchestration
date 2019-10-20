variable vertica_basename {
  description = "Instance user name and Prefix to be used when naming GCP resources"
  default = "verticatf"
}

variable project_cred_file {
  description = "GCP service credentials JSON file"
  default = "keyfile.json"
}

variable project_name {
  description = "GCP project name"
  default = "vertica-sandbox"
}

variable region {
  description = "Region for managed instance group"
  default = "us-central1"
}

variable zone {
  description = "Zone for managed instance groups"
  default = "us-central1-f"
}

variable mc_instance_name {
  description = "MC instance name"
  default = "verticatf-mc-instance"
}

variable mc_machine_type {
  description = "Machine type for the Management Console VM"
  default = "n1-standard-1"
}

variable mc_boot_disk_image {
  description = "Boot image for MC instance"
  default = "centos-7-v20190916"
}

variable vertica_boot_disk_image {
  description = "Boot image for Vertica server instances"
  default = "centos-7-v20190916"
}

variable vertica_boot_disk_size {
  description = "Boot disk size for Vertica server instances"
  default = 100
}

variable cluster_size {
  description = "Target size of the Vertica DB cluster - managed instance group"
  default = 2
}

variable compute_machine_type {
  description = "Machine type for the VMs in the instance group"
  default = "n1-standard-1"
}
