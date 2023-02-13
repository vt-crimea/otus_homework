## Установка и настройка PostgteSQL в контейнере Docker
### • Создать ВМ с Ubuntu 20.04/22.04 или развернуть докер любым удобным способом

Создаем виртуальную машину в VirtualBox: </br>
<img width="593" alt="1_create_vm" src="https://user-images.githubusercontent.com/44090170/218348814-b56f32de-6ba9-436e-b1f3-276ecaef370c.png">
<img width="644" alt="2_vm_created" src="https://user-images.githubusercontent.com/44090170/218348919-9f839ff6-b6ef-4a93-aade-78c3ecebfe3f.png"></br>

Качаем образ Ubuntu: https://releases.ubuntu.com/releases/22.04/ubuntu-22.04.1-live-server-amd64.iso и выбираем его в качестве загрузочного диска после запуска виртуальной машины: </br>
<img width="325" alt="3_install_ubultu" src="https://user-images.githubusercontent.com/44090170/218349198-21601ad0-2947-4ba5-b3ba-8eb39709da54.png"></br>
Жмем "продолжить" и наслаждаемся процессом. Все опции при установке - по умолчанию. </br>

Выбираем тип сетевого подключения "сетевой мост": </br>
<img width="237" alt="3_1_network_settongs_vbox" src="https://user-images.githubusercontent.com/44090170/218349604-16d373fb-e928-44bc-bfe1-247622e1d616.png">

### • Поставить Docker Engine
Ставлю Docker с помощью автоматического скрипта:
>$ sudo https://docs.docker.com/engine/install/ubuntu/
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && rm get-docker.sh && sudo usermod -aG docker $USER </br>

### • Сделать каталог /var/lib/postgres </br>
>$ sudo mkdir /var/lib/postgres </br>

### • Развернуть контейнер с PostgreSQL 14 смонтировав в него /var/lib/postgres
Предварительно создаем сеть dockera: </br>
<img width="334" alt="4_1_docker_network" src="https://user-images.githubusercontent.com/44090170/218350828-0a0ab99c-7b06-431a-ab12-b0c12e7baf04.png"></br>
Затем стартуем контейнер: </br>
<img width="855" alt="4_docker_start_postgres" src="https://user-images.githubusercontent.com/44090170/218350161-0b4580d0-85e1-482f-952a-4c33286f3a33.png"> </br>

### • Развернуть контейнер с клиентом postgres. Подключиться из контейнера с клиентом к контейнеру с сервером и сделать таблицу с парой строк </br>
Подключаемся: </br>
<img width="855" alt="4_docker_start_postgres" src="https://user-images.githubusercontent.com/44090170/218351271-f42c4046-2ac6-4536-8b0f-d7baf5382a3f.png"> </br>
Создаем таблицу: </br>
<img width="279" alt="5_create_table" src="https://user-images.githubusercontent.com/44090170/218351319-433ef75c-4929-48ad-a746-99a9ca7ed5ea.png"></br>

### • Подключиться к контейнеру с сервером с ноутбука/компьютера извне инстансов GCP/ЯО/места установки докера
Для разнообразия подключимся dbeaver-ом: </br>
<img width="495" alt="6_connect_from_note" src="https://user-images.githubusercontent.com/44090170/218351532-2fe7920d-0982-4af0-8d55-dac020adac5e.png"> </br>
Заглянем в нашу таблицу:</br>
<img width="151" alt="7_select_from_dbeaver" src="https://user-images.githubusercontent.com/44090170/218351664-df30ba96-2b78-4ad8-b8f5-8d8c9d4ff52f.png"> </br>

### • Удалить контейнер с сервером
<img width="634" alt="8_remove_container" src="https://user-images.githubusercontent.com/44090170/218351852-406dba02-1a4e-4b00-870c-aa3f62d840f9.png"> </br>

*Заглянем в каталог /var/lib/postgres - все файлы на месте:* </br>
<img width="473" alt="9_postgres_dir_content" src="https://user-images.githubusercontent.com/44090170/218352196-5bd7fcc6-c5c3-4f25-b4c0-8304031118dc.png"> </br>
*значит при пересоздании контейнера, мы не потеряем наши данные.* </br>

### • Создать его заново
<img width="834" alt="10_dcoker_start_postgress_again" src="https://user-images.githubusercontent.com/44090170/218352243-ae1a4ee0-7d42-4c9f-b84e-582c0c63f940.png"> </br>

### • Проверить, что данные остались на месте </br>
<img width="600" alt="11_connect_again" src="https://user-images.githubusercontent.com/44090170/218352422-ee4bfd16-5133-4ba9-a2c3-a06054f54f21.png">
