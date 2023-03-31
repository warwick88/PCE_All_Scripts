use ProdSmartCare


select * from clientdiagnosis
where clientid=32697

select PROGRAMID,PROGRAMCODE,PROGRAMNAME,ACTIVE from programs
where active='Y'
and ISNULL(recorddeleted,'N') ='N'
order by createddate desc

select PR.Procedurerateid,PR.createdby,PR.createddate,PR.coverageplanid,PR.procedurecodeid,PC.ProcedureCodeName,PR.fromdate,PR.todate,PR.amount,PR.chargetype,PR.ProgramGroupName from ProcedureRates PR
Join Procedurecodes PC on PR.ProcedureCodeId = PC.ProcedureCodeId
where FromDate > '2021-09-30'
order by ProgramGroupName

select PR.*,PC.PROCEDURECODENAME from ProcedureRates PR
Join Procedurecodes PC on PR.ProcedureCodeId = PC.ProcedureCodeId
where FromDate > '2021-09-30'
order by ProgramGroupName

SELECT * FROM ProcedureRatePrograms

SELECT PRP.*,P.ProgramName,PR.*,PC.ProcedureCodeName FROM ProcedureRatePrograms PRP
JOIN ProcedureRates PR ON PRP.ProcedureRateId = PR.ProcedureRateId
JOIN Programs P ON PRP.ProgramId = P.ProgramId
JOIN ProcedureCodes PC ON PR.ProcedureCodeId = PC.ProcedureCodeId
where PR.FromDate > '2021-09-30'


select * from Reports
order by createddate desc

SELECT * FROM ProcedureRateServiceAreas

select * from programgroups

select *
from procedurecodes 
where 1=1
and active='Y'
and isnull(recorddeleted,'N')='N'
and procedurecodeid not in(
	select pc.ProcedureCodeId
	from coverageplanrules cpr
	join coverageplans cp on cpr.CoveragePlanId=cp.CoveragePlanId
	join coverageplanrulevariables cprv on cpr.CoveragePlanRuleId=cprv.CoveragePlanRuleId
	join ProcedureCodes pc on cprv.ProcedureCodeId=pc.ProcedureCodeId
	where 1=1
	and isnull(cprv.recorddeleted,'N')='N'
	and isnull(cpr.recorddeleted,'N')='N'
	and cp.CoveragePlanName like 'general fund'
	and cpr.RuleName like '%auth%')
order by 1

select * from groupservices

select * from globalcodes
order by createddate desc

select * from Procedurecodes
where procedurecodeid=951

select * from procedurerates
