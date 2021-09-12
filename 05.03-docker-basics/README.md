# Домашнее задание к занятию "5.3. Контейнеризация на примере Docker"

## Задача 1 

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование докера? Или лучше подойдет виртуальная машина, физическая машина? Или возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение; 
- Go-микросервис для генерации отчетов;
- Nodejs веб-приложение;
- Мобильное приложение c версиями для Android и iOS;
- База данных postgresql используемая, как кэш;
- Шина данных на базе Apache Kafka;
- Очередь для Logstash на базе Redis;
- Elastic stack для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
- Мониторинг-стек на базе prometheus и grafana;
- Mongodb, как основное хранилище данных для java-приложения;
- Jenkins-сервер.

## Задача 2 

Сценарий выполения задачи:

- создайте свой репозиторий на докерхаб; 
- выберете любой образ, который содержит апачи веб-сервер;
- создайте свой форк образа;
- реализуйте функциональность: 
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже: 
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m kinda DevOps now</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на докерхаб-репо.

```
vagrant@vagrant:~$ docker pull httpd

vagrant@vagrant:~$ docker run --name apache_test -p 8095:80 -v /home/vagrant/index.html:/usr/local/apache2/htdocs/index.html -d httpd

vagrant@vagrant:~$ docker ps
CONTAINER ID   IMAGE     COMMAND              CREATED              STATUS              PORTS                                   NAMES
08f77f950827   httpd     "httpd-foreground"   About a minute ago   Up About a minute   0.0.0.0:8095->80/tcp, :::8095->80/tcp   apache_test

vagrant@vagrant:~$ docker commit 08f77f950827 moshipitsyn/apache_test:v1

vagrant@vagrant:~$ docker login

vagrant@vagrant:~$ docker images
REPOSITORY                TAG       IMAGE ID       CREATED              SIZE
moshipitsyn/apache_test   v1        d9da77d323dd   About a minute ago   138MB
httpd                     latest    f34528d8e714   9 days ago           138MB

vagrant@vagrant:~$ docker image push moshipitsyn/apache_test:v1
```
https://hub.docker.com/repository/docker/moshipitsyn/apache_test

## Задача 3 

- Запустите первый контейнер из образа centos c любым тэгом в фоновом режиме, подключив папку info из текущей рабочей директории на хостовой машине в /share/info контейнера;
- Запустите второй контейнер из образа debian:latest в фоновом режиме, подключив папку info из текущей рабочей директории на хостовой машине в /info контейнера;
- Подключитесь к первому контейнеру с помощью exec и создайте текстовый файл любого содержания в /share/info ;
- Добавьте еще один файл в папку info на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в /info контейнера.

```
vagrant@vagrant:~$ docker run -dt --name centos -v /home/vagrant/info:/share/info centos:latest

vagrant@vagrant:~$ docker run -dt --name debian -v /home/vagrant/info:/share/info debian:latest

vagrant@vagrant:~$ docker ps
CONTAINER ID   IMAGE           COMMAND       CREATED              STATUS              PORTS     NAMES
9ec4b784a635   debian:latest   "bash"        4 seconds ago        Up 4 seconds                  debian
a7d0c345bb2f   centos:latest   "/bin/bash"   About a minute ago   Up About a minute             centos

vagrant@vagrant:~$ docker exec -ti centos bash
[root@a7d0c345bb2f /]# echo "Test file" > /share/info/shared_file

vagrant@vagrant:~$ docker exec -ti debian bash
root@9ec4b784a635:/# cat /share/info/shared_file
Test file

vagrant@vagrant:~$ echo "Test file 2" > info/shared_file_2

vagrant@vagrant:~$ docker exec -ti debian bash
root@9ec4b784a635:/# cat /share/info/shared_file_2
Test file 2

```

