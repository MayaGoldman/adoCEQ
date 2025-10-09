{smcl}
{* *! version 1.0.0 09oct2025}
{title:ioShares — Calculates the share of each IO sector that is exempt, or zero-rated.}

{phang}
{cmd:ioShares} , {it:purchases(varname) exemptsh(varname) zerosh(varname) fix(varname) ioID(varname) hhweight(varname) dataout(string)}

{title:Description}
{phang}
Calculates the share of each IO sector that is exempt, or zero-rated, and saves the hh-dataset (before collapsing to the IO level) according to the name specified, for use later in the code. 

{title:Inputs} - a purchases variable; a variable that specifies whether an item is exempt, zero-rated, or fixed; an IO sector identifier, household weights, and a dataset file path and name (can be temporary or permanent). 

{phang}
{opt purchases(varname)} — Specify the variable which stores the value of purchases, by item, by household. 

{phang}
{opt exemptsh(varname)} — Specify the variable which stores whether an item is exempt (=1), partially exempt (>0 and <1) or not exempt (=0).

{phang}
{opt zerosh(varname)} — Specify the variable which stores whether an item is zero-rated (=1), partially zero-rated (>0 and <1) or not zero-rated (=0).

{phang}
{opt fix(varname)} — Specify the variable which stores whether an item is price-regulated (=1) or not (=0).

{phang}
{opt ioID(varname)} — Specify the variable which identifies the IO sector that the item is linked to. 

{phang}
{opt hhweight(varname)} — Household weights. 

{phang}
{opt dataout(string)} — Specify the file-path and name to save the household-level dataset. 

{title:Examples}
{phang}
	{cmd:.ioShares, purchases(purc) exemptsh(ex_item) zerosh(zx_item) ioID(sector) hhweight(wert) dataout("${tmp}\sim${sim}_vat_rate_dir_hh_new.dta")}
	

{title:Author}
{phang}
Maya Goldman: World Bank (mgoldman@worldbank.org)
{phang}