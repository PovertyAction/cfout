vers 10

clear programs

set seed 969252244

c cfout
cd help/example

u 1/firstEntry, clear
assert uniqueid == _n
merge uniqueid using 1/secondEntry, sort
assert _merge == 3
loc N = _N

forv i = 1/2 {
	u 2.0.0/names if N > 10000, clear
	drop N
	bsample `N', strata(gender)
	sort gender
	gen uniqueid = mod(_n - 1, `N') + 1
	tempfile names`i'
	sa `names`i''
}

foreach dta in firstEntry secondEntry {
	u "1/`dta'", clear

	forv i = 1/2 {
		cou if mi(gender)
		assert r(N) < 2
		ren gender gender_miss
		gen gender = cond(!mi(gender_miss), gender_miss, 1)

		merge uniqueid gender using `names`i'', sort
		assert _merge != 1
		drop if _merge == 2
		drop gender _merge
		ren gender_miss gender

		foreach char in . [ ] {
			replace firstname = firstname + cond(runiform() < .07, "`char'", "")
		}
		ren firstname firstname`i'
	}

	gen firstname = cond(runiform() < .07, firstname1, firstname2)
	drop firstname?
	gen lily = inlist(uniqueid, 3, 947)
	replace firstname = cond("`dta'" == "firstEntry", "Lily", "Lilly") if lily
	drop lily

	sa "2.0.0/`dta'", replace
}

cd 2.0.0
u firstEntry, clear

cfout region-no_good_at_all using secondEntry, id(uniqueid)
cfout firstname using secondEntry, id(uniqueid)
cfout firstname using secondEntry, id(uniqueid) nopunct
loc nopunct = r(discrep)

program remove_brackets
	syntax varlist(min=2 max=2 string)

	foreach var of local varlist {
		replace `var' = subinstr(`var', "[", "", .)
		replace `var' = subinstr(`var', "]", "", .)
	}
end
cfout firstname using secondEntry, id(uniqueid) nopunct strcomp(remove_brackets)

program fromto
	syntax varlist(min=2 max=2 string), from(string) to(string)

	foreach var of local varlist {
		replace `var' = "`to'" if `var' == "`from'"
	}
end
cfout firstname using secondEntry, id(uniqueid) nopunct strcomp(fromto, from(Lilly) to(Lily))
assert r(discrep) < `nopunct'

pr drop remove_brackets fromto
