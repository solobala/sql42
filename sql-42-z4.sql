����� ������� ���������� � group by. �� ������ ������� ������ �������������, 
������ ������ ��� ������� ������, � ������ , ���

select customer_id, amount 
from payment p

select customer_id, sum(amount) 
from payment p
group by customer_id

1 - �����
2 - �����

1	�����
1
1

select *
from table_one t1
right join table_two t2 on t1.name_one = t2.name_two
where t1.name_one is null

select a, b, c, 
	case
		when	then
		when	then
	end 
from

select staff_id, s.store_id, concat(first_name, ' ', last_name ) 
from staff s 
join store s2 on s2.manager_staff_id = s.staff_id

select customer_id, date_trunc('month', payment_date),
rank() over (partition by customer_id order by date_trunc('month', payment_date)),
dense_rank() over (partition by customer_id order by date_trunc('month', payment_date))
from payment 

select *
from employee_salary es
join grade_salary gs on es.salary between gs.min_salary and gs.max_salary

select p1.payment_id, p1.payment_date::date, p2.payment_id, p2.payment_date::date
from payment p1
join payment p2 on p1.payment_date::date = p2.payment_date::date - 1

 select customer_id, email, concat(upper(left(split_part(email, '@', 1), 1)), lower(substring(split_part(email, '@', 1), 2))) as "Email before @",
concat(upper(left(split_part(email, '@', 2), 1)), lower(substring(split_part(email, '@', 2), 2))) as "Email after @" from customer c;

overlay
right(split_part(email, '@', 1), -1)

select count(*)
from customer c
cross join payment p
join rental r on r.rental_id = p.rental_id
left join inventory i on i.inventory_id = r.inventory_id
right join film f on f.film_id = i.film_id
full join film_category fc on f.film_id = fc.film_id

� ����� public ���� ���� ������� ( film_in_stock, last_day, get_customer_balance � �.�.). 
��� ��� ��� ������������? ��� ����� �� ���� ����������?

https://dev.mysql.com/doc/sakila/en/sakila-structure.html

select *
from customer c 
where customer_id = inventory_held_by_customer(6)

select * 
from rewards_report(5, 1)

from t1
cross join t2
cross join t3, t4

create temporary table a as (select count(*)
from customer c
cross join payment p
join rental r on r.rental_id = p.rental_id
left join inventory i on i.inventory_id = r.inventory_id
right join film f on f.film_id = i.film_id
full join film_category fc on f.film_id = fc.film_id)

select * from a

view(p1, p2)

order by 
having 
where 

where customer_id = 1
group by
having 

select customer_id, sum(amount) * x
from payment p
--where customer_id = 1
group by customer_id
having sum(amount) = (
	select max(sum)
	from (
		select customer_id, sum(amount) 
		from payment 
		group by customer_id) t)

a	b 
���� � ������ 

���� �� ������
a							b 
a_id PK						b_id
b_id references b(b_id)

1, 1
2, 1
3, 1

������ �� ������
a				b 				a_b
a_id PK			b_id PK			b_id references b(b_id)
								a_id references a(a_id)
								b_id+a_id PK
	
a_b 
1,1
2,1
1,2

���� �������� - ������� �������
������� - ������ ���� �����
������ - ������� �� ������ �������

where x in (��������� ������������ ������) (1, 6, 57)

select *
from payment p
where (customer_id, payment_date) = (1, '2005-05-28 10:35:23')

from ���������1 (�������1)
join ���������2 (�������2)

with recursive r as (
	select 100 as x
	union select
	x+100 as x
	from r
	where x < (select count(*) from payment))
	
with recursive r as (
	select 1 as x
	from payment 
	union 
	select x+1 as x
	from r
	where x < (select max(payment_id) from payment))
select * from r

select *
from (
	select *, row_number() over (order by payment_date)
	from payment p) t
where row_number % 100 = 0

1. ������� ������ �� ������ � SQL � �������� �������� � ����� ��������� � DS?
2. �������������� ����� ������� ������� ����� �� SQL � �������� �������� (�� ������� 3.. 5 �����), 
��� ������ ��� �� ��� ��������� ������ �����������?
3. ��������� ����� ����� ��������� �������� ������?
4. ��� ������, ��� ����� � ������ ������? ���� ���-����?
5. ���� ������ �� SQL ���������� ������ ���� ������, ������� �� ����� ����� ������� ���������� 
�� �� ������� ������ (���������� ��, ��������� ��� �� ����������, ��������� �����, ������� ����� �� �����) 
� ����� ����������� ��������� ��� ����� ������� ������� ��� �� ���?
6. ��� ����� �������� ����� ������������ ������ PostgreSQL � Python?
7. ��� �� �� �������� ��� ������� �� ������������� � IT 5 ��� �����. �������� �� ��������� ��� �������, 
�������/�����������/���������, ���, � ������ �������� �����, ����� ���� ����� ������ ��-������� ��� ��������?

1) ���� �� �����������  ������������ ��� ������ postgresql? �� ���� ���� ���� �������� �� ����������
�������� � ����������� ����������� ���� ������ � Excel, ��������������� ����� csv � postgresql, 
�������� ��������� ������ � ID ��� ������ �������� � �� ������ � �������� �������� ����� ������ �������, 
��� ����� ���-�� ��� ���������������� (�������� �� ���������� :) )? 
2) ���� �� ������� � ���������� �������� ������ ������? ����������� �� ��� ��������������� ��������
�� ������� 
3) ��� ��������� �� ����� �� ������������ sql? ��� ��� ������ ��� �������� �� � ���� � �����������������,
� �� ��� ��������� ��������?
4) ���������, �� ����� ������, sql ���������� ��� �������������� �������� ������? ��� ��� ������ � ����
������ �� ��������?

create function foo (x int, y int, out z int) as $$
	begin
		select power(x, y) into z;
	end;
$$ language plpgsql

create function foo (int, int) returns int as $$
	declare z int;
	begin
		select power($1, $2) into z;
		return z;
	end;
$$ language plpgsql

select foo(5, 5) / foo(2, 7)


while 
for 1..100 / in (select ...)
foreach

������� ������. ���� ���� ��������, ����� ��������� � ���������� ���� �������, ����� �. �������� � sql.
������� 1

use db
 
db.users.insertMany([{name: 'a', dog: 'aa', price: 200, coll: 200, total: 40000, color: 'red'},
	{name: 'b', dog: 'aa', price: 300, coll: 150, total: 45000},
	{name: 'c', dog: 'bb', price: 50, coll: 100, total: 5000},
	{name: 'd', dog: 'bb', price: 25, coll: 100, total: 2500}])

������� 2
db.users.aggregate([{ $project: {name: 1, cat: 1, price:1, coll:1, total: {$multiply: ["$price", "$coll"]}}}])
db.users.aggregate({ $match: { cat: "aa" }}, { $group: { '_id': 'total', sumtotal: { $sum: '$total' } } })
db.users.aggregate({ $match: { cat: "bb" }}, { $group: { '_id': 'total', sumtotal: { $sum: '$total' } } })
db.users.find()

������� 3.
db.users.updateOne({"name": "a", "cat": "aa", "price": 200, "coll": 200, "total":40000},  {$inc: { coll: -1}})
db.users.updateOne({"name": "b", "cat": "aa", "price": 300, "coll": 150, "total":45000},  {$inc: { coll: -1}})
db.users.updateOne({"name": "c", "cat": "bb", "price": 50, "coll": 100, "total":5000},  {$inc: { coll: -1}})
db.users.updateOne({"name": "d", "cat": "bb", "price": 25, "coll": 100, "total":2500},  {$inc: { coll: -1}})

������� 4.
db.users.find().sort( {total: -1} )
db.users.find({ $and: [{$or: [{ name: 'a'}, { name: 'b' }]}, {coll:1000} ]})
���, ��������,
db.users.find({ total: { $gte : 40000}}) 

CAP
��������������� 
�����������
������������ � ����������

sql CA
nosql CP / AP

������_1 - ����� 
������_1 - ����� - �������������� ������_2 - ��� ��������

hive hadoop

1 psql  100 hadoop