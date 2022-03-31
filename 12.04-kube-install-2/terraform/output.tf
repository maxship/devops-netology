output "external_ip_control_plane" {
  value = yandex_compute_instance.cp-1.network_interface.0.nat_ip_address
}

output "external_ip_nodes" {
  value = yandex_compute_instance.node[*].network_interface.0.nat_ip_address
}
