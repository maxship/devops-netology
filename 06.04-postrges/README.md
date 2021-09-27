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
    volumes:
       - pg_13_data:/data/postgres
       - pg_13_backup:/etc/backup
    ports:
      - "5432:5432"
    networks:
      - pg_13_net
    restart: unless-stopped

networks:
  pg_13_net:
    driver: bridge

volumes:
    pg_13_data:
    pg_13_backup:
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

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

---
