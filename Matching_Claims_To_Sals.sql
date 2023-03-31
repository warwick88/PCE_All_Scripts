USE datakzo
/*
	Provider CHC Contract is 1219
	Vendor: 162
*/

/*
	So provider 1219 CHC - Elizabeth Upjohn Healing Center has 281 claims
	how many SAL
*/
SELECT * FROM EDICLDPF
WHERE CDF_PRVID = 1219

/*
	We want to tie DCO Claims to SAL'S that have been entered into the system.
	They ahve 355 Claims
	So provider 2450 CHC - Elizabeth Upjohn Healing Center has 281 claims
	how many SAL
*/
SELECT * FROM EDICLDPF
WHERE CDF_PRVID = 2450
--and CDF_CLTID = 00125789      --fk to client id
order by CD_FRMDT asc

/*
	So we have 1 individual here from DCO CHC. We want to see, CAN we tie these to the existing SAL'S in the system?
	Are there SAL'S that tie to these claims? LETS FIND OUT! YAY

*/
--So let's try to tie these to SALS'
SELECT * FROM EDICLDPF
WHERE CDF_PRVID = 2450
--and CDF_CLTID = 00125789      --fk to client id
order by CD_FRMDT asc

SELECT * into #TempClaims FROM EDICLDPF 
WHERE CDF_PRVID = 2450
and CDF_CLTID = 00125789      --fk to client id

select * from #Temp1

/*So me thinks you link it to this. So they might seem duplicated due to T1040's getting generated, SO DON'T tie a T1040 to your stuff! ignore IT
You need to link on CPT code, times, person etc.
*/
select * from PCHSALPF
where SAF_CLTID = 00125789

/*
	So FFS - You have to connect to CPT codes THEN also connect to the stupid revenue codes in PCHCPTPF to even see what's a T1040
*/
select * from PCHSALPF
where SAF_CLTID = 00125789
AND SA_SRVDATE > '2023-03-22'
--and SAF_XSPID= 122616    --THIS IS ACTUALLY THE CPT CROSSWALK

SELECT * FROM PCHXSPPF
WHERE SAF_XSPID= 11761 

SELECT * FROM PCHXSPPF
WHERE XPF_XWKID= 11761 

--sO WTF Are we doing here. Ok wo have our claims in a temp table. Now we are going to SALS' however to get the freaking cpt code you need to join AGAIN.
--so now we are going to join the below query to PCHCPTPF to get cpt codes

/*
	So now we can pull the SAL'S and then exclude T0140'S by filtering out CR_CODE where it's T0140
*/
select SALS.*,REVCodes.CR_CODE from PCHSALPF SALS
JOIN PCHXSPPF CPTCrosswalk ON SALS.SAF_XSPID = CPTCrosswalk.XP_RCDID   
LEFT JOIN PCHCPTPF REVCodes ON CPTCrosswalk.XPF_CPTID = REVCodes.CR_RCDID
where SAF_CLTID = 00125789
AND SA_SRVDATE > '2023-03-22'

SELECT * FROM PCHCPTPF
WHERE CR_CODE LIKE '%T1040%'


/*
	So now we can pull the SAL'S and then exclude T0140'S by filtering out CR_CODE where it's T0140
	Again this can then all get joined in an approximation to the temp table we made.
*/
select SALS.*,REVCodes.CR_CODE from PCHSALPF SALS
JOIN PCHXSPPF CPTCrosswalk ON SALS.SAF_XSPID = CPTCrosswalk.XP_RCDID   
LEFT JOIN PCHCPTPF REVCodes ON CPTCrosswalk.XPF_CPTID = REVCodes.CR_RCDID
where SAF_CLTID = 00125789
AND SA_SRVDATE > '2023-03-22'

/*So we manage to really narrow down the SAL's here. No T1040's we could accidentally match on. Let's
	pull these into a temp table and tie them to claims now
*/
select SALS.*,REVCodes.CR_CODE into #TEMPSALS from PCHSALPF SALS
JOIN PCHXSPPF CPTCrosswalk ON SALS.SAF_XSPID = CPTCrosswalk.XP_RCDID   
LEFT JOIN PCHCPTPF REVCodes ON CPTCrosswalk.XPF_CPTID = REVCodes.CR_RCDID
where SAF_CLTID = 00125789
AND REVCodes.CR_CODE NOT IN('T1040')

SELECT * FROM PCHCPTPF
WHERE CR_CODE NOT IN ('t1040')

select * from #TempClaims TC




--LEFT JOIN #TEMPSALS TS ON TC.CDF_CLTID = TS.SAF_CLTID AND 
--So we have a lot of items, we match on client id, time, cpt code, units, date what else can we do?

select * from #TEMPSALS
--Making progress, joined to client id, and to the procedure code matching or "revenue code" matching.
select * from #TempClaims TC
LEFT JOIN #TEMPSALS TS ON TC.CDF_CLTID = TS.SAF_CLTID AND TC.CD_PROCCD = TS.CR_CODE AND TC.CD_FRMDT = TS.SA_SRVDATE AND TC.CD_UNITS = TS.SA_UNITS 


select * from #TempClaims TC
LEFT JOIN #TEMPSALS TS ON TC.CDF_CLTID = TS.SAF_CLTID AND TC.CD_PROCCD = TS.CR_CODE AND TC.CD_FRMDT = TS.SA_SRVDATE AND TC.CD_UNITS = TS.SA_UNITS AND TC.CD_THRTM = TS.SA_ENDTIME


SELECT * FROM #TempClaims --IT'S CD_THRTM ON CLAIMS

SELECT * FROM #TEMPSALS --SO IT'S SA_BEGTIME ON SALS