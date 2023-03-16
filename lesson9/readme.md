## Работа с журналами

### Цель:
### • уметь работать с журналами и контрольными точками
### • уметь настраивать параметры журналов

### Настройте выполнение контрольной точки раз в 30 секунд.

>ALTER SYSTEM SET checkpoint_timeout = '30s';</br>

### 10 минут c помощью утилиты pgbench подавайте нагрузку.

>vt@ubuntu:~$ sudo -u postgres pgbench  -c8 -P 60 -T 600 -U postgres postgres
>
>pgbench (14.7 (Ubuntu 14.7-0ubuntu0.22.04.1)) </br>
>starting vacuum...end.</br>
>progress: 60.0 s, 439.4 tps, lat 18.195 ms stddev 10.193</br>
>progress: 120.0 s, 445.2 tps, lat 17.970 ms stddev 9.849</br>
>progress: 180.0 s, 447.6 tps, lat 17.870 ms stddev 9.958</br>
>progress: 240.0 s, 446.4 tps, lat 17.924 ms stddev 9.994</br>
>progress: 300.0 s, 444.4 tps, lat 18.001 ms stddev 9.949</br>
>progress: 360.0 s, 426.9 tps, lat 18.738 ms stddev 10.393</br>
>progress: 420.0 s, 444.1 tps, lat 18.015 ms stddev 9.948</br>
>progress: 480.0 s, 448.8 tps, lat 17.823 ms stddev 9.763</br>
>progress: 540.0 s, 444.3 tps, lat 18.005 ms stddev 9.938</br>
>progress: 600.0 s, 445.1 tps, lat 17.973 ms stddev 9.997</br>
>transaction type: <builtin: TPC-B (sort of)></br>
>scaling factor: 1</br>
>query mode: simple</br>
>number of clients: 8</br>
>number of threads: 1</br>
>duration: 600 s</br>
>number of transactions actually processed: 265935</br>
>latency average = 18.049 ms</br>
>latency stddev = 10.001 ms</br>
>initial connection time = 30.826 ms</br>
>tps = 443.208086 (without initial connection time)</br>

### Измерьте, какой объем журнальных файлов был сгенерирован за это время. Оцените, какой объем приходится в среднем на одну контрольную точку.
Для этого перед запуском pgbench получили текущую позицию: </br>
>pg_current_wal_insert_lsn </br>
>
>0/B2947E08</br>

После того, как pgbench отработал, сделали то же самое:</br>
>pg_current_wal_insert_lsn </br>
>
>0/CAB47FB0</br>

и получили разницу: </br>
>SELECT '0/CAB47FB0'::pg_lsn - '0/B2947E08'::pg_lsn;</br>
>404750760 </br>

В среднем на одну контрольную точку: </br>
>SELECT ('0/CAB47FB0'::pg_lsn - '0/B2947E08'::pg_lsn)/21;</br>
>19273846</br>

### Проверьте данные статистики: все ли контрольные точки выполнялись точно по расписанию. Почему так произошло?
Не совсем понимаю, как это увидеть в статистике.
SELECT * FROM pg_stat_bgwriter - дает только общее количество. </br>
Я посмотрел по логам. Для этого вначале активируем запись чекпойнта в лог: </br>
>ALTER SYSTEM SET log_checkpoints=TRUE </br>

Затем, после того как pgbench отработал, смотрим что попало в лог postgres:</br>
>cat postgresql-14-main.log | grep "checkpoint "</br>

2023-03-16 17:34:21.607 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:34:36.096 UTC [3414] LOG:  checkpoint complete: wrote 288 buffers (0.2%); 0 WAL file(s) added, 0 removed, 0 recycled; write=14.408 s, sync=0.049 s, total=14.489 s; sync files=16, longest=0.010 s, average=0.004 s; distance=2085 kB, estimate=2085 kB<br>
2023-03-16 17:34:51.112 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:35:06.074 UTC [3414] LOG:  checkpoint complete: wrote 1915 buffers (1.5%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.890 s, sync=0.032 s, total=14.962 s; sync files=18, longest=0.007 s, average=0.002 s; distance=19313 kB, estimate=19313 kB<br>
2023-03-16 17:35:21.088 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:35:36.159 UTC [3414] LOG:  checkpoint complete: wrote 1916 buffers (1.5%); 0 WAL file(s) added, 0 removed, 2 recycled; write=14.985 s, sync=0.036 s, total=15.072 s; sync files=19, longest=0.007 s, average=0.002 s; distance=19550 kB, estimate=19550 kB<br>
2023-03-16 17:35:51.172 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:36:06.126 UTC [3414] LOG:  checkpoint complete: wrote 1906 buffers (1.5%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.887 s, sync=0.036 s, total=14.955 s; sync files=18, longest=0.010 s, average=0.002 s; distance=19640 kB, estimate=19640 kB<br>
2023-03-16 17:36:21.140 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:36:36.126 UTC [3414] LOG:  checkpoint complete: wrote 1949 buffers (1.5%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.912 s, sync=0.033 s, total=14.987 s; sync files=19, longest=0.007 s, average=0.002 s; distance=19539 kB, estimate=19630 kB<br>
2023-03-16 17:36:51.139 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:37:06.059 UTC [3414] LOG:  checkpoint complete: wrote 1939 buffers (1.5%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.852 s, sync=0.027 s, total=14.921 s; sync files=18, longest=0.006 s, average=0.002 s; distance=19477 kB, estimate=19615 kB<br>
2023-03-16 17:37:21.072 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:37:36.125 UTC [3414] LOG:  checkpoint complete: wrote 1937 buffers (1.5%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.984 s, sync=0.030 s, total=15.054 s; sync files=17, longest=0.007 s, average=0.002 s; distance=19534 kB, estimate=19607 kB<br>
2023-03-16 17:37:51.140 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:38:06.101 UTC [3414] LOG:  checkpoint complete: wrote 1903 buffers (1.5%); 0 WAL file(s) added, 0 removed, 2 recycled; write=14.901 s, sync=0.021 s, total=14.962 s; sync files=18, longest=0.005 s, average=0.002 s; distance=19593 kB, estimate=19605 kB<br>
2023-03-16 17:38:21.115 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:38:36.116 UTC [3414] LOG:  checkpoint complete: wrote 1984 buffers (1.5%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.931 s, sync=0.033 s, total=15.001 s; sync files=19, longest=0.005 s, average=0.002 s; distance=19619 kB, estimate=19619 kB<br>
2023-03-16 17:38:51.131 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:39:06.114 UTC [3414] LOG:  checkpoint complete: wrote 1890 buffers (1.4%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.912 s, sync=0.024 s, total=14.983 s; sync files=17, longest=0.006 s, average=0.002 s; distance=19550 kB, estimate=19613 kB<br>
2023-03-16 17:39:21.127 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:39:36.049 UTC [3414] LOG:  checkpoint complete: wrote 1945 buffers (1.5%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.859 s, sync=0.025 s, total=14.922 s; sync files=17, longest=0.006 s, average=0.002 s; distance=19629 kB, estimate=19629 kB<br>
2023-03-16 17:39:51.063 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:40:06.061 UTC [3414] LOG:  checkpoint complete: wrote 1984 buffers (1.5%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.926 s, sync=0.027 s, total=14.998 s; sync files=19, longest=0.006 s, average=0.002 s; distance=19671 kB, estimate=19671 kB<br>
2023-03-16 17:40:21.075 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:40:36.121 UTC [3414] LOG:  checkpoint complete: wrote 1979 buffers (1.5%); 0 WAL file(s) added, 0 removed, 2 recycled; write=14.968 s, sync=0.033 s, total=15.047 s; sync files=16, longest=0.006 s, average=0.002 s; distance=19665 kB, estimate=19671 kB<br>
2023-03-16 17:40:51.137 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:41:06.132 UTC [3414] LOG:  checkpoint complete: wrote 2139 buffers (1.6%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.938 s, sync=0.024 s, total=14.995 s; sync files=19, longest=0.005 s, average=0.002 s; distance=21758 kB, estimate=21758 kB<br>
2023-03-16 17:41:21.147 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:41:36.144 UTC [3414] LOG:  checkpoint complete: wrote 2063 buffers (1.6%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.926 s, sync=0.034 s, total=14.997 s; sync files=22, longest=0.009 s, average=0.002 s; distance=19624 kB, estimate=21545 kB<br>
2023-03-16 17:41:51.156 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:42:06.078 UTC [3414] LOG:  checkpoint complete: wrote 1876 buffers (1.4%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.859 s, sync=0.033 s, total=14.923 s; sync files=18, longest=0.005 s, average=0.002 s; distance=19529 kB, estimate=21343 kB<br>
2023-03-16 17:42:21.092 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:42:36.057 UTC [3414] LOG:  checkpoint complete: wrote 1998 buffers (1.5%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.898 s, sync=0.031 s, total=14.966 s; sync files=20, longest=0.007 s, average=0.002 s; distance=19696 kB, estimate=21179 kB<br>
2023-03-16 17:42:51.072 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:43:06.053 UTC [3414] LOG:  checkpoint complete: wrote 2119 buffers (1.6%); 0 WAL file(s) added, 0 removed, 2 recycled; write=14.912 s, sync=0.031 s, total=14.982 s; sync files=20, longest=0.006 s, average=0.002 s; distance=19477 kB, estimate=21009 kB<br>
2023-03-16 17:43:21.067 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:43:36.145 UTC [3414] LOG:  checkpoint complete: wrote 1913 buffers (1.5%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.975 s, sync=0.056 s, total=15.078 s; sync files=19, longest=0.010 s, average=0.003 s; distance=19674 kB, estimate=20875 kB<br>
2023-03-16 17:43:51.159 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:44:06.073 UTC [3414] LOG:  checkpoint complete: wrote 1869 buffers (1.4%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.854 s, sync=0.022 s, total=14.914 s; sync files=18, longest=0.005 s, average=0.002 s; distance=18906 kB, estimate=20678 kB<br>
2023-03-16 17:44:21.087 UTC [3414] LOG:  checkpoint starting: time<br>
2023-03-16 17:44:36.112 UTC [3414] LOG:  checkpoint complete: wrote 2050 buffers (1.6%); 0 WAL file(s) added, 0 removed, 1 recycled; write=14.980 s, sync=0.024 s, total=15.026 s; sync files=19, longest=0.005 s, average=0.002 s; distance=19639 kB, estimate=20574 kB<br>

Тут мы видим, что контрольные точки выполняются +- по расписанию. </br>
В вопросе же скорей всего имелось в виду, что процесс записи на диск будет выполняться в течении интервала, заданного checkpoint_completion_target.
Контрольная точка - скорей не точка, а отрезок.
Этот интервал (15с) мы и видим между checkpoint starting и checkpoint complete.

### Сравните tps в синхронном/асинхронном режиме утилитой pgbench. Объясните полученный результат.
Включаем асинхронный режим:
>ALTER SYSTEM SET synchronous_commit = 'off';

затем рестартуем postgresql и запускаем pgbench по новой с теми же параметрами: </br>
>root@ubuntu:/var/log/postgresql# systemctl restart postgresql</br>
>root@ubuntu:/var/log/postgresql# sudo -u postgres pgbench  -c8 -P 60 -T 600 -U postgres postgres</br>
>
>pgbench (14.7 (Ubuntu 14.7-0ubuntu0.22.04.1))</br>
>starting vacuum...end.</br>
>progress: 60.0 s, 1276.9 tps, lat 6.261 ms stddev 4.030</br>
>progress: 120.0 s, 1263.5 tps, lat 6.330 ms stddev 4.146</br>
>progress: 180.0 s, 1266.3 tps, lat 6.318 ms stddev 4.161</br>
>progress: 240.0 s, 1268.2 tps, lat 6.307 ms stddev 4.069</br>
>progress: 300.0 s, 1256.7 tps, lat 6.366 ms stddev 4.390</br>
>progress: 360.0 s, 1239.1 tps, lat 6.456 ms stddev 4.698</br>
>progress: 420.0 s, 1258.9 tps, lat 6.355 ms stddev 4.131</br>
>progress: 480.0 s, 1289.6 tps, lat 6.203 ms stddev 4.094</br>
>progress: 540.0 s, 1280.6 tps, lat 6.247 ms stddev 4.064</br>
>progress: 600.0 s, 1293.7 tps, lat 6.183 ms stddev 4.024</br>
>transaction type: <builtin: TPC-B (sort of)></br>
>scaling factor: 1</br>
>query mode: simple</br>
>number of clients: 8</br>
>number of threads: 1</br>
>duration: 600 s</br>
>number of transactions actually processed: 761616</br>
>latency average = 6.302 ms</br>
>latency stddev = 4.185 ms</br>
>initial connection time = 28.930 ms</br>
>tps = 1269.335938 (without initial connection time)</br>

Как видно из полученного результата, tps увеличился почти в 3 раза. </br>
Это происходит потому, что в асинхронном режиме сервер сообщает об успешном завершении сразу, как только транзакция будет завершена логически, прежде чем сгенерированные записи WAL фактически будут записаны на диск.


### Создайте новый кластер с включенной контрольной суммой страниц. Создайте таблицу. Вставьте несколько значений. Выключите кластер. Измените пару байт в таблице. 

Создаем кластер:

>pg_createcluster 14 new -p 5433 -- --data-checksums </br>
>Creating new PostgreSQL cluster 14/new ...</br>
>/usr/lib/postgresql/14/bin/initdb -D /var/lib/postgresql/14/new --auth-local peer --auth-host scram-sha-256 --no-instructions --data-checksums</br>
>The files belonging to this database system will be owned by user "postgres".</br>
>This user must also own the server process.</br>
>
>The database cluster will be initialized with locale "ru_RU.UTF-8".</br>
>The default database encoding has accordingly been set to "UTF8".</br>
>The default text search configuration will be set to "russian".</br>
>
>Data page checksums are enabled.</br>
>
>fixing permissions on existing directory /var/lib/postgresql/14/new ... ok</br>
>creating subdirectories ... ok</br>
>selecting dynamic shared memory implementation ... posix</br>
>selecting default max_connections ... 100</br>
>selecting default shared_buffers ... 128MB</br>
>selecting default time zone ... Etc/UTC</br>
>creating configuration files ... ok</br>
>running bootstrap script ... ok</br>
>performing post-bootstrap initialization ... ok</br>
>syncing data to disk ... ok</br>
>Ver Cluster Port Status Owner    Data directory             Log file</br>
>14  new     5433 down   postgres /var/lib/postgresql/14/new /var/log/postgresql/postgresql-14-new.log</br>

Запускаем его:</br>
pg_ctlcluster 14 new start
>sudo -u postgres psql -p 5433</br>
>
>psql (14.7 (Ubuntu 14.7-0ubuntu0.22.04.1))</br>
>Type "help" for help.</br>

Создаем таблицу:
>postgres=# create table test(id int, name varchar);</br>
>CREATE TABLE</br>

Вставляем в нее строку:</br>

>postgres=# insert into test(id,name) values (1,'qqq');</br>
>
>INSERT 0 1

Находим, в каком каталоге база: </br>
>postgres=# SELECT oid, datname FROM pg_catalog.pg_database;</br>
>  oid  |  datname</br>
>-------+-----------</br>
> 13761 | postgres</br>
>     1 | template1</br>
> 13760 | template0</br>
>(3 rows)</br>

Находим, в каком файле находится таблица:
>postgres=# SELECT relname, relfilenode FROM pg_class where relname='test';</br>
> relname | relfilenode</br>
>---------+-------------</br>
> test    |       16384</br>
>(1 row)</br>

Изменяем содержимое файла /var/lib/postgresql/14/new/base/13761/16384

### Включите кластер и сделайте выборку из таблицы. Что и почему произошло? как проигнорировать ошибку и продолжить работу?

В результате кластер включился успешно, выборка из таблицы давала 0 записей.
Воспроизвести сбой не удалось, но в случае сбоя, чтобы проигнорировать ошибку, надо установить параметр конфигурации ignore_checksum_failure = on
