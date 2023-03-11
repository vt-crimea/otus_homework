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

