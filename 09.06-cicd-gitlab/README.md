# Домашнее задание к занятию "09.06 Gitlab"

## Подготовка к выполнению

1. Необходимо [зарегистрироваться](https://about.gitlab.com/free-trial/)
2. Создайте свой новый проект
3. Создайте новый репозиторий в gitlab, наполните его [файлами](./repository)
4. Проект должен быть публичным, остальные настройки по желанию

### [https://gitlab.com/maxship/netology-cicd](https://gitlab.com/maxship/netology-cicd)

## Основная часть

### DevOps

В репозитории содержится код проекта на python. Проект - RESTful API сервис. Ваша задача автоматизировать сборку образа с выполнением python-скрипта:
1. Образ собирается на основе [centos:7](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated)
2. Python версии не ниже 3.7
3. Установлены зависимости: `flask` `flask-jsonpify` `flask-restful`
4. Создана директория `/python_api`
5. Скрипт из репозитория размещён в /python_api
6. Точка вызова: запуск скрипта
7. Если сборка происходит на ветке `master`: Образ должен пушится в docker registry вашего gitlab `python-api:latest`, иначе этот шаг нужно пропустить

---

Создал докерфайл:

```dockerfile
FROM centos:7

RUN yum install python3 python3-pip -y
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY python-api.py /python_api/python-api.py
CMD ["python3", "/python_api/python-api.py"]
```

Необходимые библиотеки прописаны в `requirements.txt`:

```
flask
flask-restful
flask_jsonpify
```

Создал файл `.gitlab-ci.yml`:

```yml
stages:
    - build
    #- test
    - deploy
image: docker:20.10.12
services:
    - docker:20.10.12-dind
builder:
    stage: build
    script:
        - docker build -t local_build:latest .
    except:
        - main
deployer:
    stage: deploy
    script:
        - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
        - docker build -t $CI_REGISTRY/maxship/netology-9.6-cicd-gitlab/python-api:latest .
        - docker push $CI_REGISTRY/maxship/netology-9.6-cicd-gitlab/python-api:latest
    only: 
        - main
```

Все изменения залиты в ветку `main`, сборка завершена успешно, созданный образ появился в хранилище.

![961](https://user-images.githubusercontent.com/72273610/149295446-b0c364f8-31a5-4b90-b7a5-baae13b745f0.png)

![962](https://user-images.githubusercontent.com/72273610/149295459-4535c7f9-a2eb-4b0b-9920-3cd1fe3df31f.png)


### Product Owner

Вашему проекту нужна бизнесовая доработка: необходимо поменять JSON ответа на вызов метода GET `/rest/api/get_info`, необходимо создать Issue в котором указать:
1. Какой метод необходимо исправить
2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`
3. Issue поставить label: feature

---

![963](https://user-images.githubusercontent.com/72273610/149296421-32cae229-8a35-4a1f-a7b4-939c310b04fc.png)

### Developer

Вам пришел новый Issue на доработку, вам необходимо:
1. Создать отдельную ветку, связанную с этим issue
2. Внести изменения по тексту из задания
3. Подготовить Merge Requst, влить необходимые изменения в `master`, проверить, что сборка прошла успешно

---

Заходим в созданную задачу, меняем сообщение в новой ветке.

![964](https://user-images.githubusercontent.com/72273610/149297696-ac41b700-c3c5-428f-8dda-2bc56a16e9f3.png)

![965](https://user-images.githubusercontent.com/72273610/149297705-03754b41-91b3-47cc-b361-aec824129051.png)

```python
from flask import Flask, request
from flask_restful import Resource, Api
from json import dumps
from flask_jsonpify import jsonify

app = Flask(__name__)
api = Api(app)

class Info(Resource):
    def get(self):
        return {'version': 3, 'method': 'GET', 'message': 'Running'}

api.add_resource(Info, '/get_info')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port='5290')
```

После внесения изменений и успешной сборки, ставим пометку о закрытии issue и мержим в ветку `main`.

![966](https://user-images.githubusercontent.com/72273610/149298444-769ede16-ed01-4247-beb3-ac0b25021f60.png)

![967](https://user-images.githubusercontent.com/72273610/149298867-1a082be1-fb98-449e-82cf-dd56677667d0.png)

![968](https://user-images.githubusercontent.com/72273610/149299239-47bee559-1d08-4095-96cf-b6569e4b5ab6.png)

![969](https://user-images.githubusercontent.com/72273610/149299388-b59d48a5-fb84-4c22-a4a0-8047da8b577e.png)

![9610](https://user-images.githubusercontent.com/72273610/149299400-99f262da-4635-43b3-b631-3ef97ed7ef74.png)


### Tester

Разработчики выполнили новый Issue, необходимо проверить валидность изменений:
1. Поднять докер-контейнер с образом `python-api:latest` и проверить возврат метода на корректность
2. Закрыть Issue с комментарием об успешности прохождения, указав желаемый результат и фактически достигнутый

---

Запустил контейнер на локальной машине, проверил возврат метода, все работает корректно:

```sh
$ docker run --rm -dt --name test-api -p 5290:5290 registry.gitlab.com/maxship/netology-9.6-cicd-gitlab/python-api:latest
e998055163e7d595954896dfe1f2458c79efa3c71683d4365d2f7bc73e1496d3
$ curl localhost:5290/get_info
{"version": 3, "method": "GET", "message": "Running"}
```

## Итог

### Ссылка на проект Gitlab: 
### [https://gitlab.com/maxship/netology-9.6-cicd-gitlab](https://gitlab.com/maxship/netology-9.6-cicd-gitlab)

## Необязательная часть

Автомазируйте работу тестировщика, пусть у вас будет отдельный конвейер, который автоматически поднимает контейнер и выполняет проверку, например, при помощи curl. На основе вывода - будет приниматься решение об успешности прохождения тестирования

---
