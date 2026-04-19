-- ============================================================
-- SQL for Data Analysts — Part 5: CTEs
-- examples/null_pattern.sql
-- Finding reps with zero orders using LEFT JOIN + IS NULL
-- (same pattern from Part 3 — now written cleaner with a CTE)
-- ============================================================


-- ── WITHOUT A CTE (from Part 3) ──────────────────────────────
-- Works fine, but the date logic is buried inside the join

SELECT
    r.rep_id,
    r.rep_name,
    r.region
FROM sales_reps r
LEFT JOIN sales_orders o
    ON r.rep_id = o.rep_id
    AND DATE_TRUNC('month', o.order_date) = DATE_TRUNC('month', CURRENT_DATE)
WHERE o.order_id IS NULL
ORDER BY r.region, r.rep_name;


-- ── WITH A CTE ───────────────────────────────────────────────
-- The CTE does one job: define "active this month"
-- The outer query does one job: find who's not in that list

WITH active_this_month AS (
    SELECT DISTINCT rep_id
    FROM sales_orders
    WHERE DATE_TRUNC('month', order_date) = DATE_TRUNC('month', CURRENT_DATE)
)
SELECT
    r.rep_id,
    r.rep_name,
    r.region
FROM sales_reps r
LEFT JOIN active_this_month a ON r.rep_id = a.rep_id
WHERE a.rep_id IS NULL
ORDER BY r.region, r.rep_name;

-- Expected: Dana Kovacs (rep 10) has zero orders in the table.
-- Lin Wei (rep 9) only has an order from 45 days ago — also shows up.
-- Tariq Al-Amin (rep 8) has orders this month but all are 'pending',
-- so he appears here too depending on how you define "active".
-- Try modifying the CTE to only count 'paid' orders — see what changes.
