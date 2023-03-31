USE ProdSmartCare
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
		,PA.UnitsUsed
		,CASE	
			WHEN PA.AssignedPopulation = 24432 THEN 'Adult MI'
			WHEN PA.AssignedPopulation = 24434 THEN 'Child MI'
			WHEN PA.AssignedPopulation = 24434 THEN 'Adult DD'
			WHEN PA.AssignedPopulation = 24434 THEN 'Child DD'
			WHEN PA.AssignedPopulation = 24434 THEN 'Adult SA'
		ELSE 'No Population'
		END AS Population
		,PA.TotalUnitsApproved - PA.UnitsUsed AS 'Current_Remaining_Units'
	FROM ProviderAuthorizations PA
	WHERE EndDate >= '10-1-2022'
	AND StartDate <= '10-1-2022'
	AND EndDate < '1-1-2027'
	)
	SELECT * FROM HistoricalProviderAuths