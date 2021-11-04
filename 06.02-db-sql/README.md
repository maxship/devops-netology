# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

---

Создал docker-compose.yml файл для запуска PostgreSQL + pgAdmin (web-интерфейс).

```yml
version: '3.5'

services:
  postgres:
    container_name: postgres_container
    image: postgres:12
    environment:
      POSTGRES_USER: admin
      # Если не задана переменная с названием первой БД, то она по умолчанию равна POSTGRES_USER
      POSTGRES_PASSWORD: password      
      # Задаем новую директорию для хранения данных
      PGDATA: /data/postgres
    volumes:
       - psql_data:/data/postgres
       - psql_backup:/etc/backup
    ports:
      - "5432:5432"
    networks:
      - postgres
    restart: unless-stopped

  pgadmin:
    container_name: pgadmin_container
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@psql.com
      PGADMIN_DEFAULT_PASSWORD: admin
      PGADMIN_CONFIG_SERVER_MODE: 'False'
    volumes:
       - pgadmin:/var/lib/pgadmin

    ports:
      - "8095:80"
    networks:
      - postgres
    restart: unless-stopped

networks:
  postgres:
    driver: bridge

volumes:
    psql_data:
    psql_backup:
    pgadmin:
```

Запуск в фоне:
```
vagrant@vagrant:~/postgresql$ docker-compose up -d
```
Для работы через встроенную утилиту psql с хоста:
```
vagrant@vagrant:~/postgresql$ psql -h localhost -p 5432 -U admin -d admin
```
Остановка и удаление контейнеров и томов:
```
vagrant@vagrant:~/postgresql$ docker-compose down -v
```
## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

---

```sql
# Создаем пользователя с админскими правами и тестовую БД
CREATE USER test_admin_user WITH PASSWORD 'password';

CREATE DATABASE test_db;

GRANT ALL PRIVILEGES ON DATABASE test_db TO test_admin_user;

# Создаем таблицы, устанавливаем внешний ключ на поле "заказ"
CREATE TABLE orders (
    id serial primary key,
    "наименование" text,
    "цена" integer);

CREATE TABLE clients (
    id serial primary key, 
    "фамилия" text,
    "страна проживания" text,
    "заказ" integer,
    FOREIGN KEY ("заказ") REFERENCES orders (id)
    );


# Создаем индекс
CREATE INDEX country_i ON clients ("страна проживания");

# Создаем обычного пользователя
CREATE USER test_simple_user WITH PASSWORD 'password';

GRANT SELECT, INSERT, UPDATE, DELETE ON clients, orders TO test_simple_user;
```

Подключимся к БД через консольную утилиту psql.
```
vagrant@vagrant:~/postgresql$ psql -h localhost -p 5432 -U test_admin_user -d test_db
```
Список БД:
```
test_db=> \l
                                 List of databases
   Name    | Owner | Encoding |  Collate   |   Ctype    |     Access privileges
-----------+-------+----------+------------+------------+---------------------------
 admin     | admin | UTF8     | en_US.utf8 | en_US.utf8 |
 postgres  | admin | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/admin                 +
           |       |          |            |            | admin=CTc/admin
 template1 | admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/admin                 +
           |       |          |            |            | admin=CTc/admin
 test_db   | admin | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/admin                +
           |       |          |            |            | admin=CTc/admin          +
           |       |          |            |            | test_admin_user=CTc/admin
(5 rows)
```
Описание таблиц:
```
test_db=> \d+
                                List of relations
 Schema |      Name      |   Type   |      Owner      |    Size    | Description
--------+----------------+----------+-----------------+------------+-------------
 public | clients        | table    | test_admin_user | 8192 bytes |
 public | clients_id_seq | sequence | test_admin_user | 8192 bytes |
 public | orders         | table    | test_admin_user | 16 kB      |
 public | orders_id_seq  | sequence | test_admin_user | 8192 bytes |
 public | orders_price   | view     | test_admin_user | 0 bytes    |
(5 rows)
```
Права доступа:
```
test_db=> \dp
                                              Access privileges
 Schema |      Name      |   Type   |            Access privileges            | Column privileges | Policies
--------+----------------+----------+-----------------------------------------+-------------------+----------
 public | clients        | table    | test_admin_user=arwdDxt/test_admin_user+|                   |
        |                |          | test_simple_user=arwd/test_admin_user   |                   |
 public | clients_id_seq | sequence |                                         |                   |
 public | orders         | table    | test_admin_user=arwdDxt/test_admin_user+|                   |
        |                |          | test_simple_user=arwd/test_admin_user   |                   |
 public | orders_id_seq  | sequence |                                         |                   |
 public | orders_price   | view     |                                         |                   |
(5 rows)
```

Поля таблиц:
```
test_db=> \d clients
                                  Table "public.clients"
      Column       |  Type   | Collation | Nullable |               Default
-------------------+---------+-----------+----------+-------------------------------------
 id                | integer |           | not null | nextval('clients_id_seq'::regclass)
 фамилия           | text    |           |          |
 страна проживания | text    |           |          |
 заказ             | integer |           |          |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "country_i" btree ("страна проживания")
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)

test_db=> \d orders
                               Table "public.orders"
    Column    |  Type   | Collation | Nullable |              Default
--------------+---------+-----------+----------+------------------------------------
 id           | integer |           | not null | nextval('orders_id_seq'::regclass)
 наименование | text    |           |          |
 цена         | integer |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.
---

Заполняем таблицы:
```sql

INSERT INTO orders (наименование, цена) VALUES
    ('Шоколад', 10),
    ('Книга', 10),
    ('Принтер', 3000),
    ('Монитор', 7000),
    ('Гитара', 4000);
    
INSERT INTO clients ("фамилия","страна проживания") VALUES
    ('Иванов Иван Иванович', 'USA'),
    ('Петров Петр Петрович', 'Canada'),
    ('Иоганн Себастьян Бах', 'Japan'),
    ('Ронни Джеймс Дио', 'Russia'),
    ('Ritchie Blackmore', 'Russia');

```

Смотрим вывод.
```sql
test_db=> SELECT * FROM orders;
 id | наименование | цена
----+--------------+------
  1 | Шоколад      |   10
  2 | Книга        |   10
  3 | Принтер      | 3000
  4 | Монитор      | 7000
  5 | Гитара       | 4000
(5 rows)

test_db=> SELECT * FROM clients;
 id |       фамилия        | страна проживания | заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |
  2 | Петров Петр Петрович | Canada            |
  3 | Иоганн Себастьян Бах | Japan             |
  4 | Ронни Джеймс Дио     | Russia            |
  5 | Ritchie Blackmore    | Russia            |
(5 rows)
```

Количество записей:
```sql
test_db=> SELECT COUNT(*) FROM orders;
 count
-------
     5
(1 row)

test_db=> SELECT COUNT(*) FROM clients;
 count
-------
     5
(1 row)
```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказка - используйте директиву `UPDATE`.

---

Добавляем в столбец "заказ" таблицы clients id заказов из связанной таблицы orders.
```sql
UPDATE clients SET "заказ" = (SELECT id FROM orders WHERE "наименование" = 'Книга')
    WHERE "фамилия" = 'Иванов Иван Иванович';
UPDATE clients SET "заказ" = (SELECT id FROM orders WHERE "наименование" = 'Монитор')
    WHERE "фамилия" = 'Петров Петр Петрович';
UPDATE clients SET "заказ" = (SELECT id FROM orders WHERE "наименование" = 'Гитара')
    WHERE "фамилия" = 'Иоганн Себастьян Бах';
```
```sql
test_db=> SELECT * FROM clients;
 id |       фамилия        | страна проживания | заказ
----+----------------------+-------------------+-------
  4 | Ронни Джеймс Дио     | Russia            |
  5 | Ritchie Blackmore    | Russia            |
  1 | Иванов Иван Иванович | USA               |     2
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(5 rows)
```
Пользователи, оформившие заказ:
```sql
test_db=> SELECT "фамилия" FROM clients WHERE "заказ" IS NOT NULL;
       фамилия
----------------------
 Иванов Иван Иванович
 Петров Петр Петрович
 Иоганн Себастьян Бах
(3 rows)
```
Запрос к обеим таблицам:
```sql
test_db=> SELECT "фамилия", "наименование"
test_db-> FROM clients c
test_db-> INNER JOIN orders o ON o.id = c."заказ";
       фамилия        | наименование
----------------------+--------------
 Иванов Иван Иванович | Книга
 Петров Петр Петрович | Монитор
 Иоганн Себастьян Бах | Гитара
(3 rows)
```

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

---

```sql
test_db=> EXPLAIN SELECT "фамилия" FROM clients WHERE "заказ" IS NOT NULL;
                        QUERY PLAN
-----------------------------------------------------------
 Seq Scan on clients  (cost=0.00..18.10 rows=806 width=32)
   Filter: ("заказ" IS NOT NULL)
(2 rows)

```
Значение cost - приблизительная стоимость запуска (время, через которое начнется вывод данных) и общая стоимость (если будут возвращены все доступные строки).  
rows - ожидаемое число строк.  
width - ожидаемый размер строк.  


## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

---

Заходим в контейнер postrges и делаем дамп.
```
vagrant@vagrant:~/postgresql$ docker exec -ti postgres_container bash

root@94eb2931c97c:/etc/backup# pg_dump test_db -U admin > /etc/backup/backup_1
```
Останавливаем запущенные контейнеры.
```
vagrant@vagrant:~/postgresql$ docker-compose down
Stopping postgres_container ... done
Stopping pgadmin_container  ... done
Removing postgres_container ... done
Removing pgadmin_container  ... done
Removing network postgresql_postgres
```
Запускаем заново.
```
vagrant@vagrant:~/postgresql$ docker-compose up -d
Creating network "postgresql_postgres" with driver "bridge"
Creating postgres_container ... done
Creating pgadmin_container  ... done
```

Подключаемся к контейнеру и восстанавливаем БД.
```
vagrant@vagrant:~/postgresql$ docker exec -ti postgres_container bash

root@15c90b7c3157:/# psql -U admin < /etc/backup/backup_1
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
CREATE VIEW
ALTER TABLE
ALTER TABLE
ALTER TABLE
COPY 5
COPY 5
 setval
--------
      5
(1 row)

 setval
--------
      5
(1 row)

ALTER TABLE
ALTER TABLE
CREATE INDEX
ALTER TABLE
GRANT
```
Проверяем:
```
test_db-> \d
                  List of relations
 Schema |      Name      |   Type   |      Owner
--------+----------------+----------+-----------------
 public | clients        | table    | test_admin_user
 public | clients_id_seq | sequence | test_admin_user
 public | orders         | table    | test_admin_user
 public | orders_id_seq  | sequence | test_admin_user
 public | orders_price   | view     | test_admin_user
(5 rows)
```
