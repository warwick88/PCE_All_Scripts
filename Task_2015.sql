USE ProdSmartCare

select * from GlobalCodes
where GlobalCodeId=79093
--CodeName was : No Level of Care Assessed per FEI Assessment
BEGIN TRAN
update GlobalCodes
SET CodeName = 'No Level of Care Assessed per FEI Assessment 0'
where GlobalCodeId=79093
COMMIT TRAN