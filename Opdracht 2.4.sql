-- Transaction beginnen om data aan te passen en toe te voegen

BEGIN TRANSACTION

-- Huidig salaris van werknemer 1020 aanpassen naar 5000

UPDATE EMP
SET msal = 5000
WHERE empno = 1020

-- Data toevoegen aan de HIST tabel 

INSERT INTO HIST
--Van 2000 tot 2002:
VALUES (1020, '2002-01-01', 15, 4000)

--Van 2002 tot 2004:
INSERT INTO HIST
VALUES (1020, '2004-01-01', 15, 4200)

--Van 2004 tot 2009
INSERT INTO HIST
VALUES (1020, '2009-01-01', 15, 4500)

-- Query
;WITH [listEmpSalary] AS
(
	SELECT empno, msal, getdate() as hired , ' emp'  as d
	FROM EMP e
	WHERE empno = 1020
	UNION 
	SELECT empno, msal, until, 'hist'
	FROM HIST h
)

SELECT empno, msal, cast(hired as date) AS [from], CAST(LEAD(hired) OVER (PARTITION BY empno ORDER BY empno) as date) AS [until]
FROM [listEmpSalary]

-- Transaction terug draaien om de toegevoegde en aangepaste data ongedaan te maken
ROLLBACK TRANSACTION
