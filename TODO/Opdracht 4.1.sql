--Aantal courses die door de verschillende trainers worden gegeven
SELECT e.empno, e.ename, e.job, o.trainer, COUNT(o.course) [Aantal courses]
FROM EMP e
INNER JOIN OFFR o
ON o.trainer = e.empno
WHERE job = 'TRAINER'
GROUP BY e.empno, e.ename, e.job, o.trainer
ORDER BY empno;

--Courses die door een trainer worden gegeven met de duration in dagen
SELECT e.empno, e.ename, e.job, o.trainer, o.course, o.starts, c.dur
FROM EMP e
INNER JOIN OFFR o
ON o.trainer = e.empno
INNER JOIN CRS c
ON c.code = o.course
WHERE job = 'TRAINER'
ORDER BY empno;


--Stored Procedure
CREATE PROCEDURE spTrainersCantTeachSimul
				@EMPNO		NUMERIC(4,0),
				@STARTDATE	DATETIME,
				@DURATION	NUMERIC(2,0)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
			SELECT e.empno 
			FROM EMP e
			INNER JOIN OFFR o
			ON o.trainer = e.empno
			INNER JOIN CRS c
			ON c.code = o.course
			WHERE empno = @EMPNO
			AND starts != @STARTDATE
        BEGIN
            ;THROW 50001, 'Foutmelding', 1
        END
    END TRY
    BEGIN CATCH
        ;THROW
    END CATCH
END
