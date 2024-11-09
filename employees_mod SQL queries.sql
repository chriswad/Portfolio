-- Aiming to create a breakdown between male and female employees working in the company each year starting in 1990
SELECT emp_no, from_date, to_date
FROM t_dept_emp;

SELECT DISTINCT emp_no, from_date, to_date
FROM t_dept_emp;


SELECT YEAR(d.from_date) AS calendar_year, 
		e.gender, 
		COUNT(e.emp_no) AS num_of_employees
FROM t_employees e
	JOIN
	t_dept_emp d ON d.emp_no = e.emp_no
GROUP BY calendar_year, e.gender
HAVING calendar_year >= 1990;


-- Aiming to compare the number of male managers to the number of female managers from different departments for each year starting in 1990
-- Managers may have switched departments so need to create an extra field to know if a manager worked in a particular department in year x and not year y
SELECT
	d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
		WHEN YEAR(dm.to_date) >= e.calendar_year AND YEAR(dm.from_date) <= e.calendar_year THEN 1
        ELSE 0
	END AS Active
FROM
	(SELECT YEAR(hire_date) AS calendar_year
	FROM t_employees
	GROUP BY calendar_year) e
		CROSS JOIN t_dept_manager dm
		JOIN t_departments d ON dm.dept_no = d.dept_no
		JOIN t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no, calendar_year;

SELECT
	d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
		WHEN YEAR(dm.to_date) >= e.calendar_year AND YEAR(dm.from_date) <= e.calendar_year THEN 1
        ELSE 0
	END AS Active
FROM
	(SELECT YEAR(hire_date) AS calendar_year
	FROM t_employees
	GROUP BY calendar_year) e
		CROSS JOIN t_dept_manager dm
		JOIN t_departments d ON dm.dept_no = d.dept_no
		JOIN t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no, calendar_year;

SELECT *
FROM
	(SELECT YEAR(hire_date) AS calendar_year
	FROM t_employees
	GROUP BY calendar_year) e
		CROSS JOIN t_dept_manager dm
		JOIN t_departments d ON dm.dept_no = d.dept_no
		JOIN t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no, calendar_year;


-- Aiming to compare average salaries of female vs male employees overall and by department
SELECT
	e.gender, 
    d.dept_name, 
    ROUND(AVG(s.salary), 2) AS salary,
    YEAR(s.from_date) AS calendar_year
FROM t_salaries s 
	JOIN t_employees e ON s.emp_no = e.emp_no
    JOIN t_dept_emp de ON de.emp_no = e.emp_no
    JOIN t_departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no, e.gender, calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no;


-- Aiming to create a stored procedure that obtains the average male and female salary by departmnet within a certain salary range 
DROP PROCEDURE IF EXISTS filter_salary;

DELIMITER $$
CREATE PROCEDURE filter_salary (IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
SELECT e.gender, d.dept_name, AVG(s.salary) AS avg_salary
FROM t_salaries s
		JOIN t_employees e ON s.emp_no = e.emp_no
		JOIN t_dept_emp de ON de.emp_no = e.emp_no
		JOIN t_departments d ON d.dept_no = de.dept_no
	WHERE s.salary BETWEEN p_min_salary AND p_max_salary
GROUP BY d.dept_no, e.gender;
END $$

DELIMITER ;

CALL filter_salary(50000, 90000);
