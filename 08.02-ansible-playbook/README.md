# Домашнее задание к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению
1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
3. Подготовьте хосты в соотвтествии с группами из предподготовленного playbook. 
4. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`. 

---

### [Ссылка на новый репозиторий](https://github.com/maxship/netology-8.2-ansible-playbook)

---

## Основная часть

---
1. Приготовьте свой собственный inventory файл `prod.yml`.

Для подключения в созданным в вагранте ВМ использовал ssh со входом по паролю. Пароль зашифровал командой `ansible-vault encrypt_string`.

```yml
---
elasticsearch:
  hosts:
    ubuntu-1:
    # Подключение к локальной ВМ 1 по ssh
      ansible_host: 127.0.0.1
      ansible_port: 2222
      ansible_connection: ssh
      ansible_user: vagrant
      ansible_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          36313330623266383839376530386661633930613364633238656531303832373338353536643834
          3263306633646264353033636134666433393833623133630a353935646161386637623930313038
          66616431333031653931356438613933356662633533646135346561346430373235306135313464
          3134633131363739360a646538393237393863323238353464326337303633393839333662376130
          3732
kibana:
  hosts:
    ubuntu-2:
    # Подключение к локальной ВМ 2 по ssh
      ansible_host: 127.0.0.1
      ansible_port: 2200
      ansible_connection: ssh
      ansible_user: vagrant
      ansible_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          36313330623266383839376530386661633930613364633238656531303832373338353536643834
          3263306633646264353033636134666433393833623133630a353935646161386637623930313038
          66616431333031653931356438613933356662633533646135346561346430373235306135313464
          3134633131363739360a646538393237393863323238353464326337303633393839333662376130
          3732
```
---
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.
---

Плей для кибаны выглядит так:

```yml
- name: Install Kibana
  hosts: kibana
  tasks:
    - name: Upload tar.gz Kibana from remote URL
      get_url:
        url: "https://artifacts.elastic.co/downloads/kibana/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        mode: 0755
        timeout: 60
        force: true
        validate_certs: false
      register: get_kibana
      until: get_kibana is succeeded
      tags: kibana
    - name: Create directrory for Kibana
      become: true
      file:
        state: directory
        path: "{{ kibana_home }}"
        mode: 0644
      tags: kibana
    - name: Extract Kibana in the installation directory
      become: true
      unarchive:
        copy: false
        src: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        dest: "{{ kibana_home }}"
        extra_opts: [--strip-components=1]
        creates: "{{ kibana_home }}/bin/kibana"
        mode: 0644
      tags:
        - kibana
    - name: Set environment kibana
      become: true
      template:
        src: templates/kibana.sh.j2
        dest: /etc/profile.d/kibana.sh
        mode: 0644
      tags: kibana
```
---
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
---

Установил `ansible-lint` 

```sh
pip3 install git+https://github.com/ansible-community/ansible-lint.git
```

Проверка завершилось без ошибок, но с предупреждениями `risky-file-permissions`. 

```sh
$ ansible-lint site.yml
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
WARNING  Listing 7 violation(s) that are fatal
risky-file-permissions: File permissions unset or incorrect
site.yml:9 Task/Handler: Upload .tar.gz file containing binaries from local storage

risky-file-permissions: File permissions unset or incorrect
site.yml:16 Task/Handler: Ensure installation dir exists

risky-file-permissions: File permissions unset or incorrect
site.yml:32 Task/Handler: Export environment variables

risky-file-permissions: File permissions unset or incorrect
site.yml:53 Task/Handler: Create directrory for Elasticsearch

risky-file-permissions: File permissions unset or incorrect
site.yml:68 Task/Handler: Set environment Elastic

You can skip specific rules or tags by adding them to your configuration file:
# .ansible-lint
warn_list:  # or 'skip_list' to silence them completely
  - experimental  # all rules tagged as experimental

Finished with 0 failure(s), 7 warning(s) on 1 files.
```
Насколько я понял, lint ругается, что права не заданы в явном виде параметром `mode`. Непонятно только, насколько это критично? Принято ли задавать разрешения в таком виде, или эти предупреждения можно игнорировать?

Во всех указанных случаях добавил права `mode: 0644` снова запустил lint.

```
$ ansible-lint site.yml
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
```

---
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
---

На таске разархиварования эластика в директорию `--check` выдает такое сообщение:
```sh
TASK [Extract Elasticsearch in the installation directory] ********
task path: /home/max/devops/netology-8.2-ansible-playbook/site.yml:58
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
fatal: [ubuntu]: FAILED! => {"changed": false, "msg": "dest '/opt/elastic/7.15.2' must be an existing dir"}

PLAY RECAP ***********
ubuntu                     : ok=8    changed=2    unreachable=0    failed=1    skipped=1    rescued=0    ignored=0 
```
На сколько я понял, это не ошибка, просто эта директория еще не создана в реальности, и проверить работоспособность дальше получится только запустив плей на хосте.

---
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
---

```sh
$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass --diff

.......

TASK [Create directrory for Elasticsearch] ********************************************************************************************************
fatal: [ubuntu]: FAILED! => {"changed": false, "msg": "There was an issue creating /opt/elastic as requested: [Errno 13] Permission denied: b'/opt/elastic'", "path": "/opt/elastic/7.15.2"}

PLAY RECAP ****************************************************************************************************************************************
ubuntu                     : ok=7    changed=1    unreachable=0    failed=1    skipped=1    rescued=0    ignored=0 
```
Из вывода понятно, что нужно повысить права для создания этой директории.

```yml
    - name: Create directrory for Elasticsearc
      become: true
      file:
        state: directory
        path: "{{ elastic_home }}"
      tags: elastic
```

---
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен. 
---   

Запустил плейбук еще раз, на этот раз все отработало правильно.

```sh
$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass --diff
Vault password: 

.....

TASK [Set environment kibana] *********************************************************************************************************************
--- before
+++ after: /home/max/.ansible/tmp/ansible-local-35784c9sw0qd1/tmpxeshy7xy/kibana.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export KB_HOME=/opt/kibana/7.15.2
+export PATH=$PATH:$KB_HOME/bin
\ No newline at end of file

changed: [ubuntu]

PLAY RECAP ****************************************************************************************************************************************
ubuntu                     : ok=15   changed=7    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0 
```

Запустил еще раз для проверки идемпотентности.

```sh
PLAY RECAP ****************************************************************************************************************************************
ubuntu                     : ok=13   changed=0    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0 
```

---
9.  Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10.   Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.
---

### [Готовый плейбук + файл README.md с описанием парамеров](https://github.com/maxship/netology-8.2-ansible-playbook)

В выше приведенном выводе результатов команд видно только один хост, т.к. изначально я установил кибану и эластик на один хост. Уже после того как выполнил ДЗ, добавил отдельный хост для кибаны. Заново приводить сюда все не стал, конечный результат выглядит так::


```sh
$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass --diff
Vault password: 

PLAY [Install Java] **********************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [ubuntu-1]
ok: [ubuntu-2]

TASK [Set home dir for Java 11] **********************************************************************************************************
ok: [ubuntu-1]
ok: [ubuntu-2]

TASK [Upload .tar.gz file containing binaries from local storage] ************************************************************************
ok: [ubuntu-1]
ok: [ubuntu-2]

TASK [Ensure installation dir exists] ****************************************************************************************************
ok: [ubuntu-1]
ok: [ubuntu-2]

TASK [Extract java in the installation directory] ****************************************************************************************
skipping: [ubuntu-1]
skipping: [ubuntu-2]

TASK [Export environment variables] ******************************************************************************************************
ok: [ubuntu-1]
ok: [ubuntu-2]

PLAY [Install Elasticsearch] *************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [ubuntu-1]

TASK [Upload tar.gz Elasticsearch from remote URL] ***************************************************************************************
ok: [ubuntu-1]

TASK [Create directrory for Elasticsearc] ************************************************************************************************
ok: [ubuntu-1]

TASK [Extract Elasticsearch in the installation directory] *******************************************************************************
skipping: [ubuntu-1]

TASK [Set environment Elastic] ***********************************************************************************************************
ok: [ubuntu-1]

PLAY [Install Kibana] ********************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************
ok: [ubuntu-2]

TASK [Upload tar.gz Kibana from remote URL] **********************************************************************************************
ok: [ubuntu-2]

TASK [Create directrory for Kibana] ******************************************************************************************************
ok: [ubuntu-2]

TASK [Extract Kibana in the installation directory] **************************************************************************************
skipping: [ubuntu-2]

TASK [Set environment kibana] ************************************************************************************************************
ok: [ubuntu-2]

PLAY RECAP *******************************************************************************************************************************
ubuntu-1                   : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
ubuntu-2                   : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
```
---