USE SmartCarePreProd

/*
	Downloaded RDL - This is the logic it points to, just text no SP or table just the view Ed wrote.
	The query makes 1 date, since there is 1 variable, @AsOf

	Ed Notes: Ed stated field called effective Start and Effective End, these are the fields you want to target with extra date parameters.
*/


SELECT     TOP (10000) CodeWMods, codename, providername, sitename, ContractRate, ClientId, StartDate, EndDate, Active, RequiresAffilatedProvider, AllAffiliatedProviders, 
                      ContractRateId, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, ContractStart, ContractEnd, EffectiveStart, EffectiveEnd, ProviderId, SiteId
FROM         v_CareMgmt_Rates
WHERE     (EffectiveEnd >= @AsOf) AND (EffectiveStart <= @AsOf)
ORDER BY providername, CodeWMods



--So now this is working in just a query form.

--We want Effective Start
--Effective end

DECLARE @AsOf DATE
SET @AsOf = '2022-04-28'

SELECT TOP (10000) CodeWMods
	, codename
	, providername
	, sitename
	, ContractRate
	, ClientId
	, StartDate
	, EndDate
	, Active
	, RequiresAffilatedProvider
	, AllAffiliatedProviders
	, ContractRateId
	, CreatedBy
	, CreatedDate
	, ModifiedBy
	, ModifiedDate
	, ContractStart
	, ContractEnd
	, EffectiveStart
	, EffectiveEnd
	, ProviderId
	, SiteId
FROM v_CareMgmt_Rates
WHERE 
(EffectiveEnd >= @AsOf) AND (EffectiveStart <= @AsOf)
ORDER BY providername, CodeWMods

--Modified-------------------------------------

--We want Effective Start
--Effective end

DECLARE @StartDate DATE
SET @StartDate = '2022-04-28'

DECLARE @EndDate DATE
SET @EndDate = '2022-04-28'

SELECT TOP (10000) CodeWMods
	, codename
	, providername
	, sitename
	, ContractRate
	, ClientId
	, StartDate
	, EndDate
	, Active
	, RequiresAffilatedProvider
	, AllAffiliatedProviders
	, ContractRateId
	, CreatedBy
	, CreatedDate
	, ModifiedBy
	, ModifiedDate
	, ContractStart
	, ContractEnd
	, EffectiveStart
	, EffectiveEnd
	, ProviderId
	, SiteId
FROM v_CareMgmt_Rates
WHERE 
(EffectiveEnd >= @EndDate) AND (EffectiveStart <= @StartDate)
ORDER BY providername, CodeWMods

-----------2nd Round

/*
	So interesting finding. I don't think you need to point at a new view, or create variables
	You should be good to just paste this as TEXT and refresh paramters and it SHOULD work.
*/

DECLARE @StartDate DATE
SET @StartDate = '2021-10-01'

DECLARE @EndDate DATE
SET @EndDate = '2022-10-01'

SELECT TOP (10000) CodeWMods
	, codename
	, providername
	, sitename
	, ContractRate
	, ClientId
	, StartDate
	, EndDate
	, Active
	, RequiresAffilatedProvider
	, AllAffiliatedProviders
	, ContractRateId
	, CreatedBy
	, CreatedDate
	, ModifiedBy
	, ModifiedDate
	, ContractStart
	, ContractEnd
	, EffectiveStart
	, EffectiveEnd
	, ProviderId
	, SiteId
FROM v_CareMgmt_Rates
WHERE 
(EffectiveEnd <= @EndDate) AND (EffectiveStart >= @StartDate)
ORDER BY providername, CodeWMods




