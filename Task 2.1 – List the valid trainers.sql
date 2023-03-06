/*Task 2.1 – List the valid trainers
Give a list of all offered courses that are given by a valid trainer. A valid trainer is:
1)	someone whose job is trainer and who is at least one year an employee in this organization,
2)	or someone who has attended this course (as a participant). 

Return the empno and ename of the trainer and the course code and course description of the applicable courses.
Use one or more set operators or exists operators.
The header of this view should be:
CREATE VIEW VW_ListTheValidTrainers
*/
USE COURSE;
GO

CREATE OR ALTER VIEW VW_ListTheValidTrainers(empno, ename, code, [desc]) AS
	SELECT 
		e.empno,
		e.ename,
		c.code,
		c.descr
	FROM offr o
		INNER JOIN emp e
		ON o.trainer = e.empno
		INNER JOIN crs c
		ON o.course = c.code
	WHERE 
		(--Scenario 1: Someone whose job is trainer and who is at least one year an employee in this organization
			job LIKE 'TRAINER' AND	--Employee is a trainer
			DATEDIFF(YEAR, hired, GETDATE()) >= 1 AND	--Employee has been on for at least a year. Maybe rewrite to require > 1 year CONTINUOUS employment?
			NOT EXISTS(	--Employee wasn't fired (without being rehired)
				SELECT 1
				FROM term t
				WHERE 
					t.empno = e.empno AND
					e.hired < t.leftcomp
			)
		) AND
		o.[status] NOT LIKE 'CANC%'	--Exclude cancelled courses
UNION	
	SELECT 
		e.empno,
		e.ename,
		c.code,
		c.descr
	FROM offr o
		INNER JOIN emp e
		ON o.trainer = e.empno
		INNER JOIN crs c
		ON o.course = c.code
	WHERE EXISTS (--Scenario 2: Someone who has attended this course (as a participant).
		SELECT 1
		FROM reg r
		WHERE 
			(--Subquery association anchor
				r.stud = o.trainer AND
				r.course = o.course
			) AND
			DATEADD(DAY, c.dur, r.starts) < GETDATE() AND	--Require course completion
			o.[status] NOT LIKE 'CANC%'	--Exclude cancelled courses
	);
GO
	

--Use one or more set operators or exists operators!

