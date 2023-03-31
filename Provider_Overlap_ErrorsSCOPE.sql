USE DATAKZO_ISK_Supplemental


select * from EDICLAPF where ca_adjnote like 'Duplicate and/or conflicting service previously claimed on this date of service.%'

SELECT 
	 CA_UPDDATE AS 'dateUserChg'
	,CA_RCVDT AS 'receivedDate'
	,CAF_CLMID AS 'ClaimID'
	,CAF_CLDID AS 'ClaimDetailID'
	,CAF_CLSID AS 'ClaimSubscriberPayer'
	,CAF_BICID AS 'BatchInvoice'
	,CA_THRDT AS 'serviceDateThru'
	,CA_RECON AS 'reconsideredClaim'
	,CA_ADJRSN AS 'adjustmentReason'
	,CA_ADJQTY AS 'adjustmentQuantity'
	,CAF_PFSID AS 'FeeSchedule'
	,CAF_CAIID AS 'ClaimAccountInfo'
	,CA_OVRRIDE AS 'overrideFlag'
	,CA_RECONP AS 'reconsideredClaimPaid'
	,CA_FRMDT AS 'serviceDateFrom'
	,CAF_ADDUSR AS 'UserAdd'
	,CA_ADJTYP AS 'adjustmentType'
	,CAF_UPDUSR AS 'UserChg'
	,CA_PAYAMT AS 'paidAmount'
	,CA_ALWAMT AS 'allowedAmount'
	,CA_ADJDT AS 'adjustmentDate'
	,CA_ADJNOTE AS 'adjustmentNote'
	,CAF_AUDID AS 'AuthorizationDetail'
	,CA_RCDID AS 'claimAdjustmentID'
	,CAF_PBHID AS 'PaymentBatchHeader'
	,CA_ADDDATE AS 'dateUserAdd'
	,CAF_INSID AS 'InsuranceCompany'
	,CA_ADJREF AS 'adjustmentReference'
	,CAF_DENYCD AS 'DenialCode'
FROM EDICLAPF
	WHERE ca_adjnote like 'Duplicate and/or conflicting service previously claimed on this date of service.%'


SELECT 
	 CA_UPDDATE AS 'dateUserChg'
	,CA_RCVDT AS 'receivedDate'
	,CAF_CLMID AS 'ClaimID'
	,CAF_CLDID AS 'ClaimDetailID'
	,CAF_CLSID AS 'ClaimSubscriberPayer'
	,CAF_BICID AS 'BatchInvoice'
	,CA_THRDT AS 'serviceDateThru'
	,CA_RECON AS 'reconsideredClaim'
	,CA_ADJRSN AS 'adjustmentReason'
	,CA_ADJQTY AS 'adjustmentQuantity'
	,CAF_PFSID AS 'FeeSchedule'
	,CAF_CAIID AS 'ClaimAccountInfo'
	,CA_OVRRIDE AS 'overrideFlag'
	,CA_RECONP AS 'reconsideredClaimPaid'
	,CA_FRMDT AS 'serviceDateFrom'
	,CAF_ADDUSR AS 'UserAdd'
	,CA_ADJTYP AS 'adjustmentType'
	,CAF_UPDUSR AS 'UserChg'
	,CA_PAYAMT AS 'paidAmount'
	,CA_ALWAMT AS 'allowedAmount'
	,CA_ADJDT AS 'adjustmentDate'
	,CA_ADJNOTE AS 'adjustmentNote'
	,CAF_AUDID AS 'AuthorizationDetail'
	,CA_RCDID AS 'claimAdjustmentID'
	,CAF_PBHID AS 'PaymentBatchHeader'
	,CA_ADDDATE AS 'dateUserAdd'
	,CAF_INSID AS 'InsuranceCompany'
	,CA_ADJREF AS 'adjustmentReference'
	,CAF_DENYCD AS 'DenialCode'
into #test1 FROM EDICLAPF 
	WHERE ca_adjnote like 'Duplicate and/or conflicting service previously claimed on this date of service.%'

SELECT * fROM #test1

/*
	Let's tell a story
	We start with EDICLAPF which contains the physical Errors
	Then we connect EDICLAPF to EDICLMPF with claimID to CH_RCDID <--This is for all your fun consumers data
	Then we connect EDICLMPF to "ToProvider" which is actual provider data on PR_RCDID to CHF_PRVID FK
	So EDICLMPF connects to PCHPRVPF thru join from PR_RCDID
*/

select * from EDICLMPF


--so this contains PROGRAM or provider w/e you want to call it!
select * from PCHPRVPF


--So Just 1 Join to EDICLMPF will contain TONS of individual / provider details we are really looking for.
SELECT * fROM #test1 AS T1
LEFT JOIN EDICLMPF AS E1 ON T1.ClaimID = CH_RCDID
WHERE adjustmentNote LIKE '%Duplicate and/or conflicting service previously claimed on this date of service. (See claim%'



SELECT TOP 100* FROM EDICLMPF


--So this isolates the overlap errors with Claims
SELECT * fROM #test1 AS T1
LEFT JOIN EDICLMPF AS E1 ON T1.ClaimID = CH_RCDID
WHERE adjustmentNote LIKE '%Duplicate and/or conflicting service previously claimed on this date of service. (See claim%'




--This isolates the overlap errors with Services
SELECT * fROM #test1 T2
LEFT JOIN EDICLMPF AS E2 ON T2.ClaimID = E2.CH_RCDID
WHERE adjustmentNote LIKE 'Duplicate and/or conflicting service previously claimed on this date of service. (See SAL%'

EDICLMPF






select ClaimID,serviceDateFrom,serviceDateThru from #test1
group by ClaimID,serviceDateFrom,serviceDateThru
order by ClaimID asc

select ClaimID from #test1
group by ClaimID
order by ClaimID asc

select ClaimID,serviceDateFrom,serviceDateThru,adjustmentReason from #test1
group by ClaimID,serviceDateFrom,serviceDateThru,adjustmentReason
order by ClaimID asc

SELECT

