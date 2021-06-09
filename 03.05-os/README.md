# 3.5. Файловые системы

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.

2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

Не могут, т.к. с точки зрения системы все жесткие ссылки эквивалентны этому объекту и иимеют те же атрибуты.

3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
```
Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.
    
4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.
```
root@vagrant:/home/vagrant# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
sdb                    8:16   0  2.5G  0 disk
sdc                    8:32   0  2.5G  0 disk

root@vagrant:/home/vagrant# fdisk /dev/sdb

Command (m for help): g
Created a new GPT disklabel (GUID: ADC11E7A-C11E-3C42-AD48-A446231C5DA9).

Command (m for help): n
Partition number (1-128, default 1):
First sector (2048-5242846, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242846, default 5242846): +2G

Created a new partition 1 of type 'Linux filesystem' and of size 2 GiB.

Command (m for help): n
Partition number (2-128, default 2):
First sector (4196352-5242846, default 4196352):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242846, default 5242846):

Created a new partition 2 of type 'Linux filesystem' and of size 511 MiB.

Command (m for help): p
.....
Device       Start     End Sectors  Size Type
/dev/sdb1     2048 4196351 4194304    2G Linux filesystem
/dev/sdb2  4196352 5242846 1046495  511M Linux filesystem
```


5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.

```
root@vagrant:/home/vagrant# sfdisk -d /dev/sdb | sfdisk /dev/sdc
.....
New situation:
Disklabel type: gpt
Disk identifier: ADC11E7A-C11E-3C42-AD48-A446231C5DA9

Device       Start     End Sectors  Size Type
/dev/sdc1     2048 4196351 4194304    2G Linux filesystem
/dev/sdc2  4196352 5242846 1046495  511M Linux filesystem

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

```
root@vagrant:/home/vagrant# mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
mdadm: array /dev/md0 started.
```

7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

```
root@vagrant:/home/vagrant# mdadm -C -v /dev/md1 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2
mdadm: array /dev/md1 started.
```

8. Создайте 2 независимых PV на получившихся md-устройствах.

```
root@vagrant:/home/vagrant# pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created.
root@vagrant:/home/vagrant# pvcreate /dev/md1
  Physical volume "/dev/md1" successfully created.
```

9. Создайте общую volume-group на этих двух PV.

```
root@vagrant:/home/vagrant# vgcreate test_vg /dev/md0 /dev/md1
  Volume group "test_vg" successfully created
  
root@vagrant:/home/vagrant# pvdisplay
.....
  --- Physical volume ---
  PV Name               /dev/md0
  VG Name               test_vg
  PV Size               <2.00 GiB / not usable 0
.....
  --- Physical volume ---
  PV Name               /dev/md1
  VG Name               test_vg
  PV Size               1017.00 MiB / not usable 0
.....
```

10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

```
root@vagrant:/home/vagrant# lvcreate -n test_lv -L100M test_vg /dev/md1
  Logical volume "test_lv" created.
```

11. Создайте `mkfs.ext4` ФС на получившемся LV.

```
root@vagrant:/home/vagrant# lvdisplay
.........
  --- Logical volume ---
  LV Path                /dev/test_vg/test_lv
.........

root@vagrant:/home/vagrant# mkfs.ext4 /dev/test_vg/test_lv
......
Writing superblocks and filesystem accounting information: done
```

12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.

```
root@vagrant:/home/vagrant# mkdir /tmp/new
root@vagrant:/home/vagrant# mount /dev/test_vg/test_lv /tmp/new
```

13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.

```
root@vagrant:/home/vagrant# wget -q https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
root@vagrant:/home/vagrant# ls /tmp/new
lost+found  test.gz
```

14. Прикрепите вывод `lsblk`.

```
root@vagrant:/home/vagrant# lsblk
NAME                  MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                     8:0    0   64G  0 disk
├─sda1                  8:1    0  512M  0 part  /boot/efi
├─sda2                  8:2    0    1K  0 part
└─sda5                  8:5    0 63.5G  0 part
  ├─vgvagrant-root    253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1  253:1    0  980M  0 lvm   [SWAP]
sdb                     8:16   0  2.5G  0 disk
├─sdb1                  8:17   0    2G  0 part
│ └─md0                 9:0    0    2G  0 raid1
└─sdb2                  8:18   0  511M  0 part
  └─md1                 9:1    0 1017M  0 raid0
    └─test_vg-test_lv 253:2    0  100M  0 lvm   /tmp/new
sdc                     8:32   0  2.5G  0 disk
├─sdc1                  8:33   0    2G  0 part
│ └─md0                 9:0    0    2G  0 raid1
└─sdc2                  8:34   0  511M  0 part
  └─md1                 9:1    0 1017M  0 raid0
    └─test_vg-test_lv 253:2    0  100M  0 lvm   /tmp/new
```

15. Протестируйте целостность файла:

```
root@vagrant:/home/vagrant# gzip -t /tmp/new/test.gz
root@vagrant:/home/vagrant# echo $?
0
```

16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

```
root@vagrant:/home/vagrant# pvmove /dev/md1 /dev/md0
  /dev/md1: Moved: 100.00%
```

17. Сделайте `--fail` на устройство в вашем RAID1 md.

```
root@vagrant:/home/vagrant# mdadm /dev/md0 --fail /dev/sdc1
mdadm: set /dev/sdc1 faulty in /dev/md0
```

18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.

```
root@vagrant:/home/vagrant# dmesg | grep md0
[18542.496026] md/raid1:md0: Disk failure on sdc1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.
```

19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

```
root@vagrant:/home/vagrant# gzip -t /tmp/new/test.gz
root@vagrant:/home/vagrant# echo $?
0
 ```


