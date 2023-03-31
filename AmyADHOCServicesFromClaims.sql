use ProdSmartCare


/*
	Service Columns
	1. Client ID - First ask
	2. Status for the Service at the end, right now it just has claim status
	3. More Service Details
	4. Pull Service Diagnosis's

	Claims Requests:
	Paid Amount and Approved Amount Units etc
*/
select top 10000 sitename, CodeWMods, pos, Status, alldx, starttime, cl.modifieddate, clsm.*
from v_ClaimLines cl left join ClaimLineServiceMappings clsm on cl.ClaimLineId=clsm.ClaimLineId
where 1=1
and sitename like 'dco%'
and status not like 'denied'
and cl.ModifiedDate>clsm.CreatedDate


--1253 results
--Added Client ID
--Added Service Status

--Things to add, lets get ProcedureCode Name, Location,Clinician Name, Program Name, Billable, Charge
select top 10000 
	cl.sitename,cl.Clientid, cl.CodeWMods, cl.pos, cl.Status, cl.alldx, cl.starttime, cl.modifieddate, 
	clsm.*,
	gc.codename AS 'Service Status'
from v_ClaimLines cl 
LEFT JOIN ClaimLineServiceMappings clsm on cl.ClaimLineId=clsm.ClaimLineId
LEFT JOIN Services S on clsm.ServiceId = S.ServiceId
LEFT JOIN GlobalCodes GC on S.Status = GC.GlobalCodeId
where 1=1
and sitename like 'dco%'
and cl.status not like 'denied'
and cl.ModifiedDate>clsm.CreatedDate

--Things to add, lets get ProcedureCode Name, Location - done,, Program Name - done, Billable, Charge
select top 10000 
	cl.sitename,cl.Clientid, cl.CodeWMods, cl.pos, cl.Status, cl.alldx, cl.starttime, cl.modifieddate 
	,clsm.*
	,gc.codename AS 'Service Status'
	,PC.DisplayAs AS 'Service Procdure Code'
	,PC.ExternalCode1 AS 'Service External Code'
	,P.ProgramName as 'Service Program'
	,L.LocationName as 'Service Location'
	,CASE
		WHEN S.Billable = 'Y' THEN 'Yes'
		WHEN S.Billable = 'N' THEN 'No'
	END AS 'Service Billable'
	,S.Charge as 'Service Charge'
from v_ClaimLines cl 
LEFT JOIN ClaimLineServiceMappings clsm on cl.ClaimLineId=clsm.ClaimLineId
LEFT JOIN Services S on clsm.ServiceId = S.ServiceId
LEFT JOIN GlobalCodes GC on S.Status = GC.GlobalCodeId
LEFT JOIN ProcedureCodes PC ON S.ProcedureCodeId = PC.ProcedureCodeId
LEFT JOIN Programs P ON S.ProgramId = P.ProgramId
LEFT JOIN Locations L on S.LocationId = L.LocationId
where 1=1
and sitename like 'dco%'
and cl.status not like 'denied'
and cl.ModifiedDate>clsm.CreatedDate



select * from services S
LEFT JOIN (
	Select ICD10Code 
	from ServiceDiagnosis SD
	where ISNULL(SD.RecordDeleted,'N') = 'N'
	AND SD."Order" = 1
	) AS ServiceDiagnosis1 on S.ServiceId = SD.ServiceId and SD."Order" = 1
where S.serviceid in (
1105201,
1105337,
1105367,
1105190,
1105249,
1105302)

------------------------------
select top 10000 
	cl.sitename,cl.Clientid, cl.CodeWMods, cl.pos, cl.Status, cl.alldx, cl.starttime, cl.modifieddate 
	,clsm.*
	,gc.codename AS 'Service Status'
	,PC.DisplayAs AS 'Service Procdure Code'
	,PC.ExternalCode1 AS 'Service External Code'
	,P.ProgramName as 'Service Program'
	,L.LocationName as 'Service Location'
	,CASE
		WHEN S.Billable = 'Y' THEN 'Yes'
		WHEN S.Billable = 'N' THEN 'No'
	END AS 'Service Billable'
	,S.Charge as 'Service Charge'
	,ServiceDiagnosis1 = (select ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 1
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis2 = (select ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 2
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis3 = (select ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 3
					and ISNULL(SD.RecordDeleted,'N')='N')
from v_ClaimLines cl 
LEFT JOIN ClaimLineServiceMappings clsm on cl.ClaimLineId=clsm.ClaimLineId
LEFT JOIN Services S on clsm.ServiceId = S.ServiceId
LEFT JOIN GlobalCodes GC on S.Status = GC.GlobalCodeId
LEFT JOIN ProcedureCodes PC ON S.ProcedureCodeId = PC.ProcedureCodeId
LEFT JOIN Programs P ON S.ProgramId = P.ProgramId
LEFT JOIN Locations L on S.LocationId = L.LocationId
where 1=1
and sitename like 'dco%'
and cl.status not like 'denied'
and cl.ModifiedDate>clsm.CreatedDate





select * , 
	ServiceDiagnosis1 = (select ICD10Code 
						from ServiceDiagnosis SD
						where SD.ServiceId = S.ServiceId and SD."Order" = 1
						and ISNULL(SD.RecordDeleted,'N')='N')
	FROM Services S
where S.serviceid in (
1105201,
1105337,
1105367,
1105190,
1105249,
1105302)

select * from ServiceDiagnosis
where serviceid=1105201
and ISNULL(RECORDDELETED,'N') = 'N'

select * into #temp1 from ServiceDiagnosis SD
where serviceid=1105201

select * from #temp1

select t.*,
	CASE 
		WHEN t."Order" = 1 THEN 'One'
		WHEN t."Order" = 2 THEN 'Two'
		END AS OrderName
	from #temp1 t


Order
1
1
2
select TOP 100* from Services S
LEFT JOIN ServiceDiagnosis SD on S.ServiceId = SD.ServiceId where SD.Order = 1
order by s.createddate desc

select TOP 100* from Services S
LEFT JOIN (
	select ICD10Code from ServiceDiagnosis SD
	) as ServiceDiagnosis1 on SD.Serviceid = S.ServiceId
order by s.createddate desc


SELECT SD.ICd10Code from ServiceDiagnosis SD
where serviceid=1105201
and ISNULL(sd.RECORDDELETED,'N') = 'N'
and SD.or =1




select * from locations

select * from procedurecodes
order by createddate desc
