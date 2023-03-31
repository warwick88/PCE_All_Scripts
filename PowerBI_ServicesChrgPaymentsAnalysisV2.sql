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

/*
	Notes from meeting with Team: CREATE VIEW [dbo].[kv_SrvRevDashboard_Programs] This view is now all set and available for use.
	Notes: So 
			This select --> Then ties to Charges
			Charges Tie to ARLedger with Charge ID
			ProcedureRates tie from the column "ProcedureRateId" In the Services original query
			From ProcedureRates you can look at DegreeGroup Modifier ETC

*/

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
	,ServiceDiagnosis1 = (select TOP 1 ICD10Code 
				from ServiceDiagnosis SD
				where SD.ServiceId = S.ServiceId and SD."Order" = 1 
				and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis2 = (select TOP 1 ICD10Code 
				from ServiceDiagnosis SD
				where SD.ServiceId = S.ServiceId and SD."Order" = 2 
				and ISNULL(SD.RecordDeleted,'N')='N')
	,ServiceDiagnosis3 = (select TOP 1 ICD10Code 
				from ServiceDiagnosis SD
				where SD.ServiceId = S.ServiceId and SD."Order" = 3 
				and ISNULL(SD.RecordDeleted,'N')='N')
from Services S
LEFT JOIN GlobalCodes GC ON S.Status = GC.GlobalCodeId 
LEFT JOIN ProcedureCodes PC ON S.ProcedureCodeId = PC.ProcedureCodeId
LEFT JOIN Locations L ON S.LocationId = L.LocationId
where ISNULL(S.RecordDeleted,'N') = 'N'
AND S.CreatedDate > '2022-01-01'
AND S.CreatedDate < '2022-01-10'
--and S.Charge is NOT NULL
--AND S.Billable = 'Y' --We don't ONLY want billable
AND S.ProcedureCodeId <> 944 --This is T1040 We don't want that
order by S.CreatedDate desc

SELECT C.*,S.ServiceId,S.DateOfService,S.ProcedureCodeId FROM Clients C
LEFT JOIN Services S on C.ClientId = S.ClientId 
	AND S.DateOfService =
		(
			SELECT MAX(DateOfService)
			FROM Services S2
			WHERE S2.ClientId = S.ClientId
		)
WHERE C.Active = 'Y'
AND ISNULL(C.Recorddeleted,'N')='N'

SELECT TOP 2500* FROM ClaimLines
ORDER BY CREATEDDATE DESC

SELECT TOP 2500* FROM Claims
ORDER BY CREATEDDATE DESC


SELECT * FROM Clients C
WHERE C.Active = 'Y'
AND ISNULL(C.Recorddeleted,'N')='N'

SELECT a.State, count(c.CustomerID)
FROM Product p
INNER JOIN Customer c ON c.CustomerID = p.CustomerID
LEFT JOIN Address a ON a.CustomerID = c.CustomerID 
      AND a.AddressID = 
        (
           SELECT MAX(AddressID) 
           FROM Address z 
           WHERE z.CustomerID = a.CustomerID
        )
WHERE p.ProductID = 101
GROUP BY a.State

select * from Clients
where clientid in (
130216,
129072,
96046,
125457,
126419,
96127)
SQL08R201.dwh.dbo.v_cleanBilliable_SERVICE_AND_CLAIM_V4

select * from Charges
where CreatedDate > '2022-01-01'
AND CreatedDate < '2022-01-10'

select * from ARLedger
where DateOfService > '2022-01-01'
AND DateOfService < '2022-01-10'
and (ISNULL

--You can get a charge ID
select * from Charges
where ServiceId in (
1063982,
1063973,
1063972,
1063969)

--This ledger is Charged it's charge amount, then when payment is made you will see a 
--Negative entry to bring balance to 0.
--This all ties to Coverage Plans

--So these ARLedger Payments seem to tie to ClaimeLinePayments - which then ties to a check
select * from ARLedger
where ChargeId in (
881395,
883638,
884420,
880599)

--Doesnt tie correctly
select * from ClaimLinePayments
where ClaimLinePaymentId in (44706,44722,44775)


select * from GlobalCodes
where GlobalCodeId in (44706)

select * from charges


select c.name as 'columnname'
,t.name as 'tablename'
from sys.columns c
join sys.tables t on c.object_id = t.object_id
where c.name like '%PaymentId%'
order by tablename, columnname;

--Eventually should look at the paymentID . Where is that from?

select * from ProcedureRates
where ProcedureRateId = 3284

--So from Charge ID we want to get into the AR Ledger

select * from ClaimLinePayments



select * from ClientCoveragePlans
where ClientCoveragePlanId=307115

--Procedure Rate id
select * from ProcedureRates
order by CreatedDate desc







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

