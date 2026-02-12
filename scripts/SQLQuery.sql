---------------------------------------CHECKS---------------------------------------
USE MyDatabase;
SELECT * FROM data_analyst_jobs;

-- Total rows
SELECT COUNT(*) AS total_rows
FROM data_analyst_jobs;

-- Check nulls in key fields
SELECT
    SUM(CASE WHEN salary_year_avg IS NULL THEN 1 ELSE 0 END) AS null_salary,
    SUM(CASE WHEN country IS NULL OR country = '' THEN 1 ELSE 0 END) AS null_country,
    SUM(CASE WHEN posted_date IS NULL THEN 1 ELSE 0 END) AS null_date
FROM data_analyst_jobs;

-------------------------------------CHECKS OVER-------------------------------------

-------------------------------------KPI QUERIES-------------------------------------

--TOTAL JOBS IN DATA
SELECT COUNT(*) AS total_jobs
FROM data_analyst_jobs;


--ONSITE VS REMOTE JOB COUNT
SELECT
    is_remote,
    COUNT(*) AS job_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM data_analyst_jobs
GROUP BY is_remote;


--AVG, MIN, MAX SALARIES
SELECT
    AVG(salary_year_avg) AS avg_salary,
    MIN(salary_year_avg) AS min_salary,
    MAX(salary_year_avg) AS max_salary
FROM data_analyst_jobs
WHERE salary_year_avg IS NOT NULL;


--SKILL DEMAND PERCENTAGE FOR DATA ANALYST JOBS
SELECT
    ROUND(AVG(CAST(sql AS FLOAT))*100,2) AS sql_pct,
    ROUND(AVG(CAST(python AS FLOAT))*100,2) AS python_pct,
    ROUND(AVG(CAST(excel AS FLOAT))*100,2) AS excel_pct,
    ROUND(AVG(CAST(tableau AS FLOAT))*100,2) AS tableau_pct,
    ROUND(AVG(CAST(r AS FLOAT))*100,2) AS r_pct,
    ROUND(AVG(CAST(power_bi AS FLOAT))* 100,2) AS powerbi_pct
FROM data_analyst_jobs;


--SALARY BY SKILL DEMAND
SELECT 'SQL' AS skill, AVG(salary_year_avg) AS avg_salary
FROM data_analyst_jobs WHERE sql = 1 AND salary_year_avg IS NOT NULL
UNION ALL
SELECT 'Python', AVG(salary_year_avg)
FROM data_analyst_jobs WHERE python = 1 AND salary_year_avg IS NOT NULL
UNION ALL
SELECT 'Excel', AVG(salary_year_avg)
FROM data_analyst_jobs WHERE excel = 1 AND salary_year_avg IS NOT NULL
UNION ALL
SELECT 'Tableau', AVG(salary_year_avg)
FROM data_analyst_jobs WHERE tableau = 1 AND salary_year_avg IS NOT NULL
UNION ALL
SELECT 'R', AVG(salary_year_avg)
FROM data_analyst_jobs WHERE r = 1 AND salary_year_avg IS NOT NULL
UNION ALL
SELECT 'Power BI', AVG(salary_year_avg)
FROM data_analyst_jobs WHERE power_bi = 1 AND salary_year_avg IS NOT NULL;


--COUNTRY ANALYSIS BY JOBS
SELECT country,
       COUNT(*) AS job_count,
       AVG(salary_year_avg) AS avg_salary
FROM data_analyst_jobs
GROUP BY country
ORDER BY job_count DESC;


--DEGREE REQUIREMENT ANALYSIS
SELECT
    no_degree_required,
    COUNT(*) AS job_count,
    AVG(salary_year_avg) AS avg_salary
FROM data_analyst_jobs
GROUP BY no_degree_required;


--TIME TREND ANALYSIS
SELECT
    posted_date,
    COUNT(*) AS job_count
FROM data_analyst_jobs
GROUP BY posted_date
ORDER BY posted_date;


-----------------------------------KPI QUERIES OVER-----------------------------------

-------------------------------------IMPORTANT KPI------------------------------------

--VIEWS FOR THE IMPORTANT KPI

--MARKET OVERVIEW
ALTER VIEW v_market_overview AS
SELECT
    COUNT(*) AS total_jobs,
    ROUND(AVG(CAST(is_remote AS FLOAT)),3)  AS remote_pct,
    AVG(salary_year_avg) AS avg_salary,
    ROUND(AVG(CAST(no_degree_required AS FLOAT)),3) AS no_degree_pct
FROM data_analyst_jobs;

SELECT * FROM v_market_overview;


--SKILL DEMAND VIEW

ALTER VIEW v_skill_demand_long AS
WITH total_jobs AS (
    SELECT COUNT(*) AS total
    FROM data_analyst_jobs
)
SELECT 'SQL' AS skill,
       CAST(COUNT(*) AS FLOAT) / (SELECT total FROM total_jobs) AS demand_pct
FROM data_analyst_jobs
WHERE sql = 1

UNION ALL
SELECT 'Python',
       CAST(COUNT(*) AS FLOAT) / (SELECT total FROM total_jobs)
FROM data_analyst_jobs
WHERE python = 1

UNION ALL
SELECT 'Excel',
       CAST(COUNT(*) AS FLOAT)/ (SELECT total FROM total_jobs)
FROM data_analyst_jobs
WHERE excel = 1

UNION ALL
SELECT 'Tableau',
       CAST(COUNT(*) AS FLOAT)/ (SELECT total FROM total_jobs)
FROM data_analyst_jobs
WHERE tableau = 1

UNION ALL
SELECT 'R',
       CAST(COUNT(*) AS FLOAT)/ (SELECT total FROM total_jobs)
FROM data_analyst_jobs
WHERE r = 1

UNION ALL
SELECT 'Power BI',
       CAST(COUNT(*) AS FLOAT)/ (SELECT total FROM total_jobs)
FROM data_analyst_jobs
WHERE power_bi = 1;

SELECT * FROM v_skill_demand_long;


--AVG, MIN, MAX SALARY VIEW
CREATE VIEW v_amm_salary AS
SELECT
    ROUND(AVG(salary_year_avg),0) AS avg_salary,
    MIN(salary_year_avg) AS min_salary,
    MAX(salary_year_avg) AS max_salary
FROM data_analyst_jobs
WHERE salary_year_avg IS NOT NULL;

SELECT * FROM v_amm_salary;




--SALARY BY SKILL VIEW
CREATE VIEW v_salary_by_skill AS
SELECT 'SQL' AS skill, AVG(salary_year_avg) AS avg_salary
FROM data_analyst_jobs WHERE sql = 1 AND salary_year_avg IS NOT NULL
UNION ALL
SELECT 'Python', AVG(salary_year_avg)
FROM data_analyst_jobs WHERE python = 1 AND salary_year_avg IS NOT NULL
UNION ALL
SELECT 'Excel', AVG(salary_year_avg)
FROM data_analyst_jobs WHERE excel = 1 AND salary_year_avg IS NOT NULL
UNION ALL
SELECT 'Tableau', AVG(salary_year_avg)
FROM data_analyst_jobs WHERE tableau = 1 AND salary_year_avg IS NOT NULL
UNION ALL
SELECT 'R', AVG(salary_year_avg)
FROM data_analyst_jobs WHERE r = 1 AND salary_year_avg IS NOT NULL
UNION ALL
SELECT 'Power BI', AVG(salary_year_avg)
FROM data_analyst_jobs WHERE power_bi = 1 AND salary_year_avg IS NOT NULL;

SELECT * FROM v_salary_by_skill;


--REMOTE VS ONSITE SALARY VIEW
CREATE VIEW v_remote_salary AS
SELECT
    is_remote,
    COUNT(*) AS job_count,
    AVG(salary_year_avg) AS avg_salary
FROM data_analyst_jobs
WHERE salary_year_avg IS NOT NULL
GROUP BY is_remote;

SELECT * FROM v_remote_salary;


--GEOGRAPHY VIEW
CREATE VIEW v_geography AS
SELECT
    country,
    COUNT(*) AS job_count,
    AVG(salary_year_avg) AS avg_salary
FROM data_analyst_jobs
GROUP BY country;

SELECT * FROM v_geography;


--TIME TRENDS
CREATE VIEW v_time_trend AS
SELECT
    FORMAT(posted_date, 'yyyy-MM') AS posted_month,
    COUNT(*) AS job_count
FROM data_analyst_jobs
GROUP BY FORMAT(posted_date, 'yyyy-MM');

SELECT * FROM v_time_trend;



----------------------------------IMPORTANT KPI---------------------------------