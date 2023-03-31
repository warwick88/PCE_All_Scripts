USE [ISK_Reporting_Production]
GO

/****** Object:  StoredProcedure [dbo].[sp_ClaimsReporting_ClaimsBreakoutByDay]    Script Date: 1/26/2023 3:05:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--use [ISK_Reporting_Production]

/**************************************************************************/
/***
  Create temporary table, containing DW-supplied values, 
     plus calculating
	 
		1) DateDiffStartEnd = # of Days covered by the given record
		2) CalculatedUnitsForDay -  per day, using DateDiffStartEnd
		3) Billed Amounts per day - per day, using DateDiffStartEnd
***/
/**************************************************************************/
CREATE Procedure [dbo].[sp_ClaimsReporting_ClaimsBreakoutByDay]
as
   
select distinct
	Claimid, DateofServiceStart, DateofServiceEnd, 
	(datediff(dd, DateofServiceStart, DateofServiceEnd) + 1) as DateDiffStartEnd, 
	Units, adjustedUnits, 
	CalculatedUnitsForDay = ( Units / ( datediff(dd, DateofServiceStart, DateofServiceEnd) + 1) ) ,
	BilledAmount, 
	CalculatedBilledAmountForDay = ( BilledAmount / (datediff(dd, DateofServiceStart, DateofServiceEnd) + 1) )
into #Claims
from DW_CorporateInfo..Fact_ServiceActivity
	where dateofserviceStart - dateofServiceEnd <> 0

	select * from #Claims


	--Ok, so we only have 4810 claims that are even like this.
	SELECT COUNT(DISTINCT(CLAIMID)) FROM #Claims


	select * from ClaimsByDay_Reporting CR
	RIGHT JOIN DW_CorporateInfo..Fact_ServiceActivity SA on CR.ClaimId = SA.ClaimID

	select * from ClaimsByDay_Reporting
	GROUP BY ClaimId,DateofServiceStart,DateofServiceEnd,DateDiffStartEnd,CalculatedDateofService,Units,CalculatedUnitsForDay,BilledAmount,CalculatedBilledAmountForDay


	select * from ClaimsByDay_Reporting CR
	JOIN DW_CorporateInfo..Fact_ServiceActivity SA on CR.ClaimId = SA.ServiceLineID

	SELECT * FROM DW_CorporateInfo..Fact_ServiceActivity
	WHERE ClaimID=57670

	SELECT * FROM DW_CorporateInfo..Fact_ServiceActivity


truncate table dbo.ClaimsByDay_Reporting 

insert into  dbo.ClaimsByDay_Reporting 

select 
	t.ClaimId, t.DateofServiceStart, t.DateofServiceEnd, t.DateDiffStartEnd,
	d.FullDate as CalculatedDateofService,
	t.Units,t.CalculatedUnitsForDay,t.BilledAmount, t.CalculatedBilledAmountForDay
From #Claims t
join [DW_CorporateInfo].[dbo].[DimDate] d on 
d.FullDate between t.DateofServiceStart and t.DateofServiceEnd

 /********************************************************************/
 /*  Review results  */
 /********************************************************************/
/*
select * 
From dbo.ClaimsByDay_Reporting 
order by claimid, dateofServiceStart, CalculatedDAteofService
*/

drop table #Claims 

GO


