# 3.3. Операционные системы, лекция 1

### 1. Какой системный вызов делает команда cd? В прошлом ДЗ мы выяснили, что cd не является самостоятельной программой, это shell builtin, поэтому запустить strace непосредственно на cd не получится. Тем не менее, вы можете запустить strace на /bin/bash -c 'cd /tmp'. В этом случае вы увидите полный список системных вызовов, которые делает сам bash при старте. Вам нужно найти тот единственный, который относится именно к cd.

```chdir("/tmp")```

### 2. Попробуйте использовать команду file на объекты разных типов на файловой системе. Например:
```
vagrant@netology1:~$ file /dev/tty
/dev/tty: character special (5/0)
vagrant@netology1:~$ file /dev/sda
/dev/sda: block special (8/0)
vagrant@netology1:~$ file /bin/bash
/bin/bash: ELF 64-bit LSB shared object, x86-64
```
### Используя strace выясните, где находится база данных file на основании которой она делает свои догадки.

```openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3```

### 3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

Делаем файл, куда постоянно дописыается вывод команды топ.
```
vagrant@vagrant:~$ tty
/dev/pts/0
vagrant@vagrant:~$ top | tee -a logfile
```
Проверяем - размер действительно увеличивается со временем.
```
vagrant@vagrant:~$ tty
/dev/pts/1
vagrant@vagrant:~$ ll
total 14284
-rw-rw-r-- 1 vagrant vagrant  230912 Jun  4 05:59 logfile

vagrant@vagrant:~$ ll
total 14336
-rw-rw-r-- 1 vagrant vagrant  285910 Jun  4 06:00 logfile
```
Смотрим нужную инфу по процессу::
```
vagrant@vagrant:~$ ps aux | grep tee
vagrant     1313  0.0  0.0   8088   528 pts/0    S+   06:15   0:00 tee -a logfile
vagrant     1315  0.0  0.0   8900   736 pts/1    S+   06:15   0:00 grep --color=auto tee

vagrant@vagrant:~$ lsof -p 1313 | grep logfile
tee     1313 vagrant    3w   REG  253,0   115588 2883616 /home/vagrant/logfile
```
Удаляем файл.
```
vagrant@vagrant:~$ rm logfile
vagrant@vagrant:~$ cat logfile
cat: logfile: No such file or directory
```
Смотрим содержимое удаленного файла
```
vagrant@vagrant:~$ lsof -p 1313 | grep logfile
tee     1313 vagrant    3w   REG  253,0   260578 2883616 /home/vagrant/logfile (deleted)

vagrant@vagrant:~$ cat /proc/1313/fd/3
top - 06:19:07 up  1:05,  2 users,  load average: 0.02, 0.01, 0.00
Tasks: 103 total,   1 running,  99 sleeping,   3 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :   1987.6 total,   1476.1 free,     98.0 used,    413.5 buff/cache
MiB Swap:    980.0 total,    980.0 free,      0.0 used.   1732.9 avail Mem
......
```
Обнуляем содержимое файлового дескриптора.
```
cat /dev/null > /proc/1313/fd/3
```


### 4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
Зомби-процесс не потребляет ресурсов, просто висит в таблице процессов с выходным статусом для родительского процесса.

### 5. В iovisor BCC есть утилита opensnoop:
```
root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
/usr/sbin/opensnoop-bpfcc
```
### На какие файлы вы увидели вызовы группы open за первую секунду работы утилиты? Воспользуйтесь пакетом bpfcc-tools для Ubuntu 20.04. Дополнительные сведения по установке.
Не совсем разобрался как запускать эту утилиту, почему-то синтаксис из ридми не работает.
```
vagrant@vagrant:/$ opensnoop
-bash: opensnoop: command not found

vagrant@vagrant:/usr/sbin$ sudo opensnoop-bpfcc -T
TIME(s)       PID    COMM               FD ERR PATH
0.000000000   579    irqbalance          6   0 /proc/interrupts
0.000259000   579    irqbalance          6   0 /proc/stat
0.000443000   579    irqbalance          6   0 /proc/irq/20/smp_affinity
0.000610000   579    irqbalance          6   0 /proc/irq/0/smp_affinity
0.000779000   579    irqbalance          6   0 /proc/irq/1/smp_affinity
0.000946000   579    irqbalance          6   0 /proc/irq/8/smp_affinity
0.001114000   579    irqbalance          6   0 /proc/irq/12/smp_affinity
0.001287000   579    irqbalance          6   0 /proc/irq/14/smp_affinity
0.001457000   579    irqbalance          6   0 /proc/irq/15/smp_affinity
```


### 6. Какой системный вызов использует uname -a? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в /proc, где можно узнать версию ядра и релиз ОС.

```uname()```

 Part of the utsname information is also accessible via /proc/sys/kernel/{ostype,  hostname,  osrelease,  version,  domain‐
 name} (man 2 uname: line 55).

### 7. Чем отличается последовательность команд через ; и через && в bash? Например:
```
root@netology1:~# test -d /tmp/some_dir; echo Hi
Hi
root@netology1:~# test -d /tmp/some_dir && echo Hi
root@netology1:~#
```
При использовании ```;``` команды выполняются последовательно, независимо от результата.  
В случае с ```&&``` команда ```echo Hi``` будет выполнена только если выполенние ```test -d``` вернет 0. 

### Есть ли смысл использовать в bash &&, если применить set -e?
```set -e``` завершает работу, если команда выдает ненулевой статус вывода. То есть в примере, в случае если /tmp/some_dir не является директорией, использование ```set -e``` вторая команда не будет выполнена.  
Но если команда является частью цикла, while или until, то работа не будет завершена (man bash: line 3914). Поэтому использование ```&&``` (логический оператор "И") имеет смысл.

### 8. Из каких опций состоит режим bash set -euxo pipefail и почему его хорошо было бы использовать в сценариях?

**-e** завершает работу, если команда выдает ненулевой статус вывода.  
**-u** завершение работы с ненулевым статусом вывода при подстановке неустановленной переменной.  
**-x** после подстановок в каждой команде выдается значение переменной $PS4.  
**-o pipefail** возвращает в качестве зачения пайплайна значение последней команды (самой правой по ходу выполнения) с ненулевым статусом выхода.  

Насколько я понял, использование этих параметов позволяет быстро находить место возникновения ошибок при выполнении пайплайна.


### 9. Используя -o stat для ps, определите, какой наиболее часто встречающийся статус у процессов в системе. В man ps ознакомьтесь (/PROCESS STATE CODES) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).

Наиболее часто встречается S - Interruptible sleep (неактивен)
```
vagrant@vagrant:~$ ps -axo stat | grep -c S
55
```
И I - Idle kernel thread
```
vagrant@vagrant:~$ ps -axo stat | grep -c I
46
```
Дополнительные символы:  
**<** высокий приоритет   
**N** низкий приоритет  
**L** имеются страницы, блокированные в памяти 
**s** лидер сеанса  
**и** многопоточный  
**+** на переднем плане





