# Домашнее задание к занятию "12.3 Развертывание кластера на собственных серверах, лекция 1"
Поработав с персональным кластером, можно заняться проектами. Вам пришла задача подготовить кластер под новый проект.

## Задание 1: Описать требования к кластеру
Сначала проекту необходимо определить требуемые ресурсы. Известно, что проекту нужны база данных, система кеширования, а само приложение состоит из бекенда и фронтенда. Опишите, какие ресурсы нужны, если известно:

* База данных должна быть отказоустойчивой. Потребляет 4 ГБ ОЗУ в работе, 1 ядро. 3 копии.
* Кэш должен быть отказоустойчивый. Потребляет 4 ГБ ОЗУ в работе, 1 ядро. 3 копии.
* Фронтенд обрабатывает внешние запросы быстро, отдавая статику. Потребляет не более 50 МБ ОЗУ на каждый экземпляр, 0.2 ядра. 5 копий.
* Бекенд потребляет 600 МБ ОЗУ и по 1 ядру на копию. 10 копий.

## Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

План расчета
1. Сначала сделайте расчет всех необходимых ресурсов.
2. Затем прикиньте количество рабочих нод, которые справятся с такой нагрузкой.
3. Добавьте к полученным цифрам запас, который учитывает выход из строя как минимум одной ноды.
4. Добавьте служебные ресурсы к нодам. Помните, что для разных типов нод требовния к ресурсам разные.
5. Рассчитайте итоговые цифры.
6. В результате должно быть указано количество нод и их параметры.


---

## Решение.
## Задача 1: Описать требования к кластеру

Опишем требования в виде таблицы. 

|Ресурсы|Кол-во CPU|RAM|Кол-во копий|Итого требуемых ресурсов|
|:---|:---|:---|:---|:---|
|База данных|1|4 Гб|3|3 CPU и 12 Гб RAM|
|Кэш|1|4 Гб|3|3 CPU и 12 Гб RAM|
|Фронтенд|0.2|50 Мб|5|1 CPU и 250 Мб RAM|
|Бекенд|1|600 Мб|10|10 CPU и 6 Гб RAM|
|Control Plane|2|2 Гб|неизвестно|2 CPU и 2 Гб RAM на 1 ноду|
|Рабочая нода|1|1 Гб|неизвестно|1 CPU и 1 Гб RAM на 1 ноду|

**Суммарно на полезную нагрузку:** 17 CPU и 20.25 Гб RAM

**Вариант конфигурации кластера.**

Предположим, что у нас 4 рабочих ноды. Эта комбинация потребует 17 + 4 = 21 CPU и 20.25 + 4 = 25 Гб RAM. Каждая нода в этом случае будет иметь по 6 CPU и 8 Гб RAM. Для обеспечения отказоустойчивости добавим еще одну рабочую ноду, итого 5 рабочих нод (30 CPU, 40 Гб RAM суммарно).

Количество управляющих нод примем равным 3. Тогда каждая нода будет иметь по 2 CPU и 2 Гб RAM (6 CPU, 6 Гб RAM суммарно)

Итого, кластер потребует выделения 36 CPU и 46 Гб RAM.