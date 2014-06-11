cfout
=====

`cfout` compares the dataset in memory to a using dataset and saves a list of differences to a .csv file. It is useful if you are doing data entry and want to get an easy-to-work-with list of discrepancies between the first and second entries of a dataset.

`cfout` is available through SSC: type `ssc install cfout` in Stata to install.

Stata help file
---------------

Converted automatically from SMCL:

```
log html cfout.sthlp cfout.md
```

The help file looks best when viewed in Stata as SMCL.

<pre>
<b>help cfout</b>
-------------------------------------------------------------------------------
<p>
<b><u>Title</u></b>
<p>
    <b>cfout</b> -- Compare two files, outsheeting a list of differences
<p>
<b><u>Syntax</u></b>
<p>
        <b>cfout</b> [<i>varlist</i>]<b> using</b><i> filename</i> <b>, id</b>(<i>varname</i>) [<i>options</i>]
<p>
    <i>options</i>               Description
    -------------------------------------------------------------------------
      <b><u>nop</u></b><b>unct</b>             ignores differences in punctuation and
                            capitalization
      <b><u>alt</u></b><b>id(</b><i>varname</i><b>)</b>      display an additional identifying variable.
      <b><u>na</u></b><b>me(</b><i>filename</i><b>)</b>      name of the resulting .csv file
      <b><u>f</u></b><b>ormat(</b><i> </i><b>%</b><i>fmt</i><b>)</b>       display format to use for numeric variables
      <b><u>nomat</u></b><b>ch</b>             surpress warnings about missing observations
      <b><u>u</u></b><b>pper</b>               convert all string variables to upper case before
                            comparing
      <b><u>l</u></b><b>ower</b>               convert all string variables to lower case before
                            comparing
      <b><u>nos</u></b><b>tring</b>            do not compare any string variables
      <b>replace</b>             overwrite existing filename
    -------------------------------------------------------------------------
<p>
<b><u>Description</u></b>
<p>
    <b>cfout</b> compares the variables in <i>varlist</i> from the dataset in memory to the
    variables in <i>varlist</i> from the using dataset and saves a list of
    differences to a .csv file.  It is useful if you are doing data entry and
    want to get an easy-to-work-with list of discrepancies between the first
    and second entries of a dataset.
<p>
<b><u>Options</u></b>
<p>
    <b>id(</b><i>varname</i><b>)</b> is required.<i>  varname</i> is the variable that matches
        observations in the master dataset to observations in the using
        dataset.  It must uniquely identify observations in both the master
        and using datasets.
<p>
    <b>nopunct</b> Deletes the following characters before comparing:<b>  ! ? '</b> and
        replaces the following characters with a space:<b>  . , - / ;</b>
<p>
    <b>altid(</b><i>varname</i><b>)</b> displays<i> varname</i> in the resulting .csv file.  Displaying a
        second id is useful when you suspect there may be errors in the
        primary id. altid is not used for matching; it is purely cosmetic.
<p>
    <b>name(</b><i>filename</i><b>)</b> specifies the name and path of the resulting .csv file.
        The default is "discrepancies report.csv"
<p>
    <b>format(</b><i> </i><b>%</b><i>fmt</i><b>)</b> specifies the display format to be used for all numeric
        variables, including id if it is numeric.  The default is %9.0g.  See
        format for help with formating.
<p>
    <b>nomatch</b> is specified if the number of observations in the master and
        using dataset do not need to match.  The default is to assume 1:1
        matching between the datasets, and to list any observations that
        existin in only one dataset.
<p>

<b><u>Remarks</u></b>
<p>
    <b>cfout</b> is intended to be used as part of the data entry process when data
    is entered two times for accuracy.  After the second entry, the datasets
    need to be reconciled.<b>  cfout</b> will compare the first and second entries
    and generate a list of discrepancies in a format that is useful for the
    data entry teams.<b>  cfout</b> assumes that the variable specified in the id
    option uniquely idenfifies observations in both datasets.<b>  cfout</b> does not
    compare variables that have a different string/numeric type in both
    datasets.<b>  cfout</b> also doesn't compare variables that are different in all
    observations.
<p>
<b><u>Examples</u></b>
<p>
<p>
<p>
use "first entry.dta"
<p>
cfout region-no_good_at_all using "second entry.dta" , id(uniqueid)
<p>
<b><u>Saved Results</u></b>
<p>
    <b>cfout</b> saves the following in <b>r()</b>:
<p>
    Scalars
      <b>r(discrep)</b>     number of discrepenacies
      <b>r(N)</b>           number of data points compared
<p>
<p>
<b><u>Author</u></b>
<p>
    Ryan Knight, rknight at poverty-action.org
<p>
<b><u>Also see</u></b>
<p>
    Online:  cf, compare
<p>
</pre>
