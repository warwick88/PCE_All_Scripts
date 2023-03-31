USE DATAKZO_ISK_Supplemental


/*
	we identified the pp who had received payment, but PAYOR and originla name do not match so they get stuck
	case number and date of service. need to be added in join
*/

select PRIINS.ic_name, ADJINS.IC_NAME, 
ch_clmno, cd_lineno, cd_proccd, sum(ca_payamt)
from edierrpf 
join pchsalpf on erf_salid = sa_Rcdid and sa_bilsts = 'Y' --Joined to the sal and checking did this get billed to a 3rd party? Y
join edicldpf on saf_cldbid = cd_rcdid --Claim detail
join ediclmpf on cdf_clmid = ch_rcdid --claim header
join pchinspf PRIINS on chf_insid = PRIINS.ic_rcdid --Primary payor it's saved on within this table. Matching with payment.
left join ediclapf on caf_cldid = cd_rcdid --tied to adjustments
left join pchinspf ADJINS on caf_insid = ADJINS.ic_rcdid --joining back to the insurance, pointer from adjustmetn to check payor.
where erf_batid = 110    and er_code = 'PRIINS' 
group by PRIINS.ic_name, ADJINS.IC_NAME, 
ch_clmno, cd_lineno, cd_proccd
having sum(ca_payamt) is not null


/*
	Here Mark states the CH_ADDDATE is when claim is generated, so this lists represents encounters
	we have not received payment on. The ones that are a bit older say 10-10/31 are a bit more problematic
	because this is a while for us not to receive payments.
*/
select PRIINS.ic_name, ADJINS.IC_NAME, cl_caseno, 
CH_ADDDATE,ch_clmno, cd_frmdt, cd_lineno, cd_proccd, cd_mod, cd_mod2, sum(ca_payamt)
from edierrpf 
join pchsalpf on erf_salid = sa_Rcdid and sa_bilsts = 'Y'
join pchcltpf on saf_cltid = cl_rcdid
join edicldpf on saf_cldbid = cd_rcdid
join ediclmpf on cdf_clmid = ch_rcdid
join pchinspf PRIINS on chf_insid = PRIINS.ic_rcdid
left join ediclapf on caf_cldid = cd_rcdid
left join pchinspf ADJINS on caf_insid = ADJINS.ic_rcdid
where erf_batid = 110    and er_code = 'PRIINS' 
group by PRIINS.ic_name, ADJINS.IC_NAME, cl_caseno, CH_ADDDATE,
ch_clmno, cd_frmdt, cd_lineno, cd_proccd, cd_mod, cd_mod2
having sum(ca_payamt) is null --This means did NOT received a payment  This is a big one because we can see 
--1507 erors right now are due to third party payment not being received. So essentially where is our payment for these?


--You can join this back to the encounter and see more info.



select PRIINS.ic_name, ADJINS.IC_NAME, cl_caseno, 
CH_ADDDATE,ch_clmno, cd_frmdt, cd_lineno, cd_proccd, cd_mod, cd_mod2, sum(ca_payamt)
from edierrpf 
join pchsalpf on erf_salid = sa_Rcdid and sa_bilsts = 'Y'
join pchcltpf on saf_cltid = cl_rcdid
join edicldpf on saf_cldbid = cd_rcdid
join ediclmpf on cdf_clmid = ch_rcdid
join pchinspf PRIINS on chf_insid = PRIINS.ic_rcdid
left join ediclapf on caf_cldid = cd_rcdid
left join pchinspf ADJINS on caf_insid = ADJINS.ic_rcdid
where erf_batid = 110    and er_code = 'PRIINS' 
group by PRIINS.ic_name, ADJINS.IC_NAME, cl_caseno, CH_ADDDATE,
ch_clmno, cd_frmdt, cd_lineno, cd_proccd, cd_mod, cd_mod2
having sum(ca_payamt) is not null --We DID receive payment