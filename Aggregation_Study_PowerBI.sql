use SmartCarePreProd

/*
	This is a query for generalized Windows function learning to help aggregate results for 
	Power BI Reports

*/

select 
	s.ProcedureCodeId,
	PC.ProcedureCodeName,
	COUNT(s.ProcedureCodeId) OVER(partition by s.procedurecodeid) AS ProcedureCodeCount,
	SUM(Charge) OVER() as All_Charge_Totals,
	SUM(Charge) OVER(PARTITION BY S.ProcedureCodeId) as ProcedureCodeCharges
from Services S
JOIN ProcedureCodes PC on S.ProcedureCodeId = PC.ProcedureCodeId
where ISNULL(S.RECORDDELETED,'N') = 'N'
and DateOfService <= '2022-03-26'
and DateOfService > '2022-03-25'


/*	
	Now this is pretty cool, we have each rows charge, procedurecodecount, all charge totals, ProcedureCodeCharges Totals
	Then now we ALSO have a rowcount for each ProcedureCode that appears.
	We could technically also query the Service Date and make it rank them by that instead.
*/
select 
	s.ProcedureCodeId,
	PC.ProcedureCodeName,
	S.Billable,
	S.Charge,
	COUNT(s.ProcedureCodeId) OVER(partition by s.procedurecodeid) AS ProcedureCodeCount,  --> Counts times procedure code shows
	SUM(Charge) OVER() as All_Charge_Totals, --> blank OVER just to sum Charge column for ALL_Charge_Totals
	SUM(Charge) OVER(PARTITION BY S.ProcedureCodeId) as ProcedureCodeCharges --> Here it's summing by ProcedureCodeCharges
	,ROW_NUMBER() OVER(PARTITION BY S.ProcedureCodeId ORDER BY charge) as ProcedureCodeCount
from Services S
JOIN ProcedureCodes PC on S.ProcedureCodeId = PC.ProcedureCodeId
where ISNULL(S.RECORDDELETED,'N') = 'N'
and DateOfService <= '2022-03-26'
and DateOfService > '2022-03-25'

select 
	s.ProcedureCodeId
	,PC.ProcedureCodeName
	,S.Billable
	,S.Charge
	,AVG(Charge) over() as AverageCharge
	,AVG(Charge) OVER(PARTITION BY S.ProcedureCodeid) as ProcedureCodeAvg
	,AVG(Charge) OVER(PARTITION BY S.ProcedureCodeid) - AVG(Charge) OVER() as VarianceAnalysis
	,COUNT(s.ProcedureCodeId) OVER(partition by s.procedurecodeid) AS ProcedureCodeCount  --> Counts times procedure code shows
	,SUM(Charge) OVER() as All_Charge_Totals --> blank OVER just to sum Charge column for ALL_Charge_Totals
	,SUM(Charge) OVER(PARTITION BY S.ProcedureCodeId) as ProcedureCodeCharges --> Here it's summing by ProcedureCodeCharges
	,ROW_NUMBER() OVER(PARTITION BY S.ProcedureCodeId ORDER BY charge) as ProcedureCodeCount
from Services S
JOIN ProcedureCodes PC on S.ProcedureCodeId = PC.ProcedureCodeId
where ISNULL(S.RECORDDELETED,'N') = 'N'
and DateOfService <= '2022-03-26'
and DateOfService > '2022-03-25'

















SELECT
         year, country, product, profit,
         ROW_NUMBER() OVER(PARTITION BY country) AS row_num1,
         ROW_NUMBER() OVER(PARTITION BY country ORDER BY year, product) AS row_num2
       FROM sales;



select top 2000* from Services
where ISNULL(RECORDDELETED,'N') = 'N'
order by DateOfService desc


select 
	ServiceId,
	ClientId,
	sum(charge) over() ChargeTotals
from Services
where ISNULL(RECORDDELETED,'N') = 'N'
and DateOfService <= getdate()
and DateOfService > '2021-10-01'



--So we get a total of $6,391,062.42
select 
	Procedurecodeid,
	sum(charge)
from Services
where ISNULL(RECORDDELETED,'N') = 'N'
and DateOfService <= getdate()
and DateOfService > '2021-10-01'
group by ProcedureCodeId

select 
	Procedurecodeid,
	sum(charge) OVER(PARTITION BY Charge) xvalues
from Services
where ISNULL(RECORDDELETED,'N') = 'N'
and DateOfService <= getdate()
and DateOfService > '2021-10-01'
group by ProcedureCodeId


select 
	Serviceid,
	Clientid,
	ProcedureCodeId,
	DateOfService
	EnddateofService,
	Unit,
	Status,
	ProgramId,
	Billable,
	Charge
from Services
where ISNULL(RECORDDELETED,'N') = 'N'
and DateOfService <= '2022-03-26'
and DateOfService > '2022-03-25'


--sum of the charges is   $42,262.95
select 
	Procedurecodeid,
	SUM(Charge)
from Services
where ISNULL(RECORDDELETED,'N') = 'N'
and DateOfService <= '2022-03-26'
and DateOfService > '2022-03-25'
group by ProcedureCodeId

SELECT Procedurecodeid,
	SUM(charge) AS ProcedureCodeCharges
       FROM Services
       GROUP BY ProcedureCodeId
       ORDER BY ProcedureCodeId

select 
	s.ProcedureCodeId,
	PC.ProcedureCodeName,
	COUNT(s.ProcedureCodeId) OVER(partition by s.procedurecodeid) AS ProcedureCodeCount,
	SUM(Charge) OVER() as All_Charge_Totals,
	SUM(Charge) OVER(PARTITION BY S.ProcedureCodeId) as ProcedureCodeCharges
from Services S
JOIN ProcedureCodes PC on S.ProcedureCodeId = PC.ProcedureCodeId
where ISNULL(S.RECORDDELETED,'N') = 'N'
and DateOfService <= '2022-03-26'
and DateOfService > '2022-03-25'




SELECT
         year, country, product, profit,
         SUM(profit) OVER() AS total_profit,
         SUM(profit) OVER(PARTITION BY country) AS country_profit
       FROM sales
       ORDER BY country, year, product, profit;


select 
	Serviceid,
	Clientid,
	ProcedureCodeId,
	DateOfService
	EnddateofService,
	Unit,
	Status,
	ProgramId,
	Billable,
	Charge
from Services
where ISNULL(RECORDDELETED,'N') = 'N'
and DateOfService <= '2022-03-26'
and DateOfService > '2022-03-25'
GROUP BY ProcedureCodeId


