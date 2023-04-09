  
SELECT
    *
FROM
    bricks a,
     (
        SELECT
            colour,
            AVG(weight) AS avgs
        FROM
            bricks
        GROUP BY
            colour
    )      b
WHERE
    a.colour = b.colour;
    
   --introduce lateral to enable reference left table 
SELECT
    *
FROM
    bricks a,
    lateral(
        SELECT
            colour,
            AVG(weight) AS avgs
        FROM
            bricks
        WHERE
            colour = a.colour
        GROUP BY
            colour
    )      b
WHERE
    a.colour = b.colour;
