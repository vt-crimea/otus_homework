## Работа с журналами

### Цель:
### • уметь работать с журналами и контрольными точками
### • уметь настраивать параметры журналов

### Настройте выполнение контрольной точки раз в 30 секунд.

>ALTER SYSTEM SET checkpoint_timeout = '30s';</br>

### 10 минут c помощью утилиты pgbench подавайте нагрузку.

>vt@ubuntu:~$ sudo -u postgres pgbench  -c8 -P 60 -T 600 -U postgres postgres
>
>pgbench (14.7 (Ubuntu 14.7-0ubuntu0.22.04.1))
>starting vacuum...end.
>progress: 60.0 s, 439.4 tps, lat 18.195 ms stddev 10.193
>progress: 120.0 s, 445.2 tps, lat 17.970 ms stddev 9.849
>progress: 180.0 s, 447.6 tps, lat 17.870 ms stddev 9.958
>progress: 240.0 s, 446.4 tps, lat 17.924 ms stddev 9.994
>progress: 300.0 s, 444.4 tps, lat 18.001 ms stddev 9.949
>progress: 360.0 s, 426.9 tps, lat 18.738 ms stddev 10.393
>progress: 420.0 s, 444.1 tps, lat 18.015 ms stddev 9.948
>progress: 480.0 s, 448.8 tps, lat 17.823 ms stddev 9.763
>progress: 540.0 s, 444.3 tps, lat 18.005 ms stddev 9.938
>progress: 600.0 s, 445.1 tps, lat 17.973 ms stddev 9.997
>transaction type: <builtin: TPC-B (sort of)>
>scaling factor: 1
>query mode: simple
>number of clients: 8
>number of threads: 1
>duration: 600 s
>number of transactions actually processed: 265935
>latency average = 18.049 ms
>latency stddev = 10.001 ms
>initial connection time = 30.826 ms
>tps = 443.208086 (without initial connection time)

### Измерьте, какой объем журнальных файлов был сгенерирован за это время. Оцените, какой объем приходится в среднем на одну контрольную точку.

### Проверьте данные статистики: все ли контрольные точки выполнялись точно по расписанию. Почему так произошло?

### Сравните tps в синхронном/асинхронном режиме утилитой pgbench. Объясните полученный результат.
### Создайте новый кластер с включенной контрольной суммой страниц. Создайте таблицу. Вставьте несколько значений. Выключите кластер. Измените пару байт в таблице. 

### Включите кластер и сделайте выборку из таблицы. Что и почему произошло? как проигнорировать ошибку и продолжить работу?
