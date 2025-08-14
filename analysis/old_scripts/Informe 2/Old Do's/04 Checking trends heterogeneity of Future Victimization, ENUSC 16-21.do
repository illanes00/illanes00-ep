/*******************************************************************************
	Project:	Seguridad Pública EP, Informe 2
	
	Title:		04 Checking trends heterogeneity of Future Victimization, ENUSC 16-21
	Author:		Lucas García
	Date:		February 14, 2023
	Version:	Stata 17

	Summary:	This dofile uses enusc_16_21 from use data to plot the trends 
				of beliefs of future victimization, checking heterogeneity
				by different social variables.
				
				The second section plots the crimes that people believe are going
				to be a victim, conditional on the belief that they will be a victim
				of a crime in the next 12 months.
				
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
*              1. FV TRENDS	       		       *
************************************************

*00			Open DB & defining data as survey
use "$usedata/enusc_16_21", clear

*	Set as survey
svyset enc_idr [pweight=Fact_pers], strata(VarStrat) singleunit(certainty)

*01			Trend of Future victimization Variable, By geographic group
tempname lgc
tempfile fv
postfile `lgc' mean_pais year using `fv', replace

svy: mean future_victimization , over(year)
mat table_pais = r(table)

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_pais[1,`y']) (`year')
}  

postclose `lgc'

preserve
use "`fv'", clear

*	Trend
#delimit ;

twoway	(scatter mean_pais year , connect(direct) msymbol(circle)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1) 
		legend(on lab(1 "¿Cree usted que será víctima de un delito en el futuro?") 
		size(small));

#delimit cr

graph export "$graphs/Tendencias de victimización futura, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de victimización futura, 2016-2021.png", replace
graph export "$graphs/Tendencias de victimización futura, 2016-2021.eps", replace
restore

*02			Trend of FV Variable, By geographic group & sex
tempname lgc
tempfile fv
postfile `lgc' mean_pais year female using `fv', replace

svy: mean future_victimization , over(year rph_sexo)
mat table_pais = r(table)

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+1
	post `lgc' (table_pais[1,`column']) (`year') (1)
}  

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+2
	post `lgc' (table_pais[1,`column']) (`year') (2)
}

postclose `lgc'

preserve
use "`fv'", clear

*	Trend
#delimit ;

twoway	(scatter mean_pais year if female==1, lpattern(dash) connect(direct)  symbol(O) lcolor(navy) mcolor(navy)) 
		(scatter mean_pais year if female==2, connect(direct) symbol(T) lcolor(maroon) mcolor(maroon)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"¿Cree usted que será víctima de un delito en el futuro?, Hombres"
						2	"¿Cree usted que será víctima de un delito en el futuro?, Mujeres") r(2));

#delimit cr

graph export "$graphs/Tendencias de victimización futura, Hombres y mujeres 2016-2021.pdf", replace
graph export "$graphs/Tendencias de victimización futura, Hombres y mujeres 2016-2021.png", replace
graph export "$graphs/Tendencias de victimización futura, Hombres y mujeres 2016-2021.eps", replace
restore


*03			Trend of FV Variable, By geographic group & education level
tempname lgc
tempfile fv
postfile `lgc' mean_pais year educ using `fv', replace

* Education levels
g low = 1 if (rph_nivel==0 | rph_nivel==1 | rph_nivel==2) & Kish==1 & year==2021
replace low = 1 if (rph_nivel<=8 | rph_nivel==90) & year<=2019

g high = 1 if (rph_nivel==3) & Kish==1 & year==2021
replace high = 1 if (rph_nivel>=9 & rph_nivel<=13) & year<=2019
replace high=0 if low==1

svy: mean future_victimization , over(year high)
mat table_pais = r(table)

forvalues y = 0(2)8{
	local year = `y'+2016-`y'/2
	local column = `y'+1
	post `lgc' (table_pais[1,`column'])  (`year') (0)
}  

forvalues y = 0(2)8{
	local year = `y'+2016-`y'/2
	local column = `y'+2
	post `lgc' (table_pais[1,`column'])  (`year') (1)
}

postclose `lgc'

preserve
use "`fv'", clear

replace year=2021 if year==2020

*	Trend
#delimit ;

twoway	(scatter mean_pais year if educ==1, lpattern(dash) connect(direct)  symbol(O) lcolor(navy) mcolor(navy)) 
		(scatter mean_pais year if educ==0, connect(direct) symbol(T) lcolor(maroon) mcolor(maroon)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"¿Cree usted que será víctima de un delito en el futuro?, con educación superior"
						2	"¿Cree usted que será víctima de un delito en el futuro?, sin educación superior") size(small) r(2));

#delimit cr

graph export "$graphs/Tendencias de victimización futura, Educación 2016-2021.pdf", replace
graph export "$graphs/Tendencias de victimización futura, Educación 2016-2021.png", replace
graph export "$graphs/Tendencias de victimización futura, Educación 2016-2021.eps", replace
restore


*04			Trend of FV Variable, By geographic group & age
tempname lgc
tempfile fv
postfile `lgc' mean_pais year age using `fv', replace

* Age ranges
g age_range = 1 if (rph_edad==1 | rph_edad==2) & Kish==1
replace age_range = 2 if (rph_edad==3 | rph_edad==4) & Kish==1
replace age_range = 3 if (rph_edad==5 | rph_edad==6) & Kish==1
replace age_range = 4 if (rph_edad==7 | rph_edad==8) & Kish==1
replace age_range = 5 if (rph_edad==9 | rph_edad==10) & Kish==1

svy: mean future_victimization , over(year age_range)
mat table_pais = r(table)

forvalues x = 1/5{
	forvalues y = 0(5)25{
		local year = `y'/5+2016
		local column = `y'+`x'
		post `lgc' (table_pais[1,`column']) (`year') (`x'-1)
	} 
}

postclose `lgc'

preserve
use "`fv'", clear

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
		legend(order(	1	"¿Cree usted que será víctima de un delito en el futuro?, entre 15 y 24 años"
						2	"¿Cree usted que será víctima de un delito en el futuro?, entre 25 y 39 años"
						3	"¿Cree usted que será víctima de un delito en el futuro?, entre 40 y 59 años"
						4	"¿Cree usted que será víctima de un delito en el futuro?, entre 60 y 79 años"
						5	"¿Cree usted que será víctima de un delito en el futuro?, 80 años o más") size(small) r(5));

#delimit cr

graph export "$graphs/Tendencias de victimización futura, Tramos de edad, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de victimización futura, Tramos de edad, 2016-2021.png", replace
graph export "$graphs/Tendencias de victimización futura, Tramos de edad, 2016-2021.eps", replace

restore


*05			Trend of FV Variable, By geographic group & working situation (kish only)
*	Laboral situation
replace working=. if working>2 | Kish==0
replace working=0 if working==2

tempname lgc
tempfile fv
postfile `lgc' mean_pais year working using `fv', replace

svy: mean future_victimization , over(year working)
mat table_pais = r(table)

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+1
	post `lgc' (table_pais[1,`column']) (`year') (0)
}  

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+2
	post `lgc' (table_pais[1,`column']) (`year') (1)
}

postclose `lgc'

preserve
use "`fv'", clear

*	Trend
#delimit ;

twoway	(scatter mean_pais year if working==1, lpattern(dash) connect(direct)  symbol(O) lcolor(navy) mcolor(navy)) 
		(scatter mean_pais year if working==0, connect(direct) symbol(T) lcolor(maroon) mcolor(maroon)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"¿Cree usted que será víctima de un delito en el futuro?, trabajó semana pasada"
						2	"¿Cree usted que será víctima de un delito en el futuro?, no trabajó") size(small) r(2));

#delimit cr

graph export "$graphs/Tendencias de victimización futura, Trabajo 2016-2021.pdf", replace
graph export "$graphs/Tendencias de victimización futura, Trabajo 2016-2021.png", replace
graph export "$graphs/Tendencias de victimización futura, Trabajo 2016-2021.eps", replace
restore



************************************************
*              2. FV TRENDS, by Crime	       *
************************************************

*00			Preparing Variables to be dummy
local names burglary mvt mvt_fromvehicle larceny robbery theft assault economic threat graffiti vandalism ciber sexual other

foreach x in `names'{
	replace fv_`x' = 0 if fv_`x'==2
	replace fv_`x' = . if fv_`x'>1
}

*01			Trend of Future victimization by crime
tempname lgc
tempfile fv
postfile `lgc' mean_burglary mean_mvt mean_mvt_fromvehicle mean_larceny mean_robbery mean_theft mean_assault mean_economic mean_threat mean_graffiti mean_vandalism mean_ciber mean_sexual mean_other year using `fv', replace

foreach x in `names'{
	svy: mean fv_`x' , over(year)
	mat table_`x' = r(table)
}

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc'	(table_burglary[1,`y'])	(table_mvt[1,`y'])	(table_mvt_fromvehicle[1,`y'])	(table_larceny[1,`y'])	///
				(table_robbery[1,`y'])	(table_theft[1,`y'])	(table_assault[1,`y'])	(table_economic[1,`y'])		///
				(table_threat[1,`y'])	(table_graffiti[1,`y'])	(table_vandalism[1,`y'])	(table_ciber[1,`y'])	///
				(table_sexual[1,`y'])	(table_other[1,`y'])	(`year')
}  

postclose `lgc'

preserve
use "`fv'", clear

*	Trend
#delimit ;

twoway	(scatter mean_burglary year , connect(direct))
		(scatter mean_mvt year , connect(direct))
		(scatter mean_larceny year , connect(direct))
		(scatter mean_robbery year , connect(direct))
		(scatter mean_theft year , connect(direct))
		(line mean_mvt_fromvehicle year , connect(direct))
		(line mean_assault year , connect(direct))
		(line mean_economic year , connect(direct))
		(line mean_threat year , connect(direct))
		(line mean_graffiti year , connect(direct))
		(line mean_vandalism year , connect(direct))
		(line mean_ciber year , connect(direct))
		(line mean_sexual year , connect(direct))
		(line mean_other year , connect(direct)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1) 
		legend(order(	1	"Robo en su vivienda"
						2	"Robo de su vehículo motorizado"
						3	"Robo por sorpresa"
						4	"Robo con violencia o intimidación"
						5	"Hurto"
						6	"Robo desde su vehículo motorizado"
						7	"Lesiones"
						8	"Delito de connotación económica"
						9	"Amenaza"
						10	"Rayones en su vivienda o auto"
						11	"Vandalismo en su vivienda o auto"
						12	"Acoso u otras agresiones sexuales"
						13	"Otro")
		size(tiny) r(6));

#delimit cr

graph export "$graphs/Tendencias de victimización futura por crimen, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de victimización futura por crimen, 2016-2021.png", replace
graph export "$graphs/Tendencias de victimización futura por crimen, 2016-2021.eps", replace
restore


*02			Trend of Future victimization by crime, by gender
tempname lgc
tempfile fv
postfile `lgc' mean_burglary mean_mvt mean_mvt_fromvehicle mean_larceny mean_robbery mean_theft mean_assault mean_economic mean_threat mean_graffiti mean_vandalism mean_ciber mean_sexual mean_other year female using `fv', replace

local names burglary mvt mvt_fromvehicle larceny robbery theft assault economic threat graffiti vandalism ciber sexual other

foreach x in `names'{
	svy: mean fv_`x' , over(year rph_sexo)
	mat table_`x' = r(table)
}


forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+1
	post `lgc'	(table_burglary[1,`column'])	(table_mvt[1,`column'])	(table_mvt_fromvehicle[1,`column'])	(table_larceny[1,`column'])	///
				(table_robbery[1,`column'])	(table_theft[1,`column'])	(table_assault[1,`column'])	(table_economic[1,`column'])		///
				(table_threat[1,`column'])	(table_graffiti[1,`column'])	(table_vandalism[1,`column'])	(table_ciber[1,`column'])	///
				(table_sexual[1,`column'])	(table_other[1,`column'])	(`year')	(1)
} 

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+2
	post `lgc'	(table_burglary[1,`column'])	(table_mvt[1,`column'])	(table_mvt_fromvehicle[1,`column'])	(table_larceny[1,`column'])	///
				(table_robbery[1,`column'])	(table_theft[1,`column'])	(table_assault[1,`column'])	(table_economic[1,`column'])		///
				(table_threat[1,`column'])	(table_graffiti[1,`column'])	(table_vandalism[1,`column'])	(table_ciber[1,`column'])	///
				(table_sexual[1,`column'])	(table_other[1,`column'])	(`year')	(2)
}  

postclose `lgc'

preserve
use "`fv'", clear

*	Trend
*Hombres
#delimit ;

twoway	(scatter mean_burglary year if female==1, connect(direct))
		(scatter mean_mvt year if female==1, connect(direct))
		(scatter mean_larceny year if female==1, connect(direct))
		(scatter mean_robbery year if female==1, connect(direct))
		(scatter mean_theft year if female==1, connect(direct)),
		ytitle("Proporción", size(medsmall)) xtitle("Hombres")
		graphregion(color(white)) ylabel(0(0.2)1) 
		legend(order(	1	"Robo en su vivienda"
						2	"Robo de su vehículo motorizado"
						3	"Robo por sorpresa"
						4	"Robo con violencia o intimidación"
						5	"Hurto")
		size(vsmall) region(c(none))) name(gph_0, replace);

#delimit cr

*Mujeres
#delimit ;

twoway	(scatter mean_burglary year if female==2, connect(direct))
		(scatter mean_mvt year if female==2, connect(direct))
		(scatter mean_larceny year if female==2, connect(direct))
		(scatter mean_robbery year if female==2, connect(direct))
		(scatter mean_theft year if female==2, connect(direct)),
		ytitle("Proporción", size(medsmall)) xtitle("Mujeres")
		graphregion(color(white)) ylabel(0(0.2)1) name(gph_1, replace);

#delimit cr

grc1leg gph_0 gph_1, legendfrom(gph_0) ycommon r(2) graphregion(color(white)) iscale(0.6)

graph export "$graphs/Tendencias de victimización futura por crimen, Hombres y Mujeres, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de victimización futura por crimen, Hombres y Mujeres, 2016-2021.png", replace
graph export "$graphs/Tendencias de victimización futura por crimen, Hombres y Mujeres, 2016-2021.eps", replace
restore


*03			Trend of Future victimization by crime, by education level
tempname lgc
tempfile fv
postfile `lgc' mean_burglary mean_mvt mean_mvt_fromvehicle mean_larceny mean_robbery mean_theft mean_assault mean_economic mean_threat mean_graffiti mean_vandalism mean_ciber mean_sexual mean_other year education using `fv', replace

local names burglary mvt mvt_fromvehicle larceny robbery theft assault economic threat graffiti vandalism ciber sexual other

foreach x in `names'{
	svy: mean fv_`x' , over(year high)
	mat table_`x' = r(table)
}


forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+1
	post `lgc'	(table_burglary[1,`column'])	(table_mvt[1,`column'])	(table_mvt_fromvehicle[1,`column'])	(table_larceny[1,`column'])	///
				(table_robbery[1,`column'])	(table_theft[1,`column'])	(table_assault[1,`column'])	(table_economic[1,`column'])		///
				(table_threat[1,`column'])	(table_graffiti[1,`column'])	(table_vandalism[1,`column'])	(table_ciber[1,`column'])	///
				(table_sexual[1,`column'])	(table_other[1,`column'])	(`year')	(0)
} 

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+2
	post `lgc'	(table_burglary[1,`column'])	(table_mvt[1,`column'])	(table_mvt_fromvehicle[1,`column'])	(table_larceny[1,`column'])	///
				(table_robbery[1,`column'])	(table_theft[1,`column'])	(table_assault[1,`column'])	(table_economic[1,`column'])		///
				(table_threat[1,`column'])	(table_graffiti[1,`column'])	(table_vandalism[1,`column'])	(table_ciber[1,`column'])	///
				(table_sexual[1,`column'])	(table_other[1,`column'])	(`year')	(1)
}  

postclose `lgc'

preserve
use "`fv'", clear

replace year=2021 if year==2020

*	Trend
*Low Education
#delimit ;

twoway	(scatter mean_burglary year if education==0, connect(direct))
		(scatter mean_mvt year if education==0, connect(direct))
		(scatter mean_larceny year if education==0, connect(direct))
		(scatter mean_robbery year if education==0, connect(direct))
		(scatter mean_theft year if education==0, connect(direct)),
		ytitle("Proporción", size(medsmall)) xtitle("Sin educación superior")
		graphregion(color(white)) ylabel(0(0.2)1) xline(2020, lpattern(dot))
		legend(order(	1	"Robo en su vivienda"
						2	"Robo de su vehículo motorizado"
						3	"Robo por sorpresa"
						4	"Robo con violencia o intimidación"
						5	"Hurto")
		size(vsmall) region(c(none))) name(gph_0, replace);

#delimit cr

*High Education
#delimit ;

twoway	(scatter mean_burglary year if education==1, connect(direct))
		(scatter mean_mvt year if education==1, connect(direct))
		(scatter mean_larceny year if education==1, connect(direct))
		(scatter mean_robbery year if education==1, connect(direct))
		(scatter mean_theft year if education==1, connect(direct)),
		ytitle("Proporción", size(medsmall)) xtitle("Con educación superior")
		graphregion(color(white)) ylabel(0(0.2)1) name(gph_1, replace) xline(2020, lpattern(dot));

#delimit cr

grc1leg gph_0 gph_1, legendfrom(gph_0) ycommon r(2) graphregion(color(white)) iscale(0.6)

graph export "$graphs/Tendencias de victimización futura por crimen, Educación, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de victimización futura por crimen, Educación, 2016-2021.png", replace
graph export "$graphs/Tendencias de victimización futura por crimen, Educación, 2016-2021.eps", replace
restore


*04			Trend of Future victimization by crime, by working situation
tempname lgc
tempfile fv
postfile `lgc' mean_burglary mean_mvt mean_mvt_fromvehicle mean_larceny mean_robbery mean_theft mean_assault mean_economic mean_threat mean_graffiti mean_vandalism mean_ciber mean_sexual mean_other year working using `fv', replace

local names burglary mvt mvt_fromvehicle larceny robbery theft assault economic threat graffiti vandalism ciber sexual other

foreach x in `names'{
	svy: mean fv_`x' , over(year working)
	mat table_`x' = r(table)
}


forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+1
	post `lgc'	(table_burglary[1,`column'])	(table_mvt[1,`column'])	(table_mvt_fromvehicle[1,`column'])	(table_larceny[1,`column'])	///
				(table_robbery[1,`column'])	(table_theft[1,`column'])	(table_assault[1,`column'])	(table_economic[1,`column'])		///
				(table_threat[1,`column'])	(table_graffiti[1,`column'])	(table_vandalism[1,`column'])	(table_ciber[1,`column'])	///
				(table_sexual[1,`column'])	(table_other[1,`column'])	(`year')	(0)
} 

forvalues y = 0(2)10{
	local year = `y'+2016-`y'/2
	local column = `y'+2
	post `lgc'	(table_burglary[1,`column'])	(table_mvt[1,`column'])	(table_mvt_fromvehicle[1,`column'])	(table_larceny[1,`column'])	///
				(table_robbery[1,`column'])	(table_theft[1,`column'])	(table_assault[1,`column'])	(table_economic[1,`column'])		///
				(table_threat[1,`column'])	(table_graffiti[1,`column'])	(table_vandalism[1,`column'])	(table_ciber[1,`column'])	///
				(table_sexual[1,`column'])	(table_other[1,`column'])	(`year')	(1)
}  

postclose `lgc'

preserve
use "`fv'", clear

*	Trend
*Didn't work last week
#delimit ;

twoway	(scatter mean_burglary year if working==0, connect(direct))
		(scatter mean_mvt year if working==0, connect(direct))
		(scatter mean_larceny year if working==0, connect(direct))
		(scatter mean_robbery year if working==0, connect(direct))
		(scatter mean_theft year if working==0, connect(direct)),
		ytitle("Proporción", size(medsmall)) xtitle("No trabajó la última semana")
		graphregion(color(white)) ylabel(0(0.2)1) 
		legend(order(	1	"Robo en su vivienda"
						2	"Robo de su vehículo motorizado"
						3	"Robo por sorpresa"
						4	"Robo con violencia o intimidación"
						5	"Hurto")
		size(vsmall) region(c(none))) name(gph_0, replace);

#delimit cr

*Worked last week
#delimit ;

twoway	(scatter mean_burglary year if working==1, connect(direct))
		(scatter mean_mvt year if working==1, connect(direct))
		(scatter mean_larceny year if working==1, connect(direct))
		(scatter mean_robbery year if working==1, connect(direct))
		(scatter mean_theft year if working==1, connect(direct)),
		ytitle("Proporción", size(medsmall)) xtitle("Trabajó la última semana")
		graphregion(color(white)) ylabel(0(0.2)1) name(gph_1, replace);

#delimit cr

grc1leg gph_0 gph_1, legendfrom(gph_0) ycommon r(2) graphregion(color(white)) iscale(0.6)

graph export "$graphs/Tendencias de victimización futura por crimen, Trabajo, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de victimización futura por crimen, Trabajo, 2016-2021.png", replace
graph export "$graphs/Tendencias de victimización futura por crimen, Trabajo, 2016-2021.eps", replace
restore



*05			Trend of Future victimization by crime, by age range
tempname lgc
tempfile fv
postfile `lgc' mean_burglary mean_mvt mean_mvt_fromvehicle mean_larceny mean_robbery mean_theft mean_assault mean_economic mean_threat mean_graffiti mean_vandalism mean_ciber mean_sexual mean_other year age using `fv', replace

local names burglary mvt mvt_fromvehicle larceny robbery theft assault economic threat graffiti vandalism ciber sexual other

foreach x in `names'{
	svy: mean fv_`x' , over(year age)
	mat table_`x' = r(table)
}

forvalues x = 0/4{
	forvalues y = 0(2)10{
		local year = `y'+2016-`y'/2
		local column = `y'+`x'+1
		post `lgc'	(table_burglary[1,`column'])	(table_mvt[1,`column'])	(table_mvt_fromvehicle[1,`column'])	(table_larceny[1,`column'])	///
					(table_robbery[1,`column'])	(table_theft[1,`column'])	(table_assault[1,`column'])	(table_economic[1,`column'])		///
					(table_threat[1,`column'])	(table_graffiti[1,`column'])	(table_vandalism[1,`column'])	(table_ciber[1,`column'])	///
					(table_sexual[1,`column'])	(table_other[1,`column'])	(`year')	(`x')
	} 
}

postclose `lgc'

preserve
use "`fv'", clear

*	Trend
*15 to 24 years old
#delimit ;

twoway	(scatter mean_burglary year if age==0, connect(direct) yaxis(2) msymbol(O))
		(scatter mean_mvt year if age==0, connect(direct) yaxis(2) msymbol(T))
		(scatter mean_larceny year if age==0, connect(direct) yaxis(2) msymbol(D))
		(scatter mean_robbery year if age==0, connect(direct) yaxis(2) msymbol(S))
		(scatter mean_theft year if age==0, connect(direct) yaxis(1) msymbol(X)),
		ytitle("Proporción", size(medsmall) axis(1)) ytitle("Proporción", size(medsmall) axis(2))
		xtitle("15 a 24 años")
		graphregion(color(white)) ylabel(0(0.2)1, axis(1)) ylabel(0(0.2)1, axis(2))
		legend(order(	1	"Robo en su vivienda"
						2	"Robo de su vehículo motorizado"
						3	"Robo por sorpresa"
						4	"Robo con violencia o intimidación"
						5	"Hurto")
		size(tiny) symysize(0.25) symxsize(0.25) r(1) region(c(none))) 
		name(gph_0, replace);

#delimit cr

*25 to 39 years old
#delimit ;

twoway	(scatter mean_burglary year if age==1, connect(direct) yaxis(2) msymbol(O))
		(scatter mean_mvt year if age==1, connect(direct) yaxis(2) msymbol(T))
		(scatter mean_larceny year if age==1, connect(direct) yaxis(2) msymbol(D))
		(scatter mean_robbery year if age==1, connect(direct) yaxis(1) msymbol(S))
		(scatter mean_theft year if age==1, connect(direct) yaxis(1) msymbol(X)),
		ytitle("Proporción", size(medsmall) axis(1)) ytitle("Proporción", size(medsmall) axis(2)) xtitle("25 a 39 años")
		graphregion(color(white)) ylabel(0(0.2)1, axis(1)) ylabel(0(0.2)1, axis(2)) 
		name(gph_1, replace);

#delimit cr

*40 to 59 years old
#delimit ;

twoway	(scatter mean_burglary year if age==2, connect(direct) yaxis(2) msymbol(O))
		(scatter mean_mvt year if age==2, connect(direct) yaxis(2) msymbol(T))
		(scatter mean_larceny year if age==2, connect(direct) yaxis(2) msymbol(D))
		(scatter mean_robbery year if age==2, connect(direct) yaxis(2) msymbol(S))
		(scatter mean_theft year if age==2, connect(direct) yaxis(1) msymbol(X)),
		ytitle("Proporción", size(medsmall) axis(1)) ytitle("Proporción", size(medsmall) axis(2)) xtitle("40 a 59 años")
		graphregion(color(white)) ylabel(0(0.2)1, axis(1)) ylabel(0(0.2)1, axis(2)) 
		name(gph_2, replace);

#delimit cr

*60 to 79 years old
#delimit ;

twoway	(scatter mean_burglary year if age==3, connect(direct) yaxis(2) msymbol(O))
		(scatter mean_mvt year if age==3, connect(direct) yaxis(2) msymbol(T))
		(scatter mean_larceny year if age==3, connect(direct) yaxis(2) msymbol(D))
		(scatter mean_robbery year if age==3, connect(direct) yaxis(2) msymbol(S))
		(scatter mean_theft year if age==3, connect(direct) yaxis(1) msymbol(X)),
		ytitle("Proporción", size(medsmall) axis(1)) ytitle("Proporción", size(medsmall) axis(2)) xtitle("60 a 79 años")
		graphregion(color(white)) ylabel(0(0.2)1, axis(1)) ylabel(0(0.2)1, axis(2)) 
		name(gph_3, replace);

#delimit cr

*80 or more years old
#delimit ;

twoway	(scatter mean_burglary year if age==4, connect(direct) yaxis(2) msymbol(O))
		(scatter mean_mvt year if age==4, connect(direct) yaxis(2) msymbol(T))
		(scatter mean_larceny year if age==4, connect(direct) yaxis(2) msymbol(D))
		(scatter mean_robbery year if age==4, connect(direct) yaxis(2) msymbol(S))
		(scatter mean_theft year if age==4, connect(direct) yaxis(1) msymbol(X)),
		ytitle("Proporción", size(medsmall) axis(1)) ytitle("Proporción", size(medsmall) axis(2)) xtitle("80 años o más")
		graphregion(color(white)) ylabel(0(0.2)1, axis(1)) ylabel(0(0.2)1, axis(2)) 
		name(gph_4, replace);

#delimit cr

grc1leg gph_0 gph_1 gph_2 gph_3 gph_4, legendfrom(gph_0) ycommon r(5) graphregion(color(white)) iscale(0.45)

graph export "$graphs/Tendencias de victimización futura por crimen, Tramos de edad, 2016-2021.pdf", replace
graph export "$graphs/Tendencias de victimización futura por crimen, Tramos de edad, 2016-2021.png", replace
graph export "$graphs/Tendencias de victimización futura por crimen, Tramos de edad, 2016-2021.eps", replace
restore