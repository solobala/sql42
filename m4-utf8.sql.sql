--=============== МОДУЛЬ 4. УГЛУБЛЕНИЕ В SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--База данных: если подключение к облачной базе, то создаёте новую схему с префиксом в --виде фамилии, название должно быть на латинице в нижнем регистре и таблицы создаете --в этой новой схеме, если подключение к локальному серверу, то создаёте новую схему и --в ней создаёте таблицы.

--Спроектируйте базу данных, содержащую три справочника:
--· язык (английский, французский и т. п.);
--· народность (славяне, англосаксы и т. п.);
--· страны (Россия, Германия и т. п.).
--Две таблицы со связями: язык-народность и народность-страна, отношения многие ко многим. Пример таблицы со связями — film_actor.
--Требования к таблицам-справочникам:
--· наличие ограничений первичных ключей.
--· идентификатору сущности должен присваиваться автоинкрементом;
--· наименования сущностей не должны содержать null-значения, не должны допускаться --дубликаты в названиях сущностей.
--Требования к таблицам со связями:
--· наличие ограничений первичных и внешних ключей.

--В качестве ответа на задание пришлите запросы создания таблиц и запросы по --добавлению в каждую таблицу по 5 строк с данными.
 
--СОЗДАНИЕ ТАБЛИЦЫ ЯЗЫКИ

create table language (language_id serial4 primary key,
language_name varchar(30) unique not null);


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ ЯЗЫКИ

insert
	into
	language(language_name)
values ('русский'),
('английский'),
('немецкий'),
('французский'),
('испанский');

select * from language;

--СОЗДАНИЕ ТАБЛИЦЫ НАРОДНОСТИ

create table nationality (nationality_id serial4 primary key,
nationality_name varchar(30)unique not null)

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ НАРОДНОСТИ

insert
	into
	nationality (nationality_name)
values ('славяне'),
('англосаксы'),
('немцы'),
('французы'),
('испанцы');

select * from nationality;

--СОЗДАНИЕ ТАБЛИЦЫ СТРАНЫ

create table country (country_id serial4 primary key,
country_name varchar(50)unique not null);


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СТРАНЫ

insert
	into
	country (country_name)
values ('Россия'),
('США'),
('Германия'),
('Франция'),
('Испания');

select * from country;

--СОЗДАНИЕ ПЕРВОЙ ТАБЛИЦЫ СО СВЯЗЯМИ

create table language_nation(language_id int2,
nationality_id int2,
primary key(language_id,
nationality_id),
foreign key (language_id) references language (language_id),
foreign key (nationality_id) references nationality (nationality_id));


--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ

insert into language_nation(language_id, nationality_id)
values((select language_id from language where language_id = 1),(select nationality_id from nationality where nationality_id = 1));
insert into language_nation(language_id, nationality_id)
values((select language_id from language where language_id = 2),(select nationality_id from nationality where nationality_id = 2));
insert into language_nation(language_id, nationality_id)
values((select language_id from language where language_id = 3),(select nationality_id from nationality where nationality_id = 3));
insert into language_nation(language_id, nationality_id)
values((select language_id from language where language_id = 4),(select nationality_id from nationality where nationality_id = 4));
insert into language_nation(language_id, nationality_id)
values((select language_id from language where language_id = 5),(select nationality_id from nationality where nationality_id = 5));
select * from language_nation;

--СОЗДАНИЕ ВТОРОЙ ТАБЛИЦЫ СО СВЯЗЯМИ

create table nation_country(nationality_id int2,country_id int2,
primary key(nationality_id, country_id),
foreign key (nationality_id) references nationality (nationality_id),
foreign key (country_id) references country (country_id));

--ВНЕСЕНИЕ ДАННЫХ В ТАБЛИЦУ СО СВЯЗЯМИ

insert into nation_country(nationality_id, country_id)
values ((select nationality_id from nationality where nationality_id = 1),(select country_id from country where country_id = 1));
insert into nation_country(nationality_id, country_id)
values ((select nationality_id from nationality where nationality_id = 2),(select country_id from country where country_id = 2));
insert into nation_country(nationality_id, country_id)
values ((select nationality_id from nationality where nationality_id = 3),(select country_id from country where country_id = 3));
insert into nation_country(nationality_id, country_id)
values ((select nationality_id from nationality where nationality_id = 4),(select country_id from country where country_id = 4));
insert into nation_country(nationality_id, country_id)
values ((select nationality_id from nationality where nationality_id = 5),(select country_id from country where country_id = 5));

select * from nation_country;
--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============


--ЗАДАНИЕ №1 
--Создайте новую таблицу film_new со следующими полями:
--·   	film_name - название фильма - тип данных varchar(255) и ограничение not null
--·   	film_year - год выпуска фильма - тип данных integer, условие, что значение должно быть больше 0
--·   	film_rental_rate - стоимость аренды фильма - тип данных numeric(4,2), значение по умолчанию 0.99
--·   	film_duration - длительность фильма в минутах - тип данных integer, ограничение not null и условие, что значение должно быть больше 0
--Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.

create table film_new(film_name varchar(255) not null,
film_year int2 check (film_year >0),
film_rental_rate numeric(4,
2) default(0.99),
film_duration int2 not null check(film_duration>0));


--ЗАДАНИЕ №2 
--Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
--·       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--·       film_year - array[1994, 1999, 1985, 1994, 1993]
--·       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--·   	  film_duration - array[142, 189, 116, 142, 195]
create table temporary(film_name varchar(255) [],
film_year int2 [],
film_rental_rate numeric(4,
2) [],
film_duration int2 []);

insert into temporary (film_name,film_year,film_rental_rate,film_duration) values('{"The Shawshank Redemption", "The Green Mile", "Back to the Future", "Forrest Gump", "Schindlers List"}',
'{1994, 1999, 1985, 1994, 1993}','{2.99, 0.99, 1.99, 2.99, 3.99}', '{142, 189, 116, 142, 195}');

insert into film_new(film_name,film_year,film_rental_rate,film_duration) 
select film_name[1],film_year[1], film_rental_rate[1], film_duration[1] from temporary;
insert into film_new(film_name,film_year,film_rental_rate,film_duration) 
select film_name[2],film_year[2], film_rental_rate[2], film_duration[2] from temporary;
insert into film_new(film_name,film_year,film_rental_rate,film_duration) 
select film_name[3],film_year[3], film_rental_rate[3], film_duration[3] from temporary;
insert into film_new(film_name,film_year,film_rental_rate,film_duration) 
select film_name[4],film_year[4], film_rental_rate[4], film_duration[4] from temporary;
insert into film_new(film_name,film_year,film_rental_rate,film_duration) 
select film_name[5],film_year[5], film_rental_rate[5], film_duration[5] from temporary;

drop table temporary;
select * from film_new;


--ЗАДАНИЕ №3
--Обновите стоимость аренды фильмов в таблице film_new с учетом информации, 
--что стоимость аренды всех фильмов поднялась на 1.41

update
	film_new
set
	film_rental_rate = film_rental_rate + 1.41;

select * from film_new;

--ЗАДАНИЕ №4
--Фильм с названием "Back to the Future" был снят с аренды, 
--удалите строку с этим фильмом из таблицы film_new

delete
from
	film_new
where
	film_name like 'Back to the Future';

--ЗАДАНИЕ №5
--Добавьте в таблицу film_new запись о любом другом новом фильме

insert
	into
	film_new
values('Джентльмены удачи',
1967,
1.45,
115)

--ЗАДАНИЕ №6
--Напишите SQL-запрос, который выведет все колонки из таблицы film_new, 
--а также новую вычисляемую колонку "длительность фильма в часах", округлённую до десятых

select
	film_name,
	film_year,
	film_rental_rate,
	film_duration,
	round(film_duration::Numeric / 60, 1)as "длительность фильма в часах"
from
	film_new;

--ЗАДАНИЕ №7 
--Удалите таблицу film_new

drop table film_new;