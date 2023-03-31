
use ISKzooSmartCareQA
select * from systemdatabases
update systemdatabases set OrganizationName='KCMHSAS KQA',
ConnectionString='Data Source=SLNONPROD-DB;Initial Catalog=ISKZOOSmartCareQA;Trusted_Connection=yes;'
where systemdatabaseid=2

==========================================
--here now
--Select OrganizationName,ReportURL,ReportFolderName,ReportServerDomain,ReportServerUserName,ReportServerPassword,ReportServerConnection from systemconfigurations
--update systemconfigurations set 
--OrganizationName='Kalamazoo KQA | 06/02/2022',
--ReportURL='http://slnonprod-db/Reportserver_SLNONPROD',
--ReportFolderName='QA/SCDocuments',
--ReportServerDomain='KCMHSAS',
--ReportServerUserName='streamline',
--ReportServerPassword='jun09sat',
--ReportServerConnection='Data Source=SLNONPROD-DB;Initial Catalog=IsKzooSmartCareQA;Trusted_Connection=yes;'

==========================================

select * from systemreports 
--update systemreports set reporturl=replace(reporturl,'http://kcmh-db1/ReportServer?/ProdSCDocuments/','http://slnonprod-db/Reportserver_SLNONPROD?/QA/SCDocuments/')
--update systemreports set reporturl=replace(reporturl,'http://kcmh-db1/ReportServer?/ProdSCReports/','http://slnonprod-db/Reportserver_SLNONPROD?/QA/SCReports/')

==========================================

select * from reportservers
--update reportservers set 
--Name='KCMHSAS KQA Report Server',
--URL='http://slnonprod-db/Reportserver_SLNONPROD',
--ConnectionString='Data Source=SLNONPROD-DB;Initial Catalog=ReportServer;Trusted_Connection=yes;',
--DomainName='KCMHSAS',
--UserName='streamline',
--Password='jun09sat'

==========================================

select * from ImageServers
--update ImageServers set 
--ImageServerName='KCMHSAS KQA ImageServer',
--ImageServerURL='http://localhost/QAImageService/ImageServerWebService.asmx',
--ImageViewReportPath='/QA/SCDocuments/ScannedViewDocReport'


==========================================

select * from reports
--update reports set reportserverpath=replace(reportserverpath,'/ProdSCReports/','/QA/SCReports/')
--update reports set reportserverpath=replace(reportserverpath,'/ProdDWReports/','/QA/DWReports/')
--update reports set reportserverpath=replace(reportserverpath,'/StreamlineStandardReportsPROD/','/QA/StreamlineStandardReportsPREPROD/')
--update reports set reportserverpath=replace(reportserverpath,'/ProdSCDocuments/','/QA/SCDocuments/')
--update reports set reportserverpath=replace(reportserverpath,'/prodcmdocuments/','/QA/CMDocuments/')
--update reports set reportserverpath=replace(reportserverpath,'/ProdCMReports/','/QA/CMReports/')
--update reports set reportserverpath=replace(reportserverpath,'/RDWCoreReports/','/QA/RDWCoreReports/')
--update reports set reportserverpath=replace(reportserverpath,'/DCH/TEDS/','/QA/DCH/TEDS/')
--update reports set reportserverpath=replace(reportserverpath,'/SWMBH/','/QA/SWMBH/')

==========================================

Select * from SystemConfigurationKeys where [key] like '%adhoc%'

--update SystemConfigurationKeys set Value='https://slnonprod.iskzoo.org/ISKzooSCAdhocReportingQA/ValidateToken.aspx?StaffId=' where [key] = 'AdhocLoginURL'

==========================================

select * from catalogs

update catalogs set connectionstring='Data Source=SLNONPROD-DB;Initial Catalog=IsKzooSmartCareQA;Trusted_Connection=yes;'

==========================================

select * from webfarmnodes

Truncate Table webfarmnodes

==========================================
--"Disable and enable  the Triggers of target database [SC] using query"
--this step is going slowly at 1:40 usually instant.
DECLARE @string VARCHAR(8000)
DECLARE @tableName NVARCHAR(500)
DECLARE cur CURSOR
FOR SELECT name AS tbname FROM sysobjects WHERE id IN(SELECT parent_obj FROM sysobjects WHERE xtype='tr')
OPEN cur
FETCH next FROM cur INTO @tableName
WHILE @@fetch_status = 0
BEGIN
print @tableName
SET @string ='Alter table '+ @tableName + ' Disable trigger all'
EXEC (@string)
FETCH next FROM cur INTO @tableName
END
CLOSE cur
DEALLOCATE cur

==========================================

--"Enable  the Triggers of target database [SC] using query

DECLARE @string VARCHAR(8000)
DECLARE @tableName NVARCHAR(500)
DECLARE cur CURSOR
FOR SELECT name AS tbname FROM sysobjects WHERE id IN(SELECT parent_obj FROM sysobjects WHERE xtype='tr')
OPEN cur
FETCH next FROM cur INTO @tableName
WHILE @@fetch_status = 0
BEGIN
print @tableName
SET @string ='Alter table '+ @tableName + ' Enable trigger all'
EXEC (@string)
FETCH next FROM cur INTO @tableName
END
CLOSE cur
DEALLOCATE cur

==========================================
--Please set set the database to recovery model to simple for NON-PROD
==========================================

--synonyms 

==========================================

select * from systemconfigurationkeys WHERE [Key]='SETAPPLICATIONHEADERCOLOR'
--update systemconfigurationkeys set Value='BLUE' WHERE [Key]='SETAPPLICATIONHEADERCOLOR'

==========================================

--"After Restore of any Databases for TRAIN/TEST/QA/PreProd ---Execute the below scripts

Script1:
DECLARE @DBname NVARCHAR(50)
SELECT @DBname = DB_NAME()
EXEC ('ALTER DATABASE ' +'['+ @DBname +']'+ ' SET TRUSTWORTHY ON')
EXEC ('ALTER AUTHORIZATION on DATABASE::' +'['+ @DBname +']'+ ' to sa')

Script2:
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'clr enabled', 1;
GO
RECONFIGURE;
GO

==========================================

Select PMPWebServiceURL, * from PMPWebServiceConfigurations 
update PMPWebServiceConfigurations set PMPWebServiceURL='https://scriptstaging.streamlinehealthcare.com/SSService/rx/PMPRequest'