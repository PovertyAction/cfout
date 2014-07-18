vers 10

clear
set obs 2

gen id = _n
lab de labid 1 one 2 two
lab val id labid

gen double x = _n
form x %8.0g

forv i = 1/2 {
	replace x = x + 1e-15 in L
	sa gen`i'
}
