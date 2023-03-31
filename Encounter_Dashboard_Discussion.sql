use datakzo

/*
	Steps prior to when an encounter gets generated:
	Dashboard: look at each rendered service, after rendered what must happen to make an encounter
	
	1.	Two approaches, first is internally provided
	2.	Then also contracted out 
		A. Claim is a source of an encounter
		B. SAL is a source of an encounter

	3. There will be a pointer on a SAL or a claim to an outbound encounter, but there will not be a pointer on the encounter
	to point back to a SAL or Claim.

	Finalize a batch a pointer gets created.

	Starting with SAL's: PCECMH is the SAL table to look at.
						 SAF_CLDID - fkEDIClaimDetailEncoutner this means it's been submitted as an encounter.
							Seeing this is populated before sending an ecounter
							If they have an insurance policy to cover the code.
						 SAF_CLDBID - fkEDIClaimDetailBilling
							If it's got zero payment, then it won't be sent if it's marked waiting for 3rd party payor.

						Look at the detail columns not the general header DETAIL

	Contract out a service or a provider claim:
		EDICLDPF - EDIClaimDetail - Claim Detail File - Claim detail service lines
					CDF_CLDID - fkEDIClaimDetailEncounter pointer to encounter
					CDF_CLDBID - fkEDIClaimDetaliBilling - shows if we have received 3rd party payment

		EDICLMPF: This is a table that will show what type of claim it is : check out column
					CH_CLMTYP - shows if HA provider HCFA-1500
								UA - porivider UB-04
								ha
								HE
								UA
								UE
								These are the 4 we are using. 2 are inbound 2 are outbound.

								CHF_BICID - fkBatchInvoice - will be populated on claims we pay.


		EDIBICPF - One of the columns includes this info, shows when it's paid.
			P = paid / sent to GL
	
		
	
		SA_OKTOUSE - OkToUse - IF this is marked YES or Y then it's ok to use. You can see if it's no then why? Might not be signed.
		SA_STATUS - Check it's null it should be, that's good. If it's not it's probably not going out.

		PCHCONPF - points to a contract
			So sal's point to contract
			CO_NOENC - do not report encounters - N/Y answers here.



*/
