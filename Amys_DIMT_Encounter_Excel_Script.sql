
-- use datakzo

Select V.TimePeriod, V.StartDate, V.EndDate
into #T
from (
	VALUES
	('Thru Feb','2022-10-01','2023-03-01')
	) as V(TimePeriod,StartDate,EndDate)


-- Base table: All rendered services and claims


-- Data source 1: Completed SALs
Select ClientId = SAF_CLTID
	, DateOfService = cast(SA_SRVDATE AS DATE)
	, ServiceCode = cast(CR_CODE as varchar(64))
	, DataSource = cast('1 - SAL' as varchar(64))
	, SourceId = SA_RCDID
into #SALs
from PCHSALPF
join #T as t on SA_SRVDATE >= t.StartDate and SA_SRVDATE < t.EndDate
join PCHXSPPF on XP_RCDID = SAF_XSPID
join PCHCPTPF on CR_RCDID = XPF_CPTID
where isnull(SA_BILSTS,'') <> 'U'
and isnull(SA_STATUS,'') <> 'D'
and SA_FACE = 'Y'
and SA_OKTOUSE = 'Y'
and CR_CODE <> 'T1040' -- handled separately


-- Data source 2: Submitted claims
-- Known issue needing fixed: Imperfect matching claims-to-SALs when multiple different services rendered on the same date with the same proc code. Not sure how to do this right given that some claims don't have start/stop times
-- Also multiday claims may not be correctly matched on FRMDT alone, if any of those are supposed to have SALs as well
Select ClientId = CDF_CLTID
	, DateOfService = cast(CD_FRMDT as date)
	, ServiceCode = isnull(CD_REVCD, CD_PROCCD)
	, DataSource = '2 - Provider claim'
	, SourceId = CD_RCDID
into #Claims
from EDICLDPF
join #T as t on CD_FRMDT >= t.StartDate and CD_FRMDT < t.EndDate
join EDICLMPF on CDF_CLMID = CH_RCDID
left join #SALs as s
	on CDF_CLTID = s.ClientId
	and cast(CD_FRMDT as date) = s.DateOfService
	and CD_PROCCD = s.ServiceCode
where isnull(CH_CLMTYP, '') != 'HE' -- outbound claims
and isnull(CH_CLMSTS, '') != 'V' -- voided
and isnull(CD_STATUS,'') <> 'V' -- voided
and s.SourceId is null -- not already captured by a found SAL


-- Data source 3: Note that is usually billable but has no SAL
-- Known issue with different logic for Group Notes, just ignoring those for now until I figure it out
/* 
-- Finding the right list of doc types
Select DCF_DOCTYP, CO_SDESCR
	, NBillable = count(distinct CASE WHEN isnull(SA_BILSTS,'') <> 'U' and SA_FACE = 'Y'
								THEN SA_RCDID ELSE null END
						)
	, NNonbillable = count(distinct CASE WHEN isnull(SA_BILSTS,'') <> 'U' and SA_FACE = 'Y'
								THEN null ELSE SA_RCDID END
							)
from PCHSALPF
join PCHDOCPF on SAF_DOCID = DC_RCDID
join CODCODPF on DCF_DOCTYP = CO_RCDID
where isnull(SA_STATUS,'') <> 'D' and SA_OKTOUSE = 'Y'
group by DCF_DOCTYP, CO_SDESCR
order by count(SA_RCDID) desc
*/
;
With UsuallyBillableNotes as (
	Select V.DOCTYP, V.DocDescr
	from (
		VALUES
		('13980','Progress Note'),('16379','Psychiatric E&M Note'),('14373','Injection / Med Admin Note'),('13959','Assessment'),('15255','IPOS'),/*('15248','Group Note'),*/('16671','Crisis Intervention'),/*('16367','DBT Group Note'),*/('15346','Pre-Admission Screening'),/*('17086','Peer Support Group Note'),*/('18902','Nursing Progress Note')
		) as V(DOCTYP,DocDescr)
)
Select ClientId = DCF_CLTID
	, DateOfService = cast(DC_DOCDT as date) -- extremely rare for this to not match SA_SRVDATE once a SAL is created
	, ServiceCode = DocDescr
	, DataSource = '3 - Billable note without SAL'
	, SourceId = DC_RCDID
into #Notes
from PCHDOCPF
join UsuallyBillableNotes on DCF_DOCTYP = DOCTYP
left join PCHSALPF
	on SAF_DOCID = DC_RCDID
	and isnull(SA_STATUS,'') <> 'D'
	and SA_OKTOUSE = 'Y'
left join #Claims
	on DCF_CLTID = ClientId
	and cast(DC_DOCDT as date) = DateOfService
where DC_STATUS = 'A'
and SA_RCDID is null -- no matching SAL found
and SourceId is null -- no ~matching claim found, to avoid duplicating. Maybe Notes should come first in the priority order??


/*
-- Too hard to get it to work right ... never mind for now
-- Data source 4: Workflow without note
;
With WorkflowDocs as (
	Select V.DOCTYP, v.DocDescr
	from (
		VALUES
		('17085','Psychiatric Visit') -- ok these other ones are too messy, just do Psych visits for now --,('18385','Intake Workflow'),('19146','Annual Workflow'),('19714','SUD Intake Workflow'),('19715','SUD Annual Workflow')
		) as V(DOCTYP,DocDescr)
)
Select ClientId = w.DCF_CLTID
	, DateOfService = cast(w.DC_DOCDT as date) -- extremely rare for this to not match SA_SRVDATE once a SAL is created
	, ServiceCode = DocDescr
	, DataSource = '4 - Psych Visit without note'
	, SourceId = w.DC_RCDID
	, CCBHC = 0
	, HasT1040SameDay = 0
from PCHDOCPF as w -- workflows base table
join #T as t on DC_DOCDT >= t.StartDate and DC_DOCDT < t.EndDate
join WorkflowDocs on DCF_DOCTYP = DOCTYP
left join SHLWXRPF -- crosswalk between Workflows and their specific steps
	on w.DC_RCDID = WX_PSRCRCD
	and WX_SRCFILE in ('KZOINTPF','KZOPSNPF') -- pulling out the steps that have either an Assessment or E&M Note associated
left join PCHDOCPF as d -- making sure those associated documents are active
	on WX_SRCRCD = d.DC_RCDID
	and d.DC_STATUS = 'A'
left join #RenderedServices as s -- very imperfect
	on w.DCF_CLTID = ClientId
	and w.DC_DOCDT = DateOfService
where w.DC_STATUS = 'A'
and d.DC_RCDID is null -- no associated document found
and SourceId is null
order by w.DCF_CLTID
*/


-- Data source 4: Appointment kept which is usually billable, but no documentation (known imperfect matching)
-- Also ignoring Group appointments here until I figure them out
/*
-- For finding the right list of appointment types
-- All "appointment purposes" in use and the codes that went with them in SC conversion
Select distinct 
	APF_APTPUR
	, ApptPurpose = pr.CO_SDESCR
	, CR_CODE
	, max(APF_CLTID)
from PCHAPTPF
join CODCODPF as pr on APF_APTPUR = pr.CO_RCDID
left join PCHXSPPF on APF_XSPID = XP_RCDID
left join PCHCPTPF on XPF_CPTID = CR_RCDID
where AP_TYPE = 'N'
and APF_CLTID is not null
group by APF_APTPUR, pr.CO_SDESCR, CR_CODE
order by APF_APTPUR, CR_CODE
*/
;
With OftenNonbillableAppts as (
	Select V.APTPUR, V.ApptPurposeDescr
	from (
		VALUES
		('10562','Group/Class Session') -- temporary until I figure out how to handle them
		,('10568','Other'),('19704','SIS Assessment'),('19901','LOCUS Assessment')
		) as V(APTPUR,ApptPurposeDescr)
)
Select ClientId = APF_CLTID
	, DateOfService = cast(AP_APTDT as date)
	, ServiceCode = CO_SDESCR
	, DataSource = '4 - Kept appointment with no note'
	, SourceId = AP_RCDID
into #Appts
from PCHAPTPF
join #T as t on AP_APTDT >= t.StartDate and AP_APTDT < t.EndDate
join CODCODPF on APF_APTPUR = CO_RCDID
left join OftenNonbillableAppts on APF_APTPUR = APTPUR
left join #SALs as s
	on APF_CLTID = s.ClientId
	and cast(AP_APTDT as date) = s.DateOfService
left join #Notes as n
	on APF_CLTID = n.ClientId
	and cast(AP_APTDT as date) = n.DateOfService
where AP_TYPE = 'N'
and APF_CLTID is not null
and APF_APTSTS = 13812 -- kept
and APTPUR is null -- not an appt type that is often non-billable
and coalesce(s.SourceId,n.SourceId) is null -- doesn't have evidence that we already know about, SAL or billable note (will miss if they actually have two different services on the same day, one with a SAL and one where it's only "appt kept")
and not exists ( -- if they have a non-billable note actually linked to the appt then assume it was legitimately non-billable, to reduce false positives
	Select 1
	from PCHDOCPF
	where DCF_APTID = AP_RCDID
	)



Select ConstructedUniqueId = Identity(int)
	, q.*
	, HasTPLEncounter = 0
	, EncounterGenerated = 0
	, EncounterId = 0
	, EncounterAcceptedSWMBH = 0
	, CCBHC = 0
	, HasT1040SAL = 0
	, HasT1040Encounter = 0
	, T1040EncounterId = 0
	, T1040EncAcceptedSWMBH = 0
into #RenderedServices
from (
	Select * from #SALs
	Union
	Select * from #Claims
	Union
	Select * from #Notes
	Union
	Select * from #Appts
	) as q


Delete s
from #RenderedServices as s
join PCHCLTPF on s.ClientId = CL_RCDID and CL_TESTCLT = 'Y'



-- Determine whether each service is CCBHC-eligible
-- For now, just sloppily using the T1040 = Will fail to catch if there are problems with T1040s getting generated in the first place.
-- Better way will be: Look for presence of CCBHC Demonstration "insurance", plus if the code is a CCBHC-eligible procedure code
Select distinct ClientId = SAF_CLTID
	, DateOfService = cast(SA_SRVDATE AS DATE)
into #T1040SALs
from PCHSALPF
join #T as t on SA_SRVDATE >= t.StartDate and SA_SRVDATE < t.EndDate
join PCHXSPPF on XP_RCDID = SAF_XSPID
join PCHCPTPF on CR_RCDID = XPF_CPTID
where isnull(SA_BILSTS,'') <> 'U'
and isnull(SA_STATUS,'') <> 'D'
and SA_FACE = 'Y'
and SA_OKTOUSE = 'Y'
and CR_CODE = 'T1040'


-- This is also filling in "CCBHC" wrong in cases where they have a non-CCBHC service on the same day as a CCBHC service
Update s
Set s.CCBHC = 1, s.HasT1040SAL = 1
from #RenderedServices as s
join #T1040SALs as t on s.ClientId = t.ClientId and s.DateOfService = t.DateOfService


-- Marking the SALs that have a TPL encounter. If they are missing a Caid encounter then the TPL might be the hangup
Update s
Set s.HasTPLEncounter = 1
from #RenderedServices as s
join PCHSALPF on left(s.DataSource,1) = '1' and s.SourceId = SA_RCDID and SAF_CLDBID is not null


-- Determine whether each rendered service has an associated Encounter. This is only possible when a SAL or Claim exists.
-- By the below method DCO data will often be wrong when there is a SAL without a Claim or vice versa. Needs cleanup later

-- SAL has encounter
Update s
Set s.EncounterGenerated = 1, s.EncounterId = SAF_CLMID
from #RenderedServices as s
join PCHSALPF on left(s.DataSource,1) = '1' and s.SourceId = SA_RCDID
join EDICLMPF on SAF_CLMID = CH_RCDID
where CH_CLMTYP = 'HE' -- outbound

-- Claim has encounter
Update s
Set s.EncounterGenerated = 1, s.EncounterId = e.CH_RCDID
from #RenderedServices as s
join EDICLDPF on left(s.DataSource,1) = '2' and s.SourceId = CD_RCDID
join EDICLMPF as c on CDF_CLMID = c.CH_RCDID -- provider claim
join EDICLMPF as e on c.CHF_CLMID = e.CH_RCDID -- outbound encounter
where e.CH_CLMTYP = 'HE' -- outbound

-- Service-day has a T1040 encounter on the same day
Update s
Set s.HasT1040Encounter = 1, s.T1040EncounterId = e.CH_RCDID
from #RenderedServices as s
join EDICLDPF
	on s.ClientId = CDF_CLTID
	and s.DateOfService = CD_FRMDT
	and CD_PROCCD = 'T1040'
join EDICLMPF as e 
	on CDF_CLMID = e.CH_RCDID
	and e.CH_CLMTYP = 'HE'




-- Accepted encounters according to SWMBH
Select e.ClaimReferenceNumber
	, SourceId = convert(float, right(e.ClaimReferenceNumber,9))
into #SwmbhAccepted
from [ISK_DataLake].[dbo].[AcceptedEncounters_2023] as e
join #T as t on e.ServiceStartDate >= t.StartDate and e.ServiceStartDate < t.EndDate
where e.ProcedureCode != 'T1040'

select * from #SwmbhAccepted

Create index ix_srcid on #SwmbhAccepted ([SourceId] asc)


Update s
Set s.EncounterAcceptedSWMBH = 1
from #RenderedServices as s
join #SwmbhAccepted as e
	on e.SourceId = s.EncounterId



-- Accepted T1040s
Select e.ClaimReferenceNumber
	, SourceId = convert(float, right(e.ClaimReferenceNumber,9))
	, e.ClientId, DateOfService = e.ServiceStartDate
into #SwmbhAcceptedT1040
from [ISK_DataLake].[dbo].[AcceptedEncounters_2023] as e
join #T as t on e.ServiceStartDate >= t.StartDate and e.ServiceStartDate < t.EndDate
where e.ProcedureCode = 'T1040'

Create index ix_srcid on #SwmbhAcceptedT1040 ([SourceId] asc)


Update s
Set s.T1040EncAcceptedSWMBH = 1
from #RenderedServices as s
join #SwmbhAcceptedT1040 as e
	on e.SourceId = s.EncounterId





/*
-- Errors, etc too much to figure out right now
-- Start by just reporting difference btw services rendered & enc generated
Select top 1000 *
from #RenderedServices
join EDIERRPF on SourceId in (ERF_CLMID,ERF_SALID)

Select top 100 * from EDIERRPF
*/

/*
	So this table below is the NON-CCBHC Table
	So this result EncounterAccepted goes into row 8 total non ccbhc services excel tab
	this query gives you all the results you need on that tab.
*/

Select NonCCBHCTotal = count(s.ConstructedUniqueId)
	, ApptNoNote = sum( CASE WHEN left(s.DataSource,1) = '4' THEN 1 ELSE 0 END )
	, NoteNoSAL = sum( CASE WHEN left(s.DataSource,1) = '3' THEN 1 ELSE 0 END )
	, EncounterGenerated = sum(s.EncounterGenerated)
	, EncounterAccepted = sum(s.EncounterAcceptedSWMBH)
from #RenderedServices as s
where s.CCBHC = 0

/*
	CCBHC Tab data generation is found here.
*/

Select s.ClientId, s.DateOfService
	, DataSource = min(s.DataSource)
	, HasT1040SAL = max(HasT1040SAL)
	, HasTPLEncounter = max(HasTPLEncounter)
	, EncounterGenerated = max(EncounterGenerated)
	, EncounterAcceptedSWMBH = max(EncounterAcceptedSWMBH)
	, HasT1040Encounter = max(HasT1040Encounter)
	, T1040EncAcceptedSWMBH = max(T1040EncAcceptedSWMBH)
	, ReportingLine = cast(null as varchar(128))
into #CCBHCDistinctDays
from #RenderedServices as s
where CCBHC = 1 or HasT1040Encounter = 1
group by s.ClientId, s.DateOfService




Update s
Set s.ReportingLine = '08 Enc but no T1040'
from #CCBHCDistinctDays as s
where s.EncounterGenerated = 1
and s.HasT1040Encounter = 0


Update s
Set s.ReportingLine = '06 TPL enc and no Caid enc'
from #CCBHCDistinctDays as s
where s.HasTPLEncounter = 1
and s.ReportingLine is null


Update s
Set s.ReportingLine = '07 No enc gen, other reason'
from #CCBHCDistinctDays as s
where s.EncounterGenerated = 0
and s.ReportingLine is null


Update s
Set s.ReportingLine = '11 Accepted by SWMBH but no T1040'
from #CCBHCDistinctDays as s
where s.EncounterAcceptedSWMBH = 1



Update s
Set s.ReportingLine = '12 Accepted by SWMBH with T1040'
from #CCBHCDistinctDays as s
where s.EncounterAcceptedSWMBH = 1
and s.T1040EncAcceptedSWMBH = 1

/*
	This first query is the top result in CCBHC tab "Total Distinct CCBHC Service-Days total:
*/
Select count(*) from #CCBHCDistinctDays

/*
	
*/
Select s.ReportingLine, count(s.DateOfService)
from #CCBHCDistinctDays as s
group by s.ReportingLine
order by s.ReportingLine


-- People interested in detail data 3/22
Select s.ClientId, s.DateOfService, NoteType = s.ServiceCode, s.DataSource, DocumentId = s.SourceId
from #RenderedServices as s
where s.DataSource like '%billable%note%'


/*
	This has the client IT, date of service and reporting line. So an Ideal front end will look like this excel data
	and when you click on line 6 you will see the detail line
	So yes line 6 would open up, summary table then to detail.

*/
SELECT * FROM #CCBHCDistinctDays

/*
	This temp table is the supporting info Amy already built, so you want to know client ID, the date of service, data source etc.
*/
select * from #RenderedServices