-- ============================================================
-- SQL for Data Analysts — Part 3: JOINs
-- Tables: sales_orders, sales_reps
-- ============================================================


-- EXERCISE 1
-- INNER JOIN — order details with rep name and region

SELECT
    o.order_id,
    o.amount,
    r.rep_name,
    r.region
FROM sales_orders o
INNER JOIN sales_reps r
    ON o.rep_id = r.rep_id;


-- EXERCISE 2
-- LEFT JOIN — all reps, NULL where no orders exist

SELECT
    r.rep_name,
    r.region,
    o.order_id,
    o.amount
FROM sales_reps r
LEFT JOIN sales_orders o
    ON r.rep_id = o.rep_id;


-- EXERCISE 3
-- Reps with zero orders — LEFT JOIN + IS NULL

SELECT
    r.rep_id,
    r.rep_name,
    r.region
FROM sales_reps r
LEFT JOIN sales_orders o
    ON r.rep_id = o.rep_id
WHERE o.order_id IS NULL;


-- EXERCISE 4
-- Total paid sales per rep — LEFT JOIN + GROUP BY

SELECT
    r.rep_name,
    r.region,
    COUNT(o.order_id)   AS total_orders,
    SUM(o.amount)       AS total_sales
FROM sales_reps r
LEFT JOIN sales_orders o
    ON r.rep_id = o.rep_id
    AND o.status = 'paid'
GROUP BY r.rep_name, r.region
ORDER BY total_sales DESC NULLS LAST;


-- EXERCISE 5
-- EMEA paid orders only — condition in ON clause

SELECT
    o.order_id,
    o.amount,
    r.rep_name,
    r.region
FROM sales_orders o
INNER JOIN sales_reps r
    ON o.rep_id = r.rep_id
WHERE o.status = 'paid'
  AND r.region = 'EMEA'
ORDER BY o.amount DESC;
