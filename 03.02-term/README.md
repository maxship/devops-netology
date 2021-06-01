# 3.2. Работа в терминале, лекция 2 (домашнее задание)

### 1. Какого типа команда cd?
```bash
vagrant@vagrant:~$ type cd  
cd is a shell builtin
```
Встроенная команда оболочки. Насколько я понимаю, раз она используется для перемещения по каталогам, то использование ее без оболочки не имеет смысла.

### 2. Какая альтернатива без pipe команде grep <some_string> <some_file> | wc -l?
```bash
vagrant@vagrant:~$ grep cpu /proc/cpuinfo/cpuinfo | grep cpu | wc -l
10
```
То же самое можно сделать без лишней команды wc:
```bash
vagrant@vagrant:~$ grep -c cpu /proc/cpuinfo
10
```

### 3. Какой процесс с PID 1 является родителем для всех процессов в вашей виртуальной машине Ubuntu 20.04?
Родительский процесс - systemd.
```bash
vagrant@vagrant:~$ pstree -p
systemd(1)─┬─VBoxService(758)─┬─{VBoxService}(760)
           │                  ├─{VBoxService}(761)
           │                  ├─{VBoxService}(762)
           │                  ├─{VBoxService}(763)
           │                  ├─{VBoxService}(764)
           │                  ├─{VBoxService}(765)
           │                  ├─{VBoxService}(766)
           │                  └─{VBoxService}(767)
           ├─accounts-daemon(570)─┬─{accounts-daemon}(605)
           │                      └─{accounts-daemon}(692)
           ├─agetty(652)
           ├─atd(641)
           ├─cron(638)
           ├─dbus-daemon(571)
           ├─irqbalance(577)───{irqbalance}(581)
           ├─multipathd(521)─┬─{multipathd}(522)
           │                 ├─{multipathd}(523)
           │                 ├─{multipathd}(524)
           │                 ├─{multipathd}(525)
           │                 ├─{multipathd}(526)
           │                 └─{multipathd}(527)
           ├─networkd-dispat(578)
           ├─polkitd(771)─┬─{polkitd}(774)
           │              └─{polkitd}(776)
           ├─rpcbind(548)
           ├─rsyslogd(579)─┬─{rsyslogd}(633)
           │               ├─{rsyslogd}(634)
           │               └─{rsyslogd}(635)
           ├─sshd(670)───sshd(1050)───sshd(1086)───bash(1087)─┬─man(1153)───pager(1163)
           │                                                  └─pstree(1440)
           ├─systemd(790)───(sd-pam)(793)
           ├─systemd-journal(350)
           ├─systemd-logind(607)
           ├─systemd-network(385)
           ├─systemd-resolve(549)
           └─systemd-udevd(381)
```
### 4. Как будет выглядеть команда, которая перенаправит вывод stderr ls на другую сессию терминала?

Смотрим номер текущего терминала и открываем новое окно:
```bash
vagrant@vagrant:~$ who am i                                                                                      
vagrant  pts/1        2021-05-27 10:51 (:pts/0:S.0)
vagrant@vagrant:~$ screen
```
В новом окне смотрим номер терминала:
```bash
vagrant@vagrant:~$ who am i
vagrant  pts/2        2021-05-27 10:51 (:pts/0:S.1)
```
Переключаемся обратно в терминал pts/1 (Ctrl+A Ctrl+A) и оправляем stderror на терминал pts/2 (для проверки в параметрах ls указана несуществующая директория):
```bash
vagrant@vagrant:~$ ls /not_existing_dir 2> /dev/pts/2
```
Переключаемся на терминал pts/2, проверяем:
```bash
ls: cannot access '/not_existing_dir': No such file or directory
```

### 5. Получится ли одновременно передать команде файл на stdin и вывести ее stdout в другой файл?
Не уверен, возможно, что-то типа такого:  

Создаем файлик с тестовой строкой
```
[max@hi10 ~]$ nano test_stdin_out
```
И проверяем
```
[max@hi10 ~]$ cat <> test_stdin_out 
Test line for input/output
```

### 6. Получится ли вывести находясь в графическом режиме данные из PTY в какой-либо из эмуляторов TTY? Сможете ли вы наблюдать выводимые данные?

Получится. Открываем в графическом режиме, например, Xterm, смотрим номер псевдотерминала:
```
[max@hi10 ~]$ who am i
max      pts/1        2021-05-28 03:33 (:0)
```
Переключаемся на сессию терминала Ctrl+Alt+F2. Смотрим номер эмулятора терминала:
```
[max@hi10 ~]$ who am i
max      tty2         2021-05-28 03:29
```
Возвращаемся обратно Ctrl+Alt+F7 и перенаправляем вывод в эмулятор терминала:
```
[max@hi10 ~]$ who am i
max      pts/1        2021-05-28 03:33 (:0)
[max@hi10 ~]$ echo Hello > /dev/tty2
```
Переключаемся на эмулятор терминала и видим вывод:
```
[max@hi10 ~]$ who am i
max      tty2         2021-05-28 03:29
[max@hi10 ~]$ Hello
```

### 7. Выполните команду bash 5>&1. К чему она приведет? Что будет, если вы выполните echo netology > /proc/$$/fd/5?
```bash
vagrant@vagrant:~$ bash 5>&1
echo netology > /proc/$$/fd/5
netology
```
В первой команде создается новый дескриптор 5, который добавляется к стандартному выводу 1 (то есть дублирует stdout).
Вторая команда выводит поток bash с дескриптором 5, он полностью идентичен выводу команды ```echo netology```.

### 8. Получится ли в качестве входного потока для pipe использовать только stderr команды, не потеряв при этом отображение stdout на pty?

### 9. Что выведет команда cat /proc/$$/environ? Как еще можно получить аналогичный по содержанию вывод?
Содержит переменные окружения, заданные на момент запуска процесса. Выводит данные без разделителей. Чтобы вывести то же самое построчно, можно ввести:
```
vagrant@vagrant:~$ cat /proc/$$/environ | tr '\000' '\n'
USER=vagrant
LOGNAME=vagrant
HOME=/home/vagrant
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
SHELL=/bin/bash
TERM=xterm-256color
XDG_SESSION_ID=4
XDG_RUNTIME_DIR=/run/user/1000
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
XDG_SESSION_TYPE=tty
XDG_SESSION_CLASS=user
MOTD_SHOWN=pam
LANG=en_US.UTF-8
LANGUAGE=en_US:
SSH_CLIENT=10.0.2.2 53575 22
SSH_CONNECTION=10.0.2.2 53575 10.0.2.15 22
SSH_TTY=/dev/pts/1
```

Эти же переменные есть и в выводе команды ```$ env```

### 10. Используя man, опишите что доступно по адресам /proc/[PID]/cmdline, /proc/[PID]/exe

В файле /proc/[PID]/cmdline содержится командная строка, которой был запущен процесс. Если это процесс зомби, то файл будет пустым (line 226).  
В файле /proc/[PID]/exe содержится символьная ссылка на исполняемую команду              
           
### 11. Узнайте, какую наиболее старшую версию набора инструкций SSE поддерживает ваш процессор с помощью /proc/cpuinfo

SSE 4.2
```
vagrant@vagrant:~$ grep -i SSE /proc/cpuinfo
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx fxsr_opt rdtscp lm constant_tsc rep_good nopl nonstop_tsc cpuid extd_apicid tsc_known_freq pni ssse3 sse4_1 sse4_2 hypervisor lahf_lm cmp_legacy cr8_legacy 3dnowprefetch ssbd vmmcall fsgsbase arat
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx fxsr_opt rdtscp lm constant_tsc rep_good nopl nonstop_tsc cpuid extd_apicid tsc_known_freq pni ssse3 sse4_1 sse4_2 hypervisor lahf_lm cmp_legacy cr8_legacy 3dnowprefetch ssbd vmmcall fsgsbase arat
```
           
### 12. При открытии нового окна терминала и vagrant ssh создается новая сессия и выделяется pty. Это можно подтвердить командой tty, которая упоминалась в лекции 3.2. Однако:
```
vagrant@netology1:~$ ssh localhost 'tty'
not a tty
```           
### Почитайте, почему так происходит, и как изменить поведение.

Возможно, команда не работает, т.к. запускается из псевдотерминала, а не из графического интерфейса. Если прописать опцию -t, указывающую на псевдотерминал, то получается так:
```
vagrant@vagrant:~$ ssh -t localhost 'tty'
vagrant@localhost's password:
/dev/pts/2
Connection to localhost closed.
```

### 13. Бывает, что есть необходимость переместить запущенный процесс из одной сессии в другую. Попробуйте сделать это, воспользовавшись reptyr. Например, так можно перенести в screen процесс, который вы запустили по ошибке в обычной SSH-сессии.

### 14. sudo echo string > /root/new_file не даст выполнить перенаправление под обычным пользователем, так как перенаправлением занимается процесс shell'а, который запущен без sudo под вашим пользователем. Для решения данной проблемы можно использовать конструкцию echo string | sudo tee /root/new_file. Узнайте что делает команда tee и почему в отличие от sudo echo команда с sudo tee будет работать.
