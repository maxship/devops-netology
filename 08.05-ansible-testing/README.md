# Домашнее задание к занятию "08.05 Тестирование Roles"

## Подготовка к выполнению

1. Установите molecule: `pip3 install "molecule==3.4.0"`

В официальной документации настоятельно рекомендуется устанавливать молекулу в виртуальное окружнение, поэтому:

```bash
$ sudo apt install python3.8-venv
$ python3 -m venv ~/my_env
$ source my_env/bin/activate

(my_env)$ python3 -m pip install --upgrade setuptools
(my_env)$ python3 -m pip install "molecule[docker,lint]"
```

Инициализировал дефолтный сценарий в существующей роли.

```bash

$ molecule init scenario --role-name elasticsearch-role --driver-name docker
INFO     Initializing new scenario default...
INFO     Initialized scenario in /home/max/devops/netology-8.3-ansible-yandex/roles/elasticsearch-role/molecule/default successfully.
```

2. Соберите локальный образ на основе [Dockerfile](./Dockerfile)

## Основная часть

Наша основная цель - настроить тестирование наших ролей. Задача: сделать сценарии тестирования для kibana, logstash. Ожидаемый результат: все сценарии успешно проходят тестирование ролей.

### Molecule

1. Запустите  `molecule test` внутри корневой директории elasticsearch-role, посмотрите на вывод команды.

Запустил дефолтный сценарий:

```bash
$ molecule test
TASK [elasticsearch-role : Download Elasticsearch's rpm] ***********************
FAILED - RETRYING: Download Elasticsearch's rpm (3 retries left).
FAILED - RETRYING: Download Elasticsearch's rpm (2 retries left).
FAILED - RETRYING: Download Elasticsearch's rpm (1 retries left).
fatal: [instance -> localhost]: FAILED! => {"attempts": 3, "changed": false, "checksum_dest": null, "checksum_src": "fe688cd2e3fa0f084fa12cc643be4acdcd23ac62", "dest": "files/elasticsearch-7.14.0-x86_64.rpm", "elapsed": 49, "msg": "Destination files does not exist", "src": "/home/max/.ansible/tmp/ansible-tmp-1639051087.662048-39320-253526503292800/tmp_n2zgdli", "url": "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.14.0-x86_64.rpm"}
```

Установочные файлы не скачиваются, т.к. отсутствует папка `roles/elasticsearch-role/molecule/default/files`. После создания директории для загрузки файлов при прогоне роли получаю такую ошибку:

```bash
TASK [elasticsearch-role : include_tasks] **************************************
fatal: [instance]: FAILED! => {"reason": "Could not find or access '/home/max/devops/netology-8.3-ansible-yandex/roles/elasticsearch-role/molecule/default/download_dnf.yml' on the Ansible Controller."}
```

Из описания видно, что не найден файл `download_dnf`, что логично, т.к. в роли есть варианты установки для менеджеров пакетов `apt` и `yum`, а в прописанном в дефолтном сценарии `centos:8` используется менеджер пакетов `dnf`.

2. Перейдите в каталог с ролью kibana-role и создайте сценарий тестирования по умолчаню при помощи `molecule init scenario --driver-name docker`.

```bash
$ molecule init scenario --driver-name docker
INFO     Initializing new scenario default...
INFO     Initialized scenario in /home/max/devops/netology-8.3-ansible-yandex/roles/kibana-role/molecule/default successfully.
```

3. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.

Добавил дополнительные платформы для тестирования. Для выполнения роли на centos 8 добавил файлы таски `download_dnf`, `install_dnf`.

```yml
# roles/kibana-role/molecule/default/molecule.yml
---
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
# инстанс для эластика
  - name: el-instance
    groups: 
      - elasticsearch
    image: docker.io/pycontribs/centos:7
    pre_build_image: true
# инстансы для тестирования роли кибаны
  - name: centos7
    groups: 
      - kibana
    image: docker.io/pycontribs/centos:7
    pre_build_image: true
  - name: centos8
    groups: 
      - kibana
    image: docker.io/pycontribs/centos:8
    pre_build_image: true
  - name: ubuntu
    groups: 
      - kibana
    image: docker.io/pycontribs/ubuntu:latest
    pre_build_image: true
provisioner:
  name: ansible
verifier:
  name: ansible

# roles/kibana-role/tasks/install_dnf.yml
# для установки требуется GPG ключ
---
- name: Download GPG-KEY
  become: true
  command: 
    cmd: "rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch"
  changed_when: false

- name: Install Kibana
  become: true
  dnf:
    name: "/tmp/kibana-{{ kibana_version }}-x86_64.rpm"
    state: present
  notify: restart Kibana
```

После этого выполнил 

```bash
$ molecule test

PLAY RECAP *********************************************************************
centos7                    : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
centos8                    : ok=8    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
el-instance                : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
ubuntu                     : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

4. Добавьте несколько assert'ов в verify.yml файл, для  проверки работоспособности kibana-role (проверка, что web отвечает, проверка логов, etc). Запустите тестирование роли повторно и проверьте, что оно прошло успешно.

```yml
  tasks:
  - name: Verify kibana http
    assert:
      uri:
        url: http://localhost:5601
```

5. Повторите шаги 2-4 для filebeat-role.

6. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

### Tox

1. Запустите `docker run --privileged=True -v <path_to_repo>:/opt/elasticsearch-role -w /opt/elasticsearch-role -it <image_name> /bin/bash`, где path_to_repo - путь до корня репозитория с elasticsearch-role на вашей файловой системе.
2. Внутри контейнера выполните команду `tox`, посмотрите на вывод.
3. Добавьте файл `tox.ini` в корень репозитория каждой своей роли.
4. Создайте облегчённый сценарий для `molecule`. Проверьте его на исполнимость.
5. Пропишите правильную команду в `tox.ini` для того чтобы запускался облегчённый сценарий.
6. Запустите `docker` контейнер так, чтобы внутри оказались обе ваши роли.
7. Зайдти поочерёдно в каждую из них и запустите команду `tox`. Убедитесь, что всё отработало успешно.
8. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

После выполнения у вас должно получится два сценария molecule и один tox.ini файл в каждом репозитории. Ссылки на репозитории являются ответами на домашнее задание. Не забудьте указать в ответе теги решений Tox и Molecule заданий.

## Необязательная часть

1. Проделайте схожие манипуляции для создания роли logstash.
2. Создайте дополнительный набор tasks, который позволяет обновлять стек ELK.
3. В ролях добавьте тестирование в раздел `verify.yml`. Данный раздел должен проверять, что logstash через команду `logstash -e 'input { stdin { } } output { stdout {} }'`  отвечает адекватно.
4. Создайте сценарий внутри любой из своих ролей, который умеет поднимать весь стек при помощи всех ролей.
5. Убедитесь в работоспособности своего стека. Создайте отдельный verify.yml, который будет проверять работоспособность интеграции всех инструментов между ними.
6. Выложите свои roles в репозитории. В ответ приведите ссылки.

---
