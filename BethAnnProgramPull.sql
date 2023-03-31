use ProdSmartCare


select CP.*,P.ProgramName,gc.CodeName from ClientPrograms CP
LEFT JOIN GlobalCodes GC on CP.Status = GC.GLOBALCODEID
LEFT JOIN Programs P ON CP.ProgramId = P.ProgramId
where CP.clientid=93745
and CP.Status = 4
and ISNULL(CP.Recorddeleted,'N') = 'N'


select CP.*,
	P.ProgramName,
	gc.CodeName,
	CASE
		WHEN CP.PrimaryAssignment = 'Y' THEN 'PrimaryProgram'
		WHEN CP.PrimaryAssignment = 'N' THEN 'Not Primary Program'
		ELSE 'Nothing'
	END As ProgramDetails
from ClientPrograms CP
LEFT JOIN GlobalCodes GC on CP.Status = GC.GLOBALCODEID
LEFT JOIN Programs P ON CP.ProgramId = P.ProgramId
where CP.clientid=93745
and CP.Status = 4
and ISNULL(CP.Recorddeleted,'N') = 'N'


select CP.*,
	P.ProgramName,
	gc.CodeName,
	C.FirstName + ' '+ C.Lastname AS 'Client FullName',
	CASE
		WHEN CP.PrimaryAssignment = 'Y' THEN 'PrimaryProgram'
		WHEN CP.PrimaryAssignment = 'N' THEN 'Not Primary Program'
		ELSE 'Nothing'
	END As ProgramDetails
from ClientPrograms CP
LEFT JOIN GlobalCodes GC on CP.Status = GC.GLOBALCODEID
LEFT JOIN Programs P ON CP.ProgramId = P.ProgramId
LEFT JOIN Clients C on CP.ClientId = C.ClientId
where CP.clientid=93745
AND CP.Status = 4
and ISNULL(CP.Recorddeleted,'N') = 'N'

select CP.*,
	P.ProgramName,
	gc.CodeName,
	C.FirstName + ' '+ C.Lastname AS 'Client FullName',
	C.Active,
	CASE
		WHEN CP.PrimaryAssignment = 'Y' THEN 'Primary Program'
		WHEN CP.PrimaryAssignment = 'N' THEN 'Not Primary Program'
		ELSE 'Nothing'
	END As ProgramDetails
from ClientPrograms CP
LEFT JOIN GlobalCodes GC on CP.Status = GC.GLOBALCODEID
LEFT JOIN Programs P ON CP.ProgramId = P.ProgramId
LEFT JOIN Clients C on CP.ClientId = C.ClientId
WHERE CP.Status = 4
and ISNULL(CP.Recorddeleted,'N') = 'N'

where CP.clientid=93745



select distinct(cp.status) from ClientPrograms CP
JOIN GlobalCodes GC on CP.Status = GC.GLOBALCODEID
where CP.clientid=93745

select * from Clients
where clientid in (
82790,
70259,
83360,
82912,
83904,
69974,
82526,
83265,
83095,
83387,
83812,
85637)



--4 Enrolled 5 Discharged
select * from GlobalCodes
where globalcodeid in (4,5)


select * from ClaimLineServiceMappings
order by createddate desc

select * from Reports
order by CreatedDate


select * from ElectronicEligibilityVerificationBatches
order by createddate desc