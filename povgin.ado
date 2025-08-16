cap program drop povgin 
program define povgin
	version 16.0
	syntax [, natpovinc(varlist) gininc(varlist) intlpovinc(varlist) nsim(integer 0) natpovline(string) intlpovline(string) pcweight(string) data(string) exportfile(string) exportsheet(string) restore]

	if "`restore'" == "restore"{
		preserve 
	}

	loc l = "`nsim'"
	disp `l'

di "Variables passed: `varlist'"

loc povlines `natpovline' `intlpovline'
disp "`povlines'"
 if "`povlines'" == ""{
	di "You must specify your poverty line."
	exit 198
}


** Inequality calculation 
	loc j = 0
	foreach y in `gininc'{ 
		loc ++j
		qui ineqdeco `y' [w=`pcweight']                 
		gen gi_`j' = r(gini)*100
		lab var gi_`j' "Gini (%)"
	}

* Poverty calculation
	* NATIONAL 	
	foreach line in `natpovline'{
		loc j = 0
		foreach y in `natpovinc'{
			loc ++ j
			qui povdeco `y' [w=`pcweight'], varpl(`line')   
			g ph_`line'_`j' = r(fgt0)*100
			g pg_`line'_`j' = r(fgt1)*100

			lab var ph_`line'_`j' "Headc. (`line', `y')"
			lab var pg_`line'_`j' "Gap. (`line', `y')"
		}
	}
	loc totInc = `j' //save the total number of income concepts 

	* INTERNATIONAL 	
	foreach line in `intlpovline'{
		loc j = 0
		foreach y in `intlpovinc'{
			loc ++j
			qui povdeco `y' [w=`pcweight'], varpl(`line')   
			g ph_`line'_`j' = r(fgt0)*100
			g pg_`line'_`j' = r(fgt1)*100

			lab var ph_`line'_`j' "Headc. (`line', `y')"
			lab var pg_`line'_`j' "Gap. (`line', `y')"
		}
	}

	keep gi* ph* pg*
	keep if _n == 1 //keep just one national result

		collapse (mean) gi_* ph_* pg_*

		loc gilist gi_ 
		loc povlist
		foreach line in `povlines'{
			loc povlist `povlist' ph_`line'_ pg_`line'_			
		}
		disp "`povlist'"

		g id = _n 
		reshape long `gilist' `povlist', i(id) j(income)  //y is the variable that will store the incomes
		drop id
		lab var income "Income concept"
		ren (*_) (*)

		lab var gi "Gini"
		foreach line in `povlines'{
			lab var ph_`line' "Headc. (`line')"
			lab var pg_`line' "Gap (`line')"
		}

		* Calculate the total impact on poverty and inequality  
			insobs 1	
			count
			replace income = `r(N)' if income == .
			loc k = `j'-1
			foreach var of varlist gi*{
				replace `var' = `var'[1] - `var'[`totInc'] if `var' == .
			}
			foreach var of varlist ph* pg*{
				replace `var' = `var'[1] - `var'[`k'] if `var' == . 
			}
			lab define income_lbl 1 "Market + pens." 2"Net market" 3"Gross" 4"Disposable" 5"Consumable" 6"Final" 7"Total effect", replace
			lab val income income_lbl

		* Generate a marker variable for the simulation 

			if `l' != 0{
				g sim = `nsim'
				lab var sim "Sim nr"
			}

		* Save and export the data
			if "`data'" != ""{
				save "`data'", replace
			}
			if "`exportfile'" != ""{
				export excel "`exportfile'", sheet("`exportsheet'") first(varl) cell(A1) sheetmodify keepcellfmt
				if "`exportfile'" == ""{
					di in red "Error: Specify a sheet name!"
					exit 198
				}
				if _rc {
				    di "Excel export failed. Try creating the file first or check sheet name."
				}	
			}
			else{
				di "Failure to specify an Excel output spreadsheet. No Excel results produced."
			}

	if "`restore'" == "restore"{
		restore
	}
end 

