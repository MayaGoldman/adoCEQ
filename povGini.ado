cap program drop povgin 
program define povgin
	version 16.0
	syntax varlist(min = 1) [, varpovlines(string) pcweight(string) ///
		data(string) exportfile(string) exportsheet(string) outputformat(string)] 

di "Variables passed: `varlist'"


 if "`varpovlines'" == ""{
	di "You must specify your poverty line."
	exit 198
}


** Inequality calculation 
	foreach y in `varlist'{ 
		qui ineqdeco `y' [w=`pcweight']                 
		gen gi_`y' = r(gini)*100
		lab var gi_`y' "Gini (%)"
	}

* Poverty calculation	
	foreach line in `varpovlines'{
		foreach y in `varlist'{
			qui povdeco `y' [w=`pcweight'], varpl(`line')   
			g ph_`line'_`y' = r(fgt0)*100
			g pg_`line'_`y' = r(fgt1)*100

			lab var ph_`line'_`y' "Headc. (`line', `y')"
			lab var pg_`line'_`y' "Gap. (`line', `y')"
		}
	}

preserve
	keep gi* ph* pg*
	keep if _n == 1 //keep just one national result

	if "`outputformat'" == "wide"{
		* Generate clean dataset 
			if "`simnumber'" != ""{
				di "Cannot specify a simulation number if output format is wide"
				exit 198
			}	
			if "`data'" != ""{
				save "`data'", replace
			}
			if "`exportfile'" != ""{
				export excel "`exportfile'", sheet("`exportsheet'") first(varl) cell(B3) sheetmodify
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
	} 
	else if "`outputformat'" == "long"{
		* Rename variables by number (as prep for the reshape)
		loc j = 0
		
		foreach y in `varlist'{
			loc ++j
			ren (gi_`y') (gi_`j')
			
			foreach line in `varpovlines'{
				ren (p*_`line'_`y') (p*_`line'_`j') 
			}
		} 
		loc totInc = `j' //save the total number of income concepts 

		collapse (mean) gi_* ph_* pg_*

		loc gilist gi_ 
		loc povlist
		foreach line in `varpovlines'{
			loc povlist $povlist ph_`line'_ pg_`line'_			
		}
		disp "`povlist'"

		g id = _n 
		reshape long `gilist' `povlist', i(id) j(income)  //y is the variable that will store the incomes
		drop id
		lab var income "Income concept"
		ren (*_) (*)

		lab var gi "Gini"
		foreach line in `varpovlines'{
			lab var ph_`line' "Headc. (`line')"
			lab var pg_`line' "Gap (`line')"
		}

		* Calculate the total impact on poverty and inequality  
			insobs 1	
			count
			replace income = `r(N)' if income == .
			loc k = `j'-1
			foreach var of varlist gi*{
				replace `var' = `var'[2] - `var'[`totInc'] if `var' == .
			}
			foreach var of varlist ph* pg*{
				replace `var' = `var'[2] - `var'[`k'] if `var' == . 
			}
			if "`data'" != ""{
				save "`data'", replace
			}
			if "`exportfile'" != ""{
				export excel "`exportfile'", sheet("`exportsheet'") first(varl) cell(B3) sheetmodify
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
	} // if format == long
	else if "`outputformat'" != "long" & "`outputformat'" != "wide"{
		di in red "ERROR: please specify wide / long for your outputs"
	} 
restore
end 

