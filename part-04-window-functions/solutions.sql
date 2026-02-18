/* =========================================
PART 4 — WINDOW FUNCTIONS
Dataset:
employee_id | employee_name | department | sales | month
========================================= */


/* Q1: Rank employees by sales (overall) */

SELECT 
    employee_id,
    employee_name,
    department,
    sales,
    RANK() OVER (ORDER BY sales DESC) AS sales_rank
FROM sales;


/* Q2: Rank employees within each department */

SELECT 
    employee_id,
    employee_name,
    department,
    sales,
    RANK() OVER (
        PARTITION BY department
        ORDER BY sales DESC
    ) AS dept_rank
FROM sales;


/* Q3: Find top 3 employees per department */

SELECT *
FROM (
    SELECT 
        employee_id,
        employee_name,
        department,
        sales,
        ROW_NUMBER() OVER (
            PARTITION BY department
            ORDER BY sales DESC
        ) AS row_num
    FROM sales
) ranked
WHERE row_num <= 3;


/* Q4: Create running total of sales by month */

SELECT 
    month,
    SUM(sales) AS monthly_sales,
    SUM(SUM(sales)) OVER (
        ORDER BY month
    ) AS running_total
FROM sales
GROUP BY month
ORDER BY month;


/* Q5: Compare each employee’s sales to department average */

SELECT 
    employee_id,
    employee_name,
    department,
    sales,
    sales - AVG(sales) OVER (
        PARTITION BY department
    ) AS difference_from_dept_avg
FROM sales;

