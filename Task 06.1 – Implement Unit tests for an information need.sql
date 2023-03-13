/*Task 6.1 – Implement Unit tests for an information need
Implement unit tests for one of the information needs as mentioned in chapter 2. Choose one yourself.
*/
USE COURSE;
GO

EXECUTE tSQLt.NewTestClass 'testInformationNeeds_2-1';
GO


-- Testcase where none are valid
CREATE OR ALTER PROCEDURE [testInformationNeeds_2-1].[test for when no valid training offers exist]
AS BEGIN
	/*Arrange*/
		
	--Testbed
	EXECUTE tSQLt.FakeTable	'offr';
	EXECUTE tSQLt.FakeTable	'crs';
	EXECUTE tSQLt.FakeTable 'reg';
	EXECUTE tSQLt.FakeTable 'emp';
	EXECUTE tSQLt.FakeTable 'term';		--Don't want any of the guineapigs accidentally existing and having been fired

	--Testdata
		/* Offers:
			1: Fledgling trainer
			2: Still ongoing
			3: Cancelled
			4: Jobless instructor
		*/
	
	INSERT INTO crs([code], [dur])
	VALUES ('tstcrs', 3);

	INSERT INTO emp([empno], [job], [hired])
	VALUES
		(1, 'TRAINER',	GETDATE())						-- Fledgling trainer
	,	(2, 'STUDENT',	NULL)							-- Still enrolled
	,	(3, 'TRAINER',	DATEADD(YEAR, -10, GETDATE()))	-- Cancelled
	,	(4, NULL,		DATEADD(YEAR, -10, GETDATE()))	-- A nobody
	;

	INSERT INTO offr([trainer], [course], [starts])
		SELECT 
			empno
		,	(SELECT TOP 1 code FROM crs)
		,	DATEADD(DAY, -10, GETDATE())
		FROM emp;
		
		UPDATE offr
		SET starts = DATEADD(DAY, -1, GETDATE())
		WHERE trainer = 2;	-- Still enrolled

		UPDATE offr
		SET [status] = 'CANC'
		WHERE trainer = 3;	-- Cancelled
	
	
	INSERT INTO reg([stud], [course], [starts])
		SELECT
			trainer
		,	course
		,	starts
		FROM offr
		WHERE trainer = 2;	-- Still enrolled

	/*Act*/
	DROP TABLE IF EXISTS #results;
	
	SELECT * INTO #results
	FROM VW_ListTheValidTrainers;
	
	/*Assert*/
	EXECUTE tSQLt.AssertEmptyTable '#results';
END;
GO

-- Testcase for trainer by trade with one year experience
CREATE OR ALTER PROCEDURE [testInformationNeeds_2-1].[test for offers by employees whose jobs are trainer and who have at least one year of employment]
AS BEGIN
	/*Arrange*/		
	--Testbed
	EXECUTE tSQLt.FakeTable	'offr';
	EXECUTE tSQLt.FakeTable 'emp';
	EXECUTE tSQLt.FakeTable 'crs';
	EXECUTE tSQLt.FakeTable 'term';		--Don't want the guineapig accidentally existing and having been fired

	--Testdata
	
	INSERT INTO crs([code])
	VALUES ('tstcrs');
	
	INSERT INTO emp([empno], [job], [hired])
	VALUES (1, 'TRAINER', DATEADD(YEAR, -1, GETDATE()));
	
	INSERT INTO offr([trainer], [course])
		SELECT 
			empno
		,	(SELECT TOP 1 code FROM crs)
		FROM emp;
		
	DROP TABLE IF EXISTS #expected;
	SELECT * INTO #expected
	FROM VW_ListTheValidTrainers
	WHERE 1 = 0

	/*Act*/
	DROP TABLE IF EXISTS #results;
	
	SELECT * INTO #actual
	FROM VW_ListTheValidTrainers;
	
	/*Assert*/
	EXECUTE tSQLt.AssertEqualsTable 
		@Expected = '#expected'
	,	@Actual = '#actual';
END;
GO

-- Testcase for unofficial trainer who completed a course
CREATE OR ALTER PROCEDURE [testInformationNeeds_2-1].[test for offers by employees who have attended this course as a participant]
AS BEGIN
	/*Arrange*/		
	--Testbed
	EXECUTE tSQLt.FakeTable	'offr';
	EXECUTE tSQLt.FakeTable 'emp';
	EXECUTE tSQLt.FakeTable 'crs';
	EXECUTE tSQLt.FakeTable 'reg';

	--Testdata
	INSERT INTO crs([code], [dur])
	VALUES ('tstcrs', 3);
	
	INSERT INTO emp([empno])
	VALUES (1);
	
	INSERT INTO offr([trainer], [course], [starts])
		SELECT 
			empno
		,	(SELECT TOP 1 code FROM crs)
		,	DATEADD(DAY, -10, GETDATE())
		FROM emp;
		
	INSERT INTO reg([stud], [course], [starts])
		SELECT
			trainer
		,	course
		,	starts
		FROM offr

	DROP TABLE IF EXISTS #expected;
	SELECT * INTO #expected
	FROM VW_ListTheValidTrainers
	WHERE 1 = 0

	/*Act*/
	DROP TABLE IF EXISTS #results;
	
	SELECT * INTO #actual
	FROM VW_ListTheValidTrainers;
	
	/*Assert*/
	EXECUTE tSQLt.AssertEqualsTable 
		@Expected = '#expected'
	,	@Actual = '#actual';
END;
GO


--Run tests for this functionality
EXECUTE tSQLt.RunTestClass 'testInformationNeeds_2-1';






/*This is Code Regarding All-consuming Perfectionism (C.R.A.P), work and sort this out before turnin!

	--Testdata
	DECLARE
		@crsId SMALLINT = 0
	,	@empId SMALLINT = 0
	
	;

	INSERT INTO offr([course], [starts], [status], [trainer])
	VALUES
		('testO1', GETDATE(), 'CANC', 1)
	,	('testO2', GETDATE(), 'CONF', 2)
	,	('testO3', GETDATE(), 'SCHD', 3)
	,	('testO4', GETDATE(), '', 4)
	,	('testO5', GETDATE(), '', 5)
	;

	;WITH CTE_numberedTrainers AS (
		SELECT
			trainer
		,	ROW_NUMBER() OVER(ORDER BY trainer) AS [i]
		FROM offr
	)
	INSERT INTO emp([empno], [job], [hired])
		SELECT TOP (SELECT COUNT(*) FROM offr)
			*
		FROM CTE_numberedTrainers;
		

	INSERT INTO crs([code], [dur])
		SELECT
			course
		FROM offr
*/