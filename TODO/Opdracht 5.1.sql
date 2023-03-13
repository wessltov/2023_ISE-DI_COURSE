CREATE TRIGGER EMP_TRAINER
	ON EMP
AFTER INSERT
AS
BEGIN
	DECLARE @EMPNO NUMERIC(4,0)
	IF @@ROWCOUNT=0
RETURN
    SET NOCOUNT ON
    IF EXISTS 
        (SELECT empno
         FROM EMP
         WHERE empno = @EMPNO
		 AND job = 'TRAINER'
		 AND DATEDIFF(year, hired, GETDATE()) >= 1)
	OR EXISTS	
		(SELECT stud
		 FROM REG
		 WHERE stud = @EMPNO)
    BEGIN
        ; THROW 50000, 'Foutje, bedankt', 1
    END             
END
