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

Отключил сборщики на мастере. Создал новый узел `agent-01`, прописал корень удаленной ФС так же как в плейбуке: `/opt/jenkins_agent/`, метки: `docker ansible python3`. Способ запуска: через выполнение команды `ssh 62.84.112.172 java -jar /opt/jenkins_agent/agent.jar` (IP созданного ранее хоста jenkins-agent).

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
`
Item -> Freestyle Job `Molecule_run_FJ`. Label `ansible`.
- Управление исходным кодом `Git`. 
- Credentials -> Add `git@github.com:maxship/kibana-role.git`. 
- Branch Specifier `*/main`.
- Additional Behaviours `Check out for sub-directory`: `kibana-role`.
Сборка -> Выполнить команду shell:

  ```sh
  cd kibana-role
  mkdir molecule/default/files
  pip3 install -r test-requirements.txt
  molecule test
  ```
Сам файл `test-requirements.txt` лежит в корне репозитория, и содержит список того, что требуется установить в среду:

```
molecule==3.4.0
molecule_docker==0.3.3
ansible<3
docker
selinux
ansible-lint
yamllint
```

При загрузке зависимых ролей galaxy возникла ошибка с правами доступа:

```sh
Starting galaxy role install process
[WARNING]: - elasticsearch-role was NOT installed successfully: - command
/usr/bin/git clone git@github.com:netology-code/mnt-homeworks-ansible.git
elasticsearch-role failed in directory /home/jenkins/.ansible/tmp/ansible-
local-14774x542qgpg/tmprt3or9pc (rc=128) - Permission denied (publickey).
fatal: Could not read from remote repository.  Please make sure you have the
correct access rights and the repository exists.
```
Установил плагин SSH-agent, пробрасывающий ключ из credentials в проект, установил в настройках среды разработки соответствующий чекбокс.

После этого запустил сборку, все отработало успешно:

```
PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Pruning extra files from scenario ephemeral directory
$ ssh-agent -k
unset SSH_AUTH_SOCK;
unset SSH_AGENT_PID;
echo Agent pid 9472 killed;
[ssh-agent] Stopped.
Finished: SUCCESS
```

2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.

Создал Item -> Pipeline `Molecule_run_DP`.
Добавил pipeline script с использованием генератора синтаксиса `Pipeline Syntax -> Snippet Generator / Declarative Directive Generator`.

Как пробросить ключи из credentials через плагин sshagent в скрипте я не разобрался (нужны для загрузки galaxy ролей). Просто добавил публичный ключ агента в гитхаб.

```yml
pipeline {
    agent {
        label 'ansible'
    }
    stages {
        stage('Cleanup'){
            steps{
                cleanWs()
            }
        }
        stage ('Get chekout'){
            steps {
                 ws('kibana-role') { // новая рабочая директория для нашей роли
                    git branch: 'main', credentialsId: '56d713a4-f66a-47e6-a4bd-7191559e1587', url: 'git@github.com:maxship/kibana-role.git'
                 }
            }
        }
        stage ('Install requiments'){
            steps {
                ws('kibana-role') {
                    sh "pip3 install -r test-requirements.txt"
                }
            }
        }
        stage ('molecule test'){
            steps {
                ws('kibana-role') {
                    sh 'mkdir molecule/default/files'
                    sh 'molecule test'
                }
            }
        }
    }
}
```

```
PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Pruning extra files from scenario ephemeral directory
[Pipeline] }
[Pipeline] // ws
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS
```

3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.

Скопировал скрипт с предыдущего шага в созданный `Jenkinsfile`в корневой директории репозитория с ролью.

4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.

Создал Item -> Multibranch Pipeline `Molecule_run_MP`. Указал путь к репозиторию и файлу со скриптом. 

```
Scheduled build for branch: jenkins-multibranch-test
Processed 2 branches
[Sat Jan 08 11:57:09 UTC 2022] Finished branch indexing. Indexing took 7.3 sec
Finished: SUCCESS
```

5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).



6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True), по умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.



7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`. Цель: получить собранный стек ELK в Ya.Cloud.

 

8. Отправить две ссылки на репозитории в ответе: с ролью и Declarative Pipeline и c плейбукой и Scripted Pipeline.

### [https://github.com/maxship/kibana-role/tree/main](https://github.com/maxship/kibana-role/tree/main) - Declarative Pipeline

### [https://github.com/maxship/devops-netology/tree/main/09.04-cicd-jenkins](https://github.com/maxship/devops-netology/tree/main/09.04-cicd-jenkins) - Scripted Pipeline

## Необязательная часть

1. Создать скрипт на groovy, который будет собирать все Job, которые завершились хотя бы раз неуспешно. Добавить скрипт в репозиторий с решеним с названием `AllJobFailure.groovy`.
2. Дополнить Scripted Pipeline таким образом, чтобы он мог сначала запустить через Ya.Cloud CLI необходимое количество инстансов, прописать их в инвентори плейбука и после этого запускать плейбук. Тем самым, мы должны по нажатию кнопки получить готовую к использованию систему.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
