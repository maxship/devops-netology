# Домашнее задание к занятию "14.3 Карты конфигураций"

## Задача 1: Работа с картами конфигураций через утилиту kubectl в установленном minikube

Выполните приведённые команды в консоли. Получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать карту конфигураций?

```
kubectl create configmap nginx-config --from-file=nginx.conf
kubectl create configmap domain --from-literal=name=netology.ru
```

### Как просмотреть список карт конфигураций?

```
kubectl get configmaps
kubectl get configmap
```

### Как просмотреть карту конфигурации?

```
kubectl get configmap nginx-config
kubectl describe configmap domain
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get configmap nginx-config -o yaml
kubectl get configmap domain -o json
```

### Как выгрузить карту конфигурации и сохранить его в файл?

```
kubectl get configmaps -o json > configmaps.json
kubectl get configmap nginx-config -o yaml > nginx-config.yml
```

### Как удалить карту конфигурации?

```
kubectl delete configmap nginx-config
```

### Как загрузить карту конфигурации из файла?

```
kubectl apply -f nginx-config.yml
```

## Задача 2 (*): Работа с картами конфигураций внутри модуля

Выбрать любимый образ контейнера, подключить карты конфигураций и проверить
их доступность как в виде переменных окружения, так и в виде примонтированного
тома

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

В качестве решения прикрепите к ДЗ конфиг файлы для деплоя. Прикрепите скриншоты вывода команды kubectl со списком запущенных объектов каждого типа (pods, deployments, configmaps) или скриншот из самого Kubernetes, что сервисы подняты и работают, а также вывод из CLI.

---

# Решение

## Задача 1: Работа с картами конфигураций через утилиту kubectl.

```shell
# Создание карт конфигурации
$ kubectl create configmap nginx-config --from-file=nginx.conf
configmap/nginx-config created
$ kubectl create configmap domain --from-literal=name=netology.ru
configmap/domain created

### Просмотр списка карт
$ kubectl get configmaps 
NAME               DATA   AGE
domain             1      17s
kube-root-ca.crt   1      19m
nginx-config       1      3m2s

# Просмотр содержимого карты
$ kubectl get configmap nginx-config
NAME           DATA   AGE
nginx-config   1      3m45s
$ kubectl describe configmap domain
Name:         domain
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
name:
----
netology.ru

BinaryData
====

Events:  <none>

# Получение информации в формате YAML и JSON
$ kubectl get configmap nginx-config -o yaml
apiVersion: v1
data:
  nginx.conf: |
    server {
        listen 80;
        server_name  netology.ru www.netology.ru;
        access_log  /var/log/nginx/domains/netology.ru-access.log  main;
        error_log   /var/log/nginx/domains/netology.ru-error.log info;
        location / {
            include proxy_params;
            proxy_pass http://10.10.10.10:8080/;
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2022-05-23T07:27:36Z"
  name: nginx-config
  namespace: default
  resourceVersion: "2284"
  uid: 5d9d8342-0eec-4c4b-8a11-a84eac3f19ed

$ kubectl get configmap domain -o json
{
    "apiVersion": "v1",
    "data": {
        "name": "netology.ru"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2022-05-23T07:30:21Z",
        "name": "domain",
        "namespace": "default",
        "resourceVersion": "2518",
        "uid": "99d6bfe6-b8f7-4c7c-a92a-22a070ea7c20"
    }
}

# Выгрузка карт конфигурации в файл
$ kubectl get configmaps -o json > configmaps.json
$ kubectl get configmap nginx-config -o yaml > nginx-config.yml
$ ls
configmaps.json  env-secret.yml  generator.py  multitool.yml  myapp-pod.yml  nginx.conf  nginx-config.yml  README.md  templates

# Удаление
$ kubectl delete configmap nginx-config
configmap "nginx-config" deleted

# Создание карты из файла
$ kubectl apply -f nginx-config.yml
configmap/nginx-config created
```

## Задача 2: Работа с картами конфигураций внутри модуля

Карта конфигурации для nginx:

```yaml
# test_app_configmap.yml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-configmap
data:
  nginx.conf: |
    server {
        server_name   localhost;
        listen        127.0.0.1:8888;

        error_page    500 502 503 504  /50x.html;

        location      / {
            root   /usr/share/nginx/html;
        }
    }
  nginx.html: |
    <html><head><h1>NGINX</h1></head>
    <body><h2>This is test static page</h2>
    </body></html>
  ConfigMapEnv: "NGINX_CONFIG" # Не будет влиять на работу приложения - добавлена для примера
```

Манифест для пода с картой конфигурации, переданной через примонтированные тома. Также для примера добавлена переменная среды из карты.

```yaml
# test_app.yml
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-config-test
spec:
  containers:
  - name: nginx
    image: nginx:1.21.6
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - name: nginx-static-page
        mountPath: /usr/share/nginx/html/
        readOnly: true
      - name: nginx-config
        mountPath: /etc/nginx/conf.d/
    env:
      - name: ConfigMapEnv
        valueFrom:
          configMapKeyRef:
            name: nginx-configmap
            key: ConfigMapEnv           
  volumes:
  - name: nginx-static-page
    configMap:
      name: nginx-configmap
      items:
        - key: nginx.html
          path: index.html
  - name: nginx-config
    configMap:
      name: nginx-configmap
      items:
        - key: nginx.conf
          path: default.conf
```

Запускаем карту и приложение.

```shell
$ kubectl apply -f test_app_configmap.yml 
configmap/nginx-configmap created
$ kubectl apply -f test_app.yml 
pod/nginx-config-test configured

$ kubectl get po,configmaps 
NAME                    READY   STATUS    RESTARTS   AGE
pod/nginx-config-test   1/1     Running   0          29m

NAME                         DATA   AGE
configmap/kube-root-ca.crt   1      3h13m
configmap/nginx-configmap    3      29m
```

Проверяем работоспособность:

```shell
# Проверка параметров карты, переданных через примонтированные тома:
$ kubectl exec -it nginx-config-test -- cat /etc/nginx/conf.d/default.conf
server {
    server_name   localhost;
    listen        127.0.0.1:8888;

    error_page    500 502 503 504  /50x.html;

    location      / {
        root   /usr/share/nginx/html;
    }
}

$ kubectl exec -it nginx-config-test -- cat /usr/share/nginx/html/index.html
<html><head><h1>NGINX</h1></head>
<body><h2>Config status: applied</h2>
</body></html>

$ kubectl port-forward nginx-config-test 8888:8888
Forwarding from 127.0.0.1:8888 -> 8888
Forwarding from [::1]:8888 -> 8888
Handling connection for 8888

$ curl localhost:8888
<html><head><h1>NGINX</h1></head>
<body><h2>This is test static page</h2>
</body></html>

# Проверка параметров карты, переданных в виде переменной:
$ kubectl exec -it nginx-config-test -- env | grep ConfigMapEnv
ConfigMapEnv=NGINX_CONFIG
```