vers 10

forv i = 1/2 {
	clear
	set obs 1000

	gen id = _n

	gen one = 1
	gen x = _n + _N * `i'

	sa gen`i', replace
}
