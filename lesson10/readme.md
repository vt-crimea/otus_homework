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

pid  |locktype     |lockid |mode            |granted|</br>
11023|transactionid|4050824|ExclusiveLock   |true   | - "самоблокировка" транзакции </br>
11532|transactionid|4050824|ShareLock       |false  | - "самоблокировка" транзакции </br>
11532|transactionid|4050825|ExclusiveLock   |true   | - "самоблокировка" транзакции </br>
11544|transactionid|4050827|ExclusiveLock   |true   | - "самоблокировка" транзакции </br>

11544|relation     |test   |RowExclusiveLock|true   | - блокировка таблицы (на уровне строки)</br> 
11023|relation     |test   |RowExclusiveLock|true   | - блокировка таблицы (на уровне строки)</br>
11532|relation     |test   |RowExclusiveLock|true   | - блокировка таблицы (на уровне строки)</br>

11532|tuple        |test:5 |ExclusiveLock   |true   | - блокировка версии строки</br>
11544|tuple        |test:5 |ExclusiveLock   |false  | - блокировка версии строки</br>

### 3. Воспроизведите взаимоблокировку трех транзакций. Можно ли разобраться в ситуации постфактум, изучая журнал сообщений?

В 1м окне:</br>
>begin; </br>
>update test set name = 'a' where id=1;</br>

Во 2м окне:</br>
>begin;</br>
>update test set name = 'b' where id=2;</br>

В 3м окне:</br>
>begin;</br>
>update test set name = 'c' where id=3;</br>

Возвращаюсь в 1е:</br>
>begin;</br>
>update test set name = 'a' where id=3;</br>

2е:</br>
>begin;</br>
>update test set name = 'b' where id=1;</br>

3е:</br>
>begin;</br>
>update test set name = 'c' where id=2;</br>

В логе:

2023-03-17 13:41:11.551 UTC [14346] postgres@testdb ERROR:  deadlock detected</br>
2023-03-17 13:41:11.551 UTC [14346] postgres@testdb DETAIL:  Process 14346 waits for ShareLock on transaction 4050876; blocked by process 14347.</br>
        Process 14347 waits for ShareLock on transaction 4050875; blocked by process 14345.</br>
        Process 14345 waits for ShareLock on transaction 4050877; blocked by process 14346.</br>
        Process 14346: UPDATE test SET name = 'b' WHERE id = 2</br>
        Process 14347: UPDATE test SET name = 'b' WHERE id = 1</br>
        Process 14345: UPDATE test SET name = 'c' WHERE id = 3</br>


### 4. Могут ли две транзакции, выполняющие единственную команду UPDATE одной и той же таблицы (без where), заблокировать друг друга?
Могут, если они будут делать массовое обновление в разном порядке.

### Задание со звездочкой*
### Попробуйте воспроизвести такую ситуацию.

Тестовые данные: </br>
--таблица
>CREATE TABLE accounts (id bigint generated always as identity, name varchar, amount numeric);</br>
>CREATE INDEX ON accounts(amount DESC);</br>
>
>--данные
>INSERT INTO accounts (name, amount)</br>
>SELECT 'abc' AS name, 100\*ROW_NUMBER() OVER (ORDER by gs) AS amount</br>
>FROM generate_series(1, 15) gs</br>
>
>--меделенный апдейт
>CREATE FUNCTION inc_slow(n numeric) RETURNS numeric AS $$</br>
>  SELECT pg_sleep(1);</br>
>    SELECT n + 100.00;</br>
>$$ LANGUAGE SQL;</br>

Теперь в одном окне:</br>
>UPDATE accounts SET amount = inc_slow(amount);

В другом окне:</br>
>SET enable_seqscan = off;</br>
>set enable_bitmapscan = off;</br>
>UPDATE accounts SET amount = inc_slow(amount);</br>

Результат:
 ERROR: deadlock detected </br>
  Подробности: Process 16231 waits for ShareLock on transaction 4050936; blocked by process 16229.</br>
Process 16229 waits for ShareLock on transaction 4050937; blocked by process 16231.



