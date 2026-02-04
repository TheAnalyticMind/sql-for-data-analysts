-- 1
SELECT name, salary FROM employees;

-- 2
SELECT * FROM employees WHERE salary > 60000;

-- 3
SELECT * FROM employees ORDER BY salary DESC;

-- 4
SELECT * FROM employees ORDER BY salary DESC LIMIT 3;

-- 5
SELECT COUNT(*) FROM employees WHERE department = 'Sales';
