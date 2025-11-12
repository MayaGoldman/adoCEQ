cap program drop kakwCoeff 
program define kakwCoeff
	version 16.0
	syntax [, pcweight(varlist) taxes(varlist) transfers(varlist) income(varlist) data(string) pline(string) exportfile(string) exportsheet(string) restore]

	if "`restore'" == "restore"{
			preserve 
	}  

	loc list `taxes' `transfers'

		foreach y in `income'{
			loc x = substr("`y'", 1, 2)
			foreach i in `list'{
				qui concindexi `i' [aw = `pcweight'], welfarevar(`y') clean
				loc z = substr("`i'", 1, strlen("`i'") - 3)
					matselrc r(CII) C_`z', row(1) col(1)
					g cc_`x'_`z' = C_`z'[1,1]*100
					matrix list C_`z'
			}
		}

	** Inequality calculation 
	foreach y in `income'{ 
		loc x = substr("`y'", 1, 2)
		qui ineqdeco `y' [w=`pcweight']                 
		gen gi_`x' = r(gini)*100
		lab var gi_`x' "Gini (%)"
	}

	keep if _n == 1
	
* Kakwani Coefficient
	loc indlist "" 	
	foreach y in `income'{
		loc x = substr("`y'", 1, 2)
		*if `transfers' != ""{ 
			foreach i in `transfers'{
				loc z = substr("`i'", 1, strlen("`i'") - 3)
				g kk_`x'_`z' = gi_`x' - cc_`x'_`z'	
			}	
		*}
		*if `taxes' != ""{
			foreach i in `taxes'{
				loc z = substr("`i'", 1, strlen("`i'") - 3)
				g kk_`x'_`z' = cc_`x'_`z' - gi_`x'
			}
		*}
		loc indlist `indlist' cc_`x'_ kk_`x'_
	}
	disp "`indlist'"
	g id = 1 
	
	//reshape long so that you have the variable on the rows, and the type of indicator on the columns 
		
	loc n = 0
	foreach i in `list'{
		loc z = substr("`i'", 1, strlen("`i'") - 3)
		loc ++n 
		disp `n'
		loc lbl_`n': variable label `i'
		foreach j in `indlist'{
			ren (`j'`z') (`j'`n')
		} 
	}

	disp "`indlist'"

	keep id kk_* cc_* 
	reshape long `indlist', i(id) j(instrument)		
	ren (*_) (*)

	lab define instrument_lbl 1"`lbl_1'" 2"`lbl_2'" 3"`lbl_3'" 4"`lbl_4'" 5"`lbl_5'" 6"`lbl_6'" 7"`lbl_7'" 8"`lbl_8'" 9"`lbl_9'" 10"`lbl_10'" 11"`lbl_11'" 12"`lbl_12'" 13"`lbl_13'" 14"`lbl_14'" 15"`lbl_15'" ///
	15"`lbl_15'" 16"`lbl_16'" 17"`lbl_17'" 18"`lbl_18'" 19"`lbl_19'" 20"`lbl_20'" 21"`lbl_21'" 22"`lbl_22'" 23"`lbl_23'" 24"`lbl_24'" 25"`lbl_25'" 26"`lbl_26'" 27"`lbl_27'" 28"`lbl_28'" 29"`lbl_29'" ///
	30"`lbl_30'" 31"`lbl_31'" 32"`lbl_32'" 33"`lbl_33'" 34"`lbl_34'" 35"`lbl_35'" 36"`lbl_36'" 37"`lbl_37'" 38"`lbl_38'" 39"`lbl_39'" 40"`lbl_40'" 41"`lbl_41'" ///
	40"`lbl_30'" 41"`lbl_31'" 42"`lbl_32'" 43"`lbl_33'" 44"`lbl_34'" 45"`lbl_35'" 46"`lbl_36'" 47"`lbl_37'" 48"`lbl_38'" 49"`lbl_39'" 50"`lbl_40'" 51"`lbl_41'", replace

	lab var instrument "Fiscal instrument"
	lab val instrument instrument_lbl
	foreach y in `income'{
		loc x = substr("`y'", 1, 2)
		lab var cc_`x' "Concentration coefficient (`x')"
		lab var kk_`x' "Kakwani Index (`x')"
	}	
	drop id 
		
	 *Save and export the data
		if "`data'" != ""{
			save "`data'", replace
		}
		if "`exportfile'" != ""{
			export excel "`exportfile'", sheet("`exportsheet'") first(varl) cell(A1) sheetmodify keepcellfmt
		
		 	if "`exportsheet'" == ""{
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
