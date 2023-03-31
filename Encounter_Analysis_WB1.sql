use datakzo

--SAL ENCOUNTERS: Being Xfered to the state reside in this table.
select * from PCHSALPF
--two here
--SAF_CLDID --If this is populated, it means it's been reported on an encounter to the PHIP on a finalized edit batch.
--SAF_CLDBID --It's a pointer to a 3rd party. So if it's billing 3rd party it is populated.  <--We are looking for this to be populated 




--So now we are going to contracted out so CLAIMS

--CLAIMS!
select * from EDICLDPF
WHERE CDF_CLMID=75728
AND CD_STATUS='V'
order by CD_FRMDT ASC
--CDF_CLDID this is the encounter pointer
--For Details go one above to FK CDF_CLDBID

select * from EDICLDPF
WHERE CD_STATUS='V'

select * from EDICLDPF
WHERE CDF_CLMID IN (41326,75728,75620,55067,75618,75616,39086,64096,75614,39329)


SELECT * FROM EDICLMPF
--COLUMN CH_CLMTYP will give you tye claim type
--HA provider HCFA-1500