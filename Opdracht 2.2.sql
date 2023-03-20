CREATE VIEW VW_ListExactSameSetOfCourseRegistrations AS
SELECT e.ename, r.stud, r.course, r.starts
FROM REG r
INNER JOIN EMP e
ON e.empno = r.stud
WHERE EXISTS ( 
				SELECT COUNT(*)
				FROM REG 
				WHERE starts = r.starts
				AND course = r.course
				HAVING COUNT(*) > 1
			)
ORDER BY starts
