--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате

select
	customer_id,
	payment_id,
	payment_date,
	row_number() over (partition by payment_date::date order by payment_date)
from payment;
	

--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
select
	customer_id,
	payment_id,
	payment_date,
	row_number() over (partition by customer_id order by payment_date)
from
	payment
order by customer_id;

--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей

select
	customer_id,
	payment_id,
	amount,
	payment_date,
	sum(amount) over (partition by customer_id order by payment_date, amount) 
from
	payment
order by customer_id;

--Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим 
--так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

select
	customer_id,
	payment_id,
	amount,
	payment_date,
	dense_rank () over (partition by customer_id order by amount desc)
from
	payment
order by customer_id;



--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.

select
	customer_id,
	payment_id,
	payment_date,
	amount as "Стоимость платежа",
	lag(amount, 1, 0.0) over (partition by customer_id order by payment_date) as "Предыдущее значение"
		
from
	payment
order by customer_id;	



--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.

select
	customer_id,
	payment_id,
	payment_date,
	amount,
	amount - lead(amount, 1, 0.0) over (partition by customer_id order by payment_date, customer_id) as difference
from
	payment;


--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

select
	customer_id,
		payment_id,
		payment_date,
		last_value
from
	(
	select
		customer_id,
		payment_id,
		payment_date,
		last_value(amount) over (partition by customer_id
	order by
		payment_date desc),	
		row_number() over(partition by customer_id
	order by
		payment_date desc)
		from payment
) t
where
	row_number =1;




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.


with cte1 as 
(
select
	p.staff_id,
	p.payment_date::date,
	sum(p.amount) as sum_amount
from
			payment p
where
		p.payment_date between '2005-08-01' and '2005-08-31':: date + interval '1 day'
group by
	p.staff_id,
	p.payment_date::date
order by
	p.staff_id,
	p.payment_date::date)
select
	staff_id as "ID сотрудника",
	payment_date as "Дата",
	sum_amount as "Продажи за день",
	sum(sum_amount) over (partition by staff_id
order by
	date_trunc('month', payment_date)
                rows between unbounded preceding and current row) as "Продажи с начала месяца"
from
	cte1
order by
	staff_id;






--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку


select
			t.customer_id as "ID клиента",
			t.payment_date as "Дата",
			t.payment_number as "Номер платежа"
from 
		(
	select
			customer_id,
			payment_date,
			row_number() over (
	order by
			payment_date) as payment_number
	from
			(
		select
				customer_id,
				payment_date
		from
				payment
		where
				payment_date between '2005-08-20:00:00:00.000' and '2005-08-20:23:59:59.999')q
		)t
where
		t.payment_number %100 = 0;
	
	

--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:



	
-- 1. покупатель, арендовавший наибольшее количество фильмов	
	with cte1 as(
select
	*
from
	(
	select
		c.country_id,
		c.country ,
		c3.first_name ,
		c3.last_name,
		rank() over (partition by c.country_id
	order by
		count(p.payment_id) desc) as rank_count
	from
		payment p
	inner join customer c3
			using(customer_id)
	inner join address a
			using(address_id)
	inner join city c2
			using(city_id)
	inner join country c
			using(country_id)
	group by
		c.country_id,
		c3.customer_id)q1
where
	rank_count = 1
	),
-- 2. покупатель, арендовавший фильмов на самую большую сумму	
	cte2 as (
select
	*
from
	(
	select
		c.country_id,
		c.country ,
		c3.first_name ,
		c3.last_name,
		rank() over (partition by c.country_id
	order by
		sum(p.amount) desc) as rank_sum
	from
		payment p
	inner join customer c3
			using(customer_id)
	inner join address a
			using(address_id)
	inner join city c2
			using(city_id)
	inner join country c
			using(country_id)
	group by
		c.country_id,
		c3.customer_id) q2
where
	rank_sum = 1
	),
-- 3. покупатель, который последним арендовал фильм		
	cte3 as (
select
	*
from
	(
	select
		c.country_id,
		c.country,
		c3.first_name,
		c3.last_name,
		row_number() over( partition by c.country_id
	order by
		p.payment_date desc) as rn,
		last_value(p.payment_date) over (partition by c3.customer_id
	order by
		p.payment_date desc) as lv
	from
		payment p
	inner join customer c3
			using(customer_id)
	inner join address a
			using(address_id)
	inner join city c2
			using(city_id)
	inner join country c
			using(country_id)
	group by
		c.country_id,
		c3.customer_id,
		p.payment_date
	order by
		c.country_id,
		p. payment_date desc) q
where
	rn = 1)
--А теперь все результаты в одном запросе	
	select
	c1.country as "Страна",
	c1.first_name || ' ' || c1.last_name as "FIO_1",
	--rank_count,
	c2.first_name || ' ' || c2.last_name as "FIO_2",
	--rank_sum,
	c3.first_name || ' ' || c3.last_name as "FIO_3", 
	lv
from
	cte1 c1
inner join cte2 c2
		using(country_id)
inner join cte3 c3
		using(country_id);




