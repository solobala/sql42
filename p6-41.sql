============= представления =============

4. Создайте view с колонками клиент (ФИО; email) и title фильма, который он брал в прокат последним
+ Создайте представление:
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1

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
	
4.1. Создайте представление с 3-мя полями: название фильма, имя актера и количество фильмов, в которых он снимался
+ Создайте представление:
* Используйте таблицу film
* Соедините с film_actor
* Соедините с actor
* count - агрегатная функция подсчета значений
* Задайте окно с использованием предложений over и partition by

create view task_2 as 
	select f.title, concat(a.last_name, ' ', a.first_name), 
		count(f.film_id) over (partition by a.actor_id)
	from film f
	join film_actor fa on f.film_id = fa.film_id
	join actor a on a.actor_id = fa.actor_id
	
select * from task_2

============= материализованные представления =============

5. Создайте материализованное представление с колонками клиент (ФИО; email) и title фильма, 
который он брал в прокат последним
Иницилизируйте наполнение и напишите запрос к представлению.
+ Создайте материализованное представление без наполнения (with NO DATA):
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1
+ Обновите представление
+ Выберите данные

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
with NO data

refresh materialized view task_3

explain analyze --15.98
select * 
from task_3
where left(concat, 1) = 'A'

create index f_l_i  on task_3 (left(concat, 1))

explain analyze --10.33
select * 
from task_3
where left(concat, 1) = 'A'

5.1. Содайте наполенное материализованное представление, содержащее:
список категорий фильмов, средняя продолжительность аренды которых более 5 дней
+ Создайте материализованное представление с наполнением (with DATA)
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней
 + Выберите данные

create materialized view public.task_4 as 
	select c."name"
	from film f
	join film_category fc on f.film_id = fc.film_id
	join category c on c.category_id = fc.category_id
	group by c.category_id
	having avg(f.rental_duration) > 5
	
select * 
from task_4

create table task_4 (
	name varchar(25) not null)
	
create function foo () returns trigger
(
	if tg_op = 'INSERT'
		if tg_table_name = 'film'
			then (insert into task_4)

)

create trigger film .. foo

create trigger film_category .. foo

create trigger category .. foo

select distinct table_type
from information_schema."tables" t


============ Индексы ===========

select * --688kb
from film

film_id | title

btree = > < is null in 
hash = 
gin / gist 

alter table film drop constraint film_pkey cascade

после удаления индексов - 472кб

explain analyze --67.50 / 0.143
select *
from film 
where film_id = 333

create index film_id_idx on film (film_id)

1-1000
1-500 501-1000
1-250 251-500 501-750 751-1000
1-125 126-250 251-375
    
explain analyze --8.29 / 0.014
select *
from film 
where film_id = 333

explain analyze --9.89 / 0.019
select *
from film 
where film_id between 100 and 125

drop index film_id_idx

create index film_id_idx on film using hash (film_id)

create index film_year_title_idx on film (release_year, title)

explain analyze --67.50
select *
from film 
where release_year = 2006

explain analyze --39.78
select *
from film 
where title = 'ACADEMY DINOSAUR'

explain analyze
select *
from payment 
where payment_date = '2005-05-25 11:30:37'

create index payment_date_idx on payment (payment_date)

explain analyze
select *
from payment 
where payment_date::date = '2005-05-25'

create index payment_date_date_idx on payment (cast(payment_date as date))

::, cast

explain analyze --118.29
select *
from payment 
where payment_date::date = '2005-05-25'

drop index payment_date_idx

gin 

A Thoughtful Panorama of a Database Administrator And a Mad Scientist who must Outgun a Mad Scientist in A Jet Boat

'Mad':{10, 16}
'a':{1,5,9,15,19}


============ explain ===========

explain analyze
select c."name"
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
group by c.category_id
having avg(f.rental_duration) > 5

left/inner/full - логика соединения данных

hash join 
merge join 
nested loop - алгоритмы соединения данных

project set

explain analyze
with c as (
	select 2 x
	from payment )
select * from c
join rental r on r.customer_id = c.x

Ссылка на сервис по анализу плана запроса 
https://explain.depesz.com/ -- открывать через ВПН
https://tatiyants.com/pev/
https://habr.com/ru/post/203320/


EXPLAIN [ ( параметр [, ...] ) ] оператор
EXPLAIN [ ANALYZE ] [ VERBOSE ] оператор

Здесь допускается параметр:

    ANALYZE [ boolean ]
    VERBOSE [ boolean ]
    COSTS [ boolean ]
    BUFFERS [ boolean ]
    TIMING [ boolean ]
    FORMAT { TEXT | XML | JSON | YAML }
 
explain (format json, analyse)   
select c."name"
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
group by c.category_id
having avg(f.rental_duration) > 5

======================== json ========================
Создайте таблицу orders
 
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
 
|{название_товара: quantity, product_id: quantity, product_id: quantity}|общая сумма заказа|

6. Выведите общее количество заказов:
* CAST ( data AS type) преобразование типов
* SUM - агрегатная функция суммы
* -> возвращает JSON
*->> возвращает текст

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

6*  Выведите среднее количество заказов, продуктов начинающихся на "Toy"

select avg((info->'items'->>'qty')::numeric)
from orders
where info->'items'->>'product' ilike 'toy%'

--Получить все ключи из json
select json_object_keys(info->'items')
from orders

======================== array ========================
7. Выведите сколько раз встречается специальный атрибут (special_features) у
фильма -- сколько элементов содержит атрибут special_features
* array_length(anyarray, int) - возвращает длину указанной размерности массива

wish_list [1, 6, 74, 988]

wish_list '1,6,74,988'

'10:00,12:00'
'{10:00,12:00}'::time[]

int[]
date[]
numeric[]
text[]

['01.05.2022','50']

05
2022
50
06
2022
30

select title, array_length(special_features, 1)
from film 

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::int[], 2)


7* Выведите все фильмы содержащие специальные атрибуты: 'Trailers','Commentaries'
* Используйте операторы:
@> - содержит
<@ - содержится в
*  ARRAY[элементы] - для описания массива

https://postgrespro.ru/docs/postgresql/12/functions-subquery
https://postgrespro.ru/docs/postgrespro/12/functions-array

-- ПЛОХАЯ ПРАКТИКА --
select title, special_features
from film 
where special_features[1] ='Trailers' or 
	special_features[2] ='Trailers' or 
	special_features[3] ='Trailers' or 
	special_features[4] ='Trailers'
	
select title, special_features
from film 
where special_features::text like '%Trailers%' 

-- ЧТО-ТО СРЕДНЕЕ ПРАКТИКА --

explain analyze --274
select title, array_agg(unnest)
from (
	select title, unnest(special_features)
	from film) t 
where t.unnest = 'Trailers' or t.unnest = 'Commentaries'
group by title

explain analyze --113
select title, special_features
from film
where 'Trailers' in (select unnest(special_features)) or 'Commentaries' in (select unnest(special_features))

-- ХОРОШАЯ ПРАКТИКА --

select title, special_features
from film
where special_features && array['Trailers', 'Commentaries']

select title, special_features
from film
where special_features @> array['Trailers', 'Commentaries']

select title, special_features
from film
where special_features <@ array['Trailers']

select title, special_features
from film
where array['Trailers'] <@ special_features

select title, special_features
from film
where 'Trailers' = any(special_features)

any = some

select title, special_features
from film
where 'Trailers' = all(special_features)

select title, special_features, array_position(special_features, 'Deleted Scenes')
from film
where array_position(special_features, 'Trailers') > 0 -- так не очень хорошо

select title, special_features, array_position(special_features, 'Deleted Scenes')
from film
where array_position(special_features, 'Trailers') is not null -- так не очень хорошо

array_position - возвращает индекс элемента первого вхождения
array_positions - возвращает массив с индексами элементов всех вхождений

create temporary table a (
	id serial primary key,
	val int[] not null)
	
insert into a (val)
values (array[5,7])

select val[2] from a

update a 
set val[-10] = 100
where id = 1

select val from a

{[-10:2]={100,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5,7}}

select array_lower(val, 1), array_upper(val, 1)
from a

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::int[], 2)

select cardinality('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::int[])
	
-- НЕ СОДЕРЖИТ
select title, special_features
from film
where not 'Trailers' = any(special_features)

select title, special_features
from film
where not special_features && array['Trailers', 'Commentaries']