vers 10

clear
input id labeled formatted
0.5 0.5 0.5
1 0 0
1.5 1.5 1.5
2 1 1
2.5 2.5 2.5
3 2 2
3.5 3.5 3.5
end

form labeled formatted %td

lab de lab 0 "Value 0" 1 ""
lab val labeled lab

sa gen1

drop _all
input id labeled formatted
0.5 0.5 0.5
1 1 1
1.5 1.5 1.5
2 2 1
2.5 2.5 2.5
3 0 2
3.5 3.5 3.5
end

form labeled formatted %td
lab val labeled lab

sa gen2
