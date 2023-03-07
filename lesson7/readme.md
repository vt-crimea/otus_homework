## Работа с базами данных, пользователями и правами
### Цель:
### • создание новой базы данных, схемы и таблицы
### • создание роли для чтения данных из созданной схемы созданной базы данных
### • создание роли для чтения и записи из созданной схемы созданной базы данных

### 1 создайте новый кластер PostgresSQL 14
сделано в рамках предыдущих заданий:
https://github.com/vt-crimea/otus_homework/tree/main/lesson2
https://github.com/vt-crimea/otus_homework/tree/main/lesson3

### 2 зайдите в созданный кластер под пользователем postgres
>$ sudo -u postgres psql </br>
>
>psql (14.7 (Ubuntu 14.7-0ubuntu0.22.04.1)) </br>
>postgres=# </br>

### 3 создайте новую базу данных testdb 

>postgres=# create database testdb; <br>
>
>CREATE DATABASE <br>

### 4 зайдите в созданную базу данных под пользователем postgres

> postgres=# \c testdb;<br>
> 
> You are now connected to database "testdb" as user "postgres".<br>

### 5 создайте новую схему testnm

>testdb=# create schema testnm;
>
>CREATE SCHEMA

### 6 создайте новую таблицу t1 с одной колонкой c1 типа integer
>testdb=# create table testnm.t1 (c1 int);
>
>CREATE TABLE

### 7 вставьте строку со значением c1=1

>testdb=# insert into testnm.t1(c1) values(1);
>
>INSERT 0 1

### 8 создайте новую роль readonly

>testdb=# create role readonly;
>
>CREATE ROLE

### 9 дайте новой роли право на подключение к базе данных testdb

>testdb=# GRANT CONNECT ON DATABASE testdb TO readonly;
> 
>GRANT

### 10 дайте новой роли право на использование схемы testnm

>testdb=# GRANT USAGE ON schema testnm to readonly;
>>
>GRANT

### 11 дайте новой роли право на select для всех таблиц схемы testnm

>testdb=# GRANT SELECT on all tables IN SCHEMA testnm to readonly;
>
>GRANT

### 12 создайте пользователя testread с паролем test123

>testdb=# CREATE USER testread WITH PASSWORD 'test123';
>
>CREATE ROLE

### 13 дайте роль readonly пользователю testread

>testdb=# GRANT readonly TO testread;
>
>GRANT ROLE

### 14 зайдите под пользователем testread в базу данных testdb

>postgres=# \c testdb testread;
>
>connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  Peer authentication failed for user "testread"
>Previous connection kept</br>

Через Peer authentication нас не пускает, т.к. пользователя линукс testread нет.
Выйдем и зайдем по сети:
>$ psql -h 127.0.0.1 -U testread -d testdb -W
>
>Password:
>
>psql (14.7 (Ubuntu 14.7-0ubuntu0.22.04.1))
>
>SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
>
>Type "help" for help.
>
>testdb=>

### 15 сделайте select * from t1;

>testdb=> select * from t1;
>
>ERROR:  relation "t1" does not exist

***16 получилось? (могло если вы делали сами не по шпаргалке и не упустили один существенный момент про который позже)
17 напишите что именно произошло в тексте домашнего задания
18 у вас есть идеи почему? ведь права то дали?
19 посмотрите на список таблиц
20 подсказка в шпаргалке под пунктом 20
21 а почему так получилось с таблицей (если делали сами и без шпаргалки то может у вас все нормально)***

Я тут пошел не много не по тому маршруту.
По итогу, таблицу создали в нужной схеме, а запрос сейчас выполнили без указания схемы.

Вот так:
>testdb=>select * from testnm.t1;
>
>с1;
>
>1;
>
>(1 row);
>
все работает.</br>
Или как вариант, можно задать search_path.


### 22 вернитесь в базу данных testdb под пользователем postgres

>$ sudo -u postgres psql
>
>psql (14.7 (Ubuntu 14.7-0ubuntu0.22.04.1))
>
>postgres=# </br>
>
>postgres=# \c testdb;<br>
> 
> You are now connected to database "testdb" as user "postgres".<br>


### 23 удалите таблицу t1

>testdb=# drop table testnm.t1;
>
>DROP TABLE

### 24 создайте ее заново

>testdb=# create table testnm.t1 (c1 int);
>
>CREATE TABLE

### 25 вставьте строку со значением c1=1

>testdb=# insert into testnm.t1(c1) values(1);
>
>INSERT 0 1

### 26 зайдите под пользователем testread в базу данных testdb

>quit;
>
>
>$ psql -h 127.0.0.1 -U testread -d testdb -W
>
>Password:
>
>psql (14.7 (Ubuntu 14.7-0ubuntu0.22.04.1))
>
>SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
>
>Type "help" for help.
>
>testdb=>

### 27 сделайте select * from testnm.t1;

>testdb=> select * from testnm.t1;
>
>ERROR:  permission denied for table t1

### 28 получилось?

Нет, потому что мы дали роли readonly права на выборку из **существующих** таблиц, а потом пересоздали testnm.t1.

### 30 как сделать так чтобы такое больше не повторялось? если нет идей - смотрите шпаргалку

Надо дать роли readonly права на доступ к таблицам схемы testnm по умолчанию. (Делаем из под пользователя postgres)
>postgres=# \c testdb;
>
>You are now connected to database "testdb" as user "postgres".
>
>testdb=# ALTER DEFAULT PRIVILEGES in SCHEMA testnm GRANT SELECT ON TABLES TO readonly;
>
>ALTER DEFAULT PRIVILEGES


31 сделайте select * from testnm.t1;
32 получилось?
33 есть идеи почему? если нет - смотрите шпаргалку
31 сделайте select * from testnm.t1;
32 получилось?
33 ура!
34 теперь попробуйте выполнить команду create table t2(c1 integer); insert into t2 values (2);
35 а как так? нам же никто прав на создание таблиц и insert в них под ролью readonly?
36 есть идеи как убрать эти права? если нет - смотрите шпаргалку
37 если вы справились сами то расскажите что сделали и почему, если смотрели шпаргалку - объясните что сделали и почему выполнив указанные в ней команды
38 теперь попробуйте выполнить команду create table t3(c1 integer); insert into t2 values (2);
39 расскажите что получилось и почему
