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

```bash
$ docker login https://registry.redhat.io
Username: maxship
Password: 

$ docker build -t podman:test_env -f Dockerfile .

```

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
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  # инстанс с эластиком (необходим для работы кибаны)
  - name: el-instance
    groups: 
      - elasticsearch
    image: docker.io/pycontribs/centos:7
    pre_build_image: true
    command: /usr/sbin/init
    privileged: true
  # платформы для тестирования роли
  - name: centos7
    groups: 
      - kibana
    image: docker.io/pycontribs/centos:7
    pre_build_image: true
    command: /usr/sbin/init
    privileged: true
  - name: centos8
    groups: 
      - kibana
    image: docker.io/pycontribs/centos:8
    pre_build_image: true
    command: /usr/sbin/init
    privileged: true  
  - name: ubuntu
    groups: 
      - kibana
    image: docker.io/pycontribs/ubuntu:latest
    pre_build_image: true
provisioner:
  name: ansible
verifier:
  name: ansible

# roles/kibana-role/molecule/default/converge.yml
---
- name: Elastic role
  hosts: elasticsearch
  tasks:
    - name: "Include elasticsearch-role"
      include_role:
        name: "elasticsearch-role"       
- name: kibana role
  hosts: kibana
  tasks:
    - name: "Include kibana-role"
      include_role:
        name: "kibana-role"

# roles/kibana-role/tasks/download_dnf.yml
---
- name: "Download Kibana's rpm"
  get_url:
    url: "https://artifacts.elastic.co/downloads/kibana/kibana-{{ kibana_version }}-x86_64.rpm"
    dest: "files/kibana-{{ kibana_version }}-x86_64.rpm"
  register: download_kibana
  delegate_to: localhost
  until: download_kibana is succeeded
  when: kibana_install_type == 'remote'

- name: Copy Kibana to managed node
  copy:
    src: "files/kibana-{{ kibana_version }}-x86_64.rpm"
    mode: 0755
    dest: "/tmp/kibana-{{ kibana_version }}-x86_64.rpm"

# roles/kibana-role/tasks/install_dnf.yml
---
# для установки требуется GPG ключ
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

После этого выполнил `molecule test`

```bash
$ molecule test

PLAY RECAP *********************************************************************
centos7                    : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
centos8                    : ok=8    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
el-instance                : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
ubuntu                     : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

4. Добавьте несколько assert'ов в verify.yml файл, для  проверки работоспособности kibana-role (проверка, что web отвечает, проверка логов, etc). Запустите тестирование роли повторно и проверьте, что оно прошло успешно.

Добавил проверку на прослушивание порта 5601 и наличие лог-файла.

```yml
# roles/kibana-role/molecule/default/verify.yml
- name: Verify
  hosts: kibana
  gather_facts: false
  tasks:
  - name: Wait for Kibana port is listening
    wait_for:
      port: 5601
      state: started
      timeout: 60
      msg: "Port 5601 wasn't opened"
  - name: Wait for Kibana log file created
    wait_for:
      path: /var/lib/kibana/
      state: present
      timeout: 60
      msg: "Kibana log file wasn't created"
```

При тестировании на докер-контейнерах были проблемы с запуском сервисов. Долго не мог понять что именно нужно сделать, чтобы запустить сервисы, в итоге добавил следующие блоки кода, после которых все заработало:

```yml
# roles/kibana-role/tasks/configure.yml
---
- name: Enable Kibana service
  become: true
  service:
    name: kibana
    state: started
    enabled: yes

# roles/kibana-role/molecule/default/molecule.yml
# для всех инстансов кроме ubuntu
---
    command: /usr/sbin/init
    privileged: true
```
```sh
$ molecule test
...
PLAY [Verify] ******************************************************************

TASK [Wait for Kibana port is listening] ***************************************
ok: [centos7]
ok: [centos8]
ok: [ubuntu]

TASK [Wait for Kibana log file created] ****************************************
ok: [centos7]
ok: [centos8]
ok: [ubuntu]

PLAY RECAP *********************************************************************
centos7                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
centos8                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

5. Повторите шаги 2-4 для filebeat-role.

Проделал все то же самое для роли filebeat.

```bash
$ molecule test
...
PLAY RECAP *********************************************************************
centos7                    : ok=9    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
centos8                    : ok=10   changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
el-instance                : ok=7    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
kibana-instance            : ok=8    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
ubuntu                     : ok=9    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Idempotence completed successfully.
INFO     Running default > side_effect
WARNING  Skipping, side effect playbook not configured.
INFO     Running default > verify
INFO     Running Ansible Verifier

PLAY [Verify] ******************************************************************

TASK [Wait for Filebeat log file created] **************************************
ok: [centos7]
ok: [centos8]
ok: [ubuntu]

```

6. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

```bash
 $ git tag -a 1.0.1 -m "molecule test"

 $ git log --pretty=oneline
1a7bbfea3516e6dfb006759d2661fee4a8e57ebf (HEAD -> main, tag: 1.0.1, origin/main, origin/HEAD) molecule test success
4e1de86d0e5352372ce07212d4b66b8a08047139 8.5 started: molecule added; centos8 support
f0a9d2b2e8af4bd78c3ddf59aefea5dea89b26b7 (tag: 1.0.0) role created
5dc62bfbf3bcc5a74523832712128fe6f73fca78 role created
ce7882958649248fe9e2b623dded13ff5b3053ed Initial commit

$ git push --tags
```
### Tox

1. Запустите `docker run --rm --privileged=True -v <path_to_repo>:/opt/elasticsearch-role -w /opt/elasticsearch-role -it <image_name> /bin/bash`, где path_to_repo - путь до корня репозитория с elasticsearch-role на вашей файловой системе.

```
$ docker run --rm --privileged=True \
-v /home/maxship/devops/netology-8.3-ansible-yandex/roles/elasticsearch-role:/opt/elasticsearch-role \
-w /opt/elasticsearch-role \
-it podman:test_env /bin/bash
```

2. Внутри контейнера выполните команду `tox`, посмотрите на вывод.


3. Добавьте файл `tox.ini` в корень репозитория каждой своей роли.

```ini
# roles/kibana-role/tox.ini
[tox]
minversion = 1.8
basepython = python3.6
envlist = py{36,39}-ansible{28,30}
skipsdist = true

[testenv]
deps =
    -rtox-requirements.txt
    ansible28: ansible<2.9
    ansible29: ansible<2.10
    ansible210: ansible<3.0
    ansible30: ansible<3.1
commands =
    {posargs:molecule test -s tox}
```

4. Создайте облегчённый сценарий для `molecule`. Проверьте его на исполнимость.

```yml
# roles/kibana-role/molecule/tox/molecule.yml
---
dependency:
  name: galaxy
driver:
  name: podman
platforms:
- name: el-instance
  groups: 
  - elasticsearch
  image: docker.io/pycontribs/centos:7
  pre_build_image: true
  command: /usr/sbin/init
  privileged: true
- name: centos7
  groups: 
    - kibana
  image: docker.io/pycontribs/centos:7
  pre_build_image: true
  command: /usr/sbin/init
  privileged: true

provisioner:
  name: ansible
verifier:
  name: ansible
scenario:
  test_sequence:
    - destroy
    - create
    - converge
    - destroy
```

5. Пропишите правильную команду в `tox.ini` для того чтобы запускался облегчённый сценарий.

```ini
commands =
    {posargs:molecule test -s tox}
```

6. Запустите `docker` контейнер так, чтобы внутри оказались обе ваши роли. 

Дополнительно подключил директорию с ssh ключами для закачки ролей с гитхаба.

```sh
$ docker run --rm --privileged=True \
-v /home/maxship/devops/netology-8.3-ansible-yandex/roles/kibana-role:/opt/kibana-role \
-v /home/maxship/devops/netology-8.3-ansible-yandex/roles/filebeat-role:/opt/filebeat-role \
-v /home/maxship/.ssh:/root/.ssh \
-w /opt/kibana-role \
-it podman:test_env /bin/bash
```

7. Зайти поочерёдно в каждую из них и запустите команду `tox`. Убедитесь, что всё отработало успешно.

При запуске `tox` вылезла ошибка во время загрузки зависимостей (отсутствует git). Чтобы не пересобирать образ, установил вручную:

```
$ yum update -y
$ yum install git -y
```

```bash
[root@09a450db78c4 kibana-role]$ tox
py36-ansible28 create: /opt/kibana-role/.tox/py36-ansible28
py36-ansible28 installdeps: -rtox-requirements.txt, ansible<2.9
...
```

8. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

После выполнения у вас должно получится два сценария molecule и один tox.ini файл в каждом репозитории. Ссылки на репозитории являются ответами на домашнее задание. Не забудьте указать в ответе теги решений Tox и Molecule заданий.

---

Ссылки на теги со сценариями `molecule`:

### [https://github.com/maxship/kibana-role/tree/1.0.1](https://github.com/maxship/kibana-role/tree/1.0.1)
### [https://github.com/maxship/filebeat-role/tree/1.0.1](https://github.com/maxship/filebeat-role/tree/1.0.1)

Ссылки на теги со сценариями `tox`:

### [https://github.com/maxship/kibana-role/tree/1.0.3](https://github.com/maxship/kibana-role/tree/1.0.3)

### [https://github.com/maxship/filebeat-role/tree/1.0.2](https://github.com/maxship/filebeat-role/tree/1.0.2)

---


## Необязательная часть

1. Проделайте схожие манипуляции для создания роли logstash.
2. Создайте дополнительный набор tasks, который позволяет обновлять стек ELK.
3. В ролях добавьте тестирование в раздел `verify.yml`. Данный раздел должен проверять, что logstash через команду `logstash -e 'input { stdin { } } output { stdout {} }'`  отвечает адекватно.
4. Создайте сценарий внутри любой из своих ролей, который умеет поднимать весь стек при помощи всех ролей.
5. Убедитесь в работоспособности своего стека. Создайте отдельный verify.yml, который будет проверять работоспособность интеграции всех инструментов между ними.
6. Выложите свои roles в репозитории. В ответ приведите ссылки.


