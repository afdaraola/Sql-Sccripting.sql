/*

SQL Schema
Table: Logs

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| num         | varchar |
+-------------+---------+
id is the primary key for this table.
id is an autoincrement column.
 

Write an SQL query to find all numbers that appear at least three times consecutively.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Logs table:
+----+-----+
| id | num |
+----+-----+
| 1  | 1   |
| 2  | 1   |
| 3  | 1   |
| 4  | 2   |
| 5  | 1   |
| 6  | 2   |
| 7  | 2   |
+----+-----+
Output: 
+-----------------+
| ConsecutiveNums |
+-----------------+
| 1               |
+-----------------+
Explanation: 1 is the only number that appears consecutively for at least three times.

*/

create table logs (id number, num varchar(20);

insert into logs values (1,1);
insert into logs values (2,1);
insert into logs values (3,1);
insert into logs values (4,2);
insert into logs values (5,1);
insert into logs values (6,2);
insert into logs values (7,2);


select distinct num as ConsecutiveNums
from logs l1
where num = (select num from logs l2 where l2.id = l1.id+1)
  and num = (select num from logs l3 where l3.id = l1.id+2)

