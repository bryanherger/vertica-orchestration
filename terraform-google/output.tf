output "vertica_ip" {
  value = "${google_compute_forwarding_rule.verticatf.ip_address}"
}

output "vertica_console_ip" {
  value = "${google_compute_instance.verticatf_mc_instance.network_interface.0.access_config.0.nat_ip}"
}

output "vertica_instances" {
  value = "${data.google_compute_instance_group.verticatf.instances}"
}

output "vertica_basename" {
  value = "${var.vertica_basename}"
}

