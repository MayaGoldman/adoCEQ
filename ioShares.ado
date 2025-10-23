cap program drop ioShares 
program define ioShares
version 16.0
	syntax [, purchases(varname) exemptsh(varname) zerosh(varname) fix(varname) ioID(varname) hhweight(varname) drop missing] 

************************************************************************************** 
* Step 1: Calculate shares (standard, exempt etc.), by IO sector
**************************************************************************************
	//Inputs: variables that specify which items are exempt, zero-rated etc. 
	//Method: Based on survey consumption 	
		
	* Determine the weighted share of exempted and zero-rated goods in each sector based on the shares of consumption of each type of good in the household survey 
		* Save dataset for merging down below 
		g ex_purc = `purchases'*`exemptsh' 	//exempted purchases
		g nx_purc = `purchases'*(1-`exemptsh') // non-exempted purchases
		g zx_purc = `purchases'*`zerosh' 	//zero-rated purchases

		*** Checks
			assert  !mi(ex_purc) & !mi(nx_purc) 
			tempvar sum
			egen `sum' = rowtotal(nx_purc ex_purc)
			replace `sum' = `purchases' if `sum' <= 1.0001*`purchases' & `sum' >= 0.9999*`purchases'
			assert `sum' == `purchases' 
		***
		drop __000*

	* Collapse to calculate exempted and zero-rated shares at the IO sector level 

		keep `purchases' ex_purc nx_purc zx_purc `hhweight' `ioID' `fix'
		collapse (sum) `purchases' ex_purc nx_purc zx_purc [pw = `hhweight'], by(`ioID' `fix')  //collapse to the IO level

		lab var purc "Purchases"
		lab var ex_purc "Exempt purchases"
		lab var nx_purc "Non-exempt (TAXABLE) purchases"
		lab var zx_purc "Zero-rated purchases" 

		g ex_iosh = 0 
		replace ex_iosh = ex_purc/`purchases' 		if `purchases' > 0 & ex_purc > 0										//exempted share
		
		g nx_iosh = 0 
		replace nx_iosh = nx_purc/`purchases' 		if `purchases' > 0 & nx_purc > 0
		replace  nx_iosh = 1 if `purchases' == 0 										// sector 50 is standard-rated, even though there are no purchases of these items 

		g zx_iosh = 0 
		replace zx_iosh = zx_purc/nx_purc 		if nx_purc > 0 & zx_purc > 0

		lab var ex_iosh "Exempt share of purchases (by IO sector)"
		lab var nx_iosh "Non-exempt share of purchases (by IO sector)"
		lab var zx_iosh "Zero-rated share of TAXABLE purchases (by IO sector)" //we calculate this as a share of TAXABLE purchases, because we are going to split out the exempt and non-exempt sectors when we augment
		
		assert !mi(ex_iosh) & !mi(nx_iosh) & !mi(zx_iosh) 

		*** Checks
			tempvar sum
			egen `sum' = rowtotal(ex_iosh nx_iosh)
			replace `sum' = 1 if `sum' > 0.99999999  //eliminate rounding error
			assert `sum' == 1 
			assert !mi(nx_iosh) & !mi(ex_iosh) 
		***


if "`missing'" == "missing"{
	* Add in placeholders for missing sectors (these are needed for the indirect VAT rates to be accurately calculated)
	qui sum sector 
	loc max = r(max)
	disp `max'
	cap drop missingSector
	g missingSector = 0 
	forval i = 1/`max'{
		disp in red "Sector `i'"
		count if sector == `i'
		loc IOcount = r(N)
		disp `IOcount'
		if `IOcount' == 0{
			disp in red "Sector `i' is missing"
			expand 2 in l, gen(missingSector`i')  
			replace sector = `i' if missingSector`i' == 1
			replace missingSector = 1 if missingSector`i' == 1
			cap drop missingSector`i'
		}
	}
	foreach var in ex_purc zx_purc nx_purc purc{
		replace `var' = 0 if missingSector == 1 & `var' != 0  
	}
}

if "`drop'" == "drop"{
	drop ex_purc nx_purc zx_purc
}
	
end

