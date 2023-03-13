/*Task 6.2 – Implement Unit tests for a declarative constraint 
Implement unit tests for one of the information needs as mentioned in chapter 3. Choose one yourself.
*/
USE COURSE;
GO

EXECUTE tSQLt.NewTestClass 'testDeclarativeConstraints_3-1';
GO


-- Testcase for allowd row
CREATE OR ALTER PROCEDURE [testDeclarativeConstraints_3-1].[test for president earning more than 10000]
AS BEGIN
	/*Arrange*/
	EXECUTE tSQLt.FakeTable 'emp';
	EXECUTE tSQLt.ApplyConstraint 
		@TableName = 'emp'
	,	@ConstraintName = 'ck_presEarnsOverTenTon';

	/*Assert*/
	EXECUTE tSQLt.ExpectNoException;

	/*Act*/
	INSERT INTO emp([job], [msal])
	VALUES('PRESIDENT', 10001);
END;
GO

--Run tests for this functionality
EXECUTE tSQLt.RunTestClass 'testDeclarativeConstraints_3-1';





/*

w

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
*/
