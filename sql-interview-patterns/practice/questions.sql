-- ============================================================
-- SQL Interview Patterns — Practice Questions
-- ============================================================
-- Write each query yourself before opening solutions.sql.
-- Run setup.sql first if you haven't already.
-- ============================================================


-- ── Q1: RUNNING TOTALS ───────────────────────────────────────
-- Show each rep's paid orders in date order with a running
-- total of sales. Each rep's running total should reset
-- independently — not accumulate across all reps.
--
-- Return: rep_name, order_date, amount, running_total
-- Order by: rep_name, order_date

-- YOUR ANSWER:




-- ── Q2: RANK WITHIN GROUP ────────────────────────────────────
-- Rank reps by total paid sales within each region.
-- Use DENSE_RANK() so tied reps share the same rank.
-- Include reps with zero paid orders — they should rank last.
--
-- Return: rep_name, region, total_sales, region_rank
-- Order by: region, region_rank

-- YOUR ANSWER:




-- ── Q3: MONTH-OVER-MONTH CHANGE ──────────────────────────────
-- Show each rep's total paid sales by month, and how that
-- changed versus the previous month.
-- The first month per rep will have NULL for the change — that's correct.
--
-- Return: rep_name, sale_month, total_sales, prev_month_sales, mom_change
-- Order by: rep_name, sale_month

-- YOUR ANSWER:




-- ── Q4: DEDUPLICATION ────────────────────────────────────────
-- The sales_orders table has some customers with multiple orders.
-- Return only each customer's most recent order (by order_date).
-- If a customer has one order, they still appear.
--
-- Return: all columns from sales_orders, one row per customer
-- Hint: ROW_NUMBER(), not DISTINCT

-- YOUR ANSWER:




-- ── Q5: ANTI-JOIN ────────────────────────────────────────────
-- Find every rep who had zero paid orders this month.
-- Use LEFT JOIN + IS NULL (not NOT IN).
--
-- Return: rep_id, rep_name, region
-- Order by: region, rep_name

-- YOUR ANSWER:




-- ── Q6: TOP N PER GROUP ──────────────────────────────────────
-- Return the top 2 reps by total paid sales in each region.
-- If two reps tie for 2nd, both should appear.
--
-- Return: rep_name, region, total_sales, rank
-- Order by: region, rank

-- YOUR ANSWER:




-- ── Q7: COHORT LOGIC ─────────────────────────────────────────
-- Group reps by the month they were hired (their hire cohort).
-- For each cohort, show: how many reps are in it, their
-- combined paid sales, and average paid sales per rep.
--
-- Return: hire_cohort, reps_in_cohort, total_sales, avg_sales_per_rep
-- Order by: hire_cohort

-- YOUR ANSWER:




-- ── Q8: CONDITIONAL AGGREGATION ─────────────────────────────
-- Show each rep's paid, pending, and cancelled order amounts
-- in a single row. Also show their total order count.
--
-- Return: rep_name, region, paid_total, pending_total, cancelled_total, total_orders
-- Order by: paid_total descending

-- YOUR ANSWER:




-- ── Q9: HAVING vs WHERE ──────────────────────────────────────
-- Find reps who closed more than 2 paid orders this month.
-- Use HAVING, not a subquery or CTE.
--
-- Return: rep_name, region, paid_order_count
-- Order by: paid_order_count descending

-- YOUR ANSWER:




-- ── Q10: CHAINED CTEs ────────────────────────────────────────
-- For each region, return the top rep by paid sales this month.
-- Include: their deal count, average deal size, the region average
-- sales, and how far above or below the region average they are.
-- Use at least 3 chained CTEs. Say your steps out loud first.
--
-- Return: region, rep_name, deal_count, total_sales,
--         avg_deal_size, region_avg_sales, vs_region_avg
-- Order by: region

-- YOUR ANSWER:
