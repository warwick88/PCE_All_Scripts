USE ProdSmartCare



--625 users
select S.*
	,SR1.RoleId AS 'AdministratorROLE'
	,SR2.RoleId AS 'MCO_External_Provider_Claim_Entry'
	,SR3.RoleId AS 'MCO_External_Provider_View_MCO_Info'
	,SR4.RoleId AS 'Access_Staff_Crisis_Worker'
	,SR5.RoleId AS 'External_Full_EMR_Clinician'
	,SR6.RoleId AS 'MCO_Institutional_Claims_Provider'
	,SR7.RoleId AS 'Finance_Reimbur_Billing'
	,SR8.RoleId AS 'Finance_Claims_Analyst'
	--,SR9.RoleId AS 'Psychiatrist' 
	--,SR10.RoleId AS 'Nurse' 
	,SR11.RoleId AS 'Admin_Uber_User' 
	,SR12.RoleId AS 'Mobile_crisis_Emergency_Services_Clinician' INTO #TEST1 from Staff S
LEFT JOIN StaffRoles SR1 on S.Staffid = SR1.Staffid and SR1.RoleId=50104 
LEFT JOIN StaffRoles SR2 on S.Staffid = SR2.Staffid and SR2.RoleId=73510 
LEFT JOIN StaffRoles SR3 on S.Staffid = SR3.Staffid and SR3.RoleId=73511 
LEFT JOIN StaffRoles SR4 on S.Staffid = SR4.Staffid and SR4.RoleId=73925 
LEFT JOIN StaffRoles SR5 on S.Staffid = SR5.Staffid and SR5.RoleId=75852
LEFT JOIN StaffRoles SR6 on S.Staffid = SR6.Staffid and SR6.RoleId=77783
LEFT JOIN StaffRoles SR7 on S.Staffid = SR7.Staffid and SR7.RoleId=25251
LEFT JOIN StaffRoles SR8 on S.Staffid = SR8.Staffid and SR8.RoleId=25252
LEFT JOIN StaffRoles SR9 on S.Staffid = SR9.Staffid and SR9.RoleId=24536
LEFT JOIN StaffRoles SR10 on S.Staffid = SR10.Staffid and SR10.RoleId=24537
LEFT JOIN StaffRoles SR11 on S.Staffid = SR11.Staffid and SR11.RoleId=24532
LEFT JOIN StaffRoles SR12 on S.Staffid = SR12.Staffid and SR12.RoleId=24539
where S.Active='Y'
and ISNULL(S.RECORDDELETED,'N')='N'
AND S.Lastvisit >= '2022-01-01'



drop table #TEST1
drop table #FINAL1
/*
	First we need to cut this down a little 474 roles, some duplicates. So if ALL rows are null
	then we don't need the user to stay on this list. We are whittling down to who is kept

*/

--474
SELECT * FROM #TEST1
---------------------------------
SELECT * INTO #FINAL1  FROM #TEST1 
WHERE ADMINISTRATORROLE IS NOT NULL

SELECT * INTO #FINAL2  FROM #TEST1 
WHERE MCO_External_Provider_Claim_Entry IS NOT NULL

SELECT * INTO #FINAL3  FROM #TEST1 
WHERE MCO_External_Provider_View_MCO_Info IS NOT NULL

SELECT * INTO #FINAL4  FROM #TEST1 
WHERE Access_Staff_Crisis_Worker IS NOT NULL

SELECT * INTO #FINAL5  FROM #TEST1 
WHERE External_Full_EMR_Clinician IS NOT NULL

SELECT * INTO #FINAL6  FROM #TEST1 
WHERE MCO_Institutional_Claims_Provider IS NOT NULL

SELECT * INTO #FINAL7  FROM #TEST1 
WHERE Finance_Reimbur_Billing IS NOT NULL

SELECT * INTO #FINAL8  FROM #TEST1 
WHERE Finance_Claims_Analyst IS NOT NULL

SELECT * INTO #FINAL11  FROM #TEST1 
WHERE Admin_Uber_User IS NOT NULL

SELECT * INTO #FINAL12  FROM #TEST1 
WHERE Mobile_crisis_Emergency_Services_Clinician IS NOT NULL

drop table #FINAL1
drop table #FINAL2
drop table #FINAL3 
drop table #FINAL4 
drop table #FINAL5
drop table #FINAL6 
drop table #FINAL9
drop table #FINAL10
drop table #FINAL11 
drop table #FINAL12

------------------------------------------

SELECT * FROM #FINAL1
SELECT * FROM #FINAL2
SELECT * FROM #FINAL3
SELECT * FROM #FINAL4
SELECT * FROM #FINAL5
SELECT * FROM #FINAL6
SELECT * FROM #FINAL7
SELECT * FROM #FINAL8
SELECT * FROM #FINAL11
SELECT distinct(staffid) FROM #FINAL12




/*
	The time has come! We are done cleaning, let's union are odd way of collecting data
	Man a CTE would have been far smarter.
	--295 is the count!
*/
SELECT STAFFID,USERCODE,LastName,FirstName,Active into #COUNTDOWN FROM #FINAL1
union
SELECT STAFFID,USERCODE,LastName,FirstName,Active FROM #FINAL2
union
SELECT STAFFID,USERCODE,LastName,FirstName,Active FROM #FINAL3
union
SELECT STAFFID,USERCODE,LastName,FirstName,Active FROM #FINAL4
union
SELECT STAFFID,USERCODE,LastName,FirstName,Active FROM #FINAL5
union
SELECT STAFFID,USERCODE,LastName,FirstName,Active FROM #FINAL6
union
SELECT STAFFID,USERCODE,LastName,FirstName,Active FROM #FINAL7
union
SELECT STAFFID,USERCODE,LastName,FirstName,Active FROM #FINAL8
union
SELECT STAFFID,USERCODE,LastName,FirstName,Active FROM #FINAL11
union
SELECT STAFFID,USERCODE,LastName,FirstName,Active FROM #FINAL12

select * from staff
where UserCode like 'TMyers%'

--Select specified users to keep active
select StaffId,USERCODE,LastName,FirstName,Active into #tempadditions FROM Staff
where staffid in (1112,1113,23,682,1912,12,31013,682,39047,39043,39826,1831,894,30994,920,25481,39083,39045,26277,39069,25911,38949,39035)



--400 still active users.
SELECT STAFFID,USERCODE,LastName,FirstName,Active INTO #FinalDataSet FROM #COUNTDOWN
UNION 
SELECT STAFFID,USERCODE,LastName,FirstName,Active FROM #tempadditions


--YOUR FINAL SELECT
SELECT * FROM #FinalDataSet

select * into #BlockList from staff S
where staffid not in (select staffid from #FinalDataSet)
and S.Active='Y'
and ISNULL(S.RECORDDELETED,'N')='N'
AND S.Lastvisit >= '2022-01-01'

select Staffid,Firstname,lastname,active from #BlockList

--220 USERS Blocked.
BEGIN TRAN
UPDATE Staff
SET ACTIVE='N'
WHERE STAFFID IN (SELECT STAFFID FROM #BLOCKLIST)
COMMIT TRAN






DROP TABLE #tempadditions






