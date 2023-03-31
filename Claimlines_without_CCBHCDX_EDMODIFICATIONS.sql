USE ProdSmartCare

select sitename, clientid, FromDate, codewmods, AllDx, x.claimlineid, claimid, diagnosis1, diagnosis2
,status, x.createddate, x.createdby, x.modifieddate, x.modifiedby, clsm.ServiceId, clsm.CreatedDate ServiceFromClaimDate
from v_claimlines x left join ClaimLineServiceMappings clsm on x.ClaimLineId=clsm.ClaimLineId
where 1=1
and fromdate>='10/1/2021'
and sitename like '%DCO%'
and status<>'Denied'
and (isnull(diagnosis1,'') not like 'f%' or isnull(diagnosis1,'') like 'f[78]%')
and (isnull(diagnosis2,'') not like 'f%' or isnull(diagnosis2,'') like 'f[78]%')
and (isnull(diagnosis3,'') not like 'f%' or isnull(diagnosis3,'') like 'f[78]%')
order by sitename, clientid, fromdate