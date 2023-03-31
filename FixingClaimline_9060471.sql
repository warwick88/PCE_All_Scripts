use ProdSmartCare

select * from claimlinecredits
where claimlineid=9060471  and checkid=17959

begin tran
Update claimlinecredits set amount= 25.76,modifiedby='KCMHSASH#2004',ModifiedDate=GETDATE()
where claimlineid=9060471 and claimlinecreditid =130369 and checkid=17959
commit tran


--so this was payable amount=-16.42 paidamount=200.66
Update claimlines set PayableAmount= 0, PaidAmount=0,ModifiedBy='KCMHSASH#2004',ModifiedDate=GETDATE() where claimlineid=9060471
--so this was payable amount=-16.42 paidamount=200.66
select * from claimlines
where claimlineid=9060471

select * from claimlines
where claimlineid=9060471