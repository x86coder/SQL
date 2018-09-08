-- Oracle SQL Grouping excercises.
-- Author: Jaime A. Reyes.
--   Date: March, 2017.

-- 1) Design a query that returns all employees whose rate is the
-- lowest in his/her department. Add a column that shows the difference
-- between that employee and the next whose rate is the lowest posible
-- but higher than the former.

select
  *
from (
  select
   departamento,
   empleado,
   hour_rate,
   minimo,
   diferencia,
   row_number() over (partition by departamento order by hour_rate asc) num_particion
   from
    (
    select
        departamento,
        ae2.emp_name as empleado,
        ae2.hour_rate,
        minimo,
        (lead(hour_rate,1) over (partition by ae2.dept_id order by hour_rate asc) - minimo) diferencia
    from (
       select
            d.dept_id depid,
        d.dept_name departamento,
            min(hour_rate) minimo
        from TBL_emp ae
        join TBL_dept d on d.dept_id = ae.dept_id
        group by d.dept_id, d.dept_name
        )
    join TBL_emp ae2 on ae2.dept_id = depid
    --group by departamento, ae2.emp_id, ae2.emp_name, ae2.hour_rate, minimo
    order by departamento, hour_rate
    )
  )
  where num_particion < 2 or (hour_rate != minimo);

-- 2) Count the number of tasks for each project.
-- And for each of these tasks, show the task whose priority is the highest.
-- If there exist more than 2 tasks with equal priority, show these tasks
-- in a comma-separated list, in a single column (cell).

select
identificador,
proyecto,
listagg(case when maximos>0 then (case maximo2 when t3.task_priority then t3.description else null end) else null end, ', ') within group (order by t3.task_priority) tareas_max_prioridad
from (select
	  identificador,
	  proyecto,
	  sum(case t2.task_priority when maximo then 1 else 0 end) maximos,
	  min(t2.task_priority) maximo2
	  from ( select
		  p.project_id identificador,
		  p.project_name proyecto,
		  min(t.task_priority) maximo
		  from TBL_project p
		join TBL_task t on p.project_id = t.project_id
		group by p.project_id,p.project_name)
	join TBL_task t2 on t2.project_id = identificador
	group by proyecto,identificador)
join TBL_task t3 on t3.project_id = identificador
group by identificador, proyecto;

-- 3) Design a query that fetchs all the tasks from TBL_TASK.
-- Add a row that shows if the task in ith row is one the tasks with the
-- highest priority in its project.
-- The shown value will be "YES" if it is, or else "NO".

select
	t2.description,
	(case t2.task_priority when max_prioridad then 'YES' else 'NO' end) alta_prioridad
from (
	select
		p.project_id proyecto,
		min(t.task_priority) max_prioridad
	from TBL_task t
	join TBL_project p on p.project_id = t.project_id
	group by p.project_id
)
join TBL_task t2 on t2.project_id = proyecto;
