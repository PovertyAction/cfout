cfout
=====

`cfout` compares the dataset in memory (the master dataset) to a using dataset. It uses unique ID variables to match observations. `cfout` optionally saves the list of differences to file.

`cfout` is available through SSC: type `ssc install cfout` in Stata to install.

Certification script
--------------------

The [certification script](http://www.stata.com/help.cgi?cscript) of `cfout` is [`cscript/cfout.do`](/cscript/cfout.do). If you are new to certification scripts, you may find [this](http://www.stata-journal.com/sjpdf.html?articlenum=pr0001) Stata Journal article helpful. See [this guide](/cscript/Tests.md) for more on `cfout` testing.

Stata help file
---------------

Converted automatically from SMCL:

```
log html cfout.sthlp cfout.md
```

The help file looks best when viewed in Stata as SMCL.

<pre>
<b><u>Title</u></b>
<p>
    <b>cfout</b> -- Compare two datasets, optionally saving the list of differences
        to file
<p>
<p>
<a name="syntax"></a><b><u>Syntax</u></b>
<p>
        <b>cfout</b> [<i>varlist</i>] <b>using</b> <i>filename</i><b>,</b> <b>id(</b><i>varlist</i><b>)</b> [<i>options</i>]
<p>
    <i>options</i>                        Description
    -------------------------------------------------------------------------
    Main
    * <b>id(</b><i>varlist</i><b>)</b>                  unique ID variables
<p>
    String comparison
      <b><u>l</u></b><b>ower</b>                        convert string variables to lowercase
                                     before comparing
      <b><u>u</u></b><b>pper</b>                        convert string variables to uppercase
                                     before comparing
      <b><u>nop</u></b><b>unct</b>                      remove punctuation in string variables
                                     before comparing
      <b><u>strc</u></b><b>omp(</b><i>command</i><b>)</b>             execute <i>command</i> for string variable pairs
                                     before comparing
<p>
    Options
      <b><u>sa</u></b><b>ving(</b><i>filename</i> [<b>,</b> <i>sopts</i>]<b>)</b>   save list of differences to <i>filename</i>
      <b><u>numc</u></b><b>omp(</b><i>command</i><b>)</b>             use <i>command</i> to determine differences
                                     within numeric variable pairs
      <b><u>nos</u></b><b>tring</b>                     do not compare string variables
      <b><u>nonum</u></b><b>eric</b>                    do not compare numeric variables
      <b><u>dropd</u></b><b>iff</b>                     do not include variables that differ on
                                     every observation
      <b><u>nomat</u></b><b>ch</b>                      suppress warnings about observations that
                                     are not in both master and using data
      <b><u>nop</u></b><b>reserve</b>                   do not save original data; programmer's
                                     option
    -------------------------------------------------------------------------
    * <b>id()</b> is required.
<p>
<a name="sopts"></a>    <i>sopts</i>                    Description
    -------------------------------------------------------------------------
      <b><u>v</u></b><b>ariable(</b><i>newvar</i><b>)</b>       name of variable name variable; default is
                               <b>Question</b>
      <b><u>mas</u></b><b>terval(</b><i>newvar</i><b>)</b>      name of master value variable; default is <b>Master</b>
      <b><u>us</u></b><b>ingval(</b><i>newvar</i><b>)</b>       name of using value variable; default is <b>Using</b>
      <b><u>a</u></b><b>ll</b>[<b>(</b><i>newvar</i><b>)</b>]          save all comparisons, not just differences,
                               creating a variable named <i>newvar</i> to mark
                               differences; default is <b>diff</b>
      <b><u>keepmas</u></b><b>ter(</b><i>varlist</i><b>)</b>    variables to keep from master data
      <b><u>keepus</u></b><b>ing(</b><i>varlist</i><b>)</b>     variables to keep from using data
      <b><u>p</u></b><b>roperties(</b><i>popts</i><b>)</b>      save variable properties as variables
      <b><u>la</u></b><b>bval</b>                 save labeled master and using values
      <b>csv</b>                    output in comma-separated format instead of as a
                               Stata dataset
      <b>replace</b>                overwrite existing <i>filename</i>
    -------------------------------------------------------------------------
<p>
<a name="popts"></a>    <i>popts</i>                    Description
    -------------------------------------------------------------------------
      <b><u>t</u></b><b>ype</b>[<b>(</b><i>newvar</i><b>)</b>]         save storage types as <i>newvar</i>; default is <b>type</b>
      <b><u>f</u></b><b>ormat</b>[<b>(</b><i>newvar</i><b>)</b>]       save display formats as <i>newvar</i>; default is
                               <b>format</b>
      <b><u>vall</u></b><b>abel</b>[<b>(</b><i>newvar</i><b>)</b>]     save value labels as <i>newvar</i>; default is <b>vallabel</b>
      <b><u>varl</u></b><b>abel</b>[<b>(</b><i>newvar</i><b>)</b>]     save variable labels as <i>newvar</i>; default is
                               <b>varlabel</b>
      <b><u>c</u></b><b>har(</b><i>charnamelist</i><b>)</b>     save characteristics
      <b><u>chars</u></b><b>tub(</b><i>stub</i><b>)</b>         begin characteristic variable names with <i>stub</i>;
                               default is <b>char_</b>
      <b><u>note</u></b><b>s(</b><i>numlist</i>|<b>_all)</b>    save notes
      <b><u>notess</u></b><b>tub(</b><i>stub</i><b>)</b>        begin notes variable names with <i>stub</i>; default is
                               <b>note</b>
    -------------------------------------------------------------------------
<p>
<p>
<a name="description"></a><b><u>Description</u></b>
<p>
    <b>cfout</b> compares <i>varlist</i> of the dataset in memory (the master dataset) to
    <i>varlist</i> of <i>filename</i> (the using dataset).  It uses unique ID variables to
    match observations.  <b>cfout</b> optionally saves the list of differences to
    file.
<p>
<p>
<a name="remarks"></a><b><u>Remarks</u></b>
<p>
    If the master and using data contain value labels with the same name, the
    ones from the master data are used.
<p>
    Among the applications of <b>cfout</b> is data entry, for which the command may
    facilitate the reconciliation of two separate entries of the same
    dataset.  <b>cfout</b> can output a list of differences in a format useful for
    data entry teams. The related SSC program <b>readreplace</b> then inputs the
    correct values from a similarly formatted file.
<p>
    The GitHub repository for <b>cfout</b> is here.  Previous versions may be found
    there: see the tags.  If outdated syntax is specified, <b>cfout</b> issues a
    warning message describing how the command will be interpreted.
<p>
<p>
<a name="remarks_comparison_commands"></a><b><u>Remarks for options strcomp() and numcomp()</u></b>
<p>
    Options <b>strcomp()</b> and <b>numcomp()</b> specify user-written comparison programs
    to determine which observation pairs are relevantly different.  For
    instance, while the two strings <b>"Vladimir Levenshtein"</b> and <b>"vladimir</b>
    <b>levenshtein"</b> are different, they are not when converted to lowercase. The
    numbers <b>1</b> and <b>1.5</b> are different, but not when an acceptable difference of
    <b>0.75</b> is specified.  <b>strcomp()</b> and <b>numcomp()</b> specify how to determine
    differences within pairs.
<p>
    For each variable of <i>varlist</i>, <b>cfout</b> passes to the relevant comparison
    program two variables that contain the values in the master data and the
    values in the using, respectively.  If the variable is string, the
    variable pair is passed to the program specified to <b>strcomp()</b>.  If it is
    numeric, the pair is passed to the program specified to <b>numcomp()</b>.  From
    here, the roles of the two comparison programs differ slightly.
<p>
    <b><u>strcomp()</u></b>
<p>
    The string comparison program specified to <b>strcomp()</b> is expected to
    change the variable pair so that they are actually different if and only
    if they are relevantly different. For instance, the program may convert
    the variables to lowercase, replace some strings with other strings, or
    make other changes. <b>cfout</b> will then compare the changed variables rather
    than the original ones.
<p>
    An example may be helpful.  Datasets <b>firstEntry.dta</b> and <b>secondEntry.dta</b>
    (available through SSC as ancillary files) share a string variable named
    <b>firstname</b> that stores respondents' first names.  The variable is messy,
    containing punctuation in addition to letters.
<p>
    <b>use firstEntry</b>
    <b>cfout firstname using secondEntry, id(uniqueid)</b>
<p>
    Option <b>nopunct</b> removes much but not all of the punctuation:
<p>
    <b>cfout firstname using secondEntry, id(uniqueid) nopunct</b>
<p>
    We notice that <b>firstname</b> also contains errant brackets.  We thus write a
    program to remove them:
<p>
    <b>program remove_brackets</b>
        <b>syntax varlist(min=2 max=2 string)</b>
<p>
        <b>foreach var of local varlist {</b>
            <b>replace `var' = subinstr(`var', "[", "", .)</b>
            <b>replace `var' = subinstr(`var', "]", "", .)</b>
        <b>}</b>
    <b>end</b>
<p>
    We then specify the name of the program to <b>strcomp()</b>:
<p>
    <b>cfout firstname using secondEntry, id(uniqueid) nopunct</b>
        <b>strcomp(remove_brackets)</b>
<p>
    The comparison command specified to <b>strcomp()</b> may also include options.
    For instance, we notice that the datasets contain both <b>Lily</b> and <b>Lilly</b>,
    and we decide not to count this as a difference. We need not write a
    program tailor-made for Lilys.  Suppose we already have a program that
    replaces one string with another:
<p>
    <b>program fromto</b>
        <b>syntax varlist(min=2 max=2 string), from(string) to(string)</b>
<p>
        <b>foreach var of local varlist {</b>
            <b>replace `var' = "`to'" if `var' == "`from'"</b>
        <b>}</b>
    <b>end</b>
<p>
    We may now specify this program to <b>strcomp()</b> with options:
<p>
    <b>cfout firstname using secondEntry, id(uniqueid) nopunct strcomp(fromto,</b>
        <b>from("Lilly") to("Lily"))</b>
<p>
    Even here, the command we specify to <b>strcomp()</b> does not include a
    <i>varlist</i>: <b>cfout</b> will insert one for each master-using variable pair.
    Further, while the command specified to <b>strcomp()</b> may include options, it
    may not include other syntactical elements, such as <b>if</b> or <b>using</b>.  If
    <i>command</i> is <i>program_name</i><b>,</b> <i>options</i>, <b>cfout</b> will always run:
<p>
    <i>program_name varname_master varname_using</i><b>,</b> <i>options</i>
<p>
    <b><u>numcomp()</u></b>
<p>
    The numeric comparison program specified to <b>numcomp()</b> is expected to
    create a new indicator variable that marks whether the master and using
    values are relevantly different.  For instance, the program could create
    an indicator variable that is <b>1</b> if observation pairs differ by more than
    <b>0.75</b> and <b>0</b> if not.  <b>cfout</b> will then use this indicator variable to
    determine relevant differences: only these will be reported and saved to
    file.
<p>
    Like <b>strcomp()</b>, <b>numcomp()</b> helps <b>cfout</b> determine which differences are
    important. However, it differs slightly in its approach:  while the
    string comparison program specified to <b>strcomp()</b> changes the variable
    pair specified to it, the numeric comparison program should not, instead
    only creating an indicator variable to mark differences.
<p>
    Let's see an example.  Datasets <b>firstEntry.dta</b> and <b>secondEntry.dta</b> store
    respondents' ages in variable <b>age</b>:
<p>
    <b>use firstEntry</b>
    <b>cfout age using secondEntry, id(uniqueid)</b>
<p>
    However, suppose we know that <b>age</b> may differ slightly between the two
    datasets, and this is not a source of concern.  We may wish to limit the
    differences to only those that are more than <b>5</b> years.
<p>
    To do so, we write a program that accepts the variable pair and an option
    <b>generate()</b>, to which <b>cfout</b> will specify the name of the new difference
    indicator variable.
<p>
    <b>program range5</b>
        <b>syntax varlist(min=2 max=2 numeric), generate(name)</b>
        <b>gettoken var1 varlist : varlist</b>
        <b>gettoken var2 : varlist</b>
<p>
        <b>generate `generate' = abs(`var1' - `var2') &gt; 5</b>
    <b>end</b>
<p>
    We then specify the name of the program to <b>numcomp()</b>:
<p>
    <b>cfout age using secondEntry, id(uniqueid) numcomp(range5)</b>
<p>
    Do not specify the program's option <b>generate()</b> to <b>numcomp()</b>:  <b>cfout()</b>
    will specify it when it creates the indicator variable.
<p>
    Like <b>strcomp()</b>, <b>numcomp()</b> accepts comparison commands that include
    options. We could rewrite the program above so that the acceptable
    difference is specified to an option <b>d()</b>:
<p>
    <b>program range</b>
        <b>syntax varlist(min=2 max=2 numeric), generate(name) d(real)</b>
        <b>gettoken var1 varlist : varlist</b>
        <b>gettoken var2 : varlist</b>
<p>
        <b>generate `generate' = abs(`var1' - `var2') &gt; `d'</b>
    <b>end</b>
<p>
    <b>cfout age using secondEntry, id(uniqueid) numcomp(range, d(5))</b>
<p>
    Again, as with <b>strcomp()</b>, even here the command we specify to <b>numcomp()</b>
    does not include a <i>varlist</i>.  We also continue not to specify option
    <b>generate()</b>.  If <i>command</i> is <i>program_name</i><b>,</b> <i>options</i>, <b>cfout</b> will always run:
<p>
    <i>program_name varname_master varname_using</i><b>,</b> <b>generate(</b><i>newvar</i><b>)</b> <i>options</i>
<p>
    In the indicator variable that the comparison program creates, <b>0</b> means
    that an observation pair is the same, and nonzero values mean that it is
    different.
<p>
    <u>General advice</u>
<p>
    An alternative to <b>strcomp()</b> and <b>numcomp()</b> is to save the list of
    differences, then load it and drop irrelevant differences.  Above, we
    ran:
<p>
    <b>use firstEntry</b>
    <b>cfout firstname using secondEntry, id(uniqueid) nopunct</b>
        <b>strcomp(remove_brackets)</b>
<p>
    Yet we could have achieved the same result without specifying <b>strcomp()</b>
    by executing <b>remove_brackets</b> only after loading the list of differences:
<p>
    <b>cfout firstname using secondEntry, id(uniqueid) nopunct saving(diffs)</b>
    <b>use diffs</b>
    <b>remove_brackets Master Using</b>
    <b>drop if Master == Using</b>
    <b>display _N</b>
<p>
    However, specifying <b>strcomp()</b> and <b>numcomp()</b> has advantages.  By dropping
    observations as soon as possible, it limits the number of differences
    that ever reach the final list, thereby reducing memory requirements --
    sometimes significantly so.
<p>
    <b>cfout</b> expects the programs specified to <b>strcomp()</b> and <b>numcomp()</b> to behave
    in certain ways.  If they do not, <b>cfout</b> may result in an error or produce
    incorrect results.
<p>
    The comparison programs have access to a full dataset, not just the
    variable pair specified to them.  However, they should not make
    assumptions about the rest of the dataset, and they should not modify it
    or its metadata, for instance, variable properties like variable labels
    or characteristics.  While the string comparison program is expected to
    make changes to the variable pair specified to it, it should not make
    assumptions about or modify their metadata.  The same holds for
    <b>numcomp()</b>, which should also not modify the variable pair, instead only
    creating an indicator variable.
<p>
    As a rule, the comparison programs should not use information not passed
    to them, as this may change across <b>cfout</b> versions.  The programs should
    restrict themselves to the variable names and their values.  Order
    usually does not matter, but <b>cfout</b> will always specify the master value
    variable first in the pair.  The master value variable retains its
    variable name from the master data, but the name of the using value
    variable will differ.
<p>
    The comparison programs are free to sort the data without restoring the
    original order.  In fact, this may reduce the time cost of the programs.
<p>
    Finally, note that the comparison programs may be run <b>noisily</b> so that
    error messages are displayed correctly.  To reduce this output, add
    <b>quietly</b> within the programs.
<p>
<p>
<a name="options"></a><b><u>Options</u></b>
<p>
        +-------------------+
    ----+ String comparison +------------------------------------------------
<p>
    <b>nopunct</b> specifies changes to string variables before they are compared.
        It removes the following characters before comparing: <b>! ' ?</b>  It
        replaces the following strings with a space: <b>( ) , -- . / : ;</b> It then
        removes leading or trailing blanks and multiple, consecutive internal
        blanks.
<p>
    <b>strcomp(</b><i>command</i><b>)</b> specifies a command to execute for all string variable
        pairs before they are compared.  See the remarks above for more
        information. <b>strcomp()</b> is implemented after the other string
        comparison options <b>lower</b>, <b>upper</b>, and <b>nopunct</b>.
<p>
        +---------+
    ----+ Options +----------------------------------------------------------
<p>
    <b>saving(</b><i>filename</i> [<b>,</b> <i>sopts</i>]<b>)</b> saves the list of differences to <i>filename</i> as a
        Stata dataset.  This "differences dataset" contains an observation
        for each difference and variables for the unique ID values, the name
        of the variable that differs, and the values in the master and using
        data.  The master and using values of string variables reflect the
        changes to the variables that the string comparison options
        implement.  The variables for the master and using values are string
        if and only if one of the compared variables is string.
<p>
        <b>all(</b><i>newvar</i><b>)</b> specifies that the differences dataset include all
            comparisons, not just differences.  It creates an indicator
            variable named <i>newvar</i> that is <b>1</b> if the master and using values
            differ and <b>0</b> if not.  If <b>all</b> is specified without <i>newvar</i>, the
            indicator variable is named <b>diff</b>.  If option <b>numcomp()</b> is
            specified, the <b>all()</b> indicator variable reflects the indicator
            variable created by the numeric comparison program.  In that
            case, <b>all()</b> may mark a different master-using value pair as not
            different, because <b>numcomp()</b> has specified that they are not
            relevantly different.  If option <b>labval</b> is specified, the <b>all()</b>
            indicator variable marks whether the values actually differ, not
            whether they do after being formatted:  two different values may
            appear the same after being formatted.
<p>
        <b>keepmaster(</b><i>varlist</i><b>)</b> specifies variables from the master data to
            include in the differences dataset. They are merged into the
            differences dataset using the unique ID variables.
<p>
        <b>keepusing(</b><i>varlist</i><b>)</b> specifies variables from the using data to include
            in the differences dataset. They are merged into the differences
            dataset using the unique ID variables.
<p>
        <b>properties(</b><i>popts</i><b>)</b> saves the properties of variables in the
            differences dataset's variable name variable as their own
            variables.  The variable properties of the master data are used.
<p>
            <b>char(</b><i>charnamelist</i><b>)</b> saves the characteristics <i>charnamelist</i> of
                variables in the differences dataset's variable name variable
                as their own variables.  Characteristic variable names are
                the combination of the characteristic variable name stub
                specified to <b>charstub()</b> and the name of the characteristic.
<p>
            <b>notes(</b><i>numlist</i>|<b>_all)</b> saves the notes of variables in the
                differences dataset's variable name variable as their own
                variables.  Notes variable names are the combination of the
                notes variable name stub specified to <b>notesstub()</b> and the
                note number.  <i>numlist</i> specifies the numbers of the notes to
                save.  If <b>_all</b> is specified, notes are saved from <b>1</b> to the
                maximum note number among the variables specified to <b>cfout</b>.
<p>
        <b>labval</b> specifies that the master and using values be labeled and
            formatted according to their value label and display format.  By
            default, the variables that contain the master and using values
            store numeric values formatted as <b>%24.0g</b>.  Value labels and
            display formats from the master data are used.  The variables for
            the master and using values will be stored as string.
<p>
    <b>numcomp(</b><i>command</i><b>)</b> specifies a command to determine differences within
        numeric variable pairs.  See the remarks above for more information.
<p>
    <b>dropdiff</b> specifies that variables that differ on every observation not be
        included. Results for these variables are not reported in the
        summary, returned in <b>r()</b> stored results, or saved in the differences
        dataset.  If options <b>strcomp()</b> and/or <b>numcomp()</b> are specified,
        <b>dropdiff</b> follows them in determining which observations are
        different.
<p>
    <b>nopreserve</b> is intended for use by programmers.  It speeds the comparison
        by not saving the original data, which normally can be restored
        should things go wrong or if you press <b>Break</b>. Programmers can specify
        this option if they have already preserved the original data.
        <b>nopreserve</b> does not affect the comparison.  If both options
        <b>nopreserve</b> and <b>saving()</b> are specified, the differences dataset is
        left in memory.
<p>
<p>
<a name="examples"></a><b><u>Examples</u></b>
<p>
    Compare the variables <b>region-no_good_at_all</b> of the datasets
    <b>firstEntry.dta</b> and <b>secondEntry.dta</b>, using variable <b>uniqueid</b> to match
    observations
        <b>. use firstEntry</b>
        <b>. cfout region-no_good_at_all using secondEntry, id(uniqueid)</b>
<p>
    Save the differences to the file <b>diffs.dta</b>
        <b>. cfout region-no_good_at_all using secondEntry, id(uniqueid)</b>
            <b>saving(diffs)</b>
        <b>. use diffs</b>
<p>
    Save the differences dataset with alternative variable names
        <b>. use firstEntry</b>
        <b>. cfout region-no_good_at_all using secondEntry, id(uniqueid)</b>
            <b>saving(diffs, variable(varname) masterval(master_value)</b>
            <b>usingval(using_value))</b>
        <b>. use diffs</b>
<p>
    Save all comparisons to the differences dataset, not just differences
        <b>. use firstEntry</b>
        <b>. cfout region-no_good_at_all using secondEntry, id(uniqueid)</b>
            <b>saving(diffs, all)</b>
        <b>. use diffs</b>
        <b>. count if diff</b>
<p>
    Add variable <b>deo</b> from <b>firstEntry.dta</b> to the differences dataset
        <b>. use firstEntry</b>
        <b>. cfout region-no_good_at_all using secondEntry, id(uniqueid)</b>
            <b>saving(diffs, keepmaster(deo))</b>
        <b>. use diffs</b>
<p>
    Save the storage types of the compared variables as an additional
    variable of the differences dataset
        <b>. use firstEntry</b>
        <b>. cfout region-no_good_at_all using secondEntry, id(uniqueid)</b>
            <b>saving(diffs, properties(type))</b>
        <b>. use diffs</b>
        <b>. generate isstrvar = strmatch(type, "str*")</b>
<p>
    Save the storage types of the compared variables with an alternative
    variable name
        <b>. use firstEntry</b>
        <b>. cfout region-no_good_at_all using secondEntry, id(uniqueid)</b>
            <b>saving(diffs, properties(type(storage_type)))</b>
        <b>. use diffs</b>
<p>
    For data that has been entered twice, compare the first and second
    entries, calculating discrepancy rates for each pair of data entry
    operators.  This yields the same results as the SSC program <b>cfby</b>.
        <b>. use firstEntry</b>
        <b>. * Variable deo identifies the data entry operator.</b>
        <b>. rename deo deo1</b>
        <b>. cfout region-no_good_at_all using secondEntry, id(uniqueid)</b>
            <b>saving(diffs, all keepmaster(deo1) keepusing(deo))</b>
        <b>. use diffs, clear</b>
        <b>. rename deo deo2</b>
        <b>. generate swap = deo1 &gt; deo2</b>
        <b>. generate t = deo1 if swap</b>
        <b>. replace deo1 = deo2 if swap</b>
        <b>. replace deo2 = t if swap</b>
        <b>. drop swap t</b>
        <b>. bysort deo*: generate total = _N</b>
        <b>. by deo*: egen total_diff = total(diff)</b>
        <b>. by deo*: generate error_rate = 100 * total_diff / total</b>
        <b>. format error_rate %9.2f</b>
        <b>. sort deo*</b>
        <b>. egen tag = tag(deo*)</b>
        <b>. list deo* total_diff total error_rate if tag, abbreviate(32) noobs</b>
<p>
    For twice entered data and a list of correct values, determine the error
    rates of individual data entry operators (not pairs as above)
        <b>. use firstEntry</b>
        <b>. readreplace using correctedValues.csv, id(uniqueid)</b>
            <b>variable(question) value(correctvalue)</b>
        <b>. cfout region-no_good_at_all using firstEntry,  id(uniqueid)</b>
            <b>saving(diff1, all keepusing(deo))</b>
        <b>. cfout region-no_good_at_all using secondEntry, id(uniqueid)</b>
            <b>saving(diff2, all keepusing(deo))</b>
        <b>. use diff1, clear</b>
        <b>. append using diff2</b>
        <b>. bysort deo: generate total = _N</b>
        <b>. by deo: egen total_diff = total(diff)</b>
        <b>. by deo: generate error_rate = 100 * total_diff / total</b>
        <b>. format error_rate %9.2f</b>
        <b>. sort deo</b>
        <b>. egen tag = tag(deo)</b>
        <b>. list deo total_diff total error_rate if tag, abbreviate(32) noobs</b>
<p>
<p>
<a name="results"></a><b><u>Stored results</u></b>
<p>
    <b>cfout</b> stores the following in <b>r()</b>:
<p>
    Scalars
      <b>r(N)</b>                number of values compared; includes only the
                            variables of <b>r(varlist)</b>
      <b>r(discrep)</b>          number of differences; includes only the variables
                            of <b>r(varlist)</b>
      <b>r(Nonlym)</b>           number of observations only in the master dataset
      <b>r(Nonlyu)</b>           number of observations only in the using dataset
<p>
    Macros
      <b>r(varlist)</b>          variables compared; does not include <b>r(varonlym)</b>,
                            <b>r(difftype)</b>, or (if option <b>dropdiff</b> is specified)
                            <b>r(alldiff)</b>
      <b>r(varonlym)</b>         variables only in the master dataset
      <b>r(difftype)</b>         variables that are numeric in one dataset and
                            string in the other
      <b>r(alldiff)</b>          variables that differ on every observation
<p>
<p>
<a name="acknowledgments"></a><b><u>Acknowledgments</u></b>
<p>
    Christopher Robert of the Harvard Kennedy School suggested option
    <b>nonumeric</b>.
<p>
<p>
<a name="authors"></a><b><u>Authors</u></b>
<p>
    Ryan Knight
    Matthew White
<p>
    For questions or suggestions, submit a GitHub issue or e-mail
    researchsupport@poverty-action.org.
<p>
<p>
<b><u>Also see</u></b>
<p>
    Help:  <b>[D] cf</b>, <b>[D] compare</b>, <b>[P] dta_equal</b>, <b>[D] datasignature</b>
<p>
    User-written:  <b>readreplace</b>, <b>bcstats</b>, <b>mergeall</b>
</pre>
