		( select 
			CL.ClaimLineId
			,C.ClientId
			,C.ClaimId
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
			,CL.NeedsToBeWorked
			,CL.DoNotAdjudicate
			,CL.ToReadjudicate
			,CL.RenderingProviderId
			,CL.RenderingProviderName
			,CL.LastAdjudicationDate
			,CL.FinalStatus
			,C.Diagnosis1 AS 'Claim Diagnosis 1'
			,C.Diagnosis2 AS 'Claim Diagnosis 2'
			,C.Diagnosis3 AS 'Claim Diagnosis 3'
			,C.TotalCharge
			,C.AmountPaid
			,C.BalanceDue
			,C.ReceivedDate
			,C.CleanClaimDate
			,C.SiteId
			,S.SiteName
			,P.ProviderName
			,C.BillingProviderInfo
			INTO #FINALTEST1 FROM ClaimLines CL
		LEFT JOIN GlobalCodes GC ON CL.Status = GC.GlobalCodeId
		LEFT JOIN GlobalCodes GC2 ON CL.PlaceOfService = GC2.GlobalCodeId
		LEFT JOIN BillingCodes BC ON CL.BillingCodeId = BC.BillingCodeId
		LEFT JOIN Claims C ON CL.ClaimId = C.ClaimId
		LEFT JOIN Sites S on C.SiteId = S.SiteId
		LEFT JOIN Providers P on S.ProviderId = P.ProviderId
		where 1=1
			AND ISNULL(CL.RecordDeleted,'N')='N'
			AND CL.CreatedDate >= '2021-10-01'
			AND CL.CreatedDate <= '2022-10-01'
			)

	select CL.*
		,CA.ProviderAuthorizationid
		,CA.UnitsUsed
		,PA.AssignedPopulation
		,GC.Codename 
		,ROW_NUMBER() OVER (PARTITION BY CL.CLAIMLINEID ORDER BY CL.CREATEDDATE DESC) AS CLAIMLINEIDCOUNT
		INTO #FINALTEST4 from #FINALTEST1 CL
	LEFT JOIN ClaimLineAuthorizations CA ON CL.ClaimLineId = CA.ClaimLineId AND ISNULL(CA.RECORDDELETED,'N')='N' 
	LEFT JOIN ProviderAuthorizations PA ON CA.ProviderAuthorizationId = PA.ProviderAuthorizationId
	LEFT JOIN GlobalCodes GC on PA.AssignedPopulation = GC.Globalcodeid
	where CL.ClaimLineId in (select claimlineid from #FINALTEST1)
	order by ClaimLineId desc

	select * from #FINALTEST4