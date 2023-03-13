/*Task 4.1 – Trainers cannot teach different courses simultaneously 
Implement and test a stored procedure enforcing the constraint ‘trainers cannot teach different courses simultaneously’. The constraint should be validated as soon as a new course offering is inserted.
*/
USE COURSE;
GO

-- Returns 1 if free, 0 if occupied
CREATE OR ALTER PROCEDURE isTrainerOccupied (
	-- Potentially dynamify column types
	@trainerId 
		NUMERIC (4, 0)
,	@status 
		VARCHAR(4)
,	@course 
		VARCHAR(6)
,	@startDate 
		DATE
,	@location
		VARCHAR(14)
,	@capacity
		NUMERIC(2, 0)
/*,	@occupied
		BIT
		OUTPUT*/
) AS
BEGIN
    SET NOCOUNT ON;  
    
	IF(
		@trainerId IS NULL OR	-- offr.trainer (pretty much the most important column to consider) is nullable, so fastpass
		(
			EXISTS(	-- Qualifier
				SELECT 1
				FROM VW_ListTheValidTrainers
				WHERE 
					ename = @trainerId AND
					code = @course
			) AND
			NOT EXISTS( -- Disqualifier
				SELECT 1
				FROM (	-- Get proposed new training offer
					SELECT
						@trainerId AS [trainer]
					,	@course AS [course]
					,	@startDate AS [starting]
					,	DATEADD(DAY, dur, @startDate) AS [ending]
					FROM crs
					WHERE code = @course
				) AS [prop]
				INNER JOIN offr AS [o]	-- Get potential conflicts
					ON 
						prop.trainer = o.trainer AND
						prop.starting = o.starts
					INNER JOIN crs AS [c]		-- Append course data to aforementioned
						ON o.course = c.dur
				WHERE 
					o.trainer = @trainerId AND
					(	
						-- Can't start new training when one is ongoing
						prop.starting <= DATEADD(DAY, c.dur, o.starts)	-- Maybe inner join end date on offer and use its alias here for readability
						AND
						-- Can't have new training overlap with starting trainings
						prop.ending >= o.starts
					)
			)
		)
	) 
	BEGIN
		--SET @occupied = 0;	-- Trainer is free to offer the new training
		INSERT INTO offr(trainer, [status], course, starts, loc, maxcap)
		VALUES(@trainerId, @status, @course, @startDate, @location, @capacity)
	
	END
	ELSE
	BEGIN
		-- Trainer is occupied
		--SET @occupied = 1;
		;THROW 50001, 'Trainer doesn''t exist or is occupied', 1;
		
	END

	--RETURN @occupied;
END
GO

-- Testing the new constraint
/*BEGIN TRANSACTION
	
	EXECUTE 




ROLLBACK TRANSACTION

*/






/* According to my teacher, the following was wholly unnecessary


CREATE OR ALTER TRIGGER tr_preventDoubleBooking		--Why TF do I need to use an SP to validate as soon as an offer is inserted!?
ON offr AFTER INSERT, UPDATE AS
BEGIN
	IF(@@ROWCOUNT < 1) RETURN;
	DECLARE @rCnt INT = @@ROWCOUNT;
	SET NOCOUNT ON;

	BEGIN TRY
		
		DECLARE 
			@cnt INT = 0,
			@trainerOccupied BIT;
		WHILE(@cnt < @rCnt)
			
			EXECUTE isTrainerOccupied	
				

			IF()
			BEGIN
				
				

				-- Throw me a river ;_;
				;THROW;
			END
		END
	END TRY
	BEGIN CATCH
		;THROW 50001, 'Set contains double bookings!', 1;
	END CATCH
END

