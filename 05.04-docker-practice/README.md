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

```dockerfile
FROM node:latest

COPY nodejs-demo /usr/local/bin

RUN cd /usr/local/bin && npm install

EXPOSE 3000

WORKDIR /usr/local/bin

ENTRYPOINT ["bash"]

CMD npm start

FROM node:latest

COPY nodejs-demo /usr/local/bin

RUN cd /usr/local/bin/ && npm install

EXPOSE 3000

ENTRYPOINT ["/bin/bash"]

CMD [ "npm start"]
```

```
vagrant@vagrant:~/nodejs$ docker build -t node_npm:v1 -f DF_nodejs_npm .
...
Successfully built 86f2a77ecac0
Successfully tagged node_npm:v1
```
```

```
