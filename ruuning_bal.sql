CREATE TABLE sales_history (
  order_id INT,
  sales_date DATE,
  salesperson VARCHAR(20),
  order_value INT
);


INSERT INTO sales_history VALUES (1, '08-jan-2021', 'John', 15);
INSERT INTO sales_history(order_id, sales_date, salesperson, order_value) VALUES  (2, '09-jan-2021', 'Sarah', 8);
INSERT INTO sales_history(order_id, sales_date, salesperson, order_value) VALUES  (3, '09-jan-2021', 'Sally', 19);
INSERT INTO sales_history(order_id, sales_date, salesperson, order_value) VALUES  (4, '10-jan-2021', 'John', 2);
INSERT INTO sales_history(order_id, sales_date, salesperson, order_value) VALUES  (5, '10-jan-2021', 'Mark', 18);
INSERT INTO sales_history(order_id, sales_date, salesperson, order_value) VALUES  (6, '11-jan-2021', 'Sally', 3);
INSERT INTO sales_history(order_id, sales_date, salesperson, order_value) VALUES  (7, '11-jan-2021', 'Mark', 21);
INSERT INTO sales_history(order_id, sales_date, salesperson, order_value) VALUES  (8, '12-jan-2021', 'Sarah', 16);
INSERT INTO sales_history(order_id, sales_date, salesperson, order_value) VALUES  (9, '13-jan-2021', 'John', 4);



select order_id, sales_date, salesperson, order_value , sum(order_value) over(PARTITION BY salesperson order by sales_date asc) running_total
from sales_history 
group by  order_id, sales_date, salesperson, order_value ;

select order_id, sales_date, salesperson, order_value , sum(order_value) over(order by sales_date, order_id asc) running_total
from sales_history 
group by  order_id, sales_date, salesperson, order_value 
order by sales_date
