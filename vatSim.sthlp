{smcl}
{* *! version 1.0.0 09oct2025}
{title:vatSim — Calculates VAT rates.}

{phang}
{cmd:vatSim} , {it: hhid(varname) hhweight(varname) itemID(varname) purchases(varname) exemptItem(varname) bDir(varname) dir(varname) bInd(varname) ind(varname) rate(real 0) infShare(varname)  dataout(string) collapse}

{title:Description}
{phang}
Calculates the share of each IO sector that is exempt, or zero-rated, and saves the hh-dataset (before collapsing to the IO level) according to the name specified, for use later in the code. 

{title:Inputs} - a purchases variable; a variable that specifies whether an item is exempt, zero-rated, or fixed; an IO sector identifier, household weights, and a dataset file path and name (can be temporary or permanent). 

{phang}
{opt hhid(varname)} — Household ID. 

{phang}
{opt hhweight(varname)} — Household weights. 

{phang}
{opt itemID(varname)} — Item code. 

{phang}
{opt purchases(varname)} — value of purchases, by item, by household. 

{phang}
{opt exemptItem(varname)} — an item is exempt (=1), partially exempt (>0 and <1) or not exempt (=0).

{phang}
{opt zerosh(varname)} — an item is zero-rated (=1), partially zero-rated (>0 and <1) or not zero-rated (=0).

{phang}
{opt infShare(varname)} — share of consumption that is informal (by item-decile).

{phang}
{opt bDir(varname)} — BASELINE direct VAT rate per item (differs from the statutory rate because of exemptions and zero-ratings). If not specified, default is to assume that bDir = dir. 

{phang}
{opt dir(varname)} — SIMULATION direct VAT rate per item (differs from the statutory rate because of exemptions and zero-ratings). 

{phang}
{opt bInd(varname)} — BASELINE indirect VAT rate per IO sector. If not specified, default is to assume that bInd = ind. 

{phang}
{opt ind(varname)} — SIMULATION indirect VAT rate per IO sector. 

{phang}
{opt dataout(string)} — Specify the file-path and name to save the household-level dataset. 

{phang}
{opt collapse} — Specify if you wish to collapse the dataset to the household level. 

{title:Examples}
{phang}
	{cmd:.ioShares, purchases(purc) exemptsh(ex_item) zerosh(zx_item) ioID(sector) hhweight(wert) dataout("${tmp}\sim${sim}_vat_rate_dir_hh_new.dta")}
	

{title:Author}
{phang}
Maya Goldman: World Bank (mgoldman@worldbank.org)
{phang}