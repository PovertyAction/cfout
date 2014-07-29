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
loc varlist `r(varlist)'
unab unab : region-no_good_at_all
assert `:list varlist == unab'
cd ..

* Test 22
cd 22
u 1, clear
cfout gender using 2, id(id)
assert r(N) == 998
assert r(discrep) == 2
assert r(Nonlym) == 1
assert r(Nonlyu) == 1
cd ..

* Test 23
cd 23
loc 1not2 region
loc 2not1 no_good_at_all
u firstEntry, clear
unab 1 : _all
d using secondEntry, varl
loc 2 `r(varlist)'
assert `:list 1 == 2'
drop `2not1'
sa gen1
u secondEntry, clear
drop `1not2'
sa gen2
u gen1
loc id uniqueid
ds `id', not
loc noid `r(varlist)'
foreach varlist in "`noid'" _all {
	cfout `varlist' using gen2, id(uniqueid)
	loc r_varlist `r(varlist)'
	unab expected : `varlist'
	loc expected : list expected - id
	loc expected : list expected - 1not2
	assert `:list r_varlist == expected'
	loc varonlym `r(varonlym)'
	assert `:list varonlym == 1not2'
}
cd ..

* Test 24
cd 24
* Normal
u firstEntry, clear
unab varlist : region-no_good_at_all
cfout `varlist' using secondEntry, id(uniqueid)
loc r_varlist `r(varlist)'
assert `:list r_varlist == varlist'
* -tostring- the master version.
loc tostring region no_good_at_all
assert `:list tostring in varlist'
conf numeric var `tostring'
tostring `tostring', replace
conf str var `tostring'
cfout `varlist' using secondEntry, id(uniqueid)
loc difftype `r(difftype)'
assert `:list difftype == tostring'
loc r_varlist `r(varlist)'
loc expected : list varlist - difftype
assert `:list r_varlist == expected'
* -tostring- the using version.
u secondEntry, clear
conf numeric var `tostring'
tostring `tostring', replace
conf str var `tostring'
tempfile 2
sa `2', replace
u firstEntry, clear
cfout `varlist' using `2', id(uniqueid)
loc difftype `r(difftype)'
assert `:list difftype == tostring'
loc r_varlist `r(varlist)'
loc expected : list varlist - difftype
assert `:list r_varlist == expected'
cd ..

* Test 25
cd 25
u firstEntry, clear
forv i = 1/2 {
	loc ab region-no_good_at_all
	loc varlist : di _dup(`i') "`ab' "
	cfout `varlist' using secondEntry, id(uniqueid)
	assert r(N) == 15000
	assert r(discrep) == 44
	loc r_varlist `r(varlist)'
	unab unab : `ab'
	assert `:list r_varlist == unab'
}
cd ..

* Test 26
cd 26
u gen1, clear
foreach saving in "" saving(diff) {
	cfout one x using gen2, id(id) dropdiff `saving'
	assert r(N) == 1000
	assert r(discrep) == 0
	assert "`r(varlist)'" == "one"
	assert "`r(alldiff)'" == "x"
}
u diff, clear
assert !_N
cd ..

* Test 44
cd 26
cap erase diff.dta
u gen1, clear
foreach saving in "" saving(diff) {
	cfout one x using gen2, id(id) `saving'
	assert r(N) == 2000
	assert r(discrep) == 1000
	assert "`r(varlist)'" == "one x"
	assert "`r(alldiff)'" == "x"
}
u diff, clear
assert _N == 1000
cd ..

* Test 46
cd 46
u gen1, clear
#d ;
loc tests "
	""						6	3	"n s"
	nostring				3	1	n
	nonumeric				3	2	s
	"nostring nonumeric"	0	0	""
";
#d cr
while `:list sizeof tests' {
	gettoken opts		tests : tests
	gettoken N			tests : tests
	gettoken discrep	tests : tests
	gettoken varlist	tests : tests

	u gen1, clear
	foreach saving in "" "saving(diff, replace)" {
		cfout n s using gen2, id(id) `opts' `saving'
		assert r(N) == `N'
		assert r(discrep) == `discrep'
		assert "`r(varlist)'" == "`varlist'"
	}
	u diff, clear
	assert _N == `discrep'
}
* -nostring- for all string variables
u gen1, clear
tostring _all, replace
unab all : _all
conf str var `all'
preserve
u gen2, clear
tostring _all, replace
conf str var `all'
sa gen2_str
restore
cfout using gen2_str, id(id) nostring
assert r(N) == 0
assert r(discrep) == 0
* -nonumeric- for all numeric variables
u gen1, clear
destring, replace
conf numeric var `all'
preserve
u gen2, clear
destring, replace
conf numeric var `all'
sa gen2_num
restore
cfout using gen2_num, id(id) nonumeric
assert r(N) == 0
assert r(discrep) == 0
cd ..

* Test 47
cd 47
u gen1, clear
pr test47, rclass
	_on_colon_parse `0'
	loc 0		"`s(before)'"
	loc cfout	"`s(after)'"
	syntax, [NUMeric STRing]
	loc 0 "`cfout'"
	syntax varlist, [SAving(str asis) *]

	if "`numeric'`string'" == "" ///
		err 198
	if "`numeric'" != "" & "`string'" != "" ///
		err 198

	cfout `varlist' using gen2, id(id) saving(diff, `saving' replace) `options'
	ret add
	preserve
	u diff, clear
	conf `numeric'`string' var Master Using
end
test47, num: n
test47, num: n, nonumeric
test47, str: s
test47, num: s, nostring
test47, str: n s
test47, str: n s, nonumeric
test47, num: n s, nostring
test47, num: n s, nonumeric nostring
test47, str: s_alldiff
test47, num: s_alldiff, dropdiff
test47, str: n s_alldiff
test47, num: n s_alldiff, dropdiff
assert "`r(alldiff)'" == "s_alldiff"
test47, str: n, saving(labval)
test47, str: n, saving(labval) nonumeric
test47, str: n s_alldiff, saving(labval)
test47, str: n s_alldiff, saving(labval) dropdiff
cd ..

* Test 48
cd 48
u 1, clear
lab data "Master label"
assert "`:data lab'" == "Master label"
note: Master note
preserve
u 2, clear
lab data "Using label"
note: Using note
sa gen2
restore
cfout gender using gen2, id(id) saving(diff)
u diff, clear
assert "`:data lab'" == ""
assert "`:char _dta[]'" == ""
cd ..

* Test 49
cd 49
u 1, clear
cfout gender using 2, id(id) saving(diff)
compdta 1
cfout gender using 2, id(id) saving(diff, replace) nopre
compdta diff
cd ..

* Test 63
cd 63
pr nc_default
	syntax varlist(min=2 max=2), Generate(name)
	gettoken var1 var2 : varlist

	gen `generate' = `var1' != `var2'
end
pr nc_same
	syntax varlist(min=2 max=2), Generate(name)

	gen `generate' = 0
end
pr nc_diff
	syntax varlist(min=2 max=2), Generate(name)

	gen `generate' = 1
end
pr nc_range_tenth
	syntax varlist(min=2 max=2), Generate(name)
	gettoken var1 var2 : varlist

	gen `generate' = abs(`var1' - `var2') > .1
end
pr nc_range
	syntax varlist(min=2 max=2), Generate(name) Range(real)
	gettoken var1 var2 : varlist

	gen `generate' = abs(`var1' - `var2') > `range'
end
pr nc_two
	syntax varlist(min=2 max=2), Generate(name)

	gen `generate' = 2
end
pr nc_miss
	syntax varlist(min=2 max=2), Generate(name)

	gen `generate' = .
end
#d ;
loc progdiscrep "
	""						6
	nc_default				6
	nc_same					0
	nc_diff					7
	nc_range_tenth			3
	"nc_range, range(.1)"	3
	"nc_range, range(.2)"	1
	nc_default,				6
	"nc_default ,"			6
	"nc_range , range(.1)"	3
	nc_two					7
	nc_miss					7
";
#d cr
while `:list sizeof progdiscrep' {
	gettoken program	progdiscrep : progdiscrep
	gettoken discrep	progdiscrep : progdiscrep

	di as res "`program'"

	u gen1, clear
	cfout x using gen2, id(id) numcomp(`program') ///
		saving(diff, all replace) nopre
	assert r(N) == 7
	assert r(discrep) == `discrep'

	assert inlist(diff, 0, 1)
	qui cou if diff
	assert r(N) == `discrep'
}
cd ..

* Test 69
cd 69
u 1, clear
keep in 1/10
sa gen1_10
drop in 1/L
sa gen1_0
u 2, clear
keep in 1/10
sa gen2_10
drop in 1/L
sa gen2_0
foreach saving in "" "saving(diff, replace)" {
	u gen1_0, clear
	cfout gender using gen2_10, id(id) `saving'
	assert "`r(varlist)'" == "gender"
	assert !r(N)
	assert !r(discrep)
	assert "`r(alldiff)'" == ""

	u gen1_10, clear
	cfout gender using gen2_0, id(id) `saving'
	assert "`r(varlist)'" == "gender"
	assert !r(N)
	assert !r(discrep)
	assert "`r(alldiff)'" == ""

	u gen1_0, clear
	cfout gender using gen2_0, id(id) `saving'
	assert "`r(varlist)'" == "gender"
	assert !r(N)
	assert !r(discrep)
	assert "`r(alldiff)'" == ""
}
u diff, clear
assert "`:type Master'" == "byte"
cd ..

* Test 70
cd 70
u 1, clear
lab de orphan 1 1
sa gen1, o
cfout gender using 2, id(id) saving(diff)
rcof "noi compdta 1" == 9
compdta gen1
cfout gender using 2, id(id) saving(diff, replace) nopre
compdta diff
cd ..

* Test 80
cd 80
u 2, clear
assert _N > 2
drop in 1
sa gen2
u 1, clear
drop in L
cfout gender using gen2, id(id) saving(diff)
assert r(N)
assert r(Nonlym) == 1
assert r(Nonlyu) == 1
cfout gender using gen2, id(id) saving(diff_nomatch) nomatch
compdta diff diff_nomatch
* Show warning messages about both variables and observations not compared.
cfout using gen2, id(id) saving(diff, replace)
cd ..


/* -------------------------------------------------------------------------- */
					/* id()					*/

* Test 27
cd 27
u firstEntry, clear
foreach vars in region-no_good_at_all "region-no_good_at_all uniqueid" {
	cfout `vars' using secondEntry, id(uniqueid)
	assert r(N) == 15000
	assert r(discrep) == 44
	loc varlist `r(varlist)'
	unab unab : region-no_good_at_all
	assert `:list varlist == unab'
}
cd ..

* Test 30
cd 30
u gen1, clear
cfout gender using gen2, id(id1 id2) saving(diff)
compdta diff gen_diff
cd ..

* Test 31
cd 30
cap mkdir ../31
loc dtas : dir . file "gen*.dta"
foreach dta of loc dtas {
	u "`dta'", clear

	d, varl
	loc sort `r(sortlist)'

	tostring id2, replace
	conf numeric var id1
	conf str var id2

	if "`sort'" != "" ///
		sort `sort'

	sa "../31/`dta'"
}
cd ../31
u gen1, clear
cfout gender using gen2, id(id1 id2) saving(diff)
compdta diff gen_diff
cd ..

* Test 34
cd 11
u 1, clear
cfout gender using 2, id(id id) saving(diff34)
compdta diff34 expected/diff
cd ..
cd 30
u gen1, clear
cfout gender using gen2, id(id1 id2 id1 id2) saving(diff34)
compdta diff34 gen_diff
cd ..


/* -------------------------------------------------------------------------- */
					/* string comparison	*/

pr sc_lower
	syntax varlist(min=2 max=2)
	gettoken var1 var2 : varlist

	replace `var1' = strlower(`var1')
	replace `var2' = strlower(`var2')
end

pr sc_same
	syntax varlist(min=2 max=2)
	gettoken var1 var2 : varlist

	replace `var1' = `var2'
end

pr sc_diff
	syntax varlist(min=2 max=2)
	gettoken var1 var2 : varlist

	assert strlen(`var1') < c(maxstrvarlen)
	replace `var2' = `var1' + "x"
end

pr sc_wizard
	syntax varlist(min=2 max=2)
	gettoken var1 var2 : varlist

	replace `var1' = "pineapple" if `var1' == "wizard"
end

pr sc_from_to
	syntax varlist(min=2 max=2), from(str asis) to(str asis)
	gettoken var1 var2 : varlist

	replace `var1' = `to' if `var1' == `from'
end

* Test 17
cd 17
#d ;
loc optsN "
	""							6
	lower						4
	upper						4
	nopunct						5
	"lower nopunct"				2
	"upper nopunct"				2
	strcomp(sc_lower)			4
	strcomp(sc_same)			0
	strcomp(sc_diff)			8
	strcomp(sc_wizard)			6
	"lower strcomp(sc_wizard)"	3
	`"strcomp(sc_from_to, from("wizard") to("pineapple"))"'
								6
	`"lower strcomp(sc_from_to, from("wizard") to("pineapple"))"'
								3
	`"strcomp(sc_from_to , from("wizard") to("pineapple"))"'
								6
";
#d cr
while `:list sizeof optsN' {
	gettoken opts		optsN : optsN
	gettoken discrep	optsN : optsN

	u gen1, clear
	cfout s x using gen2, id(id) `opts' saving(diff, replace)
	assert r(discrep) == `discrep'

	* Redo the string comparison.

	loc 0 , `opts'
	syntax, [lower upper NOPUNCT strcomp(str asis)]

	loc master Master
	loc using Using

	u diff, clear
	assert Question == "s"

	u gen1
	drop x
	ren s sm
	merge id using gen2, sort keep(s)
	assert _merge == 3
	drop _merge
	ren s `using'
	ren sm `master'

	foreach X of var `master' `using' {
		if "`lower'" != "" ///
			replace `X' = strlower(`X')

		if "`upper'" != "" ///
			replace `X' = strupper(`X')

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

	if `:length loc strcomp' {
		gettoken cmd_name cmd_opts : strcomp, p(", ")
		`cmd_name' `master' `using'`cmd_opts'
	}

	keep if `master' != `using'
	assert _N == `discrep'

	cf _all using diff
}
cd ..

* Test 19
cd 17
u gen1, clear
foreach opt in "" lower upper nopunct strcomp(sc_lower) {
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

* Test 28
cd 28
#d ;
loc optsnames "
	""							"Question Master Using"
	variable(variable)			"variable Master Using"
	masterval(master_value)		"Question master_value Using"
	usingval(using_value)		"Question Master using_value"
	"variable(Question) masterval(Master) usingval(Using)"
								"Question Master Using"
	"variable(Master) masterval(Using) usingval(Question)"
								"Master Using Question"
	"variable(variable) masterval(master_value) usingval(using_value)"
								"variable master_value using_value"
";
#d cr
while `:list sizeof optsnames' {
	gettoken opts  optsnames : optsnames
	gettoken names optsnames : optsnames

	assert `:list sizeof names' == 3
	gettoken variable	names : names
	gettoken master		names : names
	gettoken usingval	names : names

	u expected/diff, clear
	foreach var of var Question Master Using {
		tempvar `var'
		ren `var' ``var''
	}
	ren `Question'	`variable'
	ren `Master'	`master'
	ren `Using'		`usingval'
	tempfile expected
	sa `expected'

	u 1, clear
	cfout gender using 2, id(id) saving(diff, `opts' replace)
	compdta diff `expected'
}
cd ..

* Test 35
cd 35
u 1, clear
form id %24.0g
preserve
u 2, clear
form id %22.0g
tempfile 2
sa `2'
restore
cfout gender using `2', id(id) saving(diff)
u diff, clear
assert "`:format id'" == "%24.0g"
cd ..

* Test 36
cd 36
u 2, clear
assert "`:val lab id'" == ""
assert "`:var lab id'" == ""
u 1, clear
forv i = 1/1000 {
	lab de idlab `i' "Value `i'", modify
}
lab val id idlab
lab var id "My label"
cfout gender using 2, id(id) saving(diff)
u diff, clear
assert "`:val lab id'" == "idlab"
assert "`:var lab id'" == "My label"
cd ..

* Test 37
cd 37
u 1, clear
assert "`:val lab id'" == ""
assert "`:var lab id'" == ""
u 2, clear
forv i = 1/1000 {
	lab de idlab `i' "Value `i'", modify
}
lab val id idlab
lab var id "My label"
tempfile 2
sa `2'
u 1, clear
cfout gender using `2', id(id) saving(diff)
u diff, clear
assert "`:val lab id'" == ""
assert "`:var lab id'" == ""
cd ..

* Test 38
cd 38
forv i = 1/2 {
	u `i', clear
	forv j = 1/1000 {
		lab de idlab`i' `j' "`j' (`i'.dta)", modify
	}
	lab val id idlab`i'
	lab var id "My label `i'"
	sa gen`i'
}
u gen1, clear
cfout gender using gen2, id(id) saving(diff)
u diff, clear
assert "`:val lab id'" == "idlab1"
assert "`:var lab id'" == "My label 1"
cd ..

* Test 39
cd 39
u 2, clear
assert "`:char id[]'" == ""
char id[Same] 1
char id[Different] 2
char id[Only2] 3
sa gen2
u 1, clear
assert "`:char id[]'" == ""
char id[Same] 1
char id[Different] 4
char id[Only1] 5
cfout gender using gen2, id(id) saving(diff)
u diff, clear
loc chars : char id[]
loc expected Same Different Only1
assert `:list chars === expected'
assert `id[Same]' == 1
assert `id[Different]' == 4
assert `id[Only1]' == 5
cd ..

* Test 40
cd 40
u 1, clear
lab val id idlab
sa gen1
u 2, clear
lab de idlab 1 "Value 1"
lab val id idlab
sa gen2
u gen1, clear
cfout gender using gen2, id(id) saving(diff)
lab drop _all
u diff, clear
assert "`:val lab id'" == "idlab"
lab dir
assert "`r(names)'" == "idlab"
lab li idlab
assert r(k) == 1
assert r(min) == 1
cd ..

* Test 41
cd 41
u 2, clear
lab val id idlab
sa gen2
u 1, clear
lab de idlab 1 "Value 1"
lab val id idlab
cfout gender using gen2, id(id) saving(diff)
lab drop _all
u diff, clear
assert "`:val lab id'" == "idlab"
lab dir
assert "`r(names)'" == "idlab"
lab li idlab
assert r(k) == 1
assert r(min) == 1
cd ..

* Test 42
cd 42
u 1, clear
lab de idlab 1 "1 (1.dta)"
lab val id idlab
sa gen1
u 2, clear
lab de idlab 2 "2 (2.dta)" 3 "3 (2.dta)"
lab val id idlab
sa gen2
u gen1, clear
cfout gender using gen2, id(id) saving(diff)
lab drop _all
u diff, clear
assert "`:val lab id'" == "idlab"
lab li idlab
assert r(k) == 1
assert r(min) == 1
cd ..

* Test 43
cd 43
u gen1, clear
cfout x using gen2, id(id) saving(diff, csv)
assert r(N) == 2
assert r(discrep) == 1
tempname fh
file open `fh' using diff.csv, r
file r `fh' line
file r `fh' line
file r `fh' blank
assert !`:length loc blank'
assert r(eof)
file close `fh'
mata:
line = tokens(st_local("line"), ",")
line = select(line, line :!= ",")
assert(length(line) == 4)
assert(/* id */			line[1] == "2")
assert(/* variable */	line[2] == "x")
assert(/* master */		line[3] == "2.0000000000000009")
assert(/* using */		line[4] == "2.0000000000000018")
end
cd ..

* Test 53
cd 53
* Differences only
u firstEntry, clear
loc cfout cfout region-no_good_at_all using secondEntry, id(uniqueid)
`cfout' saving(diff)
loc N 15000
loc discrep 44
assert r(N) == `N'
assert r(discrep) == `discrep'
u diff, clear
assert _N == `discrep'
* -saving(, all)-
u firstEntry, clear
`cfout' saving(diff_all_diff, all)
assert r(N) == `N'
assert r(discrep) == `discrep'
u diff_all_diff, clear
assert _N == `N'
assert inlist(diff, 0, 1)
cou if diff
assert r(N) == `discrep'
assert diff == (Master != Using)
keep if diff
drop diff
compdta diff
* -saving(, all())-
u firstEntry, clear
`cfout' saving(diff_all_foo, all(foo))
assert r(N) == `N'
assert r(discrep) == `discrep'
u diff_all_foo, clear
ren foo diff
compdta diff_all_diff
cd ..

* Test 54
cd 54
#d ;
loc optsN "
	saving(diff)					3
	"saving(diff) dropdiff"			1
	"saving(diff, all)"				4
	"saving(diff, all) dropdiff"	2
";
#d cr
while `:list sizeof optsN' {
	gettoken opts	optsN : optsN
	gettoken N		optsN : optsN

	u gen1, clear
	cap erase diff.dta
	cfout x y using gen2, id(id) nopre `opts'
	assert _N == `N'
}
cd ..

* Test 56
cd 56
u gen1
cfout labeled formatted using gen2, id(id) saving(diff, labval) nopre
compdta expected/diff
cd ..

* Test 57
cd 56
u expected/diff, clear
foreach var of var Master Using {
	replace `var' = "01jan1960" if `var' == "Value 0"
	replace `var' = "02jan1960" if `var' == ""
}
sa diff57
u gen1
lab val labeled
cfout labeled formatted using gen2, id(id) saving(diff, labval replace) nopre
compdta diff57
cd ..

* Test 58
cd 56
u gen2, clear
lab de lab2 0 "Value zero" 1 "Value one"
lab val labeled lab2
tempfile 2
sa `2'
u gen1, clear
cfout labeled formatted using `2', id(id) saving(diff, labval replace) nopre
compdta expected/diff
cd ..

* Test 59
cd 56
u gen1, clear
lab drop _all
cfout labeled formatted using gen2, id(id) saving(diff, labval replace) nopre
compdta expected/diff
cd ..

* Test 60
cd 56
u gen2, clear
lab dir
assert "`r(names)'" == "lab"
lab de `r(names)' 0 "Value zero" 1 "Value one", replace
tempfile 2
sa `2'
u gen1, clear
cfout labeled formatted using `2', id(id) saving(diff, labval replace) nopre
compdta expected/diff
cd ..

* Test 61
cd 56
u gen2, clear
form formatted %tc
tempfile 2
sa `2'
u gen1, clear
cfout labeled formatted using `2', id(id) saving(diff, labval replace) nopre
compdta expected/diff
cd ..

* Test 71
cd 71
* Neither -keepmaster()- nor -keepusing()-
u gen1, clear
cfout gender using gen2, id(id) nopre ///
	saving(diff, replace)
compdta expected/diff
* -keepmaster()- only
loc keepmaster both onlym
u expected/diff, clear
d, varl
loc sort `r(sortlist)'
merge id using gen1, sort uniqus keep(`keepmaster')
drop if _merge == 2
drop _merge
sort `sort'
foreach var of loc keepmaster {
	move `var' Question
}
sa diff_keepmaster
u gen1, clear
cfout gender using gen2, id(id) nopre ///
	saving(diff, replace keepmaster(`keepmaster'))
compdta diff_keepmaster
* -keepusing()- only
loc keepusing both onlyu
u expected/diff, clear
merge id using gen2, sort uniqus keep(`keepusing')
drop if _merge == 2
drop _merge
sort `sort'
foreach var of loc keepusing {
	move `var' Question
}
sa diff_keepusing
u gen1, clear
cfout gender using gen2, id(id) nopre ///
	saving(diff, replace keepusing(`keepusing'))
compdta diff_keepusing
* Both -keepmaster()- and -keepusing()-
u expected/diff, clear
merge id using gen1, sort uniqus keep(`keepmaster')
drop if _merge == 2
drop _merge
loc unotm : list keepusing - keepmaster
merge id using gen2, sort uniqus keep(`unotm')
drop if _merge == 2
drop _merge
sort `sort'
foreach var of var `keepmaster' `unotm' {
	move `var' Question
}
sa diff_both
u gen1, clear
cfout gender using gen2, id(id) nopre ///
	saving(diff, replace keepmaster(`keepmaster') keepusing(`unotm'))
compdta diff_both
cd ..

* Test 72
cd 72
u 2, clear
forv i = 1/10 {
	loc newvar onlyu`i'
	gen `newvar' = `i'
	loc newvars : list newvars | newvar
}
sa gen2
u 1, clear
cfout gender using gen2, id(id) saving(diff_expected, keepusing(`newvars'))
foreach keepusing in onlyu* "onlyu1-onlyu10" "onlyu* onlyu*" ///
	"onlyu1 onlyu2-onlyu9 onlyu*" "`newvars' `newvars'" {
	cfout gender using gen2, id(id) saving(diff, keepusing(`keepusing') replace)
	compdta diff diff_expected
}
cd ..

* Test 74
cd 74
* -keepmaster()-
u 1, clear
cfout using 2, id(id) saving(diff_master, keepmaster(gender))
u expected/diff, clear
merge id using 1, sort uniqus keep(gender)
drop if _merge == 2
drop _merge
sort id
move gender Question
compdta diff_master
* -keepusing()-
u 1, clear
cfout using 2, id(id) saving(diff_using, keepusing(gender))
u expected/diff, clear
merge id using 2, sort uniqus keep(gender)
drop if _merge == 2
drop _merge
sort id
move gender Question
compdta diff_using
cd ..

* Test 75
cd 75
u 1, clear
cfout gender using 2, id(id) saving(diff_expected)
foreach keep in keepmaster(id) keepusing(id) "keepmaster(id) keepusing(id)" {
	cfout gender using 2, id(id) saving(diff, `keep' replace)
	compdta diff diff_expected
}
cd ..

* Test 76
cd 76
u 2, clear
lab de sex 1 male 2 female
lab val gender sex
sa gen2
u 1, clear
lab de sex 1 female 2 male
sa gen1_orphan, o
lab val gender sex
sa gen1_no_orphan
foreach dta in gen1_orphan gen1_no_orphan {
	u `dta', clear
	lab dir
	assert "`r(names)'" == "sex"

	cfout gender using gen2, id(id) ///
		saving(diff, keepusing(gender) replace) nopre
	lab dir
	assert "`r(names)'" == "sex"
	assert "`:val lab gender'" == "sex"
	assert "`:label (gender) 1'" == "female"
}
cd ..

* Test 77
cd 77
u 2, clear
lab de sex 1 Male 2 Female
lab val gender sex
sa gen2
u 1, clear
lab de val 1 "Value 1" 2 "Value 2"
lab val gender val
cfout gender using gen2, id(id) saving(diff, keepusing(gender)) nopre
lab dir
assert "`r(names)'" == "sex"
assert "`:val lab gender'" == "sex"
assert "`:label (gender) 1'" == "Male"
cd ..

* Test 78
cd 78
u 2, clear
lab de sex 1 Male 2 Female
lab val gender sex
sa gen2
u 1, clear
lab de val 1 "Value 1" 2 "Value 2"
lab val gender val
cfout gender using gen2, id(id) saving(diff, keepmaster(gender)) nopre
lab dir
assert "`r(names)'" == "val"
assert "`:val lab gender'" == "val"
assert "`:label (gender) 1'" == "Value 1"
cd ..

* Test 79
cd 79
u 2, clear
drop in 1/L
gen onlyu = 2
sa gen2
u 1, clear
cfout gender using gen2, id(id) saving(diff, keepusing(onlyu)) nomatch
u diff, clear
assert !_N
unab all : _all
loc expected id onlyu Question Master Using
assert `:list all == expected'
conf numeric var id onlyu Master Using
conf str var Question
cd ..

* Test 81
cd 81
u 1, clear
cfout gender using 2, id(id) saving(diff)
cfout gender using 2, id(id) saving(diff_props, properties())
compdta diff diff_props
loc type : type gender
loc format : format gender
loc vallabel sex
lab de `vallabel' 1 male 2 female
lab val gender `vallabel'
loc varlabel Respondent gender
lab var gender "`varlabel'"
sa gen1
loc opts type format vallabel varlabel
foreach opt of loc opts {
	cfout gender using 2, id(id) ///
		saving(diff1, replace properties(`opt'))
	cfout gender using 2, id(id) ///
		saving(diff2, replace properties(`opt'(myprop)))

	u diff1, clear
	assert _N
	assert Question == "gender"
	assert `opt' == "``opt''"
	unab all : _all
	loc expected id Question `opt' Master Using
	assert `:list all == expected'
	drop `opt'
	compdta diff

	u diff2, clear
	ren myprop `opt'
	compdta diff1

	u diff_props, clear
	gen order = _n
	merge id Question using diff1, sort keep(`opt')
	assert _merge == 3
	drop _merge
	move `opt' Master
	sort id order
	drop order
	sa, replace

	u gen1, clear
}
cfout gender using 2, id(id) saving(diff_all, properties(`opts')) nopre
compdta diff_props
cd ..

* Test 82
cd 82
u 1, clear
gen difftype = 1
preserve
u 2, clear
gen difftype = "1"
sa gen2
restore
cfout gender difftype using gen2, ///
	id(id) saving(diff)
assert "`r(difftype)'" == "difftype"
cfout gender difftype using gen2, ///
	id(id) saving(diff_props, properties(varlabel))
u diff_props, clear
drop varlabel
compdta diff
cd ..

* Test 84
cd 84
u 1, clear
cfout gender using 2, id(id) saving(diff)
char gender[x1] abc
char gender[x2] 123
cfout gender using 2, id(id) saving(diff_char, p(char(x1 x2)))
cfout gender using 2, id(id) saving(diff_charstub, p(char(x1 x2) charstub(c)))
u diff_char, clear
assert _N
assert Question == "gender"
assert char_x1 == "abc"
assert char_x2 == "123"
unab all : _all
loc expected id Question char_x1 char_x2 Master Using
assert `:list all == expected'
ren char_x1 cx1
ren char_x2 cx2
compdta diff_charstub
drop cx?
compdta diff
cd ..

* Test 86
cd 86
if c(stata_version) >= 13 {
	u 1, clear
	mata: st_global("gender[x]", x = (c("maxstrvarlen") + 1) * "x")
	cfout gender using 2, id(id) saving(diff, p(char(x))) nopre
	assert _N
	assert "`:type char_x'" == "strL"
	mata: assert(st_sdata(., "char_x") == J(st_nobs(), 1, x))
}
cd ..

* Test 87
cd 87
u 1, clear
cfout gender using 2, id(id) saving(diff)
loc note1 And Winter slumbering in the open air,
loc note2 Wears on his smiling face a dream of Spring!
note gender: `note1'
note gender: `note2'
sa gen1
cfout gender using 2, id(id) saving(diff_notes, p(notes(1 2)))
cfout gender using 2, id(id) saving(diff_notesstub, p(notes(1 2) notesstub(n)))
cfout gender using 2, id(id) saving(diff_char, p(char(note1 note2)))
u diff_notes, clear
assert _N
assert Question == "gender"
assert note1 == "`note1'"
assert note2 == "`note2'"
unab all : _all
loc expected id Question note1 note2 Master Using
assert `:list all == expected'
ren note1 n1
ren note2 n2
compdta diff_notesstub
forv i = 1/2 {
	ren n`i' char_note`i'
	lab var char_note`i' "Characteristic note`i'"
}
compdta diff_char
drop char_note?
compdta diff
* Various -notes()- specifications
u gen1, clear
foreach notes in 1/2 2/1 _all "1/2 2/1" "1/2 _all" "_all 1/2" "1 _all 2" ///
	"_all _all" {
	cfout gender using 2, id(id) saving(diff_list, p(notes(`notes')) replace)
	compdta diff_list diff_notes
}
cfout gender using 2, id(id) saving(diff_notes4, p(notes(1 2 4))) nopre
assert note4 == ""
drop note4
compdta diff_notes
u gen1, clear
cfout gender using 2, id(id) saving(diff_notes4_2, p(notes(1 2 4 _all))) nopre
compdta diff_notes4_2
cd ..


/* -------------------------------------------------------------------------- */
					/* old syntax			*/

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

* Test 45
cd 26
u gen1, clear
cfout one x using gen2, id(id) replace
assert r(N) == 1000
assert r(discrep) == 0
assert "`r(varlist)'" == "one"
assert "`r(alldiff)'" == "x"
insheet using "discrepancy report.csv", c n case clear
assert !_N
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

* Test 20
cd 20
u 1, clear
rcof "noi cfout gender using 2, id(id)" == 111
cd ..

* Test 21
cd 21
u 1, clear
cfout gender using 2, id(id)
conf numeric var id
tostring id, replace
conf str var id
rcof "noi cfout gender using 2, id(id)" == 106
u 2, clear
cfout gender using 1, id(id)
conf numeric var id
tostring id, replace
conf str var id
tempfile 2
sa `2'
u 1, clear
rcof "noi cfout gender using `2', id(id)" == 106
cd ..

* Test 29
cd 29
u 1, clear
cfout gender using 2, id(id) saving(diff)
#d ;
foreach opts in
	variable(id)
	masterval(id)
	usingval(id)
	variable(Master)
	variable(Using)
	masterval(Question)
	masterval(Using)
	usingval(Question)
	usingval(Master)
	"masterval(val) usingval(val)"
	all(id)
	all(Question)
	all(Master)
	all(Using)
	"keepmaster(gender) variable(gender)"
	"keepmaster(gender) masterval(gender)"
	"keepmaster(gender) usingval(gender)"
	"keepmaster(gender) all(gender)"
	"keepusing(gender)  variable(gender)"
	"keepusing(gender)  masterval(gender)"
	"keepusing(gender)  usingval(gender)"
	"keepusing(gender)  all(gender)"
	"keepmaster(gender) keepusing(gender)"
	p(varlab(id))
	p(varlab(Question))
	p(varlab(Master))
	p(varlab(Using))
	"p(varlab(diff)) all"
	"p(varlab(gender)) keepmaster(gender)"
	"p(varlab(gender)) keepusing(gender)"
	"p(type(x) format(x))"
	"p(type(x) vallabel(x))"
	"p(type(x) varlabel(x))"
	"p(type(char_x) char(x))"
	"p(type(note1) notes(1))"
	"p(format(x) vallabel(x))"
	"p(format(x) varlabel(x))"
	"p(format(char_x) char(x))"
	"p(format(note1) notes(1))"
	"p(vallabel(x) varlabel(x))"
	"p(vallabel(char_x) char(x))"
	"p(vallabel(note1) notes(1))"
	"p(varlabel(char_x) char(x))"
	"p(varlabel(note1) notes(1))"
	"p(char(note1) notes(1) notesstub(char_note))"
{;
	#d cr
	rcof "noi cfout gender using 2, id(id) saving(diff, `opts' replace)" == 198
}
cd ..

* Test 32
cd 30
u gen1, clear
cfout gender using gen2, id(id1 id2)
expand 2
rcof "noi cfout gender using gen2, id(id1 id2)" == 459
u gen2, clear
expand 2
tempfile 2
sa `2'
u gen1, clear
rcof "noi cfout gender using `2', id(id1 id2)" == 459
cd ..

* Test 33
cd 31
if c(stata_version) >= 13 {
	u gen1, clear
	cfout gender using gen2, id(id1 id2)
	recast strL id2
	rcof "noi cfout gender using gen2, id(id1 id2)" == 109
	u gen2, clear
	recast strL id2
	tempfile 2
	sa `2'
	u gen1, clear
	rcof "noi cfout gender using `2', id(id1 id2)" == 109
}
cd ..

* Test 50
cd 17
u gen1, clear
rcof "noi cfout s using gen2, id(id) strcomp(sc_lower Master Using)" == 101
pr sc_using
	syntax varlist(min=2 max=2) using
end
tempfile temp
sa `temp'
rcof `"noi cfout s using gen2, id(id) strcomp(sc_lower using `temp')"' == 101
cd ..

* Test 51
cd 17
u gen1, clear
rcof "noi cfout s using gen2, id(id) strcomp(DoesNotExist)" == 199
cd ..

* Test 52
cd 17
pr sc_error
	di as err "sc_error error"
	ex 123
end
u gen1, clear
rcof "noi cfout s using gen2, id(id) strcomp(sc_error)" == 123
cd ..

* Test 55
cd 55
u 1, clear
rcof "noi cfout gender using 2, id(id) saving(diff, all all(diff))" == 198
rcof "noi cfout gender using 2, id(id) saving(diff, all all(foo))" == 198
cd ..

* Test 62
cd 17
u gen1, clear
rcof  "noi cfout s using gen2, id(id) strcomp(B@dN@me)" == 198
rcof `"noi cfout s using gen2, id(id) strcomp("two names")"' == 198
cd ..

* Test 64
cd 63
pr nc_error
	syntax varlist(min=2 max=2), Generate(name)

	di as err "nc_error error"
	ex 456
end
u gen1, clear
rcof "noi cfout x using gen2, id(id) numcomp(nc_error)" == 456
cd ..

* Test 65
cd 63
u gen1, clear
rcof "noi cfout x using gen2, id(id) numcomp(DoesNotExist)" == 199
cd ..

* Test 66
cd 63
pr nc_no_generate
	syntax varlist(min=2 max=2)
	di "Hello world!"
end
u gen1, clear
rcof "noi cfout x using gen2, id(id) numcomp(nc_no_generate)" == 101
cd ..

* Test 67
cd 63
pr nc_only_generate
	syntax, Generate(name)

	gen `generate' = 1
end
u gen1, clear
rcof "noi cfout x using gen2, id(id) numcomp(nc_only_generate)" == 101
cd ..

* Test 68
cd 63
pr nc_gen_str
	syntax varlist(min=2 max=2), Generate(name)

	gen `generate' = "1"
end
u gen1, clear
rcof "noi cfout x using gen2, id(id) numcomp(nc_gen_str)" == 109
cd ..

* Test 73
cd 73
u 1, clear
rcof "noi cfout gender using 2, id(id) saving(diff, keepmaster(onlym))" == 111
rcof "noi cfout gender using 2, id(id) saving(diff, keepmaster(o*))" == 111
rcof "noi cfout gender using 2, id(id) saving(diff, keepusing(onlyu))" == 111
rcof "noi cfout gender using 2, id(id) saving(diff, keepusing(o*))" == 111
compdta 1
cd ..

* Test 83
cd 83
u 1, clear
foreach opt in type format vallabel varlabel {
	#d ;
	rcof "noi cfout gender using 2, id(id) saving(diff, p(`opt' `opt'(xyz)))"
		== 198;
	#d cr
}
cd ..

* Test 85
cd 85
u 1, clear
char gender[x] abc
loc x31 : di _dup(31) "x"
loc x32 : di _dup(32) "x"
cfout gender using 2, id(id) saving(diff1, p(char(x) charstub(`x31')))
#d ;
rcof "noi cfout gender using 2, id(id)
	saving(diff2, p(char(x) charstub(`x32')))" == 7;
#d cr
cd ..

* Test 88
cd 88
u 1, clear
note gender: Lugete, O Veneres Cupidinesque
loc x31 : di _dup(31) "x"
loc x32 : di _dup(32) "x"
loc cfout noi cfout gender using 2, id(id)
`cfout' saving(diff, p(note(1) notesstub(`x31')))
erase diff.dta
rcof "`cfout' saving(diff, p(note(1) notesstub(`x32')))" == 7
rcof "`cfout' saving(diff, p(note(0)))" == 125
rcof "`cfout' saving(diff, p(note(-1)))" == 125
rcof "`cfout' saving(diff, p(note(1.5)))" == 126
rcof "`cfout' saving(diff, p(note(x)))" == 121
rcof `"`cfout' saving(diff, p(note(" ")))"' == 122
cd ..


/* -------------------------------------------------------------------------- */
					/* finish up			*/

cd ..

timer off 1
timer list 1

if `profile' {
	cap conf f C:\ado\profile.do
	if !_rc ///
		run C:\ado\profile
}

timer list 1

log close cfout
