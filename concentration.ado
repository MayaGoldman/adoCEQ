* Maya Goldman 
* July 2025 

cap program drop concentration 
program define concentration
	version 16.0
	syntax varlist(min = 1) [, rerank Quantiles(integer 10) UNIT(integer 1) PCWeight(string) DATAset(string) EXPortfile(string) consh(string) absvalsh(string) income(varname) incomeRank(varname) restore]

		if "`restore'" == "restore"{
			preserve 
		} 
		loc keeplist `pcweight' `pline' `varlist' `income'
		keep `keeplist'	

		foreach v in `keeplist' {
			assert !mi(`v')
		}

	* Convert variable names into locals for labeling later on 
		foreach v in `varlist' {
			local lbl : variable label `v'
			local `v'_lbl "`lbl'"
			disp "``v'_lbl'"
		}

		loc y `income'
		di in red "{You have chosen to rank by `y'}"


	* Collapse the dataset by quantile 
		loc q "`quantiles'"
		
	if "`rerank'" != "rerank"{
		loc y `incomeRank'
		cap drop decile_`y'
		quantiles `y' [w = `pcweight'], nq(`q') gencatvar(decile_`y')
		di in red "{You have chosen to rank by `y'}"
		
	}
	quantiles `y' [w = `pcweight'], nq(`q') gencatvar(decile_`y')
	collapse (sum) `varlist' `income'  [pw=`pcweight'], by(decile_`y')

		insobs 1
		replace decile_`y' = 11 if decile_`y' == .

	* Concentration shares
		loc concentrationlist ""
		foreach v in `varlist'{
			qui sum `v' 
			loc total = r(sum)
			replace `v' = `total' if decile_`y' == 11 & `v' == . 
			gen con_`y'_`v' = (`v'/`total')*100

			loc j = "``v'_lbl'"
			disp "`j'"
			lab var con_`y'_`v' "`j'"
			loc concentrationlist `concentrationlist' con_`y'_`v' 

			qui sum con_`y'_`v' if decile_`y' < 11
			loc check = r(sum)
			assert `check' > 99 & `check' < 101
			replace con_`y'_`v' = `check' if decile_`y' == 11 & con_`y'_`v' == .
		}

			lab var decile_`y' "Decile `y'"
			keep decile* con_* `varlist'
			lab define decile_lbl 1"Poorest" 10"Richest" 11"National"
			lab var decile_`y' decile_lbl

	* Absolute value
		foreach v in `varlist'{
			loc lbl : variable label `v'
			if "`unit'" == "6"{
				replace `v' = `v'/1e6
				lab var `v' "``v'_lbl' (mil' LCU)"
			} 
			else if "`unit'" == "9"{
				replace `v' = `v'/1e9
				lab var `v' "``v'_lbl' (bil' LCU)"
			} 
			else if "`unit'" == "12"{
				replace `v' = `v'/1e12
				lab var `v' "``v'_lbl' (tril' LCU)"
			} 
		}

		tempfile dataset 
		save `dataset'
		
	* Save and export the data
		if "`data'" != ""{
			save "`data'", replace
		}
		if "`exportfile'" != ""{
				keep decile_`y' con_*
				export excel "`exportfile'", sheet("`consh'") first(varl) cell(A1) sheetmodify keepcellfmt
			use `dataset', clear
				keep decile_`y' `varlist' 
				export excel "`exportfile'", sheet("`absvalsh'") first(varl) cell(A1) sheetmodify keepcellfmt

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

