--DROP TRIGGER trgOFFR_TrainersOnlyOneCourseATime

CREATE OR ALTER TRIGGER trgOFFR_TrainersOnlyOneCourseATime
ON dbo.OFFR
AFTER INSERT, UPDATE AS
BEGIN
	IF @@ROWCOUNT = 0
		RETURN 
    SET NOCOUNT ON 
	BEGIN TRY

		IF EXISTS (
						SELECT COUNT(o.trainer), o.starts, o.trainer
						FROM offr o
						INNER JOIN inserted i
						ON i.trainer = o.trainer
						GROUP BY o.starts, o.trainer
						HAVING COUNT(o.trainer) >1
																			)

		BEGIN
			;THROW 50001, 'Trainer already has another course at this start date', 1
		END
	END TRY	
	BEGIN CATCH
		;THROW	
	END CATCH
END
GO

-- Test de trigger / moet error terug geven, combinatie van datum en trainer bestaat al
BEGIN TRANSACTION

INSERT INTO OFFR
VALUES ('APEX', '1997-09-06', 'CONF', 6, 1017, 'TEST')

SELECT *
FROM offr
WHERE trainer = 1017
AND starts = '1997-09-06'
ORDER BY starts asc

ROLLBACK TRANSACTION