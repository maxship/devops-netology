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

Создайем докерфайл для первого образа.

```dockerfile
FROM amazoncorretto:latest

#Используем вариант установки из war файла (https://www.jenkins.io/doc/book/installing/)

ADD https://get.jenkins.io/war-stable/2.303.1/jenkins.war /root/

WORKDIR /root

EXPOSE 8080

ENTRYPOINT ["java"]

CMD ["-jar", "jenkins.war"]

```
```
vagrant@vagrant:~/jenkins$ docker build -t jenkins_amazon:ver1 -f DF_jen_amazon .
....
Successfully built 2e4151bd9335
Successfully tagged jenkins_amazon:ver1

vagrant@vagrant:~/jenkins$ docker run --name jenkins_amazon -dt jenkins_amazon:ver1
5880d95c877dc78d646170af4a564f4b4807dfa760cb0254dc97f6c406886ad3
```

```
*************************************************************

2021-09-19 09:20:45.459+0000 [id=28]    INFO    jenkins.InitReactorRunner$1#onAttained: Completed initialization
2021-09-19 09:20:45.475+0000 [id=20]    INFO    hudson.WebAppMain$3#run: Jenkins is fully up and running
2021-09-19 09:20:45.949+0000 [id=42]    INFO    h.m.DownloadService$Downloadable#load: Obtained the updated data file for hudson.tasks.Maven.MavenInstaller
2021-09-19 09:20:45.950+0000 [id=42]    INFO    hudson.util.Retrier#start: Performed the action check updates server successfully at the attempt #1
2021-09-19 09:20:45.953+0000 [id=42]    INFO    hudson.model.AsyncPeriodicWork#lambda$doRun$0: Finished Download metadata. 13,960 ms

```
```
FROM ubuntu:latest

RUN apt-get update \
  && apt install -y wget gnupg \
  && apt install -y default-jdk \
  && wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - \
  && sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' \
  && apt-get update \
  && apt-get install -y jenkins

CMD ["/bin/bash"]
```


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
