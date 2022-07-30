output "nat_public_external_ip" {
  value = yandex_compute_instance.nat-instance.network_interface.0.nat_ip_address
}

output "nat_public_internal_ip" {
  value = yandex_compute_instance.nat-instance.network_interface.0.ip_address
}

output "vm_public_external_ip" {
  value = yandex_compute_instance.vm-public.network_interface.0.nat_ip_address
}

output "vm_private_internal_ip" {
  value = yandex_compute_instance.vm-private.network_interface.0.ip_address
}

output "kube-cluster-ext-endpoint" {
  value = yandex_kubernetes_cluster.k8s-cluster.master[0].external_v4_endpoint
}

output "kube-cluster-ca-cert" {
  value = yandex_kubernetes_cluster.k8s-cluster.master[0].cluster_ca_certificate
}

