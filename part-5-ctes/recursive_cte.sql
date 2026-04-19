-- ============================================================
-- SQL for Data Analysts — Part 5: CTEs
-- examples/recursive_cte.sql
-- Org chart hierarchy using a recursive CTE
-- ============================================================
-- Use this when: you have a table where rows point back
-- to other rows in the same table (manager_id, parent_id, etc.)
-- ============================================================
-- Supported by: PostgreSQL, Snowflake, BigQuery, SQL Server,
--               MySQL 8.0+, SQLite 3.35+
-- ============================================================


-- ── WHAT THE DATA LOOKS LIKE ─────────────────────────────────
-- Run this first to see the raw table
SELECT emp_id, emp_name, title, manager_id
FROM employees
ORDER BY emp_id;


-- ── THE RECURSIVE CTE ────────────────────────────────────────
-- Business question: show the full org chart with each
-- person's level in the hierarchy

WITH RECURSIVE org_chart AS (

    -- Base case: start at the top (no manager)
    SELECT
        emp_id,
        emp_name,
        title,
        manager_id,
        1 AS level,
        emp_name::TEXT AS reporting_path   -- start the path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive step: find everyone who reports to someone
    -- already in our result set, go one level deeper
    SELECT
        e.emp_id,
        e.emp_name,
        e.title,
        e.manager_id,
        oc.level + 1,
        (oc.reporting_path || ' → ' || e.emp_name)::TEXT
    FROM employees e
    INNER JOIN org_chart oc ON e.manager_id = oc.emp_id

)
SELECT
    REPEAT('    ', level - 1) || emp_name  AS org_structure,
    title,
    level,
    reporting_path
FROM org_chart
ORDER BY reporting_path;


-- ── FIND EVERYONE WHO REPORTS TO A SPECIFIC PERSON ───────────
-- Business question: who is in Arjun Mehta's org? (emp_id = 2)

WITH RECURSIVE arjun_org AS (

    SELECT emp_id, emp_name, title, manager_id, 1 AS level
    FROM employees
    WHERE emp_id = 2   -- Arjun Mehta

    UNION ALL

    SELECT e.emp_id, e.emp_name, e.title, e.manager_id, ao.level + 1
    FROM employees e
    INNER JOIN arjun_org ao ON e.manager_id = ao.emp_id
)
SELECT
    REPEAT('    ', level - 1) || emp_name AS org_structure,
    title,
    level
FROM arjun_org
ORDER BY level, emp_name;


-- ── HOW THE RECURSION WORKS ──────────────────────────────────
--
-- Round 1 (base case):   Priya Sharma (level 1, no manager)
-- Round 2 (recursive):   Arjun, Meera, Carlos (they report to Priya)
-- Round 3 (recursive):   Dev, Sana, Karan, Sophie, Maya, Dana (report to round 2)
-- Round 4 (recursive):   Aisha, Lin, James, Tariq (report to round 3)
-- Round 5:               No more rows found. Recursion stops.
--
-- The database keeps running the recursive step until
-- it finds no new rows to add.
