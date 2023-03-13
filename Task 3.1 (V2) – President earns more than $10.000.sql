/*3.1	Task 3.1 – President earns more than $10.000
Implement and test the constraint ‘the president of the company earns more than $10.000 monthly’.
*/
USE COURSE;
GO

ALTER TABLE emp
DROP CONSTRAINT IF EXISTS ck_presEarnsOverTenTon;
GO

ALTER TABLE emp
ADD CONSTRAINT ck_presEarnsOverTenTon
	CHECK (	--Can''t be president if you don''t earn > 10000
		msal > 10000 OR
		job != 'PRESIDENT'
	);
GO

/*TESTING*/
BEGIN TRANSACTION
	-- Testparameters
	SELECT TOP 0
		job
	,	msal
	INTO #testBed
	FROM emp;

	-- Tried using https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-executesql-transact-sql?view=sql-server-ver16 to dynamically apply constraint to both emp and #testBed, couldn't do it.
	ALTER TABLE #testBed
	ADD CONSTRAINT ck_presEarnsOverTenTon
		CHECK (	--Can''t be president if you don''t earn > 10000
			msal > 10000 OR
			job != 'PRESIDENT'
		);

	SAVE TRANSACTION richPresident
		PRINT('Expecting succes - President earning > 10000');

		INSERT INTO #testBed(job, msal)
		VALUES('PRESIDENT', 10001);
	ROLLBACK TRANSACTION richPresident

	SAVE TRANSACTION poorPresident
		PRINT('Expecting failure - President earning <= 10000');
	
		INSERT INTO #testBed(job, msal)
		VALUES('PRESIDENT', 10000);
	ROLLBACK TRANSACTION poorPresident
	
	SAVE TRANSACTION richRandom
		PRINT('Expecting succes - Random job earning > 10000');
		
		INSERT INTO #testBed(job, msal)
		VALUES('COOK', 10001);
	ROLLBACK TRANSACTION richRandom

	SAVE TRANSACTION regularRandom
		PRINT('Expecting succes - Random job earning <= 10000');
		
		INSERT INTO #testBed(job, msal)
		VALUES('COOK', 10000);
	ROLLBACK TRANSACTION regularRandom
ROLLBACK TRANSACTION
GO
