--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

--Seq Scan on film  (cost=0.00..77.50 rows=538 width=117) (actual time=0.014..0.376 rows=538 loops=1)
--Execution Time: 0.399 ms
--explain
--analyze
select
	film_id,
	title,
	description,
	release_year
from
	film
where
	'Behind the Scenes' = any(special_features);


--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.


--Seq Scan on film  (cost=0.00..67.50 rows=538 width=78) (actual time=0.015..0.400 rows=538 loops=1)
--Execution Time: 0.423 ms
--explain
--analyze
select
	film_id,
	title,
	special_features
from
	film
where
	array ['Behind the Scenes'] <@ special_features;

--Seq Scan on film  (cost=0.00..67.50 rows=538 width=78) (actual time=0.031..0.431 rows=538 loops=1)
--Execution Time: 0.447 ms
--explain
--analyze
select
	film_id,
	title,
	special_features
from
	film
where
	array ['Behind the Scenes'] && special_features;

--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

--Sort  (cost=673.97..675.47 rows=599 width=10) (actual time=9.430..9.454 rows=599 loops=1)
--Execution Time: 8.145 ms

explain
analyze
with cte as (
select
	film_id,
	title,
	description,
	release_year
from
	film
where
	array ['Behind the Scenes'] <@ special_features
)
select
	r.customer_id,
	count(film_id) as "Количество"
from
	rental r
inner join inventory
		using(inventory_id)
inner join 
(
	select
		film_id,
		title,
		description,
		release_year
	from
		cte) ct
		using(film_id)
group by
	r.customer_id
order by
	"Количество" desc;



--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

--Sort  (cost=673.97..675.47 rows=599 width=10) (actual time=7.763..7.780 rows=599 loops=1)
--Execution Time: 7.968 ms
explain
analyze
select
	r.customer_id,
	count(film_id) as "Количество"
from
	rental r
inner join inventory i
		using(inventory_id)
inner join (
	select
		film_id,
		title,
		description,
		release_year
	from
		film f
	where
		array ['Behind the Scenes'] <@ special_features
	
)q
		using(film_id)
group by
	r.customer_id
order by
	"Количество" desc;



--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления
drop materialized view qty

explain
analyze
create materialized view qty as (
select
	r.customer_id,
	count(film_id) as "Количество"
from
	rental r
inner join inventory i
		using(inventory_id)
inner join (
	select
		film_id,
		title,
		description,
		release_year
	from
		film f
	where
		array ['Behind the Scenes'] <@ special_features
	
)q
		using(film_id)
group by
	r.customer_id
order by
	"Количество" desc
) with no data;
/*
Sort  (cost=673.97..675.47 rows=599 width=10) (never executed)
  Sort Key: (count(f.film_id)) DESC
  ->  HashAggregate  (cost=640.35..646.34 rows=599 width=10) (never executed)
        Group Key: r.customer_id
        ->  Hash Join  (cost=202.30..597.19 rows=8632 width=6) (never executed)
              Hash Cond: (i.film_id = f.film_id)
              ->  Hash Join  (cost=128.07..480.67 rows=16044 width=4) (never executed)
                    Hash Cond: (r.inventory_id = i.inventory_id)
                    ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=6) (never executed)
                    ->  Hash  (cost=70.81..70.81 rows=4581 width=6) (never executed)
                          ->  Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (never executed)
              ->  Hash  (cost=67.50..67.50 rows=538 width=4) (never executed)
                    ->  Seq Scan on film f  (cost=0.00..67.50 rows=538 width=4) (never executed)
                          Filter: ('{"Behind the Scenes"}'::text[] <@ special_features)
Planning Time: 0.550 ms
Execution Time: 3.030 ms
*/

refresh materialized view qty;
explain
analyze
select * from qty;
/*
 * Seq Scan on qty  (cost=0.00..9.99 rows=599 width=10) (actual time=0.035..0.084 rows=599 loops=1)
Planning Time: 0.692 ms
Execution Time: 0.124 ms
*/
 




--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
--Ответ: any();

--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса
-- Ответ: c использованием подзапроса





--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии
--Сделайте explain analyze этого запроса.
 
explain
analyze
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc;

--Основываясь на описании запроса, найдите узкие места и опишите их.

--1. Сортировка по count(r.inventory_id) ->  Sort  (cost=1090.36..1090.38 rows=5 width=44) (actual time=57.266..57.502 rows=8632 loops=1)
--2. Сортировка по cu.customer_id внутри оконной функции ->  Sort  (cost=1090.19..1090.20 rows=5 width=21) (actual time=43.824..44.408 rows=8632 loops=1)
-- В результате Execution Time: 58.532 ms

--Сравните с вашим запросом из основной части:

-- Запрос с использованием подзапроса (основная часть ДЗ п.4)срабатывает в 7 раз быстрее, энергозатраты (cost) примерно в 2 раза меньше.

--Сделайте построчное описание explain analyze на русском языке оптимизированного запроса.
/*
Sort  (cost=673.97..675.47 rows=599 width=10) (actual time=8.002..8.019 rows=599 loops=1) -> Сортировка по count(film.film_id)
  Sort Key: (count(film.film_id)) DESC
  Sort Method: quicksort  Memory: 53kB
  ->  HashAggregate  (cost=640.35..646.34 rows=599 width=10) (actual time=7.881..7.933 rows=599 loops=1)-> группировка по r.customer_id
        Group Key: r.customer_id
        ->  Hash Join  (cost=202.30..597.19 rows=8632 width=6) (actual time=1.320..6.754 rows=8608 loops=1) -> объединение с film по условию inventory.film_id = film.film_id
              Hash Cond: (inventory.film_id = film.film_id)
              ->  Hash Join  (cost=128.07..480.67 rows=16044 width=4) (actual time=0.850..4.598 rows=16044 loops=1)  -> объединение с inventory По условию r.inventory_id = inventory.inventory_id
                    Hash Cond: (r.inventory_id = inventory.inventory_id)
                    ->  Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=6) (actual time=0.008..0.926 rows=16044 loops=1) ->последовательное сканирование отношения rental
                    ->  Hash  (cost=70.81..70.81 rows=4581 width=6) (actual time=0.796..0.796 rows=4581 loops=1)
                          Buckets: 8192  Batches: 1  Memory Usage: 234kB
                          ->  Seq Scan on inventory  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.008..0.387 rows=4581 loops=1)->последовательное сканирование отношения inventory
              ->  Hash  (cost=67.50..67.50 rows=538 width=4) (actual time=0.465..0.465 rows=538 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 27kB
                    ->  Seq Scan on film  (cost=0.00..67.50 rows=538 width=4) (actual time=0.013..0.416 rows=538 loops=1)->последовательное сканирование отношения film 
                          Filter: ('{"Behind the Scenes"}'::text[] <@ special_features)-> отбор строк по условию наличия элемента "Behind the Scenes" среди элементов массива special_features
                          Rows Removed by Filter: 462
Planning Time: 0.700 ms
Execution Time: 8.145 ms
*/

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.

with cte1 as (
select
	p.staff_id,
	p.payment_id,
	p.amount,
	p.payment_date,
	p.customer_id,
	p.rental_id,
	row_number() over w as rn
from
	payment p
window w as (partition by p.staff_id
order by
	p.payment_date)
order by
	p.staff_id 
)
select
	cte1.staff_id,
	f.film_id,
	f.title,
	c.last_name || ' ' || c.first_name as customer_name,
	cte1.amount,
	cte1.payment_date
from
	cte1
inner join customer c
		using (customer_id)
inner join rental r
		using (rental_id)
inner join inventory i
		using (inventory_id)
inner join film f
		using(film_id)
where
	cte1.rn = 1;



--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день
-- вариант с оконными функциями и cte
explain analyze
with cte1 as (
select
	q.store_id,
	q.r_date,
	q.my_count
from
	(
	select
		s.store_id,
		r.rental_date::date as r_date,
		count(*) as my_count,
		row_number() over (partition by s.store_id
	order by
		count(*)desc) as rn
	from
		rental r
	inner join inventory i
			using(inventory_id)
	inner join store s
			using (store_id)
	group by
		s.store_id,
		r_date)q
where
	rn = 1),
cte2 as (
select
	q.store_id,
	q.p_date,
	q.my_amount
from
	(
	select
		s.store_id,
	p.payment_date::date as p_date,
		sum(p.amount) as my_amount,
		row_number() over (partition by s.store_id
	order by
		sum(p.amount)) as rn
	from
		payment p
	inner join staff st using(staff_id)
	inner join store s on st.staff_id = s.manager_staff_id
	group by
		s.store_id,
		p_date)q
where
	rn = 1)
	select cte1.store_id as "ID Магазина", 
	cte1.r_date as "Дата рекорда по количеству", 
	cte1.my_count as "Макс. кол-во фильмов",
	cte2.p_date as "Дата антирекорда по продажам",
	cte2.my_amount as "Мин. объем продаж"
	from cte1
	inner join cte2 using(store_id);



--вариант с подзапросами
ДЗ 6 ч. 2 доп. п.3 альтернативный вариант -чуть меньше по затратам, но медленнее, чем с оконными функциями

explain analyze
select
	qty.store_id,
	qty.r_date,
	qty.my_count,
	amt.p_date,
	amt.my_amount
from
	(
	select
		q.store_id,
		q.r_date,
		my_count
	from
		(
		select
			st.store_id,
			r.rental_date::date as r_date,
			count(*) as my_count
		from
			rental r
		inner join inventory i
				using(inventory_id)
		inner join store st
				using(store_id)
		group by
			st.store_id,
			(rental_date::date)
		order by
			st.store_id) q
	order by
		q.my_count desc
	limit 2)qty
inner join (
	select
		q2.store_id,
		q2.p_date,
		my_amount
	from
		(
		select
			st.store_id,
			p.payment_date::date as p_date,
			sum(amount) as my_amount
		from
			payment p
		inner join staff st
				using(staff_id)
		inner join store s on
			st.staff_id = s.manager_staff_id
		group by
			st.store_id,
			(payment_date::date)
		order by
			st.store_id) q2
	order by
		q2.my_amount
	limit 2)amt
		using(store_id);













