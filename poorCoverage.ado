cap program drop poorCoverage 
program define poorCoverage
	version 16.0
	syntax varlist(min = 1) [,popweight(string) povline(varname) income(varname) data(string) exportfile(string) exportsh(string) restore]

	if "`restore'" == "restore"{
			preserve 
	}

	keep `varlist' `income' `povline' `popweight'
	g poor = (`income' < `povline')
	drop `income' `povline'
	keep if poor == 1

	g poorPop = 1
	

* Store labels 
loc j = 0
loc newlist ""
	foreach v in `varlist'{
		loc ++j
		loc `j'_lbl : variable label `v'
		g coveredPoorPop_`j' = (`v' > 0) //ru = receiving unit - should work whether we're at the household or individual level, as long as we specify the correct weights  
	}

	collapse (sum) coveredPoorPop_* poorPop [pw = `popweight']
* Reshape 
	g id = 1 
	reshape long coveredPoorPop_, i(id) j(transfer)
	drop id 
	ren coveredPoorPop_ coveredPoorPop
	replace  coveredPoorPop = coveredPoorPop/1e6
	replace  poorPop = poorPop/1e6

	g poorCoverage = coveredPoorPop/poorPop*100
	lab var poorCoverage "Coverage of the poor (% of poor Pop)"
	lab var coveredPoorPop "Covered poor population ('mil)"
	lab var poorPop "Poor population ('mil)"

	lab define transfer_lbl 1"`1_lbl'" 2"`2_lbl'" 3"`3_lbl'" 4"`4_lbl'"  5"`5_lbl'"  6"`6_lbl'" 7"`7_lbl'" 8"`8_lbl'" 9"`9_lbl'" 10"`10_lbl'" ///
							11"`11_lbl'" 12"`12_lbl'" 13"`13_lbl'" 14"`14_lbl'" 15"`15_lbl'" 16"`16_lbl'" 17"`17_lbl'" 18"`18_lbl'" 19"`19_lbl'" 20"`20_lbl'" ///
						    21"`21_lbl'" 22"`22_lbl'" 23"`23_lbl'" 24"`24_lbl'" 25"`25_lbl'" 26"`26_lbl'" 27"`27_lbl'" 28"`28_lbl'" 29"`29_lbl'" 30"`30_lbl'" ///
						    31"`31_lbl'" 32"`32_lbl'" 33"`33_lbl'" 34"`34_lbl'" 35"`35_lbl'" 36"`36_lbl'" 37"`37_lbl'" 38"`38_lbl'" 39"`39_lbl'" 40"`40_lbl'", replace 
	lab val transfer transfer_lbl
	lab var transfer "Program"

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
