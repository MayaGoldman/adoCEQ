cap program drop vatIndirect 
program define vatIndirect
version 16.0
	syntax [, rate(real 0) exemptVar(varname) fixedVar(varname) zeroShVar(varname) ioID(varname) dataout(string)] 


**************************************************************************************
* Step 4: Calculate Indirect effects
**************************************************************************************
preserve			
		* If fixed then sectors cannot be cost-push, nor exempted. 
		replace `exemptVar' = 0 if `fixedVar' == 1
		gen cp = 1 - `fixedVar'

		* Specify the taxable sectors 
		g vatable = 1 - `fixedVar' - `exemptVar' 		//MG: VATable sectors are those that are neither exempt, nor fixed
		assert vatable >= 0 

		* Specify the average statutory VAT rate for each IO sector 

		if !inlist(`exemptVar',0,1) {
			display as error "Error: Variable `exemptVar' must be 0 or 1 only."
       		 error 459
		}

		g rate_IO = 0
		lab var rate_IO "VAT rate"
		replace rate_IO = `rate'*(1-`zeroShVar') if `exemptVar' == 0
		assert rate_IO == 0 if `exemptVar' == 1
		 
		order `ioID' `exemptVar' cp rate_IO
		keep `ioID' sector_* `fixedVar' ex_io cp rate_IO vatable
		
		vatpush sector_*, exempt(`exemptVar') costpush(cp) shock(rate_IO) vatable(vatable) gen(vatRateInd)

		duplicates list `ioID' `exemptVar' vatable cp `fixedVar', force
  		isid `ioID' `exemptVar'
		drop sector_*

		assert vatRateInd >= 0 		
		lab var vatRateInd "Indirect VAT rate"
		
		loc x = `rate'*100
		ren vatRateInd vatRateInd_`x'
		save `dataout', replace

		disp "Rates saved in dataset: `dataout'"	
restore

end 


