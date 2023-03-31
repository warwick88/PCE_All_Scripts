USE [SmartCarePreProd]
GO

/****** Object:  StoredProcedure [dbo].[ksp_dfa_Assessment_AccessLog]    Script Date: 5/25/2022 10:27:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














CREATE PROCEDURE [dbo].[ksp_dfa_Assessment_AccessLog]
 	@DocumentVersionId INT
 AS  
 -- =============================================        
 -- Author: Warwick Barlow    
 -- Create date: 5/25/2022    
 -- Description: RDL Data Set

 -- =============================================        
 BEGIN  
 BEGIN TRY  
	SELECT S.Clientid
		,C.FirstName
			,C.LastName
			,S.ServiceId
			,S.DateOfService
			,P.ProgramName AS 'Service Program'
			,L.LocationName AS 'Service Location'
			,CASE
				WHEN S.Status = 70 THEN 'Scheduled'
				WHEN S.Status = 71 THEN 'Show'
				WHEN S.Status = 72 THEN 'No Show'
				WHEN S.Status = 73 THEN 'Cancel'
				WHEN S.Status = 75 THEN 'Complete'
				WHEN S.Status = 76 THEN 'Error'
				END AS 'Service Status' 
			,PC.ProcedureCodeName AS 'Procedure Code Name'
			,SS.FirstName + ' '+ SS.LastName AS 'Clinician Full Name'
			FROM services S
	JOIN CLIENTS C ON S.Clientid = C.Clientid
	JOIN LOCATIONS L ON S.LocationId = L.LocationId
	JOIN Programs P on S.ProgramId = P.ProgramId
	JOIN Staff SS ON S.ClinicianId = SS.StaffId
	JOIN ProcedureCodes PC on S.ProcedureCodeId = PC.ProcedureCodeId
	where S.ProcedureCodeId in (
	1143,
	775,
	774,
	773,
	759,
	754,
	749,
	725,
	724,
	648,
	641,
	765,
	651,
	637)
	AND DateOfService < GETDATE()
	order by S.DateofService desc
 
 END TRY  
   
 BEGIN CATCH  
 	DECLARE @Error VARCHAR(8000)  
 
 	SET @Error = CONVERT(VARCHAR, ERROR_NUMBER()) + '*****' + CONVERT(VARCHAR(4000), ERROR_MESSAGE()) + '*****' + ISNULL(CONVERT(VARCHAR, ERROR_PROCEDURE()), 'ksp_dfa_Assessment_AccessLog') + '*****' + CONVERT(VARCHAR, ERROR_LINE()) + '*****' + CONVERT(VARCHAR, ERROR_SEVERITY()) + '*****' + CONVERT(VARCHAR, ERROR_STATE())  
 
 	RAISERROR (  
 		@Error,-- Message text.                                                                       
 		16,-- Severity.                                                              
 		1 -- State.                                                           
 	);  
 END CATCH  
 END
 
GO


