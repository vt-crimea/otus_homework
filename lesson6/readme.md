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

Нашли наш диск, это /dev/sdb: </br>
<img width="353" alt="6_lsblk" src="https://user-images.githubusercontent.com/44090170/223162438-0d54fec1-7e94-4922-a6e3-553fcaad0b61.png"></br>
<img width="353" alt="6_lsblk" src="https://user-images.githubusercontent.com/44090170/223162139-7a5f976c-a26b-4546-8435-2ced9f9484b9.png"></br>

Далее по инструкции создаем метку, размечаем и создаем файловую систему:</br>
<img width="292" alt="8_parted" src="https://user-images.githubusercontent.com/44090170/223162972-d139ab65-5c25-4c3b-8dcc-18a594d0fad9.png"></br>
<img width="383" alt="9_create_fs" src="https://user-images.githubusercontent.com/44090170/223162993-f7a7d1b9-4d55-426c-babb-fb7c77a22d3f.png"></br>

Успешно:</br>
<img width="681" alt="10_lsblk_after_create_fs" src="https://user-images.githubusercontent.com/44090170/223163035-2dee38ce-dfaf-426d-90ef-7d0924c1c693.png"></br>

Создаем папку /mnt/data и монтируем:</br>
<img width="293" alt="11_mount" src="https://user-images.githubusercontent.com/44090170/223163128-5d1110f2-dbe2-452d-b9e3-8db5ef22e8b7.png"></br>

Сразу меняем fstab, чтобы после загрузки наш диск примонтировался автоматически:</br>
<img width="604" alt="12_fstab_edit" src="https://user-images.githubusercontent.com/44090170/223163528-63d54c29-7fbe-481a-b2de-7d650f036c36.png"></br>

перезагружаем и проверяем:</br>
<img width="690" alt="13_lsblk_after_reboot" src="https://user-images.githubusercontent.com/44090170/223163606-d5a53e9e-1154-4181-aca9-d2df0680a8cd.png"></br>

### сделайте пользователя postgres владельцем /mnt/data - chown -R postgres:postgres /mnt/data/
<img width="290" alt="14_chown" src="https://user-images.githubusercontent.com/44090170/223164651-3fd1ef33-324f-45e8-b795-b21e42776b1f.png"></br>

### перенесите содержимое /var/lib/postgresql/14 в /mnt/data:
<img width="901" alt="15_move_pg_files" src="https://user-images.githubusercontent.com/44090170/223166958-3c6597ae-be8f-440a-9e00-178a8082aba7.png">

### попытайтесь запустить кластер - sudo -u postgres pg_ctlcluster 14 main start
<img width="939" alt="16_start_postgres" src="https://user-images.githubusercontent.com/44090170/223167547-e1d5c0aa-2ba1-462c-a010-54daee94b848.png"></br>
Не получилось, ведь postgres пытается найти каталог данных по старому пути. </br>

### задание: найти конфигурационный параметр в файлах раположенных в /etc/postgresql/14/main который надо поменять и поменяйте его
В файле postgreql.conf надо поменять параметр data_directory: </br>
<img width="460" alt="17_change_dir" src="https://user-images.githubusercontent.com/44090170/223168902-e1133bb7-a623-4e5b-91ec-a874426db89c.png">

### попытайтесь запустить кластер - sudo -u postgres pg_ctlcluster 14 main start
### напишите получилось или нет и почему
<img width="951" alt="18_start_error_no_permission" src="https://user-images.githubusercontent.com/44090170/223170124-01f388e3-6217-4d30-94e7-63768c3928bd.png"> </br>
не получилось, т.к. не настроены разрешения на доступ к каталогу /mnt/data </br>
<img width="497" alt="19_chmod_then_start" src="https://user-images.githubusercontent.com/44090170/223170893-d84d4278-e6e2-4a48-843c-f85729aa86d7.png"> </br>
теперь получилось

### зайдите через через psql и проверьте содержимое ранее созданной таблицы
<img width="330" alt="20_psql_select" src="https://user-images.githubusercontent.com/44090170/223172276-1e0507e8-a3fc-4836-bf98-45c1c3124a61.png"> </br>
Таблица на месте.

### задание со звездочкой \*: не удаляя существующий инстанс ВМ сделайте новый, поставьте на него PostgreSQL, удалите файлы с данными из /var/lib/postgres, перемонтируйте внешний диск который сделали ранее от первой виртуальной машины ко второй и запустите PostgreSQL на второй машине так чтобы он работал с данными на внешнем диске, расскажите как вы это сделали и что в итоге получилось.

Создал новую ВМ и поставил на нее Ubuntu:</br>
<img width="726" alt="21_ubuntu_new" src="https://user-images.githubusercontent.com/44090170/223179930-adbdc5e5-0ecd-4741-9d35-29cd361d34a3.png"></br>

затем установил PostgreSQL:</br>
>$ sudo apt-get install postgresql</br>
<img width="401" alt="22_postgresql_ok" src="https://user-images.githubusercontent.com/44090170/223181052-056acb75-8bfd-4088-a182-3179d7d112b4.png"></br>




