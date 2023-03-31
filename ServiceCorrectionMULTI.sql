USE ProdSmartCare

select DV.documentversionid Into #Temp1 
FROM DocumentVersions DV
JOIN Documents D ON DV.DocumentId = D.DocumentId
JOIN Services S on D.ServiceId = S.ServiceId
WHERE S.ServiceId in (1251583, 1252475, 1255037, 1255087, 1255207, 1255933, 1251203, 1254925, 1258249, 1202449, 1251567, 1241995, 1251966, 1255018, 1261505)



--Important, this is how we target all our DocumentVersions at Once instead of 1 by 1.
select 
	'Wbarlow' AS CreatedBy,
	getdate() AS CreatedDate,
	DocumentVersionId AS DocumentVersionId INTO #TEMP2
FROM
	#TEMP1

	
--Final step, this inserts all the versions to fix.
insert into DocumentPDFGenerationQueue (CreatedBy, CreatedDate, DocumentVersionId)
select #TEMP2.CreatedBy,#TEMP2.CreatedDate,#TEMP2.DocumentVersionId FROM #TEMP2



exec ssp_processPDF
drop table #Temp1
drop table #TEMP2