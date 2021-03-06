# Домашнее задание к занятию "8.4 Работа с Roles"

## Подготовка к выполнению
1. Создайте два пустых публичных репозитория в любом своём проекте: kibana-role и filebeat-role.
2. Добавьте публичную часть своего ключа к своему профилю в github.

---

Создал 2 репозитория [kibana-role](https://github.com/maxship/kibana-role) и [filebeat-role](https://github.com/maxship/filebeat-role).

Сделал в [репозитории предыдущего задания](https://github.com/maxship/netology-8.3-ansible-yandex) ветку [ROLES](https://github.com/maxship/netology-8.3-ansible-yandex/tree/ROLES) для переделки ранее созданного play в вариант с использованием roles.

## Основная часть

Наша основная цель - разбить наш playbook на отдельные roles. Задача: сделать roles для elastic, kibana, filebeat и написать playbook для использования этих ролей. Ожидаемый результат: существуют два ваших репозитория с roles и один репозиторий с playbook.

1. Создать в старой версии playbook файл `requirements.yml` и заполнить его следующим содержимым:
   ```yaml
   ---
     - src: git@github.com:netology-code/mnt-homeworks-ansible.git
       scm: git
       version: "2.0.0"
       name: elastic 
   ```
2. При помощи `ansible-galaxy` скачать себе эту роль.

Скачал role в директорию внутри пректа (дириктория `roles/elasticsearch-role` создается автоматически по параметру `name` в файле `requirements.yml`).
```
$ ansible-galaxy install -r requirements.yml -p roles
Starting galaxy role install process
- extracting elasticsearch-role to /home/max/devops/netology-8.3-ansible-yandex/roles/elasticsearch-role
- elasticsearch-role (2.0.0) was installed successfully
```

3. Создать новый каталог с ролью при помощи `ansible-galaxy role init kibana-role`.

```
$ ansible-galaxy role init kibana-role
- Role kibana-role was created successfully
```

4. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`. 

```yml
# kibana-role/vars/main.yml
---
supported_systems: ['CentOS', 'Red Hat Enterprise Linux', 'Ubuntu', 'Debian']

# kibana-role/defaults/main.yml
---
kibana_version: "7.14.0"
kibana_install_type: remote

# inventory/elk/group_vars/all.yml
---
elk_stack_version: "7.15.2"
ansible_connection: ssh
ansible_user: maxship
kibana_version: "{{  elk_stack_version  }}"
elasticsearch_version: "{{  elk_stack_version  }}"
filebeat_version: "{{  elk_stack_version  }}"
```
Т.к. все сервисы elk обновляются одновременно, логично будет добавить дополнительную переменную с версией, так, чтобы она имела приоритет выше параметров, указанных по умолчанию. Например, в `inventory/elk/group_vars/all.yml`.

5. Перенести нужные шаблоны конфигов в `templates`.

```yml
# kibana-role/templates/kibana.yml.j2
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://{{ hostvars['el-instance']['ansible_facts']['default_ipv4']['address'] }}:9200"]
kibana.index: ".kibana"
```

6. Создать новый каталог с ролью при помощи `ansible-galaxy role init filebeat-role`.

```
$ ansible-galaxy role init filebeat-role
- Role filebeat-role was created successfully
```

7. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`. 

```yml
# filebeat-role/vars/main.yml
---
supported_systems: ['CentOS', 'Red Hat Enterprise Linux', 'Ubuntu', 'Debian']

# filebeat-role/defaults/main.yml
---
filebeat_version: "7.14.0"
filebeat_install_type: remote
```

8. Перенести нужные шаблоны конфигов в `templates`.

```yml
# filebeat-role/templates/filebeat.yml.j2
output.elasticsearch:
  hosts: ["http://{{ hostvars['el-instance']['ansible_facts']['default_ipv4']['address'] }}:9200"]
setup.kibana:
  host: "http://{{ hostvars['kibana-instance']['ansible_facts']['default_ipv4']['address'] }}:5601"
filebeat.config.modules.path: ${path.config}/modules.d/*.yml
```

9. Описать в `README.md` обе роли и их параметры.


10. Выложите все roles в репозитории. Проставьте тэги, используя семантическую нумерацию.

Проставил теги и загрузил их в репозитории:

```sh
$ git add *
$ git commit -m "role created"
$ git tag -a 1.0.0 -m "1st version"
$ git show --pretty=oneline
f0a9d2b2e8af4bd78c3ddf59aefea5dea89b26b7 (HEAD -> main, tag: 1.0.0) role created
$ git push
$ git push --tags
```

[https://github.com/maxship/filebeat-role/tree/1.0.0](https://github.com/maxship/filebeat-role/tree/1.0.0)

[https://github.com/maxship/kibana-role/tree/1.0.0](https://github.com/maxship/kibana-role/tree/1.0.0)


11.  Добавьте roles в `requirements.yml` в playbook.

```yml
---
- src: git@github.com:netology-code/mnt-homeworks-ansible.git
  scm: git
  version: "2.0.0"
  name: elasticsearch-role

- src: git@github.com:maxship/kibana-role.git
  scm: git
  version: "2.0.0"
  name: kibana-role

- src: git@github.com:maxship/filebeat-role.git
  scm: git
  version: "2.0.0"
  name: filebeat-role
```

12.  Переработайте playbook на использование roles.

Загрузил роли из репозитория в директорию `roles` плейбука:

```
$ ansible-galaxy install -r requirements.yml -p roles
Starting galaxy role install process
- elasticsearch-role (2.0.0) is already installed, skipping.
- extracting kibana-role to /home/max/devops/netology-8.3-ansible-yandex/roles/kibana-role
- kibana-role (1.0.0) was installed successfully
- extracting filebeat-role to /home/max/devops/netology-8.3-ansible-yandex/roles/filebeat-role
- filebeat-role (1.0.0) was installed successfully
```

При запуске плейбука получил такую ошибку:

```
TASK [kibana-role : Copy Kibana to managed node] ********************************
task path: /home/max/devops/netology-8.3-ansible-yandex/kibana-role/tasks/download_yum.yml:11
diff skipped: source file size is greater than 104448
```
Для исправления снял ограничение в `/etc/ansible/ansible.cfg`:
```
max_diff_size = 0 
```
```
$ ansible-playbook site.yml -i inventory/elk --diff -vv
.....
PLAY RECAP **********************************************************************
app-instance               : ok=9    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
el-instance                : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
kibana-instance            : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0 
```

13. Выложите playbook в репозиторий.


14. В ответ приведите ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.

**Ссылки на репозитории с ролями:**

### [https://github.com/maxship/filebeat-role](https://github.com/maxship/filebeat-role)

### [https://github.com/maxship/kibana-role](https://github.com/maxship/kibana-role)

**Ссылка на репозиторий с плейбуком:**

### [https://github.com/maxship/netology-8.3-ansible-yandex/tree/ROLES)](https://github.com/maxship/netology-8.3-ansible-yandex/tree/ROLES)


## Необязательная часть

1. Проделайте схожие манипуляции для создания роли logstash.
2. Создайте дополнительный набор tasks, который позволяет обновлять стек ELK.
3. Убедитесь в работоспособности своего стека: установите logstash на свой хост с elasticsearch, настройте конфиги logstash и filebeat так, чтобы они взаимодействовали друг с другом и elasticsearch корректно.
4. Выложите logstash-role в репозиторий. В ответ приведите ссылку.

---

