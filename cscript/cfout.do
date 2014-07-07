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


/* -------------------------------------------------------------------------- */
					/* user mistakes		*/

// ...


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
