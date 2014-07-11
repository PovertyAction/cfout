vers 10

loc ctr 0
cap di (""")
assert _rc
while _rc {
	loc ++ctr

	u id using 1, clear

	forv i = 1/2 {
		gen id`i' = ceil(0.4 * _N * runiform())
	}

	cap isid id1 id2
}

tempfile idmap
sa `idmap'

#d ;
loc dtas "
	1				gen1
	2				gen2
	expected/diff	gen_diff
";
#d cr
while `:list sizeof dtas' {
	gettoken old dtas : dtas
	gettoken new dtas : dtas

	u "`old'", clear

	d, varl
	loc sort `r(sortlist)'

	merge id using `idmap', sort
	drop if _merge == 2
	drop _merge
	move id1 id
	move id2 id
	drop id

	if "`sort'" != "" {
		loc sort : subinstr loc sort "id" "id1 id2", word all
		sort `sort'
	}

	compress id*
	sa "`new'", replace
}

di `ctr'
