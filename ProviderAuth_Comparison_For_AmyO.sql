USE ProdSmartCare


/*
	So first concern here is reviewing ProviderAuthorizations the snap shot of 9/29 data, to compare to CURRENT smartcare
	This section is OLD data, historical 9/29 data.

	Assumptions:
		1. ONLY ProviderAuthorizations are needed
		2. ONLY authorizations which span 10/1, need to start prior and go past 10/1
		3. Units left are greater than 0 or there is NO need to review
		
	Result Set:
		Should show provider
		Should show units left
		Consumer information
*/
SELECT distinct(AssignedPopulation) FROM PROVIDERAUTHORIZATIONS
ORDER BY CREATEDDATE DESC


--Result set is 403,552
;
WITH HistoricalProviderAuths 
AS 
	(
	SELECT 
		 PA.ProviderAuthorizationId
		,PA.ProviderAuthorizationDocumentId
		,PA.ClientId
		,PA.ProviderId
		,PA.SiteId
		,PA.BillingCodeId
		,PA.RequestedBillingCodeId
		,PA.Modifier1
		,PA.AuthorizationNumber
		,CASE
			WHEN PA.Status = 2042 THEN 'Approved'
			WHEN PA.Status = 2043 THEN 'Denied'
			WHEN PA.Status = 2044 THEN 'Closed'
			WHEN PA.Status = 2045 THEN 'Pended'
			ELSE 'No Status'
		END as AuthStatus
		,PA.StartDate
		,PA.EndDate
		,PA.StartDateRequested
		,PA.EndDateRequested
		,PA.UnitsRequested
		,PA.UnitsApproved
		,PA.TotalUnitsApproved
		,PA.UnitsUsed AS 'Historical_Units_Used'
		,CASE	
			WHEN PA.AssignedPopulation = 24432 THEN 'Adult MI'
			WHEN PA.AssignedPopulation = 24434 THEN 'Child MI'
			WHEN PA.AssignedPopulation = 24434 THEN 'Adult DD'
			WHEN PA.AssignedPopulation = 24434 THEN 'Child DD'
			WHEN PA.AssignedPopulation = 24434 THEN 'Adult SA'
		ELSE 'No Population'
		END AS Population
	FROM ProviderAuthorizations PA
	WHERE EndDate >= '10-1-2022'
	)
	SELECT 
		HPA.*
		,SCA.UnitsUsed as 'Current_Units_Used' 
		,Current_Units_Used - Historical_Units_Used 
	FROM HistoricalProviderAuths HPA
	LEFT JOIN [dbo].[SmartcareCurrentAuthorizationsLoad] SCA on HPA.ProviderAuthorizationId = CAST(SCA.ProviderAuthorizationId AS INT)






	




	SELECT * FROM GlobalCodes
	WHERE GlobalCodeId IN (2042,2043,2044,2045,2046)

	SELECT * FROM GlobalCodes
	WHERE GLOBALCODEID IN (24434,24432,24433,24435,24436)


/*
	So this jumped down to 6912 results, now start is prior 6,790 is adding before 10/1 start
*/
;
WITH HistoricalProviderAuths 
AS 
	(
	SELECT 
		 PA.ProviderAuthorizationId
		,PA.ProviderAuthorizationDocumentId
		,PA.ClientId
		,PA.ProviderId
		,PA.SiteId
		,PA.BillingCodeId
		,PA.RequestedBillingCodeId
		,PA.Modifier1
		,PA.Modifier2
		,PA.Modifier3
		,PA.Modifier4
		,PA.AuthorizationNumber
		,CASE
			WHEN PA.Status = 2042 THEN 'Approved'
			WHEN PA.Status = 2043 THEN 'Denied'
			WHEN PA.Status = 2044 THEN 'Closed'
			WHEN PA.Status = 2045 THEN 'Pended'
			ELSE 'No Status'
		END as AuthStatus
		,PA.StartDate
		,PA.EndDate
		,PA.StartDateRequested
		,PA.EndDateRequested
		,PA.UnitsRequested
		,PA.UnitsApproved
		,PA.TotalUnitsApproved
		,CASE	
			WHEN PA.AssignedPopulation = 24432 THEN 'Adult MI'
			WHEN PA.AssignedPopulation = 24434 THEN 'Child MI'
			WHEN PA.AssignedPopulation = 24434 THEN 'Adult DD'
			WHEN PA.AssignedPopulation = 24434 THEN 'Child DD'
			WHEN PA.AssignedPopulation = 24434 THEN 'Adult SA'
		ELSE 'No Population'
		END AS Population
		,PA.UnitsUsed AS 'Historical_Units_Used'
		--,PA.TotalUnitsApproved - PA.UnitsUsed AS 'Historical_Remaining_Units'
	FROM ProviderAuthorizations PA
	WHERE EndDate >= '10-1-2022'
	AND StartDate <= '10-1-2022'
	AND EndDate < '1-1-2027'
	)
	SELECT 
		HPA.*
		,SCA.UnitsUsed as 'Current_Units_Used' 
		--,SCA.Current_Units_Used - HPA.Historical_Units_Used AS 'UNITVARIANCE'
	into #ResultSet1 FROM HistoricalProviderAuths HPA
	LEFT JOIN [dbo].[SmartcareCurrentAuthorizationsLoad] SCA on HPA.ProviderAuthorizationId = CAST(SCA.ProviderAuthorizationId AS INT)


SELECT * FROM #ResultSet1


select * INTO #ResultSet2 from #ResultSet1
WHERE Historical_Units_Used IS NOT NULL

--select R2.*
--	,Current_Units_Used - Historical_Units_Used AS 'Additional Units Used Since 9.29'
--from #ResultSet2 R2
--LEFT JOIN Providers P ON R2.ProviderId = P.ProviderId
--ORDER BY 'Additional Units Used Since 9.29' DESC

select 
	 ProviderAuthorizationId
	,ClientId
	,P.ProviderName
	,S.SiteName
	,BC.BillingCode
	,BC2.BillingCode AS 'Requested Billing Code'
	,R2.Modifier1
	,R2.Modifier2
	,R2.Modifier3
	,R2.Modifier4
	,R2.AuthorizationNumber
	,R2.AuthStatus
	,R2.StartDate
	,R2.EndDate
	,R2.StartDateRequested
	,R2.EndDateRequested
	,R2.UnitsRequested
	,R2.UnitsApproved
	,R2.TotalUnitsApproved
	,R2.Population
	,CAST(R2.Historical_Units_Used AS INT) AS Historical_Units_Used
	,CAST(R2.Current_Units_Used AS INT) AS Current_Units_Used
	,Current_Units_Used - Historical_Units_Used AS 'Additional Units Used Since 9.29'
from #ResultSet2 R2
LEFT JOIN Providers P ON R2.ProviderId = P.ProviderId
LEFT JOIN Sites S on R2.SiteId = S.SiteId
LEFT JOIN BillingCodes BC ON R2.BillingCodeId = BC.BillingCodeId
LEFT JOIN BillingCodes BC2 ON R2.RequestedBillingCodeId = BC2.BillingCodeId
ORDER BY 'Additional Units Used Since 9.29' DESC
