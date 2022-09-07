SET search_path = bookings, public;
--**************************************************************************************************************************************************************
--1. В каких городах больше одного аэропорта?
--**************************************************************************************************************************************************************
--запрос к таблице airports с агрегацией по атрибуту city(Город) и постусловием на количество аэропортов >1 ( count(airport_code>1)). 
--В результате выводим уникальный список таких городов 
select
	city as "Город" 
from
	airports 
group by
	city
having
	count(airport_code)>1;

--**************************************************************************************************************************************************************
--2. В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?
--**************************************************************************************************************************************************************
/* 		
Список уникальных кодов аэропортов, куда прилетают и улетают самолеты с максимальной дальностью, получаем из подзапроса q.
q представляет собой объединение 2 подзапросов к таблице flights с агрегацией по коду аэропорта.
 
1-й подзапрос - список уникальных кодов аэропортов вылета и кодов самолетов по IATA (отбор, группировка, постусловие-сравнение значения атрибута aircraft_code результату еще одного подзапроса - 
к таблице aircrafts, в котором проиходит отбор всех значений aircraft_code,сортировка по убыванию range и отбор 1-го значения)
2-й подзапрос -то же, но по аэропортам прилета.

Подзапрос q обогащается наименованием аэропорта  из таблицы airports, соединенной с подзапросом q по условию равенства airport_code
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
--3. Вывести 10 рейсов с максимальным временем задержки вылета
--**************************************************************************************************************************************************************
-- запрос к таблице flights
-- время задержки - разность между фактическим и планируемым временами вылета
select
	flight_no as "Рейс",
	actual_departure - scheduled_departure as "Время задержки"
from
	flights
where
	actual_departure >scheduled_departure --берем только те записи, где реально была задержка вылета
	order by
	"Время задержки" desc  -- упорядочиваем по убыванию
limit 10; -- и берем 10 первых записей

--**************************************************************************************************************************************************************
--4.Были ли брони, по которым не были получены посадочные талоны?
--**************************************************************************************************************************************************************
--Cписок номеров бронирований, по которым не получены посадочные талоны. 
/*
в запросе используем 3 таблицы - tickets, boarding_passes и ticket_flights.

создаем cte tickets_wo_bp на базе таблицы  ticket_flights и boarding_passes, используем левостороннее соединение left join,
чтобы в результат попали все записи из таблицы ticket_flights.

связь таблиц по ticket_no и flight_id указываем условие отбора записей из результата соединения -  
отсутствуют записи в таблице посадочных талонов (boarding_passes), соответствующие записям в ticket_flights: bp.boarding_no is null

из таблицы билетов (tickets) формируем уникальный список бронирований,
соединяя ее с нашим cte tickets_wo_bp по условию равенства номеров билетов t.ticket_no = tickets_wo_bp.ticket_no
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
	distinct t.book_ref as "Бронирования без талонов"
from
	tickets t
join 
tickets_wo_bp
on
	t.ticket_no = tickets_wo_bp.ticket_no;


--**************************************************************************************************************************************************************
--5. Найдите количество свободных мест для каждого рейса, их % отношение к общему количеству мест в самолете.
--   Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. 
--Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах в течении дня
--**************************************************************************************************************************************************************
/*в запросе используются 4 таблицы - seats, boarding_passes, flights и airports(чтобы вывести название аэропорта) и
2 общих табличных выражения - cte и cte2.

cte - использует таблицу seats и считает  общее кол-во мест на рейсе в зависимости от кода самолета по IATA(s.aircraft_code) с помощью агрегирующей ф-ии count(s.seat_no) 

cte2 - использует соединение таблиц посадочных талонов (boarding_passes) и перелетов (flights)  
по условию равенства flight_id и дополнительного условия, что данный рейс вылетел (f.actual_departure is not null),
с последующей группировкой по flight_id. 
cte2 считает кол-во пассажиров на рейсе = количеству выданных посадочных талонов по рейсам с помощью агрегирующей ф-ии count(bp.seat_no) 
и нарастающим итогом кол-во пассажиров в данную дату по вылетевшим из данного аэропорта рейсам с помощью агрегирующей оконной ф-ии sum over():
sum(count(bp.seat_no)) over (partition by f.departure_airport, 	f.actual_departure::date order by f.actual_departure).
внури оконной функции выполняем партиционирование по аэропорту вылета и дате вылета, приведенной к типу date, и сортировку по дате вылета.

В основном запросе выводим результат соединения обоих cte по условию равенства кода самолета по IATA.
Кол-во свободных мест рассчитываем как разность между общим кол-вом мест на рейсе и кол-вом выданных посадочных талонов на этот рейс (cte.qty - cte2.qtp)
% свободных мест округляем с помощью ф-ии Round(), не забывая привести делимое и делитель к типу Numeric.

Результат соединения cte и cte2 обогащаем данными из таблицы airports (берем оттуда название аэропорта), 
выполняя соединение по условию равенства кодов аэропорта cte2.departure_airport = a.airport_code

Результат сортируем по названию аэропорта, дате и номеру рейса
*/

--explain analyze --cost=538892.46..538904.08 actual time=2666.122..2737.640
with cte as (
select
	s.aircraft_code,
	count(s.seat_no) as qty --общее кол-во мес на рейсе в зависимости от модели самолета 
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
	count(bp.seat_no) as qtp, -- кол-во пассажиров на рейсе = количеству посадочных талонов по рейсам
	sum(count(bp.seat_no)) over (partition by f.departure_airport, 	f.actual_departure::date order by f.actual_departure) as total -- нарастающим итогом кол-во пассажиров в данную дату по вылетевшим из данного аэропорта рейсам
from
	boarding_passes bp
inner join flights f on
	bp.flight_id = f.flight_id
	and f.actual_departure is not null 	--данный рейс вылетел
group by
	f.flight_id)
select
	a.airport_name as "Аэропорт вылета",
	cte2.flight_id as "Рейс",
	cte2.actual_departure as "дата вылета" ,
	cte.qty as "Всего мест",
	(cte.qty - cte2.qtp) as "в т.ч.cвободных",
	round((((cte.qty - cte2.qtp)::numeric / cte.qty)::numeric) * 100., 0) as "% свободных мест",
	cte2.qtp as "К-во пассажиров",
	cte2.total as "с начала дня " 	
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
--6.Найдите процентное соотношение перелетов по типам самолетов от общего количества.
--**************************************************************************************************************************************************************
/*в запросе используются 2 таблицы flights и aircrafts, 
которые соединяются посредством inner join по условию равенства aircraft_code (кода самолета по IATA) 
с последующей группировкой по aircraft_code.

Количество перелетов по типам самолетов рассчитывается с помощью агрегирующей ф-ии Count()
Процентное соотношение перелетов находим путем округления (результата деления на общее к-во перелетов и умнежения на 100.%) с помощью ф-ии round()
Делимое и делитель приводим к типу Numeric
*/

--ВАРИАНТ 1 общее к-во перелетов по всем самолетам находим  через подзапрос(проще) 
--explain analyze --cost=11213.38..11214.64 actual time=129.900..133.409
select
	ai.aircraft_code as "Код самолета по IATA",
	round(count(f.flight_id)* 100. /(select count(flight_id)::numeric as total_qty from flights), 1) as "% от кол-ва перелетов"
from
	flights f
inner join aircrafts ai
		using(aircraft_code)
group by
	ai.aircraft_code;

--ВАРИАНТ 2 общее к-во перелетов по всем самолетам через агрегирующую оконную функцию Sum() over()
--explain analyze --cost=6009.35..6010.74 actual time=74.257..79.007- быстрее и менее энергозатратно
select
	ai.aircraft_code as "Код самолета по IATA",
	round(count(f.flight_id)* 100. / sum(count(f.flight_id)::numeric) over(), 1) as "% от кол-ва перелетов"
from
	flights f
inner join aircrafts ai
		using(aircraft_code)
group by
	ai.aircraft_code;

--**************************************************************************************************************************************************************
--7. Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета? 
--**************************************************************************************************************************************************************
/*Запрос выводит города, аэропорты,маршруты и рейсы с превышением эконом-тарифа над бизнес-тарифом с группировкой внутри маршрута, а также мин. бизнес-тариф и макс. эконом-тариф по рейсам .
запрос использует 3 таблицы - flights, ticket_flights и airoports (откуда извлекаются названия городов) и 
2 cte: rf - На базе flights,        b_es - На базе flights и ticket_flights, соединенных по условию равенства flight_id.

rf формирует список кодов аэропортов  вылета и прилета, соответствующих номеров маршрутов и номеров рейсов
b_es формирует список номеров маршрутов, массив всех рейсов маршрута, массивы макс. по рейсу цен перелета эконом-классом и мин. по рейсу цен перелета бизнес-классом для маршрута,
удовлетворяющих условию  превышения стоимости эконом-тарифа над бизнес-тарифом.

Источник записей для b_ef- вложенный подзапрос q, в котором происходит определение мин. и макс. бизнес и эконом -тарифов по рейсам  из результата
соединения таблиц ticket_flights и flights  по условию равенства flight_id . 
Поиск мин. и макс. тарифов выполняется с использованем доп.условий filter(where tf.fare_conditions = 'Business') и filter(where tf.fare_conditions = 'Economy'), 
отобранные записи группируются по номеру маршрута и номеру рейса.

К сгруппированным записям применяется постусловие  having max(tf.amount)filter(where tf.fare_conditions = 'Economy')>min(tf.amount)filter(where tf.fare_conditions = 'Business')
Далее с помощью array_agg() выполняется агрегация всех отобранных рейсов для данного маршрута, всех минимальных бизнес тарифов и максимальных эконом-тарифов по отобранным рейсам, 

В основном запросе выводятся города вылета и прилета, аэропорты, номер маршрута, отобранные рейсы на маршруте, 
массив минимальных бизнес-тарифов  и массив максимальных эконом-тарифов каждого отобранного рейса маршрута.

Источник записей основного запроса - вложенный подзапрос q (совокупность записей по отдельным рейсам в рамках маршрута), представляющий собой 
соединение rf и b_es по условию равенства номера маршрута. 

Далее подзапрос обогащается городами прилета-вылета из таблицы airports,
дважды присоединенной по условиям равенства rf.departure_airport = a1.airport_code и rf.arrival_airport = a2.airport_code

К массивам рейсов и тарифов, выводимым в результате основного запроса, применяется ф-я array_to_string(), чтобы вывести результат через разделитель (',')
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
b_es as(--сте с рейсами, ценами, макс. ценой перелета эконом-классом и мин. ценой перелета бизнес-классом. 
	select
		q.flight_no,
		array_to_string(array_agg(q.flight_id),',',' ') as all_flights_in_route,-- все рейсы маршрута
		array_to_string(array_agg(q.business_amount),',',' ') as all_min_business_amounts,--массив минимальных бизнес-тарифов по рейсам внутри маршрута
		array_to_string(array_agg(q.economy_amount),',',' ') as all_max_economy_amounts--массив максимальных эконом-тарифов по рейсам внутри маршрута
	from
		(
		select
			f.flight_no,
			f.flight_id,
			min(tf.amount) filter(where tf.fare_conditions = 'Business') as business_amount,--минимальный бизнес-тариф рейса
			max(tf.amount) filter(where tf.fare_conditions = 'Economy') as economy_amount-- максимальный эконом тариф на этот рейс
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
			a1.city as "Откуда",
			a2.city as "Куда",
			concat (q.departure_airport,' - ',	q.arrival_airport) as "Аэропорты",
			q.all_flights_in_route as "Рейсы на маршруте",
			q.my_route as "ID маршрута",
			q.all_min_business_amounts as "бизнес-тарифы рейсов",
			q.all_max_economy_amounts as "эконом-тарифы рейсов"
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
--8. Между какими городами нет прямых рейсов?
--**************************************************************************************************************************************************************
/*Используем 2 таблицы - flights и airports
строим запрос на базе 2 cte - 
		  cities - список уникальных пар городов прилета и вылета по рейсам и
		  all_cities - все возможные сочетания городов прилета и вылета ( используем условие a1.city>a2.city чтобы избежать зеркальных пар).
и вычитаем результат работы 1 cte из 2 cte с помощью EXCEPT.
оборачиваем запрос в создание представления по заданию
*/
create view flights_a_d as ( 
with cities as (-- список уникальных городов прилета и вылета по рейсам
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
	all_cities as (--все возможные сочетания городов прилета и вылета	
select
		a1.city as "Город вылета",
		a2.city as "Город прилета"
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
---- вычитаем фактически существующие сочетания городов прилета и вылета из всех возможных сочетаний
select
	cities.city_arrival,
	cities.city_departed
from
		cities
order by
	"Город вылета",
	"Город прилета"
	);

--**************************************************************************************************************************************************************
--9. Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы *
--**************************************************************************************************************************************************************
/*В запросе используются таблицы:flights,aircrafts,airports  и 1 cte.

cte используется для формирования списка пар аэропортов прилета и вылета по рейсам без зеркальных пар 
В основном запросе  cte соединяется с aircrafts по условию равенства  aircraft_code для получения названия моделей самолетов и их максимальной дальности,
дважды с таблицей airports для получения названий и координат аэропортов прилета-вылета.

Для подсчета расстояния используются ф-ии sind и cosd, которые работают с градусами, поэтому широту и долготу преобразовывать не надо. Аргумент acos - В радианах,
поэтому используется acos, а не acosd.

Пробовала использовать Radians() и обычные sin и cos, после округления разницы с предыдущим расчетом нет, хотя считается, что sind, cosd и градусы точнее
*/
--explain analyze --cost=6369.20..6369.84 actual time=100.228..100.237 
with cte as (-- список пар аэропортов прилета и вылета по рейсам без зеркальных пар
select distinct
		f.departure_airport ,
		f.arrival_airport, 
		f.aircraft_code 		
from
		flights f
		where f.departure_airport>f.arrival_airport )	
select 
a1.airport_name as "Аэропорт вылета",
a2.airport_name as "Аэропорт прилета",
ai.model as "Тип самолета",
round((acos(sind(a1.latitude)* sind(a2.latitude) + cosd(a1.latitude)* cosd(a2.latitude)* cosd(a1.longitude - a2.longitude))* 6371.)::numeric, 0) as "Расстояние",
ai."range" as "Макс. дальность",
case
	when round((acos(sind(a1.latitude)* sind(a2.latitude) + cosd(a1.latitude)* cosd(a2.latitude)* cosd(a1.longitude - a2.longitude))* 6371.)::numeric, 0) <= ai."range" then 'макс.дальность не превышена'
	else 'макс. дальность превышена'
end as "Пригодность"
from cte
inner join aircrafts ai using(aircraft_code)
inner join airports a1 on cte.departure_airport=a1.airport_code 
inner join airports a2 on cte.arrival_airport=a2.airport_code 
order by a1.airport_name;


