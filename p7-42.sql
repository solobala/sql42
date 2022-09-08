select 111	-- получаем данные по актерам, но выводим 111, что бы понять размер шрифта
from actor a

select 9584/2  --4792

a - b 
b - a

where x = null 


select (random() * 53)::int

select sum(salary)
from (
	select emp_id, max(effective_from)
	from employee_salary 
	group by 1) t 
join employee_salary es on es.emp_id = t.emp_id and t.max = es.effective_from

select p.pos_id
from "position" p
left join employee e on e.pos_id = p.pos_id
where e.emp_id is null
except
select pos_id 
from vacancy v
where closure_date is null


select emp_id, salary, array_agg(grade)
from employee_salary es, grade_salary gs
where es.salary between gs.min_salary and gs.max_salary
group by 1, 2

with cte as (
	select emp_id, max(effective_from)
	from employee_salary 
	group by 1)
select t1.concat_ws, es.salary, pos_title
from cte t 
join (
	select e.emp_id, concat_ws(' ', p.last_name, p.first_name, p.middle_name), p2.pos_title
	from employee e
	join person p on p.person_id = e.person_id
	join "position" p2 on p2.pos_id = e.pos_id) t1 on t1.emp_id = t.emp_id
join employee_salary es on es.emp_id = t.emp_id and t.max = es.effective_from

with recursive r as
(select s.unit_title ,
		array[s.unit_title::text] as tree,
		1 as level,
		s.parent_id ,
		s.unit_id
from structure s where parent_id = 0
--from structure s where unit_id = 6
union 
select 	s.unit_title,
		tree||array[s.unit_title::text],
		level + 1,
		s.parent_id ,
		s.unit_id
from r
--join "structure" s on s.unit_id = r.parent_id 
join "structure" s on r.unit_id = s.parent_id 
)
select * from r;

explain analyze --42000
with t as 
	(select  p.project_id  ,  --  unpack  employees_id 
			 p.employees_id[generate_subscripts(p.employees_id, 1)] as team_member
	from projects p 
	),
t1 as
	(select project_id,			--  team_member  -  >  array
			array_agg(concat_ws(' ',person.last_name , person.first_name ,person.middle_name )) as team
	from t 
	join employee e on t.team_member = e.emp_id 
	join person on person.person_id = e.person_id 
	group by project_id
	) 
select  p.project_id , 
		sum(hours) over (partition by p.project_id),
		hours,
		concat_ws(' ',person.last_name , person.first_name ,person.middle_name ),
		name,
		p.employees_id,
		t1.team as  team_members 
from hours
join projects p using(project_id)
join employee e using (emp_id)
JOIN hr.person  ON person.person_id = e.person_id
join t1 on t1.project_id = p.project_id

explain analyze -- 631
select p.project_id, p."name", array_agg(concat_ws(' ', p2.last_name, p2.first_name, p2.middle_name))
from projects p
join employee e on e.emp_id = any(p.employees_id)
join person p2 on p2.person_id = e.person_id
group by 1, 2

explain analyze --22489
with t as 
	(select  p.project_id  ,  --  unpack  employees_id 
			 p.employees_id[generate_subscripts(p.employees_id, 1)] as team_member
	from projects p 
	),
t1 as
	(select project_id,			--  team_member  -  >  array
			array_agg(concat_ws(' ',person.last_name , person.first_name ,person.middle_name )) as team
	from t 
	join employee e on t.team_member = e.emp_id 
	join person on person.person_id = e.person_id 
	group by project_id
	) 
select t1.*
from t1 