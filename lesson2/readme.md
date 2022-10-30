# Домашнее задание
## Работа с уровнями изоляции транзакции в PostgreSQL

### Создание виртуальной машины в Яндекс-облаке
Заходим на https://cloud.yandex.ru, выбираем Все сервисы - compute cloud - создать ВМ: </br>
<img width="400" alt="10" src="https://user-images.githubusercontent.com/44090170/198855859-2da6e166-6c79-4acd-ac47-526cdc42e4ca.png"> </br>

Указываем имя новой виртуальной машины:</br>
<img width="400" alt="10" src="https://user-images.githubusercontent.com/44090170/198855649-17cda679-05b0-4939-8b34-ddaf5931229d.png"> </br>

Выбираем ОС - Ubuntu 22.04: </br>
<img width="400" alt="10" src="https://user-images.githubusercontent.com/44090170/198855691-a66b2b00-2f4b-41ed-9ee6-b31bdf2b7e29.png"> </br>

Указываем логин: </br>
<img width="400" alt="10" src="https://user-images.githubusercontent.com/44090170/198855768-60719688-d7d2-4872-8729-347a5c903c9f.png"> </br>

А также ставим галочку "прерываемая" (как бы для экономии).</br>

*Так как WSL на этой винде принципиально не хочет подниматься, использую putty.*</br>

Вначале при помощи puttygen (лежит в рабочем каталоге putty) генерируем ключи:</br>
<img width="200" alt="10" src="https://user-images.githubusercontent.com/44090170/198856015-7ecd33d3-2642-46f6-a83d-4e7d83335d31.png"> </br>

(После нажатия generate нужно активно водить мышкой по экрану, иначе ничего не выйдет)</br>
<img width="200" alt="10" src="https://user-images.githubusercontent.com/44090170/198856044-7854ea66-1c13-4bf7-91dc-750e348b76ee.png"> </br>
После того, как ключи были созданы, копируем public key  вот сюда:</br>
<img width="200" alt="10" src="https://user-images.githubusercontent.com/44090170/198856159-5f64d550-1f95-483f-9dc3-0eabb9ec6089.png"> </br>
(public key надо копировать "как есть", без переносов строк)</br>

А private key сохраняем в файл. </br>

Завершаем регистрацию ВМ в яндекс-облаке:</br>
<img width="200" alt="10" src="https://user-images.githubusercontent.com/44090170/198856312-c1467a57-3aa7-44f4-844a-bd80f4a8b01a.png"> </br>

Для подключения к виртуальной машине с помощью ключа используем pageant </br>
Запускаем pageant.exe из рабочего каталога putty и добавляем ранее сохраненный private key:</br>
<img width="200" alt="10" src="https://user-images.githubusercontent.com/44090170/198856407-56427439-c464-46fb-8e89-612464499aaa.png"> </br>

Далее надо запустить putty и добавить private key еще и туда:</br>
<img width="200" alt="10" src="https://user-images.githubusercontent.com/44090170/198856522-aa0c7d3d-5561-4e4d-bc16-9e474bbd701f.png"> </br>

Подключаемся к ВМ:</br>
<img width="200" alt="10" src="https://user-images.githubusercontent.com/44090170/198856558-00fdb301-f297-44d6-9e39-ee5878cf8ba6.png"> </br>

### Установка PostgreSQL и работа с уровнями изоляции транзакции
На всякий случай обновляемся:</br>
>$ sudo apt-get update</br>
>$ sudo apt-get upgrade</br>

Устанавливаем postgres:</br>
>$ sudo apt-get install postgresql</br>

Что у нас установилось?</br>
>$ pg_lsclusters</br>
>14  main    5432 online postgres /var/lib/postgresql/14/main /var/log/postgresql/postgresql-14-main.log</br>
Установился postgresql 14й версии</br>

Подключаемся к postgres:</br>
>$ sudo -i -u postgres</br>
>postgres=# psql</br>

Создаем БД для экспериментов:</br>
>postgres=# create database homework;</br>

Список баз данных:</br>
>postgres=# \l</br>
<img width="200" alt="10" src="https://user-images.githubusercontent.com/44090170/198339161-37a1d5cd-1e2e-440d-af1a-372d919d80ba.png"></br>
Новая база в списке на 1м месте</br>

Подключаемся к созданной бд:</br>
>postgres=# \c homework</br>

Создаем таблицу:</br>
>postgres=# create table persons(id serial, first_name text, second_name text);</br>
>CREATE TABLE</br>

Список таблиц:</br>
>postgres=# \dt</br>
<img width="195" alt="11" src="https://user-images.githubusercontent.com/44090170/198340599-c779a7d7-d131-42d6-ac5a-298e7caba4d6.png"></br>

выключаем AUTOCOMMIT:</br>
>postgres=#\set AUTOCOMMIT false</br>

Вставляем записи:</br>
>postgres=# insert into persons(first_name, second_name) values('ivan', 'ivanov'); </br>
>INSERT 0 1 </br>
>postgres=\*# insert into persons(first_name, second_name) values('petr', 'petrov');</br>
>INSERT 0 1</br>
>postgres=\*# commit; </br> 
>COMMIT </br>

*в командной строке появился символ \*, т.к. мы внутри транзакции* </br>

Текущий уровень изоляции транзакций:</br>
>postgres=# show transaction isolation level; </br>
>transaction_isolation </br>
>---------------------------</br>
>read committed </br>

В первой сессии добавить новую запись </br>
>postgres=#insert into persons(first_name, second_name) values('sergey', 'sergeev');</br>

Сделать select * from persons во второй сессии</br>
>postgres=# select * from persons;</br>
> id | first_name | second_name</br>
>----+------------+-------------</br>
>  1 | ivan       | ivanov</br>
>  2 | petr       | petrov</br>
>(2 rows)</br>

***Видите ли вы новую запись и если да то почему?***</br>
*Мы не видим новую запись, т.к. 1я транзакция еще не завершена и на уровне изоляции read committed решена проблема "грязного чтения", 
т.е. мы не можем прочитать еще не зафиксированные изменения.* </br>

Завершить первую транзакцию - commit;
>postgres=\*# commit;</br>

Сделать select * from persons во второй сессии </br>
>postgres=# select * from persons;</br>
> id | first_name | second_name</br>
>----+------------+-------------</br>
>  1 | ivan       | ivanov</br>
>  2 | petr       | petrov</br>
>  3 | sergey     | sergeev</br>
> (3 rows)</br>

***Видите ли вы новую запись и если да то почему?***</br>
*Теперь мы видим новую запись, т.к. она зафиксирована 1й транзакцией.
Таким образом, во 2й транзакции мы в 2х запросах получили разные наборы записей. Это проблема "фантомного чтения", возможная на уровне read commited.*</br>

Завершите транзакцию во второй сессии </br>
>postgres=\*# commit;</br>

Начать новые, но уже repeatable read транзации.
>postgres=# set transaction isolation level repeatable read; </br>

В первой сессии добавить новую запись </br>
>postgres=#insert into persons(first_name, second_name) values('sveta', 'svetova'); </br>

Сделать select * from persons во второй сессии </br>
>postgres=# select * from persons;</br>
> id | first_name | second_name</br>
>----+------------+-------------</br>
>  1 | ivan       | ivanov</br>
>  2 | petr       | petrov</br>
>  3 | sergey     | sergeev</br> 
>(3 rows)</br>

***Видите ли вы новую запись и если да то почему?***</br>
*Мы не видим новую запись, т.к. 1я транзакция еще не завершена и на уровне изоляции repeatable read также решена проблема "грязного чтения", 
т.е. мы не можем прочитать еще не зафиксированные изменения.*</br>

Завершить первую транзакцию 
>postgres=#commit;</br>

Сделать select * from persons во второй сессии</br>
>postgres=# select * from persons;</br>
> id | first_name | second_name</br>
>----+------------+-------------</br>
>  1 | ivan       | ivanov</br>
>  2 | petr       | petrov</br>
>  3 | sergey     | sergeev</br>  
>(3 rows)</br>

***Видите ли вы новую запись и если да то почему?***</br>
*Мы все ще не видим новую запись, т.к. в PostgreSQL на уровне изоляции repeatable read внутри транзакции можно прочитать только те записи, которые были в таблице до начала этой транзакции. Таким образом решается проблема "фантомного чтения".</br>
Кстати, к примеру в MSSQL мы могли бы увидеть другой результат, т.к. стандарт SQL допускает фантомное чтение на этом уровне.*</br>

Завершить вторую транзакцию
>postgres=#commit;</br>

Сделать select * from persons во второй сессии
>postgres=# select * from persons;</br>
> id | first_name | second_name</br>
>----+------------+-------------</br>
>  1 | ivan       | ivanov</br>
>  2 | petr       | petrov</br>
>  3 | sergey     | sergeev</br>
>  4 | sveta      | svetova</br>
> (4 rows)</br>

***Видите ли вы новую запись и если да то почему?*** </br>
*Вот теперь мы видим новую запись, т.к. мы начали новую транзакцию и видим все изменения, зафиксированные на ее начало.*</br>

***Отсебятина:***
*Единственная проблема, допустимая на уровне repeatable read - проблема сериализации. </br>
К примеру, sveta решила выйти замуж, но не определилась за кого. </br>
В  1й транзакции: update persons set second_name = 'ivanova' where id = 4; </br>
Во 2й транзакции: update persons set second_name = 'petrova' where id = 4; </br>
2я транзакция будет ждать коммита 1й и сразу после коммита выкинет ошибку: "не удалось сериализовать доступ из-за параллельного изменения"*.







