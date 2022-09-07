SET search_path = bookings, public;
--**************************************************************************************************************************************************************
--1. � ����� ������� ������ ������ ���������?
--**************************************************************************************************************************************************************
--������ � ������� airports � ���������� �� �������� city(�����) � ������������ �� ���������� ���������� >1 ( count(airport_code>1)). 
--� ���������� ������� ���������� ������ ����� ������� 
select
	city as "�����" 
from
	airports 
group by
	city
having
	count(airport_code)>1;

--**************************************************************************************************************************************************************
--2. � ����� ���������� ���� �����, ����������� ��������� � ������������ ���������� ��������?
--**************************************************************************************************************************************************************
/* 		
������ ���������� ����� ����������, ���� ��������� � ������� �������� � ������������ ����������, �������� �� ���������� q.
q ������������ ����� ����������� 2 ����������� � ������� flights � ���������� �� ���� ���������.
 
1-� ��������� - ������ ���������� ����� ���������� ������ � ����� ��������� �� IATA (�����, �����������, �����������-��������� �������� �������� aircraft_code ���������� ��� ������ ���������� - 
� ������� aircrafts, � ������� ��������� ����� ���� �������� aircraft_code,���������� �� �������� range � ����� 1-�� ��������)
2-� ��������� -�� ��, �� �� ���������� �������.

��������� q ����������� ������������� ���������  �� ������� airports, ����������� � ����������� q �� ������� ��������� airport_code
*/

--explain analyze		--cost=7341.64..7343.80 actual time=2.845..2.847
select
	a.airport_name
from
	airports a
join
(	select
		f.departure_airport as airport_code,f.aircraft_code
	from
		flights f
	group by
		f.departure_airport,f.aircraft_code
	having
		f.aircraft_code =(
		select
			aircraft_code
		from
			aircrafts ai
		order by
			ai.range desc
		limit 1)
union
	select
		f1.arrival_airport as airport_code,f1.aircraft_code
	from
		flights f1
	group by
		f1.arrival_airport,f1.aircraft_code
	having
		f1.aircraft_code =(
		select
			aircraft_code
		from
			aircrafts ai
		order by
			ai.range desc
		limit 1))q
		using(airport_code)
order by
	a.airport_name;


--**************************************************************************************************************************************************************
--3. ������� 10 ������ � ������������ �������� �������� ������
--**************************************************************************************************************************************************************
-- ������ � ������� flights
-- ����� �������� - �������� ����� ����������� � ����������� ��������� ������
select
	flight_no as "����",
	actual_departure - scheduled_departure as "����� ��������"
from
	flights
where
	actual_departure >scheduled_departure --����� ������ �� ������, ��� ������� ���� �������� ������
	order by
	"����� ��������" desc  -- ������������� �� ��������
limit 10; -- � ����� 10 ������ �������

--**************************************************************************************************************************************************************
--4.���� �� �����, �� ������� �� ���� �������� ���������� ������?
--**************************************************************************************************************************************************************
--C����� ������� ������������, �� ������� �� �������� ���������� ������. 
/*
� ������� ���������� 3 ������� - tickets, boarding_passes � ticket_flights.

������� cte tickets_wo_bp �� ���� �������  ticket_flights � boarding_passes, ���������� ������������� ���������� left join,
����� � ��������� ������ ��� ������ �� ������� ticket_flights.

����� ������ �� ticket_no � flight_id ��������� ������� ������ ������� �� ���������� ���������� -  
����������� ������ � ������� ���������� ������� (boarding_passes), ��������������� ������� � ticket_flights: bp.boarding_no is null

�� ������� ������� (tickets) ��������� ���������� ������ ������������,
�������� �� � ����� cte tickets_wo_bp �� ������� ��������� ������� ������� t.ticket_no = tickets_wo_bp.ticket_no
*/
--explain analyze  --(cost=344773.44..344773.45  (actual time=8481.250..9176.708
with tickets_wo_bp as (
	select
	tf.ticket_no, tf.flight_id 
from
	ticket_flights tf
left join boarding_passes bp on
	tf.ticket_no = bp.ticket_no
	and tf.flight_id = bp.flight_id
where
	bp.boarding_no is null)
select
	distinct t.book_ref as "������������ ��� �������"
from
	tickets t
join 
tickets_wo_bp
on
	t.ticket_no = tickets_wo_bp.ticket_no;


--**************************************************************************************************************************************************************
--5. ������� ���������� ��������� ���� ��� ������� �����, �� % ��������� � ������ ���������� ���� � ��������.
--   �������� ������� � ������������� ������ - ��������� ���������� ���������� ���������� ���������� �� ������� ��������� �� ������ ����. 
--�.�. � ���� ������� ������ ���������� ������������� ����� - ������� ������� ��� �������� �� ������� ��������� �� ���� ��� ����� ������ ������ � ������� ���
--**************************************************************************************************************************************************************
/*� ������� ������������ 4 ������� - seats, boarding_passes, flights � airports(����� ������� �������� ���������) �
2 ����� ��������� ��������� - cte � cte2.

cte - ���������� ������� seats � �������  ����� ���-�� ���� �� ����� � ����������� �� ���� �������� �� IATA(s.aircraft_code) � ������� ������������ �-�� count(s.seat_no) 

cte2 - ���������� ���������� ������ ���������� ������� (boarding_passes) � ��������� (flights)  
�� ������� ��������� flight_id � ��������������� �������, ��� ������ ���� ������� (f.actual_departure is not null),
� ����������� ������������ �� flight_id. 
cte2 ������� ���-�� ���������� �� ����� = ���������� �������� ���������� ������� �� ������ � ������� ������������ �-�� count(bp.seat_no) 
� ����������� ������ ���-�� ���������� � ������ ���� �� ���������� �� ������� ��������� ������ � ������� ������������ ������� �-�� sum over():
sum(count(bp.seat_no)) over (partition by f.departure_airport, 	f.actual_departure::date order by f.actual_departure).
����� ������� ������� ��������� ����������������� �� ��������� ������ � ���� ������, ����������� � ���� date, � ���������� �� ���� ������.

� �������� ������� ������� ��������� ���������� ����� cte �� ������� ��������� ���� �������� �� IATA.
���-�� ��������� ���� ������������ ��� �������� ����� ����� ���-��� ���� �� ����� � ���-��� �������� ���������� ������� �� ���� ���� (cte.qty - cte2.qtp)
% ��������� ���� ��������� � ������� �-�� Round(), �� ������� �������� ������� � �������� � ���� Numeric.

��������� ���������� cte � cte2 ��������� ������� �� ������� airports (����� ������ �������� ���������), 
�������� ���������� �� ������� ��������� ����� ��������� cte2.departure_airport = a.airport_code

��������� ��������� �� �������� ���������, ���� � ������ �����
*/

--explain analyze --cost=538892.46..538904.08 actual time=2666.122..2737.640
with cte as (
select
	s.aircraft_code,
	count(s.seat_no) as qty --����� ���-�� ��� �� ����� � ����������� �� ������ �������� 
from
	seats s
group by
	s.aircraft_code),
cte2 as (
select
	f.flight_id,
	f.flight_no,
	f.aircraft_code, 
	f.actual_departure::date as actual_departure,
	f.departure_airport,
	count(bp.seat_no) as qtp, -- ���-�� ���������� �� ����� = ���������� ���������� ������� �� ������
	sum(count(bp.seat_no)) over (partition by f.departure_airport, 	f.actual_departure::date order by f.actual_departure) as total -- ����������� ������ ���-�� ���������� � ������ ���� �� ���������� �� ������� ��������� ������
from
	boarding_passes bp
inner join flights f on
	bp.flight_id = f.flight_id
	and f.actual_departure is not null 	--������ ���� �������
group by
	f.flight_id)
select
	a.airport_name as "�������� ������",
	cte2.flight_id as "����",
	cte2.actual_departure as "���� ������" ,
	cte.qty as "����� ����",
	(cte.qty - cte2.qtp) as "� �.�.c��������",
	round((((cte.qty - cte2.qtp)::numeric / cte.qty)::numeric) * 100., 0) as "% ��������� ����",
	cte2.qtp as "�-�� ����������",
	cte2.total as "� ������ ��� " 	
from
	cte2
inner join cte on
	cte.aircraft_code = cte2.aircraft_code
inner join airports a on
	cte2.departure_airport = a.airport_code
order by
	a.airport_name,
	cte2.actual_departure,
	cte2.flight_id ;


--**************************************************************************************************************************************************************
--6.������� ���������� ����������� ��������� �� ����� ��������� �� ������ ����������.
--**************************************************************************************************************************************************************
/*� ������� ������������ 2 ������� flights � aircrafts, 
������� ����������� ����������� inner join �� ������� ��������� aircraft_code (���� �������� �� IATA) 
� ����������� ������������ �� aircraft_code.

���������� ��������� �� ����� ��������� �������������� � ������� ������������ �-�� Count()
���������� ����������� ��������� ������� ����� ���������� (���������� ������� �� ����� �-�� ��������� � ��������� �� 100.%) � ������� �-�� round()
������� � �������� �������� � ���� Numeric
*/

--������� 1 ����� �-�� ��������� �� ���� ��������� �������  ����� ���������(�����) 
--explain analyze --cost=11213.38..11214.64 actual time=129.900..133.409
select
	ai.aircraft_code as "��� �������� �� IATA",
	round(count(f.flight_id)* 100. /(select count(flight_id)::numeric as total_qty from flights), 1) as "% �� ���-�� ���������"
from
	flights f
inner join aircrafts ai
		using(aircraft_code)
group by
	ai.aircraft_code;

--������� 2 ����� �-�� ��������� �� ���� ��������� ����� ������������ ������� ������� Sum() over()
--explain analyze --cost=6009.35..6010.74 actual time=74.257..79.007- ������� � ����� ��������������
select
	ai.aircraft_code as "��� �������� �� IATA",
	round(count(f.flight_id)* 100. / sum(count(f.flight_id)::numeric) over(), 1) as "% �� ���-�� ���������"
from
	flights f
inner join aircrafts ai
		using(aircraft_code)
group by
	ai.aircraft_code;

--**************************************************************************************************************************************************************
--7. ���� �� ������, � ������� �����  ��������� ������ - ������� �������, ��� ������-������� � ������ ��������? 
--**************************************************************************************************************************************************************
/*������ ������� ������, ���������,�������� � ����� � ����������� ������-������ ��� ������-������� � ������������ ������ ��������, � ����� ���. ������-����� � ����. ������-����� �� ������ .
������ ���������� 3 ������� - flights, ticket_flights � airoports (������ ����������� �������� �������) � 
2 cte: rf - �� ���� flights,        b_es - �� ���� flights � ticket_flights, ����������� �� ������� ��������� flight_id.

rf ��������� ������ ����� ����������  ������ � �������, ��������������� ������� ��������� � ������� ������
b_es ��������� ������ ������� ���������, ������ ���� ������ ��������, ������� ����. �� ����� ��� �������� ������-������� � ���. �� ����� ��� �������� ������-������� ��� ��������,
��������������� �������  ���������� ��������� ������-������ ��� ������-�������.

�������� ������� ��� b_ef- ��������� ��������� q, � ������� ���������� ����������� ���. � ����. ������ � ������ -������� �� ������  �� ����������
���������� ������ ticket_flights � flights  �� ������� ��������� flight_id . 
����� ���. � ����. ������� ����������� � ������������� ���.������� filter(where tf.fare_conditions = 'Business') � filter(where tf.fare_conditions = 'Economy'), 
���������� ������ ������������ �� ������ �������� � ������ �����.

� ��������������� ������� ����������� �����������  having max(tf.amount)filter(where tf.fare_conditions = 'Economy')>min(tf.amount)filter(where tf.fare_conditions = 'Business')
����� � ������� array_agg() ����������� ��������� ���� ���������� ������ ��� ������� ��������, ���� ����������� ������ ������� � ������������ ������-������� �� ���������� ������, 

� �������� ������� ��������� ������ ������ � �������, ���������, ����� ��������, ���������� ����� �� ��������, 
������ ����������� ������-�������  � ������ ������������ ������-������� ������� ����������� ����� ��������.

�������� ������� ��������� ������� - ��������� ��������� q (������������ ������� �� ��������� ������ � ������ ��������), �������������� ����� 
���������� rf � b_es �� ������� ��������� ������ ��������. 

����� ��������� ����������� �������� �������-������ �� ������� airports,
������ �������������� �� �������� ��������� rf.departure_airport = a1.airport_code � rf.arrival_airport = a2.airport_code

� �������� ������ � �������, ��������� � ���������� ��������� �������, ����������� �-� array_to_string(), ����� ������� ��������� ����� ����������� (',')
*/
--explain analyze --cost=883944.38..884089.63 actual time=3432.988..3433.053 
with rf as (
select
	f.departure_airport ,
	f.arrival_airport,
	f.flight_no,
	f.flight_id 
from
	flights f
group by
	f.flight_id
),
b_es as(--��� � �������, ������, ����. ����� �������� ������-������� � ���. ����� �������� ������-�������. 
	select
		q.flight_no,
		array_to_string(array_agg(q.flight_id),',',' ') as all_flights_in_route,-- ��� ����� ��������
		array_to_string(array_agg(q.business_amount),',',' ') as all_min_business_amounts,--������ ����������� ������-������� �� ������ ������ ��������
		array_to_string(array_agg(q.economy_amount),',',' ') as all_max_economy_amounts--������ ������������ ������-������� �� ������ ������ ��������
	from
		(
		select
			f.flight_no,
			f.flight_id,
			min(tf.amount) filter(where tf.fare_conditions = 'Business') as business_amount,--����������� ������-����� �����
			max(tf.amount) filter(where tf.fare_conditions = 'Economy') as economy_amount-- ������������ ������ ����� �� ���� ����
		from
			ticket_flights tf
		join flights f
				using(flight_id)
		group by
			f.flight_no,
			f.flight_id 
			having min(tf.amount) filter(where tf.fare_conditions = 'Business') <max(tf.amount) filter(where tf.fare_conditions = 'Economy')
			)q
	group by
		q.flight_no	
	)
	select
			a1.city as "������",
			a2.city as "����",
			concat (q.departure_airport,' - ',	q.arrival_airport) as "���������",
			q.all_flights_in_route as "����� �� ��������",
			q.my_route as "ID ��������",
			q.all_min_business_amounts as "������-������ ������",
			q.all_max_economy_amounts as "������-������ ������"
	from
	(
	select  distinct 
			rf.departure_airport,
			rf.arrival_airport,
			b_es.all_flights_in_route,
			b_es.flight_no as my_route,
			b_es.all_min_business_amounts,
			b_es.all_max_economy_amounts
	from
			rf
	join b_es on
			b_es.flight_no = rf.flight_no
		)q
inner join airports a1 on
	q.departure_airport = a1.airport_code
inner join airports a2 on
	q.arrival_airport = a2.airport_code
order by
	a2.city;

--**************************************************************************************************************************************************************
--8. ����� ������ �������� ��� ������ ������?
--**************************************************************************************************************************************************************
/*���������� 2 ������� - flights � airports
������ ������ �� ���� 2 cte - 
		  cities - ������ ���������� ��� ������� ������� � ������ �� ������ �
		  all_cities - ��� ��������� ��������� ������� ������� � ������ ( ���������� ������� a1.city>a2.city ����� �������� ���������� ���).
� �������� ��������� ������ 1 cte �� 2 cte � ������� EXCEPT.
����������� ������ � �������� ������������� �� �������
*/
create view flights_a_d as ( 
with cities as (-- ������ ���������� ������� ������� � ������ �� ������
select
		f.flight_id,
		f.arrival_airport,
		a1.city as city_arrival,
		f.departure_airport ,
		a2.city as city_departed
from
		flights f
inner join airports a1
on
		f.arrival_airport = a1.airport_code
inner join airports a2
on
		f.departure_airport = a2.airport_code
		group by f.flight_id,a1.city,a2.city ),
	all_cities as (--��� ��������� ��������� ������� ������� � ������	
select
		a1.city as "����� ������",
		a2.city as "����� �������"
from
		airports a1,
		airports a2
where
		a1.city>a2.city
order by
		a1.city,
		a2.city)
select
	*
from
	all_cities
except
---- �������� ���������� ������������ ��������� ������� ������� � ������ �� ���� ��������� ���������
select
	cities.city_arrival,
	cities.city_departed
from
		cities
order by
	"����� ������",
	"����� �������"
	);

--**************************************************************************************************************************************************************
--9. ��������� ���������� ����� �����������, ���������� ������� �������, �������� � ���������� ������������ ���������� ���������  � ���������, ������������� ��� ����� *
--**************************************************************************************************************************************************************
/*� ������� ������������ �������:flights,aircrafts,airports  � 1 cte.

cte ������������ ��� ������������ ������ ��� ���������� ������� � ������ �� ������ ��� ���������� ��� 
� �������� �������  cte ����������� � aircrafts �� ������� ���������  aircraft_code ��� ��������� �������� ������� ��������� � �� ������������ ���������,
������ � �������� airports ��� ��������� �������� � ��������� ���������� �������-������.

��� �������� ���������� ������������ �-�� sind � cosd, ������� �������� � ���������, ������� ������ � ������� ��������������� �� ����. �������� acos - � ��������,
������� ������������ acos, � �� acosd.

��������� ������������ Radians() � ������� sin � cos, ����� ���������� ������� � ���������� �������� ���, ���� ���������, ��� sind, cosd � ������� ������
*/
--explain analyze --cost=6369.20..6369.84 actual time=100.228..100.237 
with cte as (-- ������ ��� ���������� ������� � ������ �� ������ ��� ���������� ���
select distinct
		f.departure_airport ,
		f.arrival_airport, 
		f.aircraft_code 		
from
		flights f
		where f.departure_airport>f.arrival_airport )	
select 
a1.airport_name as "�������� ������",
a2.airport_name as "�������� �������",
ai.model as "��� ��������",
round((acos(sind(a1.latitude)* sind(a2.latitude) + cosd(a1.latitude)* cosd(a2.latitude)* cosd(a1.longitude - a2.longitude))* 6371.)::numeric, 0) as "����������",
ai."range" as "����. ���������",
case
	when round((acos(sind(a1.latitude)* sind(a2.latitude) + cosd(a1.latitude)* cosd(a2.latitude)* cosd(a1.longitude - a2.longitude))* 6371.)::numeric, 0) <= ai."range" then '����.��������� �� ���������'
	else '����. ��������� ���������'
end as "�����������"
from cte
inner join aircrafts ai using(aircraft_code)
inner join airports a1 on cte.departure_airport=a1.airport_code 
inner join airports a2 on cte.arrival_airport=a2.airport_code 
order by a1.airport_name;


