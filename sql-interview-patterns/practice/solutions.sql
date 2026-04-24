-- ============================================================
-- SQL Interview Patterns — Solutions
-- ============================================================
-- Try questions.sql first.
-- Each solution includes the common trap — the exact mistake
-- that costs people the offer when they almost had it.
-- ============================================================


-- ── S1: RUNNING TOTALS ───────────────────────────────────────

SELECT
    r.rep_name,
    o.order_date,
    o.amount,
    SUM(o.amount) OVER (
        PARTITION BY o.rep_id
        ORDER BY o.order_date
    ) AS running_total
FROM sales_orders o
JOIN sales_reps r ON o.rep_id = r.rep_id
WHERE o.status = 'paid'
ORDER BY r.rep_name, o.order_date;

-- Common trap: leaving out ORDER BY inside OVER().
-- SUM() OVER (PARTITION BY rep_id) with no ORDER BY returns
-- the partition total on every row — not a running total.
-- The query runs, the numbers look plausible, and it's wrong.


-- ── S2: RANK WITHIN GROUP ────────────────────────────────────

WITH rep_totals AS (
    SELECT
        r.rep_id,
        r.rep_name,
        r.region,
        SUM(o.amount) AS total_sales
    FROM sales_reps r
    LEFT JOIN sales_orders o
        ON r.rep_id = o.rep_id AND o.status = 'paid'
    GROUP BY r.rep_id, r.rep_name, r.region
)
SELECT
    rep_name,
    region,
    total_sales,
    DENSE_RANK() OVER (
        PARTITION BY region
        ORDER BY total_sales DESC NULLS LAST
    ) AS region_rank
FROM rep_totals
ORDER BY region, region_rank;

-- Common trap: using ROW_NUMBER() instead of DENSE_RANK().
-- ROW_NUMBER() arbitrarily promotes one tied rep over another.
-- Interviewers build ties into datasets to catch exactly this.
-- Also: forgetting NULLS LAST means NULL (zero-order reps)
-- sorts to the top as if they're the best performer.


-- ── S3: MONTH-OVER-MONTH CHANGE ──────────────────────────────

WITH monthly_sales AS (
    SELECT
        r.rep_name,
        DATE_TRUNC('month', o.order_date) AS sale_month,
        SUM(o.amount)                     AS total_sales
    FROM sales_orders o
    JOIN sales_reps r ON o.rep_id = r.rep_id
    WHERE o.status = 'paid'
    GROUP BY r.rep_name, DATE_TRUNC('month', o.order_date)
)
SELECT
    rep_name,
    sale_month,
    total_sales,
    LAG(total_sales) OVER (
        PARTITION BY rep_name
        ORDER BY sale_month
    )                           AS prev_month_sales,
    total_sales - LAG(total_sales) OVER (
        PARTITION BY rep_name
        ORDER BY sale_month
    )                           AS mom_change
FROM monthly_sales
ORDER BY rep_name, sale_month;

-- Common trap: no PARTITION BY in the LAG() window.
-- Without it, LAG() looks at the previous row in the entire result —
-- rep B's "previous month" becomes rep A's last month.
-- The numbers look roughly plausible. Nobody notices until QA.


-- ── S4: DEDUPLICATION ────────────────────────────────────────

WITH ranked_orders AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC
        ) AS rn
    FROM sales_orders
)
SELECT *
FROM ranked_orders
WHERE rn = 1;

-- Common trap: using DISTINCT or GROUP BY when you need
-- the full row, not just a deduplicated key.
-- DISTINCT only works when every column in the duplicate is identical.
-- ROW_NUMBER() keeps the full row — use it whenever you need
-- all the columns from the winning row.


-- ── S5: ANTI-JOIN ────────────────────────────────────────────

WITH paid_this_month AS (
    SELECT DISTINCT rep_id
    FROM sales_orders
    WHERE status = 'paid'
      AND DATE_TRUNC('month', order_date) = DATE_TRUNC('month', CURRENT_DATE)
)
SELECT
    r.rep_id,
    r.rep_name,
    r.region
FROM sales_reps r
LEFT JOIN paid_this_month p ON r.rep_id = p.rep_id
WHERE p.rep_id IS NULL
ORDER BY r.region, r.rep_name;

-- Common trap: using NOT IN instead of LEFT JOIN + IS NULL.
-- NOT IN breaks silently when the subquery returns any NULL —
-- the entire result becomes empty. No error. Just zero rows.
-- LEFT JOIN + IS NULL or NOT EXISTS are always safe.


-- ── S6: TOP N PER GROUP ──────────────────────────────────────

WITH rep_totals AS (
    SELECT
        r.rep_name,
        r.region,
        SUM(o.amount) AS total_sales
    FROM sales_reps r
    LEFT JOIN sales_orders o
        ON r.rep_id = o.rep_id AND o.status = 'paid'
    GROUP BY r.rep_name, r.region
),
ranked AS (
    SELECT
        rep_name,
        region,
        total_sales,
        DENSE_RANK() OVER (
            PARTITION BY region
            ORDER BY total_sales DESC NULLS LAST
        ) AS rnk
    FROM rep_totals
)
SELECT rep_name, region, total_sales, rnk
FROM ranked
WHERE rnk <= 2
ORDER BY region, rnk;

-- Common trap: trying to filter WHERE rnk <= 2 in the same
-- SELECT where the window function is computed.
-- SQL evaluates SELECT aliases after WHERE, so the column
-- doesn't exist yet at filter time. Always push it to a CTE or subquery.


-- ── S7: COHORT LOGIC ─────────────────────────────────────────

WITH rep_cohorts AS (
    SELECT
        rep_id,
        DATE_TRUNC('month', hire_date) AS hire_cohort
    FROM sales_reps
),
cohort_sales AS (
    SELECT
        rc.hire_cohort,
        COUNT(DISTINCT rc.rep_id)                                AS reps_in_cohort,
        COALESCE(SUM(o.amount), 0)                               AS total_sales,
        ROUND(COALESCE(SUM(o.amount), 0) /
              COUNT(DISTINCT rc.rep_id), 2)                      AS avg_sales_per_rep
    FROM rep_cohorts rc
    LEFT JOIN sales_orders o
        ON rc.rep_id = o.rep_id AND o.status = 'paid'
    GROUP BY rc.hire_cohort
)
SELECT *
FROM cohort_sales
ORDER BY hire_cohort;

-- Common trap: joining before defining the cohort.
-- If you join first and then try to group by hire month,
-- you risk incorrect row counts and messy aggregation logic.
-- Define the cohort cleanly in a CTE first — then aggregate.


-- ── S8: CONDITIONAL AGGREGATION ─────────────────────────────

SELECT
    r.rep_name,
    r.region,
    SUM(CASE WHEN o.status = 'paid'      THEN o.amount ELSE 0 END) AS paid_total,
    SUM(CASE WHEN o.status = 'pending'   THEN o.amount ELSE 0 END) AS pending_total,
    SUM(CASE WHEN o.status = 'cancelled' THEN o.amount ELSE 0 END) AS cancelled_total,
    COUNT(o.order_id)                                               AS total_orders
FROM sales_reps r
LEFT JOIN sales_orders o ON r.rep_id = o.rep_id
GROUP BY r.rep_name, r.region
ORDER BY paid_total DESC NULLS LAST;

-- Common trap: filtering WHERE status = 'paid' before aggregating.
-- That returns one status per query. The CASE goes inside the
-- aggregate — not in the WHERE clause. Same logic as Excel's SUMIF.
-- Use ELSE 0 in SUM (not ELSE NULL) so empty values show 0, not NULL.


-- ── S9: HAVING vs WHERE ──────────────────────────────────────

SELECT
    r.rep_name,
    r.region,
    COUNT(o.order_id) AS paid_order_count
FROM sales_reps r
JOIN sales_orders o
    ON r.rep_id = o.rep_id
   AND o.status = 'paid'
   AND DATE_TRUNC('month', o.order_date) = DATE_TRUNC('month', CURRENT_DATE)
GROUP BY r.rep_name, r.region
HAVING COUNT(o.order_id) > 2
ORDER BY paid_order_count DESC;

-- Common trap: putting COUNT(order_id) > 2 in the WHERE clause.
-- WHERE cannot reference aggregate functions — it runs before
-- GROUP BY, so the aggregation hasn't happened yet.
-- WHERE = filter rows IN. HAVING = filter aggregated results OUT.


-- ── S10: CHAINED CTEs ────────────────────────────────────────

WITH paid_this_month AS (
    SELECT rep_id, amount
    FROM sales_orders
    WHERE status = 'paid'
      AND DATE_TRUNC('month', order_date) = DATE_TRUNC('month', CURRENT_DATE)
),
rep_summary AS (
    SELECT
        r.rep_id,
        r.rep_name,
        r.region,
        COUNT(p.amount)                AS deal_count,
        COALESCE(SUM(p.amount), 0)     AS total_sales,
        ROUND(COALESCE(AVG(p.amount), 0), 2) AS avg_deal_size
    FROM sales_reps r
    LEFT JOIN paid_this_month p ON r.rep_id = p.rep_id
    GROUP BY r.rep_id, r.rep_name, r.region
),
region_avg AS (
    SELECT
        region,
        ROUND(AVG(total_sales), 2) AS region_avg_sales
    FROM rep_summary
    GROUP BY region
),
ranked AS (
    SELECT
        rs.rep_name,
        rs.region,
        rs.deal_count,
        rs.total_sales,
        rs.avg_deal_size,
        ra.region_avg_sales,
        DENSE_RANK() OVER (
            PARTITION BY rs.region
            ORDER BY rs.total_sales DESC NULLS LAST
        ) AS region_rank
    FROM rep_summary rs
    JOIN region_avg ra ON rs.region = ra.region
)
SELECT
    region,
    rep_name,
    deal_count,
    total_sales,
    avg_deal_size,
    region_avg_sales,
    ROUND(total_sales - region_avg_sales, 2) AS vs_region_avg
FROM ranked
WHERE region_rank = 1
ORDER BY region;

-- Common trap: trying to do this in one or two steps.
-- Nesting the rank inside the aggregation, or trying to compute
-- the region average in the same CTE as the rep totals,
-- leads to incorrect results or query errors.
-- Four CTEs, each doing one job, is cleaner and easier to debug.
-- Debug by commenting out everything after rep_summary and
-- running SELECT * FROM rep_summary — check before adding steps.
