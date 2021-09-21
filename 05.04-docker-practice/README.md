# Домашнее задание к занятию "5.4. Практические навыки работы с Docker"

## Задача 1 

В данном задании вы научитесь изменять существующие Dockerfile, адаптируя их под нужный инфраструктурный стек.

Измените базовый образ предложенного Dockerfile на Arch Linux c сохранением его функциональности.

```text
FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:vincent-c/ponysay && \
    apt-get update
 
RUN apt-get install -y ponysay

ENTRYPOINT ["/usr/bin/ponysay"]
CMD ["Hey, netology”]
```

Для получения зачета, вам необходимо предоставить:
- Написанный вами Dockerfile
- Скриншот вывода командной строки после запуска контейнера из вашего базового образа
- Ссылку на образ в вашем хранилище docker-hub

Заменяем ubuntu на arch, и менеджер пакетов apt на pacman: 

```Dockerfile
FROM archlinux:latest

RUN pacman -Syy --noconfirm ponysay

ENTRYPOINT ["/usr/bin/ponysay"]
CMD ["Hey, netology”]
```

Собираем образ и запускаем контейнер.
```
root@vagrant:/home/vagrant/docker_ponysay# docker build -t pony_arch -f df_pony_arch .

root@vagrant:/home/vagrant/docker_ponysay# docker run -it pony_arch
```

![pony](https://user-images.githubusercontent.com/72273610/132704491-86b5dd46-c87e-4108-8a1e-dd195e8123ae.JPG)


Пушим образ в репозиторий.
```

root@vagrant:/home/vagrant/docker_ponysay# docker tag pony_arch:latest moshipitsyn/pony_arch:ponysay
root@vagrant:/home/vagrant/docker_ponysay# docker login docker.io
root@vagrant:/home/vagrant/docker_ponysay# docker push moshipitsyn/pony_arch:ponysay
```

https://hub.docker.com/repository/docker/moshipitsyn/pony_arch


## Задача 2 

В данной задаче вы составите несколько разных Dockerfile для проекта Jenkins, опубликуем образ в `dockerhub.io` и посмотрим логи этих контейнеров.

- Составьте 2 Dockerfile:

    - Общие моменты:
        - Образ должен запускать [Jenkins server](https://www.jenkins.io/download/)
        
    - Спецификация первого образа:
        - Базовый образ - [amazoncorreto](https://hub.docker.com/_/amazoncorretto)
        - Присвоить образу тэг `ver1` 
    
    - Спецификация второго образа:
        - Базовый образ - [ubuntu:latest](https://hub.docker.com/_/ubuntu)
        - Присвоить образу тэг `ver2` 

- Соберите 2 образа по полученным Dockerfile
- Запустите и проверьте их работоспособность
- Опубликуйте образы в своём dockerhub.io хранилище

Для получения зачета, вам необходимо предоставить:
- Наполнения 2х Dockerfile из задания
- Скриншоты логов запущенных вами контейнеров (из командной строки)
- Скриншоты веб-интерфейса Jenkins запущенных вами контейнеров (достаточно 1 скриншота на контейнер)
- Ссылки на образы в вашем хранилище docker-hub

### Создайем докерфайл для первого образа.

```dockerfile

FROM amazoncorretto:latest

#Вариант установки из war файла (https://www.jenkins.io/doc/book/installing/)

ADD https://get.jenkins.io/war-stable/2.303.1/jenkins.war /root/

WORKDIR /root

EXPOSE 8095

ENTRYPOINT ["java"]

CMD ["-jar", "jenkins.war"]
```
```
vagrant@vagrant:~/jenkins$ docker build -t jenkins_amazon:ver1 -f DF_jen_amazon .
vagrant@vagrant:~/jenkins$ docker run --name jenkins_amazon -it -p 8095:8080 jenkins_amazon:ver1
```

![8095_2](https://user-images.githubusercontent.com/72273610/133925987-3c0ac28f-f42b-46f3-b806-8032d21a80ca.JPG)

![8095](https://user-images.githubusercontent.com/72273610/133925989-56b4fb62-216d-4745-82c6-aa574e5e3878.JPG)


### Создайем докерфайл для второго образа.

```dockerfile
FROM ubuntu:latest

RUN apt-get update \
  && apt install -y default-jdk
  
ADD https://get.jenkins.io/war-stable/2.303.1/jenkins.war /root/

WORKDIR /root

EXPOSE 8096

ENTRYPOINT ["java"]

CMD ["-jar", "jenkins.war"]
```
```
vagrant@vagrant:~/jenkins$ docker build -t jenkins_ubuntu:ver2 -f DF_jen_ubuntu .
vagrant@vagrant:~/jenkins$ docker run --name jenkins_ubuntu -it -p 8096:8080 jenkins_ubuntu:ver2
```
![8096_2](https://user-images.githubusercontent.com/72273610/133926039-aea553f1-d1ed-4a5c-b7d9-c8dd45ddd882.JPG)

![8096](https://user-images.githubusercontent.com/72273610/133926041-45536352-3835-4854-8322-f8173d47e7be.JPG)

### Обрызы на Dockerhub:

https://hub.docker.com/r/moshipitsyn/jenkins_ubuntu

https://hub.docker.com/r/moshipitsyn/jenkins_amazon


## Задача 3 

В данном задании вы научитесь:
- объединять контейнеры в единую сеть
- исполнять команды "изнутри" контейнера

Для выполнения задания вам нужно:
- Написать Dockerfile: 
    - Использовать образ https://hub.docker.com/_/node как базовый
    - Установить необходимые зависимые библиотеки для запуска npm приложения https://github.com/simplicitesoftware/nodejs-demo
    - Выставить у приложения (и контейнера) порт 3000 для прослушки входящих запросов  
    - Соберите образ и запустите контейнер в фоновом режиме с публикацией порта

- Запустить второй контейнер из образа ubuntu:latest 
- Создайть `docker network` и добавьте в нее оба запущенных контейнера
- Используя `docker exec` запустить командную строку контейнера `ubuntu` в интерактивном режиме
- Используя утилиту `curl` вызвать путь `/` контейнера с npm приложением  

Для получения зачета, вам необходимо предоставить:
- Наполнение Dockerfile с npm приложением
- Скриншот вывода вызова команды списка docker сетей (docker network cli)
- Скриншот вызова утилиты curl с успешным ответом

---

Докер-файл:

```dockerfile
FROM node:latest

# Добавляем в образ файлы установки из https://github.com/simplicitesoftware/nodejs-demo.
# Предварительно в файле app.js заменен 'localhost' на '0.0.0.0'.

COPY nodejs-demo /usr/local/bin

RUN cd /usr/local/bin && npm install

EXPOSE 3000

WORKDIR /usr/local/bin

CMD npm start
```

Создаем образ и запускаем контейнер.

```
vagrant@vagrant:~/nodejs$ docker build -t node_npm:v1 -f DF_nodejs_npm .

vagrant@vagrant:~/nodejs$ docker run --name node_npm -it --rm -p 3000:3000 node_npm:v1
```
Проверяем сервис с хоста.

![node_scr](https://user-images.githubusercontent.com/72273610/134154319-51556023-cf47-400c-a381-6bf488f44b3f.JPG)

Запускаем контейнер с убунту, устанавливаем утилиту curl.

```
vagrant@vagrant:~/nodejs$ docker run --name ubuntu_curl -dt --rm --publish-all ubuntu_curl
```
Создаем новую сеть и подключаем к ней оба контейнера.

```
vagrant@vagrant:~/nodejs$ docker network create -d bridge net_npm

vagrant@vagrant:~/nodejs$ docker network connect net_npm ubuntu_curl

vagrant@vagrant:~/nodejs$ docker network connect net_npm node_npm
```

Смотрим параметры сети, узнаем ip-адрес сервера nodejs.

```
vagrant@vagrant:~/nodejs$ docker network inspect net_npm
[
    {
        "Name": "net_npm",
......
        "Containers": {
            "02623d71ba575b6b9ee97e2d7294382a8b1716494638f84c0d78e9d5fd58d600": {
                "Name": "ubuntu_curl",
                "EndpointID": "95fa5fa1da0abc87e2774e68e34ee48a02dba18e6fa00f7bcfd97690400d268d",
                "MacAddress": "02:42:ac:13:00:02",
                "IPv4Address": "172.19.0.2/16",
                "IPv6Address": ""
            },
            "47a08a683c4483cdeb478031a03d40a46e0add77ae1c80f4cd8e6da2f3687bdf": {
                "Name": "node_npm",
                "EndpointID": "056bfc89604dbc1e456dd90a18d62555010b68966fc9cd418b49d5bbf6a8061d",
                "MacAddress": "02:42:ac:13:00:03",
                "IPv4Address": "172.19.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```

Заходим в контейнер с убунтой и проверяем доступность приложения npm.

```
vagrant@vagrant:~/nodejs$ docker exec -ti ubuntu_curl bash

root@02623d71ba57:/# curl -I 172.19.0.3:3000
HTTP/1.1 200 OK
Cache-Control: private, no-cache, no-store, no-transform, must-revalidate
Expires: -1
Pragma: no-cache
Content-Type: text/html; charset=utf-8
Content-Length: 527202
ETag: W/"80b62-tsCV4CalCNGk8OT00a+2m+rHwZw"
Date: Tue, 21 Sep 2021 10:16:33 GMT
Connection: keep-alive
Keep-Alive: timeout=5
```

![node_curl](https://user-images.githubusercontent.com/72273610/134154138-3816ce60-f206-41de-84ad-2a96a68b0cb5.JPG)

