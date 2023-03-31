use IsKzooSmartCareQA


Update claimlinecredits set amount= 62.85,modifiedby='KCMHSASH#2004',ModifiedDate=GETDATE() where claimlineid=9179084 and claimlinecreditid =129285 and checkid=17873
Update claimlines set PayableAmount= 0, PaidAmount=0,ModifiedBy='KCMHSASH#2004',ModifiedDate=GETDATE() where claimlineid=9179084

--amount was 62.85
select * from claimlinecredits
where claimlineid=9179084 and claimlinecreditid =129285 and checkid=17873


--payable was -28.84 and paid amount was 28.84
select PayableAmount,PaidAmount from ClaimLines
where claimlineid=9179084