USE datakzo

/*
	It shows you here in the crosswalk. That you connect KZOXSPPF to PCHXSPPF on XP_RCDID from XPP_XSPID.

	Initial analysis was confusing, because you start with KZO table. It's just the ID's. You then link that to the PCE data
	Analysis of PCHXSPPF which is the actual crosswalk does include "RequiresStaffNPI" which is our notice that Rendering is required.
*/
SELECT * FROM KZOXSPPF KZ
LEFT JOIN PCHXSPPF PCE ON KZ.XPP_XSPID = PCE.XP_RCDID
WHERE PCE.XP_CWRQSTF LIKE 'Y'

SELECT PCE.XP_CWRQSTF,XPF_CPTID FROM KZOXSPPF KZ
LEFT JOIN PCHXSPPF PCE ON KZ.XPP_XSPID = PCE.XP_RCDID

SELECT * FROM KZOXSPPF KZ
LEFT JOIN PCHXSPPF PCE ON KZ.XPP_XSPID = PCE.XP_RCDID
--LEFT JOIN PCHCPTPF CODES ON KZ.XPP_XSPID = CODES.CR_RCDID
WHERE XPP_XSPID = 11906

--So where in the FUCK is this ACTUAL CPT name.

SELECT PCE.XPF_CPTID FROM KZOXSPPF KZ
LEFT JOIN PCHXSPPF PCE ON KZ.XPP_XSPID = PCE.XP_RCDID
--LEFT JOIN PCHCPTPF CODES ON KZ.XPP_XSPID = CODES.CR_RCDID
WHERE XPP_XSPID = 11906

SELECT * FROM PCHXSPPF
WHERE XPF_CPTID=18107

/*
	Looks like you can can join this to the below table on XPF_CPTID
*/
SELECT * FROM PCHCPTPF
WHERE CR_CODE LIKE '%H0032%'


/*
	So this system is a little Wack. Hard to figure out. Joined to PCHCPTPF which houses the ACTUAL Names of revenue codes...
	NOW you need to filter the following
*/
SELECT * FROM KZOXSPPF KZ
LEFT JOIN PCHXSPPF PCE ON KZ.XPP_XSPID = PCE.XP_RCDID
LEFT JOIN PCHCPTPF P1 ON PCE.XPF_CPTID = CR_RCDID
WHERE XPP_XSPID = 11906

/*
	Codes where rendering is required are marked as a 'Y'
	You are going to want to spot check these.
*/
SELECT * FROM KZOXSPPF KZ
LEFT JOIN PCHXSPPF PCE ON KZ.XPP_XSPID = PCE.XP_RCDID
LEFT JOIN PCHCPTPF P1 ON PCE.XPF_CPTID = CR_RCDID
WHERE PCE.XP_CWRQSTF LIKE 'Y'

/*
	Let's filter out some columns.
*/
SELECT * FROM KZOXSPPF KZ
LEFT JOIN PCHXSPPF PCE ON KZ.XPP_XSPID = PCE.XP_RCDID
LEFT JOIN PCHCPTPF P1 ON PCE.XPF_CPTID = CR_RCDID
WHERE PCE.XP_CWRQSTF LIKE 'Y'