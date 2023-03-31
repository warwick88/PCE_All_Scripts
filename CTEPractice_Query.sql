


;
with CTEService as 
( select 
	serviceid
	,DateOfService
	,clientid
	ProgramId
	,CASE 
		WHEN DateOfService > '10-20-2021' THEN 'EndMonth'
		WHEN DateOfService > '10-10-2021' THEN 'MidMonth'
		WHEN DateOfService > '10-01-2021' THEN 'Early Month'
		else 'whateverman'
	END AS Description
	from Services
	where DateOfService >= '10-01-2021'
	and DateOfService < '11-01-2021'
	)
	select * from CTEService
