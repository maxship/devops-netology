output "external_ip_control_plane_01" {
  value = yandex_compute_instance.cp-01.network_interface.0.nat_ip_address
}

output "external_ip_node_01" {
  value = yandex_compute_instance.node-01.network_interface.0.nat_ip_address
}