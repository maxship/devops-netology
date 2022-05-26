# Домашнее задание к занятию "14.4 Сервис-аккаунты"

## Задача 1: Работа с сервис-аккаунтами через утилиту kubectl в установленном minikube

Выполните приведённые команды в консоли. Получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать сервис-аккаунт?

```
kubectl create serviceaccount netology
```

### Как просмотреть список сервис-акаунтов?

```
kubectl get serviceaccounts
kubectl get serviceaccount
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get serviceaccount netology -o yaml
kubectl get serviceaccount default -o json
```

### Как выгрузить сервис-акаунты и сохранить его в файл?

```
kubectl get serviceaccounts -o json > serviceaccounts.json
kubectl get serviceaccount netology -o yaml > netology.yml
```

### Как удалить сервис-акаунт?

```
kubectl delete serviceaccount netology
```

### Как загрузить сервис-акаунт из файла?

```
kubectl apply -f netology.yml
```

## Задача 2 (*): Работа с сервис-акаунтами внутри модуля

Выбрать любимый образ контейнера, подключить сервис-акаунты и проверить
доступность API Kubernetes

```
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
```

Просмотреть переменные среды

```
env | grep KUBE
```

Получить значения переменных

```
K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
SADIR=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat $SADIR/token)
CACERT=$SADIR/ca.crt
NAMESPACE=$(cat $SADIR/namespace)
```

Подключаемся к API

```
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/
```

В случае с minikube может быть другой адрес и порт, который можно взять здесь

```
cat ~/.kube/config
```

или здесь

```
kubectl cluster-info
```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

В качестве решения прикрепите к ДЗ конфиг файлы для деплоя. Прикрепите скриншоты вывода команды kubectl со списком запущенных объектов каждого типа (pods, deployments, serviceaccounts) или скриншот из самого Kubernetes, что сервисы подняты и работают, а также вывод из CLI.

---

# Решение

## Задача 1: Работа с сервис-аккаунтами через утилиту kubectl

```shell
# Создание сервис-аккаунтов

$ kubectl create serviceaccount netology
serviceaccount/netology created

# Просмотр списка сервис-акаунтов

$ kubectl get serviceaccounts
$ kubectl get serviceaccount
NAME       SECRETS   AGE
default    1         2d22h
netology   1         23s


# Получение информацию в формате YAML и/или JSON

$ kubectl get serviceaccount netology -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2022-05-26T06:06:11Z"
  name: netology
  namespace: default
  resourceVersion: "56679"
  uid: e3ff4ca4-a524-4ae8-99a9-78c77a7f6b9b
secrets:
- name: netology-token-9k2sg

$ kubectl get serviceaccount default -o json
{
    "apiVersion": "v1",
    "kind": "ServiceAccount",
    "metadata": {
        "creationTimestamp": "2022-05-23T07:11:16Z",
        "name": "default",
        "namespace": "default",
        "resourceVersion": "618",
        "uid": "4c3fea45-1789-4d8d-91df-2f1721fb48b6"
    },
    "secrets": [
        {
            "name": "default-token-tgfhr"
        }
    ]
}

# Выгрузка сервис-аккаунтов в файл

$ kubectl get serviceaccounts -o json > serviceaccounts.json
$ kubectl get serviceaccount netology -o yaml > netology.yml
$ ls
multitool.yml  netology.yml  README.md  serviceaccounts.json  test_app_configmap.yml  test_app.yml  vagrant

# Удаление сервис-аккаунта

$ kubectl delete serviceaccount netology
serviceaccount "netology" deleted

# Загрузка сервис-акаунт из файла

$ kubectl apply -f netology.yml
serviceaccount/netology configured

```

## Задача 2: Работа с сервис-аккаунтами внутри модуля

```shell
# Запускаем тестовый под

$ kubectl apply -f multitool.yml
$ kubectl exec -ti multitool -- sh

# Выводим в терминал переменные среды

$ env | grep KUBE
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443

# Создаем новые переменные окружения

$ K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
$ echo $K8S
https://10.96.0.1:443

$ SADIR=/var/run/secrets/kubernetes.io/serviceaccount

$ TOKEN=$(cat $SADIR/token)
$ echo $TOKEN
eyJhbGciOiJ.......

$ CACERT=$SADIR/ca.crt
$ cat $SADIR/ca.crt
-----BEGIN CERTIFICATE-----
MIIC/jCCAeagAwIBAgIBADANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwprdWJl
.....
-----END CERTIFICATE-----

$ NAMESPACE=$(cat $SADIR/namespace)

# Подключаемся к API, использую заданные выше переменные

$ curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/
{
  "kind": "APIResourceList",
  "groupVersion": "v1",
  "resources": [
    {
      ..........
      ..........
      ..........
     "name": "services/status",
      "singularName": "",
      "namespaced": true,
      "kind": "Service",
      "verbs": [
        "get",
        "patch",
        "update"
      ]
    }
  ]
}
```