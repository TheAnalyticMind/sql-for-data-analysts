-- ============================================================
-- SQL for Data Analysts — Part 5: CTEs
-- practice/solutions.sql
-- ============================================================
-- Try questions.sql first. Seriously.
-- ============================================================


-- ── SOLUTION 1 ───────────────────────────────────────────────
-- A single CTE, then aggregate in the outer query

WITH paid_this_month AS (
    SELECT
        o.rep_id,
        o.amount
    FROM sales_orders o
    WHERE o.status = 'paid'
      AND DATE_TRUNC('month', o.order_date) = DATE_TRUNC('month', CURRENT_DATE)
)
SELECT
    r.rep_name,
    r.region,
    SUM(p.amount)  AS total_sales,
    COUNT(p.rep_id) AS deal_count
FROM sales_reps r
LEFT JOIN paid_this_month p ON r.rep_id = p.rep_id
GROUP BY r.rep_name, r.region
ORDER BY total_sales DESC NULLS LAST;

-- Note: NULLS LAST keeps reps with zero paid orders at the bottom
-- instead of sorting them to the top (NULL sorts high by default in PostgreSQL).


-- ── SOLUTION 2 ───────────────────────────────────────────────
-- Chain two CTEs — join to sales_reps in the first CTE
-- so the region filter is clean and the second CTE is pure aggregation

WITH emea_orders AS (
    -- Filter to EMEA paid orders; bring in rep info here
    SELECT
        r.rep_id,
        r.rep_name,
        o.amount
    FROM sales_orders o
    INNER JOIN sales_reps r ON o.rep_id = r.rep_id
    WHERE r.region = 'EMEA'
      AND o.status = 'paid'
),

emea_summary AS (
    SELECT
        rep_id,
        rep_name,
        SUM(amount)   AS total_sales,
        COUNT(amount)  AS deal_count
    FROM emea_orders
    GROUP BY rep_id, rep_name
)
SELECT
    rep_name,
    total_sales,
    deal_count
FROM emea_summary
ORDER BY total_sales DESC;

-- Expected: James Okafor and Sophie Laurent (the two EMEA reps with paid orders)


-- ── SOLUTION 3 ───────────────────────────────────────────────
-- CTE defines who was active (paid orders) this month
-- Outer query finds who's NOT in that list

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

-- About Tariq Al-Amin (rep 8):
-- He has two orders this month — but both are 'pending'.
-- Because we filter to status = 'paid' in the CTE, he doesn't appear
-- in paid_this_month, so he shows up here as having zero PAID orders.
-- That's intentional — this is a question about paid activity, not all activity.
-- If you want to exclude him, change the CTE to: WHERE status IN ('paid', 'pending')
-- Decide based on the business question you're actually answering.


-- ── SOLUTION 4 ───────────────────────────────────────────────
-- Full org chart, then filter to level 3

WITH RECURSIVE org_chart AS (

    -- Base case: top of the tree
    SELECT
        emp_id,
        emp_name,
        title,
        manager_id,
        1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive step: everyone who reports into the current set
    SELECT
        e.emp_id,
        e.emp_name,
        e.title,
        e.manager_id,
        oc.level + 1
    FROM employees e
    INNER JOIN org_chart oc ON e.manager_id = oc.emp_id

)
SELECT
    emp_name,
    title,
    level
FROM org_chart
WHERE level = 3
ORDER BY emp_name;

-- Expected at level 3 (two levels below the CRO):
-- Dev Anand, Karan Johar, Maya Goldstein, Sana Mirza, Sophie Laurent
--
-- The full hierarchy for reference:
-- Level 1: Priya Sharma (CRO)
-- Level 2: Arjun Mehta, Carlos Reyes, Meera Pillai
-- Level 3: Dana Kovacs, Dev Anand, Karan Johar, Maya Goldstein, Sana Mirza, Sophie Laurent
-- Level 4: Aisha Nair, James Okafor, Lin Wei, Tariq Al-Amin
