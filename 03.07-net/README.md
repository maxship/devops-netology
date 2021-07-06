# Домашнее задание к занятию "3.7. Компьютерные сети, лекция 2"

1. На лекции мы обсудили, что манипулировать размером окна необходимо для эффективного наполнения приемного буфера участников TCP сессии (Flow Control). Подобная проблема в полной мере возникает в сетях с высоким RTT. Например, если вы захотите передать 500 Гб бэкап из региона Юга-Восточной Азии на Восточное побережье США. [Здесь](https://www.cloudping.co/grid) вы можете увидеть и 200 и 400 мс вполне реального RTT. Подсчитайте, какого размера нужно окно TCP чтобы наполнить 1 Гбит/с канал при 300 мс RTT (берем простую ситуацию без потери пакетов). Можно воспользоваться готовым [калькулятором](https://www.switch.ch/network/tools/tcp_throughput/). Ознакомиться с [формулами](https://en.wikipedia.org/wiki/TCP_tuning), по которым работает калькулятор можно, например, на Wiki.

![Screenshot_21](https://user-images.githubusercontent.com/72273610/123547091-32ebcf80-d781-11eb-8632-f298e9bbee8b.png)


![Screenshot_20](https://user-images.githubusercontent.com/72273610/123546189-69bfe680-d77d-11eb-9c6e-cecdf737e3d3.png)


2. Во сколько раз упадет пропускная способность канала, если будет 1% потерь пакетов при передаче?

Пропускная способность канала расчитывается по формуле:

![Screenshot_17](https://user-images.githubusercontent.com/72273610/123207491-46780b80-d4df-11eb-952b-5ae4df6048eb.png)

Воспользумемся калькулятором из первого вопроса.
В первом случае возьмем потери в 0,000001 %. Пропускная способность составит 1460 Мбит/с.

![Screenshot_18](https://user-images.githubusercontent.com/72273610/123210552-f8193b80-d4e3-11eb-984d-162ef683630f.png)


В случае с потерями в 1 %, пропускная способность упадет в 1000 раз:

![Screenshot_19](https://user-images.githubusercontent.com/72273610/123210654-1f700880-d4e4-11eb-9e98-c1693bf3080d.png)


3. Какая  максимальная реальная скорость передачи данных достижима при линке 100 Мбит/с? Вопрос про TCP payload, то есть цифры, которые вы реально увидите в операционной системе в тестах или в браузере при скачивании файлов. Повлияет ли размер фрейма на это?

Максимальная реальная скорость TCP соединения даже в случае отсутствия потерь всегда меньше максимальной скорости канала, т.к. помимо полезных данных, каждый фрейм несет внутри заголовки всех уровней (TCP, IP, Ethernet)+ обязательное пространство между фреймами IFG + преамбулу + разделитель фреймов. 

Максимальная полезная нагрузка фрейма Ethernet равна 1500 байт. Размер заголовков известен.
Тогда максимальная ральная скорость равна:

`Max TCP Payload = (MTU–TCP–IP) / (MTU+Ethernet+IFG) = (1500–40) / (1500+26+12) = 94.9 %`

То есть для канала 100 Мбит/с максимальная ральная скорость TCP соединения будет составлять 94,9 Мбит/с.  
Так же из формулы видно, что при уменьшении размера фрейма реальная скорость будет также уменьшаться, т.к. доля служебной информации увеличивается по отношению к полезной.


4. Что на самом деле происходит, когда вы открываете сайт? :)
На прошлой лекции был приведен сокращенный вариант ответа на этот вопрос. Теперь вы знаете намного больше, в частности про IP адресацию, DNS и т.д.
Опишите максимально подробно насколько вы это можете сделать, что происходит, когда вы делаете запрос `curl -I http://netology.ru` с вашей рабочей станции. Предположим, что arp кеш очищен, в локальном DNS нет закешированных записей.

Чистим кэш
```
vagrant@vagrant:~$ ip neigh show
10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 STALE
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
vagrant@vagrant:~$ sudo ip neigh del 10.0.2.2 dev eth0
vagrant@vagrant:~$ sudo ip neigh del 10.0.2.3 dev eth0
vagrant@vagrant:~$ sudo systemd-resolve --flush-caches
```
Запускаем мониторинг
```
vagrant@vagrant:~$ sudo tcpdump -i eth0 -v | grep -v 'vagrant.ssh' >> tcpdump1
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
79 packets captured
81 packets received by filter
0 packets dropped by kernel
```

Параллельно открываем сайт
```
vagrant@vagrant:~$ sudo strace -e network curl -I http://netology.ru
socket(AF_INET6, SOCK_DGRAM, IPPROTO_IP) = 3
socketpair(AF_UNIX, SOCK_STREAM, 0, [3, 4]) = 0
socketpair(AF_UNIX, SOCK_STREAM, 0, [5, 6]) = 0
socket(AF_INET, SOCK_STREAM, IPPROTO_TCP) = 5
setsockopt(5, SOL_TCP, TCP_NODELAY, [1], 4) = 0
setsockopt(5, SOL_SOCKET, SO_KEEPALIVE, [1], 4) = 0
setsockopt(5, SOL_TCP, TCP_KEEPIDLE, [60], 4) = 0
setsockopt(5, SOL_TCP, TCP_KEEPINTVL, [60], 4) = 0
connect(5, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("172.67.43.83")}, 16) = -1 EINPROGRESS (Operation now in progress)
getsockopt(5, SOL_SOCKET, SO_ERROR, [0], [4]) = 0
getpeername(5, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("172.67.43.83")}, [128->16]) = 0
getsockname(5, {sa_family=AF_INET, sin_port=htons(60152), sin_addr=inet_addr("10.0.2.15")}, [128->16]) = 0
sendto(5, "HEAD / HTTP/1.1\r\nHost: netology."..., 76, MSG_NOSIGNAL, NULL, 0) = 76
recvfrom(5, "HTTP/1.1 301 Moved Permanently\r\n"..., 102400, 0, NULL, NULL) = 397
HTTP/1.1 301 Moved Permanently
Date: Tue, 06 Jul 2021 18:54:17 GMT
Connection: keep-alive
Cache-Control: max-age=3600
Expires: Tue, 06 Jul 2021 19:54:17 GMT
Location: https://netology.ru/
cf-request-id: 0b1ec4d7b300002de4392df000000001
Server: cloudflare
CF-RAY: 66ab0a6c5cc42de4-DME
alt-svc: h3-27=":443"; ma=86400, h3-28=":443"; ma=86400, h3-29=":443"; ma=86400, h3=":443"; ma=86400

+++ exited with 0 +++

```
Смотрим вывод.

```
    GNU nano 4.8                                           tcpdump1                                                     
18:54:13.135822 IP (tos 0x10, ttl 64, id 60102, offset 0, flags [DF], proto TCP (6), length 148)
18:54:13.136479 IP (tos 0x0, ttl 64, id 10575, offset 0, flags [none], proto TCP (6), length 40)
18:54:14.131155 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.0.2.3 tell vagrant, length 28
18:54:14.132754 ARP, Ethernet (len 6), IPv4 (len 4), Reply 10.0.2.3 is-at 52:54:00:12:35:03 (oui Unknown), length 46
18:54:14.132810 IP (tos 0x0, ttl 64, id 4786, offset 0, flags [DF], proto UDP (17), length 67)
    vagrant.36812 > 10.0.2.3.domain: 56325+ PTR? 2.2.0.10.in-addr.arpa. (39)
18:54:14.299110 IP (tos 0x0, ttl 64, id 10576, offset 0, flags [none], proto UDP (17), length 117)
    10.0.2.3.domain > vagrant.36812: 56325 NXDomain* 0/1/0 (89)
18:54:14.304232 IP (tos 0x0, ttl 64, id 4804, offset 0, flags [DF], proto UDP (17), length 68)
    vagrant.44221 > 10.0.2.3.domain: 36900+ PTR? 15.2.0.10.in-addr.arpa. (40)
18:54:14.327183 IP (tos 0x0, ttl 64, id 10577, offset 0, flags [none], proto UDP (17), length 118)
    10.0.2.3.domain > vagrant.44221: 36900 NXDomain* 0/1/0 (90)
18:54:14.334887 IP (tos 0x0, ttl 64, id 10578, offset 0, flags [none], proto TCP (6), length 76)
18:54:14.379555 IP (tos 0x10, ttl 64, id 60103, offset 0, flags [DF], proto TCP (6), length 40)
18:54:14.575602 IP (tos 0x0, ttl 64, id 10579, offset 0, flags [none], proto TCP (6), length 76)
18:54:14.575686 IP (tos 0x10, ttl 64, id 60104, offset 0, flags [DF], proto TCP (6), length 40)
18:54:14.580277 IP (tos 0x10, ttl 64, id 60105, offset 0, flags [DF], proto TCP (6), length 92)
18:54:14.582127 IP (tos 0x0, ttl 64, id 10580, offset 0, flags [none], proto TCP (6), length 40)
18:54:14.583048 IP (tos 0x10, ttl 64, id 60106, offset 0, flags [DF], proto TCP (6), length 172)
18:54:14.585227 IP (tos 0x0, ttl 64, id 10581, offset 0, flags [none], proto TCP (6), length 40)
18:54:15.150979 IP (tos 0x0, ttl 64, id 4994, offset 0, flags [DF], proto UDP (17), length 67)
    vagrant.43752 > 10.0.2.3.domain: 61700+ PTR? 3.2.0.10.in-addr.arpa. (39)
18:54:15.180827 IP (tos 0x0, ttl 64, id 10582, offset 0, flags [none], proto UDP (17), length 117)
    10.0.2.3.domain > vagrant.43752: 61700 NXDomain* 0/1/0 (89)
18:54:16.527939 IP (tos 0x0, ttl 64, id 10583, offset 0, flags [none], proto TCP (6), length 76)
18:54:16.528079 IP (tos 0x10, ttl 64, id 60107, offset 0, flags [DF], proto TCP (6), length 40)
18:54:16.537214 IP (tos 0x10, ttl 64, id 60108, offset 0, flags [DF], proto TCP (6), length 76)
18:54:16.539424 IP (tos 0x0, ttl 64, id 10584, offset 0, flags [none], proto TCP (6), length 40)
18:54:16.771350 IP (tos 0x10, ttl 64, id 60109, offset 0, flags [DF], proto TCP (6), length 76)
18:54:16.772935 IP (tos 0x0, ttl 64, id 10585, offset 0, flags [none], proto TCP (6), length 40)
18:54:16.773799 IP (tos 0x10, ttl 64, id 60110, offset 0, flags [DF], proto TCP (6), length 76)
18:54:16.775129 IP (tos 0x10, ttl 64, id 60111, offset 0, flags [DF], proto TCP (6), length 76)
18:54:16.775383 IP (tos 0x0, ttl 64, id 10586, offset 0, flags [none], proto TCP (6), length 40)
18:54:16.776417 IP (tos 0x0, ttl 64, id 10587, offset 0, flags [none], proto TCP (6), length 40)
18:54:16.779784 IP (tos 0x0, ttl 64, id 5072, offset 0, flags [DF], proto UDP (17), length 57)
    vagrant.57271 > 10.0.2.3.domain: 31668+ A? netology.ru. (29)
18:54:16.780231 IP (tos 0x0, ttl 64, id 5073, offset 0, flags [DF], proto UDP (17), length 57)
    vagrant.40496 > 10.0.2.3.domain: 41498+ AAAA? netology.ru. (29)
18:54:16.926383 IP (tos 0x0, ttl 64, id 10588, offset 0, flags [none], proto UDP (17), length 57)
    10.0.2.3.domain > vagrant.40496: 41498 0/0/0 (29)
18:54:16.926384 IP (tos 0x0, ttl 64, id 10589, offset 0, flags [none], proto UDP (17), length 105)
    10.0.2.3.domain > vagrant.57271: 31668 3/0/0 netology.ru. A 172.67.43.83, netology.ru. A 104.22.48.171, netology.>
18:54:16.935188 IP (tos 0x10, ttl 64, id 60112, offset 0, flags [DF], proto TCP (6), length 76)
18:54:16.936863 IP (tos 0x0, ttl 64, id 10590, offset 0, flags [none], proto TCP (6), length 40)
18:54:16.937016 IP (tos 0x0, ttl 64, id 27890, offset 0, flags [DF], proto TCP (6), length 60)
    vagrant.60152 > 172.67.43.83.http: Flags [S], cksum 0xe3d3 (incorrect -> 0x6d2c), seq 3201531502, win 64240, opti>
18:54:16.939428 IP (tos 0x10, ttl 64, id 60113, offset 0, flags [DF], proto TCP (6), length 84)
18:54:16.941009 IP (tos 0x0, ttl 64, id 10591, offset 0, flags [none], proto TCP (6), length 40)
18:54:16.989812 IP (tos 0x0, ttl 64, id 10592, offset 0, flags [none], proto TCP (6), length 44)
    172.67.43.83.http > vagrant.60152: Flags [S.], cksum 0x59d0 (correct), seq 638848001, ack 3201531503, win 65535, >
18:54:16.990029 IP (tos 0x0, ttl 64, id 27891, offset 0, flags [DF], proto TCP (6), length 40)
    vagrant.60152 > 172.67.43.83.http: Flags [.], cksum 0xe3bf (incorrect -> 0x769c), ack 1, win 64240, length 0
18:54:16.539424 IP (tos 0x0, ttl 64, id 10584, offset 0, flags [none], proto TCP (6), length 40)
18:54:16.771350 IP (tos 0x10, ttl 64, id 60109, offset 0, flags [DF], proto TCP (6), length 76)
18:54:16.772935 IP (tos 0x0, ttl 64, id 10585, offset 0, flags [none], proto TCP (6), length 40)
18:54:16.773799 IP (tos 0x10, ttl 64, id 60110, offset 0, flags [DF], proto TCP (6), length 76)
18:54:16.775129 IP (tos 0x10, ttl 64, id 60111, offset 0, flags [DF], proto TCP (6), length 76)
18:54:16.775383 IP (tos 0x0, ttl 64, id 10586, offset 0, flags [none], proto TCP (6), length 40)
18:54:16.776417 IP (tos 0x0, ttl 64, id 10587, offset 0, flags [none], proto TCP (6), length 40)
18:54:16.779784 IP (tos 0x0, ttl 64, id 5072, offset 0, flags [DF], proto UDP (17), length 57)
    vagrant.57271 > 10.0.2.3.domain: 31668+ A? netology.ru. (29)
18:54:16.780231 IP (tos 0x0, ttl 64, id 5073, offset 0, flags [DF], proto UDP (17), length 57)
    vagrant.40496 > 10.0.2.3.domain: 41498+ AAAA? netology.ru. (29)
18:54:16.926383 IP (tos 0x0, ttl 64, id 10588, offset 0, flags [none], proto UDP (17), length 57)
    10.0.2.3.domain > vagrant.40496: 41498 0/0/0 (29)
18:54:16.926384 IP (tos 0x0, ttl 64, id 10589, offset 0, flags [none], proto UDP (17), length 105)
    10.0.2.3.domain > vagrant.57271: 31668 3/0/0 netology.ru. A 172.67.43.83, netology.ru. A 104.22.48.171, netology.>
18:54:16.935188 IP (tos 0x10, ttl 64, id 60112, offset 0, flags [DF], proto TCP (6), length 76)
18:54:16.936863 IP (tos 0x0, ttl 64, id 10590, offset 0, flags [none], proto TCP (6), length 40)
18:54:16.937016 IP (tos 0x0, ttl 64, id 27890, offset 0, flags [DF], proto TCP (6), length 60)
    vagrant.60152 > 172.67.43.83.http: Flags [S], cksum 0xe3d3 (incorrect -> 0x6d2c), seq 3201531502, win 64240, opti>
18:54:16.939428 IP (tos 0x10, ttl 64, id 60113, offset 0, flags [DF], proto TCP (6), length 84)
18:54:16.941009 IP (tos 0x0, ttl 64, id 10591, offset 0, flags [none], proto TCP (6), length 40)
18:54:16.989812 IP (tos 0x0, ttl 64, id 10592, offset 0, flags [none], proto TCP (6), length 44)
    172.67.43.83.http > vagrant.60152: Flags [S.], cksum 0x59d0 (correct), seq 638848001, ack 3201531503, win 65535, >
18:54:16.990029 IP (tos 0x0, ttl 64, id 27891, offset 0, flags [DF], proto TCP (6), length 40)
    vagrant.60152 > 172.67.43.83.http: Flags [.], cksum 0xe3bf (incorrect -> 0x769c), ack 1, win 64240, length 0
18:54:16.994770 IP (tos 0x0, ttl 64, id 27892, offset 0, flags [DF], proto TCP (6), length 116)
    vagrant.60152 > 172.67.43.83.http: Flags [P.], cksum 0xe40b (incorrect -> 0x15cb), seq 1:77, ack 1, win 64240, le>
        HEAD / HTTP/1.1
        Host: netology.ru
        User-Agent: curl/7.68.0
        Accept: */*

18:54:16.996188 IP (tos 0x10, ttl 64, id 60114, offset 0, flags [DF], proto TCP (6), length 84)
18:54:16.997159 IP (tos 0x0, ttl 64, id 10593, offset 0, flags [none], proto TCP (6), length 40)
    172.67.43.83.http > vagrant.60152: Flags [.], cksum 0x7141 (correct), ack 77, win 65535, length 0
18:54:16.998068 IP (tos 0x0, ttl 64, id 10594, offset 0, flags [none], proto TCP (6), length 40)
18:54:16.998502 IP (tos 0x10, ttl 64, id 60115, offset 0, flags [DF], proto TCP (6), length 76)
18:54:17.001077 IP (tos 0x0, ttl 64, id 10595, offset 0, flags [none], proto TCP (6), length 40)
18:54:17.057323 IP (tos 0x0, ttl 64, id 10596, offset 0, flags [none], proto TCP (6), length 437)
    172.67.43.83.http > vagrant.60152: Flags [P.], cksum 0x2fd1 (correct), seq 1:398, ack 77, win 65535, length 397: >
        HTTP/1.1 301 Moved Permanently
        Date: Tue, 06 Jul 2021 18:54:17 GMT
        Connection: keep-alive
        Cache-Control: max-age=3600
        Expires: Tue, 06 Jul 2021 19:54:17 GMT
        Location: https://netology.ru/
        cf-request-id: 0b1ec4d7b300002de4392df000000001
        Server: cloudflare
        CF-RAY: 66ab0a6c5cc42de4-DME
        alt-svc: h3-27=":443"; ma=86400, h3-28=":443"; ma=86400, h3-29=":443"; ma=86400, h3=":443"; ma=86400
18:54:17.057443 IP (tos 0x0, ttl 64, id 27893, offset 0, flags [DF], proto TCP (6), length 40)
    vagrant.60152 > 172.67.43.83.http: Flags [.], cksum 0xe3bf (incorrect -> 0x7650), ack 398, win 63843, length 0
18:54:17.061120 IP (tos 0x10, ttl 64, id 60116, offset 0, flags [DF], proto TCP (6), length 76)
18:54:17.063182 IP (tos 0x0, ttl 64, id 10597, offset 0, flags [none], proto TCP (6), length 40)
```
Из этого вывода видны следующие этапы:  

 - Определение DNS. Запись DNS локально не закэширована, и DNS-сервер находится в другой подсети, поэтому ARP-запрос отправляется на IP-адрес шлюза по умолчанию. 
 - Отправляется запрос на сетевые DNS сервера, в результате получен ответ с IP адресом netology.ru.
 - Создается сокет `socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)`, формируется IP пакет.
 - Устанавливается TCP соединение (флаги `[S], [.]`)
 - По протоколу http отправляется запрос на сервер с методом `HEAD`.
 - В ответ сервер отправляет код 301.


5. Сколько и каких итеративных запросов будет сделано при резолве домена `www.google.co.uk`?

 - Первый запрос - поиск `.`
```
[max@hi10 ~]$ dig +trace www.google.co.uk

; <<>> DiG 9.16.18 <<>> +trace www.google.co.uk
;; global options: +cmd
.....
.			443	IN	NS	c.root-servers.net.
.			443	IN	NS	i.root-servers.net.
.			443	IN	NS	a.root-servers.net.
.....
;; Received 239 bytes from 192.168.43.1#53(192.168.43.1) in 83 ms
```
 - Далее поиск зоны верхнего уровня `uk.` 
```
....
uk.			172800	IN	NS	dns2.nic.uk.
uk.			172800	IN	NS	nsb.nic.uk.
uk.			172800	IN	NS	dns4.nic.uk.
....
;; Received 832 bytes from 192.36.148.17#53(i.root-servers.net) in 56 ms
```
 - Поиск `google.co.uk.`
```
google.co.uk.		172800	IN	NS	ns1.google.com.
google.co.uk.		172800	IN	NS	ns2.google.com.
google.co.uk.		172800	IN	NS	ns3.google.com.
google.co.uk.		172800	IN	NS	ns4.google.com.
....
;; Received 650 bytes from 43.230.48.1#53(dns4.nic.uk) in 76 ms
```
 - Поиск `www.google.co.uk.`
```
www.google.co.uk.	300	IN	A	64.233.162.94
;; Received 61 bytes from 216.239.36.10#53(ns3.google.com) in 59 ms
```

6. Сколько доступно для назначения хостам адресов в подсети `/25`? А в подсети с маской `255.248.0.0`. Постарайтесь потренироваться в ручных вычислениях чтобы немного набить руку, не пользоваться калькулятором сразу.

Подсеть с маской `/25`. 
Количество бит хостовой части `32-25=7`. Количество адресов в подсети `2^7=128`. Из них один адрес подсети, один бродкастный и один адрес шлюза по умолчанию, соответственно для хостов доступно 125 адресов.

Подсеть с маской `255.248.0.0`.  
Переводим в двоичную систему: `255.248.0.0 -> 11111111.11111000.00000000.00000000`. Хостовой части соответствует 19 бит, следовательно по CIDR количество адресов `2^19=524288`, Для назначения хостам доступно 524285 адресов.


7. В какой подсети больше адресов, в `/23` или `/24`?

По логике, чем меньше значение маски подсети, тем больше в ней количество адресов.

Проверим:  

В подсети с маской `/23` количество бит хостовой части `32-23=9`. Следовательно, количество адресов в подсети `2^9=512`.  
В подсети с маской `/24` количество адресов в подсети `2^8=256`.  

8. Получится ли разделить диапазон `10.0.0.0/8` на 128 подсетей по 131070 адресов в каждой? Какая маска будет у таких подсетей?

В двоичной системе маска подсети этого диапазона выглядик как `11111111.00000000.00000000.00000000`. Хостовой части соответствует 24 бита, и `2^24=16777216` адресов. `16777216/128=131072`. Вычитаем из этого числа 2 (адрес подсети и бродкаст-адрес) и получаем требуемые 131070 хостов в каждой подсети (включая адрес шлюза по умолчанию).

Найдем маску подсети. Переведем количество хостов в подсети в бинарный вид: `131070 -> 1 1111 1111 1111 1110` всего 17 бит.  
Проверим: `2^17=131072`, что больше чем `131070` как раз на 2 зарезервированных адреса (адрес подсети + широковещательный).  
Исходя из этого на сеть остаются `32 - 17 = 15` бит: `11111111.11111110.00000000.00000000` или `/15`.  
В десятичном выражении получится маска `255.254.0.0`.


