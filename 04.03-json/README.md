# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"

## Обязательные задания

1. Мы выгрузили JSON, который получили через API запрос к нашему сервису:
	```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
	```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

После исправления ошибок:
```json
{
  "info": "Sample JSON output from our service\t",
  "elements": [
    {
      "name": "first",
      "type": "server",
      "ip": 7175
    },
    {
      "name": "second",
      "type": "proxy",
      "ip": "71.78.22.43"
    }
  ]
}
```

2. В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. Формат записи YAML по одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

```python
#!/usr/bin/env python3

import socket
import json
import yaml
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
  with open('domains_list.json', 'w') as js: #перезаписываем актуальные пары домен - ip в .json файл
    js.write(json.dumps(domains_list, indent = 2))
  with open('domains_list.yaml', 'w') as ym: #перезаписываем актуальные пары домен - ip в .yaml файл
    ym.write(yaml.dump(domains_list, indent =2, explicit_start=True))
  a=a+1
  sleep(1) #делаем паузу
```


```commandline
vagrant@vagrant:~/netology/sysadm-homeworks$ cat domains_list.json
{
  "drive.google.com": "74.125.131.194",
  "mail.google.com": "142.250.150.83",
  "google.com": "64.233.162.100"
}

vagrant@vagrant:~/netology/sysadm-homeworks$ cat domains_list.yaml
---
drive.google.com: 74.125.131.194
google.com: 64.233.162.100
mail.google.com: 142.250.150.83
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
   * Принимать на вход имя файла
   * Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
   * Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
   * Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
   * При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
   * Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

---
