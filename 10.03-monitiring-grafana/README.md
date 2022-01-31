# Домашнее задание к занятию "10.03. Grafana"

## Задание повышенной сложности

**В части задания 1** не используйте директорию [help](./help) для сборки проекта, самостоятельно разверните grafana, где в 
роли источника данных будет выступать prometheus, а сборщиком данных node-exporter:
- grafana
- prometheus-server
- prometheus node-exporter

За дополнительными материалами, вы можете обратиться в официальную документацию grafana и prometheus.

В решении к домашнему заданию приведите также все конфигурации/скрипты/манифесты, которые вы 
использовали в процессе решения задания.

**В части задания 3** вы должны самостоятельно завести удобный для вас канал нотификации, например Telegram или Email
и отправить туда тестовые события.

В решении приведите скриншоты тестовых событий из каналов нотификаций.

## Обязательные задания

### Задание 1
Используя директорию [help](./help) внутри данного домашнего задания - запустите связку prometheus-grafana.

Зайдите в веб-интерфейс графана, используя авторизационные данные, указанные в манифесте docker-compose.

Подключите поднятый вами prometheus как источник данных.

Решение домашнего задания - скриншот веб-интерфейса grafana со списком подключенных Datasource.

---

#### Решение

Для формирования запросов к prometheus для графаны, потребуется зайти в GUI, поэтому в `docker-compose` открыл дополнительно порты:

```yml
    ports:
      - 9090:9090
```
После этого prometheus так же будет досупен по адресу `localhost:9090`.

```
$ docker-compose up -d
Creating nodeexporter ... done
Creating prometheus   ... done
Creating grafana      ... done
```

![1031](https://user-images.githubusercontent.com/72273610/151760406-1ba95756-53ce-49dc-ad0f-9a29f49ce458.png)

### Задание 2
Изучите самостоятельно ресурсы:
- [promql-for-humans](https://timber.io/blog/promql-for-humans/#cpu-usage-by-instance)
- [understanding prometheus cpu metrics](https://www.robustperception.io/understanding-machine-cpu-usage)

Создайте Dashboard и в ней создайте следующие Panels:
- Утилизация CPU для nodeexporter (в процентах, 100-idle)
- CPULA 1/5/15
- Количество свободной оперативной памяти
- Количество места на файловой системе

Для решения данного ДЗ приведите promql запросы для выдачи этих метрик, а также скриншот получившейся Dashboard.

---

#### Решение

- Для вывода графика загрузки CPU, воспользуемся значением `idle`, т.е. временем, когда процессор ничего не делает. Вычтем это значение из 100%.

```
100 -(avg by (instance) (rate(node_cpu_seconds_total{job="nodeexporter",mode="idle"}[1m])) * 100)
```

- CPULA выведем на один график с помощью запросов:

```
node_load1{instance="nodeexporter:9100", job="nodeexporter"}
node_load5{instance="nodeexporter:9100", job="nodeexporter"}
node_load15{instance="nodeexporter:9100", job="nodeexporter"}
```

- Количество свободной оперативной памяти:

```
node_memory_MemFree_bytes{instance="nodeexporter:9100", job="nodeexporter"}
```

- Количество места на файловой системе:

```
node_filesystem_avail_bytes{fstype!~"tmpfs|fuse.lxcfs|squashfs"}
```

![1032](https://user-images.githubusercontent.com/72273610/151770871-5eb7a233-6733-48a4-99f6-4d716a436dba.png)


### Задание 3
Создайте для каждой Dashboard подходящее правило alert (можно обратиться к первой лекции в блоке "Мониторинг").

Для решения ДЗ - приведите скриншот вашей итоговой Dashboard.

### Задание 4
Сохраните ваш Dashboard.

Для этого перейдите в настройки Dashboard, выберите в боковом меню "JSON MODEL".

Далее скопируйте отображаемое json-содержимое в отдельный файл и сохраните его.

В решении задания - приведите листинг этого файла.

---

