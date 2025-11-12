cap program drop errors 
program define errors
	version 16.0
	syntax varlist(min = 1) [,popweight(string) elig(varname) povline(varname) income(varname) data(string) exportfile(string) exportsh(string) restore]

	if "`restore'" == "restore"{
			preserve 
	}

	* Eligible population (if not specified, assume it is the poor)


	keep `varlist' `income' `elig' `povline' `popweight' `beneficiary'
	if "`elig'" == ""{
		g eligPop = (`income' < `povline')
		g nonEligPop = (`income' >= `povline')
	}
	else if "`elig'" != ""{
		g eligPop = (`elig' == 1)
		g nonEligPop = (`elig' == 0)
	}

	g pop = 1

* Store labels

if "`elig'" != ""{
	loc j = 0
	foreach v of varlist `varlist'{
		loc ++j
		loc `j'_name `v'
		loc `j'_lbl: variable label `v'
		g eligPopExcl_`j' = (`elig' == 1 & `v' == 0)
		g nonEligPopIncl_`j' = (`elig' == 0 & `v' > 0)
		g ben_`j' = (`v' > 0)
	}
}
else if "`elig'" == ""{ 
	loc j = 0
	foreach v of varlist `varlist'{
		loc ++j
		loc `j'_name `v'
		loc `j'_lbl: variable label `v'
		g eligPopExcl_`j' = (eligPop == 1 & `v' == 0)
		g nonEligPopIncl_`j' = (eligPop == 0 & `v' > 0)
		g ben_`j' = (`v' > 0)
	}
}

loc varNum = `j'
disp "The total number of variables is: "`varNum'




* Generate quantiles
	quantiles `income' [w = `popweight'], gencatvar(decile)
	drop `income' `povline' 


* bOTTOM 10% EXCLUSION
preserve
	collapse (sum) eligPopExcl_* nonEligPopIncl_* ben_* eligPop nonEligPop pop [pw = `popweight']
	g decile = 11
	tempfile national 
	save `national'
restore
	collapse (sum) eligPopExcl_* nonEligPopIncl_* ben_* eligPop nonEligPop pop [pw = `popweight'], by(decile)
	append using `national'

tempfile temp
save `temp', replace

	* Reshape 
	reshape long eligPopExcl_ nonEligPopIncl_ ben_, i(decile) j(transfer)
	ren (*_) (*) 
	foreach v in eligPopExcl nonEligPopIncl eligPop nonEligPop pop ben{
		replace `v' = `v'/1e6
	}

	lab define transfer_lbl 1"`1_lbl'" 2"`2_lbl'" 3"`3_lbl'" 4"`4_lbl'"  5"`5_lbl'"  6"`6_lbl'" 7"`7_lbl'" 8"`8_lbl'" 9"`9_lbl'" 10"`10_lbl'" ///
							11"`11_lbl'" 12"`12_lbl'" 13"`13_lbl'" 14"`14_lbl'" 15"`15_lbl'" 16"`16_lbl'" 17"`17_lbl'" 18"`18_lbl'" 19"`19_lbl'" 20"`20_lbl'" ///
						    21"`21_lbl'" 22"`22_lbl'" 23"`23_lbl'" 24"`24_lbl'" 25"`25_lbl'" 26"`26_lbl'" 27"`27_lbl'" 28"`28_lbl'" 29"`29_lbl'" 30"`30_lbl'" ///
						    31"`31_lbl'" 32"`32_lbl'" 33"`33_lbl'" 34"`34_lbl'" 35"`35_lbl'" 36"`36_lbl'" 37"`37_lbl'" 38"`38_lbl'" 39"`39_lbl'" 40"`40_lbl'" ///
						    41"`31_lbl'" 42"`32_lbl'" 43"`33_lbl'" 44"`34_lbl'" 45"`35_lbl'" 46"`36_lbl'" 47"`37_lbl'" 48"`38_lbl'" 49"`39_lbl'" 50"`40_lbl'", replace 
	lab val transfer transfer_lbl
	lab define decile_lbl 1"Low-income" 10"High-income" 11"National", replace 
	lab val decile decile_lbl
	lab var transfer "Program"
	lab var pop "Population ('mil)"
	lab var eligPop "Eligible population ('mil)"
	lab var nonEligPop "Non-eligible population ('mil)"
	lab var nonEligPopIncl "Included non-eligible ('mil)"
	lab var eligPopExcl "Excluded eligible ('mil)"
	lab var ben "Beneficiaries ('mil)"

if "`exportfile'" != ""{ 
	sort transfer decile
	order transfer decile
  	export excel using "`exportfile'", sheet("`exportsh'") first(varl) cell(A10) sheetmodify keepcellfmt
}



** Errors **
	use `temp', clear 
	disp "Errors of exclusion: "
	mat define A = (1 \ 2 \ 3 \ 4 \ 5 \ 6)

forval j = 1/`varNum'{

	* D1 
	loc ex_d1 = eligPopExcl_`j'/eligPop*100
	disp "Exclusion errors in Decile 1 are (% of eligible Population): " `ex_d1'

	qui sum eligPopExcl_`j' if decile == 11
	loc eligPopExcl_`j' = r(sum)
	qui sum eligPop if decile == 11
	loc eligPop = r(sum)
	loc eligPercExcl = `eligPopExcl_`j''/`eligPop'*100  
	disp "National exclusion errors are (% of eligible Population): " `eligPercExcl'

	disp "Errors of inclusion: " 
	qui sum ben_`j' if decile == 11
	loc ben = r(sum)

	qui sum ben_`j' if inrange(decile,9,10)
	loc in_t20 = r(sum)/`ben'*100
	qui sum ben_`j' if inrange(decile,7,10)
	loc in_t40 = r(sum)/`ben'*100
	qui sum ben_`j' if inrange(decile,5,10)
	loc in_t60 = r(sum)/`ben'*100
	qui sum nonEligPopIncl_`j' if decile == 11
	loc in_nat = r(sum)/`ben'*100
	
	disp "Top 20 inclusion errors (% of benef.): "`in_t20'
	disp "Top 40 inclusion errors (% of benef.): "`in_t40'
	disp "Top 60 inclusion errors (% of benef.): "`in_t60'
	disp "National inclusion error (% of benef.): "`in_nat'

	mat define B = (`ex_d1' \ `eligPercExcl' \ `in_t20' \ `in_t40' \ `in_t60' \ `in_nat')
	mat define A = (A,B)
}
	mat list A
	clear
	svmat A

	ren (A1) (typeError)
	lab var typeError "Error type"
	lab define typeError_lbl 1"D1 exclusion error (% of D1 poor)" 2"National exclusion error (% of eligible)" 3"Top 20 inclusion error (% of beneficiaries)" 4"Top 40 inclusion error (% of beneficiaries)" 5"Top 60 inclusion error (% of beneficiaries)" 6"National inclusion error (% of beneficiaries)", replace 
	lab val typeError typeError_lbl

	forval j = 1/`varNum'{
		loc i = `j' + 1
		ren A`i' ``j'_name'
		lab var ``j'_name' "``j'_lbl'"
	}

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
