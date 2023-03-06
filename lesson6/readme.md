## Установка и настройка PostgreSQL
### Цель:
### • создавать дополнительный диск для уже существующей виртуальной машины, размечать его и делать на нем файловую систему
### • переносить содержимое базы данных PostgreSQL на дополнительный диск
### • переносить содержимое БД PostgreSQL между виртуальными машинами

### • создайте виртуальную машину c Ubuntu 20.04 LTS (bionic) в GCE/ЯО:
### • поставьте на нее PostgreSQL 14 через sudo apt
Сделано в рамках предыдущих заданий:
https://github.com/vt-crimea/otus_homework/tree/main/lesson2
https://github.com/vt-crimea/otus_homework/tree/main/lesson3
Буду использовать Ubuntu, установленную на VirtualBox.

### проверьте что кластер запущен через sudo -u postgres pg_lsclusters
<img width="449" alt="1_pg_cluster_status" src="https://user-images.githubusercontent.com/44090170/223134817-a1b766c8-b08f-4865-b410-f0a397e5abbd.png">

### зайдите из под пользователя postgres в psql и сделайте произвольную таблицу с произвольным содержимым
<img width="333" alt="2_create_table" src="https://user-images.githubusercontent.com/44090170/223134834-2634a626-ad00-4789-a59f-7fb520671bdf.png">

### остановите postgres например через sudo -u postgres pg_ctlcluster 14 main stop
<img width="304" alt="3_stop_server" src="https://user-images.githubusercontent.com/44090170/223135857-af55b1ef-05b3-4b8c-b88e-3d9a47452d00.png">

### создайте новый standard persistent диск GKE через Compute Engine -> Disks в том же регионе и зоне что GCE инстанс размером например 10GB
В моем случае создаю новый диск для VirtualBox:
<img width="770" alt="4_create_disk_vbox" src="https://user-images.githubusercontent.com/44090170/223139286-b0efe430-53eb-45d2-a42c-5e2358083065.png">


