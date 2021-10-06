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
```
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
```
vagrant@vagrant:~/elastic$ docker build -t es:test1 -f elastic_df .
```

Запускаем контейнер и цепляем к нему директорию с данными и файл конфига.
```
vagrant@vagrant:~/elastic$ docker run --rm -d -p 9200:9200 \
> -v "$(pwd)"/data:/var/lib/elasticsearch \
> -v "$(pwd)"/elasticsearch.yml:/elasticsearch-7.15.0/config/elasticsearch.yml \
> es:test1
```


Тестим.
```
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

vagrant@vagrant:~/elastic/data$ curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "es-cluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```

Пушим образ в репозиторий.
```
vagrant@vagrant:~/elastic/data$ docker tag es:test1 moshipitsyn/my_elasticsearch:latest
vagrant@vagrant:~/elastic/data$ docker push moshipitsyn/my_elasticsearch:latest
```

https://hub.docker.com/repository/docker/moshipitsyn/my_elasticsearch


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
