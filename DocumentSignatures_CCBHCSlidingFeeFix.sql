USE [IsKzooSmartCareQA]
GO

/****** Object:  StoredProcedure [dbo].[ksp_dfa_CCBHCSlidingFeeDFA]    Script Date: 9/8/2022 11:01:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



select * from CustomDocumentCCBHCSlidingFeeScale
order by createddate desc

--So this is one you did sign with the PAD it works
exec ksp_dfa_CCBHCSlidingFeeDFA '8943455'

select * from documents
order by CreatedDate desc

select * from DocumentVersions
where documentid=25414124
--here is an example of one you just signed now that has a password inputed instead.
exec ksp_dfa_CCBHCSlidingFeeDFA '8943488'

select * from DocumentSignatures
where SignedDocumentVersionId='8943488'

--so we should join signername or or 
--MODIFY the DS signature portion to look for either or. Not just physical.
--There are multiple types. So lets adjust that join logic to work better

CREATE PROCEDURE [dbo].[ksp_dfa_CCBHCSlidingFeeDFA]
 	@DocumentVersionId INT
 AS  
 -- =============================================        
 -- Author: Warwick Barlow & Mike Venner & Mark Marsh   
 -- Create date: 12.21.21  
 -- Description: RDL Data Set for CCBHC Sliding Fee Custom Form.
 -- =============================================        
 BEGIN  
 BEGIN TRY  
	
 	SELECT 
 		SFS.DocumentVersionId,
 		C.ClientId,
 		SFS.Firstname,
 		SFS.LastName,
		SFS.MiddleInitial,
		SFS.DateOfBirth,
		SFS.address,
		SFS.city,
		SFS.state,
		SFS.zip,
		SFS.phone,
		SFS.AreYouEmployed,
		SFS.Employer,
		SFS.Age01,
		SFS.Age02,
		SFS.Age03,
		SFS.Age04,
		SFS.Age05,
		SFS.Age06,
		SFS.Relationship01,
		SFS.Relationship02,
		SFS.Relationship03,
		SFS.Relationship04,
		SFS.Relationship05,
		SFS.Relationship06,
		SFS.FamilyMemberName01,
		SFS.FamilyMemberName02,
		SFS.FamilyMemberName03,
		SFS.FamilyMemberName04,
		SFS.FamilyMemberName05,
		SFS.FamilyMemberName06,
		SFS.FamDob01,
		SFS.FamDob02,
		SFS.FamDob03,
		SFS.FamDob04,
		SFS.FamDob05,
		SFS.FamDob06,
		SFS.HowMuch01,
		SFS.HowMuch02,
		SFS.HowMuch03,
		SFS.HowMuch04,
		SFS.HowMuch05,
		SFS.HowMuch06,
		SFS.FullTime,
		SFS.PartTime,
		SFS.Temp,
		SFS.Contract,
		SFS.LaidOff,
		SFS.disabled,
		SFS.IncomeSource01,
		SFS.IncomeSource02,
		SFS.IncomeSource03,
		SFS.IncomeSource04,
		SFS.IncomeSource05,
		SFS.IncomeSource06,
		SFS.FamilySize,
		SFS.HouseHoldInc,
		SFS.AnnualInc,
		SFS.IfYes,
		SFS.IfNo,
		SFS.CoPay,
 		D.Documentid,
		DV.EffectiveDate,

 		S.FirstName AS AuthorFN,
 		S.LastName as AuthorLN,
 		S.SigningSuffix,
		--AA.Guardian as GuardianName, --This is the name of the patient guardian
		--AA.PhysicalSignature as PhysicalSignature, --Physical signature for the Guardian
		DS.StaffPrepDate AS PrepDate, --This is the signature Date field for staff member.
		DS.staffsignature1, --This is the staff Physical image of their signature.
		--AA.GuardianSignature AS GuardianSignature -- This is the signatureDATE for the Guardian.
		AA.CLIENTSIGNATURE1,
		AA.ClientPrepDate
 
 		FROM CustomDocumentCCBHCSlidingFeeScale SFS
 		JOIN DocumentVersions DV ON SFS.DocumentVersionId = DV.DocumentVersionId
 		JOIN Documents D ON DV.DocumentId = D.DocumentId
 		LEFT JOIN
			(SELECT SIGNERNAME AS AUTHORAGAIN,PhysicalSignature as staffsignature1, SignatureDate as StaffPrepDate, DocumentId
			FROM DocumentSignatures DS
			WHERE DS.SignatureOrder = 1
			) AS DS ON D.DocumentId = DS.DocumentId
		LEFT JOIN
			(SELECT PHYSICALSIGNATURE AS CLIENTSIGNATURE1,DocumentId, SignatureDate AS ClientPrepDate
			FROM DOCUMENTSIGNATURES AA
			where AA.SignatureOrder = 2
			and ISNULL(RecordDeleted,'N') = 'N'
			) AS AA ON D.DocumentId = AA.DocumentId
		----LEFT JOIN DocumentSignatures DS ON D.Documentid = DS.DocumentId
		--LEFT JOIN 
		--	(SELECT SIGNERNAME AS Guardian, DocumentId, PhysicalSignature,ModifiedDate,SignatureDate as GuardianSignature
		--	FROM DocumentSignatures DS
		--	WHERE DS.RelationToClient in(25037,6781)
		--	) AS AA ON D.DocumentId = AA.DocumentId
 		LEFT JOIN STAFF S ON D.AuthorId = S.Staffid
 		JOIN Clients C ON D.ClientId = C.ClientId
 		-- adding new join
 		--LEFT JOIN GLOBALCODES GCD1 ON SFS.AreYouEmployed = GCD1.GlobalCodeId
 		--LEFT JOIN GLOBALCODES GCS1 ON SFS.IfYes = GCS1.GlobalCodeId
 		--LEFT JOIN GLOBALCODES GCS2 ON SFS.IfNo = GCS2.GlobalCodeId
 		WHERE SFS.DocumentVersionId = @DocumentVersionId

		--Logic that will allow the document to refresh when co-signed.
		
		--NOt sure this block is needed.
		--insert into DocumentPDFGenerationQueue (CreatedBy, CreatedDate, DocumentVersionId)
		--values ('CCBHCSlidingFeeA', getdate(),@DocumentVersionId)
		--exec ssp_processPDF
		
		
 

 END TRY  
   
 BEGIN CATCH  
 	DECLARE @Error VARCHAR(8000)  
 
 	SET @Error = CONVERT(VARCHAR, ERROR_NUMBER()) + '*****' + CONVERT(VARCHAR(4000), ERROR_MESSAGE()) + '*****' + ISNULL(CONVERT(VARCHAR, ERROR_PROCEDURE()), 'ksp_dfa_CCBHCSlidingFeeDFA') + '*****' + CONVERT(VARCHAR, ERROR_LINE()) + '*****' + CONVERT(VARCHAR, ERROR_SEVERITY()) + '*****' + CONVERT(VARCHAR, ERROR_STATE())  
 
 	RAISERROR (  
 		@Error,-- Message text.                                                                       
 		16,-- Severity.                                                              
 		1 -- State.                                                           
 	);  
 END CATCH  
 END
 
GO


