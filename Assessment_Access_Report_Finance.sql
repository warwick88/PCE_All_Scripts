use KDEVSmartCare

select S.CLIENTID,C.Firstname,C.Lastname from services S
LEFT JOIN CLIENTS C ON S.Clientid = C.Clientid
where procedurecodeid in (
1143,
775,
774,
773,
759,
754,
749,
725,
724,
648,
641,
765,
651,
637)
order by S.createddate desc


select S.* from services S
LEFT JOIN CLIENTS C ON S.Clientid = C.Clientid
where procedurecodeid in (
1143,
775,
774,
773,
759,
754,
749,
725,
724,
648,
641,
765,
651,
637)
AND DateOfService < GETDATE()
order by S.createddate desc

select S.Clientid,C.FirstName,C.LastName,S.ServiceId,S.DateOfService,s.Status from services S
LEFT JOIN CLIENTS C ON S.Clientid = C.Clientid
LEFT JOIN ProcedureCodes PC on S.ProcedureCodeId = PC.ProcedureCodeId
where S.ProcedureCodeId in (
1143,
775,
774,
773,
759,
754,
749,
725,
724,
648,
641,
765,
651,
637)
AND DateOfService < GETDATE()
order by S.createddate desc

select S.Clientid
	,C.FirstName
		,C.LastName
		,S.ServiceId
		,S.DateOfService
		,CASE
			WHEN S.Status = 70 THEN 'Scheduled'
			WHEN S.Status = 71 THEN 'Show'
			WHEN S.Status = 72 THEN 'No Show'
			WHEN S.Status = 73 THEN 'Cancel'
			WHEN S.Status = 75 THEN 'Complete'
			WHEN S.Status = 76 THEN 'Error'
			END AS 'Service Status' 
		,PC.ProcedureCodeName
		from services S
LEFT JOIN CLIENTS C ON S.Clientid = C.Clientid
LEFT JOIN ProcedureCodes PC on S.ProcedureCodeId = PC.ProcedureCodeId
where S.ProcedureCodeId in (
1143,
775,
774,
773,
759,
754,
749,
725,
724,
648,
641,
765,
651,
637)
AND DateOfService < GETDATE()
order by S.createddate desc

SELECT * FROM GlobalCodes
WHERE CODENAME LIKE '%REMITTANCE%'

select * from GlobalCodes
where globalcodeid in(75,
72,
70,
73,
76,
71)

select * from GlobalCodes

