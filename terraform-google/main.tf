provider "google" {
  credentials = "${file("${var.project_cred_file}")}"
  project = "${var.project_name}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

resource "google_compute_instance" "verticatf_mc_instance" {
  name         = "${var.mc_instance_name}"
  machine_type = "${var.mc_machine_type}"

  boot_disk {
    initialize_params {
      image = "${var.mc_boot_disk_image}"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "${google_compute_network.vertica_tf_network.self_link}"
    access_config {
    }
  }

  connection {
      host = "${google_compute_instance.verticatf_mc_instance.network_interface.0.access_config.0.nat_ip}"
      user = "${var.vertica_basename}"
      type = "ssh"
      private_key = "${file("verticatf.sshkey")}"
    }

  provisioner "file" {
    source      = "verticatf.sshkey.pub"
    destination = "/home/${var.vertica_basename}/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    source      = "verticatf.sshkey"
    destination = "/home/${var.vertica_basename}/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "list2csv.py"
    destination = "/home/${var.vertica_basename}/list2csv.py"
  }

  provisioner "file" {
    source      = "google-install-vertica.sh"
    destination = "/home/${var.vertica_basename}/google-install-vertica.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y dialog wget git ansible nano",
      "sudo mkdir -p /vertica/tmp",
      "sudo chmod -R 755 /vertica",
      "sudo chmod -R 777 /vertica/tmp",
      "chmod 600 /home/${var.vertica_basename}/.ssh/*",
      "sudo mkdir -p /root/.ssh",
      "sudo cp /home/${var.vertica_basename}/.ssh/* /root/.ssh/"
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
      "bash /home/${var.vertica_basename}/google-install-vertica.sh"
    ]
  }

  metadata = {
    vertica-basename = "${var.vertica_basename}",
    ssh-keys = "${var.vertica_basename}:${file("verticatf.sshkey.pub")}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_network" "vertica_tf_network" {
  name                    = "${var.vertica_basename}-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "vertica_tf_firewall" {
 name    = "${var.vertica_basename}-firewall"
 network = "${google_compute_network.vertica_tf_network.self_link}"

 allow {
   protocol = "tcp"
   ports    = ["22","5433","5450"]
 }
}

resource "google_compute_firewall" "vertica_tf_internal_firewall" {
 name    = "${var.vertica_basename}-internal-firewall"
 network = "${google_compute_network.vertica_tf_network.self_link}"

 allow {
   protocol = "all"
 }

 priority = 123
 source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_instance_template" "verticatf" {
  name_prefix = "${var.vertica_basename}-instance-"

  machine_type = "${var.compute_machine_type}"

  disk {
    auto_delete = true
    boot = true
    source_image = "${var.vertica_boot_disk_image}"
    type = "PERSISTENT"
    disk_type = "pd-ssd"
    disk_size_gb = "${var.vertica_boot_disk_size}"
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "${google_compute_network.vertica_tf_network.self_link}"
#    access_config {
#    }
  }

  metadata = {
    vertica-basename = "${var.vertica_basename}",
    startup-script = "${file("vertica.sh")}",
    ssh-keys = "${var.vertica_basename}:${file("verticatf.sshkey.pub")}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "verticatf" {
  name = "${var.vertica_basename}-compute-igm"
  description = "Vertica Server VM Instance Group"

  base_instance_name = "${var.vertica_basename}-instance"

  instance_template = "${google_compute_instance_template.verticatf.self_link}"

  update_strategy = "RESTART"

  target_pools = ["${google_compute_target_pool.verticatf.self_link}"]
  target_size = "${var.cluster_size}"

  named_port {
    name = "vertica"
    port = "5433"
  }
}

data "google_compute_instance_group" "verticatf" {
    self_link = "${google_compute_instance_group_manager.verticatf.instance_group}"
}

resource "google_compute_target_pool" "verticatf" {
  name = "${var.vertica_basename}-target-pool"
  session_affinity = "NONE"
}

resource "google_compute_forwarding_rule" "verticatf" {
  name       = "${var.vertica_basename}-compute-instance-group"
  target     = "${google_compute_target_pool.verticatf.self_link}"
  load_balancing_scheme = "EXTERNAL"
  port_range = "5433"
}

