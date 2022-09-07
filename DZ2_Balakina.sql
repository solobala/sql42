--=============== ������ 2. ������ � ������ ������ =======================================
--= �������, ��� ���������� ���������� ������ ���������� � ������� ����� PUBLIC===========
SET search_path TO public;

--======== �������� ����� ==============

--������� �1
--�������� ���������� �������� ������� �� ������� �������.
select
	distinct city
from
	city;





--������� �2
--����������� ������ �� ����������� �������, ����� ������ ������� ������ �� ������,
--�������� ������� ���������� �� �L� � ������������� �� �a�, � �������� �� �������� ��������.
select
	distinct city
from
	city
where
	city like 'L%a'
	and city not like '% %';




--������� �3
--�������� �� ������� �������� �� ������ ������� ���������� �� ��������, ������� ����������� 
--� ���������� � 17 ���� 2005 ���� �� 19 ���� 2005 ���� ������������, 
--� ��������� ������� ��������� 1.00.
--������� ����� ������������� �� ���� �������.
select
	payment_id,
	payment_date,
	amount
from
	payment
where
	payment_date between '2005-06-17' and '2005-06-19'
	and amount >1.00
order by
	payment_date;





--������� �4
-- �������� ���������� � 10-�� ��������� �������� �� ������ �������.

select
	payment_id,
	payment_date,
	amount
from
	payment
order by
	payment_date desc
limit 10;



--������� �5
--�������� ��������� ���������� �� �����������:
--  1. ������� � ��� (� ����� ������� ����� ������)
--  2. ����������� �����
--  3. ����� �������� ���� email
--  4. ���� ���������� ���������� ������ � ���������� (��� �������)
--������ ������� ������� ������������ �� ������� �����.

select
	first_name || ' ' || last_name as "������� � ���",
	email as "����������� �����",
	character_length(email) as "����� email",
	last_update::DATE as "����" 
from
	customer;



--������� �6
--�������� ����� �������� ������ �������� �����������, ����� ������� KELLY ��� WILLIE.
--��� ����� � ������� � ����� �� �������� �������� ������ ���� ���������� � ������ �������.

select
	lower(last_name),
	lower(first_name),
	active
from
	customer
where
	first_name = 'KELLY'
	or first_name = 'WILLIE'
	and activebool = true;



--======== �������������� ����� ==============

--������� �1
--�������� ����� �������� ���������� � �������, � ������� ������� "R" 
--� ��������� ������ ������� �� 0.00 �� 3.00 ������������, 
--� ����� ������ c ��������� "PG-13" � ���������� ������ ������ ��� ������ 4.00.

select
	film_id,
	title,
	description,
	rating,
	rental_rate
from
	film
where
	rating = 'R'
	and rental_rate <= 3.00
union 
select
	film_id,
	title,
	description,
	rating,
	rental_rate
from
	film
where
	rating = 'PG-13'
	and rental_rate >= 4.00;



--������� �2
--�������� ���������� � ��� ������� � ����� ������� ��������� ������.

select
	film_id,
	title,
	description
from
	film
order by
	character_length(description) desc
limit 3;


--������� �3
-- �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������:
--� ������ ������� ������ ���� ��������, ��������� �� @, 
--�� ������ ������� ������ ���� ��������, ��������� ����� @.

select
	customer_id,
	email,
	substring(email from 1 for strpos(email, '@')-1) as "Email before @",
	substring(email from strpos(email, '@')+ 1 for character_length(email)-strpos(email, '@')+ 1)as "Email after @"
from
	customer;



--������� �4
--����������� ������ �� ����������� �������, �������������� �������� � ����� ��������: 
--������ ����� ������ ���� ���������, ��������� ���������.


select
	substring(email from 1 for 1)|| 
	lower(substring(email from 2 for strpos(email, '@')-1)) as "Email before @",
	upper(substring(email from strpos(email, '@')+ 1 for 1))||
	substring(email from strpos(email, '@')+ 2 for character_length(email)-strpos(email, '@')+ 1) as "Email after @"
from
	customer;

