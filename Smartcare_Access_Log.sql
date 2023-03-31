USE ProdSmartCare

SELECT * FROM AUTHORIZATIONCODES
ORDER BY CREATEDDATE DESC

--449 USERS
select * from Staff S
where S.Active='Y'
and S.PasswordExpirationDate > '2021-10-01'

--447 Users
select * from Staff S
where S.Active='Y'
and S.PasswordExpirationDate > '2021-10-01'
and ISNULL(S.RECORDDELETED,'N')='N'

--Now 440 Users.
select * from Staff S
where S.Active='Y'
and S.PasswordExpirationDate > '2021-10-01'
and ISNULL(S.RECORDDELETED,'N')='N'
AND Lastvisit >= '2022-01-01'

select * from staffroles
where staffid=31013
AND ISNULL(RECORDDELETED,'Y')='Y'

select * from globalcodes
where globalcodeid in (
4012,
25256,
24532,
25667,
73406)

select * from staffroles
where staffid=31013
AND ISNULL(RECORDDELETED,'N')='N'

/*
	Roles that actually matter
	1.50104 Administrator
	2.

*/

select Globalcodeid,Category,CodeName from globalcodes
where globalcodeid in (
50104,
73510,
73511,
73925,
75852,
77783,
75244,
4001,
24536,
24537,
24532,
24539
)
--440 USERS
select S.*,SR1.RoleId from Staff S
LEFT JOIN StaffRoles SR1 on S.Staffid = SR1.Staffid and SR1.RoleId=50104 
where S.Active='Y'
and S.PasswordExpirationDate > '2021-10-01'
and ISNULL(S.RECORDDELETED,'N')='N'
AND S.Lastvisit >= '2022-01-01'

select S.*
	,SR1.RoleId
	,SR2.RoleId
	,SR3.RoleId
	,SR4.RoleId
	,SR5.RoleId
	,SR6.RoleId
	,SR7.RoleId
	,SR8.RoleId
	,SR9.RoleId
	,SR10.RoleId
	,SR11.RoleId
	,SR12.RoleId from Staff S
LEFT JOIN StaffRoles SR1 on S.Staffid = SR1.Staffid and SR1.RoleId=50104 
LEFT JOIN StaffRoles SR2 on S.Staffid = SR2.Staffid and SR2.RoleId=73510 
LEFT JOIN StaffRoles SR3 on S.Staffid = SR3.Staffid and SR3.RoleId=73511 
LEFT JOIN StaffRoles SR4 on S.Staffid = SR4.Staffid and SR4.RoleId=73925 
LEFT JOIN StaffRoles SR5 on S.Staffid = SR5.Staffid and SR5.RoleId=75852 
LEFT JOIN StaffRoles SR6 on S.Staffid = SR6.Staffid and SR6.RoleId=77783 
LEFT JOIN StaffRoles SR7 on S.Staffid = SR7.Staffid and SR7.RoleId=75244 
LEFT JOIN StaffRoles SR8 on S.Staffid = SR8.Staffid and SR8.RoleId=4001 
LEFT JOIN StaffRoles SR9 on S.Staffid = SR9.Staffid and SR9.RoleId=24536  
LEFT JOIN StaffRoles SR10 on S.Staffid = SR10.Staffid and SR10.RoleId=24537 
LEFT JOIN StaffRoles SR11 on S.Staffid = SR11.Staffid and SR11.RoleId=24532 
LEFT JOIN StaffRoles SR12 on S.Staffid = SR12.Staffid and SR12.RoleId=24539
where S.Active='Y'
and S.PasswordExpirationDate > '2021-10-01'
and ISNULL(S.RECORDDELETED,'N')='N'
AND S.Lastvisit >= '2022-01-01'

select S.*
	,SR1.RoleId AS 'Administrator'
	,SR2.RoleId AS 'MCO External Provider Claim Entry'
	,SR3.RoleId AS 'MCO External Provider View MCO Info'
	,SR4.RoleId AS 'Access Staff/Crisis Worker'
	,SR5.RoleId AS 'External Full EMR Clinician'
	,SR6.RoleId AS 'MCO Institutional Claims Provider'
	,SR7.RoleId AS 'Admin Super User'
	,SR8.RoleId AS 'Access  Center' 
	,SR9.RoleId AS 'Psychiatrist' 
	,SR10.RoleId AS 'Nurse' 
	,SR11.RoleId AS 'Admin Uber User' 
	,SR12.RoleId AS 'Mobile crisis/ Emergency Services Clinician' from Staff S
LEFT JOIN StaffRoles SR1 on S.Staffid = SR1.Staffid and SR1.RoleId=50104 
LEFT JOIN StaffRoles SR2 on S.Staffid = SR2.Staffid and SR2.RoleId=73510 
LEFT JOIN StaffRoles SR3 on S.Staffid = SR3.Staffid and SR3.RoleId=73511 
LEFT JOIN StaffRoles SR4 on S.Staffid = SR4.Staffid and SR4.RoleId=73925 
LEFT JOIN StaffRoles SR5 on S.Staffid = SR5.Staffid and SR5.RoleId=75852
LEFT JOIN StaffRoles SR6 on S.Staffid = SR6.Staffid and SR6.RoleId=77783
LEFT JOIN StaffRoles SR7 on S.Staffid = SR7.Staffid and SR7.RoleId=75244
LEFT JOIN StaffRoles SR8 on S.Staffid = SR8.Staffid and SR8.RoleId=4001
LEFT JOIN StaffRoles SR9 on S.Staffid = SR9.Staffid and SR9.RoleId=24536
LEFT JOIN StaffRoles SR10 on S.Staffid = SR10.Staffid and SR10.RoleId=24537
LEFT JOIN StaffRoles SR11 on S.Staffid = SR11.Staffid and SR11.RoleId=24532
LEFT JOIN StaffRoles SR12 on S.Staffid = SR12.Staffid and SR12.RoleId=24539
where S.Active='Y'
and S.PasswordExpirationDate > '2021-10-01'
and ISNULL(S.RECORDDELETED,'N')='N'
AND S.Lastvisit >= '2022-01-01'

select S.*
	,SR1.RoleId AS 'AdministratorROLE'
	,SR2.RoleId AS 'MCO External_Provider_Claim_Entry'
	,SR3.RoleId AS 'MCO External_Provider View MCO Info'
	,SR4.RoleId AS 'Access Staff_Crisis Worker'
	,SR5.RoleId AS 'External_Full_EMR_Clinician'
	,SR6.RoleId AS 'MCO Institutional_Claims_Provider'
	,SR7.RoleId AS 'Admin_Super_User'
	,SR8.RoleId AS 'Access_Center' 
	,SR9.RoleId AS 'Psychiatrist' 
	,SR10.RoleId AS 'Nurse' 
	,SR11.RoleId AS 'Admin_Uber_User' 
	,SR12.RoleId AS 'Mobile_crisis_Emergency_Services_Clinician' INTO #TEST1 from Staff S
LEFT JOIN StaffRoles SR1 on S.Staffid = SR1.Staffid and SR1.RoleId=50104 
LEFT JOIN StaffRoles SR2 on S.Staffid = SR2.Staffid and SR2.RoleId=73510 
LEFT JOIN StaffRoles SR3 on S.Staffid = SR3.Staffid and SR3.RoleId=73511 
LEFT JOIN StaffRoles SR4 on S.Staffid = SR4.Staffid and SR4.RoleId=73925 
LEFT JOIN StaffRoles SR5 on S.Staffid = SR5.Staffid and SR5.RoleId=75852
LEFT JOIN StaffRoles SR6 on S.Staffid = SR6.Staffid and SR6.RoleId=77783
LEFT JOIN StaffRoles SR7 on S.Staffid = SR7.Staffid and SR7.RoleId=75244
LEFT JOIN StaffRoles SR8 on S.Staffid = SR8.Staffid and SR8.RoleId=4001
LEFT JOIN StaffRoles SR9 on S.Staffid = SR9.Staffid and SR9.RoleId=24536
LEFT JOIN StaffRoles SR10 on S.Staffid = SR10.Staffid and SR10.RoleId=24537
LEFT JOIN StaffRoles SR11 on S.Staffid = SR11.Staffid and SR11.RoleId=24532
LEFT JOIN StaffRoles SR12 on S.Staffid = SR12.Staffid and SR12.RoleId=24539
where S.Active='Y'
and S.PasswordExpirationDate > '2021-10-01'
and ISNULL(S.RECORDDELETED,'N')='N'
AND S.Lastvisit >= '2022-01-01'

drop table #TEST1
/*
	First we need to cut this down a little 474 roles, some duplicates. So if ALL rows are null
	then we don't need the user to stay on this list. We are whittling down to who is kept

*/

--474
SELECT * FROM #TEST1

SELECT * INTO #FINAL1  FROM #TEST1 
WHERE ADMINISTRATORROLE IS NOT NULL

SELECT * INTO #FINAL1  FROM #TEST2 
WHERE ADMINISTRATORROLE IS NOT NULL




/*
 Final step will be querying ALL those users from the beginning vs our final temp list. If they exist in the temp list, don't touch otherwise DE-ACTIVATE.
*/

select Globalcodeid,Category,CodeName from globalcodes
where globalcodeid in (
50104,
73510,
73511,
73925,
75852,
77783,
75244,
4001,
24536,
24537,
24532,
24539
)


select * from staffroles
where staffid=31013
AND ISNULL(RECORDDELETED,'N')='N'

LEFT JOIN StaffRoles SR2 on S.Staffid = S.Staffid and SR2.RoleId=73510 
LEFT JOIN StaffRoles SR3 on S.Staffid = S.Staffid and SR3.RoleId=73511 
LEFT JOIN StaffRoles SR4 on S.Staffid = S.Staffid and SR4.RoleId=73925 
LEFT JOIN StaffRoles SR5 on S.Staffid = S.Staffid and SR5.RoleId=75852 
LEFT JOIN StaffRoles SR6 on S.Staffid = S.Staffid and SR6.RoleId=77783 
LEFT JOIN StaffRoles SR7 on S.Staffid = S.Staffid and SR7.RoleId=75244 
LEFT JOIN StaffRoles SR8 on S.Staffid = S.Staffid and SR8.RoleId=4001 
LEFT JOIN StaffRoles SR9 on S.Staffid = S.Staffid and SR9.RoleId=24536  
LEFT JOIN StaffRoles SR10 on S.Staffid = S.Staffid and SR10.RoleId=24537 
LEFT JOIN StaffRoles SR11 on S.Staffid = S.Staffid and SR11.RoleId=24532 
LEFT JOIN StaffRoles SR12 on S.Staffid = S.Staffid and SR12.RoleId=24539