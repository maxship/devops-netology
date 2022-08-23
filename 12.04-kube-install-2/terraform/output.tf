output "external_ip_control_plane" {
  value = yandex_compute_instance.cp-1.network_interface.0.nat_ip_address
}

output "external_ip_nodes" {
  value = yandex_compute_instance.node[*].network_interface.0.nat_ip_address
}

# Export host.yml into /kubespray/inventory/gp-devops-k8s-cluster/
resource "local_file" "k8s_hosts_ip" {
  content  = <<-DOC
---
all:
  hosts:
    cp-1:
      ansible_host: ${yandex_compute_instance.cp-1.network_interface.0.nat_ip_address}
      ansible_user: ubuntu
    node-1:
      ansible_host: ${yandex_compute_instance.node[0].network_interface.0.nat_ip_address}
      ansible_user: ubuntu
  children:
    kube_control_plane:
      hosts:
        cp-1:
    kube_node:
      hosts:
        node-1:
    etcd:
      hosts:
        cp-1
    k8s_cluster:
      vars:
        supplementary_addresses_in_ssl_keys: ${yandex_compute_instance.cp-1.network_interface.0.nat_ip_address}
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
    DOC
  filename = "./hosts.yml"
}