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

---


## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.

```shell
$ ansible-vault decrypt group_vars/deb/examp.yml group_vars/el/examp.yml
Vault password: 
Decryption successful
```

2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/examp.yml`.

```shell
$ ansible-vault encrypt_string
New Vault password: 
Confirm New Vault password: 
Reading plaintext input from stdin. (ctrl-d to end input, twice if your content does not already have a newline)
PaSSw0rd
!vault |
          $ANSIBLE_VAULT;1.1;AES256
          30613730633634353938336130623637353034353937663738323964616562353363656464303638
          6231383038373764383030393334383861373139313664330a376462346536326437323336386563
          30396366343939316134366564333130316530383665303266343536663032356536373133616662
          3263306431333733640a343439323830343236326465336134326330393632356166323861663937
          3766

```
Заменил в `group_vars/all/examp.yml` строку `all default fact` на зашифрованный текст.

3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.

```shell
$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: 

TASK [Print fact] **************
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}

```


4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).

```yml
 ---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  fed:
    hosts:
      fedora:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local
```

```shell
$ docker run --name fedora -d --rm pycontribs/fedora sleep 999999
$ docker ps
CONTAINER ID   IMAGE                 COMMAND          CREATED          STATUS          PORTS     NAMES
43351ace8082   pycontribs/fedora     "sleep 999999"   22 seconds ago   Up 19 seconds             fedora
6c3a5a569ee2   pycontribs/centos:7   "sleep 999999"   4 hours ago      Up 4 hours                centos7
bec59da15056   pycontribs/ubuntu     "sleep 999999"   4 hours ago      Up 4 hours                ubuntu
```
```shell
$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass

TASK [Print fact] *******
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [fedora] => {
    "msg": "fedora default fact"
}
```

5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.

создал файл `automation.sh` со следующим содержимым:

```shell
#!/bin/bash

docker run --name ubuntu -d --rm pycontribs/ubuntu sleep 999999 

docker run --name centos7 -d --rm pycontribs/centos:7 sleep 999999

docker run --name fedora -d --rm pycontribs/fedora sleep 999999

ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass

docker stop ubuntu fedora centos7
```
Сделал его исполняемым:

```shell
$ chmod +x automation.sh 
```

Запустил:

```shell
$ bash automation.sh
a06ac688145e38bc33a9997bb170ae1038ae28bb02e507422b924cb8e3ec18b6
9dbd7f2586e0538d63ee38a580cd8117c4c14c441841b31593b1f96daba2d92b
9c3d312a40ddee1cffc663b7540d4537d65ce99035f7b9b12b4d0b7c74eaafbb
Vault password: 
[WARNING]: ansible.utils.display.initialize_locale has not been called, this may result in incorrectly calculated text widths that can cause Display to print
incorrect line lengths

PLAY [Print os facts] *********************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************
ok: [fedora]
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ubuntu should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior 
Ansible releases. A future Ansible release will default to using the discovered platform python for this host. See https://docs.ansible.com/ansible-
core/2.11/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12. Deprecation warnings can be disabled
 by setting deprecation_warnings=False in ansible.cfg.
ok: [ubuntu]
ok: [centos7]
[DEPRECATION WARNING]: Distribution Ubuntu 20.04 on host localhost should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior
 Ansible releases. A future Ansible release will default to using the discovered platform python for this host. See https://docs.ansible.com/ansible-
core/2.11/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12. Deprecation warnings can be disabled
 by setting deprecation_warnings=False in ansible.cfg.
ok: [localhost]

TASK [Print OS] ***************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [fedora] => {
    "msg": "Fedora"
}

TASK [Print fact] *************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [fedora] => {
    "msg": "fedora default fact"
}

PLAY RECAP ********************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
fedora                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu
fedora
centos7
```

6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

Репозиторий с выполненным заданием:
[https://github.com/maxship/netology-8.1-ansible](https://github.com/maxship/netology-8.1-ansible)
---
