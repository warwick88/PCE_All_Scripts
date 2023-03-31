use ProdSmartCare

--So column ProviderSiteGroupName: is CCBHC DCOs
--So budget name here is ccbhc
select * from CoveragePlanClaimBudgets

select * from claimlinecoverageplanclaimbudgets

select * from claimlinecoverageplanclaimbudgets
where claimlineid=9046942

select * from providersitegroups


select * from CoveragePlanClaimBudgetProviderSites

select * from CoveragePlanClaimBudgetProviderSites
where providerid=1258


select * from providers
where providerid=1258


select * from providers
order by modifieddate desc


select * from providers
where providername like '%edge%'
order by createddate desc

--Edge Water music therapy is 1258

SELECT * FROM sys.sysprocesses WHERE open_tran = 1
--So this will show you what process are running
--Most important is BlkBy, this shows what process it's blocked by

EXEC sp_who2
order by BlkBy desc


--This is how you kill the individual processes blocking items.
kill 97