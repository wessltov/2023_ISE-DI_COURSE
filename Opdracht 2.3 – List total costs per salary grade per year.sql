/*Task 2.3 – List total costs per salary grade per year
The cost per salary grade is calculated by the yearly salary of all employees of this grade. The yearly salary is based on the monthly salary plus the yearly bonus as defined per grade. 
Give a list of all the salary grades, the total salary costs per salary grade (the bonus included) per year and also give a running total. 
Use one or more windowing functions or CTE operators.

The header of this view should be:
CREATE VIEW VW_ListTotalCostsPerSalaryGradePerYear 
*/
USE COURSE;
GO


--CREATE OR ALTER VIEW VW_ListTotalCostsPerSalaryGradePerYear(grade, annual_costs, running_total) AS
WITH cte_totalPerGrade(grade, annual) AS (
	SELECT
		g.grade
	,	SUM(e.msal * 12 + g.bonus) AS [total]		-- 2. Within each salary grade, sum up every emp's salary, multiply by months in a year, add bonus
	FROM emp AS [e]
		RIGHT JOIN grd [g]
		ON e.sgrade = g.grade
	GROUP BY g.grade	-- 1. Group all emps by salary grade
),
intermediary(
	grade
,	annual
,	running
) AS (
SELECT
	tpg.grade
,	tpg.annual
,	(
		LAG(tpg.annual, 1, 0) OVER(ORDER BY tpg.grade) + 
		annual
	) AS [running]		-- 3. Add a running count
FROM cte_totalPerGrade AS [tpg]
),
final AS (
SELECT
	tpg.grade
,	tpg.annual
,	(
		LAG(tpg.running, 1, 0) OVER(ORDER BY tpg.grade) + 
		annual
	) AS [running]
FROM intermediary AS [tpg]
)
SELECT *,
	IIF(
		(
			running < LAG(running, 1) OVER(ORDER BY grade)
		), 
		'ERROR!',
		''
	) AS [ERROR_DETECTED],
	SUM(running) OVER()
FROM final


;WITH 
base AS(
	SELECT
		g.grade
	,	e.msal
	,	g.bonus
	FROM emp AS [e]
	RIGHT JOIN grd AS [g]
		ON e.sgrade = g.grade
	--WHERE g.grade = (SELECT MIN(grade) FROM grd)

),
rec(grade, annual, running) AS(
	SELECT
		grade
	,	SUM(msal * 12 + bonus) OVER(PARTITION BY grade) AS [annual]
	,	SUM(msal * 12 + bonus) OVER(PARTITION BY grade) AS [running]

	FROM base 
	WHERE grade = (SELECT MIN(grade) FROM grd)
	GROUP BY grade

	UNION ALL

	SELECT
		b.grade
	,	SUM(msal * 12 + bonus) OVER(PARTITION BY grade) AS [annual]
	,	rec.running + (
			SUM(msal * 12 + bonus) OVER(PARTITION BY grade) + 
			LAG(rec.running) OVER(ORDER BY b.grade)
		) AS [running]
	FROM base AS b
	INNER JOIN rec
		ON b.grade = rec.grade
	WHERE b.grade != (SELECT MIN(grade) FROM grd)
	GROUP BY b.grade
)
SELECT * FROM rec



