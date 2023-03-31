use SmartCarePreProd





/*
	Below are scripts Ed has attached to assist with this process.

*/

/*~ claimlines without ccbhc dx*/
select sitename, clientid, FromDate, codewmods, AllDx, claimlineid, claimid
  ,status, createddate, createdby, modifieddate, modifiedby
from v_claimlines 
where 1=1
and fromdate>='10/1/2021'
and sitename like '%DCO%'
and status<>'Denied'
and (isnull(diagnosis1,'')  not like 'f%' or isnull(diagnosis1,'') like 'f[78]%')
and (isnull(diagnosis2,'')  not like 'f%' or isnull(diagnosis2,'') like 'f[78]%')
and (isnull(diagnosis3,'')  not like 'f%' or isnull(diagnosis3,'') like 'f[78]%')
order by sitename, clientid, fromdate


/*~ eligibile diagnosis list*/
select d.icd10code, d.ICDDescription, CMSFiscalYear 
from DiagnosisICD10Codes d left join ICD10FiscalYearAvailability a on d.ICD10Code=a.ICD10Code and a.CMSFiscalYear=2022
where isnull(billableflag,'N')='Y' 
and d.ICD10Code like 'F%' and d.ICD10Code not like 'F[78]%'
order by a.icd10code
go

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
