USE ProdSmartCare
 
 /*Purpose: Add the credit for the claimline if full credit is missing in the Check. 
 Assign corresponding values to @ClaimLineId,@CheckId,@Amount*/
 
 
 DECLARE @ClaimLineId int = 9020389		/*set value to this variable with ClaimLIneId that has missing credit*/
 DECLARE @CheckId int= 17959				/*set value to this variable with the corresponding checkid from Checks table*/
 DECLARE @Amount money = 12.50			/*set value to this variable with  Amount to credit*/
 
BEGIN TRY
	BEGIN TRAN;

	DECLARE @CLaimLineCreditId int;
	DECLARE @createdby varchar(50);
	DECLARE @createddate datetime;
	DECLARE @ActivityStaffId int;

	SELECT @createdby= createdby,@createddate= createddate FROM checks WHERE checkid= @CheckId
	SELECT @ActivityStaffId=staffid FROM staff WHERE usercode=@createdby

/*The table ClaimLineCredits holds the credit amount of particular claimline of the check. In this scenario, the full credit was missing in the check, so the entry has to be inserted to ClaimLineCredits table*/

	INSERT INTO ClaimLineCredits (
	  ClaimLineId,
	  CheckId,
	  Amount,
	  CreatedBy,
	  CreatedDate,
	  ModifiedBy,
	  ModifiedDate
	)
	VALUES (@ClaimLineId, @CheckId, @Amount, @createdby, @createddate, @createdby, @createddate);

	SET @CLaimLineCreditId = scope_identity();

/*After inserting missing credit to ClaimLineCredits, corresponding entry has to be added in ClaimLineHistory. This will show the entry in ClaimLine details
*/
	INSERT INTO ClaimLineHistory (
	  ClaimLineId,
	  Activity,
	  ActivityDate,
	  Status,
	  ActivityStaffId,
	  ClaimLineCreditId,
	  CreatedBy,
	  CreatedDate,
	  ModifiedBy,
	  ModifiedDate
	)
	VALUES (@ClaimLineId, 2005, @createddate, 2026, @ActivityStaffId, @CLaimLineCreditId, @createdby, @createddate, @createdby, @createddate);

/*Claimlines PaidAmount and PayableAmount should be updated*/
	UPDATE ClaimLines
	SET    PaidAmount = PaidAmount - @Amount,
		   PayableAmount = PayableAmount + @Amount
	WHERE  ClaimLIneId = @ClaimLineId;

	COMMIT TRAN;
	
END TRY                                        
                                                                                                       
BEGIN CATCH   
	IF(@@error <> 0)
		BEGIN  
		  ROLLBACK TRAN  		   
		END  
  
DECLARE @Error varchar(8000)                                                                 
SET @Error= Convert(varchar,ERROR_NUMBER()) + '*****' + Convert(varchar(4000),ERROR_MESSAGE())                                                           
    + '*****' + isnull(Convert(varchar,ERROR_PROCEDURE()),'Error while executing the script:')                                                                                               
    + '*****' + Convert(varchar,ERROR_LINE()) + '*****' + Convert(varchar,ERROR_SEVERITY())                                                                                                
    + '*****' + Convert(varchar,ERROR_STATE())                                            
 RAISERROR                                                                                               
 (                                                                 
  @Error, -- Message text.                                                                                              
  16, -- Severity.                                                                                              
  1 -- State.                                                                                              
 );                                                                                 
END CATCH	

