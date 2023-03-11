## Настройка autovacuum с учетом оптимальной производительности
### Цель:
### • запустить нагрузочный тест pgbench
### • настроить параметры autovacuum для достижения максимального уровня устойчивой производительности

### создать GCE инстанс типа e2-medium и диском 10GB
### установить на него PostgreSQL 14 с дефолтными настройками

сделано в рамках предыдущих заданий:</br>
https://github.com/vt-crimea/otus_homework/tree/main/lesson2</br>
https://github.com/vt-crimea/otus_homework/tree/main/lesson3</br>

### применить параметры настройки PostgreSQL из прикрепленного к материалам занятия файла
<img width="302" alt="1_set_params" src="https://user-images.githubusercontent.com/44090170/224489109-e9c6839d-0aee-4174-a6ff-8d99ddfa8581.png">

### выполнить pgbench -i postgres
<img width="460" alt="2_pgbench_i" src="https://user-images.githubusercontent.com/44090170/224489270-1f59b7a9-4619-4e04-b050-6a6728db9995.png">

### запустить pgbench -c8 -P 60 -T 600 -U postgres postgres
### дать отработать до конца
<img width="479" alt="3_pgbench" src="https://user-images.githubusercontent.com/44090170/224489910-55dc1659-1b1c-404d-bb37-a8dddf6ff5b0.png">

### дальше настроить autovacuum максимально эффективно
### построить график по получившимся значениям
### так чтобы получить максимально ровное значение tps

процессор у нас один с одним ядром, поэтому сразу выставляем:</br>
Alter system set autovacuum_max_workers=1;</br>
Больше не имеет смысла.</br>

Остальное по умолчанию:</br>

autovacuum	on </br>
autovacuum_analyze_scale_factor	0.1 </br>
autovacuum_analyze_threshold	50 </br>
autovacuum_freeze_max_age	200000000 </br>
autovacuum_multixact_freeze_max_age	400000000 </br>
autovacuum_naptime	60</br>
autovacuum_vacuum_cost_delay	2</br>
autovacuum_vacuum_cost_limit	-1</br>
autovacuum_vacuum_insert_scale_factor	0.2</br>
autovacuum_vacuum_insert_threshold	1000</br>
autovacuum_vacuum_scale_factor	0.2</br>
autovacuum_vacuum_threshold	50</br>
autovacuum_work_mem	-1</br>

Результат работы pgbench:
>progress: 60.0 s,   447.7 tps, lat 17.855 ms stddev 9.714</br>
>progress: 120.0 s, 444.6 tps, lat 17.992 ms stddev 9.718</br>
>progress: 180.0 s, 445.4 tps, lat 17.961 ms stddev 9.697</br>
>progress: 240.0 s, 446.2 tps, lat 17.929 ms stddev 9.743</br>
>progress: 300.0 s, 430.4 tps, lat 18.589 ms stddev 10.125</br>
>progress: 360.0 s, 439.3 tps, lat 18.212 ms stddev 9.943</br>
>progress: 420.0 s, 442.3 tps, lat 18.087 ms stddev 9.740</br>
>progress: 480.0 s, 442.2 tps, lat 18.092 ms stddev 9.885</br>
>progress: 540.0 s, 439.9 tps, lat 18.188 ms stddev 9.868</br>
>progress: 600.0 s, 441.2 tps, lat 18.133 ms stddev 9.829</br>

>tps = 441.906617 (without initial connection time) </br>

Попробуем выставить более агрессивные настройки: </br>

ALTER SYSTEM SET autovacuum_naptime=15;</br>
ALTER SYSTEM SET autovacuum_vacuum_threshold=25;</br>
ALTER SYSTEM SET autovacuum_vacuum_scale_factor=0.05;</br>
ALTER SYSTEM SET autovacuum_vacuum_cost_delay=10;</br>
ALTER SYSTEM SET autovacuum_vacuum_cost_limit=1000;</br>

>progress: 60.0 s,   444.7 tps, lat 17.978 ms stddev 9.755</br>
>progress: 120.0 s, 440.9 tps, lat 18.143 ms stddev 9.814</br>
>progress: 180.0 s, 440.5 tps, lat 18.161 ms stddev 9.738</br>
>progress: 240.0 s, 436.6 tps, lat 18.322 ms stddev 9.888</br>
>progress: 300.0 s, 436.5 tps, lat 18.328 ms stddev 9.830</br>
>progress: 360.0 s, 436.8 tps, lat 18.312 ms stddev 9.786</br>
>progress: 420.0 s, 435.3 tps, lat 18.378 ms stddev 9.789</br>
>progress: 480.0 s, 435.4 tps, lat 18.374 ms stddev 9.842</br>
>progress: 540.0 s, 420.3 tps, lat 19.034 ms stddev 10.496</br>
>progress: 600.0 s, 434.2 tps, lat 18.423 ms stddev 9.886</br>

>tps = 436.126770 (without initial connection time) </br>

Как видим, производительность просела </br>

Отключим автовакуум вообще:</br>
Alter system set autovacuum='off';</br>

>progress: 60.0 s,   449.4 tps, lat 17.789 ms stddev 9.825</br>
>progress: 120.0 s, 448.8 tps, lat 17.824 ms stddev 9.927</br>
>progress: 180.0 s, 447.1 tps, lat 17.892 ms stddev 9.867</br>
>progress: 240.0 s, 449.1 tps, lat 17.812 ms stddev 9.760</br>
>progress: 300.0 s, 449.5 tps, lat 17.798 ms stddev 9.868</br>
>progress: 360.0 s, 448.8 tps, lat 17.824 ms stddev 9.805</br>
>progress: 420.0 s, 444.8 tps, lat 17.982 ms stddev 9.889</br>
>progress: 480.0 s, 445.7 tps, lat 17.950 ms stddev 9.931</br>
>progress: 540.0 s, 446.3 tps, lat 17.924 ms stddev 9.867</br>
>progress: 600.0 s, 443.0 tps, lat 18.058 ms stddev 9.907</br>

>tps = 447.253578 (without initial connection time)

На графике: </br>
<img width="602" alt="4_graphic" src="https://user-images.githubusercontent.com/44090170/224508477-95ae9b12-4059-4c58-a86f-ec7635dd1667.png">
</br>

Вывод: в данном случае лучше всего использовать максимально щадящие настройки автовакуума.

