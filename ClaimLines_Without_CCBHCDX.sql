USE KDEVSmartCare


/*
	Claimlines, finding the ones Ed would like.
	Scope: So Ed wants all CCBHC Claimlines WITHOUT CCBHC Diagnosis

	Soo let's see what scripts he cooked up in relation to this task.

	He would like claimlines that DON'T! have a qualifying CCBHC Diagnosis.

*/

SELECT TOP 100* FROM SERVICES
ORDER BY DATEOFSERVICE DESC


------Eds stuff--------------

/*~ claimlines without ccbhc dx*/
select 
	 VCL.sitename
	,VCL.clientid
	,VCL.FromDate
	,VCL.codewmods
	,VCL.AllDx
	,VCL.claimlineid
	,VCL.claimid
    ,VCL.status
    ,VCL.createddate
	,VCL.createdby
	,VCL.modifieddate
	,VCL.modifiedby
	,C.Diagnosis1
	,C.Diagnosis2
	,C.Diagnosis3
from v_claimlines VCL --View Claim Lines
LEFT JOIN CLAIMS C ON VCL.claimid = C.ClaimId
	where 1=1
	and VCL.fromdate>='10/1/2021'
	and VCL.sitename like '%DCO%'
	and VCL.status<>'Denied'
	and (isnull(VCL.diagnosis1,'')  not like 'f%' or isnull(VCL.diagnosis1,'') like 'f[78]%')
	and (isnull(VCL.diagnosis2,'')  not like 'f%' or isnull(VCL.diagnosis2,'') like 'f[78]%')
	and (isnull(VCL.diagnosis3,'')  not like 'f%' or isnull(VCL.diagnosis3,'') like 'f[78]%')
	order by VCL.sitename, VCL.clientid, VCL.fromdate


select d.icd10code, d.ICDDescription, CMSFiscalYear 
from DiagnosisICD10Codes d left join ICD10FiscalYearAvailability a on d.ICD10Code=a.ICD10Code and a.CMSFiscalYear=2022
where isnull(billableflag,'N')='Y' 
and d.ICD10Code like 'F%' and d.ICD10Code not like 'F[78]%'
order by a.icd10code
go


select top 2500* 
INTO #TEST22 from claimlines CL

SELECT * fROM #TEST22

SELECT * FROM Claims
WHERE ClaimId IN (SELECT CLAIMID FROM #TEST22)

SELECT * 
	 FROM Claims C
	 LEFT JOIN claimlines cl on c.claimid=cl.ClaimId 
	 LEFT JOIN billingcodes bc on cl.BillingCodeId=bc.BillingCodeId 
	 LEFT JOIN sites s on C.SiteId=S.SiteId
     LEFT JOIN globalcodes pos on cl.PlaceOfService=pos.GlobalCodeId
     LEFT JOIN globalcodes stat on cl.status=stat.GlobalCodeId
WHERE C.ClaimId IN (SELECT CLAIMID FROM #TEST22)






SELECT * FROM Claims
WHERE ClaimId IN (SELECT CLAIMID FROM #TEST22)


LEFT JOIN CLAIMS C ON CL.ClaimLineId = C.ClaimId

where FromDate >='10/1/2021'


order by createddate desc


CREATE view [dbo].[v_ClaimLines] as
select s.sitename, kcmhsasSupplemental.dbo.fn_join_composite_svc_cde(null,bc.BillingCode, cl.Modifier1, cl.Modifier2, cl.Modifier3, cl.Modifier4) CodeWMods
     , cl.fromdate, cl.RenderingProviderId, cl.RenderingProviderName, pos.CodeName POS, stat.codename Status
	  ,cl.ClaimLineId, c.claimid, cl.PayableAmount, cl.Charge, cl.PaidAmount, c.clientid, c.diagnosis1, c.diagnosis2, c.diagnosis3
	  , AllDX=isnull(c.diagnosis1,'')+' : '+isnull(c.diagnosis2,'')+' : '+isnull(c.diagnosis3,'')
	  , cl.StartTime, cl.EndTime,bc.billingcode, cl.CreatedDate, cl.CreatedBy, cl.modifieddate, cl.ModifiedBy
from claims c 
	 join claimlines cl on c.claimid=cl.ClaimId 
	 join billingcodes bc on cl.BillingCodeId=bc.BillingCodeId 
	 join sites s on c.SiteId=s.SiteId
     join globalcodes pos on cl.PlaceOfService=pos.GlobalCodeId
     join globalcodes stat on cl.status=stat.GlobalCodeId
where 1=1
GO



/*~ eligibile diagnosis list*/






/*~ services list without CCBHC DX*/
select top 1000 sd.ICD10Code, s.ProcedureCodeName, s.ProgramName, s.serviceid, s.clientid, s.DateOfService, d.PopulationName, d.PrimaryProgramName, d.PrimaryClinicianName
from servicediagnosis sd join kv_services s (nolock) on s.ServiceId=sd.ServiceId join kt_Demographics d on s.clientid=d.clientid
where 1=1
and s.DateOfService>='10/1/2021'
and StatusName in ('show','complete')
and s.Billable='Y'
and isnull(s.recorddeleted,'N')='N'
and isnull(sd.recorddeleted,'N')='N'
and procedurecodeid in (select IntegerCodeId from recodes r join RecodeCategories rc on r.RecodeCategoryId=rc.RecodeCategoryId
                         where rc.CategoryName like '%ccbhc%')
and exists (select * from kv_ClientCoverageHistory v 
 where s.clientid=v.clientid and v.CoveragePlanName like 'ccbhc%'
 and s.dateofservice between v.StartDate and v.EndDate)
and programname not like '%dco%'
and s.ServiceId not in
(select s.serviceid
from servicediagnosis sd join kv_services s on s.ServiceId=sd.ServiceId
where 1=1
and s.DateOfService>='10/1/2021'
and StatusName in ('show','complete')
and isnull(s.recorddeleted,'N')='N'
and isnull(sd.recorddeleted,'N')='N'
and procedurecodeid in (select IntegerCodeId from recodes r join RecodeCategories rc on r.RecodeCategoryId=rc.RecodeCategoryId
                         where rc.CategoryName like '%ccbhc%')
and ICD10Code like 'F%' and ICD10Code not like 'f[78]%'
and exists (select * from kv_ClientCoverageHistory v 
 where s.clientid=v.clientid and v.CoveragePlanName like 'ccbhc%'
 and s.dateofservice between v.StartDate and v.EndDate)
 )
order by s.programname, s.procedurecodename, s.clientid, s.serviceid 






create view kv_ReportExectionLog as
select r.name, r.ReportServerPath, s.DisplayAs, rel.* from ReportExecutionLog rel
join reports r on rel.reportid=r.reportid
join staff s on rel.StaffId=s.staffid
where 1=1
go
select top 10 * from kv_reportexecutionlog where CreatedDate<>modifieddate

select * from kv_ClientPrograms where EnrolledDate>'2/1/22'

select * from reports where name like '%enrolled%' and name like '%program%'

select * from staff where lastname='crotser' and isnull(TempClientId,0)=0

select * from coverageplans where MedicaidPlan='Y'  and isnull(recorddeleted,'N')='N'
and Capitated='N'



select top 10 * from ClientCoveragePlans
select * from kv_ClientMonthlyDeductibles
select top 100 * from kv_services
ksp_rpt_CCBHCServicesWOCCBHCdx  42

alter proc ksp_rpt_CCBHCServicesWOCCBHCdx (@ExecutedByStaffId int=4) as
begin
create TABLE #staffClients ([ClientId] [int])
insert into #staffClients
exec ksp_GetStaffClients  @ExecutedByStaffId

select sd.ICD10Code, s.ProcedureCodeName, s.ProgramName, s.serviceid, s.clientid, s.DateOfService, d.PopulationName, d.PrimaryProgramName, d.PrimaryClinicianName
from servicediagnosis sd join kv_services s (nolock) on s.ServiceId=sd.ServiceId join kt_Demographics d on s.clientid=d.clientid
where 1=1
and s.DateOfService>='10/1/2021'
and StatusName in ('show','complete')
and s.Billable='Y'
--and s.clientid in (select * from #staffClients)
and isnull(s.recorddeleted,'N')='N'
and isnull(sd.recorddeleted,'N')='N'
and procedurecodeid in (select IntegerCodeId from recodes r join RecodeCategories rc on r.RecodeCategoryId=rc.RecodeCategoryId
                         where rc.CategoryName like '%ccbhc%')
and exists (select * from kv_ClientCoverageHistory v 
 where s.clientid=v.clientid and v.CoveragePlanName like 'ccbhc%'
 and s.dateofservice between v.StartDate and v.EndDate)
and programname not like '%dco%'
and s.ServiceId not in
(select s.serviceid
from servicediagnosis sd join kv_services s on s.ServiceId=sd.ServiceId
where 1=1
and s.DateOfService>='10/1/2021'
and StatusName in ('show','complete')
and isnull(s.recorddeleted,'N')='N'
and isnull(sd.recorddeleted,'N')='N'
and procedurecodeid in (select IntegerCodeId from recodes r join RecodeCategories rc on r.RecodeCategoryId=rc.RecodeCategoryId
                         where rc.CategoryName like '%ccbhc%')
and ICD10Code like 'F%' and ICD10Code not like 'f[78]%'
and exists (select * from kv_ClientCoverageHistory v 
 where s.clientid=v.clientid and v.CoveragePlanName like 'ccbhc%'
 and s.dateofservice between v.StartDate and v.EndDate)
 )
order by s.programname, s.procedurecodename, s.clientid, s.serviceid 



