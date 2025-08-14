/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01	DMCS Cead y ENUSC
	Author:		Lucas García
	Date:		December 09, 2022
	Version:	Stata 17

	Summary:	This dofile sets the data as survey data and plots the trends of 
				biggest social connotation crimes from CEAD and from ENUSC.
				
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
	global graphs "$path/05 Graphs"
	global tables "$path/06 Tables"


************************************************
*              1. Preparing data               *
************************************************

*00			Opening DB
import spss "$rawdata/base_interanual_enusc_2008_2021.sav", clear

*01			Defining DB as survey first for households victimizations
svyset idr [pweight=fact_hog_2019_2021], strata(varstrat) singleunit(certainty)

*02			Temporal file
tempname lgc 
tempfile trend
postfile `lgc' robos lesiones hurtos Año using `trend'

*03			Keeping relevant info
*03.1	Robos (rvi rps rfv rdv rddv)
foreach x in rvi rps rfv rdv rddv{
	svy: total `x', over(año)
	mat table_`x'=r(table)
	mat list table_`x'	
}

mat robo = J(1,6,.)

forvalues f = 1/6{
	local c = `f'+8
	di `f'
	di `c'
	mat robo[1,`f'] = table_rvi[1,`c'] + table_rps[1,`c'] + table_rfv[1,`c'] + table_rdv[1,`c'] + table_rddv[1,`c']
}

*03.2	Lesiones (les)
foreach x in les{
	svy: total `x', over(año)
	mat table_`x'=r(table)
	mat list table_`x'	
}

mat lesiones = J(1,6,.)

forvalues f = 1/6{
	local c = `f'+8
	di `f'
	di `c'
	mat lesiones[1,`f'] = table_les[1,`c']
}

*03.2	Hurto (hur)
foreach x in hur{
	svy: total `x', over(año)
	mat table_`x'=r(table)
	mat list table_`x'	
}

mat hurto = J(1,6,.)

forvalues f = 1/6{
	local c = `f'+8
	di `f'
	di `c'
	mat hurto[1,`f'] = table_hur[1,`c']
}

*04 		Now filling temporal file
forvalues x = 1/6{
	local year = `x'+2015
	post `lgc' (robo[1,`x']) (lesiones[1,`x']) (hurto[1,`x']) (`year')
}

postclose `lgc'

*05			Open CEAD Data & merge with temporal file
import excel using "$rawdata/reportesEstadisticos-porDelito, lesiones, hurtos y robos", firstr sh("Hoja2") clear
	
merge 1:1 Año using "`trend'", nogen

*05.1 		Amplifying 2022 (/(3/4))
replace Hurtos=Hurtos*4/3 if Año==2022
replace LesionesAgregado=LesionesAgregado*4/3 if Año==2022
replace RoboAgregado=RoboAgregado*4/3 if Año==2022

*06			Graph
*06.1	ENUSC & CEAD
twoway		///
(scatter Hurtos Año if Año<2022, connect(direct) symbol(circle) lpattern(dash) lcolor(navy) mcolor(navy))	///
(scatter LesionesAgregado Año if Año<2022, connect(direct) symbol(circle) lpattern(dash) lcolor(dkgreen) mcolor(dkgreen))	///
(scatter RoboAgregado Año if Año<2022, connect(direct) symbol(circle) lpattern(dash) lcolor(maroon) mcolor(maroon))	///
(scatter Hurtos Año if Año>2021, symbol(Dh) lpattern(dash) lcolor(navy) mcolor(navy))	///
(scatter LesionesAgregado Año if Año>2021, symbol(Dh) lpattern(dash) lcolor(dkgreen) mcolor(dkgreen))	///
(scatter RoboAgregado Año if Año>2021, symbol(Dh) lpattern(dash) lcolor(maroon) mcolor(maroon))	///
(scatter hurtos Año, connect(direct) symbol(T) lcolor(navy) mcolor(navy))	///
(scatter lesiones Año, connect(direct) symbol(T) lcolor(dkgreen) mcolor(dkgreen))	///
(scatter robos Año, connect(direct) symbol(T) lcolor(maroon) mcolor(maroon))	///
(line Hurtos Año if Año>=2021, lcolor(navy) lpattern(dot))	///
(line LesionesAgregado Año if Año>=2021, lcolor(dkgreen) lpattern(dot))	///
(line RoboAgregado Año if Año>=2021, lcolor(maroon) lpattern(dot)),	///
xline(2021.5, lcolor(gs8) lpattern(dash))	///
graphregion(color(white))	///
ylabel(0(500000)1000000, labsize(small))					///
ytitle("Incidentes")	///
xtitle("")	///
legend(order(1 "Hurtos, CEAD" 2 "Lesiones, CEAD" 3 "Robos, CEAD" 4 "Hurtos CEAD, Proyección 2022" 5 "Lesiones CEAD, Proyección 2022" 6 "Robos CEAD, Proyección 2022"	///
7 "Hurtos, ENUSC" 8 "Lesiones, ENUSC" 9 "Robos, ENUSC") region(lwidth(none)) r(4) size(vsmall) symysize(*0.5) symxsize(*0.75))

gr_edit yaxis1.title.DragBy 0 -2

graph export "$graphs/DMCS Cead vs enusc.pdf", replace
graph export "$graphs/DMCS Cead vs enusc.png", replace
graph export "$graphs/DMCS Cead vs enusc.eps", replace

/*
*06.2 	Only CEAD
twoway		///
(scatter Hurtos Año, connect(direct) symbol(circle) lpattern(dash) lcolor(navy) mcolor(navy))	///
(scatter LesionesAgregado Año, connect(direct) symbol(circle) lpattern(dash) lcolor(dkgreen) mcolor(dkgreen))	///
(scatter RoboAgregado Año, connect(direct) symbol(circle) lpattern(dash) lcolor(maroon) mcolor(maroon)),	///
graphregion(color(white))	///
ytitle("Frecuencia")	///
xtitle("")	///
legend(order(1 "Hurtos, CEAD" 2 "Lesiones, CEAD" 3 "Robos, CEAD") r(3) size(small) symysize(*0.5) symxsize(*0.75))

graph export "$graphs/DMCS Cead.pdf", replace
graph export "$graphs/DMCS Cead.png", replace
graph export "$graphs/DMCS Cead.eps", replace
*/
