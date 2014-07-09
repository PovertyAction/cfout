* -cfout- cscript

* -version- intentionally omitted for -cscript-.

* 1 to execute profile.do after completion; 0 not to.
local profile 1


/* -------------------------------------------------------------------------- */
					/* initialize			*/

* Check the parameters.
assert inlist(`profile', 0, 1)

* Set the working directory to the cfout directory.
c cfout
cd cscript

cap log close cfout
log using cfout, name(cfout) s replace
di "`c(username)'"
di "`:environment computername'"

clear
clear matrix
clear mata
set varabbrev off
set type float
vers 10.1: set seed 335610938
set more off

cd ..
adopath ++ `"`c(pwd)'"'
adopath ++ `"`c(pwd)'/cscript/ado"'
cd cscript

timer clear 1
timer on 1

* Preserve select globals.
loc FASTCDPATH : copy glo FASTCDPATH

cscript cfout adofile cfout

* Check that Mata issues no warning messages about the source code.
if c(stata_version) >= 13 {
	matawarn cfout.ado
	assert !r(warn)
	cscript
}

* Restore globals.
glo FASTCDPATH : copy loc FASTCDPATH

cd tests

loc dirs : dir . dir *
foreach dir of loc dirs {
	foreach pat in *.csv diff*.dta gen*.dta {
		loc files : dir "`dir'" file "`pat'"
		foreach file of loc files {
			erase "`dir'/`file'"
		}
	}

	* Create generated datasets.
	cap conf f "`dir'/gen.do"
	if !_rc {
		cd "`dir'"
		do gen
		cd ..
	}
}


/* -------------------------------------------------------------------------- */
					/* basic				*/

* Test 1
cd 1
u firstEntry, clear
cfout region-no_good_at_all using secondEntry, id(uniqueid)
assert r(N) == 15000
assert r(discrep) == 44
cd ..


/* -------------------------------------------------------------------------- */
					/* string comparison	*/

* Test 17
cd 17
#d ;
loc optsN "
	""					5
	lower				3
	upper				3
	nopunct				4
	"lower nopunct"		1
	"upper nopunct"		1
";
#d cr
while `:list sizeof optsN' {
	gettoken opts	optsN : optsN
	gettoken N		optsN : optsN

	u gen1, clear
	cfout s x using gen2, id(id) `opts' saving(diff_opts, replace)
	assert r(discrep) == `N'

	* Redo the string comparison.

	cfout s x using gen2, id(id) saving(diff_no_opts, replace)
	u diff_no_opts, clear

	loc lower lower
	loc upper upper
	loc nopunct nopunct
	loc master Master
	loc using Using
	foreach X of var `master' `using' {
		if `:list lower in opts' ///
			replace `X' = strlower(`X')

		if `:list upper in opts' ///
			replace `X' = strupper(`X')

		if `:list nopunct in opts' {
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

	keep if `master' != `using'
	assert _N == `N'

	cf _all using diff_opts
}
cd ..

* Test 19
cd 17
u gen1, clear
foreach opt in "" lower upper nopunct {
	cfout s x using gen2, id(id) `opt' nostring
	assert r(discrep) == 0
}
cd ..


/* -------------------------------------------------------------------------- */
					/* -saving()-			*/

* Test 7
cd 7
u firstEntry, clear
cfout region-no_good_at_all using secondEntry, id(uniqueid)
loc files : dir . file *
assert `:list sizeof files' == 2
cfout region-no_good_at_all using secondEntry, id(uniqueid) saving(diff)
conf f diff.dta
cd ..

* Test 8
cd 8
u firstEntry, clear
cfout region-no_good_at_all using secondEntry, ///
	id(uniqueid) saving(diff)
conf f diff.dta
#d ;
rcof `"
	noi cfout region-no_good_at_all using secondEntry,
		id(uniqueid) saving(diff)
	"' == 602;
#d cr
cfout region-no_good_at_all using secondEntry, ///
	id(uniqueid) saving(diff, replace)
cd ..

* Test 9
cd 9
forv i = 1/2 {
	u firstEntry, clear
	cfout region-no_good_at_all using secondEntry, ///
		id(uniqueid) saving(diff, replace)
	// cf ...
}
cd ..

* Test 11
cd 11
u 1, clear
cfout gender using 2, id(id) saving(diff)
assert r(discrep) == 2
u diff, clear
assert _N == 2
compdta expected/diff
cd ..

* Test 12
cd 12
u 1, clear
cfout gender using 2, id(id) saving(diff)
u diff, clear
compdta expected/diff
outsheet using expected_diff.csv, c
checksum expected_diff.csv
loc size = r(filelen)
loc checksum = r(checksum)
u 1, clear
cfout gender using 2, id(id) saving(diff, csv)
checksum diff.csv
assert r(filelen) == `size'
assert r(checksum) == `checksum'
cd ..

* Test 13
cd 13
u 1, clear
cfout gender using 2, id(id) saving(diff.dta)
erase diff.dta
cfout gender using 2, id(id) saving(diff)
conf f diff.dta
cd ..

* Test 14
cd 14
u 1, clear
cfout gender using 2, id(id) saving(diff.csv, csv)
erase diff.csv
cfout gender using 2, id(id) saving(diff, csv)
conf f diff.csv
cd ..


/* -------------------------------------------------------------------------- */
					/* deprecated options	*/

* Test 2
cd 2
u firstEntry, clear
cfout region-feel_useless using secondEntry, id(uniqueid) replace
checksum "discrepancy report.csv"
loc size = r(filelen)
loc checksum = r(checksum)
cfout region-feel_useless using secondEntry, id(uniqueid) replace ///
	altid(no_good_at_all)
checksum "discrepancy report.csv"
assert r(filelen) == `size'
assert r(checksum) == `checksum'
cd ..

* Test 3
cd 3
u master, clear
cfout v1 using using, id(id) replace
checksum "discrepancy report.csv"
loc size = r(filelen)
loc checksum = r(checksum)
cfout v1 using using, id(id) replace format(%9.1f)
checksum "discrepancy report.csv"
assert r(filelen) == `size'
assert r(checksum) == `checksum'
cd ..

* Test 4
cd 4
u firstEntry, clear
cfout region-no_good_at_all using secondEntry, id(uniqueid) name(diff)
conf f diff.csv
cd ..

* Test 5
cd 5
u firstEntry, clear
cfout region-no_good_at_all using secondEntry, id(uniqueid) replace
conf f "discrepancy report.csv"
cd ..


/* -------------------------------------------------------------------------- */
					/* user mistakes		*/

* Test 6
cd 6
u firstEntry, clear
cfout region-no_good_at_all using secondEntry, ///
	id(uniqueid) saving(diff)
cfout region-no_good_at_all using secondEntry, ///
	id(uniqueid) saving(diff, replace)
#d ;
rcof `"
	noi cfout region-no_good_at_all using secondEntry,
		id(uniqueid) saving(diff) replace
	"' == 198;
#d cr
cd ..

* Test 10
cd 10
u firstEntry, clear
loc cmd cfout region-no_good_at_all using secondEntry, id(uniqueid) saving(diff)
`cmd'
rcof `"noi `cmd'"' == 602
cd ..

* Test 15
cd 15
u 1, clear
cfout gender using 2, id(id)
expand 2
rcof "noi cfout gender using 2, id(id)" == 459
u 2, clear
expand 2
tempfile 2
sa `2'
u 1, clear
rcof "noi cfout gender using `2', id(id)" == 459
cd ..

* Test 16
cd 16
if c(stata_version) >= 13 {
	u 1, clear
	cfout gender using 2, id(id)
	recast strL id
	rcof "noi cfout gender using 2, id(id)" == 109
	u 2, clear
	recast strL id
	tempfile 2
	sa `2'
	u 1, clear
	rcof "noi cfout gender using `2', id(id)" == 109
}
cd ..

* Test 18
cd 17
u gen1, clear
rcof "noi cfout s using gen2, id(id) lower upper" == 198
cd ..


/* -------------------------------------------------------------------------- */
					/* finish up			*/

timer off 1
timer list 1

if `profile' {
	cap conf f C:\ado\profile.do
	if !_rc ///
		run C:\ado\profile
}

timer list 1

log close cfout
