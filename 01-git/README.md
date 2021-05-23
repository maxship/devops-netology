# devops-netology
 
## Учебный курс по git
 
##### 2.1. Основы git
 
В файле Terraform.gitignore будут проигнорированы:
 
Локальные вложенные директории .terraform; файлы, содержащие в расширении "tfstate"; файлы логов; файлы с расширением .tfvars; файлы override; конфигурационые файлы CLI.
 
##### 2.2. Основы git
 
Изменен файл README.md (ветка main)
 
##### 2.4. Инструменты Git
 
1. Найдите полный хеш и комментарий коммита, хеш которого начинается на aefea.
 
**$git show aefea**  
_полный хэш: **aefead2207ef7e2aa5dc81a34aedf0cad4c32545**_  
_комментарий: **Update CHANGELOG.md**_
 
2. Какому тегу соответствует коммит 85024d3?
 
**$git show 85024d3**  
_тег: **v0.12.23**_
 
2. Сколько родителей у коммита b8d720? Напишите их хеши.
 
**$git show b8d720^1**    
_**56cd785**_  
**$git show b8d720^2**  
_**9ea88f2**_
 
4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.
 
**$ git log v0.12.23..v0.12.24 --oneline**  
 
_33ff1c03b (tag: v0.12.24) v0.12.24  
b14b74c49 [Website] vmc provider links  
3f235065b Update CHANGELOG.md  
6ae64e247 registry: Fix panic when server is unreachable  
5c619ca1b website: Remove links to the getting started guide's old location  
06275647e Update CHANGELOG.md  
d5f9411f5 command: Fix bug when using terraform login on Windows  
4b6d06cc5 Update CHANGELOG.md  
dd01a3507 Update CHANGELOG.md  
225466bc3 Cleanup after v0.12.23 release_
 
 
5. Найдите коммит в котором была создана функция func providerSource, ее определение в коде выглядит так func providerSource(...) (вместо троеточего перечислены аргументы).
 
**$ git log -S 'func providerSource'**  
**_commit 8c928e8_**
 
6. Найдите все коммиты в которых была изменена функция globalPluginDirs.
 
**$ git log -S 'globalPluginDirs'**  
_**commit 8364383**  
**commit c0b1761**  
**commit 35a058fb**_  
 
7. Кто автор функции synchronizedWriters?
 
**$ git log --pretty=format:"%h - %an, %ar: %s" -S 'synchronizedWriters'**  
_bdfea50cc - James Bardin, 6 months ago: remove unused  
fd4f7eb0b - James Bardin, 7 months ago: remove prefixed io  
5ac311e2a - **Martin Atkins, 4 years, 1 month ago**: main: **synchronize writes** to VT100-faker on Windows_


 

