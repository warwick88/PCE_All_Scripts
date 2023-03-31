USE [SmartCare_datastore]
GO

/****** Object:  StoredProcedure [dbo].[ksp_Rpt_SrvRevDashboard_ClaimLineFacts]    Script Date: 6/1/2022 3:04:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO












ALTER PROCEDURE [dbo].[ksp_Rpt_SrvRevDashboard_ClaimLineFacts]
 AS  
 -- =============================================        
 -- Author: Warwick Barlow & Mike Venner & Mark Marsh   
 -- Create date: 12.21.21  
 -- Description: RDL Data Set for CCBHC Sliding Fee Custom Form.
 -- =============================================        
 BEGIN  
 BEGIN TRY  
	
	; 
	with CTE_Finance_Dash as 
		( select 
			CL.ClaimLineId
			,C.ClientId
			,C.ClaimId
			,CL.CreatedBy
			,CL.CreatedDate
			,CL.ModifiedBy
			,CL.ModifiedDate
			,GC.CodeName AS 'Claim Line Status' 
			,CL.PlaceOfService AS 'Place Of Service ID'
			,GC2.CodeName AS 'Claim Place of Service' 
			,CL.BillingCodeId
			,BC.BillingCode
			,CL.FromDate
			,CL.ToDate
			,CL.AuthorizationExistsAtEntry
			,CL.Modifier1
			,CL.Modifier2
			,CL.Modifier3
			,CL.Modifier4
			,CL.Charge
			,CL.Units
			,CL.PaidAmount
			,CL.ClaimedAmount
			,CL.NeedsToBeWorked
			,CL.DoNotAdjudicate
			,CL.ToReadjudicate
			,CL.RenderingProviderId
			,CL.RenderingProviderName
			,CL.LastAdjudicationDate
			,CL.FinalStatus
			,C.Diagnosis1 AS 'Claim Diagnosis 1'
			,C.Diagnosis2 AS 'Claim Diagnosis 2'
			,C.Diagnosis3 AS 'Claim Diagnosis 3'
			,C.TotalCharge
			,C.AmountPaid
			,C.BalanceDue
			,C.ReceivedDate
			,C.CleanClaimDate
			,C.SiteId
			,S.SiteName
			,P.ProviderName
			,C.BillingProviderInfo
			FROM ClaimLines CL
		LEFT JOIN GlobalCodes GC ON CL.Status = GC.GlobalCodeId
		LEFT JOIN GlobalCodes GC2 ON CL.PlaceOfService = GC2.GlobalCodeId
		LEFT JOIN BillingCodes BC ON CL.BillingCodeId = BC.BillingCodeId
		LEFT JOIN Claims C ON CL.ClaimId = C.ClaimId
		LEFT JOIN Sites S on C.SiteId = S.SiteId
		LEFT JOIN Providers P on S.ProviderId = P.ProviderId
		where 1=1
			AND ISNULL(CL.RecordDeleted,'N')='N'
			AND CL.CreatedDate >= '2021-10-01'
			AND CL.CreatedDate <= '2022-10-01'
			),
		CL1 AS (
		select CL.*
			,CA.ProviderAuthorizationid
			,CA.UnitsUsed
			,PA.AssignedPopulation
			,GC.Codename 
			,ROW_NUMBER() OVER (PARTITION BY CL.CLAIMLINEID ORDER BY CL.CREATEDDATE DESC) AS CLAIMLINEIDCOUNT
			 from CTE_Finance_Dash  CL
		LEFT JOIN ClaimLineAuthorizations CA ON CL.ClaimLineId = CA.ClaimLineId AND ISNULL(CA.RECORDDELETED,'N')='N' 
		LEFT JOIN ProviderAuthorizations PA ON CA.ProviderAuthorizationId = PA.ProviderAuthorizationId
		LEFT JOIN GlobalCodes GC on PA.AssignedPopulation = GC.Globalcodeid
		where 1=1)
		SELECT * FROM CL1
		WHERE CLAIMLINEIDCOUNT=1



 END TRY  
   
 BEGIN CATCH  
 	DECLARE @Error VARCHAR(8000)  
 
 	SET @Error = CONVERT(VARCHAR, ERROR_NUMBER()) + '*****' + CONVERT(VARCHAR(4000), ERROR_MESSAGE()) + '*****' + ISNULL(CONVERT(VARCHAR, ERROR_PROCEDURE()), 'ksp_Rpt_SrvRevDashboard_ClaimLineFacts') + '*****' + CONVERT(VARCHAR, ERROR_LINE()) + '*****' + CONVERT(VARCHAR, ERROR_SEVERITY()) + '*****' + CONVERT(VARCHAR, ERROR_STATE())  
 
 	RAISERROR (  
 		@Error,-- Message text.                                                                       
 		16,-- Severity.                                                              
 		1 -- State.                                                           
 	);  
 END CATCH  
 END
 
GO


