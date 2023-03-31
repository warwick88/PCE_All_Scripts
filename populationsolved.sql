USE [SmartCare_datastore]
GO

/****** Object:  StoredProcedure [dbo].[ksp_Rpt_SrvRevDashboard_ClaimLineFacts]    Script Date: 6/1/2022 10:39:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





exec ksp_Rpt_SrvRevDashboard_ClaimLineFacts






CREATE PROCEDURE [dbo].[ksp_Rpt_SrvRevDashboard_ClaimLineFacts]
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
			AND CL.CreatedDate >= '2018-10-01'
			AND CL.CreatedDate <= '2022-10-01'
			)
		SELECT CL.*,C.AuthorizationNumber,a.AssignedPopulation,GC.CodeName FROM CTE_Finance_Dash CL
		LEFT JOIN Claims C ON CL.ClaimId = C.ClaimId
		LEFT JOIN Authorizations A ON C.AuthorizationNumber = A.AuthorizationNumber
		LEFT JOIN GlobalCodes GC ON A.AssignedPopulation = GC.GlobalCodeId

		select * from ClaimLines
		where ClaimLineId in (
		8344059,
8363518,
8381728,
8821953,
8857313,
8866391,
8874190,
8519968,
8554198,
8642483,
7715313)

SELECT * FROM ClaimLines
WHERE ClaimLineId=8381728

select * from Claims
where ClaimId in (
4286257)

SELECT * FROM ClaimLineAuthorizations
WHERE ClaimLineId=8381728

SELECT * FROM ProviderAuthorizations
WHERE ProviderAuthorizationId=369129

--so we are looking for 8933 authorizations with authorizationnumber 125573

select * from ProviderAuthorizations
where AuthorizationNumber='UM-20201009-312715'

select * from ProviderAuthorizations
where ProviderAuthorizationId='125573'


select * from ProviderAuthorizations
where ClientId=8933
and AuthorizationNumber='125573'
order by createddate desc


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


