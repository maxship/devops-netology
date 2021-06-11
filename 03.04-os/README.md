# 3.4. Операционные системы, лекция 2 (Домашнее задание)

1. На лекции мы познакомились с [node_exporter](https://github.com/prometheus/node_exporter/releases). В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой [unit-файл](https://www.freedesktop.org/software/systemd/man/systemd.service.html) для node_exporter:

    * поместите его в автозагрузку,
    * предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на `systemctl cat cron`),
    * удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.

Создаем пользователя для node_exporter (без этого у меня не хочет работать почему-то). Загружаем последнюю версию из репозитория, распаковываем.
```
sudo useradd node_exporter -s /sbin/nologin

wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz
tar xvfz node_exporter-1.1.2.linux-amd64.tar.gz
cd node_exporter-1.1.2.linux-amd64

sudo cp node_exporter /usr/sbin/
```

Создаем новый юнит, добавляем в него ссылку на внешний файл с настройками.
```
sudo touch /etc/systemd/system/node_exporter.service
sudo nano /etc/systemd/system/node_exporter.service

cat /etc/systemd/system/node_exporter.service

[Unit]
Description=Node Exporter

[Service]
User=node_exporter
EnvironmentFile=/etc/sysconfig/node_exporter
ExecStart=/usr/sbin/node_exporter $OPTIONS

[Install]
WantedBy=multi-user.target
```

Создаем файл с настройками, отключаем значения по умолчанию и добавляем свои. Чтобы удостовериться, что опции из внешнего файла работают, добавляем отключенный по умолчанию параметр, например, ```--collector.zoneinfo```.
```
sudo mkdir -p /etc/sysconfig
sudo touch /etc/sysconfig/node_exporter
sudo nano /etc/sysconfig/node_exporter
sudo cat /etc/sysconfig/node_exporter
OPTIONS="--collector.disable-defaults --collector.zoneinfo --collector.cpu --collector.processes  --collector.netdev --collector.loadavg --collector.meminfo"
```
Запускаем службу.
```
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

sudo systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2021-06-11 05:08:42 UTC; 2s ago
   Main PID: 1328 (node_exporter)
      Tasks: 4 (limit: 2281)
     Memory: 2.4M
     CGroup: /system.slice/node_exporter.service
             └─1328 /usr/sbin/node_exporter
....
```
Смотрим вывод и удостоверяемся что опции из файла настроек подгрузились.
```
curl http://localhost:9100/metrics | grep zone
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 30959    0 30959    0     0  5038k      0 --:--:-- --:--:-- --:--:-- 6046k
node_scrape_collector_duration_seconds{collector="zoneinfo"} 0.000291331
node_scrape_collector_success{collector="zoneinfo"} 1
# HELP node_zoneinfo_high_pages Zone watermark pages_high
# TYPE node_zoneinfo_high_pages gauge
node_zoneinfo_high_pages{node="0",zone=""} 138
node_zoneinfo_high_pages{node="0",zone="DMA32"} 16755
.......
```

Перезагружаем систему и проверяем статус службы.
```
sudo shutdown -r now
sudo systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2021-06-11 05:32:20 UTC; 32s ago

```

2. Ознакомьтесь с опциями node_exporter и выводом `/metrics` по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.

Доступные опции пожно посмотреть во встроенном мане, в моем случае, по адресу /usr/sbin/node_exporter --help.  

Чтобы вывести свой набор выходных данных, нужно отключить настройки по умолчанию и выбрать дополнительные опции, в нашем случае:
```
--collector.disable-defaults --collector.cpu --collector.meminfo --collector.filesystem --collector.netdev 
```

3. Установите в свою виртуальную машину [Netdata](https://github.com/netdata/netdata). Воспользуйтесь [готовыми пакетами](https://packagecloud.io/netdata/netdata/install) для установки (`sudo apt install -y netdata`). После успешной установки:
    * в конфигурационном файле `/etc/netdata/netdata.conf` в секции [web] замените значение с localhost на `bind to = 0.0.0.0`,
    * добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте `vagrant reload`:

    ```bash
    config.vm.network "forwarded_port", guest: 19999, host: 19999
    ```

После успешной перезагрузки в браузере *на своем ПК* (не в виртуальной машине) вы должны суметь зайти на `localhost:19999`. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.

![Screenshot_6](https://user-images.githubusercontent.com/72273610/121641116-98b53780-cab0-11eb-99b6-2334de7d7133.png)


4. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?

Отфильтровав вывод по ключевым словам vb и virt, можно понять, что ОС знает, что запущена на виртуалке.
```
vagrant@vagrant:~$ dmesg | grep -P 'virt|vb'
[    0.003521] CPU MTRRs all blank - virtualized system.
[    0.040166] Booting paravirtualized kernel on KVM
[    0.279251] Performance Events: PMU not available due to virtualization, using software events only.
[    2.174802] vboxvideo: loading out-of-tree module taints kernel.
[    2.174820] vboxvideo: module verification failed: signature and/or required key missing - tainting kernel
[    2.222127] fbcon: vboxvideodrmfb (fb0) is primary device
[    2.308891] vboxvideo 0000:00:02.0: fb0: vboxvideodrmfb frame buffer device
[    2.318711] [drm] Initialized vboxvideo 1.0.0 20130823 for 0000:00:02.0 on minor 0
[    9.975126] systemd[1]: Detected virtualization oracle.
[   13.083422] vboxguest: Successfully loaded version 6.1.16
[   13.083459] vboxguest: misc device minor 58, IRQ 20, I/O port d020, MMIO at 00000000f0400000 (size 0x400000)
[   13.083460] vboxguest: Successfully loaded version 6.1.16 (interface 0x00010004)
[   17.223253] vboxsf: g_fHostFeatures=0x8000000f g_fSfFeatures=0x1 g_uSfLastFunction=29
[   17.223306] vboxsf: Successfully loaded version 6.1.16
[   17.223345] vboxsf: Successfully loaded version 6.1.16 on 5.4.0-58-generic SMP mod_unload  (LINUX_VERSION_CODE=0x50449)
[   17.223936] vboxsf: SHFL_FN_MAP_FOLDER failed for '/vagrant': share not found
[   17.223938] vbsf_read_super_aux err=-6
[   20.031282] 06:23:11.621053 main     vbglR3GuestCtrlDetectPeekGetCancelSupport: Supported (#1)
```
6. Как настроен sysctl `fs.nr_open` на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?

Максимальное количество открытых файлов в системе.
```
vagrant@vagrant:~$ sudo sysctl -a | grep 'fs.nr_open'
fs.nr_open = 1048576
```

Параметрами, заданными по умолчанию в ```ulimit```, количество открытых файлов ограничено 1024. В отличие от ```fs.nr_open```, накладывает лимиты только на текущий шелл и все процессы, запущенные в этом шелле.
```
vagrant@vagrant:~$ ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 7605
max locked memory       (kbytes, -l) 65536
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 7605
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
```

7. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в данном задании под root (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т.д.


9. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (**это важно, поведение в других ОС не проверялось**). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?
