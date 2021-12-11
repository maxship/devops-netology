# Домашнее задание к занятию "09.01 Жизненный цикл ПО"

## Подготовка к выполнению

1. Получить бесплатную [JIRA](https://www.atlassian.com/ru/software/jira/free)
2. Настроить её для своей "команды разработки"
3. Создать доски kanban и scrum

## Основная часть
В рамках основной части необходимо создать собственные workflow для двух типов задач: bug и остальные типы задач. Задачи типа bug должны проходить следующий жизненный цикл:

1. Open -> On reproduce
2. On reproduce <-> Open, Done reproduce
3. Done reproduce -> On fix
4. On fix <-> On reproduce, Done fix
5. Done fix -> On test
6. On test <-> On fix, Done
7. Done <-> Closed, Open

Остальные задачи должны проходить по упрощённому workflow:

1. Open -> On develop
2. On develop <-> Open, Done develop
3. Done develop -> On test
4. On test <-> On develop, Done
5. Done <-> Closed, Open

Создать задачу с типом bug, попытаться провести его по всему workflow до Done. Создать задачу с типом epic, к ней привязать несколько задач с типом task, провести их по всему workflow до Done. При проведении обеих задач по статусам использовать kanban. Вернуть задачи в статус Open.
Перейти в scrum, запланировать новый спринт, состоящий из задач эпика и одного бага, стартовать спринт, провести задачи до состояния Closed. Закрыть спринт.

Если всё отработало в рамках ожидания - выгрузить схемы workflow для импорта в XML. Файлы с workflow приложить к решению задания.

---

## Выполнение задачи

Создал новый проект (шаблон `kanban`, `company-managed`).
Создал 2 кастомных workflow `Bug fix`и `Development issues` с помощью `Settings -> Issues -> Workflows -> Add workflow`.

![jira_1](https://user-images.githubusercontent.com/72273610/145681752-2578e903-75d2-4723-aef6-6329125e68d5.png)

![jira_2](https://user-images.githubusercontent.com/72273610/145681755-17b1ceaf-73f2-4c0b-b1dd-b3ff7eb09c57.png)

Далее в `Settings -> Issues -> Workflow schemes` добавил новую схему `Test project schema`.

![jira_3](https://user-images.githubusercontent.com/72273610/145681768-65fe157c-56e5-460f-bd4c-5f0eccb72dc8.png)

![jira_4](https://user-images.githubusercontent.com/72273610/145681780-026b1220-320d-4876-b5d3-1ebca5a79a8a.png)

![jira_5](https://user-images.githubusercontent.com/72273610/145681784-93085190-e5cd-4707-988f-68d5eb8ec473.png)

![jira_6](https://user-images.githubusercontent.com/72273610/145681788-714c6239-5867-4d77-a8d3-f2dc391fe572.png)



