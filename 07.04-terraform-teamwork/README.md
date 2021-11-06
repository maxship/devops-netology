# Домашнее задание к занятию "7.4. Средства командной работы над инфраструктурой."

## Задача 1. Настроить terraform cloud (необязательно, но крайне желательно).

В это задании предлагается познакомиться со средством командой работы над инфраструктурой предоставляемым
разработчиками терраформа. 

1. Зарегистрируйтесь на [https://app.terraform.io/](https://app.terraform.io/).
(регистрация бесплатная и не требует использования платежных инструментов).
1. Создайте в своем github аккаунте (или другом хранилище репозиториев) отдельный репозиторий с
 конфигурационными файлами прошлых занятий (или воспользуйтесь любым простым конфигом).
1. Зарегистрируйте этот репозиторий в [https://app.terraform.io/](https://app.terraform.io/).
1. Выполните plan и apply. 

В качестве результата задания приложите снимок экрана с успешным применением конфигурации.

___

![Screenshot from 2021-11-02 02-31-25](https://user-images.githubusercontent.com/72273610/139738107-35697522-a0ad-4645-8e69-805e077ac943.png)


## Задача 2. Написать серверный конфиг для атлантиса. 

Смысл задания – познакомиться с документацией 
о [серверной](https://www.runatlantis.io/docs/server-side-repo-config.html) конфигурации и конфигурации уровня 
 [репозитория](https://www.runatlantis.io/docs/repo-level-atlantis-yaml.html).

Создай `server.yaml` который скажет атлантису:
1. Укажите, что атлантис должен работать только для репозиториев в вашем github (или любом другом) аккаунте.
1. На стороне клиентского конфига разрешите изменять `workflow`, то есть для каждого репозитория можно 
будет указать свои дополнительные команды. 
1. В `workflow` используемом по-умолчанию сделайте так, что бы во время планирования не происходил `lock` состояния.

Создай `atlantis.yaml` который, если поместить в корень terraform проекта, скажет атлантису:
1. Надо запускать планирование и аплай для двух воркспейсов `stage` и `prod`.
1. Необходимо включить автопланирование при изменении любых файлов `*.tf`.

В качестве результата приложите ссылку на файлы `server.yaml` и `atlantis.yaml`.

---
Заходим в гитхаб, генерируем токен для входа.
Скачиваем и запускаем локальную версию атлантиса [https://github.com/runatlantis/atlantis/releases](https://github.com/runatlantis/atlantis/releases).
Атлантис мог работать с репозиторием, воспользуемся утилитой утилитой `ngrok` .

Зарегистрировавшись и сгенерировав рандомный адрес, запустим `ngrok`
```shell
ngrok http 4141
```
Полученный адрес записываем в файл серверного конфига `config.yaml`. Этот файл не обязателен - параметры можно задать переменными среды или непосредственно в консоли при запуске сервера.
Туда же вводим токен гитхаба, секретный ключ для вебхука, имя пользователя гитхаба и путь к файлу настроек репозиториев `server.yaml`.


```shell
gh-user: "maxship"
atlantis-url: "https://6b49-92-124-135-190.ngrok.io"
gh-token: {my-token}
gh-webhook-secret: "oR1Og9YbF3RoexyvVbUkCAft1"
repo-allowlist: "github.com/maxship/terraform-teamwork-example"
repo-config:  "/home/max/devops/terraform-teamwork-example/server.yaml"
```
Добавляем в тестовый репозиторий гитхаба вебхук `https://6b49-92-124-135-190.ngrok.io`. Content type: application/json. Let me select individual events: Issue comments, PR, PR reviews, Pushes.

Атлантис запущен в тестовом режиме - нужно помнить, что сгенерированный `ngrok` адрес будет работать только в текущей сессиии.

Задаем необходимые для авторизации в AWS переменные среды.

```shell
export AWS_ACCESS_KEY_ID={my_key_id}
export AWS_SECRET_ACCESS_KEY={my_key}
```
Создаем файл настроек репозиториев на сервере.

```yaml
# server.yml
# указываем репозиторий, разрешаем менять параметр workfflow (можно добавлять пользовательские команды)
repos:
- id: github.com/maxship/terraform-teamwork-example
  allowed_overrides: [workflow]

# В workflow используемом по-умолчанию, делаем так, что бы во время планирования не происходил `lock` состояния.
workflows:
  default:
    plan:
      steps:
      - init:
          extra_args: ["-lock=false"]
      - plan:
          extra_args: ["-lock=false"]
    apply:
      steps: [apply]
```
В корень тестового репозитория добавляем файл `atlantis.yaml`.

```yaml
# Включаем автоплан для обоих воркспейсов при изменении файлов .tf
version: 3
projects:
- dir: .
  workspace: stage
  autoplan:
    when_modified: [ "*.tf" ]
    enabled: true
- dir: .
  workspace: prod
  autoplan:
    when_modified: [ "*.tf" ]
    enabled: true
```

Запускаем атлантис.

```shell
$ atlantis server --config /home/max/devops/terraform-teamwork-example/config.yaml
```
Делаем pull_request.


![pull_request](https://user-images.githubusercontent.com/72273610/140607021-bc95c1a5-9426-458c-bb50-5814f603b4b5.png)



## Задача 3. Знакомство с каталогом модулей. 

1. В [каталоге модулей](https://registry.terraform.io/browse/modules) найдите официальный модуль от aws для создания
`ec2` инстансов. 
2. Изучите как устроен модуль. Задумайтесь, будете ли в своем проекте использовать этот модуль или непосредственно 
ресурс `aws_instance` без помощи модуля?
3. В рамках предпоследнего задания был создан ec2 при помощи ресурса `aws_instance`. 
Создайте аналогичный инстанс при помощи найденного модуля.   

В качестве результата задания приложите ссылку на созданный блок конфигураций. 

---
