/*Task 1 - Implement Foreign Keys and Cascading Rules 
Check the constraint script, add the correct foreign key and cascading rule declarations as depicted in the PowerDesigner PDM.

The PDM schema uses some abbrevations:
•	Upd() means no cascade
•	Upd(C) means cascade
•	Del(N) means set null
•	cpa means change parent allowed. You can ignore this for this task.

Make sure you explicitly define the cascading rules. Don’t use default implementations.
*/
USE COURSE;
GO


/*emp*/
--emp(sgrade)	-> grd(grade)	: Upd(C) Del()
--emp(deptno)	-> dept(deptno)	: Upd()  Del()
ALTER TABLE emp
DROP
	CONSTRAINT IF EXISTS fk_grd_salaryGrade
,	CONSTRAINT IF EXISTS fk_dept_worksAt;

ALTER TABLE emp
ADD
	CONSTRAINT fk_grd_salaryGrade FOREIGN KEY(sgrade) REFERENCES grd(grade)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
,	CONSTRAINT fk_dept_worksAt FOREIGN KEY(deptno) REFERENCES dept(deptno)
		ON UPDATE NO ACTION
		ON DELETE NO ACTION;
GO

/*memp*/
--memp(mgr)		-> emp(empno)	: Upd() Del()
--memp(empno)	-> emp(empno)	: Upd() Del()
ALTER TABLE memp
DROP
	CONSTRAINT IF EXISTS fk_emp_managedEmployee
,	CONSTRAINT IF EXISTS fk_emp_managedBy;

ALTER TABLE memp
ADD
	CONSTRAINT fk_emp_managedEmployee FOREIGN KEY(empno) REFERENCES emp(empno)
		ON UPDATE NO ACTION
		ON DELETE NO ACTION,
	CONSTRAINT fk_emp_managedBy FOREIGN KEY(mgr) REFERENCES emp(empno)
		ON UPDATE NO ACTION
		ON DELETE NO ACTION;
GO

/*dept*/
--dept(mgr)		-> emp(empno)	: Upd() Del()
ALTER TABLE dept
DROP CONSTRAINT IF EXISTS fk_emp_manager;

ALTER TABLE dept
ADD CONSTRAINT fk_emp_manager FOREIGN KEY(mgr) REFERENCES emp(empno)
	ON UPDATE NO ACTION
	ON DELETE NO ACTION;
GO

/*srep*/
--srep(empno) 	-> emp(empno) 	: Upd() Del(C)
ALTER TABLE srep
DROP CONSTRAINT IF EXISTS fk_emp_employeeIdentity;

ALTER TABLE srep
ADD CONSTRAINT fk_emp_employeeIdentity FOREIGN KEY(empno) REFERENCES emp(empno)
	ON UPDATE NO ACTION
	ON DELETE CASCADE;
GO

/*hist*/
--hist(empno)	-> emp(empno)		: Upd() Del()
--hist(deptno)	-> dept(deptno)		: Upd() Del()
ALTER TABLE hist
DROP
	CONSTRAINT IF EXISTS fk_emp_changedEmployee
,	CONSTRAINT IF EXISTS fk_dept_employeeWorksAt;

ALTER TABLE hist
ADD 
	CONSTRAINT fk_emp_changedEmployee FOREIGN KEY(empno) REFERENCES emp(empno)
		ON UPDATE NO ACTION
		ON DELETE CASCADE,
	CONSTRAINT fk_dept_employeeWorksAt FOREIGN KEY(deptno) REFERENCES dept(deptno)
		ON UPDATE NO ACTION
		ON DELETE NO ACTION;
GO

/*term*/
--term(empno)	-> emp(empno)	: Upd() DEL(C)
ALTER TABLE term
DROP CONSTRAINT IF EXISTS fk_emp_exEmployee;

ALTER TABLE term
ADD CONSTRAINT fk_emp_exEmployee FOREIGN KEY(empno) REFERENCES emp(empno)
	ON UPDATE NO ACTION
	ON DELETE CASCADE;
GO

/*offr*/
--offr(trainer)		-> emp(empno)	: Upd()	 Del(N)
--offr(course)		-> crs(code)	: Upd(C) Del()
ALTER TABLE offr
DROP
	CONSTRAINT IF EXISTS fk_emp_trainer
,	CONSTRAINT IF EXISTS fk_crs_offeredCourse;

ALTER TABLE offr
ADD
	CONSTRAINT fk_emp_trainer FOREIGN KEY(trainer) REFERENCES emp(empno)
		ON UPDATE NO ACTION
		ON DELETE SET NULL,
	CONSTRAINT fk_crs_offeredCourse FOREIGN KEY(course) REFERENCES crs(code)
		ON UPDATE CASCADE
		ON DELETE NO ACTION;
GO

/*reg*/
--reg(stud)				-> emp(empno) 				: Upd() Del(C)
--reg(course, starts)	-> offr(course, starts)		: Upd() Del()
ALTER TABLE reg
DROP
	CONSTRAINT IF EXISTS fk_emp_enrolledTrainee
,	CONSTRAINT IF EXISTS fk_offr_signedUpFor;

ALTER TABLE reg
ADD
	CONSTRAINT fk_emp_enrolledTrainee FOREIGN KEY(stud) REFERENCES emp(empno)
		ON UPDATE NO ACTION
		ON DELETE CASCADE,
	CONSTRAINT fk_offr_signedUpFor FOREIGN KEY(course, starts) REFERENCES offr(course, starts)
		ON UPDATE NO ACTION
		ON DELETE NO ACTION;
GO

