output "external_ip_jenkins_master" {
  value = yandex_compute_instance.jenkins-m.network_interface.0.nat_ip_address
}

output "external_ip_jenkins_agent" {
  value = yandex_compute_instance.jenkins-a.network_interface.0.nat_ip_address
}