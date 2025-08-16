cap program drop margCont 
program define margCont
	version 16.0
	syntax[, income(varlist) taxes(varlist) included(varlist) excluded(varlist) pcweight(varlist) data(string) pline(string) positivetax exportfile(string) exportsheet(string) restore]

	if "`restore'" == "restore"{
		preserve 
	}
		loc varlist `included' `excluded'
		loc keeplist `varlist' `income' `pcweight' `pline'
		disp "`keeplist'" 
		keep `keeplist'	

	* Convert variable names into locals for labeling later on 
		foreach var in `varlist'{
			local lbl : variable label `var'
			local `var'_lbl "`lbl'"
			disp "``var'_lbl'"
		}

	 	if "`positivetax'" == "positivetax" {
			di in red "{Converting tax variables to negative}"
			foreach v in `taxes'{
				replace `v' = -`v'
			} 
		}
		else {
			di in red "{Checking that tax variables are already negative}"
			foreach v in `taxes'{
				assert `v' <= 0
			} 		
		} 

* Marginal contribution 
	loc mcList ""
	foreach y in `income'{
		foreach i in `included'{
			di "`y' less `i'"
			g `y'_`i' = `y' - `i'
			lab var `y'_`i' "Cons. inc. w/o $`i'" 
		}
		
		foreach i in `excluded'{
			di "`y' plus `i'"
			g `y'_`i' = `y' + `i'
			lab var `y'_`i' "Cons. inc. w. $`i'"
		}
	
		// Calculate inequality and poverty for the extended income concepts
		qui ineqdeco `y' [w = `pcweight']
		g gi_`y' = r(gini)*100
		foreach i in `varlist'{
			qui ineqdeco `y'_`i' [w = `pcweight']
			g gi_`y'_`i' = r(gini)*100
		} 
		
		qui povdeco `y' [w = `pcweight'], varpl(`pline')
		g ph_`pline'_`y' = r(fgt0)*100
		g pg_`pline'_`y' = r(fgt1)*100
	
		foreach i in `varlist'{
			qui povdeco `y'_`i' [w = `pcweight'], varpl(`pline')   
			g ph_`y'_`i' = r(fgt0)*100
			g pg_`y'_`i' = r(fgt1)*100
		} 
							
		* Calculate marginal contributions as the value WITHOUT the variable less the value WITH the variable 
		foreach i in `included'{
			g mcgi_`y'_`i' = gi_`y'_`i' - gi_`y'
			g mcph_`y'_`i' = ph_`y'_`i' - ph_`pline'_`y'
			g mcpg_`y'_`i' = pg_`y'_`i' - pg_`pline'_`y'
		} 

		* For education and health
		foreach i in `excluded'{
			g mcgi_`y'_`i' = gi_`y' - gi_`y'_`i'
			g mcph_`y'_`i' = ph_`pline'_`y' - ph_`y'_`i'
			g mcpg_`y'_`i' = pg_`pline'_`y' - pg_`y'_`i'
		} 
		loc mcList `mcList' mcgi_`y'_ mcph_`y'_ mcpg_`y'_
	} //incomeList
	disp "`mcList'"


	//reshape long so that you have the variable on the rows, and the type of indicator on the columns 
	g id = _n  
	loc n = 0
	foreach i in `varlist'{
		loc ++n 
		disp `n'
		loc lab`n' = "``i'_lbl'"	
		foreach j in `mcList'{   //foreach variable, and for each indicator (i.e. mcgi, mcph, mcpg)
			ren (`j'`i') (`j'`n')
		} 
	}
	disp "`lab1'"

	keep id mc*
	keep if _n == 1
	reshape long `mcList', i(id) j(instrument)		
	ren (*_) (*)
 
	lab var instrument "Fiscal instrument"
	lab def instrument_lbl 1"`lab1'" 2"`lab2'" 3"`lab3'" 4"`lab4'" 5"`lab5'" 6"`lab6'" 7"`lab7'" 8"`lab8'" 9"`lab9'" 10"`lab10'" ///
	11"`lab11'" 12"`lab12'" 13"`lab13'" 14"`lab14'" 15"`lab15'" 16"`lab16'" 17"`lab17'" 18"`lab18'" 19"`lab19'" 20"`lab20'" ///
	21"`lab21'" 22"`lab22'" 23"`lab23'" 24"`lab24'" 25"`lab25'" 26"`lab26'" 27"`lab27'" 28"`lab28'" 29"`lab29'" 30"`lab30'" ///
	31"`lab31'" 32"`lab32'" 33"`lab33'" 34"`lab34'" 35"`lab35'" 36"`lab36'" 37"`lab37'" 38"`lab38'" 39"`lab39'" 40"`lab40'" ///
	41"`lab41'" 42"`lab42'" 43"`lab43'" 44"`lab44'" 45"`lab45'" 46"`lab46'" 47"`lab47'" 48"`lab48'" 49"`lab49'" 50"`lab50'" ///
	51"`lab51'" 52"`lab52'" 53"`lab53'" 54"`lab54'" 55"`lab55'" 56"`lab56'" 57"`lab57'" 58"`lab58'" 59"`lab59'" 60"`lab60'" ///
	61"`lab61'" 62"`lab62'" 63"`lab63'" 64"`lab64'" 65"`lab65'" 66"`lab66'" 67"`lab67'" 68"`lab68'" 69"`lab69'" 70"`lab70'" ///
	71"`lab71'" 72"`lab72'" 73"`lab73'" 74"`lab74'" 75"`lab75'" 76"`lab76'" 77"`lab77'" 78"`lab78'" 79"`lab79'" 80"`lab80'",  replace

	lab val instrument instrument_lbl
	foreach y in `income'{
		lab var mcgi_`y' "Gini (`y')"
		lab var mcph_`y' "Headc. (`y')"
		lab var mcpg_`y' "Gap (`y')"
	}		
	drop id 
		
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



/* Still to do: 
	Get the ado to run in the case where we submit more than one income concept. 
*/
