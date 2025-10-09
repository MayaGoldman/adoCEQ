cap program drop missingSectorMerge 
program define missingSectorMerge
version 16.0
	syntax [, misectordata(string) misectorsh(string) mivar(varname)] 

	preserve 
		* Merge in shares of exempt and zero-rated, for missing sectors 
		import excel using "`misectordata'", sheet("`misectorsh'") firstrow case(lower) clear
		keep if `mivar' == 1
		drop `mivar'
		tempfile missingSectors 
		save `missingSectors'
	restore 

		append using `missingSectors'
		sort sectorcode

end
