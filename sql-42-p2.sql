������� ' ' �� " "

' ' - ��������� ��������
" " - ��������� �������� ��������� �� �����_����� "�����-�����"

����������������� �����

select "name"
from "language" 

select name
from language 

select "select"
from "from"

�������������� ������� ���������� select;

select �������, �������, �������
from ������� 
join ������� on �������
where ������� 
group by ����������� 
having ������� � ��������������� ������
order by 
offset 
limit

���������� ������� ���������� select;

from 
on 
join 
where 
group by
having
select ����� ������ ������ (����������)
order by 
offset 
limit

pg_typeof()

select pg_typeof(customer_id)
from customer 

select pg_typeof(100)

select pg_typeof(100.)

select pg_typeof('100')

select pg_typeof(100 + '100'::numeric)

select 100 + '100'::numeric

select pg_typeof('a' || '100'::numeric)

select 'a' || '100'::numeric

1. �������� �������� id ������, ��������, ��������, ��� ������ �� ������� ������.
������������ ���� ���, ����� ��� ��� ���������� �� ����� Film (FilmTitle ������ title � ��)
- ����������� ER - ���������, ����� ����� ���������� �������
- as - ��� ������� ��������� 

select film_id, title, description, release_year
from film 

select film_id FilmFilm_id, title FilmTitle, description FilmDescription, release_year FilmRelease_year
from film 

select film_id as FilmFilm_id, title as FilmTitle, description as FilmDescription, release_year as FilmRelease_year
from film 

select film_id "FilmFilm_id", title "FilmTitle", description "FilmDescription", release_year "��� ������� ������"
from film

select 1 as "����� ������� � �� ������� ��� ���� ����� ��������"

"����� ������� � �� ������� ��� ���"

63/64

��������
����������
���� � �����
�����

integer 
numeric(10,2) 99999999,99 / money 
float
--serial = integer + ������� + �������� �� ��������� = �������������
/*  
 * 
 * */

2. � ����� �� ������ ���� ��� ��������:
rental_duration - ����� ������� ������ � ����  
rental_rate - ��������� ������ ������ �� ���� ���������� �������. 
��� ������� ������ �� ������ ������� �������� ��������� ��� ������ � ����,
������� ������������ ������� ��������� cost_per_day
- ����������� ER - ���������, ����� ����� ���������� �������
- ��������� ������ � ���� - ��������� rental_rate � rental_duration
- as - ��� ������� ��������� 

select title, rental_rate / rental_duration as cost_per_day
from film

select title, rental_rate / rental_duration as cost_per_day,
	rental_rate * rental_duration,
	rental_rate + rental_duration,
	rental_rate - rental_duration,
	power(rental_rate, rental_duration),
	rental_rate^rental_duration
from film

2*
- �������������� ��������
- �������� round

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film

select title, round(rental_rate::float / rental_duration, 2) as cost_per_day
from film

������: ������� round(double precision, integer) �� ����������

select round( 8/17, 2)

select round( 8./17, 2)

round(numeric, int)

round(float)

SELECT pg_typeof(x),
  round(x::numeric) AS num_round,
  round(x::float) AS dbl_round
FROM generate_series(-3.5, 3.5, 1) as x;

3.1 ������������� ������ ������� �� �������� ��������� �� ���� ������ (�.2)
- ����������� order by (�� ��������� ��������� �� �����������)
- desc - ���������� �� ��������

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film
order by round(rental_rate / rental_duration, 2) desc

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film
order by cost_per_day desc

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film
order by 2 desc

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film
order by 2 desc, rental_duration, 1

3.1* ������������ ������� �������� �� ����������� ����� ������� (amount)
- ����������� ER - ���������, ����� ����� ���������� �������
- ����������� order by 
- asc - ���������� �� ����������� 

select * 
from payment 
order by amount --asc

3.2 ������� ���-10 ����� ������� ������� �� ��������� �� ���� ������
- ����������� limit

��� 3 

1 - 10
5 - 9
4 - 8

10

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film
order by 2 desc
limit 10

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film
order by 2 desc
fetch first 10 rows only

3.2.1 ������� ���-1 ����� ������� ������� �� ��������� �� ���� ������, �� ���� ������� ��� 62 ������
--������� � 13 ������
select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film
order by 2 desc
fetch first 63 row with ties

select version()


3.3 ������� ���-10 ����� ������� ������� �� ��������� ������ �� ����, ������� � 58-�� �������
- �������������� Limit � offset

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film
order by 2 desc
offset 57
limit 10

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film
order by 2 desc, 1
offset 57
limit 10

3.3* ������� ���-15 ����� ������ ��������, ������� � ������� 14000
- �������������� Limit � Offset

select *
from payment 
order by amount 
offset 13999
limit 15

4. ������� ��� ���������� ���� ������� �������
- �������������� distinct

select distinct release_year
from film

select release_year
from film

4* ������� ���������� ����� �����������
- ����������� ER - ���������, ����� ����� ���������� �������
- �������������� distinct

select distinct first_name --591
from customer 

select distinct first_name, last_name --599
from customer 

select distinct last_name --599
from customer 

select first_name --599
from customer 

-- ��� �� ����
explain analyze --22.48
select distinct customer_id
from customer 

explain analyze --14.99
select customer_id
from customer 

select distinct customer_id, payment_id, amount, payment_date --16049
from payment 
order by 1, 4 desc

select distinct on (customer_id) customer_id, payment_id, amount, payment_date --599
from payment 
order by 1, 4 desc

select distinct on (customer_id) customer_id, payment_id, amount, payment_date --599
from payment 
order by 1, 4 desc

select distinct on (customer_id, amount) customer_id, amount, payment_id, amount, payment_date --599
from payment 
order by 1, 2, 4 desc

select distinct on (customer_id, amount)  payment_id, payment_date --599
from payment 


5.1. ������� ���� ������ �������, ������� ������� 'PG-13', � ����: "�������� - ��� �������"
- ����������� ER - ���������, ����� ����� ���������� �������
- "||" - �������� ������������, ������� �� concat
- where - ����������� ����������
- "=" - �������� ���������

text 
varchar(N) 0 - N
char(N) char(10) 11 'aaaaa     '

select title, release_year, rating
from film 

select title, release_year, rating
from film 
where rating = 'PG-13'

select title || ' - ' || release_year, rating
from film 
where rating = 'PG-13'

select concat(title, ' - ', release_year), rating
from film 
where rating = 'PG-13'

select concat(last_name, ' ', first_name, ' ', middle_name)
from person 

select concat_ws(' ', last_name, first_name, middle_name)
from person

select 'Hello' || null

select concat('Hello', null)

5.2 ������� ���� ������ �������, ������� �������, ������������ �� 'PG'
- cast(�������� ������� as ���) - ��������������
- like - ����� �� �������
- ilike - ������������������� �����
- lower
- upper
- length

select title, pg_typeof(rating)
from film

select title, rating
from film
where rating like 'PG%'

������: �������� �� ����������: mpaa_rating ~~ unknown

% - �� 0 �� ������ ���������� ��������
_ - ���� ����� ������

~~ - �������� like 
~ - ���������� ���������

select title, rating
from film
where rating::varchar like 'PG%'

select title, rating
from film
where cast(rating as text) like 'PG%'

select title, rating
from film
where rating::varchar like 'PG___'

select title, rating
from film
where rating::varchar like 'PG%' and char_length(rating::varchar) = 5

select title, rating
from film
where rating::varchar like '%-%'

select title, rating
from film
where rating::varchar not like '%-%'

select title, rating
from film
where title like '%\%%'

select title, rating
from film
where title like '%!%%' escape '!'

select title, rating
from film
where title like '%\\%' 

select title, rating
from film
where rating::varchar ilike 'pg%'

select title, rating
from film
where lower(rating::varchar) like 'pg%'

select title, rating
from film
where upper(rating::varchar) like 'PG%'

select ''''

select title, rating
from film
where title like '%A%' or title like '%D%' or title like '%A%D%' or title like '%D%A%'

select '�''��������'

5.2* �������� ���������� �� ����������� � ������ ���������� ���������'jam' (���������� �� �������� ���������), � ����: "��� �������" - ����� �������.
- "||" - �������� ������������
- where - ����������� ����������
- ilike - ������������������� �����
- strpos
- character_length
- overlay
- substring
- split_part

select *
from customer 
where first_name ilike '%jam%'

select strpos('Hello world', 'world') --7

select character_length('Hello world') --11

select char_length('Hello world') --11

select length('Hello world') --11

select length('������ ���') --10

select octet_length('������ ���') --19

select overlay('Hello world' placing 'Max' from 7 for 5) 

select overlay('Hello world' placing 'Max' from strpos('Hello world', 'world') for length('world')) 

select concat_ws(' ', last_name, first_name, middle_name),
	overlay(concat_ws(' ', last_name, first_name, middle_name) placing '������' 
		from strpos(concat_ws(' ', last_name, first_name, middle_name), '������') for length('������')) 
from person 
where first_name = '������'

select customer_id, initcap(email)
from customer 

select split_part(email, '@', 1), split_part(email, '@', 2)
from customer 

select split_part('������ ��� � ����', ' ', 1),
	split_part('������ ��� � ����', ' ', 2),
	split_part('������ ��� � ����', ' ', 3),
	split_part('������ ��� � ����', ' ', 4)
	
select customer_id, email
from customer 

pA.T.R.ICia.JOHNSON@sa..kILAcustomer.org

select left('Hello world', 3)

select right('Hello world', 3)

select left('Hello world', -3)

select right('Hello world', -3)

select trim(' Hello world ')

select trim(both from 'dffdfdfdfffdfdHello worlddfdfffdddfdfd', 'fd')

leading
trailing 

select substring('Hello world', 5, 3)

select substring('Hello world' from 5 for 3)

date 
timestamp 
timestamptz
time 
timetz
interval

select rental_date
from rental 

2005-05-24 22:53:30ms+tz

Ru/Eu
YYYY-mm-dd HH:mm:ss
YYYY.mm/dd HH:mm:ss
dd.mm.YYYY

US
YYYY-mm-dd
mm-dd-YYYY

17.05.2000

6. �������� id �����������, ������������ ������ � ���� � 27-05-2005 �� 28-05-2005 ������������
- ����������� ER - ���������, ����� ����� ���������� �������
- between - ������ ���������� (������ ... >= ... and ... <= ...)
- date_part()
- date_trunc()
- interval
-- extract

--������ �� ������
select customer_id, rental_date
from rental
where rental_date >= '27-05-2005' and rental_date <= '28-05-2005'
order by 2 desc

--������ �� ������
select customer_id, rental_date
from rental
where rental_date between '27-05-2005' and '28-05-2005' 
order by 2 desc

select customer_id, rental_date
from rental
where rental_date between '27-05-2005 00:00:00' and '28-05-2005 00:00:00' 
order by 2 desc

--��� �� ������ ������
select customer_id, rental_date
from rental
where rental_date between $1 and $2
order by 2 desc

select customer_id, rental_date
from rental
where rental_date between '27-05-2005' and '29-05-2005' 
order by 2 desc

select customer_id, rental_date
from rental
where rental_date between '27-05-2005' and '28-05-2005'::date + interval '1 day' 
order by 2 desc

select customer_id, rental_date
from rental
where rental_date between '27-05-2005' and '28-05-2005 24:00:00'
order by 2 desc

--�����
select customer_id, rental_date
from rental
where rental_date::date between '27-05-2005' and '28-05-2005'
order by 2 desc
  
6* ������� ������� ����������� ����� 2005-07-08
- ����������� ER - ���������, ����� ����� ���������� �������
- > - ������� ������ (< - ������� ������)

select *
from payment 
where payment_date::date > '2005-07-08'

select customer_id, date_part('year', rental_date), 
	date_part('month', rental_date), 
	date_part('day', rental_date), 
	date_part('isodow', rental_date),
	date_part('minutes', rental_date) 
from rental

04.2020
04.2021
04.2022

4 and ���

select customer_id, date_trunc('year', rental_date), 
	date_trunc('month', rental_date), 
	date_trunc('day', rental_date), 
	date_trunc('minutes', rental_date) 
from rental

timestamp - timestamp = interval 
date - date = integer

7 �������� ���������� ���� � '30-04-2007' �� ����������� ����.
�������� ���������� ������� � '30-04-2007' �� ����������� ����.
�������� ���������� ��� � '30-04-2007' �� ����������� ����.

select now()

select current_timestamp

select current_date

select current_time

select timeofday()

--���:

select current_date - '30-04-2007'

select current_timestamp - '30-04-2007'

--������:
select date_part('year', age(current_date, '30-04-2007')) * 12 + date_part('month', age(current_date, '30-04-2007'))

--����:

select date_part('year', age(current_date, '30-04-2007'))


select current_date - interval '3 days'

boolean 
true t 1 on yes
false f 0 off no

8 ���������� ��������� and � or

select customer_id, amount
from payment 
where customer_id < 3 and amount = 2.99 or amount = 4.99

�������� and ����� ��������� ����� or

select customer_id, amount
from payment 
where customer_id < 3 and (amount = 2.99 or amount = 4.99)

select customer_id, amount
from payment 
where (customer_id = 1 and amount = 2.99) or (customer_id = 2 and amount = 4.99)

select customer_id, amount
from payment 
where customer_id = 1 and amount = 2.99 or customer_id = 2 and amount = 4.99

select customer_id, amount
from payment 
where (customer_id = 1 or amount = 2.99) and (customer_id = 2 or amount = 4.99)