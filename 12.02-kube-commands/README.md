# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"
Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2). 

Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods


## Задание 2: Просмотр логов для разработки
Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе. 
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования: 
 * создан новый токен доступа для пользователя
 * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
 * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)


## Задание 3: Изменение количества реплик 
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)

---

## Решение

### Задание 1. Запуск пода из образа в деплойменте

```sh
$ kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4
deployment.apps/hello-node created

$ kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   1/1     1            1           84s

$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-7pxrl   1/1     Running   0          103s
```

```sh
 kubectl scale --replicas=2 deploy/hello-node
deployment.apps/hello-node scaled

$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-7pxrl   1/1     Running   0          4m18s
hello-node-6b89d599b9-xpgsg   1/1     Running   0          3s

$ kubectl get deploy
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   2/2     2            2           5m9s
```

## Задание 2: Просмотр логов для разработки.


```shell
# Генерируем закрытый ключ и создаем запрос на подписание сертификата CSR.
$ openssl genrsa -out developer.key 2048
Generating RSA private key, 2048 bit long modulus (2 primes)
........................................................................................................................................................+++++
.............................................+++++
e is 65537 (0x010001)

openssl req -new -key developer.key -out developer.csr

# Кодируем запрос в base64.
cat developer.csr | base64 | tr -d "\n"

# Передаем запрос кластеру кубернетеса с помощью скрипта (в поле request вставлен закодированный на предыдущем шаге текст):
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: developer
spec:
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ25qQ0NBWVlDQVFBd1dURUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeApJVEFmQmdOVkJBb01HRWx1ZEdWeWJtVjBJRmRwWkdkcGRITWdVSFI1SUV4MFpERVNNQkFHQTFVRUF3d0paR1YyClpXeHZjR1Z5TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF1OHVoNXV4VFo2VTMKalZacFJNeW1pNy85dDRyNXc2cm85dUFFeXJHY2RCVUN2czBMN3N1cnN5bm1JVmFSQXIrcDRMN3NqVlJDR3U4QwpQbUp5OTVWeW9jKzNMc0Q0SDRLcDVmWUJFWHdVOERXdGRidUNuTzRmWklzNmpkMWViREtpUkVKUkZIdGI1ejZQCkJUOXZpNFJwdk1ybGpKZmVPb1FBK0svb205Z2U2U1ZCYXBtU1Z5ZEhzK2FqZlRSSER2NHhSa3poT0lsMHFWc0sKQktNaHVZWmgwbnFZTVVoNVJDeDN4UmdEeUFKMmYzQ05TaFE1MDZuUkk2aXQvTFh2cXcrUVVuT0xtVXNLUWJKZAp3a2g3cDQ4YmJDRTdzNFI4VnhQa2hOTHZZa0FEZCs1R3YyUjZ4UHV5MEp2V2ovRVY2SW1JZXhGWFdhUUpUZmVuCnlQdHZoMXhkbXdJREFRQUJvQUF3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUlnUUZpNFdicDVKNkwrQkZLZWUKWjdiQnZlSmxrd2oxVTh4bTlxU05aQllESkJHdG1nQWgvL2pXeExKZU9OcEJLVWN4WWxLZm4wUVUvUmV5OEpFTQo5MnZYV3JyamxJNGRLdFFYV1ZIZ0J6Tysyc1RXTWtLcHZFMFNxMVpsTlI4dEdjZGRacGk3azlkRE1ENjNDSHRvCis0aVQ3VkQ2QUs5NUJYYVhUMWRQTzR5eEVYZ2NHa2hkSTllUUYzS0piZ3p5WGNoaXA3ZGVqcmdXK1ZIUjlFVmIKWExFMHpUZytJMURFY1dXZGFiRER0ZXJtTkFoZ0lTYWhIV2lra2p6Q2F0Zzlid0tURk9oYk44QWY3MkdyNVEySgp6ZFlzajhuK1R5S0NYR1RWbjVSOGVLRzBBMzVLOVAvMW5Mb0VUMVFoTHNKY2kyTlJheTRKdmF3QzArOGFPZlNFClRiQT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400  # one day
  usages:
  - client auth
EOF

# Подтверждаем сертификат.
$ kubectl certificate approve developer
certificatesigningrequest.certificates.k8s.io/developer approved

$ kubectl get csr
NAME             AGE   SIGNERNAME                                    REQUESTOR                          REQUESTEDDURATION   CONDITION
csr-twbx2        55m   kubernetes.io/kube-apiserver-client-kubelet   system:node:fhm2feote4ceokv6a3nk   <none>              Approved,Issued
developer   6m    kubernetes.io/kube-apiserver-client           minikube-user                      24h                 Approved,Issued

# Экспортируем сертификат.
$ kubectl get csr developer -o jsonpath='{.status.certificate}'| base64 -d > developer.crt

# Создаем роль с правом на просмотр и чтение pods.
$ kubectl create role developer --verb=get --verb=list --verb=watch --resource=pods
role.rbac.authorization.k8s.io/developer created

# Связываем пользователя с ролью.
$ kubectl create rolebinding developer-binding --role=developer --user=developer
rolebinding.rbac.authorization.k8s.io/developer-binding created

# Добавляем сертификат пользователя в файл конфига.
$ kubectl config set-credentials developer --client-key=developer.key --client-certificate=developer.crt --embed-certs=true
User "developer" set.

# Добавляем контекст.
$ kubectl config set-context developer --cluster=minikube --user=developer
Context "developer" created.
```
Проверка работоспособности.

```sh
# Переключаемся на контекст developer.
$ kubectl config use-context developer

# Смотрим конфиг:
root@fhm2feote4ceokv6a3nk:/home/ubuntu# kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /root/.minikube/ca.crt
    extensions:
    - extension:
        last-update: Fri, 01 Apr 2022 08:41:07 UTC
        provider: minikube.sigs.k8s.io
        version: v1.25.2
      name: cluster_info
    server: https://10.2.0.6:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: developer
  name: developer
- context:
    cluster: minikube
    extensions:
    - extension:
        last-update: Fri, 01 Apr 2022 08:41:07 UTC
        provider: minikube.sigs.k8s.io
        version: v1.25.2
      name: context_info
    namespace: default
    user: minikube
  name: minikube
current-context: developer
kind: Config
preferences: {}
users:
- name: developer
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
- name: minikube
  user:
    client-certificate: /root/.minikube/profiles/minikube/client.crt
    client-key: /root/.minikube/profiles/minikube/client.key

# Смотрим список подов: 
root@fhm2feote4ceokv6a3nk:/home/ubuntu# kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-7pxrl   1/1     Running   0          124m
hello-node-6b89d599b9-fr9dv   1/1     Running   0          115m
hello-node-6b89d599b9-h4kqw   1/1     Running   0          115m
hello-node-6b89d599b9-qbvpb   1/1     Running   0          115m
hello-node-6b89d599b9-xpgsg   1/1     Running   0          119m

# Вывод описания пода:
root@fhm2feote4ceokv6a3nk:/home/ubuntu# kubectl --context=developer describe po hello-node-6b89d599b9-xpgsg
Name:         hello-node-6b89d599b9-xpgsg
Namespace:    default
Priority:     0
Node:         fhm2feote4ceokv6a3nk/10.2.0.6
Start Time:   Fri, 01 Apr 2022 09:06:04 +0000
Labels:       app=hello-node
              pod-template-hash=6b89d599b9
Annotations:  <none>
Status:       Running
IP:           172.17.0.4
IPs:
  IP:           172.17.0.4
Controlled By:  ReplicaSet/hello-node-6b89d599b9
Containers:
  echoserver:
    Container ID:   docker://19b3787e9425fa3b738ff5b04a334e1d63cb08a9bb1abe0529c2ae8a1adff83f
    Image:          k8s.gcr.io/echoserver:1.4
    Image ID:       docker-pullable://k8s.gcr.io/echoserver@sha256:5d99aa1120524c801bc8c1a7077e8f5ec122ba16b6dda1a5d3826057f67b9bcb
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 01 Apr 2022 09:06:05 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-n5r9p (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-n5r9p:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>

# При запросе списка деплоев получаем ожидаемую ошибку, т.к. доступ был дан только на просмотр подов.
root@fhm2feote4ceokv6a3nk:/home/ubuntu# kubectl get deploy
Error from server (Forbidden): deployments.apps is forbidden: User "developer" cannot list resource "deployments" in API group "apps" in the namespace "default"

# Пробуем удалить под, так же получаем ошибку доступа.
root@fhm2feote4ceokv6a3nk:/home/ubuntu# kubectl --context=developer delete po hello-node-6b89d599b9-xpgsg
Error from server (Forbidden): pods "hello-node-6b89d599b9-xpgsg" is forbidden: User "developer" cannot delete resource "pods" in API group "" in the namespace "default"
```
Все операции в этом задании делались в соответствии с документацией кубернетеса [https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/).


## Задание 3: Изменение количества реплик 

```shell
$ kubectl scale --replicas=5 deploy/hello-node
deployment.apps/hello-node scaled

$ kubectl get deploy
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   2/5     5            2           8m23s

$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-7pxrl   1/1     Running   0          8m25s
hello-node-6b89d599b9-fr9dv   1/1     Running   0          5s
hello-node-6b89d599b9-h4kqw   1/1     Running   0          5s
hello-node-6b89d599b9-qbvpb   1/1     Running   0          5s
hello-node-6b89d599b9-xpgsg   1/1     Running   0          4m10s
```