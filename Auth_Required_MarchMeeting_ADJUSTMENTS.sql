use ProdSmartCare


SELECT * FROM ProcedureCodes
WHERE PROCEDURECODEID IN (854,876,572,836)

----------------------------------------
/*
	So this is really how you insert new Auth required codes. It will pickup the one procedurecode
	and then add it to ALL the plan rules

	So problem we are running into is this is adding the rule for ALL rules in the system essentially.

	We just want to add it to the authorization is required for the 189 differnt plans.
*/

--we need to make sure we are ONLY targeting the correct rule which is authorization is required
select * into #Temp1 from CoveragePlanRules
where rulename like '%Authorization is%'
AND ISNULL(RECORDDELETED,'N')='N'
order by createddate desc

SELECT * FROM ProcedureCodes
WHERE PROCEDURECODEID IN (946,
898,
888,
882,
867,
861,
856)


SELECT * FROM #TEMP1
--Note, this value can seem large, but you need to consider each proc code then x each plan. So each proc code will create about 
-- 190 new rules, so it adds up quickly and can seem like too many.
begin tran
insert into CoveragePlanRuleVariables(coverageplanruleid,procedurecodeid)														
select CoveragePlanRuleId,procedurecodeid 														
from procedurecodes pc, coverageplanrules cpr														
WHERE PROCEDURECODEID IN (946,
898,
888,
882,
867,
861,
856)
and CoveragePlanRuleId in (select coverageplanruleid from #Temp1)
commit tran
rollback


select * into #Temp1 from CoveragePlanRules
where rulename like '%Authorization is%'
AND ISNULL(RECORDDELETED,'N')='N'
order by createddate desc

select * from #Temp1

select * from CoveragePlanRuleVariables
where procedurecodeid in (
898,
899)
and CoveragePlanRuleId in (Select CoverageplanRuleId from #Temp1)




select * from ProcedureCodes
where procedurecodeid in (898,899)


select * from ProcedureCodes
where displayas like '96113%'

select * from services
where serviceid=1142139

