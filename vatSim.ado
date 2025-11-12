cap program drop vatSim 
program define vatSim
version 16.0
	syntax [, collapse hhid(varname) bDir(varname) dir(varname) bInd(varname) ind(varname) rate(real 0) itemID(varname) infShare(varname) exemptions(varname) purchases(varname) hhweight(varname) dataout(string) restore]
 
 **************************************************************************************
 * Step 5: Calculate VAT 
 **************************************************************************************
if "`restore'" == "restore"{
	preserve	
}
		assert !mi(`ind') & `ind' >= -0.0000001 
		assert !mi(`dir') & `dir' >= -0.0000001

		if "`bInd'" == "" {
			loc bInd `ind'
		}
		if "`bDir'" == ""{	
			loc bDir `dir'
		} 

		sum `bDir' `dir' `bInd' `ind'

		* Back out formal and informal purchases, gross of VAT
		
		g frm_purc = `purchases'*(1-`infShare')
		g frm_ex_purc = `purchases'*(1-`infShare')*`exemptions' 
		g frm_nx_purc = `purchases'*(1-`infShare')*(1-`exemptions')

		g inf_purc = `purchases'*`infShare'
		g inf_ex_purc = `purchases'*(`infShare')*`exemptions' 
		g inf_nx_purc = `purchases'*(`infShare')*(1-`exemptions')

		sum frm_ex_purc frm_nx_purc inf_ex_purc inf_nx_purc

		g frm_purc_net_vat = frm_purc/ ((1 + `bDir') * (1 + `bInd'))   
		g inf_purc_net_vat = inf_purc / (1 + `bInd') 
		assert frm_purc_net_vat >= 0 & inf_purc_net_vat >= 0 & frm_purc_net_vat <= frm_purc & inf_purc_net_vat <= inf_purc

		* Calculate pre-VAT purchases for calculating excises
		egen purc_net_vat = rowtotal(frm_purc_net_vat inf_purc_net_vat)
		assert purc_net_vat >= 0 & purc_net_vat <= (frm_purc_net_vat + inf_purc_net_vat)

		* Calculate VAT 

		* Formal 
		g itx_vatx_frml_item = frm_purc_net_vat*((1 + `dir') * (1 + `ind') - 1) 

		* Informal 
		g itx_vatx_infr_item = inf_purc_net_vat*`ind'

		* Sum the two together  
		egen itx_vatx_item = rowtotal(itx_vatx_frml_item itx_vatx_infr_item)
		assert itx_vatx_item >= 0 & itx_vatx_item != . 

		*** 
		* Checks
		loc j = 0
		foreach i in nx ex{
			g frm_`i'_vatrate = itx_vatx_frml_item/frm_purc if `exemptions' == `j'
			g inf_`i'_vatrate = itx_vatx_infr_item/inf_purc if `exemptions' == `j'
			loc ++j
		}
		sum frm_ex_vatrate frm_nx_vatrate inf_ex_vatrate inf_nx_vatrate [w=`hhweight']
		
		
		* Recalculate direct and indirect VAT such that they are additive 
		g itx_vatd_item = frm_purc_net_vat * `dir' //assume that direct tax is only levied on formal purchases
		replace itx_vatd_item = itx_vatx_item if itx_vatd_item > itx_vatx_item & itx_vatd_item <= 1.00001*itx_vatx_item
		assert itx_vatd_item <= itx_vatx_item & !mi(itx_vatd_item)
		g itx_vati_item = itx_vatx_item - itx_vatd_item
		assert itx_vatd_item >= 0 & itx_vati_item >= 0

		* 1. No informality but exemptions 
		g itx_vatx_ninf_item = purc_net_vat*((1 + `dir') * (1 + `ind') - 1) 

		* No tax expenditures
		g itx_vatx_nexp_item = frm_purc_net_vat* `rate' 

		* 2. No tax expenditures, nor informality 
		g itx_vatx_perf_item = purc_net_vat * `rate' 

		save `dataout', replace


	if "`collapse'" == "collapse"{
			collapse (sum) itx_vat*, by(`hhid' `hhweight')
			ren (*_item) (*_hh)

			lab var itx_vatx_hh "VAT"
			lab var itx_vatd_hh "Direct VAT"										
			lab var itx_vati_hh "Indirect VAT"	
			lab var itx_vatx_ninf_hh "VAT: no informality (de jure protective value of exemptions)"
			lab var itx_vatx_nexp_hh "VAT: no tax expenditures (SR)"
			lab var itx_vatx_perf_hh "VAT: no distortions (LR)"

			save `dataout', replace
	}
if "`restore'" == "restore"{
	restore	
}

end 

