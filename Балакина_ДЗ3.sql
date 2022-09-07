--=============== ������ 3. ������ SQL =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ��� ������� ���������� ��� ����� ����������, 
--����� � ������ ����������.

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



--������� �2
--� ������� SQL-������� ���������� ��� ������� �������� ���������� ��� �����������.
select
	store_id as "ID ��������",
	count(customer_id) as "���������� �����������"
	from customer
group by
	store_id;




--����������� ������ � �������� ������ �� ��������, 
--� ������� ���������� ����������� ������ 300-��.
--��� ������� ����������� ���������� �� ��������������� ������� 
--� �������������� ������� ���������.

select
	store_id as "ID ��������",
	count(customer_id) as "���������� �����������"
from
	customer
group by
	store_id
having
	count(customer_id) >300;




-- ����������� ������, ������� � ���� ���������� � ������ ��������, 
--� ����� ������� � ��� ��������, ������� �������� � ���� ��������.

select
	st.store_id as "ID ��������",
	count(customer_id) as "���������� �����������",
	ci.city as "�����",
	concat(stf.last_name, ' ', stf.first_name) as "��� ����������"
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




--������� �3
--�������� ���-5 �����������, 
--������� ����� � ������ �� �� ����� ���������� ���������� �������
select
	c.last_name || ' ' || c.first_name as "������� � ��� ����������",
	count(i.film_id) as "���������� �������"
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




--������� �4
--���������� ��� ������� ���������� 4 ������������� ����������:
--  1. ���������� �������, ������� �� ���� � ������
--  2. ����� ��������� �������� �� ������ ���� ������� (�������� ��������� �� ������ �����)
--  3. ����������� �������� ������� �� ������ ������
--  4. ������������ �������� ������� �� ������ ������ 


select
	
	c.last_name || ' ' || c.first_name as "������� � ��� ����������",
	count(p.rental_id) as "���������� �������",
	round(sum(p.amount), 0) as "����� ��������� ��������",
	min(p.amount) as "����������� ��������� �������",
	max(p.amount) as "������������ ��������� �������"
from
	customer c
inner join payment p
		using(customer_id)
group by
	c.customer_id,
	c.first_name,
	c.last_name;





--������� �5
--��������� ������ �� ������� ������� ��������� ����� �������� ������������ ���� ������� ����� �������,
 --����� � ���������� �� ���� ��� � ����������� ���������� �������. 
 --��� ������� ���������� ������������ ��������� ������������.

select ci.city as "����� 1", ct.city as "����� 2"  
from city ci, city ct
where ct.city!= ci.city;


--������� �6
--��������� ������ �� ������� rental � ���� ������ ������ � ������ (���� rental_date)
--� ���� �������� ������ (���� return_date), 
--��������� ��� ������� ���������� ������� ���������� ����, �� ������� ���������� ���������� ������.
 
select
	customer_id as "ID ����������",
	round(avg(return_date::date-rental_date::date), 2) as "������� ���������� ���� �� �������"
from
	customer
inner join rental
		using(customer_id)
group by
	customer_id,
	first_name,
	last_name
order by customer_id;



--======== �������������� ����� ==============

--������� �1
--���������� ��� ������� ������ ������� ��� ��� ����� � ������ � �������� ����� ��������� ������ ������ �� �� �����.
select
	title as "�������� ������",
	rating as "�������",
	c.name as "����",
	release_year as "��� �������",
	l.name as "����",
	count(r.rental_id) as "���������� �����",
	sum(amount) as "����� ��������� ������"
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


--������� �2
--����������� ������ �� ����������� ������� � �������� � ������� ������� ������, ������� �� ���� �� ����� � ������.


select
	title as "�������� ������",
	rating as "�������",
	c.name as "����",
	release_year as "��� �������",
	l.name as "����",
	count(r.rental_id) as "���������� �����",
	sum(amount) as "����� ��������� ������"
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


--������� �3
--���������� ���������� ������, ����������� ������ ���������. �������� ����������� ������� "������".
--���� ���������� ������ ��������� 7300, �� �������� � ������� ����� "��", ����� ������ ���� �������� "���".


select
	s.staff_id,
	count(payment_id) as "���������� ������",
	case
		when count(payment_id)>7300 then '��'
		else '���'
	end as "������"
from
	staff s
inner join payment p
		using(staff_id)
group by
	s.staff_id;






