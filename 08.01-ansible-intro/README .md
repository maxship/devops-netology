# Домашнее задание к занятию "08.01 Введение в Ansible"

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

---
Ссылка на новый репозиторий с ДЗ:
[https://github.com/maxship/netology-8.1-ansible](https://github.com/maxship/netology-8.1-ansible)

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.

```shell
max@MaxShip-Ryzen5-3600:~/devops/netology-8.1-ansible$ ansible-playbook site.yml -i inventory/test.yml
....
TASK [Print fact] *****************
ok: [localhost] => {
    "msg": 12
}
....
```

2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.

`some_fact` для всех хостов задан в файле `group_vars/all/examp.yml`

4. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

```shell
$ docker run --name ubuntu -d --rm pycontribs/ubuntu sleep 999999 

$ docker run --name centos7 -d --rm pycontribs/centos:7 sleep 999999

$ docker ps
CONTAINER ID   IMAGE                 COMMAND          CREATED          STATUS          PORTS     NAMES
6c3a5a569ee2   pycontribs/centos:7   "sleep 999999"   28 seconds ago   Up 24 seconds             centos7
bec59da15056   pycontribs/ubuntu     "sleep 999999"   2 minutes ago    Up 2 minutes              ubuntu
```
Для подключению к локальным контейнерам с помощью `ansible_connection: docker`, потребуется дополнительный плагин.
```shell
$ ansible-galaxy collection install community.docker
```

4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.

```shell
$ ansible-playbook site.yml -i inventory/prod.yml

TASK [Print fact] **********************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}
```

5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.

6. Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.

```shell
$ ansible-playbook site.yml -i inventory/prod.yml

TASK [Print OS] ****************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}


TASK [Print fact] *********************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
```

8. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.

```shell
$ ansible-vault encrypt group_vars/deb/examp.yml group_vars/el/examp.yml
```

9. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.

```shell
$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: 

....
TASK [Print fact] **********
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ******************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```
10. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.

```shell
$ ansible-doc -t connection -l
community.docker.docker     Run tasks in docker containers   
community.docker.docker_api Run tasks in docker containers 
community.docker.nsenter    execute on host running controller container
local                       execute on controller 
paramiko_ssh                Run tasks via python ssh (paramiko) 
psrp                        Run tasks over Microsoft PowerShell Remoting Protocol
ssh                         connect via ssh client binary 
winrm                       Run tasks over Microsoft's WinRM 
```
11. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.

```yaml
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local
```

12. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

```shell
$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass

TASK [Print fact] ************
ok: [localhost] => {
    "msg": "all default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}

```


13. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

[https://github.com/maxship/netology-8.1-ansible](https://github.com/maxship/netology-8.1-ansible)


## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
