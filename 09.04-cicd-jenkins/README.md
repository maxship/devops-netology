# Домашнее задание к занятию "09.04 Jenkins"

## Подготовка к выполнению

1. Создать 2 VM: для jenkins-master и jenkins-agent.

Запустил 2 инстанса с помощью терраформа. 

```bash
$ terraform apply
...
Outputs:

external_ip_jenkins_agent = "62.84.127.93"
external_ip_jenkins_master = "62.84.125.20"
```
Подключение по ssh с помощью блока

```tf
  metadata = {
    # user-data = "${file("./meta.txt")}"
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }  
```
Проверил подключение для дефолтного пользователя `$ ssh centos@62.84.125.20`.

2. Установить jenkins при помощи playbook'a.

```yml
# 09.04-cicd-jenkins/infrastructure/inventory/cicd/hosts.yml
---
all:
  hosts:
    jenkins-master-01:
      ansible_host: 62.84.125.20
    jenkins-agent-01:
      ansible_host: 62.84.127.93
  children:
    jenkins:
      children:
        jenkins_masters:
          hosts:
            jenkins-master-01:
        jenkins_agents:
          hosts:
              jenkins-agent-01:
  vars:
    ansible_connection_type: paramiko
    ansible_user: centos
```

```bash
$ ansible-playbook -i inventory/cicd/ site.yml
...
PLAY RECAP ******************************************************************************************************************************************************************************************
jenkins-agent-01           : ok=17   changed=14   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
jenkins-master-01          : ok=11   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

3. Запустить и проверить работоспособность.

Зашел по адресу `http://62.84.125.20:80" и ввел пароль администратора.
```
$ ssh centos@62.84.125.20
[centos@fhm2121v9o1vutidp4c2 ~]$ sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

4. Сделать первоначальную настройку.

Отключил сборщики на мастере. Создал новый узел `agent-01`, прописал корень удаленной ФС как в плейбуке: `/opt/jenkins_agent/`, метки: `docker ansible python3`. Способ запуска: через выполнение команды `ssh 62.84.112.172 java -jar /opt/jenkins_agent/agent.jar` (IP созданного ранее хоста jenkins-agent).

Смотрим логи:

```
[01/03/22 17:56:30] Launching agent
$ ssh 62.84.112.172 java -jar /opt/jenkins_agent/agent.jar
<===[JENKINS REMOTING CAPACITY]===>channel started
Remoting version: 4.11.2
This is a Unix agent
WARNING: An illegal reflective access operation has occurred
WARNING: Illegal reflective access by jenkins.slaves.StandardOutputSwapper$ChannelSwapper to constructor java.io.FileDescriptor(int)
WARNING: Please consider reporting this to the maintainers of jenkins.slaves.StandardOutputSwapper$ChannelSwapper
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
Evacuated stdout
Agent successfully connected and online
```
## Основная часть

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.



2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.



3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.



4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.



5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).



6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True), по умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.



7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`. Цель: получить собранный стек ELK в Ya.Cloud.

 

8. Отправить две ссылки на репозитории в ответе: с ролью и Declarative Pipeline и c плейбукой и Scripted Pipeline.

## Необязательная часть

1. Создать скрипт на groovy, который будет собирать все Job, которые завершились хотя бы раз неуспешно. Добавить скрипт в репозиторий с решеним с названием `AllJobFailure.groovy`.
2. Дополнить Scripted Pipeline таким образом, чтобы он мог сначала запустить через Ya.Cloud CLI необходимое количество инстансов, прописать их в инвентори плейбука и после этого запускать плейбук. Тем самым, мы должны по нажатию кнопки получить готовую к использованию систему.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
