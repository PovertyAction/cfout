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

* Erase differences files not in an expected directory.
loc dirs : dir . dir *
foreach dir of loc dirs {
	loc files : dir "`dir'" file "*.csv"
	foreach file of loc files {
		erase "`dir'/`file'"
	}

	loc files : dir "`dir'" file "diff*.dta"
	foreach file of loc files {
		erase "`dir'/`file'"
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
