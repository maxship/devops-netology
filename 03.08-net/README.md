# Домашнее задание к занятию "3.8. Компьютерные сети, лекция 3"

1. ipvs. Если при запросе на VIP сделать подряд несколько запросов (например, `for i in {1..50}; do curl -I -s 172.28.128.200>/dev/null; done `), ответы будут получены почти мгновенно. Тем не менее, в выводе `ipvsadm -Ln` еще некоторое время будут висеть активные `InActConn`. Почему так происходит?

Соединение находится в состоянии `InActConn`, пока не истекет timeout. По умолчанию для TCP и UDP:
```bash
root@netology3:/home/vagrant# ipvsadm -L --timeout
Timeout (tcp tcpfin udp): 900 120 300
```

2. На лекции мы познакомились отдельно с ipvs и отдельно с keepalived. Воспользовавшись этими знаниями, совместите технологии вместе (VIP должен подниматься демоном keepalived). Приложите конфигурационные файлы, которые у вас получились, и продемонстрируйте работу получившейся конструкции. Используйте для директора отдельный хост, не совмещая его с риалом! Подобная схема возможна, но выходит за рамки рассмотренного на лекции.


Запустим ВМ с IP адресами:  
172.28.128.10, 172.28.128.60 - реальные сервера;  
172.28.128.90, 172.28.128.120 - хосты LVS + keepalived;  
172.28.128.150 - клиент. 

Конфигурация `Vagranfile`:  
```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

boxes = {
  'netology1' => '10',
  'netology2' => '60',
  'netology3' => '90',
  'netology4' => '120',
  'netology5' => '150',
}

Vagrant.configure("2") do |config|
  config.vm.network "private_network", virtualbox__intnet: true, auto_config: false
  config.vm.box = "bento/ubuntu-20.04"

  boxes.each do |k, v|
    config.vm.define k do |node|
      node.vm.provision "shell" do |s|
        s.inline = "hostname $1;"\
          "ip addr add $2 dev eth1;"\
          "ip link set dev eth1 up;"\
          "sudo apt-get update;"\
		  "sudo apt-get -y install nginx;"
        s.args = [k, "172.28.128.#{v}/24"]
      end
    end
  end

end
```

Проверим работоспособность nginx:
```bash
vagrant@netology5:~$ curl -I -s 172.28.128.{10,60}:80 | grep HTTP
HTTP/1.1 200 OK
HTTP/1.1 200 OK
```
Добавляем VIP 172.28.128.200 на оба реальных сервера на интерфейс lo, отключаем ответ на ARP запросы на обоих риалах
```bash
vagrant@netology1:~$ sudo ip addr add 172.28.128.200/32 dev lo label lo:VIP200

root@netology1:~$ ip -4 addr show | grep inet
    inet 127.0.0.1/8 scope host lo
    inet 172.28.128.200/32 scope global lo:VIP200
    inet 172.28.128.10/24 scope global eth1

root@netology1:~$ sysctl -w net.ipv4.conf.all.arp_ignore=1
root@netology1:~$ sysctl -w net.ipv4.conf.all.arp_announce=2
```

Устанавливаем keepalived
```bash
vagrant@netology{3,4}:~$ sudo apt-get install keepalived
vagrant@netology4:~$ nano /etc/keepalived/keepalived.conf

global_defs {
   notification_email {
     admin@example.com
   }
   notification_email_from noreply_admin@example.com
   smtp_server 127.0.0.1
   smtp_connect_timeout 60
}

vrrp_instance RH_1 {
    state MASTER #Для второго хоста: BACKUP
    interface eth1
    virtual_router_id 50
    priority 100 #Для второго хоста: 99
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass netology
    }
    virtual_ipaddress {
        172.28.128.200
    }
}

virtual_server 172.28.128.200 80
    delay_loop 10
    lb_algo rr
    lb_kind DR
    persistence_timeout 9600
    protocol TCP

    real_server 172.28.128.10 80 {
        weight 1
        TCP_CHECK {
          connect_timeout 10
          connect_port    80
        }
    }
    real_server 172.28.128.60 80 {
        weight 1
        TCP_CHECK {
          connect_timeout 10
          connect_port    80
        }
    }
}
```
Запускаем сервис на обоих хостах, проверяем статус.

```
root@netology3:~$ systemctl start keepalived.service
root@netology3:~$ systemctl enable keepalived.service
Synchronizing state of keepalived.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable keepalived
root@netology3:~$ systemctl status keepalived.service
● keepalived.service - Keepalive Daemon (LVS and VRRP)
     Loaded: loaded (/lib/systemd/system/keepalived.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-07-26 11:07:02 UTC; 1min 18s ago
...

Jul 26 11:07:03 netology3 Keepalived_healthcheckers[22525]: Activating healthchecker for service [172.28.128.10]:tcp:80 for VS [172.28.128.200]:tcp:80
Jul 26 11:07:03 netology3 Keepalived_healthcheckers[22525]: Activating healthchecker for service [172.28.128.60]:tcp:80 for VS [172.28.128.200]:tcp:80
Jul 26 11:07:03 netology3 Keepalived_healthcheckers[22525]: Activating BFD healthchecker
Jul 26 11:07:03 netology3 Keepalived_vrrp[22526]: (RH_1) received lower priority (99) advert from 172.28.128.120 - discarding
Jul 26 11:07:06 netology3 Keepalived_vrrp[22526]: (RH_1) Entering MASTER STATE
Jul 26 11:07:08 netology3 Keepalived_healthcheckers[22525]: TCP connection to [172.28.128.60]:tcp:80 success.
Jul 26 11:07:11 netology3 Keepalived_healthcheckers[22525]: TCP connection to [172.28.128.10]:tcp:80 success.
```
```
root@netology4:~$ systemctl status keepalived.service
● keepalived.service - Keepalive Daemon (LVS and VRRP)
     Loaded: loaded (/lib/systemd/system/keepalived.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-07-26 11:06:56 UTC; 1min 13s ago
...

Jul 26 11:06:56 netology4 Keepalived_vrrp[16001]: (RH_1) Entering BACKUP STATE (init)
Jul 26 11:06:56 netology4 Keepalived_healthcheckers[16000]: Gained quorum 1+0=1 <= 2 for VS [172.28.128.200]:tcp:80
Jul 26 11:06:56 netology4 Keepalived_healthcheckers[16000]: Activating healthchecker for service [172.28.128.10]:tcp:80 for VS [172.28.128.200]:tcp:80
Jul 26 11:06:56 netology4 Keepalived_healthcheckers[16000]: Activating healthchecker for service [172.28.128.60]:tcp:80 for VS [172.28.128.200]:tcp:80
Jul 26 11:06:56 netology4 Keepalived_healthcheckers[16000]: Activating BFD healthchecker
Jul 26 11:06:59 netology4 Keepalived_vrrp[16001]: (RH_1) Entering MASTER STATE
Jul 26 11:07:02 netology4 Keepalived_healthcheckers[16000]: TCP connection to [172.28.128.60]:tcp:80 success.
Jul 26 11:07:04 netology4 Keepalived_healthcheckers[16000]: TCP connection to [172.28.128.10]:tcp:80 success.
Jul 26 11:07:06 netology4 Keepalived_vrrp[16001]: (RH_1) Master received advert from 172.28.128.90 with higher priority 100, ours 99
Jul 26 11:07:06 netology4 Keepalived_vrrp[16001]: (RH_1) Entering BACKUP STATE
```
Сервис успешно запущен на обоих хостах.  
С клиента проверяем VIP.
```bash
vagrant@netology5:~$ for i in {1..50}; do curl -I -s 172.28.128.200>/dev/null; done
```
На мастере смотрим статистику LVS.
```bash
root@netology3:~$ ipvsadm -Ln --stats
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes
  -> RemoteAddress:Port
TCP  172.28.128.200:80                  51      306        0    20349        0
  -> 172.28.128.10:80                    0        0        0        0        0
  -> 172.28.128.60:80                   51      306        0    20349        0
```
Сервисы работают, но весь трафик почему-то идет на сервер netology2. Возможно, неправильно сделал предварительную настройку real серверов?

Проверим работоспособность keepalived. Для этого вырубим службу на мастере (netology3).
```bash
root@netology3:/home/vagrant# systemctl stop keepalived.service
```

Проверяем службу на netology4.
```bash
root@netology4:/home/vagrant# systemctl status keepalived.service
● keepalived.service - Keepalive Daemon (LVS and VRRP)
...
Jul 26 11:15:32 netology4 Keepalived_vrrp[16157]: (RH_1) Backup received priority 0 advertisement
Jul 26 11:15:33 netology4 Keepalived_vrrp[16157]: (RH_1) Entering MASTER STATE
```
Видим, что состояние MASTER теперь установилось на netology4. Снова отправляем с клиента запросы на VIP.

```bash
vagrant@netology5:~$ for i in {1..50}; do curl -I -s 172.28.128.200>/dev/null; done
root@netology4:~$ ipvsadm -Ln --stats
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port               Conns   InPkts  OutPkts  InBytes OutBytes
  -> RemoteAddress:Port
TCP  172.28.128.200:80                  50      300        0    19950        0
  -> 172.28.128.10:80                    0        0        0        0        0
  -> 172.28.128.60:80                   50      300        0    19950        0
```

Видим, что keepalived действительно переключидся на BACKUP. LVS по прежнему переправляет все на один сервер (пока не могу понять почему).

### Альтернативное решение

В моем первоначальном решении демон LVS поднимался через конфиг keepalived. В чем причина неработающего round-robin я так и не выяснил.
Вместо этого убрал из конфига настройку LVS:
```
global_defs {
   script_user root
   enable_script_security
}

vrrp_script chk_nginx {
 script "systemctl status nginx"
 interval 2 }

vrrp_instance VRRP_1 {
    state MASTER
    interface eth1
    virtual_router_id 50
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass netology
    }
    virtual_ipaddress {
        172.28.128.200/32 dev eth1
    }
        track_script { chk_nginx }
}
```
И настроил LVS вручную на мастере и бэкапе:
```
root@netology4:/home/vagrant# ipvsadm -A -t 172.28.128.200:80 -s rr
root@netology4:/home/vagrant# ipvsadm -a -t 172.28.128.200:80 -r 172.28.128.10:80 -g -w 1
root@netology4:/home/vagrant# ipvsadm -a -t 172.28.128.200:80 -r 172.28.128.60:80 -g -w 1
root@netology4:/home/vagrant# ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.28.128.200:80 rr
  -> 172.28.128.10:80             Route   1      0          0
  -> 172.28.128.60:80             Route   1      0          0
```
После этого при проверке работоспособности трафик стал делиться пополам.
```
vagrant@netology5:~$ for i in {1..50}; do curl -I -s 172.28.128.200>/dev/null; done

vagrant@netology1:~$ wc -l /var/log/nginx/access.log
409 /var/log/nginx/access.log
vagrant@netology1:~$ wc -l /var/log/nginx/access.log
434 /var/log/nginx/access.log

vagrant@netology2:~$ wc -l /var/log/nginx/access.log
719 /var/log/nginx/access.log
vagrant@netology2:~$ wc -l /var/log/nginx/access.log
744 /var/log/nginx/access.log
```


3. В лекции мы использовали только 1 VIP адрес для балансировки. У такого подхода несколько отрицательных моментов, один из которых – невозможность активного использования нескольких хостов (1 адрес может только переехать с master на standby). Подумайте, сколько адресов оптимально использовать, если мы хотим без какой-либо деградации выдерживать потерю 1 из 3 хостов при входящем трафике 1.5 Гбит/с и физических линках хостов в 1 Гбит/с? Предполагается, что мы хотим задействовать 3 балансировщика в активном режиме (то есть не 2 адреса на 3 хоста, один из которых в обычное время простаивает).

Формулировка задания не понятна. Насколько я понял, в рассматриваемой схеме есть фиксированное количество хостов, равное 3. На каждом из них крутится больше одного балансровщика. Количество этих сервисов на каждом из хостов равно количеству адресов VIP?? Или сервисов по одному на каждом хосте? не разобрался пока.  

В таком случае, если используется 3 VIP адреса, то трафик делится на 3 канала по 500 Мбит/с. Соответственно, при потере одного из них, на одном из каналов будет трафик в 1 Гбит/c, что даст огромные потери.  

В случае, если  число адресов VIP будет равно 4, то изначально трафик делится между хостами в соотношении 750/375/375 Мбит/с. При падении оного из хостов в зависимости от настройки приоритетов, может получиться расклад 750/750 Мбит/с либо 1125/375 Мбит/с, что нас также не устраивает.  

При числе адресов VIP, равном 5 трафик изначально распределяется 600/600/300 Мбит/с. При потере одного из узлов нагрузка распределится как 900/600 Мбит/с, что укладывается в пропускную способность линка.
