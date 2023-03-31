Use ISK_Reporting_development


-- Look-forward by 2 weeks

Declare 
@DaysFwd Int,
@DateStart Date = getdate()
SET @DaysFwd = 14   -- @DaysFwd  populates end date based on start (today)  All this can be changed if needed
Declare
@DateEnd Date = DateAdd(dd,@DaysFwd, getDate())
-- Look-forward by 2 weeks
Select V.StartDate, V.EndDate
into #T
from (
    VALUES
    (@DateStart,@DateEnd)
    ) as V(StartDate,EndDate) Select * from #T

/*
Kathy Lentz (she/her/hers) <klentz@iskzoo.org>; Nancy McDonald <NMcDonald@iskzoo.org>; Patricia Weighman <pweighman@iskzoo.org>
Appointments without Auths 
*/




-- Reference Excel
Select V.APTPUR, V.XSPID
into #AptPurposeToAuthCode
from (
	VALUES
	(18640,11761),(19020,11762),(19023,11763),(19015,11764),(18641,11794),(18643,11810),(18721,11819),(10562,11821),(19019,11829),(19926,11860),(19926,11861),(18642,11869),(18645,11870),(10562,11870),(18645,11873),(18643,11874),(10562,11874),(18648,11875),(18721,11876),(19017,11876),(19258,11888),(10565,11931),(10565,11932),(18648,12003),(18642,12007),(19023,12146)
	) as V(APTPUR,XSPID)



-- All upcoming appointments during the date range in "scheduled" status, and where the purpose is one where I think an auth is needed
Select distinct AP_RCDID
	, CaseNumber = APF_CLTID
	, ApptDate = cast(AP_APTDT as date)
	, ApptTime = timefromparts( AP_BEGTM / 100, AP_BEGTM % 100, 0, 0, 0 )
	, APTPUR
	, ApptPurpose = pr.CO_SDESCR
	, Staff = isnull(ST_FNAME + ' ' + ST_LNAME,'')
	, Program = isnull(PR_NAME,'')
	, ApptStatus = st.CO_SDESCR
into #Appts
from PCHAPTPF
join #T as t on AP_APTDT >= t.StartDate and AP_APTDT < t.EndDate
join #AptPurposeToAuthCode as apac on APF_APTPUR = apac.APTPUR
join CODCODPF as pr on APF_APTPUR = pr.CO_RCDID
left join PCHSTFPF on APF_STFID = ST_RCDID
left join PCHPRVPF on APF_PRVID = PR_RCDID
join CODCODPF as st
	on APF_APTSTS = st.CO_RCDID
	-- Looking for which USRVAL we want: ( Select * from CODCODPF where COF_CATID = 10024 )
	and st.CO_USRVAL in ('0       ','TENATV  ')
where AP_TYPE = 'N'
and APF_CLTID is not null


-- Find likely-related auths
Select distinct a.AP_RCDID, AuthStatus = rtrim(CO_SDESCR)
into #HasAuth
from #Appts as a
join #AptPurposeToAuthCode as apac on a.APTPUR = apac.APTPUR
join PCHAUDPF 
	on apac.XSPID = ADF_XSPID
	and a.ApptDate between AD_EFFDT and AD_EXPDT
	and isnull(AD_PAYSTS,'') not in ('V','X')
join PCHAUHPF 
	on ADF_AUHID = AH_RCDID
	and AHF_CLTID = a.CaseNumber
join CODCODPF
	on AHF_AUHSTS = CO_RCDID
	and CO_SDESCR not in ('Denied','Void')



Delete a
from #Appts as a
where a.AP_RCDID in ( Select AP_RCDID from #HasAuth where AuthStatus = 'Approved' )


-- Level of care - for pulling out IDDA
;
With SortedLOC as (
	SELECT distinct 
	  CaseNumber = DCF_CLTID,
	  Sort = row_number() over ( partition by DCF_CLTID order by DC_DOCDT desc, DC_RCDID desc ),
	  DC_RCDID, LOC = CO_SDESCR
	  FROM #Appts
	  join PCHDOCPF on CaseNumber = DCF_CLTID
	  join KZOLCRPF ON DC_RCDID = LCP_DOCID -- Level of Care
	  JOIN CODCODPF ON CO_RCDID = COALESCE(LCF_LVLCAR, LCF_LVLREC)
	  WHERE DC_STATUS = 'A'
		AND LC_OKTOUSE = 'Y'
)
Select CaseNumber, LOC
into #LOC
from SortedLOC
where Sort = 1


-- Add client information & output
Select a.CaseNumber
	, ClientName = coalesce(CA_PREFNM,CL_FNAME) + ' ' + CL_LNAME
	, PrimaryProgram = coalesce(PR_ABVNAME,PR_NAME)
	, AgeGroup = ( CASE WHEN dateadd(year,18,CL_DOB) > getdate() THEN 'Youth' ELSE 'Adult' END ) -- Adults with F&CS primary program = IDDA
	, LOC = isnull(loc.LOC,'None')
	, PrimaryClinician = ST_FNAME + ' ' + ST_LNAME
	, a.ApptDate, a.ApptTime, a.ApptPurpose, a.Staff, a.Program, a.ApptStatus
	, AuthStatus = isnull(au.AuthStatus,'None')
from #Appts as a
join PCHCLTPF on a.CaseNumber = CL_RCDID
left join PCHCADPF on CLF_CADID = CA_RCDID
left join KZOCADPF on CA_RCDID = CAP_CADID -- preferred name stored here
left join PCHPRVPF on CLF_PRVID = PR_RCDID
left join PCHSTFPF on CLF_STFID = ST_RCDID
left join #LOC as loc on a.CaseNumber = loc.CaseNumber
left join #HasAuth as au on a.AP_RCDID = au.AP_RCDID
where isnull(CL_STATUS,'N') != 'D'
and isnull(CL_TESTCLT,'N') = 'N'
order by coalesce(PR_ABVNAME,PR_NAME), a.ApptDate, a.ApptPurpose, a.CaseNumber


