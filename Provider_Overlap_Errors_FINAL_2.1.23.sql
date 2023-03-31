USE datakzo


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

--SELECT * fROM #TEST1 

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
--SELECT * FROM #TEST3



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

--DROP TABLE #SALCLEANED
--DROP TABLE #CLEANEDCLAIMS
--DROP TABLE #SALCLEANED2

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

--SELECT * FROM #SALCLEANED2
--SELECT * FROM #CLEANEDCLAIMS2


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

--drop table #CLAIMSFINALEXPORT
--drop table #SALFINALEXPORT

--SELECT * INTO #Reviewed1 FROM EDICLAPF
--WHERE CAF_CLDID IN (
--22621,
--22921,
--22922,
--29800,
--29801,
--29802,
--29803,
--29806,
--29807,
--29809,
--29550,
--29551,
--47420,
--47421,
--47422,
--69087,
--37463,
--37467,
--37497,
--37513,
--59895,
--61373,
--62989,
--37454,
--37460,
--68433,
--68554,
--69074,
--69109,
--1265,
--1267,
--23504,
--23608,
--61685,
--61688,
--30213,
--30215,
--68948,
--234,
--937,
--31456,
--68065,
--37043,
--68151,
--68181,
--68590,
--83529,
--73958,
--73959,
--73975)



select * into #Reviewed2 from EDICLAPF
where CAF_CLMID IN (
22621,
22921,
22922,
29800,
29801,
29802,
29803,
29806,
29807,
29809,
29550,
29551,
47420,
47421,
47422,
69087,
37463,
37467,
37497,
37513,
59895,
61373,
62989,
37454,
37460,
68433,
68554,
69074,
69109,
1265,
1267,
23504,
23608,
61685,
61688,
30213,
30215,
68948,
234,
937,
31456,
68065,
37043,
68151,
68181,
68590,
83529,
73958,
73959,
73975,
37035,
37036,
83097,
60697,
61374,
61400,
67831,
36864,
47467,
71129,
53083,
53084,
67945,
67946,
73326,
48745,
48760,
48771,
48780,
71554,
71556,
14448,
36751,
52975,
53024,
53114,
53117,
61781,
61783,
69233,
74746,
74747,
62403,
62504,
83072,
83100,
84694,
67904,
1483,
1491,
1498,
1499,
62513,
63568,
72080,
83299,
71082,
23283,
23475,
61918,
61919,
61920,
61927,
61928,
61930,
62078,
62079,
62080,
62081,
62086,
62087,
62088,
62171,
62172,
62173,
62174,
62186,
62188,
63434,
63435,
63436,
63437,
71342,
71343,
71344,
71360,
71361,
73091,
73092,
73093,
73094,
73165,
73166,
73167,
73168,
61945,
61946,
62109,
62111,
62112,
63461,
63462,
63463,
73129,
73131,
71624,
71751,
74077,
74078,
84367,
84400,
84402,
88167,
88208,
88216,
74077,
74078,
48484,
48484,
4650,
23056,
23133,
23138,
29740,
29741,
30848,
37635,
52929,
56692,
68355,
68372,
89194,
98116,
30470,
72322,
72325,
72340,
83071,
46508,
46508,
46508,
46610,
53517,
53517,
53517,
53525,
59954,
60702,
74016,
74019,
74420,
87937,
68276,
84964,
31510,
60107,
30595,
88518,
88540,
88639,
1483,
1491,
1498,
1499,
1838,
1838,
1838,
1838,
23283,
23475,
942,
942,
73918,
88404,
72094,
83071,
72052,
85122,
97038,
89072,
96140,
4650,
23056,
23133,
23138,
29740,
29741,
30848,
37635,
52929,
56692,
68355,
68372,
89194,
30593,
30470,
72322,
72325,
72340,
83071,
46508,
46610,
53517,
53525,
59954,
60702,
74016,
74019,
74420,
87937,
68276,
84964,
31510,
60101,
73918,
87903,
88592,
109210,
109212,
109254,
109455,
109457,
109503,
109504,
109507,
109582,
97257,
97258,
97259,
109148,
93001,
95182,
97098,
109083,
103084,
95924,
102360,
110222,
96083,
96105,
96113,
96129,
97214,
97217,
97219,
97232,
97233,
97241,
98817,
98861,
98867,
98886,
98888,
98902,
113951,
113960,
113980,
114977,
114978,
114979,
114982,
114984,
96669,
96670,
96671,
102501,
102502,
102503,
102521,
109275,
109276,
109277,
109278,
109488,
109853,
109854,
109855,
110089,
110090,
110091,
110092,
113794,
113815,
95882,
98618,
98621,
98644,
98648,
98650,
98651,
98654,
113769,
113772,
113775,
113789,
113791,
113799,
113826,
113830,
113831,
113852,
108887,
96096,
96126,
96137,
97239,
98830,
98854,
98860,
98868,
113722,
113723,
114981,
61944,
96714,
96715,
96716,
96717,
96902,
109308,
109310,
109312,
97356,
97357,
97360,
97478,
97479,
97480,
98175,
98231,
103012,
95948,
102396,
109564,
109566,
109567,
103134,
103146,
103147,
98362,
95371,
95372,
95493,
95493,
87756,
87757,
114750,
72952,
110162,
89372,
103881,
110166,
115125,
115181 
)

--SELECT * FROM #Reviewed1
--WHERE CAF_CLMID=22621

--SELECT * FROM #Reviewed2
--WHERE CAF_CLMID=22621

--SELECT * FROM #Reviewed1
--SELECT * FROM #Reviewed2


--SELECT * FROM #CLAIMSFINALEXPORT
--WHERE ClaimID=22621
--SELECT * FROM #SALFINALEXPORT


--SELECT * FROM #CLAIMSFINALEXPORT
--where ClaimID not in (SELECT CAF_CLMID FROM #Reviewed1)

--SELECT * FROM #SALFINALEXPORT
--where ClaimID not in (SELECT CAF_CLMID FROM #Reviewed1)

--Here is what we want!

--SELECT * FROM #CLAIMSFINALEXPORT
--SELECT * FROM #SALFINALEXPORT

SELECT * FROM #CLAIMSFINALEXPORT
where ClaimID not in (SELECT CAF_CLMID FROM #Reviewed2)

SELECT * FROM #SALFINALEXPORT
where ClaimID not in (SELECT CAF_CLMID FROM #Reviewed2)


--SELECT T1.*,E1.* fROM #TEST1 T1
--left join EDICLDPF E1 ON T1.ClaimDetailID = E1.CD_RCDID


-------------------------------------------------------
--SELECT * FROM #CLEANEDCLAIMS
--DROP TABLE #CLEANEDCLAIMS

--SELECT
--	CLAIMID
--	,OverlappingClaimID
--	,CAST(OverlappingClaimID AS INT) AS 
--	FROM #CLEANEDCLAIMS




--select
--	claimid
--	,AdjustmentReason
--	,adjustmentnote
--	,REPLACE(adjustmentReason,'Dupe','xx')
--FROM #SALTEST

--select
--	claimid
--	,AdjustmentReason
--	,adjustmentnote
--	,REPLACE(adjustmentReason,'Dupe w/ S','') as SALID
--FROM #SALTEST
