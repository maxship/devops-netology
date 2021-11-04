# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательные задания

1. Есть скрипт:
	```python
    #!/usr/bin/env python3
	a = 1
	b = '2'
	c = a + b
	```
	* Какое значение будет присвоено переменной c?
	* Как получить для переменной c значение 12?
	* Как получить для переменной c значение 3?
	
Если ничего не менять в коде, то python попробует сложить целое число со строкой и выдаст ошибку `TypeError: unsupported operand type(s) for +: 'int' and 'str'`.
Чтобы получить результат сложения 3, нужно поменять тип переменной b на int:
```python
>>> c=a+int(b)
>>> print(c)
3
```
Чтобы получить 12, нужно склеить строчные переменные:
```python
>>> c=str(a)+b
>>> print(c)
12
```

2. Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

	```python
    #!/usr/bin/env python3

    import os

	bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
	result_os = os.popen(' && '.join(bash_command)).read()
    is_change = False
	for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(prepare_result)
            break

	```
В результате работы скрипта отображаются только первый в списке модифицированный файл.

После доработки скрипт выглядит так. 
```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
pwd_os = os.popen('pwd').read()
print('working directory: ' + pwd_os) #выводим рабочую директорию
print('modified files:\n')
for result in result_os.split('\n'):
    if result.find('modified') != -1: #находим измененные отслеживаемые файлы
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
print('\nnew files:\n')
for result in result_os.split('\n'):
    if result.find('new file') != -1: #находим новые отслеживаемые файлы
        prepare_result = result.replace('\tnew file:   ', '')
        print(prepare_result)
```
В результате в выводе получаем:
```
vagrant@vagrant:~/netology/sysadm-homeworks$ ./git_status.py
working directory: /home/vagrant/netology/sysadm-homeworks

modified files:

new_file1
git_status.py

new files:

new_dir/new_file3
```

3. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

```python
#!/usr/bin/env python3

import sys
import os

ch_dir = 'cd ' + sys.argv[1] #задаем рабочую директорию параметром при запуске скрипта
bash_command = [ch_dir, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
pwd_os = os.popen('pwd').read()
print('working directory: ' + sys.argv[1] + '\n') #выводим рабочую директорию
print('modified files:\n')
for result in result_os.split('\n'):
  if result.find('modified') != -1: #находим отслеживаемые измененные файлы
    prepare_result = result.replace('\tmodified:   ', '')
    print(prepare_result)
    print('\nnew files:\n')
for result in result_os.split('\n'):
  if result.find('new file') != -1: #находим новые отслеживаемые файлы
    prepare_result = result.replace('\tnew file:   ', '')
    print(prepare_result)
```

```
vagrant@vagrant:~/netology/sysadm-homeworks$ ./git_status.py ~/netology/another_dir/
working directory: /home/vagrant/netology/another_dir/

modified files:

test_file1
test_file2
```

4. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: drive.google.com, mail.google.com, google.com.

```python
#!/usr/bin/env python3

import socket
from time import sleep


domains_list = {"drive.google.com":"0", "mail.google.com":"0", "google.com":"0"}

a = 1

while (1 == 1):
  for k, v in domains_list.items():
    ip = socket.gethostbyname(k)
    if str(v) == str(ip) or a == 1: #сравниваем старый IP из dict 'domains_list' с новым (кроме 1й итерации)
      print(f'{k}: {ip}')
    else:
      print(f'[ERROR] {k} IP mismatch: {domains_list[k]} {ip}')
    domains_list[k] = ip #записываем новое значение IP в dict для каждого домена (ключа)
  print('\n')
  a=a+1
  sleep(1) #делаем паузу
```
Проверяем работоспособность:

```
vagrant@vagrant:~$ ./ip_check.py
drive.google.com: 74.125.131.194
mail.google.com: 142.250.150.18
google.com: 64.233.164.100


drive.google.com: 74.125.131.194
[ERROR] mail.google.com IP mismatch: 142.250.150.18 142.250.150.17
google.com: 64.233.164.100


drive.google.com: 74.125.131.194
mail.google.com: 142.250.150.17
[ERROR] google.com IP mismatch: 64.233.164.100 64.233.162.138


drive.google.com: 74.125.131.194
mail.google.com: 142.250.150.17
[ERROR] google.com IP mismatch: 64.233.162.138 64.233.162.113
```




## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так получилось, что мы очень часто вносим правки в конфигурацию своей системы прямо на сервере. Но так как вся наша команда разработки держит файлы конфигурации в github и пользуется gitflow, то нам приходится каждый раз переносить архив с нашими изменениями с сервера на наш локальный компьютер, формировать новую ветку, коммитить в неё изменения, создавать pull request (PR) и только после выполнения Merge мы наконец можем официально подтвердить, что новая конфигурация применена. Мы хотим максимально автоматизировать всю цепочку действий. Для этого нам нужно написать скрипт, который будет в директории с локальным репозиторием обращаться по API к github, создавать PR для вливания текущей выбранной ветки в master с сообщением, которое мы вписываем в первый параметр при обращении к py-файлу (сообщение не может быть пустым). При желании, можно добавить к указанному функционалу создание новой ветки, commit и push в неё изменений конфигурации. С директорией локального репозитория можно делать всё, что угодно. Также, принимаем во внимание, что Merge Conflict у нас отсутствуют и их точно не будет при push, как в свою ветку, так и при слиянии в master. Важно получить конечный результат с созданным PR, в котором применяются наши изменения. 


