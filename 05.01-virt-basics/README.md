# Домашнее задание к занятию "5.1. Основы виртуализации"

## Задача 1

Вкратце опишите, как вы поняли - в чем основное отличие паравиртуализации и виртуализации на основе ОС.

При использовании паравиртуализации эмулируется аппаратная часть компьютера и устанавливается гостевая ОС. При этом гостевая ОС использует часть ресурсов хоста через гипервизор (аналогично полной виртуализации), а часть - напрямую. 

Основное отличие виртуализации на основе ОС (контейнеризации) от паравиртуализации в том, что эмулируется не компьютер или ОС, а пользовательское окружение ОС. Контейнеры используют ядро ОС хоста и всю аппаратную часть напрямую. По сути запускается изолированный неймспейс, в котором работает приложение. Прослойка в виде гипервизора отсутствует полностью. Если это приложение не расчитано на работу с ОС хоста, то просто так запустить его не получится, нужно дополнительно подтянуть изолированную среду, в которой это приложение сможет работать. То есть, например, Docker-контейнер с Ubuntu запустить из под Windows можно, но c использованием Hyper-V.


## Задача 2

Выберите тип один из вариантов использования организации физических серверов, 
в зависимости от условий использования.

Организация серверов:
- физические сервера
- паравиртуализация
- виртуализация уровня ОС

Условия использования:

- Высоконагруженная база данных, чувствительная к отказу
- Различные Java-приложения
- Windows системы для использования Бухгалтерским отделом 
- Системы, выполняющие высокопроизводительные расчеты на GPU

Опишите, почему вы выбрали к каждому целевому использованию такую организацию.

- **Высоконагруженная база данных, чувствительная к отказу**. Для высоконагруженных баз данных важно максимальное быстродействие, поэтому любые дополнительные слои виртуализации нежелательны, и лучше всего использовать реальный сервер для этих целей.
- **Различные Java-приложения**. По-моему, этом случае лучше подойдет виртуализацию на уровне ОС. Java машина сама по себе уже использует виртуализацию, и добавить еще один дополнительный слой виртуализации - значит еще уменьшить производительность. В контейнере приложение будет напрямую работать с ОС хоста, при этом не влияя на другие запущенные на этом же хосте приложения.
- **Windows системы для использования Бухгалтерским отделом**. Здесь, на мой взляд, лучше подойдет паравиртуализация, т.к. в бухгалтерии часто используются аппаратные лицензионные ключи, требующие прямого доступа к железу. При этом использовать отдельный физический сервер для каждой системы может быть нерационально. 
- **Системы, выполняющие высокопроизводительные расчеты на GPU**. Здесь, как мне кажется, ситуация аналогична первому случаю, и можно использовать отдельный физический сервер. Но, если есть драйвера, позволяющие ВМ напрямую взаимодействовать с GPU, то целесообразно применение паравиртуализации. В этом случае можно изменять параметры системы в зависимости от нагрузки, а так же запустить несколько таких систем на одном хосте.

## Задача 3

Как вы думаете, возможно ли совмещать несколько типов виртуализации на одном сервере?
Приведите пример такого совмещения.

Самый простой пример, который приходит в голову - использование контейнеризации внутри виртуальной машины. Не уверен, что такой подход используется на реальных серверах, но как минимум в качестве сэндбокса для экспериментов вполне годится. Или, к примеру, на хосте с линуксом можно развернуть несколько виртуалок с гостевми ОС, часть из которых тоже на основе линукса, а часть, например на винде. В этом случае, по идее логично использовать для для винды виртуализацию, для линукса паравиртуализацию. 
