# 3.2. Работа в терминале, лекция 2 (домашнее задание)

### 1. Какого типа команда cd?

```
vagrant@vagrant:~$ type cd  
cd is a shell builtin
```
Встроенная команда оболочки. Насколько я понимаю, раз она используется для перемещения по каталогам, то использование ее без оболочки не имеет смысла.

### 2. Какая альтернатива без pipe команде grep <some_string> <some_file> | wc -l?

```
vagrant@vagrant:~$ grep cpu /proc/cpuinfo/cpuinfo | grep cpu | wc -l
10
```
То же самое можно сделать без лишенй команды wc:
```
vagrant@vagrant:~$ grep -c cpu /proc/cpuinfo
10
```
