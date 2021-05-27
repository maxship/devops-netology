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



### 7. Выполните команду bash 5>&1. К чему она приведет? Что будет, если вы выполните echo netology > /proc/$$/fd/5?
```bash
vagrant@vagrant:~$ bash 5>&1
echo netology > /proc/$$/fd/5
netology
```
В первой команде создается новый дескриптор 5, который добавляется к стандартному выводу 1 (то есть дублирует stdout).
Вторая команда выводит поток bash с дескриптором 5, он полностью идентичен выводу команды ```echo netology```.
