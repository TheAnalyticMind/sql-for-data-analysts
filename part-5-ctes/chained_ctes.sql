-- ============================================================
-- SQL for Data Analysts — Part 5: CTEs
-- examples/chained_ctes.sql
-- Multi-step reporting with chained CTEs
-- ============================================================
-- Business question:
-- Which reps are in the top 25% by paid sales this month,
-- and what is their average deal size?
-- ============================================================


WITH paid_orders AS (
    -- Step 1: isolate paid orders from this month only
    SELECT
        rep_id,
        amount
    FROM sales_orders
    WHERE status = 'paid'
      AND DATE_TRUNC('month', order_date) = DATE_TRUNC('month', CURRENT_DATE)
),

rep_totals AS (
    -- Step 2: aggregate by rep — join to get names and region
    SELECT
        r.rep_id,
        r.rep_name,
        r.region,
        COUNT(o.amount)  AS deal_count,
        SUM(o.amount)    AS total_sales,
        AVG(o.amount)    AS avg_deal_size
    FROM sales_reps r
    LEFT JOIN paid_orders o ON r.rep_id = o.rep_id
    GROUP BY r.rep_id, r.rep_name, r.region
),

percentile_cutoff AS (
    -- Step 3: calculate where the top 25% starts
    SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (
        ORDER BY total_sales
    ) AS p75
    FROM rep_totals
)

-- Step 4: filter to reps at or above that threshold
SELECT
    rt.rep_name,
    rt.region,
    rt.deal_count,
    rt.total_sales,
    ROUND(rt.avg_deal_size, 2) AS avg_deal_size
FROM rep_totals rt
CROSS JOIN percentile_cutoff pc
WHERE rt.total_sales >= pc.p75
ORDER BY rt.total_sales DESC;


-- ── HOW TO DEBUG THIS ────────────────────────────────────────
-- Comment out everything after the second CTE and run just:
--
-- WITH paid_orders AS ( ... ),
-- rep_totals AS ( ... )
-- SELECT * FROM rep_totals ORDER BY total_sales DESC;
--
-- Check those numbers make sense before adding the next step.
-- This is the real workflow benefit of chained CTEs.
