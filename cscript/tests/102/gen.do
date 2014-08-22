if c(stata_version) < 13 ///
	ex

vers 13

clear
set obs 1
gen id = _n
gen s = "x"
sa gen1

replace s = char(0)
sa gen2
