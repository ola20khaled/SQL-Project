-- Cleaning the data

-- Changing the dates data type
UPDATE HumanResources
SET birthdate =
	CASE
    WHEN birthdate LIKE '%-%-%'
    	THEN FORMAT(CAST(birthdate AS datetime), 'MM-dd-yyyy')
    WHEN birthdate LIKE '%/%/%'
    	THEN FORMAT(CAST(birthdate AS datetime), 'MM-dd-yyyy')
    ELSE NULL
    END;

UPDATE HumanResources
SET hire_date =
	CASE
    WHEN hire_date LIKE '%-%-%'
    	THEN FORMAT(CAST(hire_date AS datetime), 'MM-dd-yyyy')
    WHEN hire_date LIKE '%/%/%'
    	THEN FORMAT(CAST(hire_date AS datetime), 'MM-dd-yyyy')
    ELSE NULL
    END;

ALTER TABLE HumanResources
ALTER COLUMN birthdate date;

ALTER TABLE HumanResources
ALTER COLUMN hire_date date;

UPDATE HumanResources
SET termdate = CAST(REPLACE(termdate, ' UTC', ' ') AS datetime)
WHERE termdate IS NOT NULL AND termdate != ' ';

ALTER TABLE HumanResources
ALTER COLUMN termdate datetime;

UPDATE HumanResources
SET termdate = NULL
WHERE CAST(termdate AS datetime) = '1900-01-01 00:00:00';

SELECT *
FROM HumanResources;

-- Check for duplicates
SELECT id, COUNT(*)
FROM HumanResources
GROUP by id
HAVING COUNT(*) > 1;

-- Checking the birthdates range
SELECT MIN(birthdate) as youngest, MAX(birthdate) AS oldest
FROM HumanResources;

-- Exploring the gender
SELECT gender, COUNT(*)
FROM HumanResources
GROUP BY gender;

-- Exploring the races
SELECT race, COUNT(*)
FROM HumanResources
GROUP BY race
ORDER BY COUNT(*);

-- Exploring the departments
SELECT department, COUNT(*)
FROM HumanResources
GROUP BY department
ORDER BY COUNT(*);

-- Exploring the locations
SELECT location, COUNT(*)
FROM HumanResources
GROUP BY location
ORDER BY COUNT(*);

-- Which department has the more jobs in
SELECT department, jobtitle, COUNT(*)
FROM HumanResources
GROUP BY department, jobtitle
ORDER BY department, COUNT(*) DESC;

-- How many years in average do the employees stay in the company?
SELECT AVG(DATEDIFF(year, hire_date, termdate)) AS average_employee_duration
FROM HumanResources
WHERE termdate IS NOT NULL AND termdate <= GETDATE();

-- What is the gender variation in the departments?
SELECT department, gender, COUNT(*)
FROM HumanResources
GROUP BY department, gender
ORDER BY department, COUNT(*) DESC;

-- Which department has the highest turnover rate?
SELECT department, total_count, terminated_count,
	   CAST(terminated_count AS DECIMAL(10,2)) / total_count AS termination_rate
FROM (
  SELECT department, COUNT(*) AS total_count,
  SUM(CASE WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1 ELSE 0 END ) AS terminated_count
  FROM HumanResources
  GROUP BY department) AS Subquery
ORDER BY termination_rate DESC;

-- Know the location city and the employee location status
SELECT location_city, location, COUNT(*)
FROM HumanResources
GROUP BY location_city, location
ORDER BY COUNT(*) DESC;

-- The employees distribution over the years
SELECT year, hires, terminations, hires - terminations AS net_change,
	CONCAT(ROUND(((CAST(hires - terminations AS DECIMAL(10,2)) / hires) * 100), 2), '%') AS net_change_percent
FROM (
  SELECT year(hire_date) as year,
  		COUNT(*) AS hires,
  		SUM(CASE WHEN termdate IS NOT NULL AND termdate <= GETDATE() THEN 1 ELSE 0 END ) AS terminations
  FROM HumanResources
  GROUP BY year(hire_date)
  ) AS Subquery
 ORDER BY year;