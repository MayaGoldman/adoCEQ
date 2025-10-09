{smcl}
{* *! version 1.0.0 09oct2025}
{title:vatIndirect — Calculates the indirect VAT rates, by IO sector.}

{phang}
{cmd:vatIndirect} , {it:rate(real 0) exemptVar(varname) fixedVar(varname) zeroShVar(varname) ioID(varname) dataout(string)}

{title:Description}
{phang}
Calculates the share of each IO sector that is exempt, or zero-rated, and saves the hh-dataset (before collapsing to the IO level) according to the name specified, for use later in the code. 

{title:Inputs} - a variable that specifies whether a sector is exempt, or fixed, or the share of the sector that is zero-rated; an IO sector identifier, and an output dataset file path and name (can be temporary or permanent). 

{phang}
{opt rate(varname)} — the statutory VAT rate for each sector.

{phang}
{opt exemptVar(varname)} — whether a sector is exempt (=1) or not exempt (=0).

{phang}
{opt fixedVar(varname)} — whether a sector is fixed (=1) or not (=0).

{phang}
{opt zeroShVar(varname)} — whether a sector is zero-rated (=1), partially zero-rated (>0 and <1) or not zero-rated (=0).

{phang}
{opt ioID(varname)} — identifies the IO sector. 

{phang}
{opt dataout(string)} — Specify the file-path and name to save the household-level dataset. 

{title:Examples}
{phang}
	{cmd:. vatIndirect, rate(0.10) exemptVar(ex_io) zeroShVar(zx_iosh) fixedVar(fixed) ioID(sector) dataout(`indirectVAT_10')}

{phang}
	{cmd:. vatIndirect, rate(0.11) exemptVar(ex_io) zeroShVar(zx_iosh) fixedVar(fixed) ioID(sector) dataout(`indirectVAT_11')} 

{phang}
	{cmd:. vatIndirect, rate(0.12) exemptVar(ex_io) zeroShVar(zx_iosh) fixedVar(fixed) ioID(sector) dataout(`indirectVAT_12')} 

{title:Author}
{phang}
Maya Goldman: World Bank (mgoldman@worldbank.org)
{phang}