# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.

---

Создаем docker-compose:
```yml
# пользователь по умолчанию - root
version: '3.5'

services:

  db:
    image: mysql:latest
# плагин авторизации по умолчанию
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: password
    volumes:
# подключаем директории хоста для данных и бэкапов
      - ./data:/var/lib/mysql
      - ./backup:/etc/backup
# файл с настройками
      - ./my.cnf:/etc/mysql/my.cnf

```

Скачиваем файл дампа с гитхаба в директорию для бэкапов.
```
vagrant@vagrant:~/mysql/backup$ sudo curl -OL https://raw.githubusercontent.com/maxship/devops-netology/main/06.03-db-mysql/test_damp.sql
```

Восстанавливаем БД, смотрим инфу о сервере.
```sql
mysql> CREATE DATABASE test_db;

root@15587a0c8bdd:/# mysql -u root -p test_db < /etc/backup/test_damp.sql

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test_db            |
+--------------------+
5 rows in set (0.00 sec)

mysql> \u test_db

mysql> SHOW TABLES FROM test_db;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)

mysql> \s
--------------
mysql  Ver 8.0.26 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          15
Current database:
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.26 MySQL Community Server - GPL
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    latin1
Conn.  characterset:    latin1
UNIX socket:            /var/run/mysqld/mysqld.sock
Binary data as:         Hexadecimal
Uptime:                 3 days 12 hours 32 min 12 sec

Threads: 2  Questions: 45  Slow queries: 0  Opens: 158  Flush tables: 3  Open tables: 76  Queries per second avg: 0.000
--------------
```

Выведем список столбцов в таблице 'orders' и затем строки, удовлетворяющие условию 'price' > 300.
```sql
mysql> SHOW COLUMNS FROM orders;
+-------+--------------+------+-----+---------+----------------+
| Field | Type         | Null | Key | Default | Extra          |
+-------+--------------+------+-----+---------+----------------+
| id    | int unsigned | NO   | PRI | NULL    | auto_increment |
| title | varchar(80)  | NO   |     | NULL    |                |
| price | int          | YES  |     | NULL    |                |
+-------+--------------+------+-----+---------+----------------+
3 rows in set (0.00 sec)

mysql> SELECT * FROM orders WHERE price > 300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)

```
## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

---

```sql
CREATE USER 'test'@'localhost'
    IDENTIFIED WITH mysql_native_password BY 'test-pass'
    PASSWORD EXPIRE INTERVAL 180 DAY
    FAILED_LOGIN_ATTEMPTS 3;


ALTER USER 'test'@'localhost'
    WITH MAX_QUERIES_PER_HOUR 100
    ATTRIBUTE '{"fname": "James","lname": "Pretty"}';    
    
GRANT SELECT ON test_db.* TO 'test'@'localhost';
```
```sql
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES
    -> WHERE USER = 'test';
+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "James", "lname": "Pretty"} |
+------+-----------+---------------------------------------+
1 row in set (0.00 sec)
```


## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

---

Включаем профайлинг, делаем несколько запросов, затем выводим историю.
```sql
mysql> SET profiling = 1;

mysql> SHOW PROFILES;
+----------+------------+--------------------------------------------------+
| Query_ID | Duration   | Query                                            |
+----------+------------+--------------------------------------------------+
|        1 | 0.00534400 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES |
|        2 | 0.00038550 | SELECT * FROM orders
|        3 | 0.00052350 | SELECT * FROM orders WHERE price > 300
+----------+------------+--------------------------------------------------+
2 rows in set, 1 warning (0.00 sec)
```
Меняем движок, повторяем те же запросы и сравниваем время выполнения.
```sql
mysql> SET default_storage_engine==MyISAM;

mysql> SHOW PROFILES;
+----------+------------+--------------------------------------------------+
| Query_ID | Duration   | Query                                            |
+----------+------------+--------------------------------------------------+
|        1 | 0.00534400 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES |
|        2 | 0.00038550 | SELECT * FROM orders 
|        3 | 0.00052350 | SELECT * FROM orders WHERE price > 300
|        4 | 0.00028925 | show engines                                     |
|        5 | 0.00030400 | SET default_storage_engine=MyISAM                |
|        6 | 0.00083300 | show engines                                     |
|        7 | 0.00060000 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES |
|        8 | 0.00048200 | SELECT * FROM orders
|        9 | 0.00026900 | SELECT * FROM orders WHERE price > 300
+----------+------------+--------------------------------------------------+
9 rows in set, 1 warning (0.00 sec)
```
Посмотрим подробнее, за счет чего такая разнича во времени выполнения, на примере запроса 'SELECT * FROM orders WHERE price > 300'.

```
mysql> SHOW PROFILE FOR QUERY 3;
+----------------------+----------+
| Status               | Duration |
+----------------------+----------+
| starting             | 0.000064 |
| checking permissions | 0.000011 |
| Opening tables       | 0.000075 |
| init                 | 0.000005 |
| System lock          | 0.000006 |
| optimizing           | 0.000004 |
| statistics           | 0.000012 |
| preparing            | 0.000016 |
| executing            | 0.000049 |
| end                  | 0.000002 |
| query end            | 0.000006 |
| closing tables       | 0.000004 |
| freeing items        | 0.000010 |
| cleaning up          | 0.000028 |
+----------------------+----------+
14 rows in set, 1 warning (0.00 sec)

mysql> SHOW PROFILE FOR QUERY 9;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000079 |
| Executing hook on transaction  | 0.000003 |
| starting                       | 0.000009 |
| checking permissions           | 0.000005 |
| Opening tables                 | 0.000033 |
| init                           | 0.000005 |
| System lock                    | 0.000008 |
| optimizing                     | 0.000003 |
| statistics                     | 0.000014 |
| preparing                      | 0.000015 |
| executing                      | 0.000268 |
| end                            | 0.000006 |
| query end                      | 0.000003 |
| waiting for handler commit     | 0.000008 |
| closing tables                 | 0.000006 |
| freeing items                  | 0.000009 |
| cleaning up                    | 0.000010 |
+--------------------------------+----------+
17 rows in set, 1 warning (0.00 sec)
```


## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

---


