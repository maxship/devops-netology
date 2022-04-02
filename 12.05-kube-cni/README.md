# Домашнее задание к занятию "12.5 Сетевые решения CNI"
После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.
## Задание 1: установить в кластер CNI плагин Calico
Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования: 
* установка производится через ansible/kubespray;
* после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

## Задание 2: изучить, что запущено по умолчанию
Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список нод, ipPool и profile.
Требования: 
* установить утилиту calicoctl;
* получить 3 вышеописанных типа в консоли.

---
# Решение
## Задание 1. Установить в кластер CNI плагин Calico

Скачиваем репозиторий Kubespray.

```shell script
git clone https://github.com/kubernetes-sigs/kubespray

# Установка зависимостей
sudo pip3 install -r requirements.txt

# Копирование примера в папку с вашей конфигурацией
cp -rfp inventory/sample inventory/mycluster
```

В kubespray сейчас по умолчанию ставится CNI плагин Calico, поэтому удостоверимся что это действительно так, а так же укажем внешний IP кластеhа в настройках ssl для удаленной работы kubectl.

```yml
# 12.05-kube-cni/inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

# Choose network plugin (cilium, calico, weave or flannel. Use cni for generic cni plugin)
# Can also be set to 'cloud', which lets the cloud provider setup appropriate routing
kube_network_plugin: calico

## Supplementary addresses that can be added in kubernetes ssl keys.
## That can be useful for example to setup a keepalived virtual IP
# supplementary_addresses_in_ssl_keys: [10.0.0.1, 10.0.0.2, 10.0.0.3]
supplementary_addresses_in_ssl_keys: [51.250.74.210]
```
После этого запустим установку на ВМ в облаке.

```sh
$ ansible-playbook -i inventory/mycluster/hosts.yml --become --become-user=root cluster.yml
```

Копируем содержимое `/etc/kubernetes/admin.conf` в локальный файл настроек `~/.kube/config`, там же меняем IP на внешний 51.250.74.210. Проверяем работу kubectl на локальной машине.

```sh
$ kubectl get nodes
NAME     STATUS   ROLES                  AGE   VERSION
cp-1     Ready    control-plane,master   70m   v1.23.5
node-1   Ready    <none>                 69m   v1.23.5
node-2   Ready    <none>                 69m   v1.23.5
```
Далее запускаем тестовые приложения [hello-node](./apps/hello-node.yaml), [network-multitool](./apps/network-multitool.yaml) и пробуем сетевые политики [nw-policy-ingress-app](./nw-policy/nw-policy-ingress-app.yaml), [nw-policy-deny-ingress](./nw-policy/nw-policy-deny-ingress.yaml).

```sh
# Запускаем тестовые приложения.
$ kubectl apply -f ./apps/
deployment.apps/hello-node created
service/hello-node created
deployment.apps/nw-multitool created

$ kubectl get po -o wide
NAME                            READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
hello-node-c78c88764-qjlt5      1/1     Running   0          74s   10.233.69.1    node-2   <none>           <none>
nw-multitool-78ff89964b-ljlj7   1/1     Running   0          74s   10.233.112.2   node-1   <none>           <none>

# Удостоверяемся, что сетевые политики не действуют.
$ kubectl get networkpolicies
No resources found in default namespace.

# Пробуем сделать запрос к приложению hello-node из другого пода. Ответ приходит.
$ kubectl exec nw-multitool-78ff89964b-ljlj7 -- curl -s hello-node-c78c88764-qjlt5 hello-node:8080
LIENT VALUES:
client_address=10.233.112.2
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://hello-node:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=hello-node:8080
user-agent=curl/7.79.1
BODY:
-no body in request

# Добавляем политику, закрывающую все входящие соединения.
$ kubectl apply -f ./nw-policy/nw-policy-deny-ingress.yaml 
networkpolicy.networking.k8s.io/deny-ingress-policy created

# Снова отправляем запрос и получаем ошибку.
$ kubectl exec nw-multitool-78ff89964b-ljlj7 -- curl -m 3 -s hello-node-c78c88764-qjlt5 hello-node:8080
command terminated with exit code 28

# Применяем политику, разрешающую входящие соединения от пода network-multitool.
$ kubectl apply -f ./nw-policy/nw-policy-ingress-app.yaml 
networkpolicy.networking.k8s.io/network-policy-ingress-app created

# Проверяем работоспособность:
$ kubectl exec nw-multitool-78ff89964b-ljlj7 -- curl -m 3 -s hello-node-c78c88764-qjlt5 hello-node:8080
CLIENT VALUES:
client_address=10.233.112.2
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://hello-node:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=hello-node:8080
user-agent=curl/7.79.1
BODY:
-no body in request
```

## Задание 2. Изучить, что запущено по умолчанию

```sh
# Список нод:
root@cp-1:/home/ubuntu# calicoctl get nodes -o wide
NAME     ASN       IPV4           IPV6   
cp-1     (64512)   10.2.0.20/16          
node-1   (64512)   10.2.0.7/16           
node-2   (64512)   10.2.0.12/16 

# Пул IP адресов:
root@cp-1:/home/ubuntu# calicoctl get ippool -o wide
NAME           CIDR             NAT    IPIPMODE   VXLANMODE   DISABLED   DISABLEBGPEXPORT   SELECTOR   
default-pool   10.233.64.0/18   true   Never      Always      false      false              all()

# Профили:
root@cp-1:/home/ubuntu# calicoctl get profile
NAME                                                 
projectcalico-default-allow                          
kns.default                                          
kns.kube-node-lease                                  
kns.kube-public                                      
kns.kube-system                                      
ksa.default.default                                  
ksa.kube-node-lease.default                          
ksa.kube-public.default                              
ksa.kube-system.attachdetach-controller              
ksa.kube-system.bootstrap-signer                     
ksa.kube-system.calico-kube-controllers              
ksa.kube-system.calico-node                          
ksa.kube-system.certificate-controller               
ksa.kube-system.clusterrole-aggregation-controller   
ksa.kube-system.coredns                              
ksa.kube-system.cronjob-controller                   
ksa.kube-system.daemon-set-controller                
ksa.kube-system.default                              
ksa.kube-system.deployment-controller                
ksa.kube-system.disruption-controller                
ksa.kube-system.dns-autoscaler                       
ksa.kube-system.endpoint-controller                  
ksa.kube-system.endpointslice-controller             
ksa.kube-system.endpointslicemirroring-controller    
ksa.kube-system.ephemeral-volume-controller          
ksa.kube-system.expand-controller                    
ksa.kube-system.generic-garbage-collector            
ksa.kube-system.horizontal-pod-autoscaler            
ksa.kube-system.job-controller                       
ksa.kube-system.kube-proxy                           
ksa.kube-system.namespace-controller                 
ksa.kube-system.node-controller                      
ksa.kube-system.nodelocaldns                         
ksa.kube-system.persistent-volume-binder             
ksa.kube-system.pod-garbage-collector                
ksa.kube-system.pv-protection-controller             
ksa.kube-system.pvc-protection-controller            
ksa.kube-system.replicaset-controller                
ksa.kube-system.replication-controller               
ksa.kube-system.resourcequota-controller             
ksa.kube-system.root-ca-cert-publisher               
ksa.kube-system.service-account-controller           
ksa.kube-system.service-controller                   
ksa.kube-system.statefulset-controller               
ksa.kube-system.token-cleaner                        
ksa.kube-system.ttl-after-finished-controller        
ksa.kube-system.ttl-controller
```