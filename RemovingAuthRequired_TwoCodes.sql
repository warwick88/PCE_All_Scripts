use ProdSmartCare

select * into #Temp1 from CoveragePlanRules
where rulename like '%Authorization is%'
AND ISNULL(RECORDDELETED,'N')='N'
order by createddate desc

;
with CTEAuthRequiredTool as
	(select * from CoveragePlanRuleVariables
		where procedurecodeid in (
		898,
		899)
	and CoveragePlanRuleId in (Select CoverageplanRuleId from #Temp1))
select * from CTEAuthRequiredTool

begin tran
;
with CTEAuthRequiredTool as
	(select * from CoveragePlanRuleVariables
		where procedurecodeid in (
		898,
		899)
	and CoveragePlanRuleId in (Select CoverageplanRuleId from #Temp1))
update CoveragePlanRuleVariables
SET RecordDeleted='Y',DeletedDate=GETDATE(),DeletedBy='AuthReqAdj2'
WHERE RuleVariableId in (select RuleVariableId from CTEAuthRequiredTool)
commit tran
rollback

select * from CoveragePlanRuleVariables
where DeletedBy like 'AuthReqAdj2'