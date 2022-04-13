# Домашнее задание к занятию "13.3 работа с kubectl"
## Задание 1: проверить работоспособность каждого компонента
Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:
* сделайте запросы к бекенду;
* сделайте запросы к фронту;
* подключитесь к базе данных.

## Задание 2: ручное масштабирование

При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3. Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe, kubectl get pods -o wide). После уменьшите количество копий до 1.

---

# Решение
## Задание 1: проверить работоспособность каждого компонента

Для выполнения проверок потребуются дополнительные инструменты. 
На локальную машину установим клиент БД командой `apt-get install -y postgresql-client`, в кластере развернем `multitool`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: multitool
  name: multitool
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: multitool
  template:
    metadata:
      labels:
        app: multitool
    spec:
      containers:
        - image: praqma/network-multitool:alpine-extra
          imagePullPolicy: IfNotPresent
          name: network-multitool
      terminationGracePeriodSeconds: 30
```
Запустим приложения из папки [prod](./prod).

```shell
Every 2,0s: kubectl get po,svc -o wide                                                              Ryzen5-Desktop: Wed Apr 13 13:47:27 2022

NAME                             READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
pod/backend-b5d9bcd48-5ztdt      1/1     Running   0          25m   10.233.112.2   node-1   <none>           <none>
pod/backend-b5d9bcd48-grbmv      1/1     Running   0          25m   10.233.69.2    node-2   <none>           <none>
pod/frontend-65869b85df-rn7kg    1/1     Running   0          25m   10.233.112.3   node-1   <none>           <none>
pod/frontend-65869b85df-vc9sf    1/1     Running   0          25m   10.233.69.3    node-2   <none>           <none>
pod/multitool-55974d5464-kt75l   1/1     Running   0          22m   10.233.112.4   node-1   <none>           <none>
pod/postgres-0                   1/1     Running   0          26m   10.233.69.1    node-2   <none>           <none>

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
service/backend      ClusterIP   10.233.12.61    <none>        9000/TCP   25m   app=backend
service/frontend     ClusterIP   10.233.36.106   <none>        8000/TCP   25m   app=frontend
service/kubernetes   ClusterIP   10.233.0.1      <none>        443/TCP    63m   <none>
service/postgres     ClusterIP   10.233.50.97    <none>        5432/TCP   26m   app=postgres
```

Проверяем backend:

```shell
# На локальной машине
$ kubectl port-forward service/backend 9000:9000
Forwarding from 127.0.0.1:9000 -> 9000
Forwarding from [::1]:9000 -> 9000
Handling connection for 9000

$ curl 127.0.0.1:9000 -s -m 1
{"detail":"Not Found"}

# Внутри кластера
$ kubectl exec -it pod/multitool-55974d5464-kt75l -- sh -c "curl backend:9000 -s -m 1"
{"detail":"Not Found"}
```
Проверяем frontend:

```shell
# На локальной машине
$ kubectl port-forward service/frontend 8000:8000
Forwarding from 127.0.0.1:8000 -> 80
Forwarding from [::1]:8000 -> 80
Handling connection for 8000

$ curl 127.0.0.1:8000 -s -m 1
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

# Внутри кластера
$ kubectl exec -it pod/multitool-55974d5464-kt75l -- sh -c "curl frontend:8000 -s -m 1"
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
```

Проверяем БД:

```shell
# Подключение к БД внутри кластера.
$ kubectl exec -it pod/multitool-55974d5464-kt75l -- sh -c "psql -h postgres -d news -U postgres -W"
Password: 
psql (13.4, server 13.6)
Type "help" for help.

news=# 

# Подключение с локальной машины.
$ kubectl port-forward service/postgres 5433:5432
Forwarding from 127.0.0.1:5433 -> 5432
Forwarding from [::1]:5433 -> 5432

$ psql -h 127.0.0.1 -p 5433 -d news -U postgres -W
Password: 
psql (12.9 (Ubuntu 12.9-0ubuntu0.20.04.1), server 13.6)
WARNING: psql major version 12, server major version 13.
         Some psql features might not work.
Type "help" for help.

news=# 
```

## Задание 2: ручное масштабирование

```shell
# Увеличиваем количество реплик
$ kubectl scale deployment backend frontend --replicas=3
deployment.apps/backend scaled
deployment.apps/frontend scaled

# Видим, что поды равномерно распределились по рабочим нодам.
$ kubectl get po -o wide
NAME                         READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
backend-b5d9bcd48-5ztdt      1/1     Running   0          28m   10.233.112.2   node-1   <none>           <none>
backend-b5d9bcd48-grbmv      1/1     Running   0          28m   10.233.69.2    node-2   <none>           <none>
backend-b5d9bcd48-s7hv8      1/1     Running   0          72s   10.233.69.4    node-2   <none>           <none>
frontend-65869b85df-8pdnl    1/1     Running   0          38s   10.233.112.5   node-1   <none>           <none>
frontend-65869b85df-rn7kg    1/1     Running   0          28m   10.233.112.3   node-1   <none>           <none>
frontend-65869b85df-vc9sf    1/1     Running   0          28m   10.233.69.3    node-2   <none>           <none>
multitool-55974d5464-kt75l   1/1     Running   0          25m   10.233.112.4   node-1   <none>           <none>
postgres-0                   1/1     Running   0          29m   10.233.69.1    node-2   <none>           <none>

$ kubectl describe po frontend | grep Node:
Node:         node-1/10.2.0.4
Node:         node-1/10.2.0.4
Node:         node-2/10.2.0.13

$ kubectl describe po backend | grep Node:
Node:         node-1/10.2.0.4
Node:         node-2/10.2.0.13
Node:         node-2/10.2.0.13

# Уменьшаем количество реплик
$ kubectl scale deployment backend frontend --replicas=1

$ kubectl get po -o wide
NAME                         READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
backend-b5d9bcd48-5ztdt      1/1     Running   0          34m   10.233.112.2   node-1   <none>           <none>
frontend-65869b85df-vc9sf    1/1     Running   0          34m   10.233.69.3    node-2   <none>           <none>
multitool-55974d5464-kt75l   1/1     Running   0          31m   10.233.112.4   node-1   <none>           <none>
postgres-0                   1/1     Running   0          34m   10.233.69.1    node-2   <none>           <none>
```