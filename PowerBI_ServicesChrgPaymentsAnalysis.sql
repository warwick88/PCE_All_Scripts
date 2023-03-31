use SmartCare_datastore



/*

	Power BI: Finance Charges to Payments Visualization
	We are in SQL08R201, using SmartCare_Datastore, which is a 1 day lag image of PROD.


*/


--First round of fact finding. Let's see what Dimensions we need to pull into our report
select top 200* from Services
where ISNULL(RecordDeleted,'N') = 'N'
order by CreatedDate desc


/*
	So Joined tables here have been joined b/c they will not be used as Dimensions, simply because
	the values joined are ALL we need from the table.
*/
select 
	S.ServiceId
	,S.CreatedBy
	,S.CreatedDate
	,S.ModifiedBy
	,S.ModifiedDate
	,S.ClientId
	,PC.DisplayAs as 'DisplayAs'
	,PC.ProcedureCodeName as 'Procedure Code Name'
	,GC.CodeName as 'Service Status'
	,S.DateOfService
	,S.EndDateOfService
	,S.Unit
	,S.ClinicianId --> First Dimension table, no need to join, as we want lots of staff details. Gender and primary programs etc
	,S.ProgramId
	,S.Billable
	,S.ClientWasPresent
	,S.Charge
	,S.ProcedureRateId
from Services S
LEFT JOIN GlobalCodes GC ON S.Status = GC.GlobalCodeId 
LEFT JOIN ProcedureCodes PC ON S.ProcedureCodeId = PC.ProcedureCodeId
LEFT JOIN Locations L ON S.LocationId = L.LocationId
where ISNULL(S.RecordDeleted,'N') = 'N'
AND S.CreatedDate > '2022-01-01'
AND S.CreatedDate < '2022-01-10'
AND S.ProcedureCodeId <> 944 --> This is T1040 CCBHC Per Diem
order by S.CreatedDate desc

/*
	Tables reviewed as Dimensions, typically found to just be data pulls no need for whole table
*/
select * from ProcedureCodes
where ProcedureCodeId in (
623,
863,
813)

select * from Locations
where locationid in (
212,
219,
21,
12,
225)

select * from GlobalCodes
where GlobalCodeId = 78097

select * from ProcedureRates
where ProcedureRateId in (
4584,
3214,
3174,
3174,
4556,
4556)



--We don't want to join this I'm thinking
SELECT * FROM Staff
where StaffId in (
1986,
36414)



--Analysis on charges and payments

select 
	S.ServiceId
	,S.CreatedBy
	,S.CreatedDate
	,S.ModifiedBy
	,S.ModifiedDate
	,S.ClientId
	,PC.DisplayAs as 'DisplayAs'
	,S.ProcedureCodeId
	,PC.ProcedureCodeName as 'Procedure Code Name'
	,GC.CodeName as 'Service Status'
	,S.DateOfService
	,S.EndDateOfService
	,S.Unit
	,S.ClinicianId --> First Dimension table, no need to join, as we want lots of staff details. Gender and primary programs etc
	,S.ProgramId
	,S.Billable
	,S.ClientWasPresent
	,S.Charge
	,S.ProcedureRateId
from Services S
LEFT JOIN GlobalCodes GC ON S.Status = GC.GlobalCodeId 
LEFT JOIN ProcedureCodes PC ON S.ProcedureCodeId = PC.ProcedureCodeId
LEFT JOIN Locations L ON S.LocationId = L.LocationId
where ISNULL(S.RecordDeleted,'N') = 'N'
AND S.CreatedDate > '2022-01-01'
AND S.CreatedDate < '2022-01-10'
and S.Charge is NOT NULL
AND S.Billable = 'Y'
AND S.ProcedureCodeId <> 944
order by S.CreatedDate desc

select * from Charges
where ServiceId in (
1063493,
1063490,
1063488,
1063486,
1063485,
1063484,
1063483,
1063478,
1063477,
1063476)


--Twenty entries makes sense since 10 services each get 2 entires, debit the account
--Then Credit when payment is made. Debit is positive since you are Adding to the account
--The credit, subtraction from the ledger. Reversal of normal thinking.
Select * from ARLedger
where ChargeId in (
880194,
880224,
880254,
880256,
879739,
879758,
879774,
879939,
879941,
879943)

select top 100* from Charges
order by CreatedDate desc

select top 1000* from Services
where Charge is not null
and DateOfService < '2022-03-01'
and ProcedureCodeId <> 944
order by CreatedDate desc


--So Service creates a Charge
select * from services
where serviceid=1023945

--Charge is then tied to ARLedger for activity
select * from Charges
where serviceid=1023945


--This ledger is Charged it's charge amount, then when payment is made you will see a 
--Negative entry to bring balance to 0.
--This all ties to Coverage Plans
select * from ARLedger
where ChargeId=856664


select * from ARLedger
where createddate > '2022-04-01'
order by createddate desc

select * from payments

--I am not seeing the Services from claims info reaching this environment

