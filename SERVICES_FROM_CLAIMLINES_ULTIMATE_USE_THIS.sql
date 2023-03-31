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




--46236
select top 100000
	cl.sitename,cl.Clientid, cl.CodeWMods, cl.pos, cl.Status,cl.PaidAmount as 'Claim Paid Amount'
	,CL3.Diagnosis1
	,CL3.Diagnosis2
	,CL3.Diagnosis3
	,CL2.StartTime as 'Claim Start time'
	,CL2.Endtime 'Claim End time'
	,CL2.Units as 'Claim Units'
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
	,S.Unit as 'Service Units'
	,S.DateofService AS 'Date of Service Column' 
	,S.EndDateOfService AS 'End Date of Service'
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

--46844
select * from ClaimLineServiceMappings
-----CONFIRM AREA
--48,520
select * from #Test155
drop table #Test155


select * from ClaimLines
where ClaimLineId=8944423
--Total is 40,547
--First total 40,379
--need 168 last ones
drop table #Test777

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
	,CL.starttime as 'claim start time'
	,CL.endtime as 'claim end time'
	,CL.modifieddate 
	,CL.ClaimId
	,CL.FromDate
	,CL.ToDate
	,CC.Diagnosis1 AS 'Claim Diagnosis 1'
	,CC.Diagnosis2 AS 'Claim Diagnosis 2'
	,CC.Diagnosis3 AS 'Claim Diagnosis 3'
	,S.Charge as 'Service Charge'
	,S.Unit
	,S.DateOfService
	,S.EndDateOfService
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


