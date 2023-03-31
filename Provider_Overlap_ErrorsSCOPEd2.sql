USE DATAKZO_ISK_Supplemental


/*
	This will target all the overlapping claims, but it shows claims multiple times because of their ranges
	so 10/4-10/6 will have 2-3 claim line days, so it over represents the problematic claims
	you will need to at the very end aggregate by claim ID so it does not over represent
	1893 should turn into about 250.

	We have claim ID we must join to get consumer info, provider info, and finally the overlapping claim that is associated
	so we can see WHAT provider is overlapping and what CPT code etc.

*/

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
into #TEST1 FROM EDICLAPF 
	WHERE ca_adjnote like 'Duplicate and/or conflicting service previously claimed on this date of service.%'

SELECT * fROM #TEST1 

/*
	Let's tell a story
	We start with EDICLAPF which contains the physical Errors
	Then we connect EDICLAPF to EDICLMPF with claimID to CH_RCDID <--This is for all your fun consumers data
	Then we connect EDICLMPF to "ToProvider" which is actual provider data on PR_RCDID to CHF_PRVID FK
	So EDICLMPF connects to PCHPRVPF thru join from PR_RCDID
*/

SELECT 
	t1.*
	,E1.CH_PTFNM AS 'FirstName' 
	,E1.CH_PTLNM AS 'LastName'
	,E1.CHF_PRVID 
FROM #TEST1 T1    --HERE Originally T1.ClaimID was CAF_CLMID that is how it's joined above.
LEFT JOIN EDICLMPF AS E1 ON T1.ClaimID = CH_RCDID

SELECT 
	t1.*
	,E1.CH_PTFNM AS 'FirstName' 
	,E1.CH_PTLNM AS 'LastName'
	,E1.CHF_PRVID 
INTO #TEST2 FROM #TEST1 T1    --HERE Originally T1.ClaimID was CAF_CLMID that is how it's joined above.
LEFT JOIN EDICLMPF AS E1 ON T1.ClaimID = CH_RCDID

--DROP TABLE #TEST1
--drop table #TEST2


--This select completes the left hand side of our analysis. We will isolate this into a temp table
SELECT T2.*
	,E2.PR_NAME AS 'ProviderName'
	,E2.PR_NPI AS 'ProviderNPI'
INTO #TEST3 FROM #TEST2 T2
LEFT JOIN PCHPRVPF AS E2 ON T2.CHF_PRVID = E2.PR_RCDID 


--We are down to the final part, isolating the provider agency that it's overlapping with.
--So there are a few columns with our perpetrator.
--
SELECT * FROM #TEST3



--Replace target your Column, and then replace that rubbish with ''
--SELECT claimid,adjustmentreason,adjustmentnote FROM #TEST3

--So we have split this into two buckets, Claim ID and SAL versions
SELECT * INTO #CLAIMOVERLAP FROM #TEST3 
WHERE adjustmentNote LIKE '%Duplicate and/or conflicting service previously claimed on this date of service. (See claim%'




--This isolates the overlap errors with Services
SELECT * into #SALOVERLAP fROM #TEST3
WHERE adjustmentNote LIKE 'Duplicate and/or conflicting service previously claimed on this date of service. (See SAL%'

--SELECT * FROM #CLAIMOVERLAP
--SELECT * FROM #SALOVERLAP

/*
	Ok! We are done picking our data up, time to strip some info from it so we can then attach it to the PERPETRATOR CLAIM OR SAL
	So tables are isolated, time to select appropriate info and replace the junk.
*/

select
	DateUserChg
	,receivedDate
	,ClaimID
	,ClaimDetailID
	,ClaimSubscriberPayer
	,BatchInvoice
	,serviceDateThru
	,reconsideredClaim
	,adjustmentReason
	,REPLACE(adjustmentReason,'Dupe w/ S','') as 'OverlappingSALID'
	,adjustmentQuantity
	,FeeSchedule
	,ClaimAccountInfo
	,overrideFlag
	,reconsideredClaimPaid
	,serviceDateFrom
	,UserAdd
	,adjustmentType 
	,UserChg
	,paidAmount
	,allowedAmount
	,adjustmentDate
	,AdjustmentNote
	,AuthorizationDetail
	,claimAdjustmentID
	,PaymentBatchHeader
	,dateUserAdd
	,InsuranceCompany
	,adjustmentReference
	,DenialCode
	,FirstName
	,LastName
	,CHF_PRVID
	,ProviderName
	,ProviderNPI
into #SALCLEANED FROM #SALOVERLAP

--select * from #SALCLEANED

select
	DateUserChg
	,receivedDate
	,ClaimID
	,ClaimDetailID
	,ClaimSubscriberPayer
	,BatchInvoice
	,serviceDateThru
	,reconsideredClaim
	,adjustmentReason
	,CAST(OverlappingSALID AS INT) AS 'IntOverlappingSALID'
	,adjustmentQuantity
	,FeeSchedule
	,ClaimAccountInfo
	,overrideFlag
	,reconsideredClaimPaid
	,serviceDateFrom
	,UserAdd
	,adjustmentType 
	,UserChg
	,paidAmount
	,allowedAmount
	,adjustmentDate
	,AdjustmentNote
	,AuthorizationDetail
	,claimAdjustmentID
	,PaymentBatchHeader
	,dateUserAdd
	,InsuranceCompany
	,adjustmentReference
	,DenialCode
	,FirstName
	,LastName
	,CHF_PRVID
	,ProviderName
	,ProviderNPI
into #SALCLEANED2 FROM #SALCLEANED 

DROP TABLE #SALCLEANED
DROP TABLE #CLEANEDCLAIMS
DROP TABLE #SALCLEANED2

select
	DateUserChg
	,receivedDate
	,ClaimID
	,ClaimDetailID
	,ClaimSubscriberPayer
	,BatchInvoice
	,serviceDateThru
	,reconsideredClaim
	,adjustmentReason
	,REPLACE(adjustmentReason,'Dupe w/','') as 'OverlappingClaimID'
	,adjustmentQuantity
	,FeeSchedule
	,ClaimAccountInfo
	,overrideFlag
	,reconsideredClaimPaid
	,serviceDateFrom
	,UserAdd
	,adjustmentType 
	,UserChg
	,paidAmount
	,allowedAmount
	,adjustmentDate
	,AdjustmentNote
	,AuthorizationDetail
	,claimAdjustmentID
	,PaymentBatchHeader
	,dateUserAdd
	,InsuranceCompany
	,adjustmentReference
	,DenialCode
	,FirstName
	,LastName
	,CHF_PRVID
	,ProviderName
	,ProviderNPI
into #CLEANEDCLAIMS FROM #CLAIMOVERLAP

--This is done leave it the hell alone.
select
	DateUserChg
	,receivedDate
	,ClaimID
	,ClaimDetailID
	,ClaimSubscriberPayer
	,BatchInvoice
	,serviceDateThru
	,reconsideredClaim
	,adjustmentReason
	,CAST(OverlappingClaimID AS INT) AS 'IntOverlappingClaimID'
	,adjustmentQuantity
	,FeeSchedule
	,ClaimAccountInfo
	,overrideFlag
	,reconsideredClaimPaid
	,serviceDateFrom
	,UserAdd
	,adjustmentType 
	,UserChg
	,paidAmount
	,allowedAmount
	,adjustmentDate
	,AdjustmentNote
	,AuthorizationDetail
	,claimAdjustmentID
	,PaymentBatchHeader
	,dateUserAdd
	,InsuranceCompany
	,adjustmentReference
	,DenialCode
	,FirstName
	,LastName
	,CHF_PRVID
	,ProviderName
	,ProviderNPI
into #CLEANEDCLAIMS2 FROM #CLEANEDCLAIMS 


--Holy hell were good! so we have our duplicates, and more importantly we have the perpetrator as a INT so we can tie it to another table.

SELECT * FROM #SALCLEANED2
SELECT * FROM #CLEANEDCLAIMS2


/*
	Now! To finish this off, TIE the sal table to the overlapping SAL provider we need the provider name!
*/


--So finally here we have everything we need for the claims
SELECT CC2.*,E1.CHF_PRVID AS 'OVERLAPPROVIDERID',E2.PR_NAME AS 'OVERLAPPING_Provider_name' FROM #CLEANEDCLAIMS2 CC2
LEFT JOIN EDICLMPF E1 ON CC2.IntOverlappingClaimID = E1.CH_RCDID
LEFT JOIN PCHPRVPF E2 ON E1.CHF_PRVID = E2.PR_RCDID




SELECT SC2.*,E1.CHF_PRVID AS 'OVERLAPPROVIDERID',E2.PR_NAME AS 'OVERLAPPING_Provider_name' FROM #SALCLEANED2 SC2
LEFT JOIN EDICLMPF E1 ON SC2.IntOverlappingSALID = E1.CH_RCDID
LEFT JOIN PCHPRVPF E2 ON E1.CHF_PRVID = E2.PR_RCDID

--So we have our final data, pull that into one table export it.


SELECT CC2.*,E1.CHF_PRVID AS 'OVERPROVIDERID',E2.PR_NAME AS 'OVERLAPPING_Provider_name',E3.CD_PROCCD AS 'CPTCode',E3.CD_MOD AS 'CPTMod1',E3.CD_MOD2 AS 'CPTMod2',E3.CD_MOD3 AS 'CPTMod3' INTO #CLAIMSFINALEXPORT FROM #CLEANEDCLAIMS2 CC2
LEFT JOIN EDICLMPF E1 ON CC2.IntOverlappingClaimID = E1.CH_RCDID
LEFT JOIN PCHPRVPF E2 ON E1.CHF_PRVID = E2.PR_RCDID
left join EDICLDPF E3 ON CC2.ClaimDetailID = E3.CD_RCDID

SELECT SC2.*,E1.CHF_PRVID AS 'OVERLAPPROVIDERID',E2.PR_NAME AS 'OVERLAPPING_Provider_name',E3.CD_PROCCD AS 'CPTCode',E3.CD_MOD AS 'CPTMod1',E3.CD_MOD2 AS 'CPTMod2',E3.CD_MOD3 AS 'CPTMod3' INTO #SALFINALEXPORT FROM #SALCLEANED2 SC2
LEFT JOIN EDICLMPF E1 ON SC2.IntOverlappingSALID = E1.CH_RCDID
LEFT JOIN PCHPRVPF E2 ON E1.CHF_PRVID = E2.PR_RCDID
left join EDICLDPF E3 ON SC2.ClaimDetailID = E3.CD_RCDID

drop table #CLAIMSFINALEXPORT
drop table #SALFINALEXPORT

SELECT * FROM #CLAIMSFINALEXPORT
SELECT * FROM #SALFINALEXPORT







SELECT T1.*,E1.* fROM #TEST1 T1
left join EDICLDPF E1 ON T1.ClaimDetailID = E1.CD_RCDID


-----------------------------------------------------
SELECT * FROM #CLEANEDCLAIMS
DROP TABLE #CLEANEDCLAIMS

SELECT
	CLAIMID
	,OverlappingClaimID
	,CAST(OverlappingClaimID AS INT) AS 
	FROM #CLEANEDCLAIMS




select
	claimid
	,AdjustmentReason
	,adjustmentnote
	,REPLACE(adjustmentReason,'Dupe','xx')
FROM #SALTEST

select
	claimid
	,AdjustmentReason
	,adjustmentnote
	,REPLACE(adjustmentReason,'Dupe w/ S','') as SALID
FROM #SALTEST
