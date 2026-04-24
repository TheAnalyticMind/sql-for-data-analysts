-- ============================================================
-- SQL for Data Analysts — Part 5: CTEs
-- setup.sql — Run this first to create tables and load data
-- ============================================================
-- Works with: PostgreSQL, Snowflake, BigQuery (see notes below)
-- ============================================================


-- ── CLEAN SLATE ─────────────────────────────────────────────
DROP TABLE IF EXISTS sales_orders;
DROP TABLE IF EXISTS sales_reps;
DROP TABLE IF EXISTS employees;


-- ── TABLE 1: SALES REPS ─────────────────────────────────────
CREATE TABLE sales_reps (
    rep_id    INT PRIMARY KEY,
    rep_name  VARCHAR(100),
    region    VARCHAR(50),
    hire_date DATE
);

INSERT INTO sales_reps VALUES
    (1,  'Aisha Nair',      'APAC',  '2021-03-15'),
    (2,  'James Okafor',    'EMEA',  '2020-07-01'),
    (3,  'Priya Menon',     'APAC',  '2022-01-10'),
    (4,  'Carlos Reyes',    'AMER',  '2019-11-20'),
    (5,  'Sophie Laurent',  'EMEA',  '2023-02-28'),
    (6,  'Ravi Shankar',    'APAC',  '2021-09-05'),
    (7,  'Maya Goldstein',  'AMER',  '2020-04-14'),
    (8,  'Tariq Al-Amin',   'EMEA',  '2022-06-30'),
    (9,  'Lin Wei',         'APAC',  '2023-08-01'),
    (10, 'Dana Kovacs',     'AMER',  '2021-12-15');


-- ── TABLE 2: SALES ORDERS ───────────────────────────────────
CREATE TABLE sales_orders (
    order_id    INT PRIMARY KEY,
    customer_id INT,
    rep_id      INT,
    order_date  DATE,
    amount      NUMERIC(10, 2),
    status      VARCHAR(20)   -- 'paid', 'pending', 'cancelled'
);

INSERT INTO sales_orders VALUES
-- Aisha Nair (rep 1) — strong month
    (1001, 201, 1, CURRENT_DATE - INTERVAL '5 days',  4200.00, 'paid'),
    (1002, 202, 1, CURRENT_DATE - INTERVAL '12 days', 8750.00, 'paid'),
    (1003, 203, 1, CURRENT_DATE - INTERVAL '18 days', 3100.00, 'paid'),
    (1004, 204, 1, CURRENT_DATE - INTERVAL '22 days', 1500.00, 'pending'),

-- James Okafor (rep 2)
    (1005, 205, 2, CURRENT_DATE - INTERVAL '3 days',  6400.00, 'paid'),
    (1006, 206, 2, CURRENT_DATE - INTERVAL '9 days',  2200.00, 'paid'),
    (1007, 207, 2, CURRENT_DATE - INTERVAL '25 days', 4900.00, 'cancelled'),

-- Priya Menon (rep 3)
    (1008, 208, 3, CURRENT_DATE - INTERVAL '7 days',  11200.00, 'paid'),
    (1009, 209, 3, CURRENT_DATE - INTERVAL '14 days',  5600.00, 'paid'),

-- Carlos Reyes (rep 4) — top performer
    (1010, 210, 4, CURRENT_DATE - INTERVAL '2 days',  15300.00, 'paid'),
    (1011, 211, 4, CURRENT_DATE - INTERVAL '8 days',   9800.00, 'paid'),
    (1012, 212, 4, CURRENT_DATE - INTERVAL '16 days',  7200.00, 'paid'),
    (1013, 213, 4, CURRENT_DATE - INTERVAL '20 days',  3400.00, 'pending'),

-- Sophie Laurent (rep 5) — new, one small deal
    (1014, 214, 5, CURRENT_DATE - INTERVAL '10 days',  1800.00, 'paid'),

-- Ravi Shankar (rep 6)
    (1015, 215, 6, CURRENT_DATE - INTERVAL '4 days',   5500.00, 'paid'),
    (1016, 216, 6, CURRENT_DATE - INTERVAL '19 days',  2900.00, 'paid'),

-- Maya Goldstein (rep 7)
    (1017, 217, 7, CURRENT_DATE - INTERVAL '6 days',   8100.00, 'paid'),
    (1018, 218, 7, CURRENT_DATE - INTERVAL '11 days',  4300.00, 'cancelled'),
    (1019, 219, 7, CURRENT_DATE - INTERVAL '23 days',  6700.00, 'paid'),

-- Tariq Al-Amin (rep 8) — pending only
    (1020, 220, 8, CURRENT_DATE - INTERVAL '15 days',  3300.00, 'pending'),
    (1021, 221, 8, CURRENT_DATE - INTERVAL '27 days',  2100.00, 'pending'),

-- Lin Wei (rep 9) — no orders this month (older date)
    (1022, 222, 9, CURRENT_DATE - INTERVAL '45 days',  4400.00, 'paid'),

-- Dana Kovacs (rep 10) — zero orders, nothing in table
-- (intentionally absent — useful for LEFT JOIN + IS NULL practice)


-- ── TABLE 3: EMPLOYEES (for recursive CTE) ──────────────────
CREATE TABLE employees (
    emp_id     INT PRIMARY KEY,
    emp_name   VARCHAR(100),
    title      VARCHAR(100),
    manager_id INT  -- NULL means this person is the top of the tree
);

INSERT INTO employees VALUES
    (1,  'Priya Sharma',   'Chief Revenue Officer',    NULL),
    (2,  'Arjun Mehta',    'VP Sales — APAC',          1),
    (3,  'Meera Pillai',   'VP Sales — EMEA',          1),
    (4,  'Carlos Reyes',   'VP Sales — AMER',          1),
    (5,  'Dev Anand',      'Regional Manager',         2),
    (6,  'Sana Mirza',     'Regional Manager',         2),
    (7,  'Karan Johar',    'Regional Manager',         3),
    (8,  'Sophie Laurent', 'Account Executive',        3),
    (9,  'Aisha Nair',     'Account Executive',        5),
    (10, 'Lin Wei',        'Account Executive',        5),
    (11, 'James Okafor',   'Account Executive',        7),
    (12, 'Tariq Al-Amin',  'Account Executive',        7),
    (13, 'Maya Goldstein', 'Senior Account Executive', 4),
    (14, 'Dana Kovacs',    'Account Executive',        4);


-- ── VERIFY ──────────────────────────────────────────────────
SELECT 'sales_reps'   AS tbl, COUNT(*) AS rows FROM sales_reps
UNION ALL
SELECT 'sales_orders' AS tbl, COUNT(*) AS rows FROM sales_orders
UNION ALL
SELECT 'employees'    AS tbl, COUNT(*) AS rows FROM employees;

-- Expected output:
-- sales_reps    | 10
-- sales_orders  | 22
-- employees     | 14
