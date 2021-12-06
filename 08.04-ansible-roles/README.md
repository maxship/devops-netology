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


5. Перенести нужные шаблоны конфигов в `templates`.


6. Создать новый каталог с ролью при помощи `ansible-galaxy role init filebeat-role`.


7. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`. 


8. Перенести нужные шаблоны конфигов в `templates`.


9. Описать в `README.md` обе роли и их параметры.


10. Выложите все roles в репозитории. Проставьте тэги, используя семантическую нумерацию.


11. Добавьте roles в `requirements.yml` в playbook.


12. Переработайте playbook на использование roles.


13. Выложите playbook в репозиторий.


14. В ответ приведите ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.

## Необязательная часть

1. Проделайте схожие манипуляции для создания роли logstash.
2. Создайте дополнительный набор tasks, который позволяет обновлять стек ELK.
3. Убедитесь в работоспособности своего стека: установите logstash на свой хост с elasticsearch, настройте конфиги logstash и filebeat так, чтобы они взаимодействовали друг с другом и elasticsearch корректно.
4. Выложите logstash-role в репозиторий. В ответ приведите ссылку.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---