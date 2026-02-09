-- Count employees per department
SELECT department, COUNT(*)
FROM employees
GROUP BY department;

-- Average salary by department
SELECT department, AVG(salary)
FROM employees
GROUP BY department;

-- Departments with avg salary > 60000
SELECT department, AVG(salary)
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;

-- Total payroll per department
SELECT department, SUM(salary)
FROM employees
GROUP BY department;

-- Salary bands
SELECT name,
CASE
  WHEN salary >= 80000 THEN 'High'
  WHEN salary >= 60000 THEN 'Medium'
  ELSE 'Low'
END AS salary_band
FROM employees;
