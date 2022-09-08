������� 1.�������� ����� �������� ���������� � �������, � ������� ������� �R� � 
��������� ������ ������� �� 0.00 �� 3.00 ������������, � ����� ������ c ��������� �PG-13� 
� ���������� ������ ������ ��� ������ 4.00.

select title, rating, rental_rate
from film 
where (rating = 'R' and rental_rate between 0. and 3.) or (rating = 'PG-13' and rental_rate >= 4.)

between ���� �����, ���  >= and <=

������� 2. �������� ���������� � ��� ������� � ����� ������� ��������� ������.

select title, description, character_length(description)
from film 
order by character_length(description) desc 
limit 3

fetch first 3 row with ties

������� 3. �������� Email ������� ����������, �������� �������� Email �� 2 ��������� �������:
� ������ ������� ������ ���� ��������, ��������� �� @,
�� ������ ������� ������ ���� ��������, ��������� ����� @.

select customer_id, email, split_part(email, '@', 1), split_part(email, '@', 2)
from customer 

������� 4. ����������� ������ �� ����������� �������, �������������� �������� � ����� ��������: 
������ ����� ������ ���� ���������, ��������� ���������.

select customer_id, email, 
	initcap(split_part(email, '@', 1)), 
	initcap(split_part(email, '@', 2))
from customer 

select customer_id, email,
	concat(upper(left(lower(split_part(email, '@', 1)), 1)), right(lower(split_part(email, '@', 1)), 
	length(split_part(email, '@', 1))-1))
from customer 

explain analyze --35.96
select customer_id, email, 
	concat(upper(left(split_part(email, '@', 1), 1)),  lower(right(split_part(email, '@', 1), -1))),
	concat(upper(left(split_part(email, '@', 2), 1)),  lower(right(split_part(email, '@', 2), -1)))
from customer 

explain analyze --34,46
select customer_id, email, 
	concat(upper(left(email, 1)),  lower(right(split_part(email, '@', 1), -1))),
	concat(upper(left(split_part(email, '@', 2), 1)),  lower(right(split_part(email, '@', 2), -1)))
from customer 

explain analyze
select customer_id, email, 
	upper(left(email, 1)) ||  lower(right(split_part(email, '@', 1), -1)),
	upper(left(split_part(email, '@', 2), 1)) ||  lower(right(split_part(email, '@', 2), -1))
from customer 

explain analyze --32.96
select customer_id, email, 
	overlay(lower(split_part(email, '@', 1)) placing upper(left(split_part(email, '@', 1), 1)) from 1 for 1), 
	overlay(lower(split_part(email, '@', 2)) placing upper(left(split_part(email, '@', 2), 1)) from 1 for 1)
from customer 

explain analyze --67.21
select upper(substring(lower(split_part(email,'@',1)) from 1 for 1)) || 
	substring(lower(split_part(email,'@',1)) from 2 for length(split_part(email,'@',1))) as "first_part", 
	upper(substring(lower(split_part(email,'@',2)) from 1 for 1)) || 
	substring(lower(split_part(email,'@',2)) from 2 for length(split_part(email,'@',2))) as "second_part"
from customer
order by customer_id

explain analyze --52.43
select
	customer_id,
	email,
	upper(substring(email from 1 for 1))
	||
	LOWER (substring(email from 2 for 
		position ('@' in "email")-2))
			as "��������, ��������� �� @",
	upper (substring
			(substring(email from 
				position ('@' in "email")+1	for
					character_length( email )-(position ('@' in "email"))+1 ) from 1 for 1) )
	||
	lower(substring(email 
		from position ('@' in "email")+2 for character_length( email )-(position ('@' in "email"))+2 ))
			as "��������, ��������� ����� @"
from customer

explain analyze --34.46
select customer_id, email, 
	concat(upper(substring(email, 1, 1)), lower(substring(split_part(email, '@', 1), 2))) "���-�� ���-��",
	concat(upper(substring(split_part(email, '@', 2), 1, 1)), lower(substring(split_part(email, '@', 2), 2)))
from customer 

explain analyze
select *
from customer c
join payment p on p.customer_id = c.customer_id

regexp_match()
regexp_matchs()
~
\g
[0-9] d 
[a-Z�-�]

select distinct ...................

1	a
1	a
1	b

1	a
	b
	
select distinct   city

1	London
2	London

70%

declare x int = 100;

select 
from customer 
where customer_id = x

���� ������� ������� ������� ����� ��� 

����� ������� �������

- 
 
create extension file_fdw

select * from customer c

create server lets_read_excel
foreign data wrapper file_fdw

CREATE FOREIGN TABLE customer_csv (
	customer_id int4 NOT NULL,
	store_id int2 NOT NULL,
	first_name varchar(45) NOT NULL,
	last_name varchar(45) NOT NULL,
	email varchar(50) NULL,
	address_id int2 NOT NULL,
	activebool bool NOT NULL,
	create_date date NOT NULL,
	last_update timestamp NULL,
	active int4 NULL)
SERVER lets_read_excel 
OPTIONS ( filename 'c:\customer.csv', format 'csv', delimiter ';', header 'true' );

select customer_id, last_name 
from "from"
group by 2

create role aa login