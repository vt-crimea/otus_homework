
## Анализ сетевого протокола Postgres. ##
## Разработка утилиты для перехвата и анализа пакетов PostgreSQL. (pgtracer) ##

### Вступление ###
Когда я перешел с MSSQL на PostgreSQL, мне сильно не хватало инструмента наподобие SQL Profiler. Весь (достаточно богатый) ассортимент средств мониторинга PostgreSQL во-первых не слишком удобен для нередкой задачи разработчика БД - посмотреть, а что там сейчас делал клиент и в какой последовательности? А во-вторых, в pg_stat_activity, pg_stat_statements, pg_top, zabbix и т.п. я часто встречал запросы наподобие select * from table where id=$1. Чему равно $1- неизвестно, а зачастую это важно, например, чтобы воспроизвести ошибку, возникающую строго при определенных условиях (параметрах).
Что же это за запросы?
Дело в том, что Postgres поддерживает 2 варианта протокола  - Simple Query Protocol и Extended Query Protocol
https://www.postgresql.org/docs/current/protocol-flow.html
В 1м варианте запрос передается "как есть", а во 2м есть возможность передать отдельно параметры.
Выбор протокола зависит от клиента (драйвера) - возможно как использование только одного из вариантов всегда, так и обоих по ситуации.


### Постановка проблемы ###
Разработать средство, способное мониторить активность в Postgres в реальном времени, видеть запросы в порядке их  выполнения (не как pg_stat_activity - только текущие),
видеть запросы с параметрами, т.е. понимать как Simple Protocol, так и Extended.


### Краткое описание ###
Утилита представляет из себя tcp-сниффер с парсингом пакетов, с возможностью сохранения их в БД и веб-интерфейсом для удобства просмотра.
Может работать как на сервере PostreSQL, так и на клиенте.

Сам проект:
https://github.com/vt-crimea/pgtracer

Скрипты для создания тестовой БД:
https://github.com/vt-crimea/otus_homework/blob/main/project/test_db.sql

Тестовый пример вызова функции с параметрами из приложения:
https://github.com/vt-crimea/otus_homework/tree/main/project/pgtest

Пример запроса к полученным данным:
https://github.com/vt-crimea/otus_homework/blob/main/project/query_trace.sql

Источники:
Описание сетевого протокола PostgreSQL:
https://github.com/vt-crimea/otus_homework/blob/main/project/330_postgres-for-the-wire.pdf,
https://www.postgresql.org/docs/, https://metanit.com/go/


