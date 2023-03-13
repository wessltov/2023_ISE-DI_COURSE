CREATE VIEW VW_ListTotalCostsPerSalaryGradePerYear AS

WITH [totalSalary] AS 
( 
	SELECT sgrade, SUM(msal) * 12 AS TotalSalary
	FROM emp
	GROUP BY sgrade
),
[totalYearSalary] AS
(
	SELECT g.bonus+t.TotalSalary AS TotalYearSalary
	FROM grd g
	INNER JOIN totalSalary t
	ON g.grade = sgrade
),
[runningTotal] AS
(
	SELECT SUM(TotalYearSalary) AS RunningTotal
	FROM totalYearSalary
)

SELECT *
FROM [totalSalary]
UNION ALL
SELECT *, 0
FROM [totalYearSalary]
UNION ALL
SELECT *, 0
FROM [runningTotal]
