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

---

Согласно документации, преобразовать обычную таблицу в секционированную и наоборот нельзя, поэтому разбиение по определенному критерию нужно закладывать заранее при проектировании таблиц.
В нашем случае таблица с данными уже существует, поэтому придется проделать некоторые промежуточные операции.

```sql
# Начало транзакции
BEGIN;
# Нереименовываем изначальную таблицу.
ALTER TABLE orders RENAME TO orders_old;
# Создаем новую таблицу `orders`, но уже с разбиением на части в зависимости от значений в столбце `price`.
CREATE TABLE orders (id serial NOT NULL, title character varying(80) NOT NULL, price integer DEFAULT 0) PARTITION BY RANGE (price);
# Создаем 2 секции. Верхняя и нижняя граница смежных диапазонов совпадаютт, т.к верхняя граница не попадает в выборку.
CREATE TABLE orders_1 PARTITION OF orders FOR VALUES FROM (500) TO (MAXVALUE);

CREATE TABLE orders_2 PARTITION OF orders FOR VALUES FROM (0) TO (500);
# Копируем данные.
INSERT INTO orders SELECT * FROM orders_old;
# Завершаем транзакцию
COMMIT;

# Старую таблицу можно удалить.
DROP TABLE orders_old;
```

Проверяем что получилось:
```sql
test_database=# \d orders
                              Partitioned table "public.orders"
 Column |         Type          | Collation | Nullable |               Default
--------+-----------------------+-----------+----------+-------------------------------------
 id     | integer               |           | not null | nextval('orders_id_seq1'::regclass)
 title  | character varying(80) |           | not null |
 price  | integer               |           |          | 0
Partition key: RANGE (price)
Number of partitions: 2 (Use \d+ to list them.)


test_database=# SELECT * FROM orders;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
(8 rows)


test_database=# select * from orders_1;
 id |       title        | price
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
(3 rows)

test_database=# select * from orders_2;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)

```



## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

---
Заходим в контейнер и запускаем `pg_dump`. Проверяем папку с бэкапами.
```
vagrant@vagrant:~/postgres13$ docker exec -ti postgres_13_container bash
root@17577c715cfe:/# pg_dump test_database -U test_admin > /etc/backup/backup_test_database_1
root@17577c715cfe:/# ls /etc/backup/
backup_test_database_1  test_dump.sql

```

Попробовал сделать столбец `title` уникальным для всей иерархии и отдельно для секционированной таблицы, postgres выдает такое:
```
test_database=# ALTER TABLE orders ADD UNIQUE (title);
ERROR:  unique constraint on partitioned table must include all partitioning columns
DETAIL:  UNIQUE constraint on table "orders" lacks column "price" which is part of the partition key.

test_database=# ALTER TABLE ONLY orders ADD UNIQUE (title);
ERROR:  unique constraint on partitioned table must include all partitioning columns
DETAIL:  UNIQUE constraint on table "orders" lacks column "price" which is part of the partition key.
```
Пока не могу понять в чем причина.
