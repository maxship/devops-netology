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
vagrant@vagrant:~/postgresql$ psql -h localhost -p 5432 -U user
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

# Создаем таблицы
CREATE TABLE orders (
    id serial primary key,
    "наименование" text,
    "цена" integer);

CREATE TABLE clients (
    id serial primary key, 
    "фамилия" text,
    "страна проживания" text,
    "заказ" integer);

# Устанавливаем внешнй ключ на поле "заказ"    
ALTER TABLE clients ADD FOREIGN KEY ("заказ") REFERENCES orders

# Создаем индекс
CREATE INDEX country_i ON clients ("страна проживания");

# Создаем обычного пользователя
CREATE USER test_simple_user WITH PASSWORD 'password';



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


```sql

INSERT INTO orders (наименование, цена) VALUES
    ('Шоколад', 10),
    ('Книга', 10),
    ('Принтер', 3000),
    ('Монитор', 7000),
    ('Гитара', 4000);
    


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
 
Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

