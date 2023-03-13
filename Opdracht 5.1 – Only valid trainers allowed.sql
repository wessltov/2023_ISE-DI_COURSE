
USE COURSE
GO


CREATE OR ALTER TRIGGER tr_allowOnlyValidTrainers ON offr
AFTER INSERT, UPDATE
AS BEGIN
	IF(@@ROWCOUNT < 1) RETURN;
	SET NOCOUNT ON;
	
	BEGIN TRY
		
		IF(UPDATE(trainer) AND UPDATE(COURSE) AND EXISTS(
			SELECT trainer, course
			FROM inserted
			EXCEPT
			SELECT empno, code
			FROM VW_ListTheValidTrainers	
		)) THROW;


	END TRY
	BEGIN CATCH

		;THROW 50001, 'Set contains illegal trainers!', 1;
	END CATCH

END
GO
