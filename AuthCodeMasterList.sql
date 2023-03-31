use IsKzooSmartCareQA


/*
	Auth codes and the Associated Procedure Codes they authorize

*/


select * from AuthorizationCodes
order by createddate desc

select * from AuthorizationCodes
where AuthorizationCodeId=398

/*
	This is where you find the Procedure Codes associated with the Auth Code
	*/
select * from AuthorizationCodeProcedureCodes

select * from AuthorizationCodes AC
LEFT JOIN AuthorizationCodeProcedureCodes ACP ON AC.AuthorizationCodeId = ACP.AuthorizationCodeId
where AC.AuthorizationCodeId=398

select * from AuthorizationCodeProcedureCodes
where ProcedureCodeId in (649,776)

select PC.ProcedureCodeId,PC.CreatedBy,PC.CreatedDate,PC.DisplayAs,PC.ProcedureCodeName,PC.Active from ProcedureCodes PC
where ProcedureCodeId in (649,776)


--ENDS AT WRITEOFFCLIENTCHARGES
select 
	PC.ProcedureCodeId
	,PC.CreatedBy
	,PC.CreatedDate
	,PC.DisplayAs
	,PC.ProcedureCodeName
	,PC.Active
	,'BARRIER' AS 'BARRIER'
	,ACPC.AuthorizationCodeId 
	,AC.AuthorizationCodeName
FROM ProcedureCodes PC
LEFT JOIN AuthorizationCodeProcedureCodes ACPC ON PC.PROCEDURECODEID = ACPC.PROCEDURECODEID
LEFT JOIN AuthorizationCodes AC ON ACPC.AuthorizationCodeId = AC.AuthorizationCodeId
where AC.AuthorizationCodeId in (295)