use KDEVSmartCare


select * from systemdatabases
--done 11.7.22
--select * from systemdatabases
--update systemdatabases set OrganizationName='KCMHSAS KDEV',
--ConnectionString='Data Source=SLNONPROD-DB;Initial Catalog=Test;Trusted_Connection=yes;'
--where systemdatabaseid=2

==========================================

--done 11.7.22
Select OrganizationName,ReportURL,ReportFolderName,ReportServerDomain,ReportServerUserName,ReportServerPassword,ReportServerConnection from systemconfigurations
--update systemconfigurations set 
--OrganizationName='Kalamazoo KDEV | 11/22/2022',
--ReportURL='http://slnonprod-db/Reportserver_SLNONPROD',
--ReportFolderName='Test/SCDocuments',
--ReportServerDomain='KCMHSAS',
--ReportServerUserName='streamline',
--ReportServerPassword='jun09sat',
--ReportServerConnection='Data Source=SLNONPROD-DB;Initial Catalog=Test;Trusted_Connection=yes;'

==========================================

--done 11.7.22
--select * from systemreports 
--update systemreports set reporturl=replace(reporturl,'http://kcmh-db1/ReportServer?/ProdSCDocuments/','http://slnonprod-db/Reportserver_SLNONPROD?/Test/SCDocuments/')
--update systemreports set reporturl=replace(reporturl,'http://kcmh-db1/ReportServer?/ProdSCReports/','http://slnonprod-db/Reportserver_SLNONPROD?/Test/SCReports/')

==========================================
--done 11.7.22
--select * from reportservers
--update reportservers set 
--Name='KCMHSAS Test Report Server',
--URL='http://slnonprod-db/Reportserver_SLNONPROD',
--ConnectionString='Data Source=SLNONPROD-DB;Initial Catalog=ReportServer;Trusted_Connection=yes;',
--DomainName='KCMHSAS',
--UserName='streamline',
--Password='jun09sat'

==========================================

--done 11.7.22
--select * from ImageServers
update ImageServers set 
ImageServerName='KCMHSAS Test ImageServer',
ImageServerURL='http://localhost/TestImageService/ImageServerWebService.asmx',
ImageViewReportPath='/Test/SCDocuments/ScannedViewDocReport'

==========================================

--done 11.7.22
--select * from reports
--update reports set reportserverpath=replace(reportserverpath,'/ProdSCReports/','/Test/SCReports/')
--update reports set reportserverpath=replace(reportserverpath,'/ProdDWReports/','/Test/DWReports/')
--update reports set reportserverpath=replace(reportserverpath,'/StreamlineStandardReportsPROD/','/Test/StreamlineStandardReportsTest/')
--update reports set reportserverpath=replace(reportserverpath,'/ProdSCDocuments/','/Test/SCDocuments/')
--update reports set reportserverpath=replace(reportserverpath,'/prodcmdocuments/','/Test/CMDocuments/')
--update reports set reportserverpath=replace(reportserverpath,'/ProdCMReports/','/Test/CMReports/')
--update reports set reportserverpath=replace(reportserverpath,'/RDWCoreReports/','/Test/RDWCoreReports/')
--update reports set reportserverpath=replace(reportserverpath,'/DCH/TEDS/','/Test/DCH/TEDS/')
--update reports set reportserverpath=replace(reportserverpath,'/SWMBH/','/Test/SWMBH/')

==========================================


--done 11.7.22
Select * from SystemConfigurationKeys where [key] like '%adhoc%'
--done 11.7.22
--update SystemConfigurationKeys set Value='https://slnonprod.iskzoo.org/SCAdhocreportingTest/ValidateToken.aspx?StaffId=' where [key] = 'AdhocLoginURL'

==========================================

select * from catalogs

update catalogs set connectionstring='Data Source=SLNONPROD-DB;Initial Catalog=SmartCareTest;Trusted_Connection=yes;'

==========================================

select * from webfarmnodes

Truncate Table webfarmnodes

==========================================
--"Disable and enable  the Triggers of target database [SC] using query"

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
--done 11.7.22
--synonyms 

==========================================

--select * from systemconfigurationkeys WHERE [Key]='SETAPPLICATIONHEADERCOLOR'
--update systemconfigurationkeys set Value='BLACK' WHERE [Key]='SETAPPLICATIONHEADERCOLOR'

==========================================

--done 11.7.22
Script1:
DECLARE @DBname NVARCHAR(50)
SELECT @DBname = DB_NAME()
EXEC ('ALTER DATABASE ' +'['+ @DBname +']'+ ' SET TRUSTWORTHY ON')
EXEC ('ALTER AUTHORIZATION on DATABASE::' +'['+ @DBname +']'+ ' to sa')

--done 11.7.22
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
--done 11.7.22
Select PMPWebServiceURL, * from PMPWebServiceConfigurations 
update PMPWebServiceConfigurations set PMPWebServiceURL='https://scriptstaging.streamlinehealthcare.com/SSService/rx/PMPRequest'