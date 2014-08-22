{smcl}
{* *! version 1 10may2011}{...}
{pstd}
{cmd:cfby} has been superseded by the SSC program {cmd:cfout} version 2.0.0.
{cmd:cfby} continues to run as before, but it is no longer supported.
This is the original help file, which will not be updated.


{cmd:help cfby}
{hline}

{title:Title}

    {hi:cfby} -- Compare two files to get the number differences "by" a common variable

{title:Syntax}

{p 8 17 2}
{cmdab:cfby}
[{varlist}]
{cmd: using} {it: filename}
{cmd:, id}({varname}) [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt nop:unct}}ignores differences in punctuation and capitalization{p_end}
{synopt:{opt nomat:ch}}surpress warnings about missing observations{p_end}
{synopt:{opt u:pper}}convert all string variables to upper case before comparing{p_end}
{synopt:{opt l:ower}}convert all string variables to lower case before comparing{p_end}
{synopt:{opt nos:tring}}do not compare any string variables{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{title:Description}

{pstd}
{cmd:cfby} compares the variables in {varlist} from the dataset in memory
			to the variables in {varlist} from the using dataset and displays
			the discrepancy rates by a common variable.  It is useful if
			you are doing data entry and want to get discrepancy rates of 
			data entry officers.

{title:Options}

{phang}
{opt id(varname)} is required. {it: varname} is the variable that matches observations in
		the master dataset to observations in the using dataset.  
		It must uniquely identify observations in both the master and using datasets.

{phang}
{opt nopunct} Deletes the following characters before comparing: 
	{bf: ! ? ' } and replaces the 
	following characters with a space: {bf: . , - / ;} and trims all extra spaces

{phang}
{opt nomatch} is specified if the number of observations in the master and 
	using dataset do not need to match.  The default is to assume 1:1 matching
	between the datasets, and to list any observations that existin in only one
	dataset. 
	
	
{title:Remarks}

{pstd}
{cmd: cfby} is intended to be used as part of the data entry process
	when data is checked for accuracy.  It outputs a matrix of discrepancies 
	for each unique combination of values of the by variable between the master and using datasets.
	So if you compared the first entry of a dataset to the second entry, 
	it would output the discrepancy rate for each pair of data entry officers.
	If the master dataset was the result of a thoroughly checked audit
	and the using dataset were the raw first entry,
	simply set the by variable to a constant in the audit dataset
	and {bf: cfby} will output the error rate for each data entry officer in the first entry. 
	{bf: cfby} does not compare variables that have a different	string/numeric type in both datasets. 
	{bf: cfby} also doesn't compare variables that are different in all observations.
	

{title:Examples}

{pstd}


use "audit dataset.dta"

cfby region-no_good_at_all using "first entry.dta" , id(uniqueid) by(deo)

{title:Saved Results}

{pstd}
{cmd:cfby} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matricies}{p_end}
{synopt:{cmd:r(e)}}number of discrepenacies{p_end}
{synopt:{cmd:r(q)}}number of data points compared{p_end}
{p2colreset}{...}

{title:Author}

{phang}
Ryan Knight, rknight@poverty-action.org

{title:Also see}

{psee}
Online:  {help cf}, {help compare}
{psee}
User-Written: {help cfout}, {help readreplace}

