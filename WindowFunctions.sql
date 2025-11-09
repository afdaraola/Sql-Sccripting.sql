-- Drop if existing
DROP TABLE employees PURGE;

CREATE TABLE employees (
    emp_id        NUMBER PRIMARY KEY,
    emp_name      VARCHAR2(50),
    department    VARCHAR2(30),
    hire_date     DATE,
    salary        NUMBER(10,2),
    manager_id    NUMBER
);

INSERT INTO employees VALUES (1, 'Alice', 'Finance', DATE '2015-06-12', 92000, NULL);
INSERT INTO employees VALUES (2, 'Bob', 'Finance', DATE '2017-03-22', 70000, 1);
INSERT INTO employees VALUES (3, 'Carol', 'Finance', DATE '2020-01-19', 65000, 1);

INSERT INTO employees VALUES (4, 'David', 'IT', DATE '2012-11-05', 110000, NULL);
INSERT INTO employees VALUES (5, 'Eve', 'IT', DATE '2016-07-17', 95000, 4);
INSERT INTO employees VALUES (6, 'Frank', 'IT', DATE '2021-04-30', 88000, 4);
INSERT INTO employees VALUES (7, 'Grace', 'IT', DATE '2019-09-21', 90000, 4);

INSERT INTO employees VALUES (8, 'Henry', 'HR', DATE '2018-02-10', 75000, NULL);
INSERT INTO employees VALUES (9, 'Ivy', 'HR', DATE '2021-10-05', 69000, 8);
INSERT INTO employees VALUES (10, 'Jack', 'HR', DATE '2022-05-20', 71000, 8);

COMMIT;

-- Query using RANK() to rank employees by salary within their departments
select e.department,
       e.emp_name,
       e.salary,
       rank()
       over(partition by e.department
            order by e.salary desc
       ) rn
  from employees e;

-- Query using ROW_NUMBER() to assign a unique sequential integer to employees ordered by hire date
  select emp_id,
       emp_name,
       HIRE_DATE, 
       row_number()
       over(
           order by hire_date  
       ) rn
  from employees e;


-- Query using SUM() as a window function to calculate running total of salaries within each department

select e.emp_name,
       e.department,
       e.salary,
       sum(salary)
       over(partition by e.department
            order by e.HIRE_DATE asc
       ) running_toal
  from employees e;

-- Query using AVG() to calculate average salary per department and difference from average salary

select e.department,
       e.emp_name,
       e.hire_date,
       e.salary,
       round(avg(SALARY)
       over(partition by e.department
            order by department asc
       ),2) avg_salary_per_dept,
       round(SALARY - avg(SALARY)
                    over(partition by e.department
                         order by department
                    ),2) diff_from_avg
  from employees e;

-- Query using LAG() to compare each employee's salary with the previous employee's salary in the same department ordered by hire date

select e.department,
       e.emp_name,
       e.hire_date,
       e.salary,
       lag(e.salary, 1) OVER(
           PARTITION BY e.department
           ORDER BY e.hire_date
       ) AS previous_salary,
       e.SALARY - lag(e.salary, 1) OVER(
           PARTITION BY e.department
           ORDER BY e.hire_date
       ) AS salary_change
  from employees e;

-- Query to find the highest paid employee in each department using RANK()

select *
  from (
   select department,
          salary,
          rank()
          over(partition by department
               order by salary desc
          ) rnk
     from employees e
)
 where rnk = 1;


-- Query to get the highest salary in each department using FIRST_VALUE()
select e.*,
       first_value(salary)
       over(partition by department
            order by salary desc
       ) rnk
  from employees e;


-- Query to get the second highest salary in each department using NTH_VALUE()
select e.*,
       nth_value(salary,
                 2)
       over(partition by department
            order by salary desc
       ) second_highest_salary
  from employees e;



-- Query to calculate running average salary ordered by hire date
select emp_name,
       hire_date,
       salary,
       avg(salary)
       over(
           order by hire_date
          rows between unbounded preceding and current row
       ) as running_avg
  from employees;

-- Query to calculate cumulative salary per department ordered by hire date

select emp_name,
       department,
       hire_date,
       salary,
       sum(salary)
       over(partition by department
            order by hire_date
            rows between unbounded preceding and current row
       ) as cumulative_salary
  from employees;

-- Query to get top 3 highest paid employees in each department using RANK()

select * from (
  SELECT emp_name,
         department,
         hire_date,
         salary, rank() over (PARTITION BY department ORDER BY HIRE_DATE DESC) AS salary_rank
    FROM employees
) WHERE salary_rank <= 3;

-- Query to calculate PERCENT_RANK() of employees' salaries within their departments

select emp_name,
       department,
       hire_date,
       salary,
       PERCENT_RANK() over(
           partition by department
           order by salary
       ) as percent_rank
  from employees;

-- Query to calculate NTile() to divide employees into quartiles based on salary within their departments   
select emp_name,
       department,
       hire_date,
       salary,
       NTILE(4) over(
           partition by department
           order by salary
       ) as salary_quartile
  from employees;

-- Query to find the salary gap between the first hired employee and each employee within their department
select emp_name,
       department,
       hire_date,
       salary, first_hired_salary -salary as gap_between_hig_sal   from (
  select emp_name,
       department,
       hire_date,
       salary,
       first_value(salary) over(
           partition by department
           order by hire_date
       ) as first_hired_salary
    from employees
)  ;

-- Query to calculate average salary of the last 3 hired employees ordered by hire date
 
  select emp_name,
       department,
       hire_date,
       salary,
       avg(salary) over( 
           order by hire_date
           rows between 2 preceding and current row
       ) as last_hired_salary
    from employees;
 
 --Compute the rolling 2-employee average salary ordered by hire date.
  select emp_name,
       department,
       hire_date,
       salary,
       avg(salary) over( 
           order by hire_date
           rows between 1 preceding and current row
       ) as rolling_2_employee_avg_salary
    from employees;

