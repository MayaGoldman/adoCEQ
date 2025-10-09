cap program drop errors 
program define errors
	version 16.0
	syntax varlist(min = 1) [,popweight(string) povline(varname) income(varname) data(string) exportfile(string) exportsh(string) restore]

	if "`restore'" == "restore"{
			preserve 
	}

	keep `varlist' `income' `povline' `popweight' `beneficiary'
	g poorPop = (`income' < `povline')
	g nonPoorPop = (`income' >= `povline')
	g pop = 1

* Store labels 
loc j = 0
	foreach v of varlist `varlist'{
		loc ++j
		loc `j'_lbl: variable label `v'
		g poorPopExcl_`j' = (poorPop == 1 & `v' == 0)
		g nonPoorPopIncl_`j' = (poorPop == 0 & `v' > 0)
		g ben_`j' = (`v' > 0)
	}

* Generate quantiles
	quantiles `income' [w = `popweight'], gencatvar(decile)
	drop `income' `povline'

* bOTTOM 10% EXCLUSION
preserve
	collapse (sum) poorPopExcl_* nonPoorPopIncl_* ben_* poorPop nonPoorPop pop [pw = `popweight']
	g decile = 11
	tempfile national 
	save `national'
restore
	collapse (sum) poorPopExcl_* nonPoorPopIncl_* ben_* poorPop nonPoorPop pop [pw = `popweight'], by(decile)
	append using `national'

	* Reshape 
	reshape long poorPopExcl_ nonPoorPopIncl_ ben_, i(decile) j(transfer)
	ren (*_) (*) 
	foreach v in poorPopExcl nonPoorPopIncl poorPop nonPoorPop pop ben{
		replace `v' = `v'/1e6
	}

	lab define transfer_lbl 1"`1_lbl'" 2"`2_lbl'" 3"`3_lbl'" 4"`4_lbl'"  5"`5_lbl'"  6"`6_lbl'" 7"`7_lbl'" 8"`8_lbl'" 9"`9_lbl'" 10"`10_lbl'" ///
							11"`11_lbl'" 12"`12_lbl'" 13"`13_lbl'" 14"`14_lbl'" 15"`15_lbl'" 16"`16_lbl'" 17"`17_lbl'" 18"`18_lbl'" 19"`19_lbl'" 20"`20_lbl'" ///
						    21"`21_lbl'" 22"`22_lbl'" 23"`23_lbl'" 24"`24_lbl'" 25"`25_lbl'" 26"`26_lbl'" 27"`27_lbl'" 28"`28_lbl'" 29"`29_lbl'" 30"`30_lbl'" ///
						    31"`31_lbl'" 32"`32_lbl'" 33"`33_lbl'" 34"`34_lbl'" 35"`35_lbl'" 36"`36_lbl'" 37"`37_lbl'" 38"`38_lbl'" 39"`39_lbl'" 40"`40_lbl'", replace 
	lab val transfer transfer_lbl
	lab define decile_lbl 1"Low-income" 10"High-income" 11"National", replace 
	lab val decile decile_lbl
	lab var transfer "Program"
	lab var pop "Population ('mil)"
	lab var poorPop "Poor population ('mil)"
	lab var nonPoorPop "Non-poor population ('mil)"
	lab var nonPoorPopIncl "Included non-poor ('mil)"
	lab var poorPopExcl "Excluded poor ('mil)"
	lab var ben "Beneficiaries ('mil)"

if "`exportfile'" != ""{ 
	sort transfer decile
	order transfer decile
  	export excel using "`exportfile'", sheet("`exportsh'") first(varl) cell(D1) sheetmodify keepcellfmt
}

** Errors **
	disp "Errors of exclusion: "
	* D1 
	loc ex_d1 = poorPopExcl/poorPop*100
	disp "Exclusion errors in Decile 1 are (% of poor Population): " `ex_d1'

	qui sum poorPopExcl if decile == 11
	loc poorPopExcl = r(sum)
	qui sum poorPop if decile == 11
	loc poorPop = r(sum)
	loc ex_poor = `poorPopExcl'/`poorPop'*100  
	disp "National exclusion errors are (% of poor Population): " `ex_poor'

	disp "Errors of inclusion: " 
	qui sum ben if decile == 11
	loc ben = r(sum)

	qui sum ben if inrange(decile,9,10)
	loc in_t20 = r(sum)/`ben'*100
	qui sum ben if inrange(decile,7,10)
	loc in_t40 = r(sum)/`ben'*100
	qui sum ben if inrange(decile,5,10)
	loc in_t60 = r(sum)/`ben'*100
	qui sum nonPoorPopIncl if decile == 11
	loc in_nat = r(sum)/`ben'*100
	
	disp "Top 20 inclusion errors (% of benef.): "`in_t20'
	disp "Top 40 inclusion errors (% of benef.): "`in_t40'
	disp "Top 60 inclusion errors (% of benef.): "`in_t60'
	disp "National inclusion error (% of benef.): "`in_nat'

	mat define A = (1, `ex_d1' \ 2, `ex_poor' \ 3, `in_t20' \ 4, `in_t40' \ 5, `in_t60' \ 6, `in_nat')
	mat list A

	clear
	svmat A

	ren (A1 A2) (typeError perc)
	lab define typeError_lbl 1"D1 exclusion error (% of D1 poor)" 2"National exclusion error (% of poor)" 3"Top 20 inclusion error (% of beneficiaries)" 4"Top 40 inclusion error (% of beneficiaries)" 5"Top 60 inclusion error (% of beneficiaries)" 6"National inclusion error (% of beneficiaries)", replace 
	lab val typeError typeError_lbl
	lab var typeError "Error type"
	lab var perc "% of poor pop. / % of benef."

* Save and export the data
		if "`data'" != ""{
			save "`data'", replace
		}
		if "`exportfile'" != ""{
			export excel using "`exportfile'", sheet("`exportsh'") first(varl) cell(A1) sheetmodify keepcellfmt
			if _rc {
			    di "Excel export failed. Make sure the workbook is closed."
			}	
		}
		else{
			di in blue "{Specify an Excel workbook to export results.}"
		}

	if "`restore'" == "restore"{
		restore
	}
end
