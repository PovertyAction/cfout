*! v1 by Ryan Knight 10may2011
pr cfout, rclass
	vers 10.1

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

	if `:length loc saving' ///
		parse_saving `saving'

	cap isid `id'
	if _rc {
		duplicates tag `id', gen(_iddup)
		di as err "Variable `id' does not uniquely identify the following observations in the master data"
		list `id' if _iddup
		exit 459
	}

	if "`upper'`lower'`punct'" != "" & "`string'" != "" {
		di as err "`upper' `lower' `punct' may not be used with the nostrings option"
		exit 198
	}

	preserve

	quietly {

	if "`string'" != "" {
		ds `varlist', has(type string)
		local str `r(varlist)'
		local varlist: list varlist - str
	}

	keep `id' `varlist'
	ds `id', not
	local varlistm `r(varlist)'
	foreach X in `varlistm' {
		rename `X' _cf`X'
	}
	tempfile master
	save `master'

	use "`using'", clear

	cap isid `id'
	noisily if _rc {
		duplicates tag `id', gen(_iddup)
		di as err "Variable `id' does not uniquely identify the following observations in the using data"
		list `id' if _iddup
		exit 459
	}

	* List variables occuring only in 1 dataset
	ds `id', not
	if "`string'" != "" {
		ds `r(varlist)', has(type numeric)
	}
	local varlistu `r(varlist)'
	local varlistu: list varlistu & varlist

	local onlym: list varlistm - varlistu
	noisily if "`onlym'" !="" {
		di _newline as txt "The following variables are not in the using dataset"
		foreach c in `onlym' {
			di as res "`c'"
		}
	}
	local onlyu: list varlistu - varlistm
	noisily if "`onlyu'" !="" {
		di _newline as txt "The following variables are not in the master dataset"
		foreach c in `onlyu' {
			di as res "`c'"
		}
	}

	local varlist: list varlistm & varlistu
	keep `id' `varlist'
	tempfile tmpuse
	save `tmpuse'

	use `master', clear
	merge `id' using `tmpuse', sort

	* List missing observations
	if "`nomatch'" == "" {
		count if _merge==1
		local musen `r(N)'
		if `musen' > 0 {
			tempvar muse
			gen `muse'=1 if _merge==1
			sort `muse'
			noisily di _newline as err "The following observations are only in the master dataset:" _newline ///
			as txt "`id':"
			forvalues i=1/`musen' {
				noisily di as res `id'[`i']
			}
		}
		count if _merge==2
		local mmasn `r(N)'
		if `mmasn' >0 {
			tempvar mmas
			gen `mmas'=1 if _merge==2
			sort `mmas'
			noisily di _newline as err "The following observations are only in the using dataset:" _newline ///
			as txt "`id':"
			forvalues i=1/`mmasn' {
				noisily di as res `id'[`i']
			}
		}
	}

	keep if _merge ==3 // Only compare those with 2 entries to keep discrepancies reasonable
	drop _merge

	* Format string vars so you aren't counting differences in case, punctuation or spacing as errors
	if "`upper'`lower'`punct'" != "" & "`strings'" == "" {
		qui ds, has(type string)
		local strings `r(varlist)'
		local stringsnoid: list strings - id
		cfsetstr `stringsnoid', `upper' `lower' `punct'
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
	unab varlist: `varlist'

	* Run the discrepency.
	foreach X in `varlist' {
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
			cfsetstr `X' _cf`X', `upper' `lower' `punct'
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
	tokenize `varlist'
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

	if "`diftype'" !="" {
		di _newline as err "The following variables were not compared because they have a different string/numeric type in master/using:"
		di as res "`diftype'"
	}
	if "`messyvars'" !="" {
		di as err "The following variables were not compared because they are different in every observation:"
		di as res "`messyvars'"
	}

	return scalar N = `q'
	return scalar discrep = `e'

	* Display summary.
	display_summary `return(discrep)' `return(N)'

	* Display warning messages.
	if "`messyvars'"!="" | "`diftype'" !="" {
		di as txt "note: not all variables specified were compared."
	}
	if "`nomatch'" == "" {
		if "`musen'"!="0" {
			di as txt "note: not all observations were compared; " ///
				"there are observations only in the master data."
		}
		if "`mmasn'"!="0" {
			di as txt "note: not all observations were compared; " ///
				"there are observations only in the using data."
		}
	}

	cap mata: mata drop i
	cap mata: mata drop r
	cap mata: mata drop s
	cap mata: mata drop o
	cap mata: mata drop n

	if `:length loc saving' ///
		save_file, id(`id') `saving_args'

	restore
end

pr cfsetstr
	syntax varlist, [nopunct upper lower]

	foreach X of varlist `varlist' {
		if "`upper'" != "" {
			replace `X' = upper(`X')
		}
		if "`lower'" != "" {
			replace `X' = lower(`X')
		}
		if "`punct'" != "" {
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

		if "`format'" != "" ///
			warn_deprecated format()
		if "`altid'" != "" ///
			warn_deprecated altid()

		if `"`name'"' == "" ///
			loc name discrepancy report.csv
		else ///
			warn_deprecated name(), new("saving()")
		if "`replace'" != "" ///
			warn_deprecated replace, new("saving(,replace)", sub)
		loc saving "`"`name'"', csv `replace'"
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
					/* summary table		*/

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

					/* summary table		*/
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
