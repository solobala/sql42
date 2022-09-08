Задание 1. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.
Ожидаемый результат запроса: letsdocode.ru...in/5-5.png

select staff_id, payment_date::date, sum(amount),
	sum(sum(amount)) over (partition by staff_id order by payment_date::date)
from payment 
where date_trunc('month', payment_date) = '01.08.2005'
group by staff_id, payment_date::date

Задание 2. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа 
получал дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей, 
которые в день проведения акции получили скидку.
Ожидаемый результат запроса: letsdocode.ru...in/5-6.png

select *
from (
	select customer_id, row_number() over (order by payment_date)
	from payment 
	where payment_date::date = '20.08.2005') t 
where row_number % 100 = 0

select *
from (
	select customer_id, row_number() over (order by payment_date)
	from payment 
	where payment_date::date = '20.08.2005') t 
where mod(row_number, 100) = 0

Задание 3. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
· покупатель, арендовавший наибольшее количество фильмов;
· покупатель, арендовавший фильмов на самую большую сумму;
· покупатель, который последним арендовал фильм.
Ожидаемый результат запроса: letsdocode.ru...in/5-7.

explain analyze --7991
with cte1 as (
	select c.customer_id, c2.country_id, concat(c.last_name, ' ', c.first_name),
		count(r.rental_id), sum(p.amount), max(r.rental_date)
	from customer c
	join payment p on p.customer_id = c.customer_id
	join rental r on r.rental_id = p.rental_id
	join address a on c.address_id = a.address_id
	join city c2 on c2.city_id = a.city_id
	group by 1, 2),
cte2 as (
	select customer_id, country_id, concat,
		row_number() over (partition by country_id order by count desc) rc, 
		row_number() over (partition by country_id order by sum desc) rs, 
		row_number() over (partition by country_id order by max desc) rm
	from cte1)
select c.country, c1.concat, c2.concat, c3.concat
from country c 
left join cte2 c1 on c1.country_id = c.country_id and c1.rc = 1
left join cte2 c2 on c2.country_id = c.country_id and c2.rs = 1
left join cte2 c3 on c3.country_id = c.country_id and c3.rm = 1

explain analyze --4740
with cte1 as (
	select c.customer_id, c2.country_id, concat(c.last_name, ' ', c.first_name),
		count(r.rental_id), sum(p.amount), max(r.rental_date),
		max(count(r.rental_id)) over (partition by c2.country_id) mc,
		max(sum(p.amount)) over (partition by c2.country_id) ms,
		max(max(r.rental_date)) over (partition by c2.country_id) mm
	from customer c
	join payment p on p.customer_id = c.customer_id
	join rental r on r.rental_id = p.rental_id
	join address a on c.address_id = a.address_id
	join city c2 on c2.city_id = a.city_id
	group by 1, 2),
cte2 as (
	select customer_id, country_id, 
		case
			when count = mc then customer_id
		end cc,
		case
			when sum = ms then customer_id
		end cs,
		case
			when max = mm then customer_id
		end cm
	from cte1
)
select c.country, 
	string_agg(distinct cc::text, ', '), string_agg(distinct cs::text, ', '), string_agg(distinct cm::text, ', ') 
from country c 
left join cte2 c2 on c.country_id = c2.country_id
group by c.country_id

explain analyze --1273
with cte1 as (
	select c.customer_id, concat(c.last_name, ' ', c.first_name), c.address_id,
		count(r.rental_id), sum(p.amount), max(r.rental_date)
	from customer c
	join payment p on p.customer_id = c.customer_id
	join rental r on r.rental_id = p.rental_id
	group by 1),
cte2 as (
	select c.customer_id, c2.country_id,
		rank() over (partition by c2.country_id order by c.count desc) rc, 
		rank() over (partition by c2.country_id order by c.sum desc) rs, 
		rank() over (partition by c2.country_id order by c.max desc) rm
	from cte1 c
	join address a on c.address_id = a.address_id
	join city c2 on c2.city_id = a.city_id)
select c.country,
	string_agg(distinct c1.customer_id::text, ', '), string_agg(distinct c2.customer_id::text, ', '), 
	string_agg(distinct c3.customer_id::text, ', ') 
from country c 
left join cte2 c1 on c1.country_id = c.country_id and c1.rc = 1
left join cte2 c2 on c2.country_id = c.country_id and c2.rs = 1
left join cte2 c3 on c3.country_id = c.country_id and c3.rm = 1
group by c.country_id

explain analyze --1391
with cte1 as (
	select c.customer_id, concat(c.last_name, ' ', c.first_name), c.address_id,
		count, sum, max
	from customer c
	join (
		select customer_id, sum(amount)
		from payment
		group by 1) p on p.customer_id = c.customer_id
	join (
		select customer_id, count(rental_id), max(rental_date)
		from rental
		group by 1) r on r.customer_id = p.customer_id),
cte2 as (
	select c.customer_id, c2.country_id,
		rank() over (partition by c2.country_id order by c.count desc) rc, 
		rank() over (partition by c2.country_id order by c.sum desc) rs, 
		rank() over (partition by c2.country_id order by c.max desc) rm
	from cte1 c
	join address a on c.address_id = a.address_id
	join city c2 on c2.city_id = a.city_id)
select c.country,
	string_agg(distinct c1.customer_id::text, ', '), string_agg(distinct c2.customer_id::text, ', '), 
	string_agg(distinct c3.customer_id::text, ', ') 
from country c 
left join cte2 c1 on c1.country_id = c.country_id and c1.rc = 1
left join cte2 c2 on c2.country_id = c.country_id and c2.rs = 1
left join cte2 c3 on c3.country_id = c.country_id and c3.rm = 1
group by c.country_id

Задание 1. Откройте по ссылке SQL-запрос.

explain analyze
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
order by count desc

550+-10 610-650

1. Тот, кто это написал
2. unnest

Сделайте explain analyze этого запроса.
Основываясь на описании запроса, найдите узкие места и опишите их.
Сравните с вашим запросом из основной части (если ваш запрос изначально укладывается в 15мс — отлично!).
Сделайте построчное описание explain analyze на русском языке оптимизированного запроса. 
Описание строк в explain можно посмотреть по ссылке.

Задание 2. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
Ожидаемый результат запроса: letsdocode.ru...in/6-5.png

select f.title, c.last_name, c.first_name, t.*
from (
	select  *, row_number() over (partition by staff_id order by payment_date)
	from payment) t 
join rental r on r.rental_id = t.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join customer c on c.customer_id = t.customer_id
where row_number = 1

Задание 3. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
день, в который арендовали больше всего фильмов (в формате год-месяц-день);
количество фильмов, взятых в аренду в этот день;
день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
сумму продажи в этот день.
Ожидаемый результат запроса: letsdocode.ru...in/6-6.png

арендой - сотрудники или инвентори

платежами - сотрудники или инвентори

1. магазин получаем по аренде и платежам через сотрудника
2. магазин получаем по аренде и платежам через инвентори
3. магазин получаем по аренде через сотрудника и платежам через инвентори
4. магазин получаем по аренде через инвентори и платежам через сотрудника

select *
from (
	select i.store_id, count(i.film_id), r.rental_date::date,
		row_number() over (partition by i.store_id order by count(i.film_id) desc) rr
	from rental r
	join inventory i on i.inventory_id = r.inventory_id
	group by 1, 3) r
join (
	select i.store_id, sum(p.amount), p.payment_date::date,
		row_number() over (partition by i.store_id order by sum(p.amount)) rp
	from payment p
	join rental r on p.rental_id = r.rental_id
	join inventory i on i.inventory_id = r.inventory_id
	group by 1, 3) p on r.store_id = p.store_id
where rr = 1 and rp = 1

select *
from (
	select i.store_id, count(i.film_id), r.rental_date::date,
		row_number() over (partition by i.store_id order by count(i.film_id) desc) rr
	from rental r
	join inventory i on i.inventory_id = r.inventory_id
	group by 1, 3) r
join (
	select s.store_id, sum(p.amount), p.payment_date::date,
		row_number() over (partition by s.store_id order by sum(p.amount)) rp
	from payment p
	join staff s on s.staff_id = p.staff_id
	group by 1, 3) p on r.store_id = p.store_id
where rr = 1 and rp = 1

explain analyze
select *
from customer c

explain 
select *
from payment p1, payment p2, payment p3, payment p4, rental r1,
	payment p5, payment p6, payment p7, payment p8, rental r2,
	payment p9, payment p10, payment p11, payment p12, rental r3
where p1.customer_id != r2.customer_id or p2.customer_id != r3.customer_id
order by random()

13266494859404337329198390839913723207995062803174510125826179072.00

за 2 минуты минус 6,8 гигов

за 2 минуты минус 6,5 гигов

80.8