# sql42
Netology SQL42
Инструкция по установке ПО https://docs.google.com/document/d/1p2CufXVD0xB_hUcsen1nLNCjdNc2DpP3KawVmqoIFvA/edit?usp=sharing
Полезные материалы https://letsdocode.ru/sql-main/info
если забыли пароль от учетной записи при установке постгре
переустановка ничего не изменит
только переустановка операционной системы
что делать в этом случае
pg_hba.conf открыть в блокноте
в самом низу файла заменяем 4 нижних md5 на trust
в Postgres14 Будет на md5, а sha256, их аналогнично меняем на trust и сохраняем файл
ОТкрываем в windows службы (локальные) и перезапускаем  Postgre SQL server
Потом открываем DBeaver- редактировать соединение - убираем пароль - ок - сможем подключиться к бд
дальше в редакторе sql пишем: alter role postgres password ‘123’ - простой новый пароль
после выполнения. опять открываем pg_hba.conf и меняем обратно trust на md5 ( или sha256)
опять перезапускаем службу, открываем Dbeaver - редактировать соединение - главное - пароль - указываем новый пароль (‘123’)
