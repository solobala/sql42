--=============== ������ 5. ������ � POSTGRESQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ������ � ������� payment � � ������� ������� ������� �������� ����������� ������� �������� ��������:
--������������ ��� ������� �� 1 �� N �� ����

select
	customer_id,
	payment_id,
	payment_date,
	row_number() over (partition by payment_date::date order by payment_date)
from payment;
	

--������������ ������� ��� ������� ����������, ���������� �������� ������ ���� �� ����
select
	customer_id,
	payment_id,
	payment_date,
	row_number() over (partition by customer_id order by payment_date)
from
	payment
order by customer_id;

--���������� ����������� ������ ����� ���� �������� ��� ������� ����������, ���������� ������ 
--���� ������ �� ���� �������, � ����� �� ����� ������� �� ���������� � �������

select
	customer_id,
	payment_id,
	amount,
	payment_date,
	sum(amount) over (partition by customer_id order by payment_date, amount) 
from
	payment
order by customer_id;

--������������ ������� ��� ������� ���������� �� ��������� ������� �� ���������� � ������� 
--���, ����� ������� � ���������� ��������� ����� ���������� �������� ������.
--����� ��������� �� ������ ����� ��������� SQL-������, � ����� ���������� ��� ������� � ����� �������.

select
	customer_id,
	payment_id,
	amount,
	payment_date,
	dense_rank () over (partition by customer_id order by amount desc)
from
	payment
order by customer_id;



--������� �2
--� ������� ������� ������� �������� ��� ������� ���������� ��������� ������� � ��������� 
--������� �� ���������� ������ �� ��������� �� ��������� 0.0 � ����������� �� ����.

select
	customer_id,
	payment_id,
	payment_date,
	amount as "��������� �������",
	lag(amount, 1, 0.0) over (partition by customer_id order by payment_date) as "���������� ��������"
		
from
	payment
order by customer_id;	



--������� �3
--� ������� ������� ������� ����������, �� ������� ������ ��������� ������ ���������� ������ ��� ������ ��������.

select
	customer_id,
	payment_id,
	payment_date,
	amount,
	amount - lead(amount, 1, 0.0) over (partition by customer_id order by payment_date, customer_id) as difference
from
	payment;


--������� �4
--� ������� ������� ������� ��� ������� ���������� �������� ������ � ��� ��������� ������ ������.

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




--======== �������������� ����� ==============

--������� �1
--� ������� ������� ������� �������� ��� ������� ���������� ����� ������ �� ������ 2005 ���� 
--� ����������� ������ �� ������� ���������� � �� ������ ���� ������� (��� ����� �������) 
--� ����������� �� ����.


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
	staff_id as "ID ����������",
	payment_date as "����",
	sum_amount as "������� �� ����",
	sum(sum_amount) over (partition by staff_id
order by
	date_trunc('month', payment_date)
                rows between unbounded preceding and current row) as "������� � ������ ������"
from
	cte1
order by
	staff_id;






--������� �2
--20 ������� 2005 ���� � ��������� ��������� �����: ���������� ������� ������ ������� �������
--�������������� ������ �� ��������� ������. � ������� ������� ������� �������� ���� �����������,
--������� � ���� ���������� ����� �������� ������


select
			t.customer_id as "ID �������",
			t.payment_date as "����",
			t.payment_number as "����� �������"
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
	
	

--������� �3
--��� ������ ������ ���������� � �������� ����� SQL-�������� �����������, ������� �������� ��� �������:



	
-- 1. ����������, ������������ ���������� ���������� �������	
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
-- 2. ����������, ������������ ������� �� ����� ������� �����	
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
-- 3. ����������, ������� ��������� ��������� �����		
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
--� ������ ��� ���������� � ����� �������	
	select
	c1.country as "������",
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




