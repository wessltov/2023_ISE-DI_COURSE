DROP TRIGGER IF EXISTS trgEMP_AdminForDepartment
GO
CREATE TRIGGER trgEMP_AdminForDepartment
ON dbo.EMP
AFTER INSERT, UPDATE, DELETE AS
BEGIN
	IF @@ROWCOUNT = 0
		RETURN 
    SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS (	
							SELECT *
							FROM EMP e
							INNER JOIN inserted i
							ON i.deptno = e.deptno
							INNER JOIN deleted d
							ON d.deptno = e.deptno
							WHERE e.deptno = i.deptno
							OR e.deptno = d.deptno
							AND e.job = 'ADMIN'
														)
		BEGIN
			;THROW 50001, 'At least one admin should be employed at this department', 1
		END
	END TRY	
	BEGIN CATCH
		;THROW	
	END CATCH
END
GO

-- Testen / moet error terug geven, er moet minstens 1 admin verbonden zijn aan dit departement. 
BEGIN TRANSACTION

INSERT INTO DEPT
VALUES (99, 'TEST', 'TEST', 1001)

UPDATE emp
SET deptno = 99
WHERE empno = 1001

ROLLBACK TRANSACTION
