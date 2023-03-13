/*Task 3.2 – Company hires adult personnel only 
Implement and test the constraint ‘the company hires adult personnel only’
*/
USE COURSE;
GO

ALTER TABLE emp
DROP CONSTRAINT IF EXISTS ck_noChildLabor;
GO

ALTER TABLE emp
ADD CONSTRAINT ck_noChildLabor
	CHECK (	--Can't be employee if you don't be aged > 18
		DATEADD(YEAR, 18, born) < GETDATE()
	);
GO

/*TESTING*/
-- Testparameters
DECLARE @youngestAllowed DATE = DATEADD(YEAR, -18, GETDATE());

BEGIN TRANSACTION
	SELECT TOP 0
		born
	,	hired
	INTO #testBed
	FROM emp;

	ALTER TABLE #testBed
		ADD DEFAULT GETDATE() FOR hired;

	ALTER TABLE #testBed
	ADD CONSTRAINT ck_noChildLabor
		CHECK (	--Can't be employee if you don't be aged > 18
			DATEADD(YEAR, 18, born) < GETDATE()
		);

	SAVE TRANSACTION mature
		PRINT('Expecting succes - Employee 18 today');

		INSERT INTO #testBed(born)
		VALUES(@youngestAllowed);
	ROLLBACK TRANSACTION mature

	SAVE TRANSACTION underAge
		PRINT('Expecting failure - Employee 18 tomorrow');
	
		INSERT INTO #testBed(born)
		VALUES(DATEADD(DAY, 1, @youngestAllowed));
	ROLLBACK TRANSACTION underage
ROLLBACK TRANSACTION
GO
