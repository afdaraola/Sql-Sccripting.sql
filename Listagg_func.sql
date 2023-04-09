SELECT
    colour,
    LISTAGG(shape, '->' ON OVERFLOW TRUNCATE) WITHIN GROUP(
        ORDER BY
            brick_id
        ) shapes
FROM
    bricks
GROUP BY
    colour
