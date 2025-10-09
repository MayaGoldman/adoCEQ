** 8. Coverage, generosity and average grant amount received

cap program drop coverage 
program define coverage
	version 16.0
	syntax varlist(min = 1) [,quantiles(integer 10) povline(varname) pcweight(string) income(varname) data(string) exportfile(string) coveragesh(string) avgvalsh(string) generositysh(string) gapsh(string) restore]

	if "`restore'" == "restore"{
			preserve 
	}
		g id = 1
		loc y `income'

		foreach v in `varlist' {
			local lbl : variable label `v'
			local `v'_lbl "`lbl'"
			disp "``v'_lbl'"
		}

		loc rhlist ""
		loc ylist ""

		foreach v in `varlist'{
			g `v'_rh = (`v' > 0)
			loc rhlist `rhlist' `v'_rh
			g `y'_`v' = `y'*`v'_rh	
			loc ylist `ylist' `y'_`v'
		}

		g gap_`y' = 0
		replace gap_`y' = povline - `y' if povline > `y' 

		loc pregaplist ""
		loc pstgaplist ""
		foreach v in `varlist'{
			g pre_gap_`v' = 0
			replace pre_gap_`v' = (povline - `y'_`v')*`v'_rh if povline > `y'_`v'
			loc pregaplist `pregaplist' pre_gap_`v' 
			g pst_gap_`v' = 0	
			replace pst_gap_`v' = (povline - `y'_`v' - `v')*`v'_rh if povline > (`y'_`v' + `v')
			loc pstgaplist `pstgaplist' pst_gap_`v' 
		}

		loc collapselist id `varlist' `rhlist' `ylist' 

		* Generate quantiles 
		loc q "`quantiles'"
		quantiles `y' [w = `pcweight'], nq(`q') gencatvar(decile_`y')
	
		tempfile pre
		save `pre'

		* National level results
			collapse (mean) `y' `povline' gap_`y' `pregaplist' `pstgaplist' (sum) `collapselist' [pw = `pcweight']
			g decile_`y' = 11
			
			ren (id) (pop)
			ren (*_rh) (*_rpop)


			foreach v in `varlist'{
				g cov_`v' = (`v'_rpop/pop)*100   	// number of individuals receiving the grant over the total population
				g avgVal_`v' = `v'/`v'_rpop 		// total value of grant received divided by the recipient population
				g gen_`v' = (`v'/`y'_`v')*100 		// total number of recipients, divided by total income (conditional incidence)

			}

			keep decile_`y' pop cov_* avgVal_* gen_* gap* *gap*
			tempfile total 
			save `total'
		

		* Decile-level results

			use `pre', clear 
			collapse (mean) `y' `povline' gap_`y' `pregaplist' `pstgaplist' (sum)  `collapselist' [pw = `pcweight'], by(decile_`y')
			ren (id) (pop)
			ren (*_rh) (*_rpop) 

			foreach v in `varlist'{
				g cov_`v' = (`v'_rpop/pop)*100
				lab var cov_`v' "``v'_lbl'"
				g avgVal_`v' = `v'/`v'_rpop
				lab var avgVal_`v' "``v'_lbl'"
				g gen_`v' = (`v'/`y'_`v')*100
				lab var gen_`v' "``v'_lbl'"			
				lab var pre_gap_`v' "``v'_lbl'"
				lab var pst_gap_`v' "``v'_lbl'"
			}

		keep decile_`y' `povline' pop cov_* avgVal_* gen_* gap* *gap*
		lab var pop "Population (million)"
		append using `total'
		replace pop = pop/1e6
		lab define decile_lbl 1"Poorest" 10"Richest" 11"National", replace
		lab val decile_`y' decile_lbl
		lab var decile_`y' "Decile (`y')"
		lab var gap_`y' "Average distance from the poverty line (LCU)"

		
		* Save and export the data
		if "`data'" != ""{
			save "`data'", replace
		}
		if "`exportfile'" != ""{
			if "`coveragesh'" != ""{
				export excel decile_`y' pop cov_* using "`exportfile'", sheet("`coveragesh'") first(varl) cell(A1) sheetmodify keepcellfmt
			}
			if "`avgvalsh'" != ""{
				export excel decile_`y' avgVal_* using "`exportfile'", sheet("`avgvalsh'") first(varl) cell(A1) sheetmodify keepcellfmt
			}
			if "`generositysh'" != ""{
				export excel decile_`y' gen_* using "`exportfile'", sheet("`generositysh'") first(varl) cell(A1) sheetmodify keepcellfmt
			}
			if "`gapsh'" != ""{
				export excel decile_`y' gap_`y' pre_gap_* pst_gap_* using "`exportfile'", sheet("`gapsh'") first(varl) cell(A1) sheetmodify keepcellfmt
			}
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
