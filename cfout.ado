*! v1 by Ryan Knight 10may2011
pr cfout, rclass
	vers 10.1

	/* ---------------------------------------------------------------------- */
					/* check input for errors	*/

	/*
	Version 2 syntax:

	syntax [varlist] using/,
		/* main */
		id(varname)
		/* string comparison */
		[Lower Upper NOPunct]
		/* other */
		[SAving(str asis) NOString NOMATch]
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

	* Parse -saving()-.
	if `:length loc saving' ///
		parse_saving `saving'

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
	}

	preserve

	keep `id' `cfvars'
	sort `id'

	tempfile tempmaster
	qui sa `tempmaster', nol

	qui u `"`using'"', clear

	* Check -id()-.
	foreach var of loc id {
		cap conf var `var', exact
		if _rc {
			* cscript 20
			di as err "variable `var' not found in using data" _n ///
				"(error in option {bf:x()})"
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

	keep `id' `cfvars'
	sort `id'

	* Use temporary variable names to prevent name conflicts with
	* `cfvars' in the master data.
	foreach var of loc cfvars {
		tempvar cftemp
		ren `var' `cftemp'
		loc cftemps : list cftemps | cftemp
	}

	* Merge.
	tempvar merge
	qui merge `id' using `tempmaster', uniq keep(`cfvars') _merge(`merge')

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

	* Temporary code: continue to use the _cf prefix.
	forv i = 1/`:list sizeof cfvars' {
		loc var  : word `i' of `cfvars'
		loc temp : word `i' of `cftemps'
		ren `var' _cf`var'
		ren `temp' `var'
	}

	quietly {

	* Format string vars so you aren't counting differences in case, punctuation or spacing as errors
	if "`upper'`lower'`nopunct'" != "" {
		qui ds `cfvars', has(type string)
		loc strvarsu `r(varlist)'
		if "`strvarsu'" != "" {
			loc strvarsu " `strvarsu'"
			loc strvarsm : subinstr loc strvarsu " " " _cf", all
			cfsetstr `strvarsm' `strvarsu', `upper' `lower' `nopunct'
		}
	}

	mata: o = J(1,4,"")

	* Make id a single variable if it is a varlist. This feature is not documented
	local numids: word count `id'
	if `numids' > 1 {
		local labelid true
		tempname idlab
		egen _id = group(`id'), lname(`idlab')
		local oldid: subinstr local id " " "_", all
		local oldid = abbrev("`oldid'", 32)
		local id _id
	}
	else {
		* Encode ID if it's a string to make sending it to mata easier
		cap confirm numeric variable `id'
		if _rc {
			local labelid true
			tempname idlab
			encode `id', gen(_`id') label(`idlab')
			local oldid `id'
			local id _`id'
		}
	}

	tempvar isdiff
	gen `isdiff' =.
	local q = 0
	local N _N

	* Run the discrepency.
	foreach X of loc cfvars {
		cap count if `X' != _cf`X'
		if _rc {
			count if mi(`X') & mi(_cf`X')
			if `r(N)'==`N' {
				local q =`q' + `N'
				continue
			}
			cap tostring `X' _cf`X', replace
			cap confirm numeric variable `X' _cf`X'
			if _rc {
				local diftype `X'
				continue
			}
			cfsetstr `X' _cf`X', `upper' `lower' `nopunct'
			count if `X' != _cf`X'
		}
		if `r(N)'==0 {
			local q =`q' + `N'
		}
		else if `r(N)'==`N' {
			local messyvars `messyvars' `X'
		}
		else {
			local q = `q' + `N'
			replace `isdiff'=cond(`X'!=_cf`X',1,0)
			cap confirm numeric variable `X'
			if _rc {
				mata: st_view(i=.,.,"`id'","`isdiff'")
				mata: st_sview(s=.,.,("_cf`X'", "`X'"),"`isdiff'")
				mata: n = J(rows(s),1,"`X'")
				mata: o = (o \ (strofreal(i),s,n))
			}
			else {
				mata: st_view(r=.,.,("`id'", "_cf`X'", "`X'"),"`isdiff'")
				mata: n = J(rows(r),1,"`X'")
				mata: o = (o \(strofreal(r),n))
			}
		}
	}

	drop _all
	gen str244 `id'=""
	gen str32 Question=""
	gen str244 Master=""
	gen str244 Using=""
	mata: st_addobs(rows(o))
	mata: st_sstore(.,("`id'", "Master", "Using", "Question"),o)
	drop if `id'==""
	local e = _N

	gen order = .									// Sort by original variable order
	tokenize `cfvars'
	local i = 1
	while "``i''" != "" {
		replace order = `i' if Question == "``i''"
		local ++i
	}
	sort `id' order

	if "`labelid'" == "true" {
		destring `id', replace force
		label values `id' `idlab'
		rename `id' `oldid'
		local id `oldid'
	}

	}

	loc cfvars : list cfvars - messyvars
	if "`messyvars'" !="" {
		di as err "The following variables were not compared because they are different in every observation:"
		di as res "`messyvars'"
	}

	* Return stored results.
	ret loc varlist `cfvars'
	ret loc alldiff `messyvars'
	ret sca N = `nmerged' * `:list sizeof cfvars'
	ret sca discrep = `e'

	* Display summary.
	display_summary `return(discrep)' `return(N)'

	* Display warning messages.
	if `warnid' | ///
		"`return(varonlym)'`return(difftype)'`return(alldiff)'" != "" {
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

	cap mata: mata drop i
	cap mata: mata drop r
	cap mata: mata drop s
	cap mata: mata drop o
	cap mata: mata drop n

	if `:length loc saving' ///
		save_file, id(`id') `saving_args'
end

pr cfsetstr
	syntax varlist, [NOPUNCT upper lower]

	foreach X of varlist `varlist' {
		if "`upper'" != "" {
			replace `X' = upper(`X')
		}
		if "`lower'" != "" {
			replace `X' = lower(`X')
		}
		if "`nopunct'" != "" {
			replace `X' = subinstr(`X', ".", " ", .)
			replace `X' = subinstr(`X', ",", " ", .)
			replace `X' = subinstr(`X', "!", "", .)
			replace `X' = subinstr(`X', "?", "", .)
			replace `X' = subinstr(`X', "'", "", .)
			replace `X' = subinstr(`X', "--", " ", .)
			replace `X' = subinstr(`X', "/", " ", .)
			replace `X' = subinstr(`X', ";", " ", .)
			replace `X' = subinstr(`X', ":", " ", .)
			replace `X' = subinstr(`X', "(", " ", .)
			replace `X' = subinstr(`X', ")", " ", .)
			replace `X' = trim(`X')
			replace `X' = itrim(`X')
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
	}
	else if `version' == 2 {
		#d ;
		syntax [varlist] using/,
			/* main */
			id(varname)
			/* string comparison */
			[Lower Upper NOPunct]
			/* other */
			[SAving(str asis) NOString NOMATch]
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

	* "nid" for "number of IDs"
	loc nid : list sizeof varlist

	cap isid `varlist', missok
	if _rc {
		* cscript 15
		di as err "option id(): " plural(`nid', "variable") " `varlist' " ///
			plural(`nid', "does", "do") " not uniquely identify " ///
			"the observations in `data'"
		ex 459
	}

	if c(stata_version) >= 13 {
		qui ds `varlist', has(t strL)
		if "`r(varlist)'" != "" {
			* cscript 16
			di as err "option id(): " ///
				plural(`nid', "variable") " `r(varlist)' " ///
				plural(`nid', "is", "are") " strL in `data'"
			_nostrl error : `r(varlist)'
			/*NOTREACHED*/
		}
	}
end

pr parse_saving
	cap noi syntax anything(name=fn id=filename equalok everything), ///
		[csv replace]
	if _rc {
		error_saving `=_rc'
		/*NOTREACHED*/
	}

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

	loc saving_args fn(`"`fn'"') `csv' `replace'

	* Save local macros.
	foreach name in saving_args {
		c_local `name' "``name''"
	}
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
					/* save differences file	*/

pr save_file
	#d ;
	syntax,
		/* main */
		id(varname)
		/* -saving()- arguments */
		fn(str) [csv replace]
	;
	#d cr

	keep `id' Question Master Using

	if "`csv'" == "" {
		qui compress
		qui sa `"`fn'"', `replace'
	}
	else {
		qui outsheet using `"`fn'"', c `replace'
	}
end

					/* save differences file	*/
/* -------------------------------------------------------------------------- */
