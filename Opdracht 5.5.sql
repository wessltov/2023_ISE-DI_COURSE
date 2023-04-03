CREATE OR ALTER TRIGGER trgOFFR_TrainersOnlyOneCourseATime
ON dbo.OFFR
AFTER INSERT, UPDATE AS
BEGIN
	IF @@ROWCOUNT = 0
		RETURN 
    SET NOCOUNT ON 
	BEGIN TRY

		IF EXISTS 
		(
			select *
			from 
				(select e.empno, SUM(c.dur) as [total duration],
			sum(CASE
				WHEN o.loc = d.loc THEN 0
				WHEN o.loc != d.loc THEN (c.dur)
			END) AS [total duration not home]
			from emp e
			inner join dept d
			on d.deptno = e.deptno
			inner join offr o 
			on e.empno = o.trainer
			inner join crs c 
			on c.code = o.course
			group by e.empno
			) as totalDur
			where [total duration]/2 > [total duration not home]
		)

		BEGIN
			;THROW 50001, 'At least half of the course offerings must be ‘home based’. ', 1
		END
	END TRY	
	BEGIN CATCH
		;THROW	
	END CATCH
END
GO