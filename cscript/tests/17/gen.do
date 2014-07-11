vers 10.1

#d ;
loc s
	/* lower/upper */
	x	X
	/* lower/upper */
	xY	Xy
	/* nopunct */
	x	x.
	/* lower/upper + nopunct */
	x	X.
	/* simply different */
	x	y
	/* simply the same */
	x	x
	y	y
;
#d cr

loc seed "`c(seed)'"

forv i = 1/2 {
	clear

	gen s = ""
	loc copy : copy loc s
	while `:list sizeof copy' {
		gettoken s1 copy : copy
		gettoken s2 copy : copy

		set obs `=_N + 1'
		replace s = `"`s`i''"' in L
	}

	gen id = _n
	set seed 335610938
	gen x = ceil(2000 * runiform())

	sa gen`i', replace
}

set seed `seed'
