output "external_ip_minikube_master" {
  value = yandex_compute_instance.minikube-01.network_interface.0.nat_ip_address
}