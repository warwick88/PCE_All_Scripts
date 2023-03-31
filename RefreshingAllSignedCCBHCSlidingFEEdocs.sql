	select * from documentsignatures
	where documentid=25384620

	select * from documents
	where documentid in (25384620)

	select * into #Fix1 from documents
	where documentcodeid=60111

	select * from #Fix1

	select * into #docV1 From Documentversions
	where documentid in (select documentid from #Fix1)

	select * from #docV1

	select * from documentversions
	where documentversionid = 8913094

			insert into DocumentPDFGenerationQueue (CreatedBy, CreatedDate, DocumentVersionId)
		values ('CCBHCSlidingFeeA', getdate(),8913094)
		exec ssp_processPDF

		insert into DocumentPDFGenerationQueue (CreatedBy, CreatedDate, DocumentVersionId)
		values ('CCBHCSlidingFeeA', getdate(),(select DocumentVersionId from #docV1))
		exec ssp_processPDF

		select * from DocumentPDFGenerationQueue
		order by createddate desc

begin tran
insert into DocumentPDFGenerationQueue (CreatedBy, CreatedDate, DocumentVersionId)
select 
	'CCBHCSlidingFeeA'
	,getdate()
	,DocumentVersionId
	from #docV1
commit tran
 

 begin tran
insert into Messages
(CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,FromStaffId,ToStaffId,ClientId,Unread,DateReceived,Subject,Message)
select 'AutoGuardianChg'
	,getdate()
	,'AutoGuardianChg'
	,getdate()
	,33964 --This is a new staff member for this purpose
	,PrimaryClinicianId
	,ClientId
	,'Y'
	,getdate()
	,'Client Turning 18: Removing Guardianship'
	,'Your Client turned 18, all Guardianship was removed. You will need to review their current guardianship information as soon as possible.'
	from #Temp5

commit tran


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


