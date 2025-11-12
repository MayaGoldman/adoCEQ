* Maya Goldman 
* July 2025 

cap program drop concentration 
program define concentration
	version 16.0
	syntax varlist(min = 1) [, rerank Quantiles(integer 10) UNIT(integer 1) PCWeight(string) income(varname) incomeRank(varname) DATAset(string) EXPortfile(string) consh(string) absvalsh(string) restore]

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
		loc x = substr("`y'", 1, 2)
		di in red "{You have chosen to rank by `y'}"


	* Collapse the dataset by quantile 
		loc q "`quantiles'"
		
	if "`rerank'" != "rerank"{
		loc y `incomeRank'
		cap drop decile_`x'
		quantiles `y' [w = `pcweight'], nq(`q') gencatvar(decile_`x')
		di in red "{You have chosen to rank by `y'}"
		
	}
	quantiles `y' [w = `pcweight'], nq(`q') gencatvar(decile_`x')
	collapse (sum) `varlist' `income'  [pw=`pcweight'], by(decile_`x')

		insobs 1
		replace decile_`x' = 11 if decile_`x' == .

	* Concentration shares
		loc concentrationlist ""
		foreach v in `varlist'{
			loc z = substr("`v'", 1, strlen("`v'") - 3)
			qui sum `v' 
			loc total = r(sum)
			replace `v' = `total' if decile_`x' == 11 & `v' == . 
			gen con_`x'_`z' = (`v'/`total')*100

			loc j = "``v'_lbl'"
			disp "`j'"
			lab var con_`x'_`z' "`j'"
			loc concentrationlist `concentrationlist' con_`x'_`z' 

			qui sum con_`x'_`z' if decile_`x' < 11
			loc check = r(sum)
			assert `check' > 99 & `check' < 101
			replace con_`x'_`z' = `check' if decile_`x' == 11 & con_`x'_`z' == .
		}

			lab var decile_`x' "Decile `y'"
			keep decile* con_* `varlist'
			lab define decile_lbl 1"Low-income" 10"High-income" 11"National", replace 
			lab val decile_`x' decile_lbl

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
				keep decile_`x' con_y*
				export excel "`exportfile'", sheet("`consh'") first(varl) cell(A1) sheetmodify keepcellfmt
			use `dataset', clear
				keep decile_`x' `varlist' 
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

