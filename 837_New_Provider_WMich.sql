use ProdSmartCare


/*
	Ok - so first you need to check. Does my provider Import837 files? If they arent in the query below
	...they dont. If they ARE going to then insert them into this table as a first step.
*/
SELECT * FROM Import837Senders
ORDER BY CREATEDDATE DESC


--Ok so here I inserted the Provider into import837Senders. Now when this is done you can move to 2nd step.
insert into Import837Senders (CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,SenderName,SenderId,Active)
VALUES ('Wbarlow',getdate(),'Wbarlow',getdate(),'Northern Lakes CMH Authority',1669572657,'Y')

--2nd Step
--We need to insert the new provider submitting 837's into the Import837SenderProviders
--This table says what providers/sites can do.
--You do need the ID from the first column in previous insert. IN this example it's 42.

select top 5 * from Import837SenderProviders
order by createddate desc


--Ok so finally inserted the provider into the table saying this provider/site can submit 837s
insert into Import837SenderProviders (Import837SenderId,ProviderId,SiteId,Active,CreatedBy,CreatedDate,
ModifiedBy,ModifiedDate)
VALUES (42,207,1386,'Y','Wbarlow',getdate(),'Wbarlow',getdate())

BEGIN TRAN
update Import837SenderProviders
SET SiteId=190
where import837senderproviderid=130
COMMIT TRAN

select * from Staff837Senders
order by createddate desc


--The two staff we want here are 30248 & 29867
insert into Staff837Senders (CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,StaffId,Import837SenderId)
VALUES ('Wbarlow',getdate(),'Wbarlow',getdate(),29867,42)

insert into Staff837Senders (CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,StaffId,Import837SenderId)
VALUES ('Wbarlow',getdate(),'Wbarlow',getdate(),30248,42)




--so they don't exist in this table yet...that's a problem that means they have NEVER submitted 837's
select * from Import837SenderProviders
where ProviderId=207


--More Importantly need to be in this table as well. This says you import837 files essentially.
--Here the senderID is their NPI
SELECT * FROM Import837Senders
ORDER BY CREATEDDATE DESC

--
--This portion may already be done because the provider already exists
INSERT INTO [dbo].[Import837Senders]
([SenderName],[SenderId],[Active],[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate],[RecordDeleted],
[DeletedDate],[DeletedBy])
VALUES ('Centria Healthcare','1053641498','Y','ACollins',
GetDate(),'ACollins',GetDate(),NULL,NULL,NULL)


INSERT INTO [dbo].[Import837SenderProviders]
([Import837SenderId],[ProviderId],[SiteId],[Active],[CreatedBy],[CreatedDate],[ModifiedBy],[ModifiedDate],
[RecordDeleted],[DeletedDate],[DeletedBy])
VALUES (8,136,1397,'Y','Wbarlow',GetDate(),'Wbarlow',GetDate(),NULL,NULL,NULL)


Here there was a new site "1397" I queried 

SELECT TOP 100* FROM Import837Senders
where sendername like '%COMMUNITY LIVING%'

That got me the "Import837SenderId"
