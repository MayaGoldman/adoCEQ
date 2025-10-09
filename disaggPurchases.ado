cap program drop disaggPurchases 
program define disaggPurchases
version 16.0
	syntax varlist(min = 1) [, refIncome(varname) hhid(varname) itemID(varname) ioID(varname) infShare(varname) coicopID(varname) fixed(varname) rate(integer 0) exemptions(varname) purchases(varname)  iodata(string) hhweight(varname) missExSect(numlist integer >0) missStSect(numlist integer >0)

	preserve
		**** VAT analysis ***
		* Disaggregate purchases, by decile 

			merge m:1 $hhid using "${data_pre}hous_2023.dta", assert(match) keepusing(`refIncome') nogen
			keep $weight yg_pc purc inf_ex_purc inf_nx_purc frm_ex_purc frm_nx_purc exempted vatable 

			quantiles `refIncome' [w = $weight], nquant(10) gencatvar(decile)

			g check = purc - (frm_ex_purc + frm_nx_purc + inf_ex_purc + inf_nx_purc)
			assert abs(check) <= 1*1e-8

		collapse (sum) inf_ex_purc inf_nx_purc frm_ex_purc frm_nx_purc [w = $weight], by(decile)

		lab var frm_ex_purc "Formal-exempt purchases"
		lab var frm_nx_purc "Formal-standard purchases"
		lab var inf_ex_purc "Informal-exempt purchases"
		lab var inf_nx_purc "Informal-standard purchases"

		foreach var in inf_ex_purc inf_nx_purc frm_ex_purc frm_nx_purc{
			replace `var' = `var'/1e9  //unit = billions 
		}

		save "${data_int}purchVAT_${year}.dta", replace 
	restore
end
