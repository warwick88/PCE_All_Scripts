USE ProdSmartCare


--so this is the table we want
select top 100* from StaffPermissionExceptions
order by createddate desc




select * from StaffPermissionExceptions
where Allow='N'
order by createddate desc

--So we start off with a base of 315 denials.
select * from StaffPermissionExceptions
where Allow='N'
--AND ISNULL(RECORDDELETED,'N')='N'
order by createddate desc


--So we joined staff b/c we don't care if they are no longer active we arn't going to implement
select SPE.*,S.ACTIVE from StaffPermissionExceptions SPE
LEFT JOIN STAFF S ON SPE.StaffId = S.StaffId
where SPE.Allow='N'
AND ISNULL(SPE.RECORDDELETED,'N')='N'
order by SPE.createddate desc

SELECT * FROM STAFF
WHERE STAFFID=31013

--Let's now remove those innactive staff
select SPE.*,S.ACTIVE,S.LastVisit from StaffPermissionExceptions SPE
LEFT JOIN STAFF S ON SPE.StaffId = S.StaffId
where SPE.Allow='N'
AND ISNULL(SPE.RECORDDELETED,'N')='N'
order by SPE.createddate desc



select SPE.*,S.ACTIVE,S.LastVisit from StaffPermissionExceptions SPE
LEFT JOIN STAFF S ON SPE.StaffId = S.StaffId
where SPE.Allow='N'
AND ISNULL(SPE.RECORDDELETED,'N')='N'
--AND S.LastVisit <= '2022-01-01'
order by SPE.createddate desc

select SPE.*,S.FirstName,S.LastName,S.ACTIVE,S.LastVisit from StaffPermissionExceptions SPE
LEFT JOIN STAFF S ON SPE.StaffId = S.StaffId
where SPE.Allow='N'
AND ISNULL(SPE.RECORDDELETED,'N')='N'
--AND S.ACTIVE='Y'
--AND S.LastVisit <= '2022-01-01'
order by SPE.createddate desc


use Prodsmartcare					

--I start by wiping out ALL overrides for a staff member so I don't have to deal with issues

DELETE FROM StaffPermissionExceptions
WHERE STAFFID=

--Step 1 is making a table to insert. ADd your clients here (use Concecate in excel to combine (+ID+)+,   <--Fastest solution
create table #ClientsData(RowNumber smallint, ClientID int)					
insert into #ClientsData(ClientID)					
values					
					
					
(	6430	),			
(	8164	),			
(	2719	),			
(	2483	),			
(	65735	),			
(	2115	),			
(	1501	),			
(	124359	)			

--Step 2:Make sure you adjust dates for StartDate/Enddate
update #ClientsData set RowNumber = 1

Select 1 as RowNumber, StaffId, 5741 as PermissionTemplateType, 'Y' as Allow,'02/13/2019' as StartDate, '03/13/2019' as EndDate
into #RepData --(RowNumber, staffid, permissiontemplatetype, allow, startdate, enddate)
from Staff where UserCode like 'AStrasserSWMBH'   "<--Put your auditor username here"

--Step 3: Just joining tables.
Select distinct RD.staffid, RD.permissiontemplatetype, CD.ClientID as permissionitemid, RD.allow, RD.startdate, RD.enddate
into #JoinData
from #RepData RD join #ClientsData CD on RD.RowNumber=CD.RowNumber

insert into StaffPermissionExceptions (staffid, permissiontemplatetype, permissionitemid, allow, startdate, enddate)
select * from #JoinData 