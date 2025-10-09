* Maya Goldman 
* July 2025 

cap program drop incidence 
program define incidence
	version 16.0
	syntax varlist(min = 1) [, rerank quantiles(integer 10) pcweight(varname) income(varlist) taxes(varlist) data(string) exportfile(string) exportsheet(string) incomeRank(string) restore]

	if "`restore'" == "restore"{
			preserve 
	}  
		loc keeplist `pcweight' `varlist' `income'
		keep `keeplist'

		foreach v in `taxes'{
			replace `v' = -`v' 
		}

		foreach v in `keeplist' {
			assert !mi(`v')
		}

	* Convert variable names into locals for labeling later on 
		foreach v in `varlist' {
			local lbl : variable label `v'
			local `v'_lbl "`lbl'"
			disp "``v'_lbl'"
		}
		
	* Collapse the dataset by quantile 
		loc q "`quantiles'"
		loc y `income'
		quantiles `y' [w = `pcweight'], nq(`q') gencatvar(decile_`y')
		
	if "`rerank'" != "rerank"{
		loc y `incomeRank'
		cap drop decile_`y'
		quantiles `y' [w = `pcweight'], nq(`q') gencatvar(decile_`y')
		
	}
		di in red "{You have chosen to rank by `y'}"
		collapse (sum) `varlist' `income'  [pw=`pcweight'], by(decile_`y')

		* Incidence
		insobs 1 
		replace decile_`y' = 11 if decile_`y' == . 

		qui sum `y'
		replace `y' = r(sum) if `y' == . & decile == 11
		foreach i in `varlist'{
			qui sum `i'
			replace `i' = r(sum) if `i' == . & decile == 11

			gen inc_`y'_`i' = (`i'/`y')*100

			loc j = "``i'_lbl'"
			disp "`j'"
			lab var inc_`y'_`i' "`j'"
		}
		lab var decile_`y' "Decile `y'"
		keep decile* inc_* 

		lab define decile_lbl 1"Low-income" 10"High-income" 11"National", replace 
		lab val decile_`y' decile_lbl     
	
	* Save and export the data
		if "`data'" != ""{
			save "`data'", replace
		}
		if "`exportfile'" != ""{
			export excel using "`exportfile'", sheet("`exportsheet'") first(varl) cell(A1) sheetmodify keepcellfmt
			if "`exportsheet'" == ""{
				di in red "Error: Specify a sheet name!"
				exit 198
			}
			if _rc {
			    di "Excel export failed. Try creating the file first or check sheet name."
			}	
		}
		else{
			di in blue "{Specify an Excel workbook to export results.}"
		}

	if "`restore'" == "restore"{
		restore
	}
end

/* Note: I don't label the Concentration shares and incidence as such, 
				because I don't want the labels to show up in the graphs.*/
