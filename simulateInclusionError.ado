cap program drop simulateInclusionError 
program define simulateInclusionError

version 16.0
	syntax [, target(real -1) basevar(varname) popweight(varname) simvar(string) income(varname) povline(varname) seed(varname) outProb(varname) inProb(varname)  restore]

	if "`restore'" == "restore"{
			preserve 
	}

	* Poor population 
	g poor = (`income' < `povline')
	g rich = (`income' >= `povline')

	qui sum `popweight'
	loc pop = r(sum)
	disp `pop'/1e6

	qui sum `popweight' if poor == 1
	loc poor = r(sum)
	qui sum `popweight' if `basevar' > 0
	loc ben = r(sum)
	qui sum `popweight' if poor == 0 & `basevar' > 0
	loc nonPoorPopIncl = r(sum)
	qui sum `popweight' if poor == 1 & `basevar' == 0
	loc poorPopExcl = r(sum)

* Errors
	loc errorIn = `nonPoorPopIncl' //10.3
	disp "The population of non-poor included is (mil): "`errorIn'/1e6 
	*disp "The population of non-poor receiving the grant is: "`nonPoorPopIncl'/1e6
	*disp "The population of beneficiaries is: "`ben'/1e6
	
	loc errorEx = `poorPopExcl'  //11.0 mil 
	disp "The population of poor excluded is (mil): "`errorEx'/1e6
	*disp "The population of poor, not receiving the grant is: "`poorPopExcl'/1e6
	*disp "The population of poor is: "`poor'/1e6
	

* Specify inclusion error level 
	if `target' < 0{
		loc targetErrorIn = `nonPoorPopIncl'/`ben'
		disp "No target specified, using existing inclusion error levels"
	}
 	else if `target' >= 0{
 		loc targetErrorIn = "`target'" //decreased from 12.5%
 	}
 	disp in red "Target inclusion error is (%): "`targetErrorIn'*100
	assert `targetErrorIn' <= `errorIn' & `targetErrorIn' >= 0 & `targetErrorIn' < 1

	loc targetPopErrIn = `targetErrorIn'*`ben'
	disp "Target number of non-poor included is (mil): "`targetPopErrIn'/1e6  //13.5 mil non-poor beneficiaries
	disp `pop'/1e6

	loc popChange = `nonPoorPopIncl' - `targetPopErrIn'
	disp "Required change in non-poor inclusions is (mil): "`popChange'/1e6  //0.3 mil 



* Randomly drop rich households until I reach 11.8 million : 
	clonevar `simvar' = `basevar'
	gsort -`basevar' -rich `inProb' `seed'  //order rich households from lowest probability of inclusion to highest
	g wsum = sum(`popweight')
	replace `simvar' = 0 if wsum < `popChange'
	drop wsum

* Randomly include poor households until I reach 
	gsort `basevar' -poor -`outProb' `seed' //order poor households from highest probability of inclusion to lowest
	g wsum = sum(`popweight')
	replace `simvar' = 1 if wsum < `popChange'
	drop wsum

	qui sum `popweight' if rich == 1 & `simvar' == 1
	loc nonPoorPopIncl_new = r(sum)
	disp `nonPoorPopIncl_new'/1e6

	qui sum `popweight' if poor == 1 & `simvar' == 0
	loc poorPopExcl_new = r(sum)
	disp `poorPopExcl_new'/1e6

	drop poor rich `seed'

	disp in red "Old inclusion Error (% of benef.): "round(`nonPoorPopIncl'/`ben'*100,.1) //12.5%
	disp in red "Old exclusion Error (% of the poor pop.): "round(`poorPopExcl'/`poor'*100,.1) //7.6%
	disp in red "New inclusion error (% of the benef.): "round(`nonPoorPopIncl_new'/`ben'*100,.1) //10.5%
	disp in red "New exclusion error (% of the poor pop.): "round(`poorPopExcl_new'/`poor'*100,.1) //5.5% 

	if "`restore'" == "restore"{
		restore
	}
end


