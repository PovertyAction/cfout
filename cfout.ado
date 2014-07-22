*! v1 by Ryan Knight 10may2011
pr cfout, rclass
	vers 10.1

	/* ---------------------------------------------------------------------- */
					/* check input for errors	*/

	/*
	Version 2 syntax:

	syntax [varlist] using/,
		/* main */
		id(varlist)
		/* string comparison */
		[Lower Upper NOPunct]
		/* other */
		[SAving(str asis) NOString NONUMeric DROPDiff NOMATch]
	*/

	cap cfout_syntax 2 `0'
	if _rc {
		cap cfout_syntax 1 `0'
		if !_rc {
			* Do not suppress warning messages.
			cfout_syntax 1 `0'
		}
		else {
			cfout_syntax 2 `0'
			/*NOTREACHED*/
		}
	}

	* Check the ID in the master data.
	loc id : list uniq id
	check_id `id', data("the master data")

	* Check -lower- and -upper-.
	if "`lower'" != "" & "`upper'" != "" {
		* cscript 18
		di as err "options lower and upper are mutually exclusive"
		ex 198
	}

	* Check -strcomp()-.
	if `:length loc strcomp' ///
		parse_cmd_opt strcomp, syntax(, *): `strcomp'

	* Parse -saving()-.
	if `:length loc saving' {
		parse_saving, id(`id'): `saving'
		loc saving_args "`s(save_diffs)'"
	}

	* Define `cfvars', the list of variables to compare.
	loc cfvars : list uniq varlist

	* Remove `id' from `cfvars'.
	if "`:list cfvars & id'" == "" ///
		loc warnid 0
	else {
		loc cfvars : list cfvars - id
		loc warnid 1
	}

	* Define `numvarsm'.
	qui ds `cfvars', has(t numeric)
	* "m" suffix for "master": "numvarsm" for "numeric variables master."
	loc numvarsm `r(varlist)'

	* Define ID locals.
	qui ds `id', has(t numeric)
	loc idnumm `r(varlist)'
	foreach var of loc id {
		loc idtypes `idtypes' `:type `var''
		loc idformats `idformats' `:form `var''

		loc varlab st_varlabel(st_local("var"))
		mata: st_local("idvarlabs", st_local("idvarlabs") + ///
			sprintf("%f:%s", strlen(`varlab'), `varlab'))
	}

	if "`nopreserve'" == "" ///
		preserve

	keep `id' `cfvars'
	sort `id'

	tempfile tempmaster
	qui sa `tempmaster', nol

	* Save value label names and the associations between
	* variables and value labels.
	qui lab dir
	loc labnames `r(names)'
	qui ds, has(t numeric)
	foreach var in `r(varlist)' {
		loc labassoc `labassoc' `var' "`:val lab `var''"
	}

	drop _all
	tempfile vallabs
	qui sa `vallabs', empty o

	qui u `"`using'"', clear

	* Check -id()-.
	foreach var of loc id {
		cap conf var `var', exact
		if _rc {
			* cscript 20
			di as err "variable `var' not found in using data" _n ///
				"(error in option {bf:id()})"
			ex 111
		}
	}
	check_id `id', data("the using data")

	* Check that each ID variable is numeric in both datasets or
	* string in both datasets.
	qui ds `id', has(t numeric)
	* "u" suffix for "using": "idnumu" for "ID numeric using."
	loc idnumu `r(varlist)'
	if !`:list idnumm === idnumu' {
		foreach var of loc id {
			if `:list var in idnumm' + `:list var in idnumu' == 1 {
				* cscript 21
				loc typem : word `:list posof "`var'" in id' of `idtypes'
				loc typeu : type `var'
				di as err "option id(): variable `var' is " ///
					"`typem' in master but `typeu' in using data"
				ex 106
			}
		}
	}

					/* check input for errors	*/
	/* ---------------------------------------------------------------------- */

	* Error messages stop here; warnings start.

	if `warnid' ///
		di as txt "note: ID variables will not be compared."

	* Variables not in the using data
	unab all : _all
	loc varonlym : list cfvars - all
	if "`varonlym'" != "" {
		p
		di "note: the following variables are not in the using data:"
		di as res "`varonlym'
		di "{p_end}"
		loc cfvars : list cfvars - varonlym
		loc numvarsm : list numvarsm - varonlym
	}
	* Return stored result.
	ret loc varonlym `varonlym'

	* Variables that are numeric in one dataset and string in the other
	qui ds `cfvars', has(t numeric)
	loc numvarsu `r(varlist)'
	loc numonlym : list numvarsm - numvarsu
	loc numonlyu : list numvarsu - numvarsm
	loc difftype : list numonlym | numonlyu
	if "`difftype'" != "" {
		p
		di "note: the following variables are numeric in one dataset and"
		di "string in the other and will not be compared:"
		di as res "`difftype'
		di "{p_end}"
		loc cfvars : list cfvars - difftype
		loc numvarsm : list numvarsm - difftype
	}
	loc numvars `numvarsm'
	* Return stored result.
	ret loc difftype `difftype'

	* Implement -nostring-.
	if "`nostring'" != "" ///
		loc cfvars `numvars'
	* Implement -nonumeric-.
	if "`nonumeric'" != "" ///
		loc cfvars : list cfvars - numvars

	keep `id' `cfvars'
	sort `id'

	* Use temporary variable names to prevent name conflicts with
	* `cfvars' in the master data.
	foreach var of loc cfvars {
		tempvar cftemp
		ren `var' `cftemp'
		loc cftemps : list cftemps | cftemp
	}

	* Merge, using the value labels and ID metadata from the master data.
	* Remove ID characteristics from the using data.
	foreach var of loc id {
		loc chars : char `var'[]
		foreach char of loc chars {
			char `var'[`char']
		}
	}
	* Merge.
	tempvar merge
	qui merge `id' using `tempmaster', uniq keep(`cfvars') _merge(`merge')
	* Use the ID metadata from the master data.
	foreach var of loc id {
		gettoken format idformats : idformats
		format `var' `format'
	}
	mata: attach_varlabs("id", "idvarlabs")
	* Add value labels from the master data, including orphans.
	foreach lab of loc labnames {
		cap lab drop `lab'
	}
	qui append using `vallabs'
	while `:list sizeof labassoc' {
		gettoken var labassoc : labassoc
		gettoken lab labassoc : labassoc
		cap conf var `var', exact
		if !_rc ///
			lab val `var' `lab'
	}

	* Observations in only one dataset
	foreach data in master using {
		* "ab" for "abbreviation"
		loc ab = substr("`data'", 1, 1)
		loc result = cond("`data'" == "master", 2, 1)

		qui cou if `merge' == `result'
		* Return stored result.
		ret sca Nonly`ab' = r(N)
		if `return(Nonly`ab')' & "`nomatch'" == "" {
			di as txt "note: the following observations are only in " ///
				"the `data' data:"
			sort `id'
			li `id' if `merge' == `result', ab(32) noo
			di
		}
	}
	qui keep if `merge' == 3

	loc nmerged = _N

	* Implement string comparison options.
	forv i = 1/`:list sizeof cfvars' {
		loc var  : word `i' of `cfvars'
		loc temp : word `i' of `cftemps'
		cap conf str var `var'
		if !_rc {
			qui cfsetstr `var' `temp', ///
				`lower' `upper' `nopunct' strcomp(`strcomp')
		}
	}

	if !`:length loc saving' {
		mata: cfout("discrep", "alldiff", ///
			"cfvars", "cftemps", "`dropdiff'" != "")
	}
	else {
		save_diffs, id(`id') cfvars(`cfvars') cftemps(`cftemps') ///
			`saving_args' `dropdiff'
		loc discrep = r(discrep)
		loc alldiff `r(alldiff)'
	}

	* Variables different on every observation
	if "`alldiff'" != "" {
		p
		di "note: the following variables differ on every observation" _c
		if "`dropdiff'" != "" ///
			di " and will not be compared" _c
		di ":"
		di as res "`alldiff'"
	}
	if "`dropdiff'" != "" ///
		loc cfvars : list cfvars - alldiff
	* Return stored result.
	ret loc alldiff `alldiff'

	* Return stored results.
	ret loc varlist `cfvars'
	ret sca N = `nmerged' * `:list sizeof cfvars'
	ret sca discrep = `discrep'

	* Display summary.
	display_summary `return(discrep)' `return(N)'

	* Display warning messages.
	if `warnid' | "`return(varonlym)'`return(difftype)'" != "" | ///
		"`dropdiff'" != "" & "`return(alldiff)'" != "" {
		di as txt "note: not all variables specified were compared."
	}
	if "`nomatch'" == "" {
		if return(Nonlym) {
			p
			di "note: not all observations were compared;"
			di "there are observations only in the master data."
			di "{p_end}"
		}
		if return(Nonlyu) {
			p
			di "note: not all observations were compared;"
			di "there are observations only in the using data."
			di "{p_end}"
		}
	}
end


/* -------------------------------------------------------------------------- */
					/* error message programs	*/

pr assert_is_opt
	mata: st_local("name", (regexm(st_local("0"), "^(.*)\(\)$") ? ///
		regexs(1) : st_local("0")))
	if "`name'" != strtoname("`name'") | strpos("`name'", "`") ///
		err 198
end

pr error_overlap
	syntax anything(name=overlap id=overlap), opt1(str) opt2(str) [what(str)]

	* Parse `overlap'.
	gettoken overlap rest : overlap
	if !`:length loc overlap' | `:length loc rest' ///
		err 198

	* Parse -opt*()-.
	forv i = 1/2 {
		loc 0 "`opt`i''"
		syntax anything(name=opt`i'), [SUBopt]
		loc temp : subinstr loc opt`i' "(" "", cou(loc count)
		if !`count' ///
			loc opt`i' `opt`i''()
		loc sub`i' = "`subopt'" != ""
	}

	if "`what'" != "" ///
		di as err "`what' " _c
	loc options = cond(`sub1' & `sub2', "sub", "") + "options"
	di as err `"`overlap' cannot be specified to "' ///
		"both `options' `opt1' and `opt2'"
	if !(`sub1' & `sub2') ///
		ex 198
end

pr error_saving
	syntax anything(name=rc id="return code"), [SUBopt(str)]

	if "`subopt'" != "" {
		assert_is_opt `subopt'
		di as err "invalid `subopt' suboption"
	}
	di as err "invalid saving() option"
	ex `rc'
end

pr warn_deprecated
	syntax anything(name=old), [new(str asis)]

	assert_is_opt `old'

	if !`:length loc new' ///
		di as txt "note: option {cmd:`old'} is deprecated and will be ignored."
	else {
		loc 0 "`new'"
		syntax anything(name=new), [SUBopt]

		gettoken new rest : new
		if `:length loc rest' ///
			err 198

		loc option = cond("`subopt'" != "", "suboption", "option")
		di as txt "note: option {cmd:`old'} is deprecated; " ///
			"use `option' {cmd:`new'} instead."
	}
end

					/* error message programs	*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* parse user input		*/

pr cfout_syntax
	gettoken version 0 : 0

	* Check that `0' satisfies version `version' syntax.

	if `version' == 1 {
		#d ;
		syntax [varlist] using/,
			/* main */
			id(varname)
			/* string comparison */
			[Lower Upper NOPunct]
			/* other */
			[NAme(str) Format(str) ALTid(varname) replace NOString NOMATch]
		;
		#d cr

		di as txt "note: you are using old {cmd:cfout} syntax; " ///
			"see {helpb cfout} for new syntax."

		if `"`name'"' == "" ///
			loc name discrepancy report.csv
		else ///
			warn_deprecated name(), new("saving()")
		if "`replace'" != "" ///
			warn_deprecated replace, new("saving(,replace)", sub)
		loc saving "`"`name'"', csv `replace'"

		if "`format'" != "" ///
			warn_deprecated format()
		if "`altid'" != "" ///
			warn_deprecated altid()

		di as txt "note: option {cmd:dropdiff} is implied."
		loc dropdiff dropdiff
	}
	else if `version' == 2 {
		#d ;
		syntax [varlist] using/,
			/* main */
			id(varlist)
			/* string comparison */
			[Lower Upper NOPunct STRComp(str asis)]
			/* other */
			[SAving(str asis) NOString NONUMeric DROPDiff NOMATch NOPreserve]
		;
		#d cr
	}
	else {
		err 198
	}

	mata: st_local("names", invtokens(st_dir("local", "macro", "*")'))
	foreach name of loc names {
		c_local `name' "``name''"
	}
end

pr check_id
	syntax varlist, data(str)

	cap isid `varlist', missok
	if _rc {
		* cscript 15
		* "nid" for "number of IDs"
		loc nid : list sizeof varlist
		di as err "option id(): " plural(`nid', "variable") " `varlist' " ///
			plural(`nid', "does", "do") " not uniquely identify " ///
			"the observations in `data'"
		ex 459
	}

	if c(stata_version) >= 13 {
		qui ds `varlist', has(t strL)
		if "`r(varlist)'" != "" {
			* cscript 16
			loc nothe = regexr("`data'", "^the ", "")
			di as err "option id(): `nothe':"
			_nostrl error : `r(varlist)'
			/*NOTREACHED*/
		}
	}
end

* Syntax: parse_cmd_opt option_name, syntax(): command
* Parse an option named option_name that takes a command as its argument,
* checking that it matches the syntax specified to option -syntax()-.
pr parse_cmd_opt
	_on_colon_parse `0'
	loc 0			"`s(before)'"
	loc command		"`s(after)'"
	syntax name(name=opt), [syntax(str)]

	gettoken cmdname 0 : command, p(", ")
	cap noi syntax `syntax'
	if _rc {
		di as err "(error in option {bf:`opt'()})"
		ex `=_rc'
	}
end

pr parse_saving, sclass
	_on_colon_parse `0'
	loc 0 "`s(before)'"
	syntax, id(varlist)
	loc 0 "`s(after)'"

	cap noi syntax anything(name=fn id=filename equalok everything), ///
		[Variable(name) MASterval(name) USingval(name) All(name) All2 ///
		csv replace]
	if _rc {
		error_saving `=_rc'
		/*NOTREACHED*/
	}

	* Parse `fn'.
	gettoken fn rest : fn
	if `:length loc rest' {
		di as err "invalid filename"
		error_saving 198
		/*NOTREACHED*/
	}

	* Add a file extension to `fn' if necessary.
	mata: if (pathsuffix(st_local("fn")) == "") ///
		st_local("fn", st_local("fn") + ///
		(st_local("csv") != "" ? ".csv" : ".dta"));;

	* Check `fn' and -replace-.
	cap conf new f `"`fn'"'
	if ("`replace'" == "" & _rc) | ("`replace'" != "" & !inlist(_rc, 0, 602)) {
		* cscript 8
		cap noi conf new f `"`fn'"'
		error_saving `=_rc'
		/*NOTREACHED*/
	}

	* Check -all()- and -all-.
	if "`all'" != "" & "`all2'" != "" {
		di as err "suboptions all() and all are mutually exclusive"
		error_saving 198
		/*NOTREACHED*/
	}

	* Default variable names
	if "`variable'" == "" ///
		loc variable Question
	if "`masterval'" == "" ///
		loc masterval Master
	if "`usingval'" == "" ///
		loc usingval Using
	if "`all2'" != "" ///
		loc all diff

	* Check variable names.
	loc opts variable masterval usingval all
	while `:list sizeof opts' {
		gettoken opt1 opts : opts
		foreach opt2 of loc opts {
			loc overlap : list `opt1' & `opt2'
			if "`overlap'" != "" {
				* cscript 29
				gettoken first : overlap
				error_overlap `first', what(variable) ///
					opt1(`opt1', sub) opt2(`opt2', sub)
				error_saving 198
				/*NOTREACHED*/
			}
		}

		loc overlap : list id & `opt1'
		if "`overlap'" != "" {
			* cscript 29
			gettoken first : overlap
			error_overlap `first', what(variable) ///
				opt1(id) opt2("saving(,`opt1'())", sub)
			/*NOTREACHED*/
		}
	}

	* Return arguments for -save_diffs-.
	loc args fn(`"`fn'"') ///
		variable(`variable') masterval(`masterval') usingval(`usingval') ///
		all(`all') `csv' `replace'
	sret loc save_diffs "`args'"
end

					/* parse user input		*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* display programs		*/

pr p
	di as txt "{p 0 4 2}"
end

pr display_summary
	args discrep N

	loc line1a "Number of differences: "
	loc line1b `discrep'
	loc line2a "Number of values compared: "
	loc line2b `N'
	loc line3a "Percent differences: "
	loc line3b = strofreal(100 * `discrep' / `N', "%9.3f") + "%"
	loc linelen = max(strlen("`line1a'`line1b'"), ///
		strlen("`line2a'`line2b'"), strlen("`line3a'`line3b'"))
	loc col _col(3)
	#d ;
	di	_n
		`col' "{hline `linelen'}" _n
		`col' as txt "`line1a'" as res "`line1b'" _n
		`col' as txt "`line2a'" as res "`line2b'" _n
		`col' as txt "`line3a'" as res "`line3b'" _n
		`col' "{hline `linelen'}"
	;
	#d cr
end

					/* display programs		*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* string comparison	*/

pr cfsetstr
	syntax varlist(min=2 max=2), [lower upper NOPUNCT strcomp(str asis)]

	foreach var of loc varlist {
		if "`lower'`upper'" != "" {
			qui replace `var' = `lower'`upper'(`var')
		}

		if "`nopunct'" != "" {
			foreach c in ! ? "'" {
				qui replace `var' = subinstr(`var', "`c'", "", .)
			}
			foreach c in . , -- / ; : ( ) {
				qui replace `var' = subinstr(`var', "`c'", " ", .)
			}
			qui replace `var' = itrim(strtrim(`var'))
		}
	}

	if `:length loc strcomp' {
		gettoken cmd opts : strcomp, p(", ")
		cap noi `cmd' `varlist'`opts'
		if _rc {
			di as err "(error in option {bf:strcomp()})"
			ex `=_rc'
		}
	}
end

					/* string comparison	*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* save differences dataset		*/

pr save_diffs, rclass
	#d ;
	syntax,
		/* main */
		id(varlist) [cfvars(varlist) cftemps(varlist)]
		/* -saving()- arguments */
		fn(str) variable(name) masterval(name) usingval(name) [all(name)]
		[csv replace]
		/* other */
		[dropdiff]
	;
	#d cr

	* Index `id'.
	* "ididx" for "ID index"
	tempvar ididx
	gen double `ididx' = _n
	qui compress `ididx'
	preserve
	keep `id' `ididx'
	sort `ididx'
	tempfile idmap
	qui sa `idmap'
	restore
	drop `id'

	#d ;
	mata: cfout(
		/* output */				"discrep", "alldiff",
		/* comparison variables */	"cfvars", "cftemps",
		/* other */					"`dropdiff'" != "",
		/* -id()- */				"ididx",
		/* new variable names */	"variable", "masterval", "usingval", "all");
	#d cr

	tempvar order
	gen double `order' = _n

	ret sca discrep = `discrep'

	* Merge back in the ID variables.
	sort `ididx'
	tempvar merge
	qui merge `ididx' using `idmap', uniqus _merge(`merge')
	qui drop if `merge' == 2
	drop `ididx' `merge'

	* Sort so that within `id', Question remains sorted by
	* the original variable order.
	sort `id' `order'
	drop `order'

	order `id' `variable' `all' `masterval' `usingval'

	if "`csv'" == "" {
		* Remove the dataset's label and characteristics.
		lab data
		loc chars : char _dta[]
		foreach char of loc chars {
			char _dta[`char']
		}

		qui compress
		qui sa `"`fn'"', `replace'
	}
	else {
		qui ds, has(t numeric)
		loc numvars `r(varlist)'
		if "`numvars'" != "" {
			foreach var of loc numvars {
				lab val `var'
			}
			form `numvars' %24.0g
		}

		qui outsheet using `"`fn'"', c `replace'
	}

	ret loc alldiff `alldiff'
end

					/* save differences dataset		*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* type definitions, etc.	*/

vers 10.1

* Convert real x to string using -strofreal(x, `RealFormat')-.
loc RealFormat	""%24.0g""

loc RS	real scalar
loc RR	real rowvector
loc RC	real colvector
loc RM	real matrix
loc SS	string scalar
loc SR	string rowvector
loc SC	string colvector
loc SM	string matrix
loc TS	transmorphic scalar
loc TR	transmorphic rowvector
loc TC	transmorphic colvector
loc TM	transmorphic matrix

loc boolean		`RS'
loc True		1
loc False		1

* A local macro name
loc lclname		`SS'

mata:

					/* type definitions, etc.	*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* interface with Stata		*/

void st_sviewL(`SM' V, `RM' i, `TR' j)
{
	`RS' n, ctr
	`boolean' any

	any = `False'
	ctr = 0
	n = length(j)
	while (++ctr <= n & !any)
		any = st_vartype(j[ctr]) == "strL"

	if (any)
		V = st_sdata(i, j)
	else {
		pragma unset V
		st_sview(V, i, j)
	}
}

`SS' smallest_vartype(`TC' var)
{
	`RS' min, max
	`SS' strpound

	if (eltype(var) == "real") {
		if (!all(var :== floor(var)))
			return("double")
		else {
			min = min(var)
			max = max(var)

			if (min >= -127 & max <= 100)
				return("byte")
			if (min >= -32767 & max <= 32740)
				return("int")
			if (min >= -9999999 & max <= 9999999)
				return("float")
			if (min >= -2147483647 & max <= 2147483620)
				return("long")
			return("double")
		}
	}
	else if (eltype(var) == "string") {
		max = max(strlen(var))
		strpound = sprintf("str%f", min((max((max, 1)), c("maxstrvarlen"))))
		if (c("stata_version") < 13)
			return(strpound)
		return(max <= c("maxstrvarlen") ? strpound : "strL")
	}
	else {
		_error("invalid var")
	}
	/*NOTREACHED*/
}

void st_store_new(`TC' vals, `SS' name, |`SS' varlab)
{
	`RS' idx, nobs

	if (!anyof(("real", "string"), eltype(vals)))
		_error("invalid vals")

	nobs = rows(vals)
	if (nobs > st_nobs())
		st_addobs(nobs - st_nobs())

	idx = st_addvar(smallest_vartype(vals), name)
	if (nobs) {
		if (eltype(vals) == "real")
			st_store((1, nobs), idx, vals)
		else
			st_sstore((1, nobs), idx, vals)
	}

	st_varlabel(idx, varlab)
}

void attach_varlabs(`lclname' _varlist, `lclname' _varlabs)
{
	`RS' pos, len, n, i
	`SS' varlabs
	`SR' vars

	vars = tokens(st_local(_varlist))
	varlabs = st_local(_varlabs)

	n = length(vars)
	for (i = 1; i <= n; i++) {
		pos = strpos(varlabs, ":")
		assert(pos)
		len = strtoreal(substr(varlabs, 1, pos - 1))
		assert(len == floor(len) & len >= 0 & len <= 80)
		st_varlabel(vars[i], substr(varlabs, pos + 1, len))
		varlabs = substr(varlabs, pos + len + 1, .)
	}
	assert(varlabs == "")
}

					/* interface with Stata		*/
/* -------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------- */
					/* compare datasets		*/

void resize_colvector(`TC' v, `RS' n)
{
	`RS' ncur
	`SS' eltype
	`TS' miss

	ncur = length(v)
	if (n > ncur) {
		eltype = eltype(v)
		if (eltype == "real")
			miss = .
		else if (eltype == "string")
			miss = ""
		else
			_error("invalid eltype")
		v = v \ J(n - ncur, 1, miss)
	}
	else if (n < ncur)
		v = v[|1 \ n|]
}

void diff_dta_resize(pointer(`TC') rowvector v, `RS' n)
{
	`RS' nv, i

	nv = length(v)
	for (i = 1; i <= nv; i++)
		resize_colvector(*v[i], n)
}

// Compare the master and using datasets,
// optionally creating the differences dataset.
void cfout(
	/* output */				`lclname' _discrep, `lclname' _alldiff,
	/* comparison variables */	`lclname' _cfvars, `lclname' _cftemps,
	/* other */					`boolean' _dropdiff,
	/* ---------------------------------------------------------------------- */
					/* -saving()-			*/
	/* ---------------------------------------------------------------------- */
	/* -id()- */				|`lclname' _id,
	/* new variable names */
	`lclname' _variable, `lclname' _masterval, `lclname' _usingval,
	`lclname' _all)
{
	// Constants
	`RS' N_ARGS, N_ARGS_SAVING

	// "n" prefix for "number of": "ncomps" for "number of comparisons."
	`RS' firstrow, lastrow, vardiffs, nvars, ndiffs, ncomps, i
	`RC' id_merge, id_diff, all, diff, select
	`SS' id_name, all_name
	`SR' cfvars, cftemps, strvars, alldiff
	`SC' var
	`TC' master, usingval
	// "mu" for "master/using"
	`TM' mu, comps
	`boolean' diffdta
	pointer(`TC') rowvector cols

	N_ARGS = 5
	N_ARGS_SAVING = 5
	assert(anyof((N_ARGS, N_ARGS + N_ARGS_SAVING), args()))
	diffdta = args() == N_ARGS + N_ARGS_SAVING

	cfvars  = tokens(st_local(_cfvars))
	cftemps = tokens(st_local(_cftemps))
	nvars = length(cfvars)
	assert(nvars == length(cftemps))

	// Variables of the differences dataset
	if (diffdta) {
		// id_merge is a view onto the ID variable in the merged dataset.
		// It must be the first variable in the dataset so that
		// the view does not need to be updated.
		id_name = st_local(_id)
		stata("order " + id_name)
		pragma unset id_merge
		st_view(id_merge, ., id_name)
		assert(cols(id_merge) == 1)

		for (i = 1; i <= nvars; i++) {
			if (st_isstrvar(cfvars[i])) {
				pragma unset strvars
				strvars = strvars, cfvars[i]
			}
		}

		id_diff = J(0, 1, .)
		var = J(0, 1, "")
		master = usingval = J(0, 1, (length(strvars) ? "" : .))
		cols = &id_diff, &var, &master, &usingval

		all_name = st_local(_all)
		if (all_name != "") {
			all = J(0, 1, .)
			cols = cols, &all
		}
	}

	ndiffs = 0
	firstrow = 1
	lastrow = 0
	for (i = 1; i <= nvars; i++) {
		// Make mu a view onto cfvars[i] and cftemps[i].
		pragma unset mu
		if (st_isnumvar(cfvars[i]))
			st_view(mu, ., (cfvars[i], cftemps[i]))
		else
			st_sviewL(mu = "", ., (cfvars[i], cftemps[i]))

		diff = mu[,1] :!= mu[,2]
		vardiffs = sum(diff)

		if (vardiffs == st_nobs()) {
			pragma unset alldiff
			alldiff = alldiff, cfvars[i]

			if (_dropdiff & diffdta & anyof(strvars, cfvars[i])) {
				strvars = select(strvars, strvars :!= cfvars[i])
				if (!length(strvars)) {
					// Convert master usingval to real.
					if (!lastrow)
						master = usingval = J(0, 1, .)
					else {
						master   = strtoreal(master)
						usingval = strtoreal(usingval)
					}
				}
			}
		}

		if (!(_dropdiff & vardiffs == st_nobs())) {
			ndiffs = ndiffs + vardiffs

			if (diffdta) {
				// -saving(, all)-
				if (all_name == "") {
					select = diff
					ncomps = vardiffs
				}
				else {
					ncomps = st_nobs()
					select = J(ncomps, 1, 1)
				}

				if (ncomps) {
					// Store the master and using values in comps.
					if (st_isstrvar(cfvars[i]) | !length(strvars))
						comps = select(mu, select)
					else
						comps = strofreal(select(mu, select), `RealFormat')

					// Add observations to the differences dataset.
					lastrow = firstrow + ncomps - 1
					if (lastrow > length(id_diff))
						diff_dta_resize(cols, 2 * lastrow)
					id_diff[|firstrow \ lastrow|] = select(id_merge, select)
					var[|firstrow \ lastrow|] = J(ncomps, 1, cfvars[i])
					master[|firstrow \ lastrow|] = comps[,1]
					usingval[|firstrow \ lastrow|] = comps[,2]
					if (all_name != "")
						all[|firstrow \ lastrow|] = diff
					firstrow = firstrow + ncomps
				}
			}
		}

		// This should require no view updates.
		st_dropvar((cfvars[i], cftemps[i]))
	}

	// Load the differences dataset.
	if (diffdta) {
		diff_dta_resize(cols, lastrow)

		st_dropvar(.)
		st_store_new(id_diff, id_name)
		st_store_new(var, st_local(_variable), "Variable name")
		st_store_new(master, st_local(_masterval), "Master value")
		st_store_new(usingval, st_local(_usingval), "Using value")
		if (all_name != "")
			st_store_new(all, all_name, "Master and using values differ")
	}

	st_local(_discrep, strofreal(ndiffs, `RealFormat'))
	st_local(_alldiff, invtokens(alldiff))
}

					/* compare datasets		*/
/* -------------------------------------------------------------------------- */

end
