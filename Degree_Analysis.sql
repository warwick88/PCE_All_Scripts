use IsKzooSmartCareQA



select * from ProcedureRates 
where ProcedureCodeId=450
order by ModifiedDate desc

select * from ProcedureRateDegrees PRD
LEFT JOIN GLOBALCODES GC ON PRD.Degree = GC.GlobalCodeId
where ProcedureRateId in (3184)

select * from GlobalCodes
where GlobalCodeId=78127
