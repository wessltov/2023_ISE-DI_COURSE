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
		DATEDIFF(YEAR, born, GETDATE()) > 18
	);
GO

/*TESTING*/
BEGIN TRANSACTION
	-- Testparameters
	DECLARE @youngestAllowed DATE = DATEADD(YEAR, -18, GETDATE());
	
	SELECT TOP 0
		born
	,	hired
	INTO #testBed
	FROM emp;

	ALTER TABLE #testBed
		ADD DEFAULT GETDATE() FOR hired;

	ALTER TABLE #testBed
	ADD CONSTRAINT ck_noChildLabor
		CHECK( --Can't be employee if you don't be aged > 18
			DATEDIFF(DAY, DATEADD(YEAR, 18, born), hired) >= 0 AND 
			(
				DATEDIFF(YEAR, born, hired) != 0 OR 
				SQUARE(MONTH(hired)) + SQUARE(MONTH(born)) != 8 OR DAY(born) != 29 OR ( --If false, born and hired months are both 2, so days need to be compared
					DAY(hired) > DAY(born)
				) 
			) --Negative condition to account for leap years; DATEDIFF considers feb 29 in years that have that date equal to feb 28 in years that don't
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
