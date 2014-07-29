{smcl}
{* *! version 1 10may2011}{...}
{title:Title}

{phang}
{cmd:cfout} {hline 2} Compare two datasets,
optionally saving the list of differences to file


{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:cfout} [{varlist}] {cmd:using} {it:{help filename}}{cmd:,}
{opth id(varlist)} [{it:options}]

{* Using -help odbc- as a template.}{...}
{* 29 is the position of the last character in the first column + 3.}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{* Using -help heckman- as a template.}{...}
{p2coldent:* {opth id(varlist)}}unique ID variables{p_end}

{syntab:String comparison}
{synopt:{opt l:ower}}convert string variables to lowercase before
comparing{p_end}
{synopt:{opt u:pper}}convert string variables to uppercase before
comparing{p_end}
{synopt:{opt nop:unct}}remove punctuation in string variables before
comparing{p_end}
{synopt:{opt strc:omp(command)}}execute {it:command} for
string variable pairs before comparing{p_end}

{syntab:Options}
{* Using -help ca- as a template.}{...}
{synopt:{cmdab:sa:ving(}{it:filename} [{cmd:,} {help cfout##sopts:{it:sopts}}]{cmd:)}}save
list of differences to {it:filename}{p_end}
{synopt:{opt numc:omp(command)}}use {it:command} to determine differences within
numeric variable pairs{p_end}
{synopt:{opt nos:tring}}do not compare string variables{p_end}
{synopt:{opt nonum:eric}}do not compare numeric variables{p_end}
{synopt:{opt dropd:iff}}do not include variables that
differ on every observation{p_end}
{synopt:{opt nomat:ch}}suppress warnings about observations that
are not in both master and using data{p_end}
{* Using description from -help stsplit-.}{...}
{synopt:{opt nop:reserve}}do not save original data; programmer's option{p_end}
{synoptline}
{p2colreset}{...}
{* Using -help heckman- as a template.}{...}
{p 4 6 2}* {opt id()} is required.{p_end}

{* Using -help ca- as a template.}{...}
{marker sopts}{...}
{synoptset 23 tabbed}{...}
{synopthdr:sopts}
{synoptline}
{synopt:{opth v:ariable(newvar)}}name of variable name variable;
default is {cmd:Question}{p_end}
{synopt:{opth mas:terval(newvar)}}name of master value variable;
default is {cmd:Master}{p_end}
{synopt:{opth us:ingval(newvar)}}name of using value variable;
default is {cmd:Using}{p_end}
{synopt:{opth keepmas:ter(varlist)}}variables to keep from master data{p_end}
{synopt:{opth keepus:ing(varlist)}}variables to keep from using data{p_end}
{synopt:{cmdab:a:ll}[{cmd:(}{newvar}{cmd:)}]}save all comparisons,
not just differences, creating a variable named {it:newvar} to mark differences;
default is {cmd:diff}{p_end}
{synopt:{opth p:roperties(cfout##popts:popts)}}save variable properties as
variables{p_end}
{synopt:{opt la:bval}}save labeled master and using values{p_end}
{synopt:{opt csv}}output in comma-separated format instead of
as a Stata dataset{p_end}
{synopt:{opt replace}}overwrite existing {it:filename}{p_end}
{synoptline}
{p2colreset}{...}

{marker popts}{...}
{synoptset 23 tabbed}{...}
{synopthdr:popts}
{synoptline}
{synopt:{cmdab:t:ype}[{cmd:(}{newvar}{cmd:)}]}save storage types as
{it:newvar}; default is {cmd:type}{p_end}
{synopt:{cmdab:f:ormat}[{cmd:(}{newvar}{cmd:)}]}save display formats as
{it:newvar}; default is {cmd:format}{p_end}
{synopt:{cmdab:vall:abel}[{cmd:(}{newvar}{cmd:)}]}save value labels as
{it:newvar}; default is {cmd:vallabel}{p_end}
{synopt:{cmdab:varl:abel}[{cmd:(}{newvar}{cmd:)}]}save variable labels as
{it:newvar}; default is {cmd:varlabel}{p_end}
{synopt:{opt c:har(charnamelist)}}save characteristics{p_end}
{* Using description of stub from -help split-.}{...}
{synopt:{opt chars:tub(stub)}}begin characteristic variable names with
{it:stub}; default is {cmd:char_}{p_end}
{* Using -help graph_pie- as a template.}{...}
{synopt:{cmdab:note:s(}{it:{help numlist}}|{cmd:_all)}}save notes{p_end}
{synopt:{opt notess:tub(stub)}}begin notes variable names with {it:stub};
default is {cmd:note}{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:cfout} compares {varlist} of the dataset in memory (the master dataset) to
{varlist} of {it:{help filename}} (the using dataset).
It uses unique ID variables to match observations.
{cmd:cfout} optionally saves the list of differences to file.


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
