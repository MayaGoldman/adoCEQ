** 8. Coverage, generosity and average grant amount received

cap program drop coverage 
program define coverage
	version 16.0
	syntax varlist(min = 1) [,quantiles(integer 10) pcweight(string) income(varname) data(string) exportfile(string) coveragesh(string) avgvalsh(string) generositysh(string) restore]

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

		loc collapselist id `varlist' `rhlist' `ylist'

		* Generate quantiles 
		loc q "`quantiles'"
		quantiles `y' [w = `pcweight'], nq(`q') gencatvar(decile_`y')
	
		tempfile pre
		save `pre'

		* National level results
			collapse (sum) `collapselist' [pw = `pcweight']
			g decile_`y' = 11
			
			ren (id) (pop)
			ren (*_rh) (*_rpop)

			foreach v in `varlist'{
				g cov_`v' = (`v'_rpop/pop)*100   	// number of individuals receiving the grant over the total population
				g avgVal_`v' = `v'/`v'_rpop 	// total value of grant received divided by the recipient population
				g gen_`v' = (`v'/`y'_`v')*100 	// total number of recipients, divided by total income (conditional incidence)
			}

			keep decile_`y' pop cov_* avgVal_* gen_*
			tempfile total 
			save `total'
		
		use `pre', clear 
		collapse (sum)  `collapselist' [pw = `pcweight'], by(decile_`y')
		ren (id) (pop)
		ren (*_rh) (*_rpop) 

		foreach v in `varlist'{
			g cov_`v' = (`v'_rpop/pop)*100
			lab var cov_`v' "``v'_lbl'"
			g avgVal_`v' = `v'/`v'_rpop
			lab var avgVal_`v' "``v'_lbl'"
			g gen_`v' = (`v'/`y'_`v')*100
			lab var gen_`v' "``v'_lbl'"
		}

		keep decile_`y' pop cov_* avgVal_* gen_*
		lab var pop "Population (million)"
		append using `total'
		replace pop = pop/1e6
		lab define decile_lbl 1"Poorest" 10"Richest" 11"National"
		lab var decile_`y' decile_lbl
		lab var decile_`y' "Decile (`y')"
		
		* Save and export the data
		if "`data'" != ""{
			save "`data'", replace
		}
		if "`exportfile'" != ""{
			export excel decile_`y' pop cov_* using "`exportfile'", sheet("`coveragesheet'") first(varl) cell(A1) sheetmodify keepcellfmt
			export excel decile_`y' avgVal_* using "`exportfile'", sheet("`avgvalsheet'") first(varl) cell(A1) sheetmodify keepcellfmt
			export excel decile_`y' gen_* using "`exportfile'", sheet("`generositysheet'") first(varl) cell(A1) sheetmodify keepcellfmt
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
