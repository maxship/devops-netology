# 3.1. Работа в терминале, лекция 1 (домашнее задание)

## 5. Ресурсы ВМ по умолчанию.

По умолчанию ВМ создается с 1Гб оперативки, 1 процессором и динамиески расширяющимся до 64 Гб жестким диском.

### 6. Как добавить оперативной памяти или ресурсов процессора виртуальной машине?.

Vagrant.configure("2") do |config| 
  config.vm.box = "bento/ubuntu-20.04"
	
	config.vm.provider "virtualbox" do |v|
	v.memory = 2048
	v.cpus = 2
	end

end

### 7. Подключение по SHH.

![Screenshot_9](https://user-images.githubusercontent.com/72273610/119250783-44f7b280-bbc4-11eb-942c-2eba67c344c1.png)

### 8. Настройки bash.
**Какой переменной можно задать длину журнала history, и на какой строчке manual это описывается?**

Количество команд, записываемых в историю, задается переменной HISTSIZE (862 строка мануала).  

**Что делает директива ignoreboth в bash?**

ignoreboth - значение переменной HISTCONTROL (line 833) - в историю не записываются команды, начинающиеся с пробела (ignorespace),  повторы команд (ignoredups).

### 9. В каких сценариях использования применимы скобки {} и на какой строчке man bash это описано?.

Brace Expansion (line 1092). Механизм генерации произвольных строк типа "a{d,c,b}e". На выходе получится "ade ace abe".

### 10. Основываясь на предыдущем вопросе, как создать однократным вызовом touch 100000 файлов? А получилось ли создать 300000?

vagrant@vagrant:**~/test_dir$ touch file{000000..100000}**  

vagrant@vagrant:**~/test_dir$ touch file{000000..300000}**  
-bash: /usr/bin/touch: Argument list too long

### 11. В man bash поищите по /\[\[. Что делает конструкция [[ -d /tmp ]]

[[ expression ]] (line 240). Возвращает 0 или 1 в результате проверки выражения в скобках.  
Конструкция [[ -d /tmp ]] проверяет, является ли "/tmp" директорией (-d line 1587).

### 12. Добейтесь в выводе type -a bash в виртуальной машине наличия первым пунктом в списке "bash is /tmp/new_path_directory/bash".

vagrant@vagrant:~$ **mkdir /tmp/new_path_directory**  

vagrant@vagrant:~$ **PATH=/tmp/new_path_directory/bash:$(echo $PATH)**  
vagrant@vagrant:~$ **export $PATH**  
-bash: export: `/tmp/new_path_directory:/tmp/new_path_directory/bash:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin': not a valid identifier  

vagrant@vagrant:/$ **cp /bin/bash /tmp/new_path_directory/**  

vagrant@vagrant:**/$ type -a bash**  
bash is /tmp/new_path_directory/bash  
bash is /usr/bin/bash  
bash is /bin/bash  







