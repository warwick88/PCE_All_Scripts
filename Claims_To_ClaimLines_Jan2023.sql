use ISK_Reporting_Production






/**
	So first dataset is ClaimsReportTwo.
	Discoveries:
				JOIN ON ClaimsReportTwo.ClaimID = ClaimsByDay_Reporting.Claim_Number
				That can be a bit confusing.
				
				select sum(paid_amount) from ClaimsReportTwo

				select * from ClaimsReportTwo
**/


/*
	This is DF1 Make it so
*/
select CRT.*,DATEDIFF(day,Service_From_Date,Service_Thru_Date) as DaysBetween,CRT.Claim_Number AS CLAIMID2 from ClaimsReportTwo CRT
order by DaysBetween desc


select CRT.*,DATEDIFF(day,Service_From_Date,Service_Thru_Date) as DaysBetween,CRT.Claim_Number AS CLAIMID2 INTO #DF1 from ClaimsReportTwo CRT
order by DaysBetween desc

SELECT * FROM #DF1
ORDER BY DaysBetween DESC

SELECT * FROM ClaimsByDay_Reporting
WHERE ClaimId IN (74013)
left join datakzo.dbo.

SELECT TOP 30* FROM #DF1
ORDER BY DaysBetween DESC

SELECT * FROM ClaimsByDay_Reporting
WHERE ClaimId IN (
69065,
62950,
62320,
53517,
60135,
60107,
22981,
36786,
22973,
23065)


select * from ClaimsReportTwo

select * from ClaimsByDay_Reporting
WHERE ClaimId IN (
74013)


select * from ClaimsByDay_Reporting CDR
JOIN datakzo.dbo.EDICLDPF E ON CDR.ClaimId = E.CDF_CLMID
WHERE ClaimId IN (
74013)


--I think you want Claim_Number for the actual claim ID

select * from ClaimsByDay_Reporting
where ClaimId=146094

select * from ClaimsByDay_Reporting
where ClaimId in (
69065,
62950,
62320,
53517,
60107,
60135,
68094)

SELECT * FROM ClaimsByDay_Reporting
WHERE ClaimId IN (
'NLC000585165')