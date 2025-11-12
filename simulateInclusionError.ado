cap program drop simulateInclusionError 
program define simulateInclusionError

version 16.0
	syntax [, target(real -1) basevar(varname) popweight(varname) simvar(string) income(varname) povline(varname) seed(varname) outProb(varname) inProb(varname) elig(varname) restore]

	if "`restore'" == "restore"{
			preserve 
	}

	* Eligible population (if not specified, assume it is the poor)
	if "`elig'" == ""{
		g elig = (`income' < `povline')
		loc elig elig
	}

	qui sum `popweight'
	loc pop = r(sum)
	disp `pop'/1e6

	qui sum `popweight' if `elig' == 1
	loc eligPop = r(sum)
	qui sum `popweight' if `basevar' > 0
	loc ben = r(sum)
	qui sum `popweight' if `elig' == 0 & `basevar' > 0  //not eligible, but included 
	loc nonEligPopIncl = r(sum)
	qui sum `popweight' if `elig' == 1 & `basevar' == 0 //eligible, but not included
	loc eligPopExcl = r(sum)

* Errors
	loc errorIn = `nonEligPopIncl' //10.3
	disp "The population of non-eligible recipients is (mil): "`errorIn'/1e6 
	*disp "The population of non-poor receiving the grant is: "`nonPoorPopIncl'/1e6
	*disp "The population of beneficiaries is: "`ben'/1e6
	
	loc errorEx = `eligPopExcl'  //11.0 mil 
	disp "The population of eligible non-recipients is (mil): "`errorEx'/1e6
	*disp "The population of poor, not receiving the grant is: "`poorPopExcl'/1e6
	*disp "The population of poor is: "`poor'/1e6
	

* Specify inclusion error level 
	if `target' < 0{
		loc targetErrorIn = `nonEligPopIncl'/`ben'
		disp "No target specified, using existing inclusion error levels"
	}
 	else if `target' >= 0{
 		loc targetErrorIn = "`target'" //decreased from 12.5%
 	}
 	disp in red "Target inclusion error is (%): "`targetErrorIn'*100
	assert `targetErrorIn' <= `errorIn' & `targetErrorIn' >= 0 & `targetErrorIn' < 1

	loc targetPopErrIn = `targetErrorIn'*`ben'
	disp "Target number of non-eligible included is (mil): "`targetPopErrIn'/1e6  //13.5 mil non-poor beneficiaries
	disp `pop'/1e6

	loc popChange = `nonEligPopIncl' - `targetPopErrIn'
	disp "Required change in non-eligible inclusions is (mil): "`popChange'/1e6  //0.3 mil 



* Drop ineligible households until I reach 11.8 million, using : 
	clonevar `simvar' = `basevar'
	gsort -`basevar' `elig' `inProb' `seed'  //order eligible households from highest probability of exclusion to highest
	g wsum = sum(`popweight')
	replace `simvar' = 0 if wsum < `popChange'
	drop wsum

* Randomly include poor households until I reach 
	gsort `basevar' -`elig' -`outProb' `seed' //order eligible households from highest probability of inclusion to lowest
	g wsum = sum(`popweight')
	replace `simvar' = 1 if wsum < `popChange'
	drop wsum

	qui sum `popweight' if `elig' == 0 & `simvar' == 1
	loc nonEligPopIncl_new = r(sum)
	disp `nonEligPopIncl_new'/1e6

	qui sum `popweight' if `elig' == 1 & `simvar' == 0
	loc eligPopExcl_new = r(sum)
	disp `eligPopExcl_new'/1e6

	disp in red "Old inclusion Error (% of benef.): "round(`nonEligPopIncl'/`ben'*100,.1) //12.5%
	disp in red "Old exclusion Error (% of the poor pop.): "round(`eligPopExcl'/`elig'*100,.1) //7.6%
	disp in red "New inclusion error (% of the benef.): "round(`nonEligPopIncl_new'/`ben'*100,.1) //10.5%
	disp in red "New exclusion error (% of the poor pop.): "round(`eligPopExcl_new'/`elig'*100,.1) //5.5% 

	if "`restore'" == "restore"{
		restore
	}
end


