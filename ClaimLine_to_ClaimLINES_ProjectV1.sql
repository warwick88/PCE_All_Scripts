use ISK_Reporting_Production

select * from claimsbyday_reporting



use DATAKZO_ISK_Supplemental
select * from claimsbyday_reporting
order by DateofServiceEnd desc


use ISK_Reporting_Production
select * from claimsbyday_reporting
order by DateofServiceEnd desc


--So far this works within Supplemental
/*
	EDICLDPF:COLUMN-RCDID: ClaimDetailID 
			:COLUMN-CLTID: ClientID

	PCHCLTPF:
			COLUMN-CL_FNAME
			COLUMN-CL_LNAME

*/
use DATAKZO_ISK_Supplemental
select CINFO.CL_FNAME,CINFO.CL_LNAME,CBD.*,CT.* from ClaimsByDay_Reporting CBD
left join EDICLDPF CT ON CBD.ClaimId = CT.CD_RCDID
left join PCHCLTPF CINFO ON CT.CDF_CLTID = CINFO.CL_RCDID


use ISK_Reporting_Production
select CINFO.CL_FNAME,CINFO.CL_LNAME,CBD.*,CT.* from ClaimsByDay_Reporting CBD
join DATAKZO_ISK_Supplemental.dbo.EDICLDPF CT ON CBD.ClaimId = CT.CD_RCDID
join DATAKZO_ISK_Supplemental.dbo.PCHCLTPF CINFO ON CT.CDF_CLTID = CINFO.CL_RCDID

--NEW test

use ISK_Reporting_Production
select * from claimsbyday_reporting CR
join datakzo.dbo.EDICLDPF CT ON CR.ClaimId = CT.CD_RCDID


use ISK_Reporting_Production
select * from claimsbyday_reporting CR
JOIN datakzo.DBO.EDICLAPF


--TRY FROM CORPORATE INFO
use ISK_Reporting_Production
select * from claimsbyday_reporting CR
LEFT join DW_CorporateInfo.dbo.EDICLDPF CT ON CR.ClaimId = CT.CD_RCDID


use ISK_Reporting_Production
select * from claimsbyday_reporting CR
join DW_CorporateInfo.dbo.Fact_ServiceActivity CT ON CR.ClaimId = CT.ClaimID

SELECT TOP 200* FROM DW_CorporateInfo.dbo.Fact_ServiceActivity



LEFT JOIN DATAKZO_ISK_Supplemental.[dbo].[v_ClientData] CD ON CR.ClaimId = 
order by DateofServiceEnd desc



use ISK_Reporting_Production
select CBD.* from ClaimsByDay_Reporting CBD

where DateDiffStartEnd < 100
--where DateofServiceStart > '2022-12-03'
--and DateofServiceEnd < '2023-01-05'
where ClaimId = 62320

select * from ClaimsByDay_Reporting
where ClaimId in (
62950,
36248,
36960)



select * from claimsbyday_reporting
where claimid in (
62950,
62320,
53517,
60135,
60107,
67423,
67421,
67402,
67402,
67475,
67475,
67453,
67452,
63564,
63563,
59343,
59968,
67411,
67409,
67791,
67790,
67692,
67664,
59734,
59734,
59738,
59736,
59742,
59740,
59746,
59744,
59353,
59353,
59355)

select * from claimsbyday_reporting
where ClaimId in(
67657,
59613,
59614,
59614,
59614,
67658,
67519,
62877,
62879)



WITH FilteredClaimCTE AS (
  SELECT t1.CD_RCDID claimDetailID
  FROM EDICLDPF t1
   LEFT JOIN EDICLMPF t2 ON t1.CDF_CLMID  = t2.CH_RCDID
  WHERE t1.CD_FRMDT <= '2022-11-28' /*1*/
    AND (t1.CD_THRDT IS NULL   OR t1.CD_THRDT >= '2022-10-28' /*2*/)
    AND t2.CHF_PRVIDA = 1 /*3*/
    AND t2.CH_CLMSTS <> 'V' /*4*/
    AND ((t2.CH_CLMTYP IN ('HA' /*5*/, 'UA' /*6*/)  AND t1.CD_STATUS = 'O' /*7*/  AND t2.CHF_BICID IS NOT NULL)   OR t2.CH_CLMTYP IN ('HX' /*8*/, 'UX' /*9*/))
),
UNIONED_ROWS (RECID, TBLNM, Service_Date, Service_Through, Client_ID, Provider_ID, Affiliate_ID, Staff_ID, Place_of_Contact, Begin_Time, End_Time, CPT_Code, Mod1, Mod2, Mod3, Mod4, Units, Face_To_Face, CPT_Description, NumOfMinutes, Charged_Amount, Added_Date, Employee_LName, Employee_FName, Employee_NPI, GL_Account, Fund_Source, Encounter_Status, Billing_Status, AR_CHG_AMT, AR_PAID_AMT) AS (
  
    (
      SELECT DISTINCT t2.CD_RCDID RECID, 'EDICLDPF' TBLNM,
             t2.CD_FRMDT Service_Date, t2.CD_THRDT Service_Through,
             t9.CHF_CLTID Client_ID, t9.CHF_PRVID Provider_ID,
             t9.CHF_PRVIDA Affiliate_ID, t2.CDF_STFID Staff_ID,
             t3.CO_SDESCR Place_of_Contact, t2.CD_FRMTM Begin_Time,
             t2.CD_THRTM End_time,
             COALESCE(t2.CD_REVCD, t2.CD_PROCCD) CPT_Code,
             t2.CD_MOD Mod1, t2.CD_MOD2 Mod2, t2.CD_MOD3 Mod3,
             t2.CD_MOD4 Mod4, t2.CD_UNITS Units, 'Yes' Face_To_Face,
             t7.XP_RPTDESC CPT_Description,
             TZ_DIFF_MINUTES(PCESQL.WOTZ(t2.CD_FRMDT,COALESCE(t2.CD_FRMTM, 0)),PCESQL.WOTZ(t2.CD_THRDT,COALESCE(t2.CD_THRTM, 0))) NumOfMinutes,
             t2.CD_CHGAMT Charged_Amount, t9.CH_ADDDATE Added_Date,
             NULLIF('X', 'X') Employee_LName,
             NULLIF('X', 'X') Employee_FName,
             NULLIF('X', 'X') Employee_NPI, NULLIF('X', 'X') GL_Account,
             NULLIF('X', 'X') Fund_Source,
             NULLIF('X', 'X') Encounter_Status,
             NULLIF('X', 'X') Billing_Status, NULLIF(0, 0) AR_CHG_AMT,
             NULLIF(0, 0) AR_PAID_AMT
      FROM FilteredClaimCTE FilteredClaimCTE
            JOIN EDICLDPF t2 ON t2.CD_RCDID   = FilteredClaimCTE.claimDetailID
       LEFT JOIN ( CODCODPF t3              
                         JOIN CODCATPF t4 ON t3.COF_CATID  = t4.CT_RCDID
                                             AND t4.CT_PRGVAL  = 'PS' /*10*/
                   ) ON t2.CD_POS     = t3.CO_PRGVAL
       LEFT JOIN PCHAUDPF t5 ON t2.CDF_AUDID  = t5.AD_RCDID
       LEFT JOIN PCHPFSPF t6 ON t5.ADF_PFSID  = t6.PF_RCDID
       LEFT JOIN PCHXSPPF t7 ON t6.PFF_XSPID  = t7.XP_RCDID
       LEFT JOIN EDICLAPF t8 ON t2.CD_RCDID   = t8.CAF_CLDID
       LEFT JOIN EDICLMPF t9 ON t9.CH_RCDID   = t2.CDF_CLMID
      GROUP BY t9.CH_RCDID, t9.CH_CLMTYP, t2.CD_RCDID, t2.CD_FRMDT,
               t2.CD_THRDT, t9.CHF_CLTID, t9.CHF_PRVID, t9.CHF_PRVIDA,
               t2.CDF_STFID, t3.CO_SDESCR, t2.CD_FRMTM, t2.CD_THRTM,
               COALESCE(t2.CD_REVCD, t2.CD_PROCCD), t2.CD_MOD,
               t2.CD_MOD2, t2.CD_MOD3, t2.CD_MOD4, t2.CD_UNITS,
               t7.XP_RPTDESC,

               t2.CD_CHGAMT, t9.CH_ADDDATE
      HAVING (t9.CH_CLMTYP IN ('HX' /*11*/, 'UX' /*12*/)   OR SUM(t8.CA_ADJQTY) > 0 /*13*/)
    )
),
DetailRows AS (
  SELECT UNIONED_ROWS.RECID, UNIONED_ROWS.TBLNM,
         UNIONED_ROWS.Service_Date, UNIONED_ROWS.Service_Through,
         UNIONED_ROWS.Client_ID, UNIONED_ROWS.Provider_ID,
         UNIONED_ROWS.Affiliate_ID, UNIONED_ROWS.Staff_ID,
         UNIONED_ROWS.Place_of_Contact, UNIONED_ROWS.Begin_Time,
         UNIONED_ROWS.End_Time, UNIONED_ROWS.CPT_Code,
         UNIONED_ROWS.Mod1, UNIONED_ROWS.Mod2, UNIONED_ROWS.Mod3,
         UNIONED_ROWS.Mod4, UNIONED_ROWS.Units,
         UNIONED_ROWS.Face_To_Face, UNIONED_ROWS.CPT_Description,
         UNIONED_ROWS.NumOfMinutes, UNIONED_ROWS.Charged_Amount,
         UNIONED_ROWS.Added_Date, UNIONED_ROWS.Employee_LName,
         UNIONED_ROWS.Employee_FName, UNIONED_ROWS.Employee_NPI,
         UNIONED_ROWS.GL_Account, UNIONED_ROWS.Fund_Source,
         UNIONED_ROWS.Encounter_Status, UNIONED_ROWS.Billing_Status,
         UNIONED_ROWS.AR_CHG_AMT, UNIONED_ROWS.AR_PAID_AMT,
         t8.CL_CASENO, t8.CL_LNAME, t8.CL_FNAME,
         DATE(UNIONED_ROWS.Service_Date) DT_Service_Date,
         DATE(UNIONED_ROWS.Service_Through) DT_Service_Through,
         MONTH(UNIONED_ROWS.Service_Date) MONTH_Service_Date,
         YEAR(UNIONED_ROWS.Service_Date) YR_Service_Date,
         t10.PR_NAME c40_PR_NAME, t10.PR_RCDID c41_PR_RCDID,
         t10.PRF_ORGTYP, t4.PR_NAME, t4.PR_RCDID, t11.ST_LNAME,
         t11.ST_FNAME, t11.ST_RCDID,
         DATE(UNIONED_ROWS.Added_Date) DT_Added_Date, t2.CD_RCDID,
         t5.BI_RCDID,  t5.BI_STS,
         COALESCE(t3.CHF_BCHID, t3.CHF_IFTID) c55, t3.CH_CLMNO,
         t2.CD_PAYAMT, t3.CHF_CLMID, t2.CDF_CLDID, t2.CDF_CLMID,
         CASE
           WHEN SUBSTR(t3.CH_CLMTYP, 1, 1) = 'H' THEN 'FCHCFA1500'
           ELSE                                       'FCHCFA1500'
         END ClmEditPage,
         t8.CL_RCDID, t7.CA_ADJQTY, t7.CA_ALWAMT,
         t7.CA_PAYAMT c61_CA_PAYAMT, t6.CA_PAYAMT
  FROM UNIONED_ROWS UNIONED_ROWS
   LEFT JOIN EDICLDPF t2 ON t2.CD_RCDID   = UNIONED_ROWS.RECID
                            AND UNIONED_ROWS.TBLNM = 'EDICLDPF' /*14*/
   LEFT JOIN EDICLMPF t3 ON t2.CDF_CLMID  = t3.CH_RCDID
   LEFT JOIN PCHPRVPF t4 ON t3.CHF_BPRVID = t4.PR_RCDID
   LEFT JOIN EDIBICPF t5 ON t3.CHF_BICID  = t5.BI_RCDID
   LEFT JOIN EDICLAPF t6 ON t3.CH_RCDID   = t6.CAF_CLMID
                            AND t6.CAF_CLDID  IS NULL
   LEFT JOIN EDICLAPF t7 ON t2.CD_RCDID   = t7.CAF_CLDID
   LEFT JOIN PCHCLTPF t8 ON t8.CL_RCDID   = UNIONED_ROWS.Client_ID
   LEFT JOIN PCHPRVPF t9 ON t9.PR_RCDID   = UNIONED_ROWS.Affiliate_ID
   LEFT JOIN PCHPRVPF t10 ON t10.PR_RCDID  = UNIONED_ROWS.Provider_ID
   LEFT JOIN PCHSTFPF t11 ON t11.ST_RCDID  = UNIONED_ROWS.Staff_ID
   LEFT JOIN ( PCHSALPF t12              
                     JOIN KZOSALPF t13 ON t13.SAP_SALID = t12.SA_RCDID
               ) ON t12.SA_RCDID  = UNIONED_ROWS.RECID
                AND UNIONED_ROWS.TBLNM = 'PCHSALPF' /*15*/
   LEFT JOIN CODCODPF t14 ON t12.SAF_SALCLA = t14.CO_RCDID
   LEFT JOIN PCHDOCPF t15 ON t15.DC_RCDID  = t12.SAF_DOCID
  WHERE (t8.CL_TESTCLT IS NULL   OR t8.CL_TESTCLT = 'N' /*16*/)
),
Aggregates_1 AS (
  SELECT DetailRows.RECID, DetailRows.TBLNM, DetailRows.Service_Date,
         DetailRows.Service_Through, DetailRows.Client_ID,
         DetailRows.Provider_ID, DetailRows.Affiliate_ID,
         DetailRows.Staff_ID, DetailRows.Place_of_Contact,
         DetailRows.Begin_Time, DetailRows.End_Time,
         DetailRows.CPT_Code, DetailRows.Mod1, DetailRows.Mod2,
         DetailRows.Mod3, DetailRows.Mod4, DetailRows.Units,
         DetailRows.Face_To_Face, DetailRows.CPT_Description,
         DetailRows.NumOfMinutes, DetailRows.Charged_Amount,
         DetailRows.Added_Date, DetailRows.Employee_LName,
         DetailRows.Employee_FName, DetailRows.Employee_NPI,
         DetailRows.GL_Account, DetailRows.Fund_Source,
         DetailRows.Encounter_Status, DetailRows.Billing_Status,
         DetailRows.AR_CHG_AMT, DetailRows.AR_PAID_AMT,
         DetailRows.CL_CASENO, DetailRows.CL_LNAME,
         DetailRows.CL_FNAME, DetailRows.DT_Service_Date,
         DetailRows.DT_Service_Through,
         DetailRows.MONTH_Service_Date, DetailRows.YR_Service_Date,
         DetailRows.c40_PR_NAME, DetailRows.c41_PR_RCDID,
         DetailRows.PRF_ORGTYP, DetailRows.PR_NAME,
         DetailRows.PR_RCDID, DetailRows.ST_LNAME,
         DetailRows.ST_FNAME, DetailRows.ST_RCDID,
         DetailRows.DT_Added_Date, DetailRows.CD_RCDID,
         DetailRows.BI_RCDID, DetailRows.BI_STS, DetailRows.c55,
         DetailRows.CH_CLMNO, DetailRows.CD_PAYAMT,
         DetailRows.CHF_CLMID, DetailRows.CDF_CLDID,
         DetailRows.CDF_CLMID, DetailRows.ClmEditPage,
         DetailRows.CL_RCDID, DetailRows.CA_ADJQTY,
         DetailRows.CA_ALWAMT, DetailRows.c61_CA_PAYAMT,
         DetailRows.CA_PAYAMT
  FROM DetailRows DetailRows
)

SELECT Aggregates_1.RECID, Aggregates_1.TBLNM,
       Aggregates_1.Service_Date, Aggregates_1.Service_Through,
       Aggregates_1.Client_ID, Aggregates_1.Provider_ID,
       Aggregates_1.Affiliate_ID, Aggregates_1.Staff_ID,
       Aggregates_1.Place_of_Contact, Aggregates_1.Begin_Time,
       Aggregates_1.End_Time, Aggregates_1.CPT_Code,
       Aggregates_1.Mod1, Aggregates_1.Mod2, Aggregates_1.Mod3,
       Aggregates_1.Mod4, Aggregates_1.Units,
       Aggregates_1.Face_To_Face, Aggregates_1.CPT_Description,
       Aggregates_1.NumOfMinutes, Aggregates_1.Charged_Amount,
       Aggregates_1.Added_Date, Aggregates_1.Employee_LName,
       Aggregates_1.Employee_FName, Aggregates_1.Employee_NPI,
       Aggregates_1.GL_Account, Aggregates_1.Fund_Source,
       Aggregates_1.Encounter_Status, Aggregates_1.Billing_Status,
       Aggregates_1.AR_CHG_AMT, Aggregates_1.AR_PAID_AMT,
       Aggregates_1.CL_CASENO, Aggregates_1.CL_LNAME,
       Aggregates_1.CL_FNAME, Aggregates_1.DT_Service_Date,
       Aggregates_1.DT_Service_Through,
       Aggregates_1.MONTH_Service_Date,
       Aggregates_1.YR_Service_Date, Aggregates_1.c40_PR_NAME,
       Aggregates_1.c41_PR_RCDID, Aggregates_1.PRF_ORGTYP,
       Aggregates_1.PR_NAME, Aggregates_1.PR_RCDID,
       Aggregates_1.ST_LNAME, Aggregates_1.ST_FNAME,
       Aggregates_1.ST_RCDID, Aggregates_1.DT_Added_Date,
       Aggregates_1.CD_RCDID, Aggregates_1.BI_RCDID,
       Aggregates_1.BI_STS, Aggregates_1.c55,
       Aggregates_1.CH_CLMNO, Aggregates_1.CD_PAYAMT,
       Aggregates_1.CHF_CLMID, Aggregates_1.CDF_CLDID,
       Aggregates_1.CDF_CLMID, Aggregates_1.ClmEditPage,
       Aggregates_1.CL_RCDID,
       COUNT(DISTINCT Aggregates_1.CL_RCDID) OVER() DCNT_CL_RCDID,
       SUM(Aggregates_1.Units) OVER() SUM_Units,
       SUM(Aggregates_1.NumOfMinutes) OVER() SUM_NumOfMinutes,
       SUM(Aggregates_1.Charged_Amount) OVER() SUM_Charged_Amount,
       SUM(Aggregates_1.CA_ADJQTY) SUM_CA_ADJQTY,
       SUM(Aggregates_1.CA_ALWAMT) SUM_CA_ALWAMT,
       SUM(Aggregates_1.c61_CA_PAYAMT) SUM_CA_PAYAMT,
       SUM(Aggregates_1.CA_PAYAMT) SUM_CA_PAYAMT_2,
       COUNT(1) OVER() NUM_ROWS
FROM Aggregates_1 Aggregates_1
GROUP BY Aggregates_1.RECID, Aggregates_1.TBLNM,
         Aggregates_1.Service_Date, Aggregates_1.Service_Through,
         Aggregates_1.Client_ID, Aggregates_1.Provider_ID,
         Aggregates_1.Affiliate_ID, Aggregates_1.Staff_ID,
         Aggregates_1.Place_of_Contact, Aggregates_1.Begin_Time,
         Aggregates_1.End_Time, Aggregates_1.CPT_Code,
         Aggregates_1.Mod1, Aggregates_1.Mod2, Aggregates_1.Mod3,
         Aggregates_1.Mod4, Aggregates_1.Units,
         Aggregates_1.Face_To_Face, Aggregates_1.CPT_Description,
         Aggregates_1.NumOfMinutes, Aggregates_1.Charged_Amount,
         Aggregates_1.Added_Date, Aggregates_1.Employee_LName,
         Aggregates_1.Employee_FName, Aggregates_1.Employee_NPI,
         Aggregates_1.GL_Account, Aggregates_1.Fund_Source,
         Aggregates_1.Encounter_Status,
         Aggregates_1.Billing_Status, Aggregates_1.AR_CHG_AMT,
         Aggregates_1.AR_PAID_AMT, Aggregates_1.CL_CASENO,
         Aggregates_1.CL_LNAME, Aggregates_1.CL_FNAME,
         Aggregates_1.DT_Service_Date,
         Aggregates_1.DT_Service_Through,
         Aggregates_1.MONTH_Service_Date,
         Aggregates_1.YR_Service_Date, Aggregates_1.c40_PR_NAME,
         Aggregates_1.c41_PR_RCDID, Aggregates_1.PRF_ORGTYP,
         Aggregates_1.PR_NAME, Aggregates_1.PR_RCDID,
         Aggregates_1.ST_LNAME, Aggregates_1.ST_FNAME,
         Aggregates_1.ST_RCDID, Aggregates_1.DT_Added_Date,
         Aggregates_1.CD_RCDID, Aggregates_1.BI_RCDID,
         Aggregates_1.BI_STS, Aggregates_1.c55,
         Aggregates_1.CH_CLMNO, Aggregates_1.CD_PAYAMT,
         Aggregates_1.CHF_CLMID, Aggregates_1.CDF_CLDID,
         Aggregates_1.CDF_CLMID, Aggregates_1.ClmEditPage,
         Aggregates_1.CL_RCDID
ORDER BY Aggregates_1.CL_LNAME, Aggregates_1.CL_FNAME,
         Aggregates_1.CL_CASENO,
         Aggregates_1.Service_Date,
         Aggregates_1.Begin_Time,
         Aggregates_1.Begin_Time,
         Aggregates_1.End_Time,
         Aggregates_1.RECID DESC,
         Aggregates_1.TBLNM