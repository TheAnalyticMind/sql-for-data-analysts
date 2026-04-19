-- ============================================================
-- SQL for Data Analysts — Part 5: CTEs
-- examples/cte_basics.sql
-- CTE vs subquery — same result, different readability
-- ============================================================


-- ── THE SUBQUERY VERSION ─────────────────────────────────────
-- Try reading this cold. How long does it take you to
-- understand what the outer query is doing?

SELECT
    rep_name,
    region,
    total_sales
FROM (
    SELECT
        r.rep_name,
        r.region,
        SUM(o.amount) AS total_sales
    FROM sales_reps r
    LEFT JOIN sales_orders o ON r.rep_id = o.rep_id
    WHERE o.status = 'paid'
    GROUP BY r.rep_name, r.region
) rep_summary
WHERE total_sales > 10000
ORDER BY total_sales DESC;


-- ── THE CTE VERSION ─────────────────────────────────────────
-- Same query. Same result. Read it again — notice how
-- the structure tells you the story before you follow the logic.

WITH rep_summary AS (
    SELECT
        r.rep_name,
        r.region,
        SUM(o.amount) AS total_sales
    FROM sales_reps r
    LEFT JOIN sales_orders o ON r.rep_id = o.rep_id
    WHERE o.status = 'paid'
    GROUP BY r.rep_name, r.region
)
SELECT
    rep_name,
    region,
    total_sales
FROM rep_summary
WHERE total_sales > 10000
ORDER BY total_sales DESC;

-- Expected output: Carlos Reyes and Priya Menon
-- (the only two reps over 10,000 in paid orders this month)
