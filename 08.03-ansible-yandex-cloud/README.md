# Домашнее задание к занятию "08.03 Использование Yandex Cloud"

## Подготовка к выполнению
1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

---

Подготовил ВМ для задания с помощью терраформа (в заданиях блока терраформа делал все для AWS, поэтому решил сейчас попробовать на YC).

Для этого экспортировал переменную `YC_TOKEN` с токеном авторизации в `~/.bashrc`.
В файле [main.tf](https://github.com/maxship/netology-8.3-ansible-yandex/blob/master/terraform/main.tf) задал парамерты провайдера, создаваемых ВМ и сети.
Пользовательские данные для подключения к ВМ прописал в файле `meta.txt`:

```yml
#cloud-config
users:
  - name: maxship
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - <содержимое публичного ssh ключа>
```
В [main.tf](https://github.com/maxship/netology-8.3-ansible-yandex/blob/master/terraform/main.tf) путь к этому файлу указан здесь:

```yml
metadata = {
    user-data = "${file("./meta.txt")}"
  }  
```
После выполнения `terraform apply` автоматически присвоенные IP адреса прописал в `hosts.yml`.


### [Ссылка на репозитроий с готовым плейбуком.](https://github.com/maxship/netology-8.3-ansible-yandex)


## Основная часть
1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
4. Приготовьте свой собственный inventory файл `prod.yml`.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Проделайте шаги с 1 до 8 для создания ещё одного play, который устанавливает и настраивает filebeat.
10. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
11. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.

---
Дописанный плейбук:
```yml
---
# Elasticsearch
- name: Install Elasticsearch 
  hosts: elasticsearch
  handlers:
    - name: restart Elasticsearch
      become: true
      service:
        name: elasticsearch
        state: restarted
      tags: elastic

  tasks:
    - name: "Download Elasticsearch's rpm"
      get_url:
        url: "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-{{ elk_stack_version }}-x86_64.rpm"
        dest: "/tmp/elasticsearch-{{ elk_stack_version }}-x86_64.rpm"
        mode: 0755
      register: get_elastic
      until: get_elastic is succeeded
      tags: elastic

    - name: Install Elasticsearch
      become: true
      yum:
        name: "/tmp/elasticsearch-{{ elk_stack_version }}-x86_64.rpm"
        state: present
      tags: elastic

    - name: Configure Elasticsearch
      become: true
      template:
        src: elasticsearch.yml.j2
        dest: /etc/elasticsearch/elasticsearch.yml
        mode: 0644
      notify: restart Elasticsearch
      tags: elastic

# Kibana
- name: Install Kibana 
  hosts: kibana
  handlers:
    - name: restart Kibana
      become: true
      service:
        name: kibana
        state: restarted
      tags: kibana

  tasks:
    - name: "Download Kibana's rpm"
      get_url:
        url: "https://artifacts.elastic.co/downloads/kibana/kibana-{{ elk_stack_version }}-x86_64.rpm"
        dest: "/tmp/kibana-{{ elk_stack_version }}-x86_64.rpm"
        mode: 0755
      register: get_kibana
      until: get_kibana is succeeded
      tags: kibana

    - name: Install Kibana
      become: true
      yum:
        name: "/tmp/kibana-{{ elk_stack_version }}-x86_64.rpm"
        state: present
      tags: kibana

    - name: Configure Kibana
      become: true
      template:
        src: kibana.yml.j2
        dest: /etc/kibana/kibana.yml
        mode: 0644
      notify: restart Kibana
      tags: kibana

#Filebeat
- name: Install Filebeat
  hosts: app
  handlers:
    - name: restart Filebeat
      become: true
      service:
        name: filebeat
        state: restarted
      tags: filebeat

  tasks:
    - name: "Download Filebeat's rpm"
      get_url:
        url: "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-{{ elk_stack_version }}-x86_64.rpm"
        dest: "/tmp/filebeat-{{ elk_stack_version }}-x86_64.rpm"
        mode: 0755
      register: get_filebeat
      until: get_filebeat is succeeded
      tags: filebeat

    - name: Install Filebeat
      become: true
      package:
        name: "/tmp/filebeat-{{ elk_stack_version }}-x86_64.rpm"
        state: present
      tags: filebeat

    - name: Configure Filebeat
      become: true
      template:
        src: filebeat.yml.j2
        dest: /etc/filebeat/filebeat.yml
        mode: 0644
      notify: restart Filebeat
      tags: filebeat

    - name: Set filebit modules
      become: true
      command:
        cmd: filebeat modules enable system
        chdir: /usr/share/filebeat/bin
      register:
      changed_when: filebeat_modules.stdout != 'Module system ia already enabled'

    - name: Load Kibana Dashboard
      become: true
      command: 
        cmd: filebeat setup
        chdir: /usr/share/filebeat/bin
      register: filebeat_setup
      changed_when: false
      until: filebeat_setup is succeeded
```

После исправления некоторых косяков у линта нет замечаний:

```
$ ansible-lint site.yml
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
```

Запуск с параметром `--check` предсказуемо не прошел:

```
$ ansible-playbook -i inventory/elk site.yml --check

PLAY [Install Elasticsearch] ********************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************
ok: [el-instance]

TASK [Download Elasticsearch's rpm] *************************************************************************************************
changed: [el-instance]

TASK [Install Elasticsearch] ********************************************************************************************************
fatal: [el-instance]: FAILED! => {"changed": false, "msg": "No RPM file matching '/tmp/elasticsearch-7.15.2-x86_64.rpm' found on system", "rc": 127, "results": ["No RPM file matching '/tmp/elasticsearch-7.15.2-x86_64.rpm' found on system"]}

PLAY RECAP **************************************************************************************************************************
el-instance                : ok=2    changed=1    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
```

После нескольких неудач на запуске файлбита все наконец заработало:
```
$ ansible-playbook -i inventory/elk site.yml --tag filebeat --diff

....

PLAY RECAP **************************************************************************************************************************
app-instance               : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
el-instance                : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
kibana-instance            : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

### [Ссылка на репозитроий с готовым плейбуком.](https://github.com/maxship/netology-8.3-ansible-yandex)