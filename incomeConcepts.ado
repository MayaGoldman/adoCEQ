cap prog drop incomeConcepts 
prog def incomeConcepts

	version 16.0
	syntax [, aggregate(varname) transfersincluded(string) incometype(string) annualizefactor(integer 1) scaler(varname) suffix(string) oldsuffix(string) newsuffix(string) dtxlist(varlist) penlist(varlist) conlist(varlist) dtrlist(varlist) sublist(varlist) itxlist(varlist) edulist(varlist) hltlist(varlist) edufeelist(varlist) hltfeelist(varlist) extravarlist(varlist) globals] 


	loc fisclist `penlist' `conlist' `dtrlist' `dtxlist' `itxlist' `sublist' `edulist' `hltlist' `edufeelist' `hltfeelist' `extravarlist'
	foreach v in `totlist'{
		recode `v' (.=0)
	}

* Make sure the results are annual
	loc f = "`annualizefactor'"
	disp `f'

	if `f' != 1{
		foreach v in `totlist'{
			replace `v' = `v'*`f'
		}
		disp in red "{Variables are now annual}"
	}

* Generate the totals for each category

	if "`scaler'" == ""{
		loc o "`suffix'"
		disp "`o'"
	}
	else if "`scaler'" != ""{		
		loc n "`newsuffix'"
		disp "`n'"
		loc o "`oldsuffix'"
		disp "`o'"
	} 

		if "`penlist'" != ""{
			cap confirm variable pen_`o'
			local num_unique = wordcount("`penlist'")
			if _rc == 0 & "`penlist'" != "pen_`o'"{
				drop pen_`o'
			}
			if "`penlist'" != "pen_`o'"{
				egen pen_`o' = rowtotal(`penlist')
			}
		}
		else{
			g pen_`o' = 0
		}
		loc totlist `totlist' pen_`o'
		if "`conlist'" != ""{
			cap confirm variable con_`o'
			local num_unique = wordcount("`conlist'")
			if _rc == 0 & "`conlist'" != "con_`o'"{
				drop con_`o'
			}
			if "`conlist'" != "con_`o'"{
				egen con_`o' = rowtotal(`conlist')
			}
		}
		else{
			g con_`o' = 0
		}
		loc totlist `totlist' con_`o' 

		if "`dtrlist'" != ""{
			cap confirm variable dtr_`o'
			local num_unique = wordcount("`dtrlist'")
			if _rc == 0 & "`dtrlist'" != "dtr_`o'"{
				drop dtr_`o'
			}
			if "`dtrlist'" != "dtr_`o'"{
				egen dtr_`o' = rowtotal(`dtrlist')
			}
		}
		else{
			g dtr_`o' = 0
		}
		loc totlist `totlist' dtr_`o' 

		if "`dtxlist'" != ""{
			cap confirm variable dtx_`o'
			local num_unique = wordcount("`dtxlist'")
			if _rc == 0 & "`dtxlist'" != "dtx_`o'"{
				drop dtx_`o'
			}
			if "`dtxlist'" != "dtx_`o'"{
				egen dtx_`o' = rowtotal(`dtxlist')
			}
		}
		else{
			g dtx_`o' = 0
		}
		loc totlist `totlist' dtx_`o' 

		if "`itxlist'" != ""{
			cap confirm variable itx_`o'
			local num_unique = wordcount("`itxlist'")
			if _rc == 0 & "`itxlist'" != "itx_`o'"{
				drop itx_`o'
			}
			if "`itxlist'" != "itx_`o'"{
				egen itx_`o' = rowtotal(`itxlist')
			}
		}
		loc totlist `totlist' itx_`o' 
		else{
			g itx_`o' = 0
		}
		if "`sublist'" != ""{
			cap confirm variable sub_`o'
			local num_unique = wordcount("`sublist'")
			if _rc == 0 & "`sublist'" != "sub_`o'"{
				drop sub_`o'
			}
			if "`sublist'" != "sub_`o'"{
				egen sub_`o' = rowtotal(`sublist')
			}
			
		}
		else{
			g sub_`o' = 0
		}
		loc totlist `totlist' sub_`o' 
		if "`edulist'" != ""{
			cap confirm variable edu_`o'
			local num_unique = wordcount("`edulist'")
			if _rc == 0 & "`edulist'" != "edu_`o'"{
				drop edu_`o'
			}
			if "`edulist'" != "edu_`o'"{
				egen edu_`o' = rowtotal(`edulist')
			}
		}
		else{
			g edu_`o' = 0
		}
		loc totlist `totlist' edu_`o'
		if "`hltlist'" != ""{
			cap confirm variable hlt_`o'
			local num_unique = wordcount("`hltlist'")
			if _rc == 0 & "`hltlist'" != "hlt_`o'"{
				drop hlt_`o'
			}
			if "`hltlist'" != "hlt_`o'"{
				egen hlt_`o' = rowtotal(`hltlist')
			}
		}
		else{
			g hlt_`o' = 0
		}
		loc totlist `totlist' hlt_`o' 
		if "`edufeelist'" != ""{
			cap confirm variable fee_educ_`o'
			local num_unique = wordcount("`edufeelist'")
			if _rc == 0 if "`edufeelist'" != "fee_educ_`o'"{
				drop fee_educ_`o'
			}
			if "`edufeelist'" != "fee_educ_`o'"{
				egen fee_educ_`o' = rowtotal(`edufeelist')
			} 
		}
		else{
			g fee_educ_`o' = 0
		}
		loc totlist `totlist' fee_educ_`o'
		if "`hltfeelist'" != ""{
			cap confirm variable fee_hlth_`o'
			local num_unique = wordcount("`hltfeelist'")
			if _rc == 0 if "`hltfeelist'" != "fee_hlth_`o'"{
				drop fee_hlth_`o'
			}
			if "`hltfeelist'" != "fee_hlth_`o'"{
				egen fee_hlth_`o' = rowtotal(`hltfeelist')
			} 
		}
		else{
			g fee_hlth_`o' = 0
		}
		loc totlist `totlist' fee_hlth_`o' 
		if "`extravarlist'" != ""{
			cap confirm variable ext_`o'
			if _rc == 0{
				drop ext_`o'
			}
			egen ext_`o' = rowtotal(`extravarlist')
		}
		else{
			g ext_`o' = 0
		}
		loc totlist `totlist' ext_`o' 
		disp "`fisclist'"
		disp "`totlist'"

*  Scale variables 
	if "`scaler'" == ""{
		disp in red "{No scaler variable is supplied. Assuming that variables supplied are already scaled.}"
		loc n "`scalesuffix'"
		disp "`n'"
	}
	else if "`scaler'" != ""{
		disp in red "{Scaler variable was supplied. Dividing by `scaler'.}"
		foreach v in `aggregate' `fisclist' `totlist'{
			cap drop `v'_`n' 
			g `v'_`n' = `v'/`scaler'

			* Label the new variables 
			local lbl : variable label `v'
			lab var `v'_`n' "`lbl'"
		}	
	}


* Calculate the income concepts 
	if "`transfersincluded'" == "yes" & "`incometype'" == "net"{
		disp in red "{Working backwards from Disposable income}"
		cap confirm variable yd_`n'
		if _rc == 0{
			drop yd_`n' yd_`o'
		}
		g yd_`n' = `aggregate'_`n'
		g yn_`n' 	= yd_`n' - dtr_`o'_`n' 
		replace yn_`n' = 0 if yn_`n' <= 0
		g yg_`n' 	= yd_`n' + dtx_`o'_`n' 
		g yp_`n' 	= yn_`n' + dtx_`o'_`n' // pension income is already included in yd, so no need to add it here? Pension contributions are not yet subtracted off. 
		g ym_`n' 	= yp_`n' - pen_`o'_`n'
		replace ym_`n' = 0 if ym_`n' <= 0
		cap drop yd_`o'_`n'
	}
	else if "`transfersincluded'" == "yes" & "`incometype'" == "gross"{ 
		disp in red "{Working backwards from Gross income}"
		cap confirm variable yg_`n'
		if _rc == 0{ //if no error, then the variable exists, so drop it. 
			drop yg_`n'
		}
		g yg_`n' = `aggregate'_`n'
		g yd_`n' = yg_`n' - dtx_`o'_`n'
		replace yd_`n' = 0 if yd_`n' < 0
		g yn_`n' 	= yd_`n' - dtr_`o'_`n' 
		replace yn_`n' = 0 if yn_`n' <= 0
		g yp_`n' 	= yn_`n' + dtx_`o'_`n' // pension income is already included in yd, so no need to add it here? Pension contributions are not yet subtracted off. 
		g ym_`n' 	= yp_`n' - pen_`o'_`n'
		replace ym_`n' = 0 if ym_`n' <= 0
		cap drop yg_`o'_`n'
	}
	else if "`transfersincluded'" == "no" & "`incometype'" == "gross"{ 
		disp in red "{Working backwards from Market income + pensions}"
		cap confirm variable yp_`n'
		if _rc == 0{ //if no error, then the variable exists, so drop it. 
			drop yp_`n'
		}
		g yp_`n' = `aggregate'_`n'
		g ym_`n' 	= yp_`n' - pen_`o'_`n'
		replace ym_`n' = 0 if ym_`n' <= 0
		
		g yn_`n' 	= yp_`n' - dtx_`o'_`n' 
		replace yn_`n' = 0 if yn_`n' <= 0
		g yg_`n' 	= yp_`n' + dtr_`o'_`n'
		
		g yd_`n' = yg_`n' - dtx_`o'_`n'
		replace yd_`n' = 0 if yd_`n' < 0

		cap drop yp_`o'_`n'
	}
	else if "`transfersincluded'" == "no" & "`incometype'" == "net"{ 
		disp in red "{Working backwards from Net market income}"
		cap confirm variable yp_`n'
		if _rc == 0{ //if no error, then the variable exists, so drop it. 
			drop yp_`n'
		}
		g yn_`n' = `aggregate'_`n'
		g yp_`n' 	= yn_`n' + dtx_`o'_`n'
		g ym_`n' 	= yp_`n' - pen_`o'_`n'
		replace ym_`n' = 0 if ym_`n' <= 0
	
		g yg_`n' 	= yp_`n' + dtr_`o'_`n'
	
		g yd_`n' = yg_`n' - dtx_`o'_`n'
		replace yd_`n' = 0 if yd_`n' < 0

		cap drop yn_`o'_`n'
	}

	disp in red "{Working forwards from Disposable income}"
		g ynd_`n' = yd_`n' - itx_`o'_`n'
		replace ynd_`n' = 0 if ynd_`n' <= 0
		g ygd_`n' = yd_`n' + sub_`o'_`n' 
		g yc_`n' 	= ynd_`n' + sub_`o'_`n'
		g yf_`n' 	= yc_`n' + edu_`o'_`n' + hlt_`o'_`n' - fee_educ_`o'_`n' - fee_hlth_`o'_`n'
		replace yf_`n' = 0 if yf_`n' <= 0 


* Chnage the suffix
	ren (*_`o'_`n') (*_`n')	
	
	g net_cash_`n' = dtr_`n' - dtx_`n' - itx_`n' + sub_`n' 
	g net_totl_`n' = net_cash_`n' + edu_`n' - fee_educ_`n' + hlt_`n' - fee_hlth_`n' 

	loc newvarlist
	foreach v of varlist `aggregate' *_`n'{
		loc newvarlist `newvarlist' `v'
	}
	disp "`newvarlist'"

	cap lab var yd_`n'				"Disposable income"
	cap lab var yn_`n'				"Net market income" 
	cap lab var yg_`n'				"Gross income"
	cap lab var yp_`n'				"Prefiscal income" 
	cap lab var ym_`n'				"Market income" 
	cap lab var ynd_`n'				"Net disposable income"
	cap lab var ygd_`n'				"Gross disposable income" 
	cap lab var yc_`n'				"Consumable income" 
	cap lab var yf_`n'				"Final income"
	
	cap lab var pen_`n'      		"Pension income"
	cap lab var con_`n'      		"Contributions to pensions"
	cap lab var dtr_`n'  			"Direct transfers"
	cap lab var dtx_`n'  			"Direct taxes"
	cap lab var itx_`n'  			"Indirect taxes"
	cap lab var sub_`n'  			"Indirect subsidies"
	cap lab var edu_`n' 			"Educ. benefits"
	cap lab var hlt_`n' 			"Health benefits"
	cap lab var fee_educ_`n' 		"Educ. co-pays"
	cap lab var fee_hlth_`n' 		"Health co-pays"

	cap lab var net_totl_`n'			"Net total benefit"
	cap lab var net_cash_`n'			"Net cash benefit"

if "`globals'" == "globals"{
	global inclist ym_pc yp_pc yn_pc yg_pc yd_pc ynd_pc yc_pc yf_pc 
	local newlist ""
	foreach v in `penlist'{
		local base = subinstr("`v'", "_hh", "", .)
		local newlist "`newlist' `base'_pc"
		global penlist `newlist'
	}
	local newlist ""
	foreach v in `conlist'{
		local base = subinstr("`v'", "_hh", "", .)
		local newlist "`newlist' `base'_pc"
		global conlist `newlist'
	}
	local newlist ""
	foreach v in `dtrlist'{
		local base = subinstr("`v'", "_hh", "", .)
		local newlist "`newlist' `base'_pc"
		global dtrlist `newlist'
	}
	local newlist ""
	foreach v in `dtxlist'{
		local base = subinstr("`v'", "_hh", "", .)
		local newlist "`newlist' `base'_pc"
		global dtxlist `newlist'
	}
	local newlist ""
	foreach v in `itxlist'{
		local base = subinstr("`v'", "_hh", "", .)
		local newlist "`newlist' `base'_pc"
		global itxlist `newlist'
	}
	local newlist ""
	foreach v in `sublist'{
		local base = subinstr("`v'", "_hh", "", .)
		local newlist "`newlist' `base'_pc"
		global sublist `newlist'
	}
	local newlist ""
	foreach v in `edulist'{
		local base = subinstr("`v'", "_hh", "", .)
		local newlist "`newlist' `base'_pc"
		global edulist `newlist'
	}
	local newlist ""
	foreach v in `hltlist'{
		local base = subinstr("`v'", "_hh", "", .)
		local newlist "`newlist' `base'_pc"
		global hltlist `newlist'
	}
	local newlist ""
	foreach v in `edufeelist'{
		local base = subinstr("`v'", "_hh", "", .)
		local newlist "`newlist' `base'_pc"
		global edufeelist `newlist'
	}
	local newlist ""
	foreach v in `hltfeelist'{
		local base = subinstr("`v'", "_hh", "", .)
		local newlist "`newlist' `base'_pc"
		global hltfeelist `newlist'
	}
	local newlist ""
	foreach v in `extravarlist'{
		local base = subinstr("`v'", "_hh", "", .)
		local newlist "`newlist' `base'_pc"
		global extravarlist `newlist'
	}
	disp in red "Globals saved."

	disp "$inclist"
 	disp "$penlist"
 	disp "$conlist"
 	disp "$dtxlist"
 	disp "$dtrlist"
 	disp "$itxlist"
 	disp "$sublist"
 	disp "$edulist"
 	disp "$hltlist"
 	disp "$edufeelist"
 	disp "$hltfeelist"
 	disp "$extravarlist"
}

end 
