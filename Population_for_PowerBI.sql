


use ProdSmartCare

select top 10000* from services
order by createddate desc

select * from globalcodes
where globalcodeid in (
24434,
24437,
24432,
24435,
24436,
24433)

--So population is on authorizations
select distinct(assignedpopulation) from authorizations
order by createddate desc

select * from authorizations
order by createddate desc

select  AD.*,gc.codename from authorizationdocuments AD
JOIN GLOBALCODES GC ON AD.assignedpopulation = GC.Globalcodeid
order by createddate desc

--So this seems to show if a service required an auth
/*	
	So this is just like how it was before, Each Service has a Serviceauthorization
	for coverage plan & authorization id which ties to provider authorization
	and of course Authorization ID ties to population!

	so Serviceauthorizations tie to Auths
*/
select SA.*,GC.Codename from ServiceAuthorizations SA
LEFT JOIN Authorizations A ON SA.AUTHORIZATIONID = A.AUTHORIZATIONID
LEFT JOIN GLOBALCODES GC ON A.assignedpopulation = GC.Globalcodeid
WHERE SA.CREATEDDATE > '2021-10-01'

--Assigned Population is here also
select top 5000* from providerauthorizations
order by createddate desc

select top 1000* from ClaimLines
left join claims
order by createddate desc

select top 2000* from claims
order by createddate desc

SELECT col.name  AS 'ColumnName', tab.name AS 'TableName'
FROM sys.columns col
JOIN sys.tables  tab  ON col.object_id = tab.object_id
WHERE col.name LIKE '%Population%'
ORDER BY TableName,ColumnName;

SELECT col.name  AS 'ColumnName', tab.name AS 'TableName'
FROM sys.columns col
JOIN sys.tables  tab  ON col.object_id = tab.object_id
WHERE col.name LIKE '%assignedpopulation%'
ORDER BY TableName,ColumnName;