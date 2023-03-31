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

/*
	8/2/22: Changes requested by Amy
	Before DXInfo column Amy would like the actual Diagnosis that is on the claim - This is found on the Claim line header, diagnosis 1 diagnosis 2 diagnosis 3
	Claim side is missing Date of Service column,
	Service Side is missing DATE of service

	So far 5 new columns, all the Diagnosis so 3 of them, then claimside missing date of service column, then service side missing date of service.

	claim column 1
	claim column 2
	claim column 3
	Service Column 1: DOS done!!!!

*/


select top 10000 sitename, CodeWMods, pos, Status, alldx, starttime, cl.modifieddate, clsm.*
from v_ClaimLines cl left join ClaimLineServiceMappings clsm on cl.ClaimLineId=clsm.ClaimLineId
where 1=1
and sitename like 'dco%'
and status not like 'denied'
and cl.ModifiedDate>clsm.CreatedDate

select * from ClaimLineServiceMappings

---------------


select *,
	cl.sitename,cl.Clientid, cl.CodeWMods, cl.pos, cl.Status,cl.PaidAmount,cl.Diagnosis1,cl.Diagnosis2,cl.Diagnosis3, cl.alldx,CL2.Units,CL2.Diagnosis1,CL2.Diagnosis2,CL2.Diagnosis3, cl.starttime, cl.modifieddate 
	,clsm.*
	,CL3.Diagnosis1
	,CL3.Diagnosis2
	,CL3.Diagnosis3
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
	,S.DateofService AS 'Date of Service Column'   --This is a new column requested by Amy.
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
LEFT JOIN CLAIMS CL3 ON CL2.ClaimId = CL3.Claimid
WHERE sitename like 'dco%'
and cl.status not like 'denied'
and cl.ModifiedDate>=clsm.CreatedDate

select cl.claimlineid,c.diagnosis1,c.diagnosis2,c.diagnosis3 from claimlines CL
LEFT JOIN CLAIMS C ON CL.ClaimId = C.Claimid
where cl.claimlineid in (
8997005,
9023182,
9023183)


--final status is last column
select * from claimlines
where claimlineid in (
8997005,
9023182,
9023183)

select * from claims
where claimid in (
4468187,
4471472,
4471472)



--so first query is 40,379

--40,547
-------------------

/*
	So Important! found the issue with 38 claimlines not appearing was due to the the portion denied
	So it filtered out 38 results due to them being status 2024 which was not included, removed that
	Updated to 50,000 as Amy moved more over, then added a top 1 rule for diagnosis as we could not join
	must be dupicate 1-6 modifiers on some records.
*/
select top 50000
	cl.sitename,cl.Clientid, cl.CodeWMods, cl.pos, cl.Status,cl.PaidAmount as 'Claim Paid Amount'
	,CL3.Diagnosis1
	,CL3.Diagnosis2
	,CL3.Diagnosis3
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
	,S.DateofService AS 'Date of Service Column' 
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
LEFT JOIN CLAIMS CL3 ON CL2.ClaimId = CL3.Claimid
where 1=1
and sitename like 'dco%'
and clsm.ClaimLineId is not null



---testing what ones are not showing up

--So here is ALL the testing that was involved to find those stupid 14 claimlines
--Bottom line is they don't exist in the view
--First batch of 38 some just were denied, 14 don't show in the view so of course won't join later that doesnt make sense
--Their data is here



--40,547 this is the total we need to hit.
select top 100000
	cl.sitename,cl.Clientid, cl.CodeWMods, cl.pos, cl.Status,cl.PaidAmount as 'Claim Paid Amount'
	,CL3.Diagnosis1
	,CL3.Diagnosis2
	,CL3.Diagnosis3
	,CL2.FromDate
	,CL2.ToDate
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
	,S.DateofService AS 'Date of Service Column' 
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
LEFT JOIN CLAIMS CL3 ON CL2.ClaimId = CL3.Claimid
where 1=1
and sitename like 'dco%'
and clsm.ClaimLineId is not null

drop table #Test155
--so lets select from the temp table #Test155
select * from ClaimLineServiceMappings
-----CONFIRM AREA
select * from #Test155

select * from ClaimLines
where ClaimLineId=8944423
--Total is 40,547
--First total 40,379
--need 168 last ones


select * into #Test777 from ClaimLineServiceMappings
where claimlineid not in(select claimlineid from #Test155)

select * from services
where serviceid=1187447

select * from ServiceDiagnosis
where serviceid=1187447
--So it looks like we get 32,055 rows

--my query gets 31902 153 are missing.
select 
	 CLSM.*
	,CC.Diagnosis1
	,CC.Diagnosis2
	,CC.Diagnosis3
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
	,CL.FromDate
	,CL.ToDate
	,CC.Diagnosis1 AS 'Claim Diagnosis 1'
	,CC.Diagnosis2 AS 'Claim Diagnosis 2'
	,CC.Diagnosis3 AS 'Claim Diagnosis 3'
	,S.Charge as 'Service Charge'
	,S.DateOfService AS 'Date of Service column'
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


