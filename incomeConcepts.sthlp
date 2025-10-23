{smcl}
{* *! version 1.0.0 09oct2025}
{title:incomeConcepts.ado — Calculates CEQ income concepts.}

{phang}
{cmd:incomeConcepts.ado} , {it: aggregate(varname) transfersincluded(string) incometype(string) annualizefactor(integer 1) scaler(varname) suffix(string) oldsuffix(string) newsuffix(string) dtxlist(varlist) penlist(varlist) conlist(varlist) dtrlist(varlist) sublist(varlist) itxlist(varlist) edulist(varlist) hltlist(varlist) edufeelist(varlist) hltfeelist(varlist) extravarlist(varlist) globals}

{title:Description}
{phang}
Calculates the CEQ income concepts. 

{title:Options} 

{phang}
{opt aggregate(varname)} — the official income / consumption aggregate. 

{phang}
{opt transfersincluded(string)} — are transfers already included in the income aggregate? Possible responses are "yes" or "no".

{phang}
{opt incometype(string)} — is the aggregate gross or net of direct taxes? Possible responses are "gross" or "net".

{phang}
{opt annualizefactor(integer 1)} — specify a factor for annualising the data (if necessary). Default value is 1 (i.e. no annualisation). 

{phang}
{opt scaler(varname)} — specify a scaler, if needed (for example, to transform variables from household to per capita, specificy the household size variable).

{phang}
{opt suffix(varname)} — specify the variable suffix, if no scaler is specified. If a scaler is specified, then fill in the "oldsuffix" and "newsuffix" fields instead.

{phang}
{opt oldsuffix(varname)} — specify the existing variable suffix, if a scaler is specified. A newsuffix must also be specified, as the old suffix will be transformed to the new suffix, to make the scaling change clear. 

{phang}
{opt newsuffix(varname)} — specify the desired new variable suffix, if a scaler is specified. An oldsuffix must also be specified, as the old suffix will be transformed to the new suffix, to make the scaling change clear.    

{phang}
{opt penlist(string)} — specify the list of pension variables. 

{phang}
{opt conlist(string)} — specify the list of pension contribution variables. 

{phang}
{opt dtrlist(string)} — specify the list of direct transfer variables. 

{phang}
{opt dtxlist(string)} — specify the list of direct tax variables.  

{phang}
{opt sublist(string)} — specify the list of indirect subsidy variables.  

{phang}
{opt itxlist(string)} — specify the list of indirect tax variables.  

{phang}
{opt edulist(string)} — specify the list of public education benefit variables. If co-payment variables are included, then these variables should be GROSS of co-payments.  

{phang}
{opt hltlist(string)} — specify the list of public health benefit variables. If co-payment variables are included, then these variables should be GROSS of co-payments. 

{phang}
{opt edufeelist(string)} — specify the list of public education co-payment variables.  

{phang}
{opt hltfeelist(string)} — specify the list of public health co-payment variables.  

{phang}
{opt extravarlist(string)} — specify the list of additional variables that you want annualised, and scaled, but which are not used in the calculation of the income concepts. 

{phang}
{opt globals} — if specified, then the instrument lists (with the new suffixes) will be saved as globals for use later in the code.

{title:Examples}
{phang}
	{cmd:.incomeConcepts yd_hh, scaler(hhsize) oldscalesuffix(hh) newscalesuffix(pc) aggregate(consumption) transfersincluded(yes) incometype(net) annualizefactor(12) penlist($penlist) conlist($conlist) dtrlist($dtrlist) dtxlist($dtxlist) itxlist($itxlist) sublist($sublist) edulist($edulist) hltlist($hltlist) edufeelist($feeeduclist) hltfeelist($feehlthlist) extravarlist($extravarlist) globals}
	

{title:Author}
{phang}
Maya Goldman: World Bank (mgoldman@worldbank.org)
{phang}