## Задача 1: Интернет Магазин

Руководство крупного интернет магазина у которого постоянно растёт пользовательская база и количество заказов рассматривает возможность переделки своей внутренней ИТ системы на основе микросервисов. 

Вас пригласили в качестве консультанта для оценки целесообразности перехода на микросервисную архитектуру. 

Опишите какие выгоды может получить компания от перехода на микросервисную архитектуру и какие проблемы необходимо будет решить в первую очередь.

---

**При переходе на микросервисную архитектуру компания может получить следующие выгоды:**

1. Возможность быстро и с наименьшими затратами вносить изменения в функционал.
2. Простая масшатбируемость в зависимости от потребностей (можно увеличить количество инстансов отдельных высоконагруженных микросервисов, а не всей системы).
3. Возможность полной замены части сервиса на совершенно другую, не затрагивая остальные компоненты (например, можно переписать отдельный микросервис на другом, более подходящим для данной цели, языке программирования).
4. Повышение надежности и безопасности (сбой одного микросервиса, как правило, не ведет к выходу из строя всей системы, и может быть устранен в меньшие сроки).
5. Снижение зависимости от одного разработчика (отдельные микросервисы могут разрабатывать разные компании).
6. Возможность использования для микросервисов разных технологий, каждая из которых наиболее подходит для конкретной задачи (в итоге это дает более высокую производительность при тех же ресурсах).


**Для перехода на микросервисную архитектуру в первую очередь потребуется решить следующие проблемы:**

1. Определить состав компонентов. Каждый микросервис должен выполнять отдельную функцию, но при этом не должно быть огромного количества "наносервисов". В случае интернет-магазина, это могут быть: карточка товаров, корзина покупок, рекомендуемые товары, чат с поддержкой и т.д.
2. Определить инструменты, которые будут использоваться для разработки микросервисов. С одной стороны, нужно подобрать решения, оптимальные для задач каждого конкретного компонента; с другой стороны, разводить целый "зоопарк" технологий не очень хорошая идея с точки зрения администрирования.
3. Определиться со стандартами взаимодействия между микросервисами (API и безопасность).

---