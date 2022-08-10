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

# Адрес хоста MySQL
 output "mysql_host_address" {
    value = "MySQL host: ${yandex_mdb_mysql_cluster.cluster-mysql-netology.host[0].fqdn}"
 }

output "k8s_cluster_external_ip" {
  value = yandex_kubernetes_cluster.k8s-cluster.master[0].external_v4_endpoint
}

# Для подключения к кластеру с помощью kubectl с локал
output "k8s_cluster_kubectl_init_local" {
  value = "To access k8s cluster from local host via YC client, enter this command: 'yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.k8s-cluster.id} --external'"
}
