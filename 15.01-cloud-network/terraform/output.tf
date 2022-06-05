output "nat_public_external_ip" {
  value = yandex_compute_instance.nat-public.network_interface.0.nat_ip_address
}

output "vm_public_external_ip" {
  value = yandex_compute_instance.vm-public.network_interface.0.nat_ip_address
}

output "vm_private_internal_ip" {
  value = yandex_compute_instance.vm-private.network_interface.0.ip_address
}