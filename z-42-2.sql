������� 1. ���������� ��� ������� ������, ������� ��� ��� ����� � ������, 
� ����� ����� ��������� ������ ������ �� �� �����.
��������� ��������� �������: letsdocode.ru...in/3-7.png

explain analyze  --2904
select f.title, c."name", l."name", count(r.rental_id), sum(p.amount)
from film f
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
join "language" l on l.language_id = f.language_id
group by f.film_id, c.category_id, l.language_id

explain analyze --1276
select f.title, c."name", l."name", t.cr, t.sa
from film f
join (
	select i.film_id, count(r.rental_id) cr, sum(p.amount) sa
	from inventory i 
	join rental r on r.inventory_id = i.inventory_id
	join payment p on p.rental_id = r.rental_id
	group by 1) t on t.film_id = f.film_id
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
join "language" l on l.language_id = f.language_id

1	5
1	3
1	5
1	1

1	5
1	3
1	1	
������� 2. ����������� ������ �� ����������� ������� � �������� � ������� ���� ������, 
������� �� ���� �� ����� � ������.
��������� ��������� �������: letsdocode.ru...in/3-8.png

explain analyze --1227
select f.title, c."name", l."name", t.cr, t.sa
from film f
left join (
	select i.film_id, count(r.rental_id) cr, sum(p.amount) sa
	from inventory i 
	join rental r on r.inventory_id = i.inventory_id
	join payment p on p.rental_id = r.rental_id
	group by 1) t on t.film_id = f.film_id
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
join "language" l on l.language_id = f.language_id
where t.cr is null

explain analyze --2944
select f.title, c."name", l."name", count(r.rental_id), sum(p.amount)
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
join "language" l on l.language_id = f.language_id
group by f.film_id, c.category_id, l.language_id
having count(r.rental_id) = 0

explain analyze --483
select f.title, c."name", l."name", count(r.rental_id), sum(p.amount)
from film f
left join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
join "language" l on l.language_id = f.language_id
where i.inventory_id is null
group by f.film_id, c.category_id, l.language_id

1	2
2	4
3	null
4	7
...
1000
where i_id is null

explain analyze --503
select t.title, c."name", l."name", t.cr, t.sa
from (
	select f.film_id, f.language_id, f.title, count(r.rental_id) cr, sum(p.amount) sa
	from film f 
	left join inventory i on i.film_id = f.film_id
	left join rental r on r.inventory_id = i.inventory_id
	left join payment p on p.rental_id = r.rental_id
	where i.inventory_id is null
	group by 1) t 
join film_category fc on t.film_id = fc.film_id
join category c on c.category_id = fc.category_id
join "language" l on l.language_id = t.language_id

������� 3. ���������� ���������� ������, ����������� ������ ���������. �������� ����������� ������� 
��������. ���� ���������� ������ ��������� 7 300, �� �������� � ������� ����� ���, ����� ������ ���� 
�������� ����.
��������� ��������� �������: letsdocode.ru...in/3-9.png

select s.staff_id, count(p.payment_id),
	case 
		when count(p.payment_id) > 7300 then 'yes'
		else 'no'
	end	
from staff s
left join payment p on p.staff_id =s.staff_id
group by 1

������� 1. �������� ����� ������� film_new �� ���������� ������:
� film_name � �������� ������ � ��� ������ varchar(255) � ����������� not null;
� film_year � ��� ������� ������ � ��� ������ integer, �������, ��� �������� ������ ���� ������ 0;
� film_rental_rate � ��������� ������ ������ � ��� ������ numeric(4,2), �������� �� ��������� 0.99;
� film_duration � ������������ ������ � ������� � ��� ������ integer, ����������� not null � �������, 
��� �������� ������ ���� ������ 0.
���� ��������� � �������� ����, �� ����� ��������� ������� ������� ������������ ����� �����.

create table film_new (
	film_id serial primary key,
	film_name varchar(255) not null,
	film_year integer check (film_year > 0),
	film_rental_rate numeric(4,2) default 0.99,
	film_duration integer not null check (film_duration > 0)
)

������� 2. ��������� ������� film_new ������� � ������� SQL-�������, ��� �������� ������������� ������� ������:
� film_name � array[The Shawshank Redemption, The Green Mile, Back to the Future, Forrest Gump, Schindler�s List];
� film_year � array[1994, 1999, 1985, 1994, 1993];
� film_rental_rate � array[2.99, 0.99, 1.99, 2.99, 3.99];
� film_duration � array[142, 189, 116, 142, 195].

select unnest(array)

select *
from unnest(array, array, array...)

insert into film_new(film_name, film_year, film_rental_rate, film_duration)
select *
from unnest(array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 
		'Forrest Gump', 'Schindler�s List'],
	array[1994, 1999, 1985, 1994, 1993],
	array[2.99, 0.99, 1.99, 2.99, 3.99],
	array[142, 189, 116, 142, 195])

select * from film_new

������� 3. �������� ��������� ������ ������� � ������� film_new � ������ ����������, 
��� ��������� ������ ���� ������� ��������� �� 1.41.

update film_new
set film_rental_rate = film_rental_rate + 1.41

������� 4. ����� � ��������� Back to the Future ��� ���� � ������, ������� ������ � 
���� ������� �� ������� film_new.

delete from film_new
where film_id = 3

������� 5. �������� � ������� film_new ������ � ����� ������ ����� ������.

insert into film_new(film_name, film_year, film_rental_rate, film_duration)
values ('a', 2000, 4., 300)

������� 6. �������� SQL-������, ������� ������� ��� ������� �� ������� film_new, � ����� 
����� ����������� ������� ������������� ������ � ������, ���������� �� �������.

select *, round(film_duration / 60., 1)
from film_new

������� 7. ������� ������� film_new.

drop table film_new


create table a (
	val_1 int, 
	val_2 int,
	foreign key (val_1, val_2) references b(a_val_1, a_val_2)
)

create table b (
	id int ,
	a_val_1 int,
	a_val_2 int,
	unique (a_val_1, a_val_2)
)

create table c (
	val int check (val > 0 and val = 5 and val < 10)
)

alter table b drop column id

select * from b

drop table b

1 	1
1	2

1	1
1	2

select pg_typeof(date_part('year', current_date))

select pg_typeof(date_part('year', current_date) - date_part('year','01.01.2020'::date))

select *
from �����.�������

select substring('hello world', 3, 4)

select substring('hello world' from 3 for 4)

from a 
join b 
join c