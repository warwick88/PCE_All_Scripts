		select * from ARLedger
		where ChargeId in (952649)
		order by PostedDate desc

		select * from CoveragePlans
		where CoveragePlanId=49

		select * into #Service1 from services
		where serviceid=1153134

		select * into #charge1 from Charges 
		where serviceid in (select serviceid from #Service1)

		select * into #ledger from arledger
		where chargeid in (select chargeid from #charge1)

		select * from #Service1
		
		select * from #charge1
		
		select * from #ledger


		--WE WANT CLIENT COVERAGE PLAN HERE BAZINGA
		select * from charges
		where chargeid in (958378,952649,958378,952649)


		--so this is where we get the cov plan the charges are moving between.
		SELECT * FROM ClientCoveragePlans
		where ClientCoveragePlanId in (223811,
300936)

select * from coverageplans
where coverageplanid in (
49,399)