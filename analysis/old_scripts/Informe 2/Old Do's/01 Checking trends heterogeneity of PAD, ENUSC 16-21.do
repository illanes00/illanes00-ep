/*******************************************************************************
	Project:	Seguridad Pública EP, Informe 2
	
	Title:		01 Checking trends heterogeneity of PAD, ENUSC 16-21
	Author:		Lucas García
	Date:		January 31, 2023
	Version:	Stata 17

	Summary:	This dofile uses enusc_16_21 from use data to plot the trends 
				of perceptions of the rise in crime rates, checking heterogeneity
				by different social variables.
				
*******************************************************************************/

clear all

************************************************
*                0. Key Macros                 *
************************************************

*Folder globals

di "current user: `c(username)'"
if "`c(username)'" == "Lucas"{
	global path "C:\Users\Lucas\Dropbox\Seguridad Pública"
}
else if "`c(username)'" == "add user name"{
	global path ""	//	Escribir Dirección
}
	global rawdata "$path/01 RawData"
	global dofiles "$path/02 Code"
	global usedata "$path/04 Usedata"
	global graphs "$path/05 Graphs/Informe 2"
	global tables "$path/06 Tables"
	
************************************************
*              1. PAD TRENDS	               *
************************************************

*00			Open DB & defining data as survey
use "$usedata/enusc_16_21", clear

*	Set as survey
svyset enc_idr [pweight=Fact_pers], strata(VarStrat) singleunit(certainty)

*01			Trend of PAD Variable, By geographic group
tempname lgc
tempfile pad
postfile `lgc' mean_pais mean_comuna mean_barrio year using `pad', replace

svy: mean pad , over(year)
mat table_pais = r(table)

svy: mean pad_comuna , over(year)
mat table_comuna = r(table)

svy: mean pad_barrio , over(year)
mat table_barrio = r(table)

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_pais[1,`y']) (table_comuna[1,`y']) (table_barrio[1,`y']) (`year')
}  

postclose `lgc'

preserve
use "`pad'", clear

*	Trend
#delimit ;

twoway	(scatter mean_pais year , connect(direct) msymbol(circle)) 
		(scatter mean_comuna year , connect(direct) msymbol(D)) 
		(scatter mean_barrio year , connect(direct) msymbol(T)) ,
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"Percepción de aumento de la delincuencia a nivel país"
						2	"Percepción de aumento de la delincuencia a nivel comuna"
						3	"Percepción de aumento de la delincuencia a nivel barrio") size(small) r(3));

#delimit cr

graph export "$graphs/Tendencias de percepción, País, Comuna y Barrio, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de percepción, País, Comuna y Barrio, 2016-2021.png", replace
graph export "$graphs/Tendencias de percepción, País, Comuna y Barrio, 2016-2021.eps", replace
restore

*02			Trend of PAD Variable, By geographic group & sex
tempname lgc
tempfile pad
postfile `lgc' mean_pais mean_comuna mean_barrio year female using `pad', replace

svy: mean pad , over(year rph_sexo)
mat table_pais = r(table)

svy: mean pad_comuna , over(year rph_sexo)
mat table_comuna = r(table)

svy: mean pad_barrio , over(year rph_sexo)
mat table_barrio = r(table)

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+1
	post `lgc' (table_pais[1,`column']) (table_comuna[1,`column']) (table_barrio[1,`column'])  (`year') (1)
}  

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+2
	post `lgc' (table_pais[1,`column']) (table_comuna[1,`column']) (table_barrio[1,`column'])  (`year') (2)
}

postclose `lgc'

preserve
use "`pad'", clear

*	Trend
#delimit ;

twoway	(scatter mean_pais year if female==1, lpattern(dash) connect(direct)  symbol(Oh) lcolor(navy) mcolor(navy)) 
		(scatter mean_comuna year if female==1, lpattern(dash) connect(direct) symbol(Dh) lcolor(maroon) mcolor(maroon)) 
		(scatter mean_barrio year if female==1, lpattern(dash) connect(direct) symbol(Th) lcolor(dkgreen) mcolor(dkgreen))
		(scatter mean_pais year if female==2, connect(direct) symbol(O) lcolor(navy) mcolor(navy)) 
		(scatter mean_comuna year if female==2, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon)) 
		(scatter mean_barrio year if female==2, connect(direct) symbol(T) lcolor(dkgreen) mcolor(dkgreen)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"Percepción de aumento de la delincuencia a nivel país, Hombres"
						2	"Percepción de aumento de la delincuencia a nivel comuna, Hombres"
						3	"Percepción de aumento de la delincuencia a nivel barrio, Hombres"
						4	"Percepción de aumento de la delincuencia a nivel país, Mujeres"
						5	"Percepción de aumento de la delincuencia a nivel comuna, Mujeres"
						6	"Percepción de aumento de la delincuencia a nivel barrio, Mujeres") size(small) r(6));

#delimit cr

graph export "$graphs/Tendencias de percepción, País, Comuna y Barrio, Hombres y mujeres 2016-2021.pdf", replace
graph export "$graphs/Tendencias de percepción, País, Comuna y Barrio, Hombres y mujeres 2016-2021.png", replace
graph export "$graphs/Tendencias de percepción, País, Comuna y Barrio, Hombres y mujeres 2016-2021.eps", replace
restore


*03			Trend of PAD Variable, By geographic group & education level
tempname lgc
tempfile pad
postfile `lgc' mean_pais mean_comuna mean_barrio year educ using `pad', replace

* Education levels
g low = 1 if (rph_nivel==0 | rph_nivel==1 | rph_nivel==2) & Kish==1 & year==2021
replace low = 1 if (rph_nivel<=8 | rph_nivel==90) & year<=2019

g high = 1 if (rph_nivel==3) & Kish==1 & year==2021
replace high = 1 if (rph_nivel>=9 & rph_nivel<=13) & year<=2019
replace high=0 if low==1

svy: mean pad , over(year high)
mat table_pais = r(table)

svy: mean pad_comuna , over(year high)
mat table_comuna = r(table)

svy: mean pad_barrio , over(year high)
mat table_barrio = r(table)

forvalues y = 0(2)8{
	local year = `y'+2016-`y'/2
	local column = `y'+1
	post `lgc' (table_pais[1,`column']) (table_comuna[1,`column']) (table_barrio[1,`column'])  (`year') (0)
}  

forvalues y = 0(2)8{
	local year = `y'+2016-`y'/2
	local column = `y'+2
	post `lgc' (table_pais[1,`column']) (table_comuna[1,`column']) (table_barrio[1,`column'])  (`year') (1)
}

postclose `lgc'

preserve
use "`pad'", clear

replace year=2021 if year==2020

*	Trend
#delimit ;

twoway	(scatter mean_pais year if educ==1, lpattern(dash) connect(direct)  symbol(Oh) lcolor(navy) mcolor(navy)) 
		(scatter mean_comuna year if educ==1, lpattern(dash) connect(direct) symbol(Dh) lcolor(maroon) mcolor(maroon)) 
		(scatter mean_barrio year if educ==1, lpattern(dash) connect(direct) symbol(Th) lcolor(dkgreen) mcolor(dkgreen))
		(scatter mean_pais year if educ==0, connect(direct) symbol(O) lcolor(navy) mcolor(navy)) 
		(scatter mean_comuna year if educ==0, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon)) 
		(scatter mean_barrio year if educ==0, connect(direct) symbol(T) lcolor(dkgreen) mcolor(dkgreen)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"PAD a nivel país, con educación superior"
						2	"PAD a nivel comuna, con educación superior"
						3	"PAD a nivel barrio, con educación superior"
						4	"PAD a nivel país, sin educación superior"
						5	"PAD a nivel comuna, sin educación superior"
						6	"PAD a nivel barrio, sin educación superior") size(small) r(6));

#delimit cr

graph export "$graphs/Tendencias de percepción, País, Comuna y Barrio, Educación 2016-2021.pdf", replace
graph export "$graphs/Tendencias de percepción, País, Comuna y Barrio, Educación 2016-2021.png", replace
graph export "$graphs/Tendencias de percepción, País, Comuna y Barrio, Educación 2016-2021.eps", replace
restore


*04			Trend of PAD Variable, By geographic group & age
tempname lgc
tempfile pad
postfile `lgc' mean_pais mean_comuna mean_barrio year age using `pad', replace

* Age ranges
g age_range = 1 if (rph_edad==1 | rph_edad==2) & Kish==1
replace age_range = 2 if (rph_edad==3 | rph_edad==4) & Kish==1
replace age_range = 3 if (rph_edad==5 | rph_edad==6) & Kish==1
replace age_range = 4 if (rph_edad==7 | rph_edad==8) & Kish==1
replace age_range = 5 if (rph_edad==9 | rph_edad==10) & Kish==1

svy: mean pad , over(year age_range)
mat table_pais = r(table)

svy: mean pad_comuna , over(year age_range)
mat table_comuna = r(table)

svy: mean pad_barrio , over(year age_range)
mat table_barrio = r(table)

forvalues x = 1/5{
	forvalues y = 0(5)25{
		local year = `y'/5+2016
		local column = `y'+`x'
		post `lgc' (table_pais[1,`column']) (table_comuna[1,`column']) (table_barrio[1,`column'])  (`year') (`x'-1)
	} 
}

postclose `lgc'

preserve
use "`pad'", clear

*	Trend

*Country level
#delimit ;

twoway	(scatter mean_pais year if age==0, connect(direct) symbol(D)) 
		(scatter mean_pais year if age==1, connect(direct) symbol(S))
		(scatter mean_pais year if age==2, connect(direct) symbol(T))
		(scatter mean_pais year if age==3, connect(direct) symbol(X))
		(scatter mean_pais year if age==4, connect(direct) symbol(O)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"PAD a nivel país, entre 15 y 24 años"
						2	"PAD a nivel país, entre 25 y 39 años"
						3	"PAD a nivel país, entre 40 y 59 años"
						4	"PAD a nivel país, entre 60 y 79 años"
						5	"PAD a nivel país, 80 años o más") size(small) r(5));

#delimit cr

graph export "$graphs/Tendencias de percepción, País, Tramos de edad, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de percepción, País, Tramos de edad, 2016-2021.png", replace
graph export "$graphs/Tendencias de percepción, País, Tramos de edad, 2016-2021.eps", replace

*Municipality level
#delimit ;

twoway	(scatter mean_comuna year if age==0, connect(direct) symbol(D)) 
		(scatter mean_comuna year if age==1, connect(direct) symbol(S))
		(scatter mean_comuna year if age==2, connect(direct) symbol(T))
		(scatter mean_comuna year if age==3, connect(direct) symbol(X))
		(scatter mean_comuna year if age==4, connect(direct) symbol(O)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"PAD a nivel comuna, entre 15 y 24 años"
						2	"PAD a nivel comuna, entre 25 y 39 años"
						3	"PAD a nivel comuna, entre 40 y 59 años"
						4	"PAD a nivel comuna, entre 60 y 79 años"
						5	"PAD a nivel comuna, 80 años o más") size(small) r(5));

#delimit cr

graph export "$graphs/Tendencias de percepción, Comuna, Tramos de edad, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de percepción, Comuna, Tramos de edad, 2016-2021.png", replace
graph export "$graphs/Tendencias de percepción, Comuna, Tramos de edad, 2016-2021.eps", replace

*Neighborhood level
#delimit ;

twoway	(scatter mean_barrio year if age==0, connect(direct) symbol(D)) 
		(scatter mean_barrio year if age==1, connect(direct) symbol(S))
		(scatter mean_barrio year if age==2, connect(direct) symbol(T))
		(scatter mean_barrio year if age==3, connect(direct) symbol(X))
		(scatter mean_barrio year if age==4, connect(direct) symbol(O)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"PAD a nivel barrio, entre 15 y 24 años"
						2	"PAD a nivel barrio, entre 25 y 39 años"
						3	"PAD a nivel barrio, entre 40 y 59 años"
						4	"PAD a nivel barrio, entre 60 y 79 años"
						5	"PAD a nivel barrio, 80 años o más") size(small) r(5));

#delimit cr

graph export "$graphs/Tendencias de percepción, Barrio, Tramos de edad, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de percepción, Barrio, Tramos de edad, 2016-2021.png", replace
graph export "$graphs/Tendencias de percepción, Barrio, Tramos de edad, 2016-2021.eps", replace

restore


*05			Trend of PAD Variable, By geographic group & working situation (kish only)
tempname lgc
tempfile pad
postfile `lgc' mean_pais mean_comuna mean_barrio year working using `pad', replace

* Working Situation
replace working=. if working>2 | Kish==0
replace working=0 if working==2

svy: mean pad , over(year working)
mat table_pais = r(table)

svy: mean pad_comuna , over(year working)
mat table_comuna = r(table)

svy: mean pad_barrio , over(year working)
mat table_barrio = r(table)

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+1
	post `lgc' (table_pais[1,`column']) (table_comuna[1,`column']) (table_barrio[1,`column'])  (`year') (0)
}  

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+2
	post `lgc' (table_pais[1,`column']) (table_comuna[1,`column']) (table_barrio[1,`column'])  (`year') (1)
}

postclose `lgc'

preserve
use "`pad'", clear

*	Trend
#delimit ;

twoway	(scatter mean_pais year if working==1, lpattern(dash) connect(direct)  symbol(Oh) lcolor(navy) mcolor(navy)) 
		(scatter mean_comuna year if working==1, lpattern(dash) connect(direct) symbol(Dh) lcolor(maroon) mcolor(maroon)) 
		(scatter mean_barrio year if working==1, lpattern(dash) connect(direct) symbol(Th) lcolor(dkgreen) mcolor(dkgreen))
		(scatter mean_pais year if working==0, connect(direct) symbol(O) lcolor(navy) mcolor(navy)) 
		(scatter mean_comuna year if working==0, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon)) 
		(scatter mean_barrio year if working==0, connect(direct) symbol(T) lcolor(dkgreen) mcolor(dkgreen)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"PAD a nivel país, trabajó semana pasada"
						2	"PAD a nivel comuna, trabajó semana pasada"
						3	"PAD a nivel barrio, trabajó semana pasada"
						4	"PAD a nivel país, no trabajó semana pasada"
						5	"PAD a nivel comuna, no trabajó semana pasada"
						6	"PAD a nivel barrio, no trabajó semana pasada") size(small) r(6));

#delimit cr

graph export "$graphs/Tendencias de percepción, País, Comuna y Barrio, Trabajo 2016-2021.pdf", replace
graph export "$graphs/Tendencias de percepción, País, Comuna y Barrio, Trabajo 2016-2021.png", replace
graph export "$graphs/Tendencias de percepción, País, Comuna y Barrio, Trabajo 2016-2021.eps", replace
restore

