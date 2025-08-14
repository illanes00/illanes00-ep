/*******************************************************************************
	Project:	Seguridad Pública EP, Informe 2
	
	Title:		05 Checking trends heterogeneity of Insecurity Sensation, ENUSC 16-21
	Author:		Lucas García
	Date:		February 14, 2023
	Version:	Stata 17

	Summary:	This dofile uses enusc_16_21 from use data to plot the trends 
				of perceptions of insecurity sensation in specific situations, 
				checking heterogeneity by different social variables.
				
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

*	Preparing dummy variables
foreach x in walk_alone house_alone waiting_pt{
	g `x'_aux = dk_`x'
	drop dk_`x'
	g dk_`x'=(`x'_aux>=3)
	replace dk_`x'=. if `x'_aux>=85
	drop `x'_aux
}

*01			Trend of Insecurity Sensation Variable, By geographic group
tempname lgc
tempfile is
postfile `lgc' mean_walk_alone mean_house_alone mean_pt_stations year using `is', replace

svy: mean dk_walk_alone , over(year)
mat table_walk_alone = r(table)

svy: mean dk_house_alone , over(year)
mat table_house_alone = r(table)

svy: mean dk_waiting_pt , over(year)
mat table_waiting_pt = r(table)

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_walk_alone[1,`y']) (table_house_alone[1,`y']) (table_waiting_pt[1,`y']) (`year')
}  

postclose `lgc'

preserve
use "`is'", clear

*	Trend
#delimit ;

twoway	(scatter mean_walk_alone year , connect(direct) msymbol(circle))
		(scatter mean_house_alone year , connect(direct) msymbol(T))
		(scatter mean_pt_stations year , connect(direct) msymbol(D)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1) 
		legend(order(	1	"Caminando solo/a por su barrio"
						2	"Solo/a en su casa"
						3	"Esperando el transporte público")
		size(small) r(3));

#delimit cr

graph export "$graphs/Tendencias de sensación de seguridad, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de sensación de seguridad, 2016-2021.png", replace
graph export "$graphs/Tendencias de sensación de seguridad, 2016-2021.eps", replace
restore

*02			Trend of IS Variable, By geographic group & sex
tempname lgc
tempfile is
postfile `lgc' mean_walk_alone mean_house_alone mean_pt_stations year female using `is', replace

svy: mean dk_walk_alone , over(year rph_sexo)
mat table_walk_alone = r(table)

svy: mean dk_house_alone , over(year rph_sexo)
mat table_house_alone = r(table)

svy: mean dk_waiting_pt , over(year rph_sexo)
mat table_waiting_pt = r(table)

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+1
	post `lgc' (table_walk_alone[1,`column']) (table_house_alone[1,`column']) (table_waiting_pt[1,`column']) (`year') (1)
}  

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+2
	post `lgc' (table_walk_alone[1,`column']) (table_house_alone[1,`column']) (table_waiting_pt[1,`column']) (`year') (2)
}

postclose `lgc'

preserve
use "`is'", clear

*	Trend
#delimit ;

twoway	(scatter mean_walk_alone year if female==1, lpattern(dash) connect(direct)  symbol(Oh) lcolor(navy) mcolor(navy)) 
		(scatter mean_house_alone year if female==1, lpattern(dash) connect(direct) symbol(Th) lcolor(maroon) mcolor(maroon))
		(scatter mean_pt_stations year if female==1, lpattern(dash) connect(direct) symbol(Dh) lcolor(dkgreen) mcolor(dkgreen))
		(scatter mean_walk_alone year if female==2, connect(direct)  symbol(O) lcolor(navy) mcolor(navy)) 
		(scatter mean_house_alone year if female==2, connect(direct) symbol(T) lcolor(maroon) mcolor(maroon))
		(scatter mean_pt_stations year if female==2, connect(direct) symbol(D) lcolor(dkgreen) mcolor(dkgreen)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"Caminando solo/a por su barrio, Hombres"
						2	"Solo/a en su casa, Hombres"
						3	"Esperando el transporte público, Hombres"
						4	"Caminando solo/a por su barrio, Mujeres"
						5	"Solo/a en su casa, Mujeres"
						6	"Esperando el transporte público, Mujeres") r(6));

#delimit cr

graph export "$graphs/Tendencias de sensación de seguridad, Hombres y mujeres 2016-2021.pdf", replace
graph export "$graphs/Tendencias de sensación de seguridad, Hombres y mujeres 2016-2021.png", replace
graph export "$graphs/Tendencias de sensación de seguridad, Hombres y mujeres 2016-2021.eps", replace
restore


*03			Trend of IS Variable, By geographic group & education level
tempname lgc
tempfile is
postfile `lgc' mean_walk_alone mean_house_alone mean_pt_stations year educ using `is', replace

* Education levels
g low = 1 if (rph_nivel==0 | rph_nivel==1 | rph_nivel==2) & Kish==1 & year==2021
replace low = 1 if (rph_nivel<=8 | rph_nivel==90) & year<=2019

g high = 1 if (rph_nivel==3) & Kish==1 & year==2021
replace high = 1 if (rph_nivel>=9 & rph_nivel<=13) & year<=2019
replace high=0 if low==1

svy: mean dk_walk_alone , over(year high)
mat table_walk_alone = r(table)

svy: mean dk_house_alone , over(year high)
mat table_house_alone = r(table)

svy: mean dk_waiting_pt , over(year high)
mat table_waiting_pt = r(table)

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+1
	post `lgc' (table_walk_alone[1,`column']) (table_house_alone[1,`column']) (table_waiting_pt[1,`column']) (`year') (0)
}  

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+2
	post `lgc' (table_walk_alone[1,`column']) (table_house_alone[1,`column']) (table_waiting_pt[1,`column']) (`year') (1)
}

postclose `lgc'

preserve
use "`is'", clear

replace year=2021 if year==2020

*	Trend
#delimit ;

twoway	(scatter mean_walk_alone year if educ==1, lpattern(dash) connect(direct)  symbol(Oh) lcolor(navy) mcolor(navy)) 
		(scatter mean_house_alone year if educ==1, lpattern(dash) connect(direct) symbol(Th) lcolor(maroon) mcolor(maroon))
		(scatter mean_pt_stations year if educ==1, lpattern(dash) connect(direct) symbol(Dh) lcolor(dkgreen) mcolor(dkgreen))
		(scatter mean_walk_alone year if educ==0, connect(direct)  symbol(O) lcolor(navy) mcolor(navy)) 
		(scatter mean_house_alone year if educ==0, connect(direct) symbol(T) lcolor(maroon) mcolor(maroon))
		(scatter mean_pt_stations year if educ==0, connect(direct) symbol(D) lcolor(dkgreen) mcolor(dkgreen)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"Caminando solo/a por su barrio, Con educación superior"
						2	"Solo/a en su casa, Con educación superior"
						3	"Esperando el transporte público, Con educación superior"
						4	"Caminando solo/a por su barrio, Sin educación superior"
						5	"Solo/a en su casa, Sin educación superior"
						6	"Esperando el transporte público, Sin educación superior") r(6));

#delimit cr

graph export "$graphs/Tendencias de sensación de seguridad, Educación 2016-2021.pdf", replace
graph export "$graphs/Tendencias de sensación de seguridad, Educación 2016-2021.png", replace
graph export "$graphs/Tendencias de sensación de seguridad, Educación 2016-2021.eps", replace
restore


*04			Trend of IS Variable, By geographic group & age
tempname lgc
tempfile is
postfile `lgc' mean_walk_alone mean_house_alone mean_pt_stations year age using `is', replace

* Age ranges
g age_range = 1 if (rph_edad==1 | rph_edad==2) & Kish==1
replace age_range = 2 if (rph_edad==3 | rph_edad==4) & Kish==1
replace age_range = 3 if (rph_edad==5 | rph_edad==6) & Kish==1
replace age_range = 4 if (rph_edad==7 | rph_edad==8) & Kish==1
replace age_range = 5 if (rph_edad==9 | rph_edad==10) & Kish==1

svy: mean dk_walk_alone , over(year age_range)
mat table_walk_alone = r(table)

svy: mean dk_house_alone , over(year age_range)
mat table_house_alone = r(table)

svy: mean dk_waiting_pt , over(year age_range)
mat table_waiting_pt = r(table)

forvalues x = 1/5{
	forvalues y = 0(5)25{
		local year = `y'/5+2016
		local column = `y'+`x'
		post `lgc' (table_walk_alone[1,`column']) (table_house_alone[1,`column']) (table_waiting_pt[1,`column']) (`year') (`x'-1)
	} 
}

postclose `lgc'

preserve
use "`is'", clear

*	Trend
*Walking Alone
#delimit ;

twoway	(scatter mean_walk_alone year if age==0, connect(direct) symbol(D)) 
		(scatter mean_walk_alone year if age==1, connect(direct) symbol(S))
		(scatter mean_walk_alone year if age==2, connect(direct) symbol(T))
		(scatter mean_walk_alone year if age==3, connect(direct) symbol(X))
		(scatter mean_walk_alone year if age==4, connect(direct) symbol(O)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"Caminando solo/a por su barrio, entre 15 y 24 años"
						2	"Caminando solo/a por su barrio, entre 25 y 39 años"
						3	"Caminando solo/a por su barrio, entre 40 y 59 años"
						4	"Caminando solo/a por su barrio, entre 60 y 79 años"
						5	"Caminando solo/a por su barrio, 80 años o más") size(small) r(5));

#delimit cr

graph export "$graphs/Tendencias de sensación de seguridad, Caminando, Tramos de edad, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de sensación de seguridad, Caminando, Tramos de edad, 2016-2021.png", replace
graph export "$graphs/Tendencias de sensación de seguridad, Caminando, Tramos de edad, 2016-2021.eps", replace

*Home Alone
#delimit ;

twoway	(scatter mean_house_alone year if age==0, connect(direct) symbol(D)) 
		(scatter mean_house_alone year if age==1, connect(direct) symbol(S))
		(scatter mean_house_alone year if age==2, connect(direct) symbol(T))
		(scatter mean_house_alone year if age==3, connect(direct) symbol(X))
		(scatter mean_house_alone year if age==4, connect(direct) symbol(O)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"Solo/a en su casa, entre 15 y 24 años"
						2	"Solo/a en su casa, entre 25 y 39 años"
						3	"Solo/a en su casa, entre 40 y 59 años"
						4	"Solo/a en su casa, entre 60 y 79 años"
						5	"Solo/a en su casa, 80 años o más") size(small) r(5));

#delimit cr

graph export "$graphs/Tendencias de sensación de seguridad, Casa, Tramos de edad, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de sensación de seguridad, Casa, Tramos de edad, 2016-2021.png", replace
graph export "$graphs/Tendencias de sensación de seguridad, Casa, Tramos de edad, 2016-2021.eps", replace

*Waiting Public Transport
#delimit ;

twoway	(scatter mean_pt_stations year if age==0, connect(direct) symbol(D)) 
		(scatter mean_pt_stations year if age==1, connect(direct) symbol(S))
		(scatter mean_pt_stations year if age==2, connect(direct) symbol(T))
		(scatter mean_pt_stations year if age==3, connect(direct) symbol(X))
		(scatter mean_pt_stations year if age==4, connect(direct) symbol(O)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"Esperando el transporte público, entre 15 y 24 años"
						2	"Esperando el transporte público, entre 25 y 39 años"
						3	"Esperando el transporte público, entre 40 y 59 años"
						4	"Esperando el transporte público, entre 60 y 79 años"
						5	"Esperando el transporte público, 80 años o más") size(small) r(5));

#delimit cr

graph export "$graphs/Tendencias de sensación de seguridad, Paradero, Tramos de edad, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de sensación de seguridad, Paradero, Tramos de edad, 2016-2021.png", replace
graph export "$graphs/Tendencias de sensación de seguridad, Paradero, Tramos de edad, 2016-2021.eps", replace

restore


*05			Trend of IS Variable, By geographic group & working situation (kish only)
tempname lgc
tempfile is
postfile `lgc' mean_walk_alone mean_house_alone mean_pt_stations year working using `is', replace

* Working Situation
replace working=. if working>2 | Kish==0
replace working=0 if working==2

svy: mean future_victimization , over(year working)
mat table_pais = r(table)

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+1
	post `lgc' (table_walk_alone[1,`column']) (table_house_alone[1,`column']) (table_waiting_pt[1,`column']) (`year') (0)
}  

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+2
	post `lgc' (table_walk_alone[1,`column']) (table_house_alone[1,`column']) (table_waiting_pt[1,`column']) (`year') (1)
}

postclose `lgc'

preserve
use "`is'", clear

*	Trend
#delimit ;

twoway	(scatter mean_walk_alone year if working==1, lpattern(dash) connect(direct)  symbol(Oh) lcolor(navy) mcolor(navy)) 
		(scatter mean_house_alone year if working==1, lpattern(dash) connect(direct) symbol(Th) lcolor(maroon) mcolor(maroon))
		(scatter mean_pt_stations year if working==1, lpattern(dash) connect(direct) symbol(Dh) lcolor(dkgreen) mcolor(dkgreen))
		(scatter mean_walk_alone year if working==0, connect(direct)  symbol(O) lcolor(navy) mcolor(navy)) 
		(scatter mean_house_alone year if working==0, connect(direct) symbol(T) lcolor(maroon) mcolor(maroon))
		(scatter mean_pt_stations year if working==0, connect(direct) symbol(D) lcolor(dkgreen) mcolor(dkgreen)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"Caminando solo/a por su barrio, Trabajó semana pasada"
						2	"Solo/a en su casa, Trabajó semana pasada"
						3	"Esperando el transporte público, Trabajó semana pasada"
						4	"Caminando solo/a por su barrio, No trabajó"
						5	"Solo/a en su casa, No trabajó"
						6	"Esperando el transporte público, No trabajó") r(6));

#delimit cr

graph export "$graphs/Tendencias de sensación de seguridad, Trabajo 2016-2021.pdf", replace
graph export "$graphs/Tendencias de sensación de seguridad, Trabajo 2016-2021.png", replace
graph export "$graphs/Tendencias de sensación de seguridad, Trabajo 2016-2021.eps", replace
restore

