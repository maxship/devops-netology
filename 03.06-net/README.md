
# Домашнее задание к занятию "3.6. Компьютерные сети, лекция 1"

1. Необязательное задание:
можно посмотреть целый фильм в консоли `telnet towel.blinkenlights.nl` :)

2. Узнайте о том, сколько действительно независимых (не пересекающихся) каналов есть в разделяемой среде WiFi при работе на 2.4 ГГц. Стандарты с полосой 5 ГГц более актуальны, но регламенты на 5 ГГц существенно различаются в разных странах, а так же не раз обновлялись. В качестве дополнительного вопроса вне зачета, попробуйте найти актуальный ответ и на этот вопрос.

Шаг каналов частот в диапазоне 2.4 ГГц, на которых может работать оборудование, составляет 5 МГц в интервале с 2.412 Ггц до 2.484 Ггц (всего 14  каналов), а ширина канала для стандарта 802.11 b/g/n составляет 20 Мгц. 

Это означает, что рабочие частоты оборудования перекрываются, и независимых друг от друга каналов всего 3. Например 1 (2,412 ГГц), 6 (2,437 ГГц) и 11 (2,462 ГГц), частоты которых отличаются более чем на 20 МГц. Так же можно использовать каналы 2, 7, 12 или 3, 8, 13.

![Screenshot_13](https://user-images.githubusercontent.com/72273610/122647572-8ee1a300-d146-11eb-9378-f274a277f357.png)

3. Адрес канального уровня – MAC адрес – это 6 байт, первые 3 из которых называются OUI – Organizationally Unique Identifier или уникальный идентификатор организации. Какому производителю принадлежит MAC `38:f9:d3:55:55:79`?

Соответствие MAC адресов производителям мжно посмотеть, например, здесь: https://uic.io/en/mac/. 

![Screenshot_14](https://user-images.githubusercontent.com/72273610/122884976-7947c580-d360-11eb-8682-653c2dba74f0.png)


4. Каким будет payload TCP сегмента, если Ethernet MTU задан в 9001 байт, размер заголовков IPv4 – 20 байт, а TCP – 32 байта?

```
payload (MSS) = 9001(MTU) - 20(IP) - 32(TCP) = 8949
```

![Screenshot_15](https://user-images.githubusercontent.com/72273610/122891551-6c2dd500-d366-11eb-95a4-88f9cddd05d6.png)


5. Может ли во флагах TCP одновременно быть установлены флаги SYN и FIN при штатном режиме работы сети? Почему да или нет?

Механизм передачи TCP пакетов делится на 3 стадии: последовательно осуществляется инициализация соединения, передача данных и завершение соединения. Установление соединения, в свою очередь, требует выполнения "трестороннего рукопожатия" с использования флагов SYN и ACK. Флаг FIN, соответственно, используется в стадии завершения соединения после выполнения первых двух этапов. Поэтому при штатной работе сети флаги SYN и FIN не могут находиться в одном пакете.

6. `ss -ula sport = :53` на хосте имеет следующий вывод:

```bash
State           Recv-Q          Send-Q                   Local Address:Port                     Peer Address:Port          Process
UNCONN          0               0                        127.0.0.53%lo:domain                        0.0.0.0:*
```

Почему в `State` присутствует только `UNCONN`, и может ли там присутствовать, например, `TIME-WAIT`?

7. Обладая знаниями о том, как штатным образом завершается соединение (FIN от инициатора, FIN-ACK от ответчика, ACK от инициатора), опишите в каких состояниях будет находиться TCP соединение в каждый момент времени на клиенте и на сервере при завершении. Схема переходов состояния соединения вам в этом поможет.

8. TCP порт – 16 битное число. Предположим, 2 находящихся в одной сети хоста устанавливают между собой соединения. Каким будет теоретическое максимальное число соединений, ограниченное только лишь параметрами L4, которое параллельно может установить клиент с одного IP адреса к серверу с одним IP адресом? Сколько соединений сможет обслужить сервер от одного клиента? А если клиентов больше одного?

9. Может ли сложиться ситуация, при которой большое число соединений TCP на хосте находятся в состоянии  `TIME-WAIT`? Если да, то является ли она хорошей или плохой? Подкрепите свой ответ пояснением той или иной оценки.

10. Чем особенно плоха фрагментация UDP относительно фрагментации TCP?

TCP разбивает данные на сегменты, размер которых не превышает размера MTU, то есть фрагментация осуществляется на транспортном уровне. При потере сегмента он переотправляется.

Протокол UDP использует фрагментацию на сетевом уровне. Уровень IP не имеет механизмов типа таймаута и повторной передачи, аналогичных транспортному уровню (TCP). Поэтому, если один из фрагментов датаграммы потерян, переотправить только потерянный фрагмент невозможно - требуется повторноя отправка всей датаграммы. Это ведет к проблемам с производительностью, поэтому IP фрагментацию желательно избегать на уровне приложения.


11. Если бы вы строили систему удаленного сбора логов, то есть систему, в которой несколько хостов отправяют на центральный узел генерируемые приложениями логи (предположим, что логи – текстовая информация), какой протокол транспортного уровня вы выбрали бы и почему? Проверьте ваше предположение самостоятельно, узнав о стандартном протоколе syslog.

Для удаленного сбора логов я бы использовал TCP, поскольку он обеспечивает гарантированную доставку сообщений (для логов это может быть важно).

По факту используется как UDP, так и TCP.

12. Сколько портов TCP находится в состоянии прослушивания на вашей виртуальной машине с Ubuntu, и каким процессам они принадлежат?

```
vagrant@vagrant:~$ ss -t -4 state listening -n | column -t
Recv-Q  Send-Q  Local             Address:Port  Peer  Address:Port  Process
0       4096    127.0.0.53%lo:53  0.0.0.0:*
0       128     0.0.0.0:22        0.0.0.0:*
0       4096    127.0.0.1:8125    0.0.0.0:*
0       4096    0.0.0.0:19999     0.0.0.0:*
0       4096    0.0.0.0:111       0.0.0.0:*

vagrant@vagrant:~$ ss -t -4 state listening | column -t
Recv-Q  Send-Q  Local                 Address:Port  Peer  Address:Port  Process
0       4096    127.0.0.53%lo:domain  0.0.0.0:*
0       128     0.0.0.0:ssh           0.0.0.0:*
0       4096    127.0.0.1:8125        0.0.0.0:*
0       4096    0.0.0.0:19999         0.0.0.0:*
0       4096    0.0.0.0:sunrpc        0.0.0.0:*

vagrant@vagrant:~$ sudo lsof -ni :53,22,8125,19999,111 | grep TCP | grep IPv4
systemd      1            root   35u  IPv4   1798      0t0  TCP *:sunrpc (LISTEN)
rpcbind    544            _rpc    4u  IPv4   1798      0t0  TCP *:sunrpc (LISTEN)
systemd-r  545 systemd-resolve   13u  IPv4  20386      0t0  TCP 127.0.0.53:domain (LISTEN)
netdata    613         netdata    4u  IPv4  22850      0t0  TCP *:19999 (LISTEN)
netdata    613         netdata   21u  IPv4  33706      0t0  TCP 10.0.2.15:19999->10.0.2.2:60600 (ESTABLISHED)
netdata    613         netdata   33u  IPv4  23526      0t0  TCP 127.0.0.1:8125 (LISTEN)
sshd       697            root    3u  IPv4  22889      0t0  TCP *:ssh (LISTEN)
sshd      1391            root    4u  IPv4  30449      0t0  TCP 10.0.2.15:ssh->10.0.2.2:50988 (ESTABLISHED)
sshd      1442         vagrant    4u  IPv4  30449      0t0  TCP 10.0.2.15:ssh->10.0.2.2:50988 (ESTABLISHED)
```

13. Какой ключ нужно добавить в `tcpdump`, чтобы он начал выводить не только заголовки, но и содержимое фреймов в текстовом виде? А в текстовом и шестнадцатиричном?

14. Попробуйте собрать дамп трафика с помощью `tcpdump` на основном интерфейсе вашей виртуальной машины и посмотреть его через tshark или Wireshark (можно ограничить число пакетов `-c 100`). Встретились ли вам какие-то установленные флаги Internet Protocol (не флаги TCP, а флаги IP)? Узнайте, какие флаги бывают. Как на самом деле называется стандарт Ethernet, фреймы которого попали в ваш дамп? Можно ли где-то в дампе увидеть OUI?

```
vagrant@vagrant:~$ sudo tcpdump -c 100 -w ~/tcpdump.pcap
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
100 packets captured
151 packets received by filter
0 packets dropped by kernel

vagrant@vagrant:~$ tshark -r ~/tcpdump.pcap

vagrant@vagrant:~$ tshark -r ~/tcpdump.pcap
    1   0.000000    10.0.2.15 → 10.0.2.2     SSH 90 Server: Encrypted packet (len=36)
    2   0.000185     10.0.2.2 → 10.0.2.15    TCP 60 50988 → 22 [ACK] Seq=1 Ack=37 Win=65535 Len=0
    3   1.082037     10.0.2.2 → 10.0.2.15    HTTP 681 GET /api/v1/alarms?active&_=1624363683093 HTTP/1.1
    4   1.082210    10.0.2.15 → 10.0.2.2     HTTP 592 HTTP/1.1 200 OK  (application/json)
    5   1.082442     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=628 Ack=539 Win=65535 Len=0
    6  11.092939     10.0.2.2 → 10.0.2.15    HTTP 681 GET /api/v1/alarms?active&_=1624363683094 HTTP/1.1
    7  11.093359    10.0.2.15 → 10.0.2.2     HTTP 592 HTTP/1.1 200 OK  (application/json)
    8  11.093579     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=1255 Ack=1077 Win=65535 Len=0
    9  12.420609     10.0.2.2 → 10.0.2.15    HTTP 814 GET /api/v1/data?chart=system.swap&format=array&points=360&group=average&gtime=0&options=absolute%7Cpercentage%7Cjsonwrap%7Cnonzero&after=-360&dimensions=used&_=1624363683095 HTTP/1.1
   10  12.421164    10.0.2.15 → 10.0.2.2     HTTP 711 HTTP/1.1 200 OK  (application/json)
   11  12.421586     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=2015 Ack=1734 Win=65535 Len=0
   12  12.430549     10.0.2.2 → 10.0.2.15    HTTP 797 GET /api/v1/data?chart=system.io&format=array&points=360&group=average&gtime=0&options=absolute%7Cjsonwrap%7Cnonzero&after=-360&dimensions=in&_=1624363683096 HTTP/1.1
   13  12.430858    10.0.2.15 → 10.0.2.2     HTTP 704 HTTP/1.1 200 OK  (application/json)
   14  12.431136     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=2758 Ack=2384 Win=65535 Len=0
   15  12.437256     10.0.2.2 → 10.0.2.15    HTTP 798 GET /api/v1/data?chart=system.io&format=array&points=360&group=average&gtime=0&options=absolute%7Cjsonwrap%7Cnonzero&after=-360&dimensions=out&_=1624363683097 HTTP/1.1
   16  12.437670    10.0.2.15 → 10.0.2.2     HTTP 1368 HTTP/1.1 200 OK  (application/json)
   17  12.440237     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=3502 Ack=3698 Win=65535 Len=0
   18  12.445874     10.0.2.2 → 10.0.2.15    HTTP 784 GET /api/v1/data?chart=system.cpu&format=array&points=360&group=average&gtime=0&options=absolute%7Cjsonwrap%7Cnonzero&after=-360&_=1624363683098 HTTP/1.1
   19  12.446322    10.0.2.15 → 10.0.2.2     HTTP 1050 HTTP/1.1 200 OK  (application/json)
   20  12.446664     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=4232 Ack=4694 Win=65535 Len=0
   21  12.451816     10.0.2.2 → 10.0.2.15    HTTP 804 GET /api/v1/data?chart=system.net&format=array&points=360&group=average&gtime=0&options=absolute%7Cjsonwrap%7Cnonzero&after=-360&dimensions=received&_=1624363683099 HTTP/1.1
   22  12.452158    10.0.2.15 → 10.0.2.2     HTTP 1511 HTTP/1.1 200 OK  (application/json)
   23  12.452513     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=4982 Ack=6151 Win=65535 Len=0
   24  12.458155     10.0.2.2 → 10.0.2.15    HTTP 800 GET /api/v1/data?chart=system.net&format=array&points=360&group=average&gtime=0&options=absolute%7Cjsonwrap%7Cnonzero&after=-360&dimensions=sent&_=1624363683100 HTTP/1.1
   25  12.458547    10.0.2.15 → 10.0.2.2     TCP 1514 HTTP/1.1 200 OK  [TCP segment of a reassembled PDU]
   26  12.458616    10.0.2.15 → 10.0.2.2     HTTP 69 HTTP/1.1 200 OK  (application/json)
   27  12.458803     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=5728 Ack=7626 Win=65535 Len=0
   28  12.465639     10.0.2.2 → 10.0.2.15    HTTP 840 GET /api/v1/data?chart=system.ram&format=array&points=360&group=average&gtime=0&options=absolute%7Cpercentage%7Cjsonwrap%7Cnonzero&after=-360&dimensions=used%7Cbuffers%7Cactive%7Cwired&_=1624363683101 HTTP/1.1
   29  12.466083    10.0.2.15 → 10.0.2.2     HTTP 1251 HTTP/1.1 200 OK  (application/json)
   30  12.466331     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=6514 Ack=8823 Win=65535 Len=0
   31  12.471939     10.0.2.2 → 10.0.2.15    HTTP 802 GET /api/v1/data?chart=system.cpu&format=json&points=123&group=average&gtime=0&options=ms%7Cflip%7Cjsonwrap%7Cnonzero&after=-120&dimensions=iowait&_=1624363683102 HTTP/1.1
   32  12.472247    10.0.2.15 → 10.0.2.2     HTTP 1098 HTTP/1.1 200 OK  (application/json)
   33  12.472454     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=7262 Ack=9867 Win=65535 Len=0
   34  12.478247     10.0.2.2 → 10.0.2.15    HTTP 803 GET /api/v1/data?chart=system.cpu&format=json&points=123&group=average&gtime=0&options=ms%7Cflip%7Cjsonwrap%7Cnonzero&after=-120&dimensions=softirq&_=1624363683103 HTTP/1.1
   35  12.478656    10.0.2.15 → 10.0.2.2     HTTP 1099 HTTP/1.1 200 OK  (application/json)
   36  12.478931     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=8011 Ack=10912 Win=65535 Len=0
   37  12.485117     10.0.2.2 → 10.0.2.15    HTTP 785 GET /api/v1/data?chart=system.load&format=json&points=300&group=average&gtime=0&options=ms%7Cflip%7Cjsonwrap%7Cnonzero&after=-360&_=1624363683104 HTTP/1.1
   38  12.485562    10.0.2.15 → 10.0.2.2     HTTP 1117 HTTP/1.1 200 OK  (application/json)
   39  12.485853     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=8742 Ack=11975 Win=65535 Len=0
   40  12.491686     10.0.2.2 → 10.0.2.15    HTTP 783 GET /api/v1/data?chart=system.io&format=json&points=300&group=average&gtime=0&options=ms%7Cflip%7Cjsonwrap%7Cnonzero&after=-360&_=1624363683105 HTTP/1.1
   41  12.492129    10.0.2.15 → 10.0.2.2     TCP 1514 HTTP/1.1 200 OK  [TCP segment of a reassembled PDU]
   42  12.492195    10.0.2.15 → 10.0.2.2     HTTP 1162 HTTP/1.1 200 OK  (application/json)
   43  12.492354     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=9471 Ack=14543 Win=65535 Len=0
   44  12.498860     10.0.2.2 → 10.0.2.15    HTTP 787 GET /api/v1/data?chart=system.pgpgio&format=json&points=300&group=average&gtime=0&options=ms%7Cflip%7Cjsonwrap%7Cnonzero&after=-360&_=1624363683106 HTTP/1.1
   45  12.499354    10.0.2.15 → 10.0.2.2     TCP 1514 HTTP/1.1 200 OK  [TCP segment of a reassembled PDU]
   46  12.499429    10.0.2.15 → 10.0.2.2     HTTP 1165 HTTP/1.1 200 OK  (application/json)
   47  12.499664     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=10204 Ack=17114 Win=65535 Len=0
   48  12.565378     10.0.2.2 → 10.0.2.15    HTTP 814 GET /api/v1/data?chart=system.swap&format=array&points=360&group=average&gtime=0&options=absolute%7Cpercentage%7Cjsonwrap%7Cnonzero&after=-360&dimensions=used&_=1624363683107 HTTP/1.1
   49  12.565795    10.0.2.15 → 10.0.2.2     HTTP 711 HTTP/1.1 200 OK  (application/json)
   50  12.566223     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=10964 Ack=17771 Win=65535 Len=0
   51  12.574111     10.0.2.2 → 10.0.2.15    HTTP 797 GET /api/v1/data?chart=system.io&format=array&points=360&group=average&gtime=0&options=absolute%7Cjsonwrap%7Cnonzero&after=-360&dimensions=in&_=1624363683108 HTTP/1.1
   52  12.574452    10.0.2.15 → 10.0.2.2     HTTP 704 HTTP/1.1 200 OK  (application/json)
   53  12.574790     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=11707 Ack=18421 Win=65535 Len=0
   54  12.581479     10.0.2.2 → 10.0.2.15    HTTP 798 GET /api/v1/data?chart=system.io&format=array&points=360&group=average&gtime=0&options=absolute%7Cjsonwrap%7Cnonzero&after=-360&dimensions=out&_=1624363683109 HTTP/1.1
   55  12.581942    10.0.2.15 → 10.0.2.2     HTTP 1368 HTTP/1.1 200 OK  (application/json)
   56  12.582192     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=12451 Ack=19735 Win=65535 Len=0
   57  12.587949     10.0.2.2 → 10.0.2.15    HTTP 784 GET /api/v1/data?chart=system.cpu&format=array&points=360&group=average&gtime=0&options=absolute%7Cjsonwrap%7Cnonzero&after=-360&_=1624363683110 HTTP/1.1
   58  12.588402    10.0.2.15 → 10.0.2.2     HTTP 1050 HTTP/1.1 200 OK  (application/json)
   59  12.588686     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=13181 Ack=20731 Win=65535 Len=0
   60  12.593792     10.0.2.2 → 10.0.2.15    HTTP 804 GET /api/v1/data?chart=system.net&format=array&points=360&group=average&gtime=0&options=absolute%7Cjsonwrap%7Cnonzero&after=-360&dimensions=received&_=1624363683111 HTTP/1.1
   61  12.594186    10.0.2.15 → 10.0.2.2     HTTP 1511 HTTP/1.1 200 OK  (application/json)
   62  12.594404     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=13931 Ack=22188 Win=65535 Len=0
   63  12.600860     10.0.2.2 → 10.0.2.15    HTTP 800 GET /api/v1/data?chart=system.net&format=array&points=360&group=average&gtime=0&options=absolute%7Cjsonwrap%7Cnonzero&after=-360&dimensions=sent&_=1624363683112 HTTP/1.1
   64  12.601246    10.0.2.15 → 10.0.2.2     TCP 1514 HTTP/1.1 200 OK  [TCP segment of a reassembled PDU]
   65  12.601312    10.0.2.15 → 10.0.2.2     HTTP 69 HTTP/1.1 200 OK  (application/json)
   66  12.601640     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=14677 Ack=23663 Win=65535 Len=0
   67  12.607148     10.0.2.2 → 10.0.2.15    HTTP 840 GET /api/v1/data?chart=system.ram&format=array&points=360&group=average&gtime=0&options=absolute%7Cpercentage%7Cjsonwrap%7Cnonzero&after=-360&dimensions=used%7Cbuffers%7Cactive%7Cwired&_=1624363683113 HTTP/1.1
   68  12.607527    10.0.2.15 → 10.0.2.2     HTTP 1251 HTTP/1.1 200 OK  (application/json)
   69  12.607760     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=15463 Ack=24860 Win=65535 Len=0
   70  12.613499     10.0.2.2 → 10.0.2.15    HTTP 802 GET /api/v1/data?chart=system.cpu&format=json&points=123&group=average&gtime=0&options=ms%7Cflip%7Cjsonwrap%7Cnonzero&after=-120&dimensions=iowait&_=1624363683114 HTTP/1.1
   71  12.613830    10.0.2.15 → 10.0.2.2     HTTP 1098 HTTP/1.1 200 OK  (application/json)
   72  12.614169     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=16211 Ack=25904 Win=65535 Len=0
   73  12.620026     10.0.2.2 → 10.0.2.15    HTTP 803 GET /api/v1/data?chart=system.cpu&format=json&points=123&group=average&gtime=0&options=ms%7Cflip%7Cjsonwrap%7Cnonzero&after=-120&dimensions=softirq&_=1624363683115 HTTP/1.1
   74  12.620360    10.0.2.15 → 10.0.2.2     HTTP 1099 HTTP/1.1 200 OK  (application/json)
   75  12.620576     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=16960 Ack=26949 Win=65535 Len=0
   76  12.722889     10.0.2.2 → 10.0.2.15    TCP 60 52394 → 19999 [SYN] Seq=0 Win=65535 Len=0 MSS=1460
   77  12.722889     10.0.2.2 → 10.0.2.15    TCP 60 60566 → 19999 [SYN] Seq=0 Win=65535 Len=0 MSS=1460
   78  12.722889     10.0.2.2 → 10.0.2.15    TCP 60 59269 → 19999 [SYN] Seq=0 Win=65535 Len=0 MSS=1460
   79  12.722930    10.0.2.15 → 10.0.2.2     TCP 58 19999 → 52394 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460
   80  12.722983    10.0.2.15 → 10.0.2.2     TCP 58 19999 → 60566 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460
   81  12.723028    10.0.2.15 → 10.0.2.2     TCP 58 19999 → 59269 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460
   82  12.723299     10.0.2.2 → 10.0.2.15    TCP 60 57982 → 19999 [SYN] Seq=0 Win=65535 Len=0 MSS=1460
   83  12.723299     10.0.2.2 → 10.0.2.15    TCP 60 52394 → 19999 [ACK] Seq=1 Ack=1 Win=65535 Len=0
   84  12.723299     10.0.2.2 → 10.0.2.15    TCP 60 63482 → 19999 [SYN] Seq=0 Win=65535 Len=0 MSS=1460
   85  12.723299     10.0.2.2 → 10.0.2.15    TCP 60 60566 → 19999 [ACK] Seq=1 Ack=1 Win=65535 Len=0
   86  12.723299     10.0.2.2 → 10.0.2.15    TCP 60 59269 → 19999 [ACK] Seq=1 Ack=1 Win=65535 Len=0
   87  12.723309    10.0.2.15 → 10.0.2.2     TCP 58 19999 → 57982 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460
   88  12.723424    10.0.2.15 → 10.0.2.2     TCP 58 19999 → 63482 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460
   89  12.723737     10.0.2.2 → 10.0.2.15    TCP 60 57982 → 19999 [ACK] Seq=1 Ack=1 Win=65535 Len=0
   90  12.723737     10.0.2.2 → 10.0.2.15    TCP 60 63482 → 19999 [ACK] Seq=1 Ack=1 Win=65535 Len=0
   91  13.384812     10.0.2.2 → 10.0.2.15    HTTP 784 GET /api/v1/data?chart=system.ram&format=json&points=300&group=average&gtime=0&options=ms%7Cflip%7Cjsonwrap%7Cnonzero&after=-360&_=1624363683116 HTTP/1.1
   92  13.385362    10.0.2.15 → 10.0.2.2     TCP 2974 HTTP/1.1 200 OK  [TCP segment of a reassembled PDU]
   93  13.385640     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=17690 Ack=29869 Win=65535 Len=0
   94  13.385709    10.0.2.15 → 10.0.2.2     HTTP 590 HTTP/1.1 200 OK  (application/json)
   95  13.385868     10.0.2.2 → 10.0.2.15    TCP 60 50813 → 19999 [ACK] Seq=17690 Ack=30405 Win=65535 Len=0
   96  13.511594     10.0.2.2 → 10.0.2.15    HTTP 784 GET /api/v1/data?chart=system.ram&format=json&points=300&group=average&gtime=0&options=ms%7Cflip%7Cjsonwrap%7Cnonzero&after=-360&_=1624363683117 HTTP/1.1
   97  13.511594     10.0.2.2 → 10.0.2.15    HTTP 787 GET /api/v1/data?chart=system.pgpgio&format=json&points=300&group=average&gtime=0&options=ms%7Cflip%7Cjsonwrap%7Cnonzero&after=-360&_=1624363683118 HTTP/1.1
   98  13.511594     10.0.2.2 → 10.0.2.15    HTTP 783 GET /api/v1/data?chart=system.io&format=json&points=300&group=average&gtime=0&options=ms%7Cflip%7Cjsonwrap%7Cnonzero&after=-360&_=1624363683119 HTTP/1.1
   99  13.511633    10.0.2.15 → 10.0.2.2     TCP 54 19999 → 52394 [ACK] Seq=1 Ack=734 Win=65535 Len=0
  100  13.511690    10.0.2.15 → 10.0.2.2     TCP 54 19999 → 60566 [ACK] Seq=1 Ack=730 Win=65535 Len=0

```
