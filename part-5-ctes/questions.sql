-- ============================================================
-- SQL for Data Analysts — Part 5: CTEs
-- practice/questions.sql
-- ============================================================
-- Try each question yourself before looking at solutions.sql
-- Run setup.sql first if you haven't already.
-- ============================================================


-- ── QUESTION 1 ───────────────────────────────────────────────
-- Write a single CTE called paid_this_month that contains
-- all paid orders from the current month.
--
-- Then query it to return:
--   - rep_name
--   - region
--   - total paid sales (aliased as total_sales)
--   - number of deals (aliased as deal_count)
--
-- Order by total_sales descending.

-- YOUR ANSWER:




-- ── QUESTION 2 ───────────────────────────────────────────────
-- Chain two CTEs:
--   1. emea_orders — all paid orders from reps in the EMEA region
--   2. emea_summary — total sales and deal count per rep, using emea_orders
--
-- Final query: return rep_name, total_sales, deal_count
-- from emea_summary, ordered by total_sales descending.
--
-- Hint: you'll need to join sales_reps somewhere to get the region.
-- Decide which CTE is the right place for that join.

-- YOUR ANSWER:




-- ── QUESTION 3 ───────────────────────────────────────────────
-- Use the LEFT JOIN + IS NULL pattern with a CTE to find
-- every rep who had zero PAID orders this month.
--
-- Return: rep_id, rep_name, region
-- Order by region, then rep_name.
--
-- Expected: you should see at least Dana Kovacs and Lin Wei.
-- Think about whether Tariq Al-Amin should appear — why or why not?

-- YOUR ANSWER:




-- ── QUESTION 4 (bonus — recursive) ──────────────────────────
-- Using the employees table, write a recursive CTE that returns
-- everyone in the organisation with their level in the hierarchy.
--
-- Then modify it: filter the final result to show only
-- level 3 employees (two levels below the top).
--
-- Return: emp_name, title, level
-- Order by emp_name.

-- YOUR ANSWER:
