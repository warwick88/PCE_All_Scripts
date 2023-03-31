USE [SmartCare_datastore]
GO

/****** Object:  View [dbo].[kv_FiscalYearServicesWB]    Script Date: 5/3/2022 2:12:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[kv_SrvRevDashboard_Programs]
AS
SELECT ProgramId
	,ProgramCode
	,ProgramName
	,Active
	,CASE	
		WHEN ProgramType = 25163 THEN 'Admit'
		WHEN ProgramType = 25247 THEN 'Call Intake'
		WHEN ProgramType = 25164 THEN 'External'
		ELSE 'Unassigned'
	END AS ProgramType
	,Address
	,City
	,State
	,ZipCode
	,AddressDisplay
	 FROM Programs
WHERE Active='Y'
AND ISNULL(RECORDDELETED,'N')='N'



GO

