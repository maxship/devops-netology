# Домашнее задание к занятию "13.2 разделы и монтирование"
Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные. А сам бекенд генерирует статику для фронта. Нужно оптимизировать это.
Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):
* установить helm: curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
* добавить репозиторий чартов: helm repo add stable https://charts.helm.sh/stable && helm repo update
* установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner

В конце установки будет выдан пример создания PVC для этого сервера.

## Задание 1: подключить для тестового конфига общую папку
В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:
* в поде подключена общая папка между контейнерами (например, /static);
* после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.

## Задание 2: подключить общую папку для прода
Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:
* все бекенды подключаются к одному PV в режиме ReadWriteMany;
* фронтенды тоже подключаются к этому же PV с таким же режимом;
* файлы, созданные бекендом, должны быть доступны фронту.

---

# Решение
## Задание 1: подключить для тестового конфига общую папку

```shell
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm repo add stable https://charts.helm.sh/stable && helm repo update
helm install nfs-server stable/nfs-server-provisioner

# на нодах:
sudo apt install nfs-common
```

```yaml
# 13.02-kube-storage/stage/pv.yml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-stage
spec:
  storageClassName: "nfs"
  accessModes:
    - ReadWriteMany
  capacity:
    storage: 10Mi
  hostPath:
    path: /data/pv

# 13.02-kube-storage/stage/pvc.yml 
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-stage
spec:
  storageClassName: "nfs"
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Mi   
    
# 13.02-kube-storage/stage/back.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: backend
  namespace: default
spec:
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - image: moshipitsyn/k8s-backend:v2
        imagePullPolicy: IfNotPresent
        name: backend
        ports:
        - containerPort: 9000
        env:
          - name: DATABASE_URL
            value: postgres://postgres:postgres@postgres:5432/news # адрес сервиса БД
        volumeMounts:
        - mountPath: "/static/pv" # директория в контейнере для монтирования тома
          name: pv-stage
      volumes:
        - name: pv-stage
          persistentVolumeClaim:
            claimName: pvc-stage

# 13.02-kube-storage/stage/front.yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: frontend
  namespace: default
spec:
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - image: moshipitsyn/k8s-frontend:v1
        imagePullPolicy: IfNotPresent
        name: frontend
        ports:
        - containerPort: 80
        env:
          - name: BASE_URL
            value: backend:9000 # адрес сервиса бекенда
        volumeMounts:
        - mountPath: "/static/pv" # директория в контейнере для монтирования тома
          name: pv-stage
      volumes:
        - name: pv-stage
          persistentVolumeClaim:
            claimName: pvc-stage
```
```shell
$ kubectl apply -f pv.yml
$ kubectl apply -f pvc.yml
$ kubectl apply -f back.yaml
$ kubectl apply -f front.yml

$ kubectl get pv,pvc -o wide
NAME                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS   REASON   AGE     VOLUMEMODE
persistentvolume/pv-stage   10Mi       RWX            Retain           Bound    default/pvc-stage   nfs                     4m29s   Filesystem

NAME                              STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   AGE    VOLUMEMODE
persistentvolumeclaim/pvc-stage   Bound    pv-stage   10Mi       RWX            nfs            4m5s   Filesystem

$ kubectl get po -o wide
NAME                                  READY   STATUS    RESTARTS   AGE     IP             NODE     NOMINATED NODE   READINESS GATES
backend-6899f7479c-fk624              1/1     Running   0          2m54s   10.233.69.7    node-2   <none>           <none>
frontend-59b747c49b-7wttl             1/1     Running   0          2m44s   10.233.112.6   node-1   <none>           <none>
nfs-server-nfs-server-provisioner-0   1/1     Running   0          52m     10.233.112.4   node-1   <none>           <none>

# Создадим тестовый файл в одном из подов.
$ kubectl exec backend-6899f7479c-fk624 -c backend -- sh -c "echo 'pv-test' > /static/pv/pv-test-file"
$ kubectl exec backend-6899f7479c-fk624 -c backend -- sh -c "cat /static/pv/pv-test-file"
pv-test
$ kubectl exec frontend-59b747c49b-7wttl -c frontend -- sh -c "cat /static/pv/pv-test-file"
pv-test

#

```
