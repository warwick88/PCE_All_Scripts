USE SmartCare_datastore

Select * from ClaimLines CL
where 1=1
AND ISNULL(RECORDDELETED,'N')='N'
AND CL.CreatedDate >= '2020-10-01'
AND CL.CreatedDate <= '2022-10-01'

select * from GlobalCodes
where GlobalCodeId in (
75294,2482)


/*So a Claimline has a Many to 1 relationship with ClaimID
--One claim can have MANY claimlines, so logically, pull claimlines, since pulling just claim would require joining claimlines oddly.
*/

select * from BillingCodes
where billingcodeid in (583)

SELECT CLAIMLINEID,GC2.CodeName FROM ClaimLines CL
left join GlobalCodes GC2 on CL.PlaceOfService = GC2.GlobalCodeId
WHERE ClaimLineID IN (
8333342,
8333343,
8333344,
8333345,
8333346,
8333347)

Select 
	CL.ClaimLineId
	,CL.CreatedBy
	,CL.CreatedDate
	,CL.ModifiedBy
	,CL.ModifiedDate
	,GC.CodeName AS 'Claim Line Status' 
	,CL.PlaceOfService AS 'Place Of Service ID'
	,GC2.CodeName AS 'Claim Place of Service' 
	,CL.BillingCodeId
	,BC.BillingCode
	,CL.FromDate
	,CL.ToDate
	,CL.AuthorizationExistsAtEntry
	,CL.Modifier1
	,CL.Modifier2
	,CL.Modifier3
	,CL.Modifier4
	,CL.Charge
	,CL.Units
	,CL.PaidAmount
	,CL.ClaimedAmount
	,CL.RenderingProviderId
	,CL.RenderingProviderName
	,CL.LastAdjudicationDate
	,CL.FinalStatus
	,CL.NeedsToBeWorked
	,CL.DoNotAdjudicate
	,CL.ToReadjudicate
	,CL.Diagnosis1 
	,CL.Diagnosis2
	,CL.Diagnosis3
	FROM ClaimLines CL
LEFT JOIN GlobalCodes GC ON CL.Status = GC.GlobalCodeId
LEFT JOIN GlobalCodes GC2 ON CL.PlaceOfService = GC2.GlobalCodeId
LEFT JOIN BillingCodes BC ON CL.BillingCodeId = BC.BillingCodeId
where 1=1
	AND ISNULL(CL.RecordDeleted,'N')='N'
	AND CL.CreatedDate >= '2020-10-01'
	AND CL.CreatedDate <= '2022-10-01'

	SELECT * FROM ClaimLines

Select CL.ClaimLineId,CL.CreatedBy,CL.CreatedDate,CL.ModifiedBy,CL.ModifiedDate,GC.CodeName AS 'Claim Line Status' from ClaimLines CL
JOIN GlobalCodes GC ON CL.Status = GC.GlobalCodeId
where 1=1
	AND ISNULL(CL.RecordDeleted,'N')='N'
	AND CL.CreatedDate >= '2018-10-01'
	AND CL.CreatedDate <= '2022-10-01'





		select 
			S.ServiceId
			,S.CreatedBy
			,S.CreatedDate
			,S.ModifiedBy
			,S.ModifiedDate
			,S.ClientId
			,PC.DisplayAs as 'DisplayAs'
			,PC.ProcedureCodeName as 'Procedure Code Name'
			,GC.CodeName as 'Service Status'
			,S.DateOfService
			,S.EndDateOfService
			,S.Unit
			,S.ClinicianId --> First Dimension table, no need to join, as we want lots of staff details. Gender and primary programs etc
			,S.ProgramId
			,S.LocationId
			,L.LocationName
			,S.Billable
			,S.ClientWasPresent
			,S.Charge
			,S.ProcedureRateId
		from Services S
		LEFT JOIN GlobalCodes GC ON S.Status = GC.GlobalCodeId 
		LEFT JOIN ProcedureCodes PC ON S.ProcedureCodeId = PC.ProcedureCodeId
		LEFT JOIN Locations L ON S.LocationId = L.LocationId
		where ISNULL(S.RecordDeleted,'N') = 'N'
		AND S.CreatedDate >= '2018-10-01'
		AND S.CreatedDate <= '2022-10-01'
		AND S.ProcedureCodeId <> 944 --> This is T1040 CCBHC Per Diem
		order by S.CreatedDate desc