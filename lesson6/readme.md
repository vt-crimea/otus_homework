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
### проинициализируйте диск согласно инструкции и подмонтировать файловую систему
Нашли наш диск, это /dev/sdb:
<img width="353" alt="6_lsblk" src="https://user-images.githubusercontent.com/44090170/223162438-0d54fec1-7e94-4922-a6e3-553fcaad0b61.png">
<img width="353" alt="6_lsblk" src="https://user-images.githubusercontent.com/44090170/223162139-7a5f976c-a26b-4546-8435-2ced9f9484b9.png">

Далее по инструкции создаем метку, размечаем и создаем файловую систему:
<img width="292" alt="8_parted" src="https://user-images.githubusercontent.com/44090170/223162972-d139ab65-5c25-4c3b-8dcc-18a594d0fad9.png">
<img width="383" alt="9_create_fs" src="https://user-images.githubusercontent.com/44090170/223162993-f7a7d1b9-4d55-426c-babb-fb7c77a22d3f.png">

Успешно:
<img width="681" alt="10_lsblk_after_create_fs" src="https://user-images.githubusercontent.com/44090170/223163035-2dee38ce-dfaf-426d-90ef-7d0924c1c693.png">

Создаем папку /mnt/data и монтируем:
<img width="293" alt="11_mount" src="https://user-images.githubusercontent.com/44090170/223163128-5d1110f2-dbe2-452d-b9e3-8db5ef22e8b7.png">

Сразу меняем fstab, чтобы после загрузки наш диск примонтировался автоматически:
<img width="604" alt="12_fstab_edit" src="https://user-images.githubusercontent.com/44090170/223163528-63d54c29-7fbe-481a-b2de-7d650f036c36.png">

перезагружаем и проверяем:
<img width="690" alt="13_lsblk_after_reboot" src="https://user-images.githubusercontent.com/44090170/223163606-d5a53e9e-1154-4181-aca9-d2df0680a8cd.png">


