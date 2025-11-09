-- Drop if they exist
DROP TABLE sales_transactions PURGE;
DROP TABLE customers PURGE;

-- Customers table
CREATE TABLE customers (
    customer_id    NUMBER PRIMARY KEY,
    customer_name  VARCHAR2(50),
    region         VARCHAR2(20)
);

INSERT INTO customers VALUES (1, 'Acme Corp', 'North');
INSERT INTO customers VALUES (2, 'Beta Ltd', 'South');
INSERT INTO customers VALUES (3, 'CitiGroup', 'West');
INSERT INTO customers VALUES (4, 'Delta Inc', 'East');
INSERT INTO customers VALUES (5, 'Epsilon Co', 'North');

-- Sales transactions table
CREATE TABLE sales_transactions (
    txn_id        NUMBER PRIMARY KEY,
    customer_id   NUMBER CONSTRAINT fk_customerID REFERENCES customers(customer_id),
    txn_date      DATE,
    product       VARCHAR2(30),
    quantity      NUMBER,
    unit_price    NUMBER(10,2)
);

INSERT INTO sales_transactions VALUES (101, 1, DATE '2024-01-15', 'Laptop', 3, 1200);
INSERT INTO sales_transactions VALUES (102, 1, DATE '2024-02-10', 'Mouse', 10, 25);
INSERT INTO sales_transactions VALUES (103, 2, DATE '2024-01-28', 'Monitor', 5, 250);
INSERT INTO sales_transactions VALUES (104, 3, DATE '2024-02-15', 'Keyboard', 8, 50);
INSERT INTO sales_transactions VALUES (105, 3, DATE '2024-03-10', 'Laptop', 2, 1300);
INSERT INTO sales_transactions VALUES (106, 4, DATE '2024-03-20', 'Laptop', 1, 1100);
INSERT INTO sales_transactions VALUES (107, 5, DATE '2024-04-02', 'Monitor', 4, 300);
INSERT INTO sales_transactions VALUES (108, 1, DATE '2024-04-12', 'Laptop', 1, 1250);
INSERT INTO sales_transactions VALUES (109, 2, DATE '2024-04-25', 'Mouse', 6, 20);
INSERT INTO sales_transactions VALUES (110, 5, DATE '2024-05-15', 'Laptop', 2, 1400);

COMMIT;


select * from sales_transactions;
select * from customers;

select * from ALL_CONSTRAINTS where table_name='SALES_TRANSACTIONS';

select * from ALL_TAB_COLS where table_name='SALES_TRANSACTIONS';

select * from ALL_TAB_COLUMNS where table_name='SALES_TRANSACTIONS';

-- Query: Total spending per customer

SELECT c.customer_name, SUM(s.quantity * s.unit_price) AS total_spent
FROM customers c
JOIN sales_transactions s ON c.customer_id = s.customer_id
GROUP BY c.customer_name
ORDER BY total_spent DESC;

-- Query: Monthly sales ranking per customer

select c.CUSTOMER_NAME , to_char(s.TXN_DATE,'MM-YYYY') MONTH_YEAR, 
        SUM(S.QUANTITY * S.UNIT_PRICE) TOTAL_SALES,
        RANK() OVER (PARTITION BY to_char(s.TXN_DATE,'MM-YYYY') 
                    ORDER BY SUM(S.QUANTITY * S.UNIT_PRICE) DESC) AS SALES_RANK
        from sales_transactions s 
            join customers c on s.customer_id = c.customer_id
        group by c.CUSTOMER_NAME, to_char(s.TXN_DATE,'MM-YYYY')
        order by MONTH_YEAR, SALES_RANK;


--Calculate month-over-month sales growth by region 
WITH monthly_sales AS (
    SELECT c.region,
           TO_CHAR(s.txn_date, 'MM-YYYY') AS month_year,
           SUM(s.quantity * s.unit_price) AS total_sales
    FROM sales_transactions s
    JOIN customers c ON s.customer_id = c.customer_id
    GROUP BY c.region, TO_CHAR(s.txn_date, 'MM-YYYY')
), sales_with_lag AS (
    SELECT region,
           month_year,
           total_sales,
           LAG(total_sales) OVER (PARTITION BY region ORDER BY month_year) AS prev_month_sales
    FROM monthly_sales
)
SELECT region,
       month_year,
       total_sales,
       prev_month_sales,
       CASE 
           WHEN prev_month_sales IS NULL THEN NULL
           ELSE ROUND(((total_sales - prev_month_sales) / prev_month_sales) * 100, 2)
       END AS sales_growth_pct
FROM sales_with_lag
ORDER BY region, month_year;    


--Find top 2 products per region by revenue 
WITH product_revenue AS (
    SELECT c.region,
           s.product,
           SUM(s.quantity * s.unit_price) AS total_revenue
    FROM sales_transactions s
    JOIN customers c ON s.customer_id = c.customer_id
    GROUP BY c.region, s.product
), ranked_products AS (
    SELECT region,
           product,
           total_revenue,
           RANK() OVER (PARTITION BY region ORDER BY total_revenue DESC) AS revenue_rank
    FROM product_revenue
)
SELECT region,
       product,
       total_revenue
FROM ranked_products
WHERE revenue_rank <= 2
ORDER BY region, revenue_rank;

--Compute a 2-transaction moving average of total sale amount per customer
WITH customer_sales AS (
    SELECT c.customer_name,
           s.txn_date,
           (s.quantity * s.unit_price) AS sale_amount
    FROM sales_transactions s
    JOIN customers c ON s.customer_id = c.customer_id
), moving_avg AS (
    SELECT customer_name,
           txn_date,
           sale_amount,
           AVG(sale_amount) OVER (PARTITION BY customer_name ORDER BY txn_date 
                                  ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS two_txn_moving_avg
    FROM customer_sales
)
SELECT customer_name,
       txn_date,
       sale_amount,
       two_txn_moving_avg
FROM moving_avg
ORDER BY customer_name, txn_date;   

--Identify each customer’s most expensive purchase  
WITH customer_purchases AS (
    SELECT c.customer_name,
           s.txn_id,
           (s.quantity * s.unit_price) AS purchase_amount,
           RANK() OVER (PARTITION BY c.customer_name ORDER BY (s.quantity * s.unit_price) DESC) AS purchase_rank
    FROM sales_transactions s
    JOIN customers c ON s.customer_id = c.customer_id
)
SELECT customer_name,
       txn_id,
       purchase_amount
FROM customer_purchases
WHERE purchase_rank = 1
ORDER BY customer_name;

--Assign transaction sequence numbers per customer
SELECT c.customer_name,
       s.txn_id,
       s.txn_date,
       ROW_NUMBER() OVER (PARTITION BY c.customer_name ORDER BY s.txn_date) AS txn_sequence
FROM sales_transactions s
JOIN customers c ON s.customer_id = c.customer_id
ORDER BY c.customer_name, s.txn_date;

--Find each region’s top-spending customer by total revenue.
WITH customer_totals AS (
    SELECT c.region,
           c.customer_name,
           SUM(s.quantity * s.unit_price) AS total_spent,
           RANK() OVER (PARTITION BY c.region ORDER BY SUM(s.quantity * s.unit_price) DESC) AS spend_rank
    FROM sales_transactions s
    JOIN customers c ON s.customer_id = c.customer_id
    GROUP BY c.region, c.customer_name
)
SELECT region,
       customer_name,
       total_spent
FROM customer_totals
WHERE spend_rank = 1
ORDER BY region;    

--Show cumulative sales growth per region by month.
WITH monthly_sales AS (
    SELECT c.region,
           TO_CHAR(s.txn_date, 'MM-YYYY') AS month_year,
           SUM(s.quantity * s.unit_price) AS total_sales
    FROM sales_transactions s
    JOIN customers c ON s.customer_id = c.customer_id
    GROUP BY c.region, TO_CHAR(s.txn_date, 'MM-YYYY')
), sales_with_cume AS (
    SELECT region,
           month_year,
           total_sales,
           SUM(total_sales) OVER (PARTITION BY region ORDER BY month_year) AS cumulative_sales
    FROM monthly_sales
)
SELECT region,
       month_year,
       total_sales,
       cumulative_sales
FROM sales_with_cume
ORDER BY region, month_year;    

--For each customer, show the difference between current and previous purchase amount.
WITH customer_purchases AS (
    SELECT c.customer_name,
           s.txn_date,
           (s.quantity * s.unit_price) AS purchase_amount,
           LAG(s.quantity * s.unit_price) OVER (PARTITION BY c.customer_name ORDER BY s.txn_date) AS prev_purchase_amount
    FROM sales_transactions s
    JOIN customers c ON s.customer_id = c.customer_id
)
SELECT customer_name,
       txn_date,
       purchase_amount,
       prev_purchase_amount,
       CASE 
           WHEN prev_purchase_amount IS NULL THEN NULL
           ELSE purchase_amount - prev_purchase_amount
       END AS amount_difference
FROM customer_purchases
ORDER BY customer_name, txn_date;                      

--Rank all customers globally and within their region by total spend.
WITH customer_spend AS (
    SELECT c.region,
           c.customer_name,
           SUM(s.quantity * s.unit_price) AS total_spent
    FROM sales_transactions s
    JOIN customers c ON s.customer_id = c.customer_id
    GROUP BY c.region, c.customer_name
)
SELECT region,
       customer_name,
       total_spent,
       RANK() OVER (ORDER BY total_spent DESC) AS global_rank,
         RANK() OVER (PARTITION BY region ORDER BY total_spent DESC) AS regional_rank
FROM customer_spend
ORDER BY region, regional_rank;


--Calculate the share of each customer’s total sales relative to their region’s total.

WITH region_totals AS (
    SELECT c.region,
           SUM(s.quantity * s.unit_price) AS region_total_sales
    FROM sales_transactions s
    JOIN customers c ON s.customer_id = c.customer_id
    GROUP BY c.region
), customer_totals AS (
    SELECT c.region,
           c.customer_name,
           SUM(s.quantity * s.unit_price) AS customer_total_sales
    FROM sales_transactions s
    JOIN customers c ON s.customer_id = c.customer_id
    GROUP BY c.region, c.customer_name
)
SELECT ct.region,
       ct.customer_name,
       ct.customer_total_sales,
       rt.region_total_sales,
       ROUND((ct.customer_total_sales / rt.region_total_sales) * 100, 2) AS sales_share_pct
FROM customer_totals ct
JOIN region_totals rt ON ct.region = rt.region
ORDER BY ct.region, sales_share_pct DESC;   