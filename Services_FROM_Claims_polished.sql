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

select * from ClaimLineServiceMappings


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
	/*
	Claims Requests:
	Paid Amount and Approved Amount Units etc
	*/

---------------------
select * from claimlines
where claimlineid in (
9031334,
9029941,
9032596,
9031961,
9031881,
9032597)

select Charge,Units
	,CASE
		WHEN Diagnosis1 = 'Y' AND Diagnosis2 = 'N' THEN 'DX 1'
		WHEN Diagnosis1 = 'Y' AND Diagnosis2 = 'Y' AND Diagnosis3 = 'N' THEN 'DX 1,2'
		WHEN Diagnosis1 = 'Y' AND Diagnosis2 = 'Y' AND Diagnosis3 = 'Y' THEN 'DX 1,2,3'
		else 'Outlier'
	END as DXInfo
	from claimlines
where claimlineid in (
9031334,
9029941,
9032596,
9031961,
9031881,
9032597,
9032103,
9032598,
9032444,
9029942)

select * from claimlines
where claimlineid in (
9031334,
9029941,
9032596,
9031961,
9031881,
9032597,
9032103,
9032598,
9032444,
9029942)

select * from claimlines
where claimlineid in (9031334)

select * from claims
where claimid in (
4472544)
4472842,
4472954,
4472976,
4473070,
4473070)

---------------


select top 10000 
	cl.sitename,cl.Clientid, cl.CodeWMods, cl.pos, cl.Status,cl.PaidAmount,cl.Diagnosis1,cl.Diagnosis2,cl.Diagnosis3, cl.alldx,CL2.Units,CL2.Diagnosis1,CL2.Diagnosis2,CL2.Diagnosis3, cl.starttime, cl.modifieddate 
	,clsm.*
	,gc.codename AS 'Service Status'
	,PC.DisplayAs AS 'Service Procdure Code'
	,PC.ExternalCode1 AS 'Service External Code'
	,P.ProgramName AS 'Service Program'
	,L.LocationName AS 'Service Location'
	,CASE
		WHEN S.Billable = 'Y' THEN 'Yes'
		WHEN S.Billable = 'N' THEN 'No'
	END AS 'Service Billable'
	,S.Charge as 'Service Charge'
	,ServiceDiagnosis1 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 1 
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis2 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 2
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis3 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 3
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis4 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 4
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis5 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 5
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis6 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 6
					and ISNULL(SD.RecordDeleted,'N')='N')
from v_ClaimLines cl 
LEFT JOIN ClaimLineServiceMappings clsm on cl.ClaimLineId=clsm.ClaimLineId
LEFT JOIN Services S on clsm.ServiceId = S.ServiceId
LEFT JOIN GlobalCodes GC on S.Status = GC.GlobalCodeId
LEFT JOIN ProcedureCodes PC ON S.ProcedureCodeId = PC.ProcedureCodeId
LEFT JOIN Programs P ON S.ProgramId = P.ProgramId
LEFT JOIN Locations L on S.LocationId = L.LocationId
LEFT JOIN ClaimLines CL2 on CL2.ClaimlineId = cl.ClaimlineId
WHERE sitename like 'dco%'
and cl.status not like 'denied'
and cl.ModifiedDate>=clsm.CreatedDate

select * from ClaimLineServiceMappings



-------------------

/*
	So Important! found the issue with 38 claimlines not appearing was due to the the portion denied
	So it filtered out 38 results due to them being status 2024 which was not included, removed that
	Updated to 50,000 as Amy moved more over, then added a top 1 rule for diagnosis as we could not join
	must be dupicate 1-6 modifiers on some records.
*/
select top 50000
	cl.sitename,cl.Clientid, cl.CodeWMods, cl.pos, cl.Status,cl.PaidAmount as 'Claim Paid Amount'
	,CASE
		WHEN CL2.Diagnosis1 = 'Y' AND CL2.Diagnosis2 = 'N' THEN 'DX 1'
		WHEN CL2.Diagnosis1 = 'Y' AND CL2.Diagnosis2 = 'Y' AND CL2.Diagnosis3 = 'N' THEN 'DX 1,2'
		WHEN CL2.Diagnosis1 = 'Y' AND CL2.Diagnosis2 = 'Y' AND CL2.Diagnosis3 = 'Y' THEN 'DX 1,2,3'
		else 'Outlier'
	END as DXInfo
	,cl.Diagnosis1,cl.Diagnosis2,cl.Diagnosis3, cl.alldx,CL2.Units,CL2.Diagnosis1,CL2.Diagnosis2,CL2.Diagnosis3, cl.starttime, cl.modifieddate 
	,clsm.*
	,gc.codename AS 'Service Status'
	,PC.DisplayAs AS 'Service Procdure Code'
	,PC.ExternalCode1 AS 'Service External Code'
	,P.ProgramName AS 'Service Program'
	,L.LocationName AS 'Service Location'
	,CASE
		WHEN S.Billable = 'Y' THEN 'Yes'
		WHEN S.Billable = 'N' THEN 'No'
	END AS 'Service Billable'
	,S.Charge as 'Service Charge'
	,ServiceDiagnosis1 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 1 
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis2 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 2
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis3 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 3
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis4 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 4
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis5 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 5
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis6 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 6
					and ISNULL(SD.RecordDeleted,'N')='N')
from v_ClaimLines cl 
LEFT JOIN ClaimLineServiceMappings clsm on cl.ClaimLineId=clsm.ClaimLineId
LEFT JOIN Services S on clsm.ServiceId = S.ServiceId
LEFT JOIN GlobalCodes GC on S.Status = GC.GlobalCodeId
LEFT JOIN ProcedureCodes PC ON S.ProcedureCodeId = PC.ProcedureCodeId
LEFT JOIN Programs P ON S.ProgramId = P.ProgramId
LEFT JOIN Locations L on S.LocationId = L.LocationId
LEFT JOIN ClaimLines CL2 on CL2.ClaimlineId = cl.ClaimlineId
where 1=1
and sitename like 'dco%'
and clsm.ClaimLineId is not null



---testing what ones are not showing up

--So here is ALL the testing that was involved to find those stupid 14 claimlines
--Bottom line is they don't exist in the view
--First batch of 38 some just were denied, 14 don't show in the view so of course won't join later that doesnt make sense
--Their data is here


--So it looks like we get 32,055 rows

--my query gets 31902 153 are missing.

select top 50000
	cl.sitename,cl.Clientid, cl.CodeWMods, cl.pos, cl.Status,cl.PaidAmount as 'Claim Paid Amount'
	,CASE
		WHEN CL2.Diagnosis1 = 'Y' AND CL2.Diagnosis2 = 'N' THEN 'DX 1'
		WHEN CL2.Diagnosis1 = 'Y' AND CL2.Diagnosis2 = 'Y' AND CL2.Diagnosis3 = 'N' THEN 'DX 1,2'
		WHEN CL2.Diagnosis1 = 'Y' AND CL2.Diagnosis2 = 'Y' AND CL2.Diagnosis3 = 'Y' THEN 'DX 1,2,3'
		else 'Outlier'
	END as DXInfo
	,clsm.*
	,gc.codename AS 'Service Status'
	,PC.DisplayAs AS 'Service Procdure Code'
	,PC.ExternalCode1 AS 'Service External Code'
	,P.ProgramName AS 'Service Program'
	,L.LocationName AS 'Service Location'
	,CASE
		WHEN S.Billable = 'Y' THEN 'Yes'
		WHEN S.Billable = 'N' THEN 'No'
	END AS 'Service Billable'
	,S.Charge as 'Service Charge'
	,ServiceDiagnosis1 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 1 
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis2 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 2
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis3 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 3
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis4 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 4
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis5 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 5
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis6 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 6
					and ISNULL(SD.RecordDeleted,'N')='N')
into #Test155 from v_ClaimLines cl 
LEFT JOIN ClaimLineServiceMappings clsm on cl.ClaimLineId=clsm.ClaimLineId
LEFT JOIN Services S on clsm.ServiceId = S.ServiceId
LEFT JOIN GlobalCodes GC on S.Status = GC.GlobalCodeId
LEFT JOIN ProcedureCodes PC ON S.ProcedureCodeId = PC.ProcedureCodeId
LEFT JOIN Programs P ON S.ProgramId = P.ProgramId
LEFT JOIN Locations L on S.LocationId = L.LocationId
LEFT JOIN ClaimLines CL2 on CL2.ClaimlineId = cl.ClaimlineId
where 1=1
and sitename like 'dco%'
and clsm.ClaimLineId is not null

--so lets select from the temp table #Test155

select * from #Test155


--Here we get 32,055 rows
select * into #Test777 from ClaimLineServiceMappings
where claimlineid not in(select claimlineid from #Test155)


--So it looks like we get 32,055 rows

--my query gets 31902 153 are missing.
select 
	 CLSM.*
	 ,S.Charge as 'Service Charge'
	,gc.codename AS 'Service Status'
	,PC.DisplayAs AS 'Service Procdure Code'
	,PC.ExternalCode1 AS 'Service External Code'
	,CASE
		WHEN S.Billable = 'Y' THEN 'Yes'
		WHEN S.Billable = 'N' THEN 'No'
	END AS 'Service Billable'
	,P.ProgramName AS 'Service Program'
	,L.LocationName AS 'Service Location'
	,CL.Diagnosis1
	,CL.Diagnosis2
	,CL.Diagnosis3
	,CL.Units
	,CL.Diagnosis1
	,CL.Diagnosis2
	,CL.Diagnosis3
	,CL.starttime
	,CL.modifieddate 
	,CL.ClaimId
	,CC.Diagnosis1 AS 'Claim Diagnosis 1'
	,CC.Diagnosis2 AS 'Claim Diagnosis 2'
	,CC.Diagnosis3 AS 'Claim Diagnosis 3'
	,ServiceDiagnosis1 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 1 
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis2 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 2
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis3 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 3
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis4 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 4
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis5 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 5
					and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis6 = (select TOP 1 ICD10Code 
					from ServiceDiagnosis SD
					where SD.ServiceId = S.ServiceId and SD."Order" = 6
					and ISNULL(SD.RecordDeleted,'N')='N')
from ClaimLineServiceMappings CLSM
LEFT JOIN SERVICES S ON CLSM.ServiceId = S.ServiceId
LEFT JOIN GlobalCodes GC on S.Status = GC.GlobalCodeId
LEFT JOIN ProcedureCodes PC ON S.ProcedureCodeId = PC.ProcedureCodeId
LEFT JOIN Programs P ON S.ProgramId = P.ProgramId
LEFT JOIN Locations L on S.LocationId = L.LocationId
LEFT JOIN ClaimLines CL on CLSM.ClaimlineId = CL.Claimlineid
LEFT JOIN Claims CC on CL.ClaimId = CC.ClaimId
where clsm.claimlineid in (select claimlineid from #Test777)


