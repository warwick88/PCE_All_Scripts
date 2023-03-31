USE kcmhsasSupplemental


select top 100 v_eligibility where SocSecNum='366786263' order by 1 desc


SELECT TOP 100* FROM v_eligibility
WHERE SocSecNum LIKE '366786263'
ORDER BY CreateDate DESC

SELECT TOP 100* FROM v_eligibility
WHERE SocSecNum LIKE '366786263'

--So there are two clients listed under this insured ID. But when I see the list in here I only really see results for 1 client
--Denise Greene, so How do I confirm who is actually right? More importantly, what is done to fix it?
SELECT * FROM v_eligibility
WHERE PrimaryIdentifier LIKE '0000983138'
ORDER BY CreateDate DESC

--So say we keep Denise as she is populating a lot, how do I fix Rachel Buck?




















select distinct ccp.insuredid, ccp.clientid, c.Active, c.dob, c.lastname, c.firstname, ccp2.clientid, cp2.CoveragePlanName	
from clientcoverageplans ccp join coverageplans cp on ccp.CoveragePlanId=cp.CoveragePlanId and cp.MedicaidPlan='Y' and cp.Active='Y' join clients c on ccp.clientid=c.ClientId and c.MasterRecord='Y'	
     join clientcoverageplans ccp2 on ccp.clientid<> ccp2.clientid and ccp.InsuredId=ccp2.InsuredId	
 join coverageplans cp2 on ccp2.CoveragePlanId=cp2.CoveragePlanId and cp2.medicaidplan='Y' and cp2.Active='Y' join clients c2 on ccp2.clientid=c2.ClientId and c2.MasterRecord='Y'	
where 1=1	
and ccp.clientid not in (select clientid from #dupclientbyssn)	
and isnull(c.recorddeleted,'N')='N'	
and ccp.clientid<>ccp2.clientid	
and .dbo.ssf_IsValidMedicaidId(ccp.insuredid)=1	
and .dbo.ssf_IsValidMedicaidId(ccp2.insuredid)=1	
and c.active='Y'	
and c2.active='Y'	
order by ccp.InsuredId	