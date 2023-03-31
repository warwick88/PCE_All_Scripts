USE ProdSmartCare

/*
	Balance to show 
	balance should be 215.60
	history should show the 6/1 credit on the check of 215.60

	--so on the header info fix the balance, then on the history you need a new line entry for a credit that shows 215.60
*/
SELECT * FROM CLAIMLINES WHERE CLAIMLINEID=9191216