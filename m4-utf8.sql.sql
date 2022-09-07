--=============== ������ 4. ���������� � SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--���� ������: ���� ����������� � �������� ����, �� ������� ����� ����� � ��������� � --���� �������, �������� ������ ���� �� �������� � ������ �������� � ������� �������� --� ���� ����� �����, ���� ����������� � ���������� �������, �� ������� ����� ����� � --� ��� ������� �������.

--������������� ���� ������, ���������� ��� �����������:
--� ���� (����������, ����������� � �. �.);
--� ���������� (�������, ���������� � �. �.);
--� ������ (������, �������� � �. �.).
--��� ������� �� �������: ����-���������� � ����������-������, ��������� ������ �� ������. ������ ������� �� ������� � film_actor.
--���������� � ��������-������������:
--� ������� ����������� ��������� ������.
--� �������������� �������� ������ ������������� ���������������;
--� ������������ ��������� �� ������ ��������� null-��������, �� ������ ����������� --��������� � ��������� ���������.
--���������� � �������� �� �������:
--� ������� ����������� ��������� � ������� ������.

--� �������� ������ �� ������� �������� ������� �������� ������ � ������� �� --���������� � ������ ������� �� 5 ����� � �������.
 
--�������� ������� �����

create table language (language_id serial4 primary key,
language_name varchar(30) unique not null);


--�������� ������ � ������� �����

insert
	into
	language(language_name)
values ('�������'),
('����������'),
('��������'),
('�����������'),
('���������');

select * from language;

--�������� ������� ����������

create table nationality (nationality_id serial4 primary key,
nationality_name varchar(30)unique not null)

--�������� ������ � ������� ����������

insert
	into
	nationality (nationality_name)
values ('�������'),
('����������'),
('�����'),
('��������'),
('�������');

select * from nationality;

--�������� ������� ������

create table country (country_id serial4 primary key,
country_name varchar(50)unique not null);


--�������� ������ � ������� ������

insert
	into
	country (country_name)
values ('������'),
('���'),
('��������'),
('�������'),
('�������');

select * from country;

--�������� ������ ������� �� �������

create table language_nation(language_id int2,
nationality_id int2,
primary key(language_id,
nationality_id),
foreign key (language_id) references language (language_id),
foreign key (nationality_id) references nationality (nationality_id));


--�������� ������ � ������� �� �������

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

--�������� ������ ������� �� �������

create table nation_country(nationality_id int2,country_id int2,
primary key(nationality_id, country_id),
foreign key (nationality_id) references nationality (nationality_id),
foreign key (country_id) references country (country_id));

--�������� ������ � ������� �� �������

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
--======== �������������� ����� ==============


--������� �1 
--�������� ����� ������� film_new �� ���������� ������:
--�   	film_name - �������� ������ - ��� ������ varchar(255) � ����������� not null
--�   	film_year - ��� ������� ������ - ��� ������ integer, �������, ��� �������� ������ ���� ������ 0
--�   	film_rental_rate - ��������� ������ ������ - ��� ������ numeric(4,2), �������� �� ��������� 0.99
--�   	film_duration - ������������ ������ � ������� - ��� ������ integer, ����������� not null � �������, ��� �������� ������ ���� ������ 0
--���� ��������� � �������� ����, �� ����� ��������� ������� ������� ������������ ����� �����.

create table film_new(film_name varchar(255) not null,
film_year int2 check (film_year >0),
film_rental_rate numeric(4,
2) default(0.99),
film_duration int2 not null check(film_duration>0));


--������� �2 
--��������� ������� film_new ������� � ������� SQL-�������, ��� �������� ������������� ������� ������:
--�       film_name - array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindlers List']
--�       film_year - array[1994, 1999, 1985, 1994, 1993]
--�       film_rental_rate - array[2.99, 0.99, 1.99, 2.99, 3.99]
--�   	  film_duration - array[142, 189, 116, 142, 195]
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


--������� �3
--�������� ��������� ������ ������� � ������� film_new � ������ ����������, 
--��� ��������� ������ ���� ������� ��������� �� 1.41

update
	film_new
set
	film_rental_rate = film_rental_rate + 1.41;

select * from film_new;

--������� �4
--����� � ��������� "Back to the Future" ��� ���� � ������, 
--������� ������ � ���� ������� �� ������� film_new

delete
from
	film_new
where
	film_name like 'Back to the Future';

--������� �5
--�������� � ������� film_new ������ � ����� ������ ����� ������

insert
	into
	film_new
values('����������� �����',
1967,
1.45,
115)

--������� �6
--�������� SQL-������, ������� ������� ��� ������� �� ������� film_new, 
--� ����� ����� ����������� ������� "������������ ������ � �����", ���������� �� �������

select
	film_name,
	film_year,
	film_rental_rate,
	film_duration,
	round(film_duration::Numeric / 60, 1)as "������������ ������ � �����"
from
	film_new;

--������� �7 
--������� ������� film_new

drop table film_new;