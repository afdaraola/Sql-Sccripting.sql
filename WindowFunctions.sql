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
       salary, first_hired_salary -salary as gap_between_hig_sal 
         from (
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



-- Example usage of REMAINDER() function
select  REMAINDER(n2, n1) as result
from (SELECT 13 as n2, 4 as n1 FROM dual);
 


--DECOMPOSE ( input_string [CANONICAL|COMPATIBILITY] )
WITH strings AS (
    SELECT 'Café' AS input_string FROM dual
)
SELECT input_string,
       DECOMPOSE(input_string, 'CANONICAL') AS canonical_form,
       DECOMPOSE(input_string, 'COMPATIBILITY') AS compatibility_form
FROM strings;

--INITCAP function example

SELECT INITCAP('hello world from oracle sql') AS initcap_result FROM dual;

--length2 function example
SELECT LENGTH2('Hello Oracle SQL!') AS length2_result, LENGTH('Hello Oracle SQL!') length_result FROM dual;

--SOUNDEX function example 
SELECT SOUNDEX('Smith') AS soundex_smith, SOUNDEX('Smyth') AS soundex_smyth FROM dual;

select * from tab ;

select * FROM employees;

set SERVEROUTPUT ON;

-- Example of EXECUTE IMMEDIATE to get total salary of a department
declare 
sql_qry varchar2(100);
v_result number;
begin
    sql_qry := 'SELECT SUM(salary) FROM employees WHERE department = :dept_name';
    EXECUTE IMMEDIATE sql_qry INTO v_result USING 'IT';
    dbms_output.put_line('Total Salary in IT Department: ' || v_result);
end;

-- Example of using BULK COLLECT with EXECUTE IMMEDIATE

DECLARE 
 Type nt_type is table of varchar2(50);
    v_names nt_type;
    sql_qry varchar2(100);
    begin
        sql_qry := 'SELECT emp_name FROM employees WHERE department = :dept_name';
        EXECUTE IMMEDIATE sql_qry BULK COLLECT INTO v_names USING 'Finance';
        
        FOR i IN 1 .. v_names.COUNT LOOP
            dbms_output.put_line('Employee Name: ' || v_names(i));
        END LOOP;
    end;

-- Example of using BULK COLLECT without EXECUTE IMMEDIATE

declare
     Type nt_ename is table of VARCHAR2(50);
        v_ename nt_ename;
    BEGIN 
        SELECT emp_name BULK COLLECT INTO v_ename
        FROM employees
        WHERE department = 'HR';
        
        FOR i IN 1 .. v_ename.COUNT LOOP
            dbms_output.put_line('HR Employee: ' || v_ename(i));
        END LOOP;
    END;


-- Example of using BULK COLLECT with a cursor
declare 
Type nt_salary is table of number;
    v_salaries nt_salary;

CURSOR c_salaries is
    SELECT salary FROM employees WHERE department = 'IT';
BEGIN
    OPEN c_salaries;
    LOOP
        FETCH c_salaries BULK COLLECT INTO v_salaries LIMIT 2;  
        EXIT WHEN v_salaries.COUNT = 0;
        FOR i IN 1 .. v_salaries.COUNT LOOP
            dbms_output.put_line('IT Salary: ' || v_salaries(i));
        END LOOP;
    END LOOP;
    CLOSE c_salaries;
END;



select user from dual;

create table mul_tab(
    mul_tab number
)

-- Example of using FORALL to perform bulk inserts

declare 
   Type nt_multi is table of number INDEX BY PLS_INTEGER;
    v_emp_ids nt_multi; 
    v_result number;
BEGIN

    for i in 1..10 loop
        v_emp_ids(i) := i * 8;
    end loop;

    forall i in v_emp_ids.FIRST .. v_emp_ids.LAST 
        insert into mul_tab(mul_tab) values (v_emp_ids(i));
COMMIT; 
select count(1) into v_result from mul_tab;
DBMS_OUTPUT.PUT_LINE('There are ' || v_result || ' items in the table.');
END;


 set SERVEROUTPUT ON;

 declare 
 type nt_name is table of VARCHAR2(10);
    v_names nt_name:= nt_name();
    BEGIN
        v_names.extend(3);
        v_names(1) := 'Anna';
        v_names(2) := 'Brian';
        v_names(3) := 'Catherine';

        FORALL i IN v_names.FIRST .. v_names.LAST save EXCEPTIONS
            INSERT INTO employees (emp_id, emp_name, department, hire_date, salary)
            VALUES (100 , v_names(i), 'Temp', SYSDATE, 50000 + ( 1000));
    COMMIT;
    EXCEPTION when others then
        FOR r IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('Error at index: ' || SQL%BULK_EXCEPTIONS(r).ERROR_INDEX ||
                                 ' - Error code: ' || SQL%BULK_EXCEPTIONS(r).ERROR_CODE);
           DBMS_OUTPUT.PUT_LINE(sqlerrm(-SQL%BULK_EXCEPTIONS(r).ERROR_CODE));
        END LOOP;
    END;


    declare 
    type nt_assoc is table of VARCHAR2(10) INDEX BY PLS_INTEGER; -- Associative Array
    type nt_nexttbl is table of VARCHAR2(10);       -- Nested Table
    type t_array is varray(10) of VARCHAR2(10);  -- VARRAY
    
        v_assoc nt_assoc;
        v_nexttbl nt_nexttbl:=nt_nexttbl();
        v_array t_array:=t_array();
    BEGIN
        v_assoc(10) := 'Delta';
        v_assoc(20) := 'Echo';

        v_nexttbl.extend;
        v_nexttbl(1) := 'Foxtrot';
        v_nexttbl.extend;
        v_nexttbl(2) := 'Golf';

        v_array.extend(2);
        v_array(1) := 'Hotel';
        v_array(2) := 'India';

        dbms_output.put_line('Associative Array: ' || v_assoc(10) || ', ' || v_assoc(20));
        dbms_output.put_line('Nested Table: ' || v_nexttbl(1) || ', ' || v_nexttbl(2)); 
        dbms_output.put_line('VARRAY: ' || v_array(1) || ', ' || v_array(2));

        dbms_output.put_line('Associative Array Count: ' || v_assoc.COUNT);
        dbms_output.put_line('Nested Table Count: ' || v_nexttbl.COUNT);
        dbms_output.put_line('VARRAY Count: ' || v_array.COUNT);
        end;




SELECT SALARY, NTH_VALUE(SALARY,2) OVER (ORDER BY DEPARTMENT) FROM employees;
        


select sys_context('USERENV','CURRENT_USER') , sys_context('USERENV', 'IP_ADDRESS') from dual;
 

 create table Tbl (id number, cube NUMBER);
----=======================================================================================================================
 --Oracle WITH PLSQL HINT.
---========================================================================================================================

 --The /*+ WITH_PLSQL */ "hint" in Oracle is not an optimizer hint for performance tuning; rather, 
 --it is a compiler directive introduced in Oracle 12c that enables the use of PL/SQL functions or 
 --procedures defined within a WITH clause when that WITH clause is not at the top level of a SQL statement. 

 --The WITH_PLSQL hint is required in specific scenarios: 
    --1. if the top-level statement is a select statement, then it must have either a WITH plsql_declaration clause or the WITH_PLSQL hint.
    --2. if the top-level statement is an insert, update, delete, or merge statement, then it must have the WITH_PLSQL hint.
 
 --Syntax Examples
 --In a Top-Level SELECT (Hint Not Needed)
 --When the WITH clause is at the very beginning of the statement, no hint is needed. 


WITH 
  FUNCTION fn_get_cube(n IN NUMBER) RETURN NUMBER
  as 
  begin 
    RETURN power(n,3);
  end;
  select level l, fn_get_cube(level) cube_value
                        from dual connect by level <= 5;


 --In a Subquery (Hint Needed)
 --When the WITH clause is nested, the top-level SELECT needs the hint. 

select /*+ WITH_PLSQL */ * from (
  with 
  FUNCTION fn_get_cube(n IN NUMBER) RETURN NUMBER
  as 
  begin 
    RETURN power(n,3);
  end;
  select level l, fn_get_cube(level) cube_value
                        from dual connect by level <= 5
);

 --In a DML Statement (Hint Needed)
 --The hint is placed after the DML keyword for INSERT, UPDATE, DELETE, or MERGE statements. 
INSERT  /*+ WITH_PLSQL */ INTO TBL 
SELECT * FROM
( with 
  FUNCTION fn_get_cube(n IN NUMBER) RETURN NUMBER
  as 
  begin 
    RETURN power(n,3);
  end;
  select level l, fn_get_cube(level) cube_value
                    from dual connect by level <= 5
);

UPDATE  /*+ WITH_PLSQL */ TBL   a
 set a.cube = 
( with 
  FUNCTION fn_get_cube(n IN NUMBER) RETURN NUMBER
  as 
  begin 
    RETURN power(n,2);
  end;
  select  fn_get_cube(2) cube_value
  from dual 
);
commit;

----===================================================================================================
---Key SQL/JSON Functions
---===================================================================================================
-- JSON_OBJECT function example
--JSON_OBJECT: Constructs a JSON object from specified key-value pairs or SQL object types.
SELECT JSON_OBJECT('employee_id' VALUE emp_id,
                   'employee_name' VALUE emp_name,
                   'department' VALUE department) AS employee_json
FROM employees
WHERE emp_id = 1;

-- JSON_ARRAYAGG function example
--JSON_ARRAYAGG: An aggregate function that creates a JSON array from multiple rows, useful for one-to-many relationships.
SELECT department, JSON_ARRAYAGG(JSON_OBJECT('employee_id' VALUE emp_id,
                             'employee_name' VALUE emp_name)) AS employees_json_array
FROM employees
--WHERE department = 'IT' 
group by department ;

-- JSON_TABLE function example
--JSON_TABLE: Transforms JSON data into a virtual relational table (rows and columns), allowing standard SQL operations and joins.
WITH json_data AS (
    SELECT '[{"emp_id":1,"emp_name":"Alice", "department":"IT"},{"emp_id":2,"emp_name":"Bob", "department":"HR"}]' AS emp_json
    FROM dual
)
SELECT * --jt.emp_id, jt.emp_name, jt.department
FROM json_data jd,
     JSON_TABLE(jd.emp_json, '$[*]' COLUMNS (
         emp_id NUMBER PATH '$.emp_id',
         emp_name VARCHAR2(50) PATH '$.emp_name',
         department VARCHAR2(30) PATH '$.department'
     )) jt; 


--Json_array function example
---JSON_ARRAY: Constructs a JSON array from a set of SQL expressions.
SELECT emp_id, JSON_ARRAY(emp_name, department) AS emp_json_array
FROM employees
WHERE emp_id = 3;


-- JSON_VALUE function example
--JSON_VALUE: Extracts a scalar value (like a number or string) from JSON data using a path expression and returns it as a SQL value.
SELECT emp_id,
       JSON_VALUE(JSON_OBJECT('emp_name' VALUE emp_name, 'department' VALUE department), '$.emp_name') AS employee_name
FROM employees
WHERE emp_id = 4;   

--JSON_TRANSFORM: Modifies JSON data atomically using operations like INSERT, SET, REMOVE, REPLACE, RENAME, and APPEND.

WITH json_data AS (
    SELECT '{"emp_id":5,"emp_name":"Eve","department":"Finance"}' AS emp_json
    FROM dual
)
SELECT JSON_TRANSFORM(jd.emp_json,
                      'SET $.department = "Marketing"',
                      'INSERT $.salary = 85000') AS updated_json
FROM json_data jd;


--JSON_SERIALIZE:
--JSON_SERIALIZE: Converts JSON data into a string representation with formatting options like pretty-printing.
WITH json_data AS (
    SELECT '{"emp_id":6,"emp_name":"Frank","department":"IT","salary":90000}' AS emp_json
    FROM dual
)
SELECT JSON_SERIALIZE(jd.emp_json FORMAT JSON PRETTY) AS pretty_json
FROM json_data jd; 


SELECT department, json_serialize(JSON_ARRAYAGG(JSON_OBJECT('employee_id' VALUE emp_id,
                             'employee_name' VALUE emp_name)) format json pretty) AS employees_json_array
FROM employees
--WHERE department = 'IT' 
group by department ;


--JSON_EXISTS function example
--JSON_EXISTS: Checks if a specified path exists within JSON data, returning a boolean result.
WITH json_data AS (
    SELECT '{"emp_id":7,"emp_name":"Grace","department":"HR","skills":["SQL","PL/SQL","Java"]}' AS emp_json
    FROM dual
)
SELECT CASE
           WHEN JSON_EXISTS(jd.emp_json, '$.skills[?(@ == "Java")]') THEN 'Java skill exists'
           ELSE 'Java skill does not exist'
       END AS skill_check
FROM json_data jd;


--JSON_OBJECT_TYPE:
--JSON_OBJECT_TYPE: Returns the type of a JSON object (e.g., OBJECT, ARRAY, STRING, NUMBER, BOOLEAN, NULL).
WITH json_data AS (
    SELECT '{"emp_id":8,"emp_name":"Henry","department":"IT"}' AS emp_json
    FROM dual
)
SELECT  JSON_OBJECT_TYPE(jd.emp_json) AS json_type
FROM json_data jd;  

---------------=====================================================
--Approximate Query Functions
----====================================================================
--Approximate query functions are designed to provide fast, resource-efficient estimates for large datasets where
select approx_count_distinct(manager_id), count(manager_id), count( distinct manager_id) , count(1) FROM employees;



----====================================================================
--PL/SQL UDF with PRAGMA UDF
---====================================================================
--Creating a UDF to calculate the square of a number
--The PRAGMA UDF is an Oracle compiler directive used within a PL/SQL function to tell the compiler that 
--the function will be used primarily in SQL statements. This allows Oracle to potentially improve performance
-- by reducing the overhead of the context switch between the SQL and PL/SQL engines. 


--Performance: The primary benefit is improved performance when a PL/SQL function is called repeatedly from a SQL context,
-- especially when processing a large number of rows. It minimizes the "context switching" cost between the SQL and PL/SQL virtual machines.

create or  REPLACE FUNCTION udf_square(n IN NUMBER)
 RETURN NUMBER
 as
PRAGMA UDF; -- Compiler directive to optimize for UDF
v_value NUMBER;
BEGIN
    RETURN n * n;
END;


--Testing the UDF
SELECT emp_id, emp_name, udf_square(salary) AS salary_squared
FROM employees;
 

 ---====================================================================
 --Automatic List-Partitioned Table
---====================================================================
--Creating an automatic list-partitioned table for employee records based on department 

DROP TABLE emp_auto_list_part PURGE;

create table emp_auto_list_part (
    emp_id        NUMBER PRIMARY KEY,
    emp_name      VARCHAR2(50),
    department    VARCHAR2(30),
    hire_date     DATE,
    salary        NUMBER(10,2)
)
partition by list (department) automatic
(
    partition p_finance values ('Finance'),
    partition p_it values ('IT'),
    partition p_hr values ('HR')
);


--Inserting sample data into the automatic list-partitioned table
INSERT INTO emp_auto_list_part VALUES (11, 'Karen', 'Finance', DATE '2023-01-15', 72000);
INSERT INTO emp_auto_list_part VALUES (12, 'Leo', 'IT', DATE '2022-08-23', 98000);
INSERT INTO emp_auto_list_part VALUES (13, 'Mona', 'HR', DATE '2021-11-30', 68000);
INSERT INTO emp_auto_list_part VALUES (14, 'Nina', 'Marketing', DATE '2023-03-12', 75000); -- New department
INSERT INTO emp_auto_list_part VALUES (15, 'Oscar', 'Sales', DATE '2022-12-05', 80000);    -- New department
COMMIT;

--Querying the automatic list-partitioned table
SELECT * FROM emp_auto_list_part;

commit;

select * from user_tab_partitions where table_name='EMP_AUTO_LIST_PART';

select * from user_tab_subpartitions where table_name='EMP_AUTO_LIST_PART';


exec dbms_stats.gather_table_stats(ownname=>'DEVUSER', tabname=>'EMP_AUTO_LIST_PART', cascade=>true);


SELECT *  --owner, table_name, last_analyzed, stale_stats 
        FROM   dba_tab_statistics WHERE  table_name = 'EMP_AUTO_LIST_PART';


BEGIN
  DBMS_STATS.GATHER_TABLE_STATS (
    ownname => 'DEVUSER',
    tabname => 'EMP_AUTO_LIST_PART'
  );
END;
/


SELECT * FROM EMP_AUTO_LIST_PART PARTITION (P_IT);

---====================================================================
--expand sql txt 
---====================================================================

create or replace view emp_view as 
select * from employees; 


declare 
output varchar2(4000);
begin
  dbms_utility.expand_sql_text('select * from emp_view', output_value=>output);
  dbms_output.put_line(output);
end;


SET SERVEROUTPUT ON

DECLARE
    input_sql  CLOB;
    output_sql CLOB;
BEGIN
    -- Assign your SQL statement to the input variable.
    -- The example uses a simple view 'my_view' for demonstration.
    input_sql := 'SELECT prod_name, sum(amount_sold) 
                  FROM my_view 
                  INNER JOIN sh.products USING (prod_id) 
                  GROUP BY prod_name';

    -- Call the expansion procedure
    DBMS_UTILITY.EXPAND_SQL_TEXT(
        input_sql  => input_sql,
        output_sql => output_sql
    );

    -- Display the expanded SQL text
    DBMS_OUTPUT.PUT_LINE('The expanded SQL is:');
    DBMS_OUTPUT.PUT_LINE(output_sql);
END;
/
