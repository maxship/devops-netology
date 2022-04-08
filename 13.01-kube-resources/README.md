# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"
Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

## Задание 1: подготовить тестовый конфиг для запуска приложения
Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
* под содержит в себе 2 контейнера — фронтенд, бекенд;
* регулируется с помощью deployment фронтенд и бекенд;
* база данных — через statefulset.

## Задание 2: подготовить конфиг для production окружения
Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.

## Задание 3 (*): добавить endpoint на внешний ресурс api
Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:
* добавлен endpoint до внешнего api (например, геокодер).

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

В качестве решения прикрепите к ДЗ конфиг файлы для деплоя. Прикрепите скриншоты вывода команды kubectl со списком запущенных объектов каждого типа (pods, deployments, statefulset, service) или скриншот из самого Kubernetes, что сервисы подняты и работают.

---
# Решение
## Задание 1: подготовить тестовый конфиг для запуска приложения

Соберем и загрузим в репозиторий образы для фронтенда и бекенда.
```shell
# Образ фронтенда
$ docker login
$ docker build -t k8s-frontend:v1 -f Dockerfile .
$ docker tag k8s-frontend:v1 moshipitsyn/k8s-frontend:v1
$ docker push moshipitsyn/k8s-frontend:v1

# Образ бекенда
$ docker build -t k8s-backend:v1 -f Dockerfile .
$ docker tag k8s-backend:v1 moshipitsyn/k8s-backend:v1
$ docker push moshipitsyn/k8s-backend:v1
```
Манифест для БД и ее сервиса:
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  labels:
    app: postgres
  namespace: default
spec:
  serviceName: "postgres"
  selector:
    matchLabels:
      app: postgres # должен совпадать с .spec.template.metadata.labels
  template:
    metadata:
      labels:
        app: postgres # должен совпадать с .spec.selector.matchLabels
    spec:
      containers:
      - name: postgres
        image: postgres:13-alpine
        imagePullPolicy: IfNotPresent
        ports:
          - containerPort: 5432
        volumeMounts:
          - name: db-volume
            mountPath: /data
        env:
          - name: POSTGRES_PASSWORD
            value: postgres
          - name: POSTGRES_USER
            value: postgres
          - name: POSTGRES_DB
            value: news
      volumes:
        - name: db-volume

---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: default
spec:
  selector:
    app: postgres
  ports:
    - name: postgres
      protocol: TCP
      port: 5432
      targetPort: 5432
  type: ClusterIP
```
Манифест для деплоймента фронтенд + бекенд:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-backend
  labels:
    app: frontend-backend
  namespace: default
spec:
  selector:
    matchLabels:
      app: frontend-backend
  template:
    metadata:
      labels:
        app: frontend-backend
    spec:
      containers:
      - image: moshipitsyn/k8s-frontend:v1
        imagePullPolicy: IfNotPresent
        name: frontend
        ports:
        - containerPort: 80
        env:
          - name: BASE_URL
            value: http://localhost:9000
      - image: moshipitsyn/k8s-backend:v1
        imagePullPolicy: IfNotPresent
        name: backend
        ports:
        - containerPort: 9000
        env:
          - name: DATABASE_URL
            value: postgres://postgres:postgres@postgres:5432/news

---
apiVersion: v1
kind: Service
metadata:
  name: frontend-backend
  namespace: default
spec:
  selector:
    app: frontend-backend
  ports:
    - name: front
      protocol: TCP
      port: 8000
      targetPort: 80
    - name: back
      protocol: TCP
      port: 9000
      targetPort: 9000
  type: ClusterIP
```

```shell
# Запускаем БД и сервис для нее.
maxship@Ryzen5-Desktop:~/devops/devops-netology/13.01-kube-resources/stage$ kubectl apply -f db.yaml 
statefulset.apps/postgres created
service/postgres created

# То же самое делаем для приложения.
maxship@Ryzen5-Desktop:~/devops/devops-netology/13.01-kube-resources/stage$ kubectl apply -f back-front.yaml 
deployment.apps/frontend-backend created
service/frontend-backend created

# Деплойменты:
maxship@Ryzen5-Desktop:~/devops/devops-netology/13.01-kube-resources/stage$ kubectl get deploy -o wide
NAME               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS         IMAGES                                                   SELECTOR
frontend-backend   1/1     1            1           17m   frontend,backend   moshipitsyn/k8s-frontend:v1,moshipitsyn/k8s-backend:v1   app=frontend-backend

# Поды:
maxship@Ryzen5-Desktop:~/devops/devops-netology/13.01-kube-resources/stage$ kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS   AGE     IP              NODE     NOMINATED NODE   READINESS GATES
frontend-backend-7898678669-vrxbj   2/2     Running   0          2m46s   10.233.69.17    node-2   <none>           <none>
postgres-0                          1/1     Running   0          3m30s   10.233.112.16   node-1   <none>           <none>

# StatefulSets:
maxship@Ryzen5-Desktop:~/devops/devops-netology/13.01-kube-resources/stage$ kubectl get statefulset.app -o wide
NAME       READY   AGE   CONTAINERS   IMAGES
postgres   1/1     16m   postgres     postgres:13-alpine

# Сервисы:
maxship@Ryzen5-Desktop:~/devops/devops-netology/13.01-kube-resources/stage$ kubectl get svc -o wide
NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)             AGE     SELECTOR
frontend-backend   ClusterIP   10.233.60.47   <none>        8000/TCP,9000/TCP   3m13s   app=frontend-backend
kubernetes         ClusterIP   10.233.0.1     <none>        443/TCP             173m    <none>
postgres           ClusterIP   10.233.16.2    <none>        5432/TCP            3m57s   app=postgres

# Проверяем настройки сервисов:
maxship@Ryzen5-Desktop:~/devops/devops-netology/13.01-kube-resources/stage$ kubectl describe svc frontend-backend 
Name:              frontend-backend
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=frontend-backend
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.233.60.47
IPs:               10.233.60.47
Port:              front  8000/TCP
TargetPort:        80/TCP
Endpoints:         10.233.69.17:80
Port:              back  9000/TCP
TargetPort:        9000/TCP
Endpoints:         10.233.69.17:9000
Session Affinity:  None
Events:            <none>

maxship@Ryzen5-Desktop:~/devops/devops-netology/13.01-kube-resources/stage$ kubectl describe svc postgres 
Name:              postgres
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=postgres
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.233.16.2
IPs:               10.233.16.2
Port:              postgres  5432/TCP
TargetPort:        5432/TCP
Endpoints:         10.233.112.16:5432
Session Affinity:  None
Events:            <none>

# При использовании сервисов типа ClusterIP на удаленном хосте, мы можем проверить работоспособность изнутри кластера. Для этого подключимся по ssh к одной из нод.
ubuntu@node-1:~$ curl 10.233.60.47:8000
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>

ubuntu@node-1:~$ curl 10.233.60.47:9000
{"detail":"Not Found"}
```

## Задание 2: подготовить конфиг для production окружения
