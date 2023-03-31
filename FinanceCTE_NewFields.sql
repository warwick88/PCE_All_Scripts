use SmartCarePreprod

/*

*/




;
with CTEService as 
( select 
	serviceid
	,DateOfService
	,clientid
	ProgramId
	,CASE 
		WHEN DateOfService > '10-20-2021' THEN 'EndMonth'
		WHEN DateOfService > '10-10-2021' THEN 'MidMonth'
		WHEN DateOfService > '10-01-2021' THEN 'Early Month'
		else 'whateverman'
	END AS Description
	from Services
	where DateOfService >= '10-01-2021'
	and DateOfService < '11-01-2021'
	)
	select * from CTEService


; 
with CTE_Finance as 
(
select D.DocumentId
	,D.CreatedBy
	,D.CreatedDate
	,D.ModifiedBy as 'Doc Modified By'
	,D.ModifiedDate as 'Doc Modified Date'
	,D.ClientId,D.DocumentCodeId
	,C.FirstName
	,C.LastName
	,D.EffectiveDate,D.Status
	,D.AuthorId
	,CFD.CustomFieldsDataId
	,CFD.ModifiedBy
	,CFD.ModifiedDate,CFD.PrimaryKey1 AS CustomDataClientId
	,CFD.ColumnVarchar14 AS 'CCBHC Sliding CheckBox'
	,CFD.ColumnVarchar15 AS 'CCBHC Declined?'
	,cast(CFD.ColumnDatetime4 as date) AS 'CCBHC Checkbox Date'
	,CASE	
		WHEN CFD.ColumnVarchar14 LIKE 'Y' THEN 'Proof Received'
		WHEN CFD.ColumnVarchar15 LIKE 'Y' THEN 'Sliding Fee Declined'
		WHEN CFD.ColumnVarchar14 IS NULL AND CFD.ColumnVarchar15 IS NULL THEN 'Not Complete'
		WHEN CFD.ColumnVarchar14 LIKE 'N' AND CFD.ColumnVarchar15 IS NULL THEN 'Not Complete'
		ELSE 'Outlier'
	END AS 'CheckBox Status'
	,ROW_NUMBER() OVER(PARTITION BY D.CLIENTID,D.DocumentCodeid ORDER BY D.DocumentCodeId,D.CREATEDDATE DESC) AS COUNT1X
from Documents D
LEFT JOIN Clients C on D.ClientId = C.ClientId
LEFT JOIN CustomFieldsData CFD ON D.ClientId = CFD.PrimaryKey1
where D.DocumentCodeId in (60111,60112) --> So 60111 is CCBHC Sliding Fee Scale -- 60110 is
and D.Status = 22 
)
select *
	,CASE	
		WHEN DocumentCodeId = 60111 THEN 'CCBHC Sliding Fee Scale'
		WHEN DocumentCodeId = 60112 THEN 'Scanned in Income Verification'
	END AS 'Document Actual Name'
from CTE_Finance
where COUNT1X=1

/*
	60111: CCBHC Sliding Fee Scale
	60112: Income Verification
*/
SELECT * FROM DocumentCodes
WHERE DOCUMENTCODEID IN (
60111,
60112) 

SELECT * FROM DocumentCodes
ORDER BY CREATEDDATE DESC