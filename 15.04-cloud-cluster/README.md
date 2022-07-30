# Домашнее задание к занятию 15.4 "Кластеры. Ресурсы под управлением облачных провайдеров"

Организация кластера Kubernetes и кластера баз данных MySQL в отказоустойчивой архитектуре.
Размещение в private подсетях кластера БД, а в public - кластера Kubernetes.

---
## Задание 1. Яндекс.Облако (обязательное к выполнению)

1. Настроить с помощью Terraform кластер баз данных MySQL:
- Используя настройки VPC с предыдущих ДЗ, добавить дополнительно подсеть private в разных зонах, чтобы обеспечить отказоустойчивость 
- Разместить ноды кластера MySQL в разных подсетях
- Необходимо предусмотреть репликацию с произвольным временем технического обслуживания
- Использовать окружение PRESTABLE, платформу Intel Broadwell с производительностью 50% CPU и размером диска 20 Гб
- Задать время начала резервного копирования - 23:59
- Включить защиту кластера от непреднамеренного удаления
- Создать БД с именем `netology_db` c логином и паролем

2. Настроить с помощью Terraform кластер Kubernetes
- Используя настройки VPC с предыдущих ДЗ, добавить дополнительно 2 подсети public в разных зонах, чтобы обеспечить отказоустойчивость
- Создать отдельный сервис-аккаунт с необходимыми правами 
- Создать региональный мастер kubernetes с размещением нод в разных 3 подсетях
- Добавить возможность шифрования ключом из KMS, созданного в предыдущем ДЗ
- Создать группу узлов состояющую из 3 машин с автомасштабированием до 6
- Подключиться к кластеру с помощью `kubectl`
- *Запустить микросервис phpmyadmin и подключиться к БД, созданной ранее
- *Создать сервис типы Load Balancer и подключиться к phpmyadmin. Предоставить скриншот с публичным адресом и подключением к БД

Документация
- [MySQL cluster](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_cluster)
- [Создание кластера kubernetes](https://cloud.yandex.ru/docs/managed-kubernetes/operations/kubernetes-cluster/kubernetes-cluster-create)
- [K8S Cluster](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster)
- [K8S node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
--- 
## Задание 2. Вариант с AWS (необязательное к выполнению)

1. Настроить с помощью terraform кластер EKS в 3 AZ региона, а также RDS на базе MySQL с поддержкой MultiAZ для репликации и создать 2 readreplica для работы:
- Создать кластер RDS на базе MySQL
- Разместить в Private subnet и обеспечить доступ из public-сети c помощью security-group
- Настроить backup в 7 дней и MultiAZ для обеспечения отказоустойчивости
- Настроить Read prelica в кол-ве 2 шт на 2 AZ.

2. Создать кластер EKS на базе EC2:
- С помощью terraform установить кластер EKS на 3 EC2-инстансах в VPC в public-сети
- Обеспечить доступ до БД RDS в private-сети
- С помощью kubectl установить и запустить контейнер с phpmyadmin (образ взять из docker hub) и проверить подключение к БД RDS
- Подключить ELB (на выбор) к приложению, предоставить скрин

Документация
- [Модуль EKS](https://learn.hashicorp.com/tutorials/terraform/eks)

---
```shell
Outputs:

kube-cluster-ca-cert = <<EOT
-----BEGIN CERTIFICATE-----
MIIC5zCCAc+gAwIBAgIBADANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwprdWJl
cm5ldGVzMB4XDTIyMDczMDExNTgyOFoXDTMyMDcyNzExNTgyOFowFTETMBEGA1UE
AxMKa3ViZXJuZXRlczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJrb
eupQM1CKOjIdOK8zjLrquBYzUxlnHtdcTczZac/kO/awc6Cdb6PXKMXKiXqA1mVL
XrHC5Vz8iMKAQulDNyHVswZPr/B97umBYEpg9AholvvNFxo0eVY8jl9Bs0smDC3G
d74D/kE9+z7OJLuZOr6LptQovTmLRcSWES2CgtJfglELcJtAExyeVl52uOzj+YZG
Mpvksysjt4T3iW0BMNaC8wOf25PPxLts+t6b65OyJHTBdlsqvV5UMAw3/rPjcd6T
mzEUXmGS5HLabe/xcp8hpVvaoeO+nOLec3XLFY3QaTImBT4nYyeW47MVvw8RgoOU
r52q/xqshXWbmo1pKFMCAwEAAaNCMEAwDgYDVR0PAQH/BAQDAgKkMA8GA1UdEwEB
/wQFMAMBAf8wHQYDVR0OBBYEFB53Wo+NKTHri95jc9o0WhVfQ7HfMA0GCSqGSIb3
DQEBCwUAA4IBAQAMxYW9n13DV6TIKRBM1ehxBfpn0cw7WcYEsqyeYj99LAJAfnkH
/HHpDn7lVvImFUGU1HipRsoCZRYIg+UHLXG1guCYBeXXGhDemrNQxRelDekCmR/O
0eqHmEPFm97iU4eGXooM+s0zVz4FwKQ8V2hvjxmjlwkumiSRUTpCB0oanPy2t4Oh
YvV9diQUrEJHvKxANFUGTqlEZ5MqibtRySf5KYjV2l3nFqVVhBLD3PSJ79WnIxNo
9mwxzo/9ozORzeTAuqVFjRNFDXXHgUddsSEyZdL7Qu6pAYqKZ+RBor4coh0ZdUpK
XeLFP3pSS6Mvs2Ooh1CS1bmy0bKMOb9vIEQ4
-----END CERTIFICATE-----

EOT
kube-cluster-ext-endpoint = "https://51.250.93.112"
nat_public_external_ip = "51.250.95.14"
nat_public_internal_ip = "192.168.10.254"
vm_private_internal_ip = "192.168.50.12"
vm_public_external_ip = "51.250.92.142"

maxship@Ryzen5-Desktop:~$ yc managed-kubernetes cluster get-credentials k8s-cluster --external

Context 'yc-k8s-cluster' was added as default to kubeconfig '/home/maxship/.kube/config'.
Check connection to cluster using 'kubectl cluster-info --kubeconfig /home/maxship/.kube/config'.

Note, that authentication depends on 'yc' and its config profile 'default'.
To access clusters using the Kubernetes API, please use Kubernetes Service Account.

maxship@Ryzen5-Desktop:~/devops/devops-netology/15.04-cloud-cluster/terraform$ kubectl cluster-info
Kubernetes control plane is running at https://51.250.93.112
CoreDNS is running at https://51.250.93.112/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://51.250.93.112/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

maxship@Ryzen5-Desktop:~/devops/devops-netology/15.04-cloud-cluster/terraform$ kubectl get nodes
NAME                        STATUS   ROLES    AGE     VERSION
cl1rs3br5cnhtfe7bsnv-okoj   Ready    <none>   7m58s   v1.19.15
cl1rs3br5cnhtfe7bsnv-omyb   Ready    <none>   7m52s   v1.19.15
cl1rs3br5cnhtfe7bsnv-ycyj   Ready    <none>   7m36s   v1.19.15

```