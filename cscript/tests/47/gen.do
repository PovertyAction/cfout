vers 10

clear
set obs 2

gen id = _n
gen n = _n

gen s = ""
replace s = "A" in 1
replace s = "B" in 2

gen s_alldiff = s

sa gen1, replace

replace n = n + 1 in 1
assert s != "C" in 1
replace s = "C" in 1

isid s_alldiff
sca s1 = s_alldiff[1]
replace s_alldiff = s_alldiff[_n + 1]
replace s_alldiff = s1 in L
isid s_alldiff

sa gen2, replace
