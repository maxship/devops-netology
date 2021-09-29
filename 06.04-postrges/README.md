# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

---
Compose файл:
```yml
version: '3.5'

services:
  postgres:
    container_name: postgres_13_container
    image: postgres:13
    environment:
      POSTGRES_USER: test_admin
      POSTGRES_PASSWORD: mypassword
      PGDATA: /data/postgres
      POSTGRES_DB: db_0
# монтируем локальные директории на хосте в контейнер      
    volumes:
       - ./pg_13_data:/data/postgres
       - ./pg_13_backup:/etc/backup
    ports:
      - "5432:5432"
    networks:
      - pg_13_net
    restart: unless-stopped
```


Запускаем контейнер и заходим в psql под указанным в docker-compose пользователем.
```
vagrant@vagrant:~/postgres13$ docker-compose up -d

vagrant@vagrant:~/postgres13$ docker exec -ti postgres_13_container psql -U test_admin -d db_0
psql (13.4 (Debian 13.4-1.pgdg110+1))
Type "help" for help.

db_0=#
```

Управляющие команды:

`\l` - вывод списка БД;  
`\c [ dbname [ username ] [ host ] [ port ] | conninfo ]` - подключениe к БД;  
`\dt` - вывода списка таблиц;  
`\d [имя таблицы]` - вывод описания содержимого таблицы;  
`\q` - выход из psql;  

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

---
```sql
db_0=# CREATE DATABASE test_database;
CREATE DATABASE
db_0=# \c test_database
You are now connected to database "test_database" as user "test_admin".
```
Скопируем файл в папку для бэкапов на хосте и восстановим из него БД.
```
vagrant@vagrant:~/postgres13/pg_13_backup$ sudo curl -OL https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-04-post
gresql/test_data/test_dump.sql

vagrant@vagrant:~/postgres13$ docker exec -ti postgres_13_container bash

root@17577c715cfe:/# psql -U test_admin test_database < /etc/backup/test_dump.sql
```
Подключаемся к восстановленной БД.
```
root@17577c715cfe:/# psql -U test_admin -d test_database

test_database=# \dt
          List of relations
 Schema |  Name  | Type  |   Owner
--------+--------+-------+------------
 public | orders | table | test_admin
(1 row)
```



## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

```
test_database=# ALTER TABLE orders RENAME TO orders_old;

test_database=# CREATE TABLE orders (id serial NOT NULL, title character varying(80) NOT NULL, price integer DEFAULT 0) PARTITION BY RANGE (price);

test_database=# CREATE TABLE orders_0_to_498 PARTITION OF orders FOR VALUES FROM (0) TO (498);

test_database=# CREATE TABLE orders_from_499 PARTITION OF orders FOR VALUES FROM (499) TO (MAXVALUE);

```



## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

---
