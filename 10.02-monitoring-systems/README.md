# Домашнее задание к занятию "10.02. Системы мониторинга"

## Обязательные задания

1. Опишите основные плюсы и минусы pull и push систем мониторинга.

2. Какие из ниже перечисленных систем относятся к push модели, а какие к pull? А может есть гибридные?

    - Prometheus 
    - TICK
    - Zabbix
    - VictoriaMetrics
    - Nagios

3. Склонируйте себе [репозиторий](https://github.com/influxdata/sandbox/tree/master) и запустите TICK-стэк, 
используя технологии docker и docker-compose.

В виде решения на это упражнение приведите выводы команд с вашего компьютера (виртуальной машины):

```sh
    - curl http://localhost:8086/ping
    - curl http://localhost:8888
    - curl http://localhost:9092/kapacitor/v1/ping
```
А также скриншот веб-интерфейса ПО chronograf (`http://localhost:8888`). 

P.S.: если при запуске некоторые контейнеры будут падать с ошибкой - проставьте им режим `Z`, например
`./data:/var/lib:Z`

---

### 3. Решение

```sh
$ ./sandbox up
$ docker-compose ps
                    Name                                  Command               State                                                              Ports                                                            
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
netology-102-monitoring-tick_chronograf_1      /entrypoint.sh chronograf        Up      0.0.0.0:8888->8888/tcp,:::8888->8888/tcp                                                                                    
netology-102-monitoring-tick_documentation_1   /documentation/documentati ...   Up      0.0.0.0:3010->3000/tcp,:::3010->3000/tcp                                                                                    
netology-102-monitoring-tick_influxdb_1        /entrypoint.sh influxd           Up      0.0.0.0:8082->8082/tcp,:::8082->8082/tcp, 0.0.0.0:8086->8086/tcp,:::8086->8086/tcp, 0.0.0.0:8089->8089/udp,:::8089->8089/udp
netology-102-monitoring-tick_kapacitor_1       /entrypoint.sh kapacitord        Up      0.0.0.0:9092->9092/tcp,:::9092->9092/tcp                                                                                    
netology-102-monitoring-tick_telegraf_1        /entrypoint.sh telegraf          Up      8092/udp, 8094/tcp, 8125/udp 
```

```sh
$ curl http://localhost:8086/ping -v
*   Trying 127.0.0.1:8086...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 8086 (#0)
> GET /ping HTTP/1.1
> Host: localhost:8086
> User-Agent: curl/7.68.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 204 No Content
< Content-Type: application/json
< Request-Id: cb99950d-7885-11ec-81ea-0242ac120002
< X-Influxdb-Build: OSS
< X-Influxdb-Version: 1.8.10
< X-Request-Id: cb99950d-7885-11ec-81ea-0242ac120002
< Date: Tue, 18 Jan 2022 17:40:58 GMT
< 
* Connection #0 to host localhost left intact

$ curl http://localhost:8888
<!DOCTYPE html><html><head><meta http-equiv="Content-type" content="text/html; charset=utf-8"><title>Chronograf</title><link rel="icon shortcut" href="/favicon.fa749080.ico"><link rel="stylesheet" href="/src.3dbae016.css"></head><body> <div id="react-root" data-basepath=""></div> <script src="/src.fab22342.js"></script> </body></html>

$ curl http://localhost:9092/kapacitor/v1/ping -v
*   Trying 127.0.0.1:9092...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 9092 (#0)
> GET /kapacitor/v1/ping HTTP/1.1
> Host: localhost:9092
> User-Agent: curl/7.68.0
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 204 No Content
< Content-Type: application/json; charset=utf-8
< Request-Id: e379ddbc-7885-11ec-81c6-000000000000
< X-Kapacitor-Version: 1.6.2
< Date: Tue, 18 Jan 2022 17:41:38 GMT
< 
* Connection #0 to host localhost left intact
```
![1021](https://user-images.githubusercontent.com/72273610/149995101-bc79242a-a706-449a-b28a-8abe842069a2.png)

---

4. Перейдите в веб-интерфейс Chronograf (`http://localhost:8888`) и откройте вкладку `Data explorer`.

    - Нажмите на кнопку `Add a query`
    - Изучите вывод интерфейса и выберите БД `telegraf.autogen`
    - В `measurments` выберите mem->host->telegraf_container_id , а в `fields` выберите used_percent. 
    Внизу появится график утилизации оперативной памяти в контейнере telegraf.
    - Вверху вы можете увидеть запрос, аналогичный SQL-синтаксису. 
    Поэкспериментируйте с запросом, попробуйте изменить группировку и интервал наблюдений.

Для выполнения задания приведите скриншот с отображением метрик утилизации места на диске 
(disk->host->telegraf_container_id) из веб-интерфейса.

---

### 4. Решение

Изначально поля `mem` в веб интерфейсе не было, поэтому добавил соответствующие настройки в файл настроек `telegraf/telegraf.conf`

```conf
  [[inputs.mem]]
```

После перезапуска docker-compose командой `./sandbox restart` выполняем `Explore -> Add a query -> telegraf.autogen -> mem -> host-1 telegraf-getting-started -> used_percent`.

Сформировался SQL-запрос:

```sql
SELECT mean("used_percent") AS "mean_used_percent" FROM "telegraf"."autogen"."mem" WHERE time > :dashboardTime: AND time < :upperDashboardTime: AND "host"='telegraf-getting-started' GROUP BY time(:interval:) FILL(null)
```

![1022](https://user-images.githubusercontent.com/72273610/149995145-1b87961c-43ea-48dd-9149-35bdc468f961.png)

---

5. Изучите список [telegraf inputs](https://github.com/influxdata/telegraf/tree/master/plugins/inputs). 
Добавьте в конфигурацию telegraf следующий плагин - [docker](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/docker):
```
[[inputs.docker]]
  endpoint = "unix:///var/run/docker.sock"
```

Дополнительно вам может потребоваться донастройка контейнера telegraf в `docker-compose.yml` дополнительного volume и 
режима privileged:

```yml
  telegraf:
    image: telegraf:1.4.0
    privileged: true
    volumes:
      - ./etc/telegraf.conf:/etc/telegraf/telegraf.conf:Z
      - /var/run/docker.sock:/var/run/docker.sock:Z
    links:
      - influxdb
    ports:
      - "8092:8092/udp"
      - "8094:8094"
      - "8125:8125/udp"
```

После настройке перезапустите telegraf, обновите веб интерфейс и приведите скриншотом список `measurments` в 
веб-интерфейсе базы telegraf.autogen . Там должны появиться метрики, связанные с docker.

Факультативно можете изучить какие метрики собирает telegraf после выполнения данного задания.

---

### 5. Решение

Добавил соответствующие настройки в файл настроек `telegraf/telegraf.conf`

```yml
[[inputs.docker]]
  endpoint = "unix:///var/run/docker.sock"
  timeout = "5s"
  perdevice = true
  total = false
```

и в `docker-compose.yml`

```yml
  telegraf:
    privileged: true
    # Telegraf requires network access to InfluxDB
    links:
      - influxdb
    volumes:
      # Mount for telegraf configuration
      - ./telegraf/telegraf.conf:/etc/telegraf/telegraf.conf:Z
      # Mount for Docker API access
      - /var/run/docker.sock:/var/run/docker.sock
    depends_on:
      - influxdb
    ports:
      - "8092:8092/udp"
      - "8094:8094"
      - "8125:8125/udp"
```

После перезапуска новые метрики не появились. Для работы потребовались дополнительные права на `/var/run/docker.sock`:

```
sudo chmod 666 /var/run/docker.sock
```

![1023](https://user-images.githubusercontent.com/72273610/151372272-bbdc59fb-0cf7-4dde-8a1b-4d4745241054.png)

---

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

В веб-интерфейсе откройте вкладку `Dashboards`. Попробуйте создать свой dashboard с отображением:

    - утилизации ЦПУ
    - количества использованного RAM
    - утилизации пространства на дисках
    - количество поднятых контейнеров
    - аптайм
    - ...
    - фантазируйте)
    
    ---
