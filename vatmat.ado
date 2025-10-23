*! vatmat v1
* Juan Pablo Baquero - WBG - Equity Policy Lab
* Daniel Valderrama - WBG - Equity Policy Lab
* Maya Goldman - WBG - Equity Policy Lab

*mata: mata clear 
cap prog drop vatmat
cap set matastrict off
program define vatmat, rclass
	version 16
	#delimit ;
	syntax varlist (min=2 numeric) [if] [in], 
		EXEMpt(varlist max=1 numeric)
		PEXEMpt(varlist max=1 numeric)
		PZERO(varlist max=1 numeric)
		SECTor(varlist max=1 numeric)
		FIX(varname max = 1 numeric)
		;
	#delimit cr		

	marksample touse
	keep if `touse'

	tempfile odata 
	save `odata', replace 


	*Reading the matrix of technical coefficients 
		mata: _io=st_data(., "`varlist'","`touse'") // Store the IO in Mata: (.) returns in stata all observations,  for  sect_1, sect_2, ..., sect_14, sect_15, sect_16, (.) no conditions on the obs or rows that should be excluded
		mata: 	st_local("rows", strofreal(rows(_io)))
		mata: 	st_local("cols", strofreal(cols(_io)))
		
		if (`rows'!=`cols'){
				dis as error "Not a square matrix"
				error 345566
				exit
		}
	
	*Reading the matrix of technical coefficients 
			mata: _ve=st_data(.,"`pexempt'",.)
		
		
	* Define lists of sectors : exempted, mixed, and non-mixed sectors 
			levelsof `sector' if `exempt'!=0 , local(excluded) // List of exempted products 
			levelsof `sector' if `exempt'==1 & `pexempt'>0 & `pexempt'<1 ,  local(noncollsecs) // List of IO sectors to be expanded 
			levelsof `sector' if `pexempt'==0 | `pexempt'==1,  local(collsecs) // List of IO sectors to be expanded 
	
	dis "Program ended "
	dis "list of sectors to be expanded : `collsecs'"
	dis "list of sectors to be expanded : `noncollsecs'"
	
/* ------------------------------------
	First we extended all the sectors 
 --------------------------------------*/
	
	mata: io=_io
	mata: ve=_ve
	

	mata: n_sect = strofreal(rows(io))
	
	mata: exempt_i=J(rows(io)*2,1,0) // null vector of `n_sect' X 2
	mata: nve=J(rows(io),1,1)-ve
	mata: extended=J(rows(io)*2,rows(io)*2,0) // null square matrix of (`n_sect' X 2) 
		
	forvalues n=1(1)`rows' {
		
		mata: jj=2*`n'-1 // odd numbers 
		mata: kk=jj+1  // paid numbers 
	
		forvalues i=1(1)`rows' {
			mata: j=2*`i'-1 // odds
			mata: k=j+1   // pairs 
			
			//extended[jj::kk,j::k]=J(2,2,io[n,i])/2
			 //take original coefficient by IO and split it by nve or ve 
			mata: extended[jj::jj,j::k]=J(1,2,io[`n',`i']*ve[`n',1])
			mata: extended[kk::kk,j::k]=J(1,2,io[`n',`i']*nve[`n',1])
		
		}
		mata: exempt_i[jj,1]=1
		mata: exempt_i[kk,1]=0
	}
	mata: extended=extended,exempt_i
	mata: st_matrix("extended",extended) // saving the stata matrix into stata

	clear 
	
	svmat extended // from mata to stata : extended is 70X (35+70)
	rename extended* sector_* // index extended sectors 
	gen sector=ceil(_n/2) // label each sector with same name (ceiling name)
	order sector sector_*
	local last_row = `rows'*2+1
	rename sector_`last_row' ex_io



/* ------------------------------------
	Limit matrix expansion to sectors with exemptions 
 --------------------------------------*/


*Limiting rows 
	gen aux=.
	
	foreach ii of local  collsecs {
		replace  aux=1    if  sector==`ii'       // sectors that collapse 
	}
	replace aux=0 if aux==.

	preserve 
	*saving sectors who will expand 
		keep if aux==0

		tempfile nocollapse
		save `nocollapse'

	restore 
	
	*Collapsing sectors that will not need disaggregation (either 0 or 100% exempt)
	keep if aux==1    // sectors that will not expand
	
	collapse (sum) sector_*  , by(sector)
	
	*Adding sectors which have been disaggregated 
	append using `nocollapse' //
	sort sector ex_io 
	drop aux 
	

*Limiting columns 
	foreach var of local collsecs { // collsecs is columns that do not expand so any pair column from collsecs will be eliminated 
		local ii =  `var'*2
		drop sector_`ii'
	}

	rename sector `sector'

*Renaming sectors 
	merge m:1 `sector' using `odata', assert(master matched) keepusing(`exempt' `pexempt' `pzero' `fix') nogen
		//MG: We merge the zero-rated share back in, so that we can calculate the average VAT rate by IO sector 
		/* Because we are merging by sectorcode, and we have duplicated some sectors, the zero-rated share will duplicate also. 
				To fix this, I remove the zero-rated share from all exempted sectors. */
		/* We also include the fixed variable in the dataset, so that we don't have to merge this back in. */

	*gen multi_col = 1 if exempted==.
	*replace multi_col = `pexempt' if exempted==1
	*replace multi_col=1-`pexempt' if exempted==0

	replace ex_io=`exempt' if ex_io==.
	replace ex_io = 0 if `fix' == 1
	replace `pzero' = 0 if `exempt' == 1
	assert !mi(`pzero')

	local i = 1
	foreach var of varlist sector_*{
		*local factor = multi_col[`i']
		*replace `var' = `var'*`factor'
		if `fix'==1 in `i' local exm = "Not exempt"
		if ex_io==1 in `i' local exm = "Exempt"
		if ex_io==0 in `i' local exm = "Not exempt"
		local sect = `sector'[`i']
		label var `var' "Sector `sect' - `exm'"
		local ++i
	}

	drop `exempt' `pexempt' //multi_col

	duplicates list `sector' ex_io `pzero'
			  
	qui count if ex_io == 1   //MG note: the vatmat ado generates a variable called "exempted", so no need to specify this in the syntax. 
	noisily disp in red "The number of exempted IO sectors is now `r(N)'"
		
	qui count if `pzero' > 0   //MG note: the vatmat ado generates a variable called "exempted", so no need to specify this in the syntax. 
	noisily disp in red "The number of IO sectors with some zero-rating is `r(N)'"

	qui count 
	noisily disp in red "The number of IO sectors is now `r(N)'"

end 
