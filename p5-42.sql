from 
on 
join 
where 
group by 
selec over t

sum(val) over (partition by ... order by...)

group by 
1	1
1	2
1	1
1	1
1	2
2	1
2	2
2	1
2	1
2	2

1	7
2	7

partition by 

1	1	7
1	2	7
1	1	7
1	1	7
1	2	7
2	1	7
2	2	7
2	1	7
2	1	7
2	2	7

============= оконные функции =============

1. Вывести ФИО пользователя и название третьего фильма, который он брал в аренду.
* В подзапросе получите порядковые номера для каждого пользователя по дате аренды
* Задайте окно с использованием предложений over, partition by и order by
* Соедините с customer
* Соедините с inventory
* Соедините с film
* В условии укажите 3 фильм по порядку

explain analyze --2418
select r.customer_id, f.title
from (
	select customer_id, array_agg(rental_id)
	from (
		select customer_id, rental_id
		from rental 
		order by customer_id, rental_date) t
	group by customer_id) t
join rental r on r.rental_id = t.array_agg[3]
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

explain analyze --2108
select t.customer_id, f.title
from (
	select *, row_number() over (partition by customer_id order by rental_date)
	from rental) t
join inventory i on i.inventory_id = t.inventory_id
join film f on f.film_id = i.film_id
where t.row_number = 3

1.1. Выведите таблицу, содержащую имена покупателей, арендованные ими фильмы и средний платеж 
каждого покупателя
* используйте таблицу customer
* соедините с paymen
* соедините с rental
* соедините с inventory
* соедините с film
* avg - функция, вычисляющая среднее значение
* Задайте окно с использованием предложений over и partition by

--НЕ ПРАВИЛЬНО
select c.last_name, f.title, avg(p.amount) 
from customer c
join payment p on p.customer_id = c.customer_id
join rental r on r.rental_id = p.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
group by c.last_name, f.title

--ПРАВИЛЬНО
select c.last_name, f.title, avg(p.amount) over (partition by c.customer_id)
from customer c
join payment p on p.customer_id = c.customer_id
join rental r on r.rental_id = p.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

select c.last_name, f.title, 
	avg(p.amount) over (partition by c.customer_id),
	sum(p.amount) over (partition by c.customer_id),
	count(p.amount) over (partition by c.customer_id),
	min(p.amount) over (partition by c.customer_id),
	max(p.amount) over (partition by c.customer_id, p.staff_id),
	avg(p.amount) over (),
	sum(p.amount) over (),
	count(p.amount) over (),
	min(p.amount) over (),
	max(p.amount) over ()
from customer c
join payment p on p.customer_id = c.customer_id
join rental r on r.rental_id = p.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

explain analyze --2944
select distinct c.last_name, 
	avg(p.amount) over (partition by c.customer_id),
	sum(p.amount) over (partition by c.customer_id),
	count(p.amount) over (partition by c.customer_id)
from customer c
join payment p on p.customer_id = c.customer_id
join rental r on r.rental_id = p.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

explain analyze --1316
select c.last_name, 
	avg(p.amount),
	sum(p.amount),
	count(p.amount) 
from customer c
join payment p on p.customer_id = c.customer_id
join rental r on r.rental_id = p.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
group by 1

explain analyze --718
select customer_id, sum(amount) *100. / (select sum(amount) from payment )
from payment 
group by 1
order by 1

explain analyze --406
select customer_id, sum(amount)*100. / sum(sum(amount)) over ()--, sum(sum(amount)) over ()
from payment 
group by 1
order by 1

-- формирование накопительного итога

1	2	2
1	2	4
1	4	8
1	1	9

select customer_id, payment_date, amount, 
	sum(amount) over (partition by customer_id order by payment_date)
from payment 
order by 1

select customer_id, payment_date::date, amount, 
	sum(amount) over (partition by customer_id order by payment_date::date)
from payment 
order by 1

select customer_id, payment_date::date, amount, 
	count(amount) over (partition by customer_id order by payment_date::date)
from payment 
order by 1

select customer_id, payment_date::date, amount, 
	avg(amount) over (partition by customer_id order by payment_date::date)
from payment 
order by 1

select customer_id, payment_date, amount, 
	sum(amount) over (partition by customer_id order by payment_date),
	sum(amount) over (order by payment_date)
from payment 
order by 2

-- работа функций lead и lag
select customer_id, payment_date, 
	lag(amount) over (partition by customer_id order by payment_date),
	amount,
	lead(amount) over (partition by customer_id order by payment_date)
from payment 
order by 1, 2

select customer_id, payment_date, 
	amount - lag(amount) over (partition by customer_id order by payment_date)
from payment 
order by 1, 2

select customer_id, payment_date, 
	lag(amount, 3) over (partition by customer_id order by payment_date),
	--получаем предыдущее значение платежа с шагом 3 для каждого пользователя вы порядке даты платежа
	amount,
	lead(amount, 2) over (partition by customer_id order by payment_date)	
	--получаем следующие значение платежа с шагом 2 для каждого пользователя вы порядке даты платежа
from payment 
order by 1, 2

from payment p1
join payment p2 on p1.payment_date = p2.payment_date - 1

select date_trunc('month', payment_date), sum(amount),
	sum(amount) - lag(sum(amount)) over (order by date_trunc('month', payment_date))
from payment p
group by date_trunc('month', payment_date)

select customer_id, payment_date, 
	lag(amount, 3, 0.) over (partition by customer_id order by payment_date),
	amount,
	lead(amount, 2, 0.) over (partition by customer_id order by payment_date)	
from payment 
order by 1, 2

select customer_id, payment_date, 
	coalesce(lag(amount, 3) over (partition by customer_id order by payment_date), 0),
	amount,
	lead(amount, 2) over (partition by customer_id order by payment_date)	
from payment 
order by 1, 2

select coalesce(null,null,null,null, 6,null,null, 7)

select last_name, lag(first_name, 1, 'имя отсутствует') over ()
from customer 

-- работа с рангами и порядковыми номерами

select customer_id, payment_date::date, 
	row_number() over (partition by customer_id order by payment_date::date),
	rank() over (partition by customer_id order by payment_date::date),
	dense_rank() over (partition by customer_id order by payment_date::date)
from payment 

-- last_value / first_value

last_value по возможности не использовать!!!

select customer_id, rental_id, rental_date,
	first_value(rental_id) over (partition by customer_id order by rental_date)
from rental 

select customer_id, rental_id, rental_date,
	first_value(rental_id) over (partition by customer_id order by rental_date desc)
from rental 

--ПЛОХО 
explain analyze --2112
select distinct
	first_value(customer_id) over (partition by customer_id order by rental_date desc),
	first_value(rental_date) over (partition by customer_id order by rental_date desc),
	first_value(rental_id) over (partition by customer_id order by rental_date desc)
from rental 

--ХОРОШО
explain analyze --2906
select distinct r.*
from (
	select customer_id, rental_date,
		first_value(rental_id) over (partition by customer_id order by rental_date desc)
	from rental) t
join rental r on r.rental_id = t.first_value

--ложное решение
select customer_id, rental_date, rental_id,
		last_value(rental_id) over (partition by customer_id order by rental_date)
from rental
order by 1, 2 

select customer_id, rental_date, rental_id,
		last_value(rental_id) over (partition by customer_id)
from (
	select *
	from rental 
	order by customer_id, rental_date) t
order by 1, 2 

select customer_id, rental_date, rental_id,
		last_value(rental_id) over (partition by customer_id order by rental_date
			rows between unbounded preceding and unbounded following)
from rental 
order by 1, 2 

rows current row 
https://postgrespro.ru/docs/postgresql/14/sql-expressions#SYNTAX-WINDOW-functions

-- filter 
select customer_id, payment_date, amount, 
	sum(amount) filter (where amount < (select customer_id from customer c where customer_id = 5)) over (partition by customer_id order by payment_date),
	sum(amount) filter (where amount > 5) over (partition by customer_id order by payment_date)
from payment 
order by 1

--алиасы
select customer_id, payment_date, amount, 
	sum(amount) filter (where amount < 5) over w_p,
	sum(amount) filter (where amount > 5) over w_p,
	count(amount) filter (where amount < 5) over w_p,
	count(amount) filter (where amount > 5) over w_p,
	sum(amount) filter (where amount < 5) over w_g,
	sum(amount) filter (where amount > 5) over w_g,
	sum(amount) filter (where amount < 5) over w_g,
	sum(amount) filter (where amount > 5) over w_g
from payment 
window w_p as (partition by customer_id order by payment_date),
	w_g as (order by payment_date)
order by 1


============= общие табличные выражения =============

2.  При помощи CTE выведите таблицу со следующим содержанием:
Название фильма продолжительностью более 3 часов и к какой категории относится фильм
* Создайте CTE:
 - Используйте таблицу film
 - отфильтруйте данные по длительности
 * напишите запрос к полученной CTE:
 - соедините с film_category
 - соедините с category

with cte1 as (
	select *
	from film 
	where length > 180
), cte2 as (
	select c.title, fc.category_id
	from film_category fc
	join cte1 c on c.film_id = fc.film_id)
select c.title, c2."name"
from cte2 c 
join category c2 on c2.category_id = c.category_id

2.1. Выведите фильмы, с категорией начинающейся с буквы "C"
* Создайте CTE:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините полученное табличное выражение с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"

select version() --14.2

explain analyze --53.54
with table_film_name  as (
	select *
	from category 
	where "name" like 'C%'
)
select f.title
from table_film_name t 
join film_category fc on fc.category_id = t.category_id
join film f on f.film_id = fc.film_id

select version() --10.11

explain analyze --54.62
with cte as (
	select *
	from category 
	where "name" like 'C%'
)
select f.title
from cte 
join film_category fc on fc.category_id = cte.category_id
join film f on f.film_id = fc.film_id

============= общие табличные выражения (рекурсивные) =============
 
 3.Вычислите факториал
 + Создайте CTE
 * стартовая часть рекурсии (т.н. "anchor") должна позволять вычислять начальное значение
 *  рекурсивная часть опираться на данные с предыдущей итерации и иметь условие остановки
 + Напишите запрос к CTE

with recursive r as (
	--стартовая часть
	select 1 as i, 1 as factorial
	union --all
	--рекурсивная часть
	select i + 1 as i, factorial * (i + 1) as factorial
	from r
	where i < 10
)
select *
from r

with recursive r as (
	select unit_id, parent_id, unit_title, 1 as level
	from "structure" s
	where unit_id = 59
	union 
	select s.unit_id, s.parent_id, s.unit_title, level + 1 as level
	from r 
	join "structure" s on s.unit_id = r.parent_id)
select *
from r

with recursive r as (
	select unit_id, parent_id, unit_title, 1 as level
	from "structure" s
	where unit_id = 59
	union 
	select s.unit_id, s.parent_id, s.unit_title, level + 1 as level
	from r 
	join "structure" s on s.parent_id = r.unit_id)
select count(*)
from r
join "position" p on p.unit_id = r.unit_id
join employee e on e.pos_id = p.pos_id


with recursive r as (
	select unit_id, parent_id, unit_title, 1 as level
	from "structure" s
	where unit_id = 59
	union 
	select s.unit_id, s.parent_id, s.unit_title, level + 1 as level
	from r 
	join "structure" s on r.parent_id = s.unit_id)
select *
from r
 
3.2 Работа с рядами.

explain analyze --2050
with recursive r as (
	select date_trunc('month', '01.01.2005'::date) x
	union 
	select x + interval '1 month' as x
	from r
	where x < date_trunc('month', '01.06.2006'::date))
select x, coalesce(sum, 0), coalesce(sum, 0) - lag(sum) over (order by x)
from r
left join (
	select date_trunc('month', payment_date), sum(amount)
	from payment 
	group by 1) t on r.x = t.date_trunc

explain analyze --4217
select x, coalesce(sum, 0), coalesce(sum, 0) - lag(sum) over (order by x)
from generate_series(date_trunc('month', '01.01.2005'::date), 
	date_trunc('month', '01.06.2006'::date), interval '1 month') x
left join (
	select date_trunc('month', payment_date), sum(amount)
	from payment 
	group by 1) t on x = t.date_trunc
	
select generate_series(1, -100, -3)

1000 1000
100000 50000
100001 4500000
хинты 