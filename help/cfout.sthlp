{smcl}
{* *! version 2.0.1 Matthew White 09mar2015}{...}
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
{synopt:{cmdab:a:ll}[{cmd:(}{newvar}{cmd:)}]}save all comparisons,
not just differences, creating a variable named {it:newvar} to mark differences;
default is {cmd:diff}{p_end}
{synopt:{opth keepmas:ter(varlist)}}variables to keep from master data{p_end}
{synopt:{opth keepus:ing(varlist)}}variables to keep from using data{p_end}
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


{marker remarks}{...}
{title:Remarks}

{pstd}
If the master and using data contain value labels with the same name,
the ones from the master data are used.

{pstd}
Among the applications of {cmd:cfout} is data entry,
for which the command may facilitate the reconciliation of
two separate entries of the same dataset.
{cmd:cfout} can output a list of differences in a format useful for
data entry teams. The related SSC program {cmd:readreplace} then inputs
the correct values from a similarly formatted file.

{pstd}
The GitHub repository for {cmd:cfout} is
{browse "https://github.com/PovertyAction/cfout":here}.
Previous versions may be found there: see the tags.
If outdated syntax is specified, {cmd:cfout} issues a warning message describing
how the command will be interpreted.


{marker remarks_comparison_commands}{...}
{title:Remarks for options strcomp() and numcomp()}

{pstd}
Options {opt strcomp()} and {opt numcomp()} specify
user-written comparison programs to determine which
observation pairs are relevantly different.
For instance, while the two strings {cmd:"Vladimir Levenshtein"} and
{cmd:"vladimir levenshtein"} are different, they are not when
converted to lowercase. The numbers {cmd:1} and {cmd:1.5} are different, but not
when an acceptable difference of {cmd:0.75} is specified.
{opt strcomp()} and {opt numcomp()} specify
how to determine differences within pairs.

{pstd}
For each variable of {varlist}, {cmd:cfout} passes to
the relevant comparison program two variables that contain
the values in the master data and the values in the using, respectively.
If the variable is string,
the variable pair is passed to the program specified to {opt strcomp()}.
If it is numeric,
the pair is passed to the program specified to {opt numcomp()}.
From here, the roles of the two comparison programs differ slightly.

{pstd}
{ul:{opt strcomp()}}

{pstd}
The string comparison program specified to {opt strcomp()} is expected to change
the variable pair so that they are actually different if and only if
they are relevantly different. For instance, the program may convert
the variables to lowercase, replace some strings with other strings,
or make other changes. {cmd:cfout} will then compare
the changed variables rather than the original ones.

{pstd}
An example may be helpful.
Datasets {cmd:firstEntry.dta} and {cmd:secondEntry.dta}
(available through {stata "ssc describe cfout":SSC} as ancillary files)
share a string variable named {cmd:firstname} that
stores respondents' first names.
The variable is messy, containing punctuation in addition to letters.

{cmd}{...}
{phang}use firstEntry{p_end}
{phang}cfout firstname using secondEntry, id(uniqueid){p_end}
{txt}{...}

{pstd}
Option {opt nopunct} removes much but not all of the punctuation:

{phang}{cmd}
cfout firstname using secondEntry, id(uniqueid) nopunct
{txt}

{pstd}
We notice that {cmd:firstname} also contains errant brackets.
We thus write a {help program} to remove them:

{cmd}{...}
{phang}program remove_brackets{p_end}
{phang2}syntax varlist(min=2 max=2 string){p_end}

{phang2}foreach var of local varlist {{p_end}
{phang3}replace `var' = subinstr(`var', "[", "", .){p_end}
{phang3}replace `var' = subinstr(`var', "]", "", .){p_end}
{phang2}}{p_end}
{phang}end{p_end}
{txt}{...}

{pstd}
We then specify the name of the program to {opt strcomp()}:

{phang}{cmd}
cfout firstname using secondEntry, id(uniqueid) nopunct strcomp(remove_brackets)
{txt}

{pstd}
The comparison command specified to {opt strcomp()} may also include options.
For instance, we notice that the datasets contain
both {cmd:Lily} and {cmd:Lilly}, and we decide not to count
this as a difference. We need not write a program tailor-made for Lilys.
Suppose we already have a program that replaces one string with another:

{cmd}{...}
{phang}program fromto{p_end}
{phang2}syntax varlist(min=2 max=2 string), from(string) to(string){p_end}

{phang2}foreach var of local varlist {{p_end}
{phang3}replace `var' = "`to'" if `var' == "`from'"{p_end}
{phang2}}{p_end}
{phang}end{p_end}
{txt}{...}

{pstd}
We may now specify this program to {opt strcomp()} with options:

{phang}{cmd}
cfout firstname using secondEntry,
id(uniqueid) nopunct strcomp(fromto, from("Lilly") to("Lily"))
{txt}

{pstd}
Even here, the command we specify to {opt strcomp()} does not include
a {it:varlist}: {cmd:cfout} will insert one for each master-using variable pair.
Further, while the command specified to {opt strcomp()} may include options,
it may not include other syntactical elements, such as {cmd:if} or {cmd:using}.
If {it:command} is {it:program_name}{cmd:,} {it:options},
{cmd:cfout} will always run:

{pstd}
{it:program_name varname_master varname_using}{cmd:,} {it:options}

{pstd}
{ul:{opt numcomp()}}

{pstd}
The numeric comparison program specified to {opt numcomp()} is expected to
create a new indicator variable that marks
whether the master and using values are relevantly different.
For instance, the program could create an indicator variable that
is {cmd:1} if observation pairs differ by more than {cmd:0.75} and
{cmd:0} if not.
{cmd:cfout} will then use this indicator variable to determine
relevant differences: only these will be reported and saved to file.

{pstd}
Like {opt strcomp()}, {opt numcomp()} helps {cmd:cfout} determine which
differences are important. However, it differs slightly in its approach:
while the string comparison program specified to {opt strcomp()} changes
the variable pair specified to it, the numeric comparison program should not,
instead only creating an indicator variable to mark differences.

{pstd}
Let's see an example.
Datasets {cmd:firstEntry.dta} and {cmd:secondEntry.dta} store
respondents' ages in variable {cmd:age}:

{cmd}{...}
{phang}use firstEntry{p_end}
{phang}cfout age using secondEntry, id(uniqueid){p_end}
{txt}{...}

{pstd}
However, suppose we know that {cmd:age} may differ slightly between
the two datasets, and this is not a source of concern.
We may wish to limit the differences to only those that are more than
{cmd:5} years.

{pstd}
To do so, we write a program that accepts the variable pair and
an option {opt generate()}, to which {cmd:cfout} will specify the name of
the new difference indicator variable.

{cmd}{...}
{phang}program range5{p_end}
{phang2}syntax varlist(min=2 max=2 numeric), generate(name){p_end}
{phang2}gettoken var1 varlist : varlist{p_end}
{phang2}gettoken var2 : varlist{p_end}

{phang2}generate `generate' = abs(`var1' - `var2') > 5{p_end}
{phang}end{p_end}
{txt}{...}

{pstd}
We then specify the name of the program to {opt numcomp()}:

{phang}{cmd}
cfout age using secondEntry, id(uniqueid) numcomp(range5)
{txt}

{pstd}
Do not specify the program's option {opt generate()} to {opt numcomp()}:
{cmd:cfout()} will specify it when it creates the indicator variable.

{pstd}
Like {opt strcomp()}, {opt numcomp()} accepts comparison commands that
include options. We could rewrite the program above so that
the acceptable difference is specified to an option {opt d()}:

{cmd}{...}
{phang}program range{p_end}
{phang2}syntax varlist(min=2 max=2 numeric), generate(name) d(real){p_end}
{phang2}gettoken var1 varlist : varlist{p_end}
{phang2}gettoken var2 : varlist{p_end}

{phang2}generate `generate' = abs(`var1' - `var2') > `d'{p_end}
{phang}end{p_end}

{phang}cfout age using secondEntry, id(uniqueid) numcomp(range, d(5)){p_end}
{txt}{...}

{pstd}
Again, as with {opt strcomp()}, even here the command we specify to
{opt numcomp()} does not include a {it:varlist}.
We also continue not to specify option {opt generate()}.
If {it:command} is {it:program_name}{cmd:,} {it:options},
{cmd:cfout} will always run:

{pstd}
{it:program_name varname_master varname_using}{cmd:,}
{opt generate(newvar)} {it:options}

{pstd}
In the indicator variable that the comparison program creates,
{cmd:0} means that an observation pair is the same, and
nonzero values mean that it is different.

{pstd}
{ul:General advice}

{pstd}
An alternative to {opt strcomp()} and {opt numcomp()} is to save the
list of differences, then load it and drop irrelevant differences.
Above, we ran:

{cmd}{...}
{phang}use firstEntry{p_end}
{phang}cfout firstname using secondEntry,
	id(uniqueid) nopunct strcomp(remove_brackets){p_end}
{txt}{...}

{pstd}
Yet we could have achieved the same result without specifying {opt strcomp()} by
executing {cmd:remove_brackets} only after loading the list of differences:

{cmd}{...}
{phang}cfout firstname using secondEntry,
	id(uniqueid) nopunct saving(diffs){p_end}
{phang}use diffs{p_end}
{phang}remove_brackets Master Using{p_end}
{phang}drop if Master == Using{p_end}
{phang}display _N{p_end}
{txt}{...}

{pstd}
However, specifying {opt strcomp()} and {opt numcomp()} has advantages.
By dropping observations as soon as possible,
it limits the number of differences that ever reach the final list,
thereby reducing memory requirements {hline 2} sometimes significantly so.

{pstd}
{cmd:cfout} expects the programs specified to
{opt strcomp()} and {opt numcomp()} to behave in certain ways.
If they do not, {cmd:cfout} may result in an error or produce incorrect results.

{pstd}
The comparison programs have access to a full dataset,
not just the variable pair specified to them.
However, they should not make assumptions about the rest of the dataset,
and they should not modify it or its metadata,
for instance, variable properties like variable labels or characteristics.
While the string comparison program is expected to make changes to
the variable pair specified to it, it should not
make assumptions about or modify their metadata.
The same holds for {opt numcomp()}, which should also not modify
the variable pair, instead only creating an indicator variable.

{pstd}
As a rule, the comparison programs should not use
information not passed to them, as this may change across {cmd:cfout} versions.
The programs should restrict themselves to the variable names and their values.
Order usually does not matter, but {cmd:cfout} will always specify
the master value variable first in the pair.
The master value variable retains its variable name from the master data,
but the name of the using value variable will differ.

{pstd}
The comparison programs are free to sort the data without
restoring the original order.
In fact, this may reduce the time cost of the programs.

{pstd}
Finally, note that the comparison programs may be run {cmd:noisily} so that
error messages are displayed correctly.
To reduce this output, add {helpb quietly} within the programs.


{marker options}{...}
{title:Options}

{dlgtab:String comparison}

{phang}
{opt nopunct} specifies changes to string variables before they are compared.
It removes the following characters before comparing: {cmd:! ' ?}
It replaces the following strings with a space: {cmd:( ) , -- . / : ;}
It then removes leading or trailing blanks and
multiple, consecutive internal blanks.

{phang}
{opt strcomp(command)} specifies a command to execute for
all string variable pairs before they are compared.
See the {help cfout##remarks_comparison_commands:remarks} above for
more information. {opt strcomp()} is implemented after
the other string comparison options {opt lower}, {opt upper}, and {opt nopunct}.

{dlgtab:Options}

{phang}
{cmd:saving(}{it:filename} [{cmd:,} {it:sopts}]{cmd:)} saves
the list of differences to {it:filename} as a Stata dataset.
This "differences dataset" contains an observation for each difference and
variables for the unique ID values, the name of the variable that differs, and
the values in the master and using data.
The master and using values of string variables reflect
the changes to the variables that the string comparison options implement.
The variables for the master and using values are string if and only if
one of the compared variables is string.

{phang2}
{opt all(newvar)} specifies that the differences dataset include
all comparisons, not just differences.
It creates an indicator variable named {it:newvar} that
is {cmd:1} if the master and using values differ and {cmd:0} if not.
If {opt all} is specified without {it:newvar},
the indicator variable is named {cmd:diff}.
If option {opt numcomp()} is specified,
the {opt all()} indicator variable reflects
the indicator variable created by the numeric comparison program.
In that case, {opt all()} may mark
a different master-using value pair as not different,
because {opt numcomp()} has specified that they are not relevantly different.
If option {opt labval} is specified,
the {opt all()} indicator variable marks whether the values actually differ,
not whether they do after being formatted:
two different values may appear the same after being formatted.

{phang2}
{opt keepmaster(varlist)} specifies variables from the master data to include in
the differences dataset. They are merged into the differences dataset using
the unique ID variables.

{phang2}
{opt keepusing(varlist)} specifies variables from the using data to include in
the differences dataset. They are merged into the differences dataset using
the unique ID variables.

{phang2}
{opt properties(popts)} saves the properties of variables in
the differences dataset's variable name variable as their own variables.
The variable properties of the master data are used.

{phang3}
{opt char(charnamelist)} saves
the {help char:characteristics} {it:charnamelist} of variables in
the differences dataset's variable name variable as their own variables.
Characteristic variable names are the combination of
the characteristic variable name stub specified to {opt charstub()} and
the name of the characteristic.

{phang3}
{cmd:notes(}{it:numlist}|{cmd:_all)} saves the {help notes} of variables in
the differences dataset's variable name variable as their own variables.
Notes variable names are the combination of
the notes variable name stub specified to {opt notesstub()} and the note number.
{it:numlist} specifies the numbers of the notes to save.
If {cmd:_all} is specified, notes are saved from {cmd:1} to
the maximum note number among the variables specified to {cmd:cfout}.

{phang2}
{opt labval} specifies that the master and using values be
labeled and formatted according to their value label and display format.
By default, the variables that contain the master and using values store
numeric values formatted as {cmd:%24.0g}.
Value labels and display formats from the master data are used.
The variables for the master and using values will be stored as string.

{phang}
{opt numcomp(command)} specifies a command to determine differences within
numeric variable pairs.
See the {help cfout##remarks_comparison_commands:remarks} above for
more information.

{phang}
{opt dropdiff} specifies that variables that differ on
every observation not be included. Results for these variables are
not reported in the summary, returned in {cmd:r()} stored results,
or saved in the differences dataset.
If options {opt strcomp()} and/or {opt numcomp()} are specified,
{opt dropdiff} follows them in determining which observations are different.

{* Some language taken from -help stsplit.}{...}
{phang}
{opt nopreserve} is intended for use by programmers.
It speeds the comparison by not saving the original data,
which normally can be restored should things go wrong or
if you press {cmd:Break}. Programmers can specify this option if
they have already preserved the original data.
{opt nopreserve} does not affect the comparison.
If both options {opt nopreserve} and {opt saving()} are specified,
the differences dataset is left in memory.


{marker examples}{...}
{title:Examples}

{pstd}
Compare the variables {cmd:region-no_good_at_all} of
the datasets {cmd:firstEntry.dta} and {cmd:secondEntry.dta},
using variable {cmd:uniqueid} to match observations
{p_end}{cmd}{...}
{phang2}. use firstEntry{p_end}
{phang2}. cfout region-no_good_at_all using secondEntry, id(uniqueid){p_end}
{txt}{...}

{pstd}
Save the differences to the file {cmd:diffs.dta}
{p_end}{cmd}{...}
{phang2}. cfout region-no_good_at_all using secondEntry, id(uniqueid)
	saving(diffs){p_end}
{phang2}. use diffs{p_end}
{txt}{...}

{pstd}
Save the differences dataset with alternative variable names
{p_end}{cmd}{...}
{phang2}. use firstEntry{p_end}
{phang2}. cfout region-no_good_at_all using secondEntry, id(uniqueid)
	saving(diffs,
	variable(varname) masterval(master_value) usingval(using_value)){p_end}
{phang2}. use diffs{p_end}
{txt}{...}

{pstd}
Save all comparisons to the differences dataset, not just differences
{p_end}{cmd}{...}
{phang2}. use firstEntry{p_end}
{phang2}. cfout region-no_good_at_all using secondEntry, id(uniqueid)
	saving(diffs, all){p_end}
{phang2}. use diffs{p_end}
{phang2}. count if diff{p_end}
{txt}{...}

{pstd}
Add variable {cmd:deo} from {cmd:firstEntry.dta} to the differences dataset
{p_end}{cmd}{...}
{phang2}. use firstEntry{p_end}
{phang2}. cfout region-no_good_at_all using secondEntry, id(uniqueid)
	saving(diffs, keepmaster(deo)){p_end}
{phang2}. use diffs{p_end}
{txt}{...}

{pstd}
Save the storage types of the compared variables as
an additional variable of the differences dataset
{p_end}{cmd}{...}
{phang2}. use firstEntry{p_end}
{phang2}. cfout region-no_good_at_all using secondEntry, id(uniqueid)
	saving(diffs, properties(type)){p_end}
{phang2}. use diffs{p_end}
{phang2}. generate isstrvar = strmatch(type, "str*"){p_end}
{txt}{...}

{pstd}
Save the storage types of the compared variables with
an alternative variable name
{p_end}{cmd}{...}
{phang2}. use firstEntry{p_end}
{phang2}. cfout region-no_good_at_all using secondEntry, id(uniqueid)
	saving(diffs, properties(type(storage_type))){p_end}
{phang2}. use diffs{p_end}
{txt}{...}

{pstd}
For data that has been entered twice, compare the first and second entries,
calculating discrepancy rates for each pair of data entry operators.
This yields the same results as the SSC program {cmd:cfby}.
{p_end}{cmd}{...}
{phang2}. use firstEntry{p_end}
{phang2}. * Variable deo identifies the data entry operator.{p_end}
{phang2}. rename deo deo1{p_end}
{phang2}. cfout region-no_good_at_all using secondEntry,
	id(uniqueid) saving(diffs, all keepmaster(deo1) keepusing(deo)){p_end}
{phang2}. use diffs, clear{p_end}
{phang2}. rename deo deo2{p_end}
{phang2}. generate swap = deo1 > deo2{p_end}
{phang2}. generate t = deo1 if swap{p_end}
{phang2}. replace deo1 = deo2 if swap{p_end}
{phang2}. replace deo2 = t if swap{p_end}
{phang2}. drop swap t{p_end}
{phang2}. bysort deo*: generate total = _N{p_end}
{phang2}. by deo*: egen total_diff = total(diff){p_end}
{phang2}. by deo*: generate error_rate = 100 * total_diff / total{p_end}
{phang2}. format error_rate %9.2f{p_end}
{phang2}. sort deo*{p_end}
{phang2}. egen tag = tag(deo*){p_end}
{phang2}. list deo* total_diff total error_rate if tag, abbreviate(32) noobs{p_end}
{txt}{...}

{pstd}
For twice entered data and a list of correct values,
determine the error rates of individual data entry operators
(not pairs as above)
{p_end}{cmd}{...}
{phang2}. use firstEntry{p_end}
{phang2}. readreplace using correctedValues.csv, id(uniqueid) variable(question) value(correctvalue){p_end}
{phang2}. cfout region-no_good_at_all using firstEntry,{space 2}id(uniqueid)
	saving(diff1, all keepusing(deo)){p_end}
{phang2}. cfout region-no_good_at_all using secondEntry, id(uniqueid)
	saving(diff2, all keepusing(deo)){p_end}
{phang2}. use diff1, clear{p_end}
{phang2}. append using diff2{p_end}
{phang2}. bysort deo: generate total = _N{p_end}
{phang2}. by deo: egen total_diff = total(diff){p_end}
{phang2}. by deo: generate error_rate = 100 * total_diff / total{p_end}
{phang2}. format error_rate %9.2f{p_end}
{phang2}. sort deo{p_end}
{phang2}. egen tag = tag(deo){p_end}
{phang2}. list deo total_diff total error_rate if tag, abbreviate(32) noobs{p_end}
{txt}{...}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:cfout} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of values compared;
includes only the variables of {cmd:r(varlist)}{p_end}
{synopt:{cmd:r(discrep)}}number of differences;
includes only the variables of {cmd:r(varlist)}{p_end}
{synopt:{cmd:r(Nonlym)}}number of observations only in the master dataset{p_end}
{synopt:{cmd:r(Nonlyu)}}number of observations only in the using dataset{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(varlist)}}variables compared;
does not include {cmd:r(varonlym)}, {cmd:r(difftype)}, or
(if option {opt dropdiff} is specified) {cmd:r(alldiff)}{p_end}
{synopt:{cmd:r(varonlym)}}variables only in the master dataset{p_end}
{synopt:{cmd:r(difftype)}}variables that are numeric in one dataset and
string in the other{p_end}
{synopt:{cmd:r(alldiff)}}variables that differ on every observation{p_end}
{p2colreset}{...}


{marker acknowledgments}{...}
{title:Acknowledgments}

{pstd}
Christopher Robert of the Harvard Kennedy School suggested
option {opt nonumeric}.


{marker authors}{...}
{title:Authors}

{pstd}Ryan Knight{p_end}
{pstd}Matthew White{p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/cfout/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}


{title:Also see}

{psee}
Help:  {manhelp cf D}, {manhelp compare D}, {manhelp dta_equal P},
{manhelp datasignature D}

{psee}
User-written:  {helpb readreplace}, {helpb bcstats}, {helpb mergeall}
{p_end}
