use ISKzooSmartCareQA

select * from CustomFieldsData
order by createddate desc

--So there are a lot of columns already present for this project, no need to insert
--Date 1/2 are used


--Date 4 field is open

--So we used field 4 for the new date collection
select * from CustomFieldsData
where ColumnDatetime4 is not null

--So Varchar 14 is open, going to use that
select * from CustomFieldsData
where ColumnVarchar14 is not null

--So adding these fields is working, testing in 1 client no problem, it writes exactly as intended to the fields.
select CustomFieldsDataId,ModifiedBy,PrimaryKey1,ColumnDatetime4,ColumnVarchar14 from CustomFieldsData
Where PrimaryKey1=93745
order by modifieddate desc


--So the two types of documents we need for the report
--DocumentCodeId: 60111 CCBHC Sliding Fee Scale
--I think Income Verification is the 2nd 60110 - test by doing one and see if it logs it in that capacity
select * from DocumentCodes
order by createddate desc

/*
	DocumentCodeId: 60111: CCBHC Sliding Fee Scale --> filled in document
	DocumentCodeId: 60110: Income Verification Scanned in document code
	So we can't do signed status b/c the scanned in one is not signed.
*/


select top 2* from Documents D
where D.DocumentCodeId in (60111,60110) --> So 60111 is CCBHC Sliding Fee Scale -- 60110 is
and D.Status = 22 --> We want Signed versions not In-Progress 
and ClientId=93745
order by createddate desc

select top 2* from Documents
where clientid=93745
and CreatedBy like 'Wbarlow%'
order by CreatedDate desc

--Additional Testing

select top 2* from Documents D
LEFT JOIN CustomFieldsData CFD ON D.ClientId = CFD.PrimaryKey1
where D.DocumentCodeId in (60111,60110) --> So 60111 is CCBHC Sliding Fee Scale -- 60110 is
and D.Status = 22 --> We want Signed versions not In-Progress 
and ClientId=93745
order by D.createddate desc

select D.DocumentId,D.CreatedBy,D.CreatedDate,D.ModifiedBy,D.ModifiedDate,D.ClientId,D.DocumentCodeId,D.EffectiveDate,D.Status,D.AuthorId
from Documents D
where D.DocumentCodeId in (60111,60110) --> So 60111 is CCBHC Sliding Fee Scale -- 60110 is
and D.Status = 22 --> We want Signed versions not In-Progress 
and ClientId=93745
order by D.createddate desc

select D.DocumentId
	,D.CreatedBy,D.CreatedDate
	,D.ModifiedBy,D.ModifiedDate
	,D.ClientId,D.DocumentCodeId
	,C.FirstName
	,C.LastName
	,D.EffectiveDate,D.Status
	,D.AuthorId
	,CFD.CustomFieldsDataId,CFD.ModifiedBy
	,CFD.ModifiedDate,CFD.PrimaryKey1 AS CustomDataClientId
	,CFD.ColumnVarchar14 AS 'CCBHC Sliding CheckBox'
	,cast(CFD.ColumnDatetime4 as date) AS 'CCBHC Checkbox Date'
	,CASE	
		WHEN CFD.ColumnVarchar14 LIKE '%Y' THEN 'Yes'
		WHEN CFD.ColumnVarchar14 LIKE '%N' THEN 'No'
		WHEN CFD.ColumnVarchar14 IS NULL THEN 'Not Completed Yet'
		ELSE 'Outlier'
	END AS 'CheckBox Status'
from Documents D
LEFT JOIN Clients C on D.ClientId = C.ClientId
LEFT JOIN CustomFieldsData CFD ON D.ClientId = CFD.PrimaryKey1
where D.DocumentCodeId in (60111,60110) --> So 60111 is CCBHC Sliding Fee Scale -- 60110 is
and D.Status = 22 --> We want Signed versions not In-Progress 
and D.ClientId=93745 --> You remove this section for the actual report.
ORder by CreatedDate desc


--GOOFIN WITH A NEW VERSION 1 RECORD PER CLIENT

--So this is pretty cool, we partitioned over....by document code and client ID, now we can just focus on selecting records with a 1 - wrap into CTE



/*
	So this should be modified to be CTE
*/


--So this checkbox constitues the 2nd document check.
SELECT * FROM DOCUMENTS
WHERE CLIENTID=126820
AND DOCUMENTCODEID IN (60111,60110)
ORDER BY CREATEDDATE DESC

select D.DocumentId
	,D.CreatedBy,D.CreatedDate
	,D.ModifiedBy,D.ModifiedDate
	,D.ClientId,D.DocumentCodeId
	,C.FirstName
	,C.LastName
	,D.EffectiveDate,D.Status
	,D.AuthorId
	,CFD.CustomFieldsDataId,CFD.ModifiedBy
	,CFD.ModifiedDate,CFD.PrimaryKey1 AS CustomDataClientId
	,CFD.ColumnVarchar14 AS 'CCBHC Sliding CheckBox'
	,cast(CFD.ColumnDatetime4 as date) AS 'CCBHC Checkbox Date'
	,CASE	
		WHEN CFD.ColumnVarchar14 LIKE '%Y' THEN 'Yes'
		WHEN CFD.ColumnVarchar14 LIKE '%N' THEN 'No'
		WHEN CFD.ColumnVarchar14 IS NULL THEN 'Not Completed Yet'
		ELSE 'Outlier'
	END AS 'CheckBox Status'
	,ROW_NUMBER() OVER(PARTITION BY D.CLIENTID,D.DocumentCodeid ORDER BY D.DocumentCodeId,D.CREATEDDATE DESC) AS COUNT1X
from Documents D
LEFT JOIN Clients C on D.ClientId = C.ClientId
LEFT JOIN CustomFieldsData CFD ON D.ClientId = CFD.PrimaryKey1
where D.DocumentCodeId in (60111,60110) --> So 60111 is CCBHC Sliding Fee Scale -- 60110 is
and D.Status = 22 --> We want Signed versions not In-Progress 
and D.ClientId=93745 --> You remove this section for the actual report.
--ORder by CreatedDate desc

SELECT * FROM Documents
where ClientId=93745
and DocumentCodeId in (60111)
order by CreatedDate desc

SELECT * FROM Documents
where DocumentCodeId in (60111,60110)
order by CreatedDate desc



select * from CustomFieldsData
WHERE PrimaryKey1=93745
order by createddate desc



select D.DocumentId
	,D.CreatedBy,D.CreatedDate
	,D.ModifiedBy,D.ModifiedDate
	,D.ClientId,D.DocumentCodeId
	,C.FirstName
	,C.LastName
	,D.EffectiveDate,D.Status
	,D.AuthorId
	,CFD.CustomFieldsDataId,CFD.ModifiedBy
	,CFD.ModifiedDate,CFD.PrimaryKey1 AS CustomDataClientId
	,CFD.ColumnVarchar14 AS 'CCBHC Sliding CheckBox'
	,cast(CFD.ColumnDatetime4 as date) AS 'CCBHC Checkbox Date'
	,CASE	
		WHEN CFD.ColumnVarchar14 LIKE '%Y' THEN 'Yes'
		WHEN CFD.ColumnVarchar14 LIKE '%N' THEN 'No'
		WHEN CFD.ColumnVarchar14 IS NULL THEN 'Not Completed Yet'
		ELSE 'Outlier'
	END AS 'CheckBox Status'
	,ROW_NUMBER() OVER(PARTITION BY D.CLIENTID,D.DocumentCodeid ORDER BY D.DocumentCodeId,D.CREATEDDATE DESC) AS COUNT1X
from Documents D
LEFT JOIN Clients C on D.ClientId = C.ClientId
LEFT JOIN CustomFieldsData CFD ON D.ClientId = CFD.PrimaryKey1
where D.DocumentCodeId in (60111,60110) --> So 60111 is CCBHC Sliding Fee Scale -- 60110 is
and D.Status = 22 --> We want Signed versions not In-Progress 
 --> You remove this section for the actual report.
--ORder by CreatedDate desc

