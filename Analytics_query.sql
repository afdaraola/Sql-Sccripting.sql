create table bricks (
  brick_id integer,
  colour   varchar2(10),
  shape    varchar2(10),
  weight   integer
);


insert into bricks values ( 1, 'blue', 'cube', 1 );
insert into bricks values ( 2, 'blue', 'pyramid', 2 );
insert into bricks values ( 3, 'red', 'cube', 1 );
insert into bricks values ( 4, 'red', 'cube', 2 );
insert into bricks values ( 5, 'red', 'pyramid', 3 );
insert into bricks values ( 6, 'green', 'pyramid', 1 );

commit;

select *  from bricks;

select colour, sum(weight) brick_per_colour from bricks a  group by colour;

--You can carve up the input to an analytic function like this with the partition by clause. The following returns 
--the total weight and count of rows of each colour. It includes all the rows:
SELECT
    a.*,
    COUNT(1)
    OVER(PARTITION BY colour) brick_per_colour,
    SUM(weight)
    OVER(PARTITION BY colour)  AS weight_per_colour
FROM
    bricks a
ORDER BY
    colour DESC;
    
    
--Complete the following query to return the count and average weight of bricks for each shape:

    select b.*, 
       count(*) over (
         partition by b.shape
       ) bricks_per_shape, 
       median ( weight ) over (
         partition by b.shape
       ) median_weight_per_shape
from   bricks b
order  by shape, weight, brick_id;



--Complete the following query to get the running average weight, ordered by brick_id:
SELECT
    b.brick_id,
    b.weight,
    round(AVG(weight)
          OVER(
        ORDER BY
            b.brick_id
          ),2) runing_total_weight
FROM
    bricks b
ORDER BY
    brick_id;

--range between unbounded preceding  and current row

--Include all the rows with a value less than or equal to that of the current row.

--This can lead to the function including values from rows after the current!

--For example, there are several rows with the same weight. So when you sort by this, all rows with the same weight have the same running count and weight:
SELECT
    b.*,
    COUNT(*)
    OVER(
    ORDER BY
        weight
    ) running_total,
    SUM(weight)
    OVER(
    ORDER BY
        weight
    ) running_weight
FROM
    bricks b
ORDER BY
    weight;


--To fix this, add columns to the order by until each set of values in the sort appears once in your results. This makes your results deterministic. Here that's the brick_id:

SELECT
    b.*,
    COUNT(*)
    OVER(
        ORDER BY
            b.weight, b.brick_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) running_total,
    SUM(b.weight)
    OVER(
        ORDER BY
            b.weight,b.brick_id
            
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) runing_weight
FROM
    bricks b
ORDER BY
    b.weight, b.brick_id;

/*
Sliding Windows
As well as running totals so far, you can change the windowing clause to be a subset of the previous rows.

The following shows the total weight of:

The current row + the previous row
All rows with the same weight as the current + all rows with a weight one less than the current
*/


select b.*, 
       sum ( weight ) over (
         order by weight
         rows between 1 preceding and current row
       ) running_row_weight, 
       sum ( weight ) over (
         order by weight
         range between 1 preceding and current row
       ) running_value_weight
from   bricks b
order  by weight;


select b.*, 
       sum ( weight ) over (
         order by weight
         rows between 1 preceding and 1 following
       ) sliding_row_window, 
       sum ( weight ) over (
         order by weight
         range between 1 preceding and 1 following
       ) sliding_value_window
from   bricks b
order  by weight;

/*
You can also offset the window, so it excludes the current row! You can do this either side of the current row.

For example, the following query has two counts. The first shows the number of rows with a weight one or two less 
than the current. The second counts those with weights greater than the current. So if the current weight = 2,
the first count includes rows with the weight 0 or 1. The second rows with weight 3 or 4:
*/



select b.*, 
       count (*) over (
         order by weight
         range between 2 preceding and 1 preceding 
       ) count_weight_2_lower_than_current, 
       count (*) over (
         order by weight
         range between 1 following and 2 following
       ) count_weight_2_greater_than_current
from   bricks b
order  by weight;


/*
The minimum colour of the two rows before (but not including) the current row
The count of rows with the same weight as the current and one value following
*/


select b.*, 
       min ( colour ) over (
         order by brick_id
         rows BETWEEN 2 preceding and 0 FOLLOWING
       ) first_colour_two_prev, 
       count (*) over (
         order by weight
         range between 0 preceding and 1 following
       ) count_values_this_and_next
from   bricks b
order  by weight;



