в бд workplace 

create database название

create schema lecture_4

set search_path to lecture_4

======================== Создание таблиц ========================
1. Создайте таблицу "автор" с полями:
- id 
- имя
- псевдоним (может не быть)
- дата рождения
- город рождения
- родной язык
* Используйте 
    CREATE TABLE table_name (
        column_name TYPE column_constraint,
    );
* для id подойдет serial, ограничение primary key
* Имя и дата рождения - not null
* город и язык - внешние ключи

create table author (
	author_id serial primary key,
	author_name varchar(150) not null,
	nick_name varchar(150),
	born_date date not null check (date_part('year', born_date) > 1700),
	city_id int2 not null references city(city_id),
	--language_id int2 not null references language(language_id),
	created_at timestamp not null default now(),
	deleted boolean not null default false
	--deleted int2 not null default 0 check (deleted in (0, 1))
)

integer
sequence 
default nextval(sequence)

uuid 5-4-6-10
char(32) check (val ~ [aZ])

1*  Создайте таблицы "Язык", "Город", "Страна".
* для id подойдет serial, ограничение primary key
* названия - not null и проверка на уникальность

create table city (
	city_id serial primary key,
	city_name varchar(150) not null,
	country_id int2 not null references country(country_id)
)

create table country (
	country_id serial primary key,
	country_name varchar(150) not null
)

create table language (
	language_id serial primary key,
	language_name varchar(150) not null
)

== Отношения ==

один к одному

create table author_language (
	author_id int not null references author(author_id) unique,
	language_id int not null references language(language_id) unique
)

1 1
2 3
3 2

один ко многим

create table author_language (
	author_id int not null references author(author_id),
	language_id int not null references language(language_id) unique
)

1 1
1 2
2 3
2 4

многие ко многим

create table author_language (
	author_id int references author(author_id),
	language_id int references language(language_id),
	primary key (author_id, language_id)
)

1 1
1 2
2 1

======================== Заполнение таблицы ========================

2. Вставьте данные в таблицу с языками:
'Русский', 'Французский', 'Японский'
* Можно вставлять несколько строк одновременно:
    INSERT INTO table (column1, column2, …)
    VALUES
     (value1, value2, …),
     (value1, value2, …) ,...;

insert into "language" (language_name)
values ('Русский'), ('Французский'), ('Японский')

select * from "language" 

insert into "language" 
values (4, 'Немецкий')

insert into "language" (language_name)
values ('Английский')

-- демонстрация работы счетчика и сброс счетчика
select * from language_language_id_seq

alter sequence language_language_id_seq restart with 100

insert into "language" (language_name)
values ('Китайский')

drop table language

create table language (
	language_id integer primary key generated always as identity,
	language_name varchar(150) not null
)

--Работает начиная с 13 версии PostgreSQL
create table a (
	id serial primary key,
	a int not null,
	b int not null,
	result int not null generated always as (a * b * .8) stored
)

insert into a (a , b)
values (10,10), (5, 10)

select * from a

insert into a (a , b)
values (10,10)

2.1 Вставьте данные в таблицу со странами из таблиц country базы dvd-rental:

select * from country c

insert into country (country_id, country_name)
select country_id, country
from public.country 

alter sequence language_language_id_seq restart with 110

2.2 Вставьте данные в таблицу с городами соблюдая связи из таблиц city базы dvd-rental:

insert into city(city_name, country_id)
select city, country_id
from public.city 

select * from city


2.3 Вставьте данные в таблицу с авторами, идентификаторы языков и городов оставьте пустыми.
Жюль Верн, 08.02.1828
Михаил Лермонтов, 03.10.1814
Харуки Мураками, 12.01.1949

select * from author 

insert into author (author_name, nick_name, born_date, city_id)
values ('Жюль Верн', null, '08.02.1828', 50),
('Михаил Лермонтов', 'Диарбекир', '03.10.1814', 100),
('Харуки Мураками', null, '12.01.1949', 1)

create extension "uuid-ossp"

select uuid_generate_v4()

======================== Модификация таблицы ========================

3. Добавьте поле "идентификатор языка" в таблицу с авторами
* ALTER TABLE table_name 
  ADD COLUMN new_column_name TYPE;

select * from author
 
-- добавление нового столбца
alter table author add column language_id int2

-- удаление столбца
alter table author drop column language_id

-- добавление ограничения not null
alter table author alter column language_id set not null
 
-- удаление ограничения not null
alter table author alter column language_id drop not null

-- добавление ограничения unique
alter table author add constraint author_name_unique unique (author_name)

-- удаление ограничения unique
alter table author drop constraint author_name_unique

-- изменение типа данных столбца
alter table author alter column language_id type text

получить значения
выгрузить в память
удалить значения
поменять тип данных 
внести значения из памяти

alter table author alter column language_id type int2 using(language_id::int2)

получить значения
выгрузить в память и приводим к новому типу данных
удалить значения
поменять тип данных 
внести значения из памяти

alter table author alter column author_name type varchar(200) 

получить значения
выгрузить в память 
удалить значения
поменять тип данных 
меняем разметку на жестком диске
внести значения из памяти

update pg_attribute set atttypmod = 150+4
where attrelid = 'author'::regclass and attname = 'author_name';
 
 3* В таблице с авторами измените колонку language_id - внешний ключ - ссылка на языки
 * ALTER TABLE table_name ADD CONSTRAINT constraint_name constraint_definition
 
alter table author add constraint author_language_fkey foreign key (language_id) references language(language_id)
	
-- удаление ограничения внешнего ключа

alter table author drop constraint author_language_fkey

 ======================== Модификация данных ========================

4. Обновите данные, проставив корректное языки писателям:
Жюль Габриэль Верн - Французский
Михаил Юрьевич Лермонтов - Российский
Харуки Мураками - Японский
* UPDATE table
  SET column1 = value1,
   column2 = value2 ,...
  WHERE
   condition;

select * from author a

3	Жюль Верн
4	Михаил Лермонтов
5	Харуки Мураками

select * from "language" l

1	Русский
2	Французский
3	Японский

update author
set language_id = 1
where author_id = 4

update author
set language_id = 1

update author
set language_id = 3
where author_id in (4, 3)

update author
set language_id = (select language_id from "language" where language_name = 'Русский')
where author_id = (select author_id from author where author_name = 'Михаил Лермонтов')

update author
set language_id = 2, nick_name = 'отсутствует'
where author_id = 5

4*. Дополните оставшие связи по городам:

 ======================== Удаление данных ========================
 
5. Удалите Лермонтова

delete from author
where author_id = 4

truncate author

select * from author a

5.1 Удалите все города

delete from city

select * from city

drop table author

drop table city

drop table author cascade

select * from author a

select * from "language" l

delete from language

при каскадном удалении таблицы удалется ограничение которое мешает, данные сохраняются

при каскадном удалении по внешнему ключу удаляются данные

----------------------------------------------------------------------------

create table author (
	author_id serial primary key,
	author_name varchar(150) not null,
	nick_name varchar(150),
	born_date date not null check (date_part('year', born_date) > 1700),
	city_id int2 not null references city(city_id),
	language_id int2 not null references language(language_id) on delete cascade,
	created_at timestamp not null default now(),
	deleted boolean not null default false
	--deleted int2 not null default 0 check (deleted in (0, 1))
)

create table language (
	language_id serial primary key,
	language_name varchar(150) not null
)

select * from "language" l

insert into "language" (language_name)
values ('Русский'), ('Французский'), ('Японский')

insert into author (author_name, nick_name, born_date, city_id, language_id)
values ('Жюль Верн', null, '08.02.1828', 50, 1),
('Михаил Лермонтов', 'Диарбекир', '03.10.1814', 100, 2),
('Харуки Мураками', null, '12.01.1949', 1, 3)

create temporary table customers_temp as (select * from public.customer)

select * 
from customers_temp

delete from customers_temp
where customer_id < 100

insert into customers_temp
values (1,	1,	'MARY',	'SMITH',	'MARY.SMITH@sakilacustomer.org',	5,	true,	'2006-02-14',	'2006-02-15 04:57:20',	1)

alter table customers_temp drop column last_name

create table cust_temp as (select * from customers_temp)

select * from cust_temp

drop table cust_temp

explain analyze --320
select distinct customer_id
from payment 
where amount > 10

create table payment_new (like payment) partition by range (amount)

create table paymnet_low partition of payment_new for values from (minvalue) to (10)

create table paymnet_high partition of payment_new for values from (10) to (maxvalue)

select * from payment_new

insert into payment_new
select * from payment

explain analyze
select * from only payment_new

select * from paymnet_high

explain analyze --3.50
select distinct customer_id
from paymnet_high

explain analyze --3.85
select distinct customer_id
from payment_new 
where amount > 8

select *
from paymnet_high 

update payment_new
set amount = 12.99
where payment_id = 1

create table customer_new (like customer) partition by list (lower(left(last_name, 1)))

create table customer_a_m partition of customer_new for values in ((select * from a))

create table customer_n_z partition of customer_new for values in ('n', 'o', 'p', 'q')

insert into customer_new
select * from customer
where lower(left(last_name, 1)) in ('a', 'b', 'c', 'd', 'n', 'o', 'p', 'q')

select * from customer_a_m

drop table customer_new

1-26

create table a(val text)

insert into a 
values ('a'), ('b'), ('c')