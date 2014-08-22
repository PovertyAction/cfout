* v1 by Ryan Knight 30jun2011

program define cfby, rclass
	version 10.1
	
	syntax [varlist] using/ , by(varname) ID(varname) [noPunct Upper Lower noMATCH noSTRING]

	cap isid `id'
	if _rc {
		duplicates tag `id' , gen(_iddup)
		di as err "Variable `id' does not uniquely identify the following observations in the master data"
		list `id' `altid' if _iddup
		exit 459
	}
	
	if "`upper'`lower'`punct'" != "" & "`string'" != "" {
		di as err "`upper' `lower' `punct' may not be used with the nostrings option"
		exit 198
	}
	
	preserve
	
	quietly {
	
	if "`string'" != "" {
		ds `varlist' , has(type string)
		local str `r(varlist)'
		local varlist: list varlist - str
	}	
	
	keep `id' `varlist' `by'
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
		duplicates tag `id' , gen(_iddup)
		di as err "Variable `id' does not uniquely identify the following observations in the using data"
		list `id' `altid' if _iddup
		exit 459
	}
	
	* List variables occuring only in 1 dataset
	ds `id', not
	if "`string'" != "" {
		ds `r(varlist)' , has(type numeric)
	}
	local varlistuall `r(varlist)'	
	local varlistu: list varlistuall & varlist
	
	local onlym: list varlistm - varlistu
	local onlym: list onlym - by
	noisily if "`onlym'" !="" {
		di _newline as txt "The following variables are not in the using dataset"
		foreach c in `onlym' {
			di as res "`c'"
		}
	}
	local onlyu: list varlistuall - varlistm
	local onlyu: list onlyu - by
	noisily if "`onlyu'" !="" {
		di _newline as txt "The following variables are not in the master dataset"
		foreach c in `onlyu' {
			di as res "`c'"
		}
	}
	
	local varlist: list varlistm & varlistu
	local varlist: list varlist - by
	keep `id' `varlist' `by'
	tempfile tmpuse
	save `tmpuse'
	
	use `master', clear
	merge `id' using `tmpuse', sort
	
	* List missing observations
	if "`match'"=="" {
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
	
	* Format strings
	if "`upper'`lower'`punct'" != "" & "`string'" == "" {
		qui ds , has(type string)
		local strings `r(varlist)'
		local stringsnoid: list strings - id
		foreach X of varlist `stringsnoid' {
			if "`upper'" != "" {
				replace `X' = upper(`X')
			}
			if "`lower'" != "" {
				replace `X' = lower(`X')
			}
			if "`punct'" != "" {
				replace `X' = subinstr(`X', "." , " " , .) 
				replace `X' = subinstr(`X', "," , " " , .) 
				replace `X' = subinstr(`X', "!" , "" , .) 
				replace `X' = subinstr(`X', "?" , "" , .)
				replace `X' = subinstr(`X', "'" , "" , .)
				replace `X' = subinstr(`X', "--" , " " , .)
				replace `X' = subinstr(`X', "/" , " " , .)
				replace `X' = subinstr(`X', ";" , " " , .)
				replace `X' = subinstr(`X', ":" , " " , .)
				replace `X' = subinstr(`X', "(" , " " , .)
				replace `X' = subinstr(`X', ")" , " " , .)
				replace `X' = trim(`X')
				replace `X' = itrim(`X')
			}
		}
	}
	* Loop through questions, saving differences by ob
	tempvar totaldiffs
	qui gen `totaldiffs'=0
	unab varlist: `varlist'
	
	foreach X in `varlist' {
		replace `totaldiffs'=`totaldiffs' + 1 if `X'!=_cf`X'
		if _rc { 
			local diftype `diftype' `X'
		}
	}
	
	* Get total number of Qs by ob
	local remaining: list varlist - diftype
	local varcount: word count `remaining'
	tempvar totalqs
	gen `totalqs' = `varcount'
	
	* Get list of unique values for by var
	levelsof `by', local(usevals)
	levelsof _cf`by', local(masvals)
	local usecount: word count `usevals'
	local mascount: word count `masvals'
	
	* Create matrices for errors & questions by operator
	matrix def A = J(`usecount',`mascount',.)
	matrix def B = J(`usecount',`mascount',.)
	matrix def C = J(`usecount',`mascount',.)
	
	forvalues i=1/`usecount' {
		
		forvalues j=1/`mascount' {
			local useby: word `i' of `usevals'
			local masby: word `j' of `masvals'
			count if (`by'==`useby' & _cf`by'==`masby') | (_cf`by'==`useby' & `by'==`masby') 
			
			if `r(N)' > 0 {
				sum `totaldiffs' if (`by'==`useby' & _cf`by'==`masby') | (_cf`by'==`useby' & `by'==`masby')  
				local errors = r(sum)
				sum `totalqs' if (`by'==`useby' & _cf`by'==`masby') | (_cf`by'==`useby' & `by'==`masby') 
				local questions = r(sum)
				matrix A[`i',`j'] = `errors'/`questions'
				matrix B[`i',`j'] = `errors'
				matrix C[`i',`j'] = `questions'
			}
		}
	}

	* Set row/column names
	local uselbls `usevals'
	local maslbls `masvals'

	foreach c in A B C {
		matrix rownames `c' = `uselbls'
		matrix roweq `c' = `by'
		matrix colnames `c' = `maslbls'
		matrix coleq `c' = `by'
	}
	}
	di _newline _dup(35) as txt "_"
	mat list A, title( "Discrepency rates by `by'")
	di _newline _dup(35) as txt "_"
	mat list B, title( "Discrepencies by `by'")
	di _newline _dup(35) as txt "_"
	mat list C, title( "Data points by `by'")
	
	if "`diftype'" !="" {
		di _newline as err "The following variables were not compared because they have a different string/numeric type in master/using:"
		di as res "`diftype'"
	}
	
	* Display overall discrepency rate
	qui sum `totaldiffs'
	local e = r(sum)
	qui sum `totalqs'
	local q = r(sum)
	di _newline _dup(35) as txt "_" _newline as txt "Total Discrepancies: " as res (`e')
	di as txt "Total Data Points Compared: " as res `q'
	di as txt "Percent Discrepancies: " %6.3f as res (`e')/`q'*100 as txt " percent"
	di _dup(35) as txt "_"
	
	if "`messyvars'"!="" | "`diftype'" !="" {
		di as err "Note: Not all variables in varlist compared."
	}
	if "`match'"=="" {
		if "`musen'"!="0" {
			di as err "Note: Not all observations compared; observations are missing in using data"
		}
		if "`mmasn'"!="0" {
			di as err "Note: Not all observations compared; observations are missing in master data"
		}
	}
	return matrix e = B
	return matrix q = C
	restore
end 
