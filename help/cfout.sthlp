{smcl}
{* *! version 1 10may2011}{...}
{title:Title}

{phang}
{cmd:cfout} {hline 2} Compare two datasets,
optionally saving the list of differences to file


{title:Syntax}

{p 8 17 2}
{cmdab:cfout}
[{varlist}]
{cmd: using} {it: filename}
{cmd:, id}({varname}) [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt nop:unct}}ignores differences in punctuation and capitalization{p_end}
{synopt:{opt alt:id(varname)}}display an additional identifying variable.{p_end}
{synopt:{opt na:me(filename)}}name of the resulting .csv file{p_end}
{synopt:{opt f:ormat( %fmt)}}display format to use for numeric variables{p_end}
{synopt:{opt nomat:ch}}surpress warnings about missing observations{p_end}
{synopt:{opt u:pper}}convert all string variables to upper case before comparing{p_end}
{synopt:{opt l:ower}}convert all string variables to lower case before comparing{p_end}
{synopt:{opt nos:tring}}do not compare any string variables{p_end}
{synopt:{opt replace}}overwrite existing filename{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{title:Description}

{pstd}
{cmd:cfout} compares the variables in {varlist} from the dataset in memory
			to the variables in {varlist} from the using dataset and saves
			a list of differences to a .csv file.  It is useful if
			you are doing data entry and want to get an easy-to-work-with
			list of discrepancies between the first and second entries of a dataset.

{title:Options}

{phang}
{opt id(varname)} is required. {it: varname} is the variable that matches observations in
		the master dataset to observations in the using dataset.
		It must uniquely identify observations in both the master and using datasets.

{phang}
{opt nopunct} Deletes the following characters before comparing:
	{bf: ! ? ' } and replaces the
	following characters with a space: {bf: . , - / ;}

{phang}
{opt altid(varname)} displays {it: varname} in the resulting .csv file.
	Displaying a second id is useful when you suspect there may be errors
	in the primary id. altid is not used for matching; it is purely cosmetic.

{phang}
{opt name(filename)} specifies the name and path of the resulting
	.csv file. The default is "discrepancies report.csv"

{phang}
{opt format( %fmt)} specifies the display format to be used for all numeric
	variables, including id if it is numeric.  The default is %9.0g.
	See {help format} for help with formating.

{phang}
{opt nomatch} is specified if the number of observations in the master and
	using dataset do not need to match.  The default is to assume 1:1 matching
	between the datasets, and to list any observations that existin in only one
	dataset.


{title:Remarks}

{pstd}
{cmd: cfout} is intended to be used as part of the data entry process
	when data is entered two times for accuracy.
	After the second entry, the datasets need to be reconciled.  {cmd: cfout}
	will compare the first and second entries and generate a list of discrepancies
	in a format that is useful for the data entry teams.  {bf: cfout} assumes that the variable specified in the id option uniquely
	idenfifies observations in both datasets.  {bf: cfout} does not
	compare variables that have a different	string/numeric type in both
	datasets. {bf: cfout} also doesn't compare variables that are different in all observations.

{title:Examples}

{pstd}


use "first entry.dta"

cfout region-no_good_at_all using "second entry.dta" , id(uniqueid)

{title:Saved Results}

{pstd}
{cmd:cfout} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(discrep)}}number of discrepenacies{p_end}
{synopt:{cmd:r(N)}}number of data points compared{p_end}
{p2colreset}{...}


{title:Author}

{phang}
Ryan Knight, rknight at poverty-action.org

{title:Also see}

{psee}
Online:  {help cf}, {help compare}
{psee}
User-Written: {help readreplace}, {help cfby}, {help mergeall}
