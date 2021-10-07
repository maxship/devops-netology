# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

---


Докерфайл:
```dockerfile
FROM centos:7

WORKDIR /

# устанавливаем ПО, необходимое для установки
RUN yum -y install wget && \
    yum -y install perl-Digest-SHA

# из под рута ES не работает, поэтому создаем нового пользователя
RUN groupadd -g 1000 elasticsearch && \
    useradd elasticsearch -u 1000 -g 1000

# загружаем и устанавливаем ES 
ADD https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.0-linux-x86_64.tar.gz .
ADD https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.0-linux-x86_64.tar.gz.sha512 .

RUN shasum -a 512 -c elasticsearch-7.15.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-7.15.0-linux-x86_64.tar.gz && \
    cd elasticsearch-7.15.0/

# создаем отдельную директорию для данных БД
RUN mkdir /var/lib/elasticsearch

# добавляем предварительно настроенный файл конфига
COPY elasticsearch.yml elasticsearch-7.15.0/config/

# назначаем права
RUN chown -R elasticsearch:elasticsearch /elasticsearch-7.15.0/ && \
    chown -R elasticsearch:elasticsearch /var/lib/elasticsearch

USER elasticsearch

ENV PATH=$PATH:/elasticsearch-7.15.0/bin

EXPOSE 9200 9300

ENTRYPOINT ["elasticsearch"]
```

При первых попытках запуска elasticsearch выдавал ошибки, для устранения которых потребовалось изменить настройки виртуальной машины и elasticsearch.yml.
```shell
vagrant@vagrant:~$ sudo sysctl -w vm.max_map_count=262144
vm.max_map_count = 262144
```
```yml
cluster.name: "es-cluster"
node.name: "netology_test"
network.host: 0.0.0.0
cluster.initial_master_nodes: netology_test
path.data: /var/lib/elasticsearch # директория для хранения данных
```

После этих исправлений собираем образ заново.
```shell
vagrant@vagrant:~/elastic$ docker build -t es:test1 -f elastic_df .
```

Пушим образ в репозиторий.
```shell
vagrant@vagrant:~/elastic/data$ docker tag es:test1 moshipitsyn/my_elasticsearch:latest
vagrant@vagrant:~/elastic/data$ docker push moshipitsyn/my_elasticsearch:latest
```

https://hub.docker.com/repository/docker/moshipitsyn/my_elasticsearch

Запускаем контейнер и цепляем к нему директорию с данными и файл конфига.
```shell
vagrant@vagrant:~/elastic$ docker run --rm -d -p 9200:9200 \
> -v "$(pwd)"/data:/var/lib/elasticsearch \
> -v "$(pwd)"/elasticsearch.yml:/elasticsearch-7.15.0/config/elasticsearch.yml \
> moshipitsyn/my_elasticsearch:latest
```

То же самое добавил для удобства в docker-compose:
```yml
version: '3.5'

services:

  es:
    container_name: elasticsearch
    image: moshipitsyn/my_elasticsearch:latest
    volumes:
      - ./data:/var/lib/elasticsearch
      - ./elasticsearch.yml:/elasticsearch-7.15.0/config/elasticsearch.yml
    ports:
      - "9200:9200"
      - "9300:9300"
    restart: unless-stopped
```

Тестим.
```shell
vagrant@vagrant:~$ curl -X GET http://localhost:9200/
{
  "name" : "netology_test",
  "cluster_name" : "es-cluster",
  "cluster_uuid" : "SdNb_NEHSd-djtQz2-sE3w",
  "version" : {
    "number" : "7.15.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "79d65f6e357953a5b3cbcc5e2c7c21073d89aa29",
    "build_date" : "2021-09-16T03:05:29.143308416Z",
    "build_snapshot" : false,
    "lucene_version" : "8.9.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```


## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

---

Добавляем индексы в соответствии с таблицей, выводим получившийся список.
```shell
vagrant@vagrant:~/elastic$ export ES_URL=localhost:9200

curl -H 'Content-Type: application/json' \
-XPUT $ES_URL/ind-1 -d \
'{"settings":{"number_of_shards":1,"number_of_replicas":0}}'

curl -H 'Content-Type: application/json' \
-XPUT $ES_URL/ind-2 -d \
'{"settings":{"number_of_shards":2,"number_of_replicas":1}}'

curl -H 'Content-Type: application/json' \
-XPUT $ES_URL/ind-3 -d \
'{"settings":{"number_of_shards":4,"number_of_replicas":2}}'

vagrant@vagrant:~/elastic$ curl -X GET "$ES_URL/_cat/indices?v"
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases zSVNlsuuSE2yxgwexog1Nw   1   0         41           34     40.1mb         40.1mb
green  open   ind-1            iZeYzE-wSQycBI53RR8dbw   1   0          0            0       208b           208b
yellow open   ind-3            J4LykfN9RoeB10aTkUMHUQ   4   2          0            0       832b           832b
yellow open   ind-2            0O7Tg81XQUikgA4C_SgVgw   2   1          0            0       416b           416b
```

```shell
vagrant@vagrant:~/elastic$ curl -X GET "$ES_URL/_cluster/health?pretty"
{
  "cluster_name" : "es-cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}

```
Видим, что состояние `green` только у первого индекса. У ind-2 и ind-3 статус `yellow`, что логично, т.к. в созданном ранее кластере всего одна нода с одним шардом, реплики отсутствуют.

Удаляем индексы.

```shell
vagrant@vagrant:~/elastic$ curl -X DELETE "$ES_URL/_all"
```

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

Заходим в контейнер и добавляем директорию для бэкапов.
```shell
vagrant@vagrant:~/elastic$ docker exec -ti elasticsearch bash

[elasticsearch@f87fae3dbebb /]$ mkdir /elasticsearch-7.15.0/snapshots
```
Добавляем путь в файл настроек.
```yml
cluster.name: "es-cluster"
node.name: "netology_test"
network.host: 0.0.0.0
cluster.initial_master_nodes: netology_test
path.data: /var/lib/elasticsearch
path.repo: /elasticsearch-7.15.0/snapshots # путь к бэкапам
```

Перезапускаем контейнер
```shell
vagrant@vagrant:~/elastic$ docker restart elasticsearch
```

Регистрируем репозиторий `snapshot_repository`, добавляем папку `netology_backup` в подключенную ранее директорию для бэкапов.
```shell
curl -H 'Content-Type: application/json' \
-X PUT "$ES_URL/_snapshot/snapshot_repository" -d \
'{"type": "fs", "settings": {"location": "/elasticsearch-7.15.0/snapshots/netology_backup"}}'
```

Создаем тестовый индекс.
```shell
curl -H 'Content-Type: application/json' \
-XPUT $ES_URL/test -d \
'{"settings":{"number_of_shards":1,"number_of_replicas":0}}'

vagrant@vagrant:~/elastic$ curl -X GET "$ES_URL/_cat/indices?v"
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases zSVNlsuuSE2yxgwexog1Nw   1   0         41           34     40.1mb         40.1mb
green  open   test             WF7k6XHbSEKWFlaYtxkd_A   1   0          0            0       208b           208b
```

Делаем снимок.
```shell
vagrant@vagrant:~/elastic$ curl -X PUT "$ES_URL/_snapshot/snapshot_repository/test_snapshot_1?wait_for_completion=true"
```

Смотрим список файлов.
```shell
vagrant@vagrant:~/elastic$ docker exec -ti elasticsearch bash

[elasticsearch@f87fae3dbebb /]$ ls -l /elasticsearch-7.15.0/snapshots/netology_backup/
total 44
-rw-r--r-- 1 elasticsearch elasticsearch   833 Oct  7 16:45 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Oct  7 16:45 index.latest
drwxr-xr-x 4 elasticsearch elasticsearch  4096 Oct  7 16:45 indices
-rw-r--r-- 1 elasticsearch elasticsearch 27573 Oct  7 16:45 meta-TmgS39hjQTmvb554fZA5bQ.dat
-rw-r--r-- 1 elasticsearch elasticsearch   442 Oct  7 16:45 snap-TmgS39hjQTmvb554fZA5bQ.dat
```

Удаляем индекс `test`, создаем индекс `test-2`.
```shell
curl -X DELETE "$ES_URL/test"

curl -H 'Content-Type: application/json' \
-XPUT $ES_URL/test-2 -d \
'{"settings":{"number_of_shards":1,"number_of_replicas":0}}'

vagrant@vagrant:~/elastic$ curl -X GET "$ES_URL/_cat/indices?v"
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2           RtoYziRYR1KXdpyEW9ehGw   1   0          0            0       208b           208b
green  open   .geoip_databases zSVNlsuuSE2yxgwexog1Nw   1   0         41           34     40.1mb         40.1mb
```

Восстанавливаем состояние кластера из снимка.
```shell
curl -H 'Content-Type: application/json' \
> -X POST "$ES_URL/_snapshot/snapshot_repository/test_snapshot_1/_restore" -d \
> '{"include_global_state": true}'

vagrant@vagrant:~/elastic$ curl -X GET "$ES_URL/_cat/indices?v"
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2           RtoYziRYR1KXdpyEW9ehGw   1   0          0            0       208b           208b
green  open   .geoip_databases vlOPNO4uRaa2hopGQWC5hA   1   0         41           34     40.1mb         40.1mb
green  open   test             KxRVsvQ1TtelMD5IsBL33w   1   0          0            0       208b           208b
```
