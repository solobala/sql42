--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select
	c.first_name||' '||	c.last_name as "Customer name",
	ad.address,
	ci.city,
	co.country
from
	customer c
inner join address ad
		using(address_id)
inner join city ci
		using(city_id)
inner join country co
		using(country_id);



--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select
	store_id as "ID магазина",
	count(customer_id) as "Количество покупателей"
	from customer
group by
	store_id;




--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

select
	store_id as "ID магазина",
	count(customer_id) as "Количество покупателей"
from
	customer
group by
	store_id
having
	count(customer_id) >300;




-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

select
	st.store_id as "ID магазина",
	count(customer_id) as "Количество покупателей",
	ci.city as "Город",
	concat(stf.last_name, ' ', stf.first_name) as "Имя сотрудника"
from
	store st
inner join staff stf on
	st.manager_staff_id = stf.staff_id
inner join address ad on
	st.address_id = ad.address_id
inner join city ci on
	ad.city_id = ci.city_id
inner join customer c on
	st.store_id = c.store_id
group by
	ci.city,
	st.store_id,
	stf.first_name,
	stf.last_name
having
	count(customer_id) >300;




--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select
	c.last_name || ' ' || c.first_name as "Фамилия и имя покупателя",
	count(i.film_id) as "Количество фильмов"
from
	customer c
inner join rental r
		using (customer_id)
inner join inventory i
		using(inventory_id)
group by
	c.customer_id,
	c.first_name,
	c.last_name
order by
	count(i.film_id) desc
limit 5;




--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма 


select
	
	c.last_name || ' ' || c.first_name as "Фамилия и имя покупателя",
	count(p.rental_id) as "Количество фильмов",
	round(sum(p.amount), 0) as "Общая стоимость платежей",
	min(p.amount) as "Минимальная стоимость платежа",
	max(p.amount) as "Максимальная стоимость платежа"
from
	customer c
inner join payment p
		using(customer_id)
group by
	c.customer_id,
	c.first_name,
	c.last_name;





--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.

select ci.city as "Город 1", ct.city as "Город 2"  
from city ci, city ct
where ct.city!= ci.city;


--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 
select
	customer_id as "ID покупателя",
	round(avg(return_date::date-rental_date::date), 2) as "Среднее количество дней на возврат"
from
	customer
inner join rental
		using(customer_id)
group by
	customer_id,
	first_name,
	last_name
order by customer_id;



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
select
	title as "Название фильма",
	rating as "Рейтинг",
	c.name as "Жанр",
	release_year as "Год выпуска",
	l.name as "Язык",
	count(r.rental_id) as "Количество аренд",
	sum(amount) as "Общая стоимость аренды"
from
	film
inner join film_category fc
		using(film_id)
inner join category c
		using(category_id)
inner join language l
		using(language_id)
inner join inventory
		using(film_id)
inner join rental r
		using(inventory_id)
inner join payment
		using(rental_id)
group by
	title,
	rating,
	c.name,
	release_year,
	l.name;


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.


select
	title as "Название фильма",
	rating as "Рейтинг",
	c.name as "Жанр",
	release_year as "Год выпуска",
	l.name as "Язык",
	count(r.rental_id) as "Количество аренд",
	sum(amount) as "Общая стоимость аренды"
from
	film
inner join film_category fc
		using(film_id)
inner join category c
		using(category_id)
inner join language l
		using(language_id)
left join inventory
		using(film_id)
left join rental r
		using(inventory_id)
left join payment
		using(rental_id)
where
	rental_id is null
group by
	title,
	rating,
	c.name,
	release_year,
	l.name;


--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".


select
	s.staff_id,
	count(payment_id) as "Количество продаж",
	case
		when count(payment_id)>7300 then 'Да'
		else 'Нет'
	end as "Премия"
from
	staff s
inner join payment p
		using(staff_id)
group by
	s.staff_id;






