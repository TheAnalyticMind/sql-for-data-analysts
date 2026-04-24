-- ============================================================
-- SQL for Data Analysts — Part 6: Interview Patterns
-- examples/all_10_patterns.sql
-- ============================================================
-- The 10 SQL patterns that show up in analyst interviews.
-- Each pattern has: the business question, the query,
-- and what to watch out for.
-- ============================================================
-- Run data/setup.sql first before trying any of these.
-- ============================================================


-- ============================================================
-- PATTERN 1: Running Totals
-- ============================================================
-- Business question: show each rep's paid orders in date order
-- with a running total of sales next to each row.

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

-- Common trap: leaving out ORDER BY inside OVER() turns this
-- into a partition total — every row returns the same number.
-- The query runs, looks plausible, and is wrong.


-- ============================================================
-- PATTERN 2: Rank Within a Group
-- ============================================================
-- Business question: rank reps by total paid sales within
-- each region. Include reps with zero orders — they rank last.

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

-- RANK() skips numbers after a tie: 1, 2, 2, 4
-- DENSE_RANK() doesn't skip:        1, 2, 2, 3
-- ROW_NUMBER() ignores ties:        1, 2, 3, 4
-- For "top N" questions use DENSE_RANK(). Interviewers
-- put ties in the dataset deliberately to catch this.


-- ============================================================
-- PATTERN 3: Month-over-Month Change with LAG()
-- ============================================================
-- Business question: show each rep's total paid sales by month
-- and how that changed versus the previous month.

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
    )                    AS prev_month_sales,
    total_sales - LAG(total_sales) OVER (
        PARTITION BY rep_name
        ORDER BY sale_month
    )                    AS mom_change
FROM monthly_sales
ORDER BY rep_name, sale_month;

-- Common trap: no PARTITION BY in the LAG() window.
-- Without it, LAG() bleeds across reps — rep B's "previous
-- month" becomes rep A's last row. Silent wrong answer.


-- ============================================================
-- PATTERN 4: Deduplication with ROW_NUMBER()
-- ============================================================
-- Business question: the orders table has duplicate rows for
-- some customers. Keep only the most recent order per customer.

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

-- Same pattern, different business questions:
-- "First purchase per customer"  →  ORDER BY order_date ASC
-- "Latest login per user"        →  ORDER BY login_time DESC
-- "Highest order per customer"   →  ORDER BY amount DESC
--
-- Common trap: using DISTINCT when you need the full row.
-- DISTINCT only works when every column in the duplicate is identical.


-- ============================================================
-- PATTERN 5: Anti-Join — Finding What's Missing
-- ============================================================
-- Business question: which reps have zero paid orders
-- this month?

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
-- the entire result becomes empty with no error.
-- Always use LEFT JOIN + IS NULL or NOT EXISTS instead.


-- ============================================================
-- PATTERN 6: Top N per Group
-- ============================================================
-- Business question: return the top 2 reps by paid sales
-- in each region. If two reps tie for 2nd, both appear.

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

-- Common trap: filtering WHERE rnk <= 2 in the same SELECT
-- where the window function is computed. SQL evaluates window
-- functions after WHERE — the column doesn't exist yet.
-- Always push the filter to an outer query or CTE.


-- ============================================================
-- PATTERN 7: Cohort Logic
-- ============================================================
-- Business question: group reps by hire month and show total
-- paid sales and average sales per rep for each cohort.

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
-- Define the cohort cleanly in a CTE first, then aggregate.
-- Get the order wrong and you get incorrect counts.


-- ============================================================
-- PATTERN 8: Conditional Aggregation — SUM(CASE WHEN)
-- ============================================================
-- Business question: show each rep's paid, pending, and
-- cancelled order totals in a single row.

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

-- Common trap: using WHERE status = 'paid' before aggregating.
-- That returns one status per query. The CASE goes INSIDE
-- the aggregate — not in the WHERE clause.
-- This is SQL's version of Excel's SUMIF.


-- ============================================================
-- PATTERN 9: HAVING vs WHERE
-- ============================================================
-- Business question: find reps who closed more than 2 paid
-- orders this month.

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

-- The one sentence that makes this stick:
-- WHERE decides which rows go INTO the aggregation.
-- HAVING decides which aggregated results come OUT.
--
-- Common trap: putting COUNT(...) > 2 in the WHERE clause.
-- WHERE runs before GROUP BY — the aggregation hasn't
-- happened yet, so it throws an error.


-- ============================================================
-- PATTERN 10: Chained CTEs — The Full Business Question
-- ============================================================
-- Business question: for each region, show the top rep by
-- paid sales this month, their deal count, average deal size,
-- and how their total compares to the region average.

WITH paid_this_month AS (
    -- Step 1: scope to paid orders this month
    SELECT rep_id, amount
    FROM sales_orders
    WHERE status = 'paid'
      AND DATE_TRUNC('month', order_date) = DATE_TRUNC('month', CURRENT_DATE)
),
rep_summary AS (
    -- Step 2: one row per rep with key metrics
    SELECT
        r.rep_id,
        r.rep_name,
        r.region,
        COUNT(p.amount)                      AS deal_count,
        COALESCE(SUM(p.amount), 0)           AS total_sales,
        ROUND(COALESCE(AVG(p.amount), 0), 2) AS avg_deal_size
    FROM sales_reps r
    LEFT JOIN paid_this_month p ON r.rep_id = p.rep_id
    GROUP BY r.rep_id, r.rep_name, r.region
),
region_avg AS (
    -- Step 3: region-level benchmark
    SELECT
        region,
        ROUND(AVG(total_sales), 2) AS region_avg_sales
    FROM rep_summary
    GROUP BY region
),
ranked AS (
    -- Step 4: rank within region + attach benchmark
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
-- Step 5: top rep per region only
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
-- Four CTEs, each doing one job, is the right structure.
-- Debug tip: comment out everything after rep_summary,
-- run SELECT * FROM rep_summary — check numbers before
-- adding the next step. That's the real workflow.
