
CREATE DATABASE IF NOT EXISTS global_tech_analysis;
USE global_tech_analysis;


SHOW TABLES;
SELECT COUNT(*) AS total_jobs
FROM tech_jobs_;
USE global_tech_analysis;

SELECT *
FROM tech_jobs_
LIMIT 10;
SELECT COUNT(*) AS total_jobs
FROM tech_jobs_;
SELECT COUNT(*) FROM tech_jobs_;

SELECT
    COUNT(*) AS total_jobs,
    ROUND(AVG(average_salary), 2) AS avg_salary,
    ROUND(MIN(average_salary), 2) AS min_salary,
    ROUND(MAX(average_salary), 2) AS max_salary
FROM tech_jobs_;

SELECT
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(average_salary), 2) AS avg_salary
FROM tech_jobs_
GROUP BY job_title
HAVING COUNT(*) >= 10
ORDER BY avg_salary DESC
LIMIT 10;

SELECT
    job_title,
    COUNT(*) AS job_count
FROM tech_jobs_
GROUP BY job_title
ORDER BY job_count DESC
LIMIT 10;

SELECT
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(average_salary), 2) AS avg_salary
FROM tech_jobs_
GROUP BY job_title
HAVING COUNT(*) >= 10
ORDER BY job_count DESC;

SELECT
    job_title,
    COUNT(*) AS job_count,
    ROUND(AVG(average_salary), 2) AS avg_salary,
    CASE
        WHEN AVG(average_salary) >= 150000 THEN 'High Salary'
        WHEN AVG(average_salary) >= 110000 THEN 'Medium Salary'
        ELSE 'Low Salary'
    END AS salary_category
FROM tech_jobs_
GROUP BY job_title
HAVING COUNT(*) >= 10
ORDER BY avg_salary DESC;

WITH job_salary AS (
    SELECT
        job_title,
        COUNT(*) AS job_count,
        ROUND(AVG(average_salary), 2) AS avg_salary
    FROM tech_jobs_
    GROUP BY job_title
)

SELECT
    job_title,
    job_count,
    avg_salary
FROM job_salary
WHERE avg_salary > (
    SELECT AVG(average_salary)
    FROM tech_jobs_
)
ORDER BY avg_salary DESC;

WITH job_salary AS (
    SELECT
        job_title,
        COUNT(*) AS job_count,
        AVG(average_salary) AS avg_salary
    FROM tech_jobs_
    GROUP BY job_title
    HAVING COUNT(*) >= 10
)

SELECT
    job_title,
    job_count,
    ROUND(avg_salary, 2) AS avg_salary,
    RANK() OVER (ORDER BY avg_salary DESC) AS salary_rank
FROM job_salary
ORDER BY salary_rank;

WITH location_salary AS (
    SELECT
        location,
        COUNT(*) AS job_count,
        AVG(average_salary) AS avg_salary
    FROM tech_jobs_
    GROUP BY location
    HAVING COUNT(*) >= 10
)

SELECT
    location,
    job_count,
    ROUND(avg_salary, 2) AS avg_salary,
    RANK() OVER (ORDER BY avg_salary DESC) AS salary_rank
FROM location_salary
ORDER BY salary_rank
LIMIT 15;
WITH RECURSIVE tech_split AS (
    SELECT
        job_id,
        TRIM(SUBSTRING_INDEX(tech_stack, ',', 1)) AS technology,
        SUBSTRING(
            tech_stack,
            LENGTH(SUBSTRING_INDEX(tech_stack, ',', 1)) + 2
        ) AS remaining
    FROM tech_jobs_

    UNION ALL

    SELECT
        job_id,
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)) AS technology,
        CASE
            WHEN remaining LIKE '%,%'
            THEN SUBSTRING(
                remaining,
                LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2
            )
            ELSE ''
        END AS remaining
    FROM tech_split
    WHERE remaining <> ''
)

SELECT
    technology,
    COUNT(DISTINCT job_id) AS job_count
FROM tech_split
WHERE technology <> ''
GROUP BY technology
ORDER BY job_count DESC
LIMIT 15;

WITH RECURSIVE tech_split AS (
    SELECT
        job_id,
        average_salary,
        TRIM(SUBSTRING_INDEX(tech_stack, ',', 1)) AS technology,
        CASE
            WHEN tech_stack LIKE '%,%'
            THEN SUBSTRING(
                tech_stack,
                LENGTH(SUBSTRING_INDEX(tech_stack, ',', 1)) + 2
            )
            ELSE ''
        END AS remaining
    FROM tech_jobs_

    UNION ALL

    SELECT
        job_id,
        average_salary,
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)) AS technology,
        CASE
            WHEN remaining LIKE '%,%'
            THEN SUBSTRING(
                remaining,
                LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2
            )
            ELSE ''
        END AS remaining
    FROM tech_split
    WHERE remaining <> ''
),

technology_salary AS (
    SELECT
        technology,
        COUNT(DISTINCT job_id) AS job_count,
        AVG(average_salary) AS avg_salary
    FROM tech_split
    WHERE technology <> ''
    GROUP BY technology
)

SELECT
    technology,
    job_count,
    ROUND(avg_salary, 2) AS avg_salary
FROM technology_salary
WHERE job_count >= 50
ORDER BY avg_salary DESC
LIMIT 15;