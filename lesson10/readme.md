## Механизм блокировок

### Цель:
### • понимать как работает механизм блокировок объектов и строк

### 1. Настройте сервер так, чтобы в журнал сообщений сбрасывалась информация о блокировках, удерживаемых более 200 миллисекунд. Воспроизведите ситуацию, при которой в журнале появятся такие сообщения.

Настройка сервера:

>ALTER SYSTEM SET log_lock_waits = 'on';
>
>ALTER SYSTEM SET deadlock_timeout = '200ms';
>
>SELECT pg_reload_conf();
>

Таблица для экспериментов:

>CREATE TABLE test(id int, name varchar);
>
>INSERT into test values(1,'qwqw'),(2,'sdsds'),(3,'sadasdsad');

Теперь открываем 2 окна с psql, в 1м открываем транзакцию и пытаемся изменить какую нибудь строку:
>testdb=# begin;</br>
>BEGIN</br>
>testdb=*# update test set name='qwe' where id=1;</br>
>UPDATE 1</br>
>testdb=*#</br>
(транзакцию не закрываем) </br>

Во 2м пытаемся изменить ту же строку:
>testdb=# update test set name='wer' where id=1;</br>

После отмены транзакции в логе видим записи:</br>
2023-03-16 22:07:34.689 UTC [11023] postgres@testdb LOG:  process 11023 still waiting for ShareLock on transaction 4050818 after 200.260 ms</br>
2023-03-16 22:07:34.689 UTC [11023] postgres@testdb DETAIL:  Process holding the lock: 11030. Wait queue: 11023.</br>
2023-03-16 22:07:34.689 UTC [11023] postgres@testdb CONTEXT:  while updating tuple (0,4) in relation "test"</br>
2023-03-16 22:07:34.689 UTC [11023] postgres@testdb STATEMENT:  update test set name='wer' where id=1;</br>
2023-03-16 22:07:39.234 UTC [11023] postgres@testdb ERROR:  canceling statement due to user request</br>
2023-03-16 22:07:39.234 UTC [11023] postgres@testdb CONTEXT:  while updating tuple (0,4) in relation "test"</br>
2023-03-16 22:07:39.234 UTC [11023] postgres@testdb STATEMENT:  update test set name='wer' where id=1;</br>






### 2. Смоделируйте ситуацию обновления одной и той же строки тремя командами UPDATE в разных сеансах. Изучите возникшие блокировки в представлении pg_locks и убедитесь, что все они понятны. Пришлите список блокировок и объясните, что значит каждая.

### 3. Воспроизведите взаимоблокировку трех транзакций. Можно ли разобраться в ситуации постфактум, изучая журнал сообщений?

### 4. Могут ли две транзакции, выполняющие единственную команду UPDATE одной и той же таблицы (без where), заблокировать друг друга?

Задание со звездочкой*
Попробуйте воспроизвести такую ситуацию.
