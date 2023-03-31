use ProdSmartCare
/*
SELECT *
FROM Staff as stftocvt 
where (RecordDeleted is null or RecordDeleted = 'N') and UserCode is not null 
and (EHRUser = 'Y') 
and (Active = 'Y' or SureScriptsPrescriberId is not null or exists (select 1 from ClientMedications as stfmeds where stfmeds.PrescriberId = stftocvt.StaffId and IsNull(stfmeds.RecordDeleted,'N')='N')) 
and lower(coalesce(email,'')) not like '%streamline%'
*/

USE ProdSmartCare

SELECT *
FROM Staff as stftocvt
where (RecordDeleted is null or RecordDeleted = 'N') and UserCode is not null
and (EHRUser = 'Y')
and (Active = 'Y' or SureScriptsPrescriberId is not null or exists (select 1 from ClientMedications as stfmeds where stfmeds.PrescriberId = stftocvt.StaffId and IsNull(stfmeds.RecordDeleted,'N')='N'))
and lower(coalesce(email,'')) not like '%streamline%'


SELECT *
INTO #TEMP1 FROM Staff as stftocvt
where (RecordDeleted is null or RecordDeleted = 'N') and UserCode is not null
and (EHRUser = 'Y')
and (Active = 'Y' or SureScriptsPrescriberId is not null or exists (select 1 from ClientMedications as stfmeds where stfmeds.PrescriberId = stftocvt.StaffId and IsNull(stfmeds.RecordDeleted,'N')='N'))
and lower(coalesce(email,'')) not like '%streamline%'



select * INTO #TEST2 from staff
where lastvisit > '10-01-2021'


SELECT * FROM #TEST2
WHERE STAFFID NOT IN(SELECT STAFFID FROM #TEMP1)
ORDER BY LASTVISIT DESC


SELECT * into #TEST3 FROM #TEST2
WHERE STAFFID NOT IN(SELECT STAFFID FROM #TEMP1)
ORDER BY LASTVISIT DESC




select * into #temp15 from (
select * from #TEMP1
union ALL
select * from #TEST3
) as tempx



SELECT * FROM #temp15
where usercode not like '%Test%'
and usercode not like '%delete%'



