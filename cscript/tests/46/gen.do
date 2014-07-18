vers 10

clear
set obs 3

gen id = _n
gen n = _n
gen s = _n
tostring s, replace

sa gen1

destring s, replace
replace n = n + 1 in 1
replace s = s + 1 in 1/2
tostring s, replace

sa gen2
