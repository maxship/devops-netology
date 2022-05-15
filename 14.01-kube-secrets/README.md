# Домашнее задание к занятию "14.1 Создание и использование секретов"

## Задача 1: Работа с секретами через утилиту kubectl в установленном minikube

Выполните приведённые ниже команды в консоли, получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать секрет?

```bash
openssl genrsa -out cert.key 4096
openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
-subj '/C=RU/ST=Moscow/L=Moscow/CN=server.local'
kubectl create secret tls domain-cert --cert=certs/cert.crt --key=certs/cert.key
```

### Как просмотреть список секретов?

```shell
kubectl get secrets
kubectl get secret
```

### Как просмотреть секрет?

```
kubectl get secret domain-cert
kubectl describe secret domain-cert
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get secret domain-cert -o yaml
kubectl get secret domain-cert -o json
```

### Как выгрузить секрет и сохранить его в файл?

```
kubectl get secrets -o json > secrets.json
kubectl get secret domain-cert -o yaml > domain-cert.yml
```

### Как удалить секрет?

```
kubectl delete secret domain-cert
```

### Как загрузить секрет из файла?

```
kubectl apply -f domain-cert.yml
```

## Задача 2 (*): Работа с секретами внутри модуля

Выберите любимый образ контейнера, подключите секреты и проверьте их доступность
как в виде переменных окружения, так и в виде примонтированного тома.

---

## Задача 1: Работа с секретами через утилиту kubectl

### Создание секрета

```shell
maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ openssl genrsa -out cert.key 4096
Generating RSA private key, 4096 bit long modulus (2 primes)
...........................................................++++
......++++
e is 65537 (0x010001)

maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
> -subj "/C=RU/ST=Moscow/L=Moscow/CN=server.local"

maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ ls
cert.crt  cert.key  multitool.yml  README.md  vagrant

maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ kubectl create secret tls domain-cert --cert=cert.crt --key=cert.key
secret/domain-cert created
```

### Просмотр списка секретов

```shell
maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-7hltm   kubernetes.io/service-account-token   3      26d
domain-cert           kubernetes.io/tls                     2      70s
```

### Просмотр секрета

```shell
maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ kubectl get secret domain-cert
NAME          TYPE                DATA   AGE
domain-cert   kubernetes.io/tls   2      2m10s

maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ kubectl describe secret domain-cert
Name:         domain-cert
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1944 bytes
tls.key:  3243 bytes
```

### Вывод информации в формате yaml и json

```shell
maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ kubectl get secret domain-cert -o yaml
apiVersion: v1
data:
  tls.crt: LS0tLS1CRUd....0tLS0K
  tls.key: LS0tLS1CRU...ZLS0tLS0K
kind: Secret
metadata:
  creationTimestamp: "2022-05-15T07:00:03Z"
  name: domain-cert
  namespace: default
  resourceVersion: "28915"
  uid: 9cb0b845-8cd9-4255-b58f-c6b6a6290d58
type: kubernetes.io/tls

maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ kubectl get secret domain-cert -o json
{
    "apiVersion": "v1",
    "data": {
        "tls.crt": "LS0tLS1CRU....JRklDQVRFLS0tLS0K",
        "tls.key": "LS0tLS1CRUd....gS0VZLS0tLS0K"
    },
    "kind": "Secret",
    "metadata": {
        "creationTimestamp": "2022-05-15T07:00:03Z",
        "name": "domain-cert",
        "namespace": "default",
        "resourceVersion": "28915",
        "uid": "9cb0b845-8cd9-4255-b58f-c6b6a6290d58"
    },
    "type": "kubernetes.io/tls"
}
```

### Выгрузка секрета в файл

```shell
maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ kubectl get secrets -o json > secrets.json
maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ kubectl get secret domain-cert -o yaml > domain-cert.yml
maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ ls
cert.crt  cert.key  domain-cert.yml  multitool.yml  README.md  secrets.json  vagrant
```

### Удаление секрета

```shell
maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ kubectl delete secret domain-cert
secret "domain-cert" deleted
```

### Загрузка секрета из файла

```shell
maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ kubectl apply -f domain-cert.yml
secret/domain-cert created
maxship@Ryzen5-Desktop:~/devops/devops-netology/14.01-kube-secrets$ kubectl get secret
NAME                  TYPE                                  DATA   AGE
default-token-7hltm   kubernetes.io/service-account-token   3      26d
domain-cert           kubernetes.io/tls                     2      13s
```

## Задача 2: Работа с секретами внутри модуля

### 2.1 Подключение секрета в виде примонтированного тома

Создал конфигурационный файл пода с подключением секрета в виде тома:

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: multitool-1
  name: pod-secret-mount
  namespace: default
spec:
  containers:
    - image: praqma/network-multitool:alpine-extra
      imagePullPolicy: IfNotPresent
      name: network-multitool
      volumeMounts:
        - name: certs-dir
          mountPath: /test-secret
  volumes:
    - name: certs-dir
      secret:
        secretName: domain-cert
  terminationGracePeriodSeconds: 30
```

Запустил под и проверил примонтированную директорию с сертификатом.

```shell
$ kubectl apply -f pod-secret-mount.yml 
pod/pod-secret-mount created

$ kubectl exec -it pod-secret-mount -- ls /test-secret
tls.crt  tls.key
```

### 2.2 Подключение секрета в виде переменной окружения

Зашифруем имя пользователя и пароль, используемые в переменной.

```shell
$ echo -n 'abc123' | base64
YWJjMTIz
$ echo -n 'test-user' | base64
dGVzdC11c2Vy
```

Создадим файл конфига для секрета с использованием полученных зашифрованных строк.

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: env-secret
type: Opaque
data:
  user: dGVzdC11c2Vy
  password: YWJjMTIz
```
Создаем секрет.

```shell
$ kubectl apply -f env-secret.yml 
secret/env-secret created
```

Создаем конфиг для пода с подключением секрета в виде переменной окружения.

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: multitool-2
  name: pod-secret-env
  namespace: default
spec:
  containers:
    - image: praqma/network-multitool:alpine-extra
      imagePullPolicy: IfNotPresent
      name: network-multitool
      env:
        - name: SECRET_USER
          valueFrom:
            secretKeyRef:
              name: env-secret
              key: user
        - name: SECRET_PASSWORD
          valueFrom:
            secretKeyRef:
              name: env-secret
              key: password
  terminationGracePeriodSeconds: 30
```

Запускаем под.

```shell
$ kubectl apply -f pod-secret-env.yml 
pod/pod-secret-env created
```

Смотрим список созданных объектов.

```shell
$ kubectl get po,secret
NAME                   READY   STATUS    RESTARTS   AGE
pod/pod-secret-env     1/1     Running   0          8m9s
pod/pod-secret-mount   1/1     Running   0          28m

NAME                         TYPE                                  DATA   AGE
secret/default-token-vk89p   kubernetes.io/service-account-token   3      51m
secret/domain-cert           kubernetes.io/tls                     2      35m
secret/env-secret            Opaque                                2      12m

```

Проверяем, прописались ли переменные:

```shell
$ kubectl exec -it pod-secret-env -- /bin/bash

bash-5.1# echo $SECRET_USER
test-user

bash-5.1# echo $SECRET_PASSWORD
abc123
```