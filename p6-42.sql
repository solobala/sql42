============= ������������� =============

4. �������� view � ��������� ������ (���; email) � title ������, ������� �� ���� � ������ ���������
+ �������� �������������:
* �������� CTE, 
- ���������� ������ �� ������� rental, 
- ��������� ����������� row_number() � ���� �� customer_id
- ����������� � ���� ���� �� rental_date �� �������� (desc)
* ���������� customer � ���������� cte 
* ��������� � inventory
* ��������� � film
* ������������ �� row_number = 1

create view task_1 as 
	with cte as (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental)
	select concat(c.last_name, ' ', c.first_name), c.email, f.title
	from cte 
	join customer c on c.customer_id = cte.customer_id
	join inventory i on i.inventory_id = cte.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1

explain analyze --2148
select * 
from task_1
	
4.1. �������� ������������� � 3-�� ������: �������� ������, ��� ������ � ���������� �������, � ������� �� ��������
+ �������� �������������:
* ����������� ������� film
* ��������� � film_actor
* ��������� � actor
* count - ���������� ������� �������� ��������
* ������� ���� � �������������� ����������� over � partition by

create view task_2 as 
	select f.title, concat(a.last_name, ' ', a.first_name), f.film_id,
		count(f.film_id) over (partition by a.actor_id)
	from film f
	join film_actor fa on f.film_id = fa.film_id
	join actor a on a.actor_id = fa.actor_id

drop view 	task_2
	
select t.*, c.name 
from task_2 t 
join film_category fc on fc.film_id = t.film_id
join category c on fc.category_id = c.category_id

============= ����������������� ������������� =============

5. �������� ����������������� ������������� � ��������� ������ (���; email) � title ������, 
������� �� ���� � ������ ���������
�������������� ���������� � �������� ������ � �������������.
+ �������� ����������������� ������������� ��� ���������� (with NO DATA):
* �������� CTE, 
- ���������� ������ �� ������� rental, 
- ��������� ����������� row_number() � ���� �� customer_id
- ����������� � ���� ���� �� rental_date �� �������� (desc)
* ���������� customer � ���������� cte 
* ��������� � inventory
* ��������� � film
* ������������ �� row_number = 1
+ �������� �������������
+ �������� ������

create materialized view task_3 as 
	with cte as (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental)
	select concat(c.last_name, ' ', c.first_name), c.email, f.title
	from cte 
	join customer c on c.customer_id = cte.customer_id
	join inventory i on i.inventory_id = cte.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
--with data

explain analyze --12.99
select * 
from task_3

select 2148 / 13

select 19 / 0.044

refresh materialized view task_3

Mon Jul 11 19:11:14 MSK 2022

5.1. ������� ���������� ����������������� �������������, ����������:
������ ��������� �������, ������� ����������������� ������ ������� ����� 5 ����
+ �������� ����������������� ������������� � ����������� (with DATA)
* ����������� ������� film
* ��������� � �������� film_category
* ��������� � �������� category
* ������������ ���������� ������� �� category.name
* ��� ������ ������ ���������� ������ ����������������� ������ �������
* �������������� ����������� �����, ��� ������ ��������� �� ������� ������������������ > 5 ����
 + �������� ������

create materialized view task_4 as 

explain analyze  --106 / 0.9
	select c."name"
	from film f
	join film_category fc on fc.film_id = f.film_id
	join category c on c.category_id = fc.category_id
	group by c.category_id
	having avg(f.rental_duration) > 5
with no data

drop materialized view task_4

explain analyze --18.5 / 0.008
select * 
from task_4

select 0.9/0.008

REFRESH MATERIALIZED view task_4

explain analyze --20.63 / 0.010
select *
from task_4
where name = 'Classics'

create index t_name_idx on task_4 using hash (name)

drop index t_name_idx

explain analyze --1.1 / 0.010
select *
from task_4
where name = 'Drama'

============ ������� ===========

������ 1.6��
984��
1.7

select * 
from payment 

alter table payment drop constraint payment_pkey

explain analyze --319 / 1
select * 
from payment 
where payment_id = 570

alter table payment add constraint payment_pkey primary key (payment_id)

explain analyze --8.3 / 0.015
select * 
from payment 
where payment_id = 570

select *
from pg_catalog.pg_indexes pi2

create index payment_amount_idx on payment (amount)

select amount, payment_id
from payment 

10 �������� + �������

btree > < = null between in
hash = 
gist 
gin

1-16000
1-8000 8001-16000
1-4000 4001-8000 8001-12000 12001-16000
1-2000
1-1000

explain analyze --8.3 / 0.015
select * 
from payment 
where amount < 5

explain analyze --237.06
select * 
from payment 
where amount < 2

->  Bitmap Heap Scan
  ->  Bitmap Index Scan --118
  
explain analyze
select * 
from payment 
where payment_date::date = '2005-06-15'

create index payment_date_idx on payment using hash (payment_date)

create index payment_date_idx_2 on payment (payment_date)

explain analyze
select * 
from payment 
where payment_date < '2005-06-15'

create index payment_date_idx_3 on payment using hash (cast(payment_date as date))

explain analyze
select * 
from payment 
where payment_date::date = '2005-06-15'

explain analyze
select *
from customer 
where left(last_name, 1) = 'S'

create index last_name_f_l_customer_idx on customer  (left(last_name, 1))

select *
from film f

'academi':{1, 67, 58 }
'battl':15 
'canadian':20 
'dinosaur':2 
'drama':5 
'epic':4 
'feminist':8 
'mad':11 
'must':14 
'rocki':21 
'scientist':12 
'teacher':17

explain analyze
select *
from film 
where fulltext::text like '%rocki%'


create index payment_amount_idx on payment (amount, (amount > 5))

drop index payment_amount_idx

explain analyze
select * 
from payment p
where amount > 9

create index payment_amount_idx_2 on payment (amount, payment_date, customer_id, (amount > 5))

explain analyze
select * 
from payment p
where customer_id = 1 and amount = 9.99 and payment_date = '2005-06-15 21:08:46'

============ explain ===========

������ �� ������ �� ������� ����� ������� 
https://explain.depesz.com/ -- ��������� ����� ���
https://tatiyants.com/pev/
https://habr.com/ru/post/203320/


EXPLAIN [ ( �������� [, ...] ) ] ��������
EXPLAIN [ ANALYZE ] [ VERBOSE ] ��������

����� ����������� ��������:

    ANALYZE [ boolean ]
    VERBOSE [ boolean ]
    COSTS [ boolean ]
    BUFFERS [ boolean ]
    TIMING [ boolean ]
    FORMAT { TEXT | XML | JSON | YAML }

explain analyze
with cte as (
	select *, row_number() over (partition by customer_id order by rental_date desc)
	from rental)
select concat(c.last_name, ' ', c.first_name), c.email, f.title
from cte 
join customer c on c.customer_id = cte.customer_id
join inventory i on i.inventory_id = cte.inventory_id
join film f on f.film_id = i.film_id
where row_number = 1

inner join 
left join 
full join

hash 
nested loop 
merge join
	
end loop

explain analyze
with cte as (
	select *, row_number() over (partition by customer_id order by rental_date desc)
	from rental)
select concat(c.last_name, ' ', c.first_name), c.email, f.title
from cte 
join customer c on c.customer_id = cte.customer_id
join inventory i on i.inventory_id = cte.inventory_id
join film f on f.film_id = i.film_id
where row_number = 1

explain (format json, analyze)
with cte as (
	select *, row_number() over (partition by customer_id order by rental_date desc)
	from rental)
select concat(c.last_name, ' ', c.first_name), c.email, f.title
from cte 
join customer c on c.customer_id = cte.customer_id
join inventory i on i.inventory_id = cte.inventory_id
join film f on f.film_id = i.film_id
where row_number = 1

======================== json ========================
�������� ������� orders
 
CREATE TABLE orders (
     ID serial PRIMARY KEY,
     info json NOT NULL
);

INSERT INTO orders (info)
VALUES
 (
'{"items": {"product": "Beer","qty": 6,"a":345}, "customer": "John Doe"}'
 ),
 (
'{ "customer": "Lily Bush", "items": {"product": "Diaper","qty": 24}}'
 ),
 (
'{ "customer": "Josh William", "items": {"product": "Toy Car","qty": 1}}'
 ),
 (
'{ "customer": "Mary Clark", "items": {"product": "Toy Train","qty": 2}}'
 );
 
select * from orders

INSERT INTO orders (info)
VALUES
 (
'{ "a": { "a": { "a": { "a": { "a": { "c": "b"}}}}}}'
 )
 
 INSERT INTO orders (info)
VALUES
 (
'{ "a": "dddddddddddddddddddddd"}'
 )
 
|{��������_������: quantity, product_id: quantity, product_id: quantity}|����� ����� ������|

6. �������� ����� ���������� �������:
* CAST ( data AS type) �������������� �����
* SUM - ���������� ������� �����
* -> ���������� JSON
*->> ���������� �����

select info, pg_typeof(info)
from orders 

select info->'items', pg_typeof(info->'items')
from orders 

select info->'items'->'qty', pg_typeof(info->'items'->'qty')
from orders 


select info->'items'->>'qty', pg_typeof(info->'items'->>'qty')
from orders 

select sum((info->'items'->>'qty')::numeric)
from orders 

6*  �������� ������� ���������� �������, ��������� ������������ �� "Toy"

select avg((info->'items'->>'qty')::numeric)
from orders 
where info->'items'->>'product' ilike 't%'

--�������� ��� ����� �� json
select json_object_keys(info->'items')
from orders 

======================== array ========================
7. �������� ������� ��� ����������� ����������� ������� (special_features) �
������ -- ������� ��������� �������� ������� special_features
* array_length(anyarray, int) - ���������� ����� ��������� ����������� �������

wish_list [6, 456, 88]
int[]

string '6,456,88'
numeric[]
date[]
text['1', '01.01.2022', 'a']
time['10:00', '12:00'] - x

x[1], x[2]

select title, special_features
from film 

select title, array_length(special_features, 1)
from film 

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::int[], 1)

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::int[], 2)

select cardinality('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::int[])

select title, array_upper(special_features, 1)
from film 

select array_upper('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::int[], 1)

select array_lower('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::int[], 1)

create table a (
	id serial primary key,
	val text[] not null
)

insert into a(val)
values(array['A'])

select val[1] from a

update a 
set val[-10] = 'B'
where id = 1

select val[-10] from a

select val from a

{[-10:1]={B,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,A}}

7* �������� ��� ������ ���������� ����������� ��������: 'Trailers','Commentaries'
* ����������� ���������:
@> - ��������
<@ - ���������� �
*  ARRAY[��������] - ��� �������� �������

https://postgrespro.ru/docs/postgresql/12/functions-subquery
https://postgrespro.ru/docs/postgrespro/12/functions-array

-- ������ �������� --

explain analyze --72.50
select title, special_features
from film 
where special_features::text like '%Trailers%'

select title, special_features
from film 
where special_features[1] = 'Trailers' or special_features[2] = 'Trailers' or special_features[3] = 'Trailers'

-- ���-�� ������� �������� --

explain analyze --250
select title, array_agg(unnest)
from (
	select title, unnest(special_features), film_id
	from film) t
where unnest = 'Trailers'
group by film_id, title

explain analyze --113
select title, special_features
from film
where 'Trailers' in (select unnest(special_features))

-- ������� �������� --

explain analyze --67.5
select title, special_features
from film
where special_features && array['Trailers'] 

explain analyze --67.5
select title, special_features
from film
where special_features @> array['Trailers'] 

select title, special_features
from film
where array['Trailers'] <@ special_features

select title, special_features
from film
where special_features <@ array['Trailers']

explain analyze --77.5
select title, special_features
from film
where 'Trailers' = any(special_features) --some

select title, special_features
from film
where 'Trailers' = all(special_features) 

explain analyze --67.5
select title, special_features
from film
where array_position(special_features, 'Trailers') is not null

explain analyze --72.5
select title, special_features
from film
where array_length(array_positions(special_features, 'Trailers'), 1) > 0
	
-- �� ��������
select title, special_features
from film
where not 'Trailers' = any(special_features) --some

select title, special_features
from film
where not special_features && array['Trailers'] 

select array_upper(val, 1), array_lower(val, 1)
from a

select val::text
from a

[-10:1]={B,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,A}

select val[array_lower(val, 1)]
from a

blob

create materialized view task as 
select concat_ws(' ', p.last_name, p.first_name, p.middle_name), e.emp_id, e.hire_date
from person p
join employee e on e.person_id = p.person_id

create table audit_view (
	id serial primary key,
	view_name text not null,
	refresh_time timestamp not null default now())
	
select * from person p where last_name = '��������'

select * from task 

refresh materialized view task

select * from audit_view 

SET PGPASSWORD=123
"C:\Program Files\PostgreSQL\14\bin\psql" -h localhost -p 5434 -U postgres -d postgres -c "set search_path to hr;" -c "refresh materialized view task;" -c "insert into audit_view (view_name) values ('task');"