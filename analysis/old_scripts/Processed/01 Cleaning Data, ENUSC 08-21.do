/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01 Trends Long Term, ENUSC 08-21 
	Author:		Lucas García
	Date:		November 11, 2022
	Version:	Stata 17

	Summary:	This dofile plots the trends of perception of delinquency,
				victimization and revictimization from 2008 to 2021 using the
				interanual ENUSC data base.			
				
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
	global graphs "$path/05 Graphs/Enusc 08 21"
	global tables "$path/06 Tables"
	
************************************************
*              1. Preparing data               *
************************************************

*00			Opening DB
import spss "$rawdata/base_interanual_enusc_2008_2021.sav", clear

*01			Defining DB as survey first for PAD & individual Victimization 
svyset id_unico [pweight=fact_pers_2019_2021], strata(varstrat) singleunit(certainty)


************************************************
* 2. Perception, victimiz and revictimiz       *
************************************************

*00 		Setting the temporal file
tempname lgc 
tempfile trend
postfile `lgc' mean_pad stderr_pad mean_vic_i stderr_vic_i mean_vic_h stderr_vic_h mean_revic stderr_revic year using `trend'

*01			First for PAD & individual Victimization 
*PAD
svy: mean pad, over(año)
mat table_pad=r(table)
mat list table_pad

*Victimization
svy: mean vp_dc, over(año)
mat table_vic_i=r(table)


*02			Now for vict and revict
svyset idr [pweight=fact_hog_2019_2021], strata(varstrat) singleunit(certainty)

*Victimization
svy: mean va_dc , over(año)
mat table_vic_h=r(table)

*Re-Victimization
svy: mean rva_dc , over(año)
mat table_revic=r(table)


*03 		Now filling temporal file
forvalues x = 1/14{
	local year = `x'+2007
	local v = `x'*2
	post `lgc' (table_pad[1,`x']) (table_pad[2,`x']) (table_vic_i[1,`x']) (table_vic_i[2,`x']) (table_vic_h[1,`x']) (table_vic_h[2,`x']) (table_revic[1,`x']) (table_revic[2,`x']) (`year')
}

postclose `lgc'

*04			Graph
preserve
use "`trend'", clear

foreach x in pad vic_i vic_h revic{
	g lbound_`x' = mean_`x'-1.96*stderr_`x'
	g ubound_`x' = mean_`x'+1.96*stderr_`x'
}

*	For all years
#delimit ;

twoway	(scatter mean_pad year , connect(direct) msymbol(circle) yaxis(1)) 
		(scatter mean_vic_i year, connect(direct) msymbol(square) yaxis(1)) 
		(scatter mean_vic_h year, connect(direct) msymbol(T) yaxis(1)) 
		(scatter mean_revic year, connect(direct) msymbol(+) yaxis(2)) if year>=2008, 
		ytitle("Proporción Nacional", size(medsmall) margin(medium) axis(1))
		ytitle("Proporción Hogares víctimas", size(medsmall) margin(medium) axis(2)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1, axis(1)) ylabel(0(0.1)1, axis(2)) xlabel(2007(2)2021)
		legend(order(1 "Percepción de aumento de la delincuencia"
					2	"Victimización personas"		
					3	"Victimización hogares"	
					4	"Revictimización hogares") size(vsmall));

#delimit cr

graph export "$graphs/Tendencias de percepción, victimización y revictimización.pdf", replace
graph export "$graphs/Tendencias de percepción, victimización y revictimización.eps", replace
graph export "$graphs/Tendencias de percepción, victimización y revictimización.jpg", replace

*	2016 and more
#delimit ;

twoway	(scatter mean_pad year if year>2015, connect(direct) msymbol(circle) yaxis(1)) 
		(scatter mean_vic_i year if year>2015, connect(direct) msymbol(S) yaxis(1)) 
		(scatter mean_vic_h year if year>2015, connect(direct) msymbol(T) yaxis(1)) 
		(scatter mean_revic year if year>2015, connect(direct) msymbol(+) yaxis(2)) if year>=2008, 
		ytitle("Proporción Nacional", size(medsmall) margin(medium) axis(1))
		ytitle("Proporción Hogares víctimas", size(medsmall) margin(medium) axis(2)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1, axis(1)) ylabel(0(0.1)1, axis(2))
		legend(order(1 "Percepción de aumento de la delincuencia"
					2	"Victimización personas"		
					3	"Victimización hogares"	
					4	"Revictimización hogares") size(vsmall));

#delimit cr

graph export "$graphs/Tendencias de percepción, victimización y revictimización, 2016 en adelante.pdf", replace
graph export "$graphs/Tendencias de percepción, victimización y revictimización, 2016 en adelante.jpg", replace
graph export "$graphs/Tendencias de percepción, victimización y revictimización, 2016 en adelante.eps", replace


*	2016 and more, Only perception & households victimization at different axis
#delimit ;

twoway	(scatter mean_pad year if year>=2016, connect(direct) yaxis(1) msymbol(circle)) 
		(scatter mean_vic_h year if year>=2016, connect(direct) yaxis(2) msymbol(T)),
		ytitle("Proporción personas que perciben" "aumento de la delincuencia", size(small) margin(medium) axis(1))
		ytitle("Proporción Hogares Víctimas", size(small) margin(medium) axis(2)) xtitle("")
		graphregion(color(white)) 
		legend(order(1	"Percepción Aumento de la delincuencia"		
					2	"Victimización hogares") r(2) size(small));

#delimit cr

graph export "$graphs/Tendencias de percepción y victimización, 2016 en adelante, ejes diferentes.pdf", replace
graph export "$graphs/Tendencias de percepción y victimización, 2016 en adelante, ejes diferentes.png", replace
graph export "$graphs/Tendencias de percepción y victimización, 2016 en adelante, ejes diferentes.eps", replace


*	2018 and more, Only perception & households victimization at different axis
#delimit ;

twoway	(scatter mean_pad year if year>=2018, connect(direct) yaxis(1) msymbol(circle)) 
		(scatter mean_vic_h year if year>=2018, connect(direct) yaxis(2) msymbol(T)),
		ytitle("Proporción personas que perciben" "aumento de la delincuencia", size(small) margin(medium) axis(1))
		ytitle("Proporción Hogares Víctimas", size(small) margin(medium) axis(2)) xtitle("")
		graphregion(color(white)) 
		legend(order(1	"Percepción Aumento de la delincuencia"		
					2	"Victimización hogares") r(2) size(small));

#delimit cr

graph export "$graphs/Tendencias de percepción y victimización, 2018 en adelante, ejes diferentes.pdf", replace
graph export "$graphs/Tendencias de percepción y victimización, 2018 en adelante, ejes diferentes.png", replace
graph export "$graphs/Tendencias de percepción y victimización, 2018 en adelante, ejes diferentes.eps", replace


*	2015 and more, without perception
#delimit ;

twoway	(scatter mean_vic_i year if year>=2015, connect(direct) ) 
		(scatter mean_vic_h year if year>=2015, connect(direct) ) 
		(scatter mean_revic year if year>=2015, connect(direct) ) if year>=2008, 
		ytitle("Proporción", size(medsmall) margin(medium)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(1	"Victimización personas"		
					2	"Victimización hogares"	
					3	"Revictimización hogares") size(small));

#delimit cr

graph export "$graphs/Tendencias de victimización y revictimización, 2015 en adelante.pdf", replace
graph export "$graphs/Tendencias de victimización y revictimización, 2015 en adelante.png", replace

restore


************************************************
* 2. Perception, by groups				       *
************************************************
svyset id_unico [pweight=fact_pers_2019_2021], strata(varstrat) singleunit(certainty)

********				By Gender
*00 		Setting the temporal file
tempname lgc 
tempfile trend_gender
postfile `lgc' mean_pad_hombre stderr_pad_hombre mean_pad_mujer stderr_pad_mujer year using `trend_gender'

*01			First for PAD & individual Victimization 
*PAD
svy: mean pad, over(año sexo)
mat table_pad=r(table)
mat list table_pad

*03 		Now filling temporal file
local k = 1
forvalues x = 1(2)27{
	local year = `k'+2007
	local v = `x'+1
	post `lgc' (table_pad[1,`x']) (table_pad[2,`x']) (table_pad[1,`v']) (table_pad[2,`v']) (`year')
	local ++k
}

postclose `lgc'

*04			Graph
preserve
use "`trend_gender'", clear

foreach x in pad_hombre pad_mujer {
	g lbound_`x' = mean_`x'-1.96*stderr_`x'
	g ubound_`x' = mean_`x'+1.96*stderr_`x'
}

*	For all years
#delimit ;

twoway	(scatter mean_pad_hombre year , connect(direct))  
		(scatter mean_pad_mujer year , connect(direct))  if year>=2008, 
		ytitle("Proporción", size(medsmall) margin(medium)) xtitle("")
		graphregion(color(white)) yscale(r(0 1)) ylabel(0(0.1)1)
		legend(order(1 "Percepción de aumento de la delincuencia, hombres"
					2 "Percepción de aumento de la delincuencia, mujeres") size(small) r(2));

#delimit cr

graph export "$graphs/Tendencias de percepción, por sexo.pdf", replace
graph export "$graphs/Tendencias de percepción, por sexo.png", replace

*	2015 and more
#delimit ;

twoway	(scatter mean_pad_hombre year if year>=2015, connect(direct)) 
		(scatter mean_pad_mujer year if year>=2015, connect(direct)) if year>=2008, 
		ytitle("Proporción", size(medsmall) margin(medium)) xtitle("")
		graphregion(color(white)) yscale(r(0 1)) ylabel(0(0.1)1)
		legend(order(1 "Percepción de aumento de la delincuencia, hombres"
					2 "Percepción de aumento de la delincuencia, mujeres") size(small) r(2));

#delimit cr

graph export "$graphs/Tendencias de percepción, por sexo, 2015 en adelante.pdf", replace
graph export "$graphs/Tendencias de percepción, por sexo, 2015 en adelante.png", replace

restore



********				By Age
*00 		Setting the temporal file and useful variables
tempname lgc 
tempfile trend_age
postfile `lgc' mean_pad_young stderr_pad_young mean_pad_old stderr_pad_old year using `trend_age'

g young=(edad<4)

*01			First for PAD & individual Victimization 
*PAD
svy: mean pad, over(año young)
mat table_pad=r(table)
mat list table_pad

*03 		Now filling temporal file
local k = 1
forvalues x = 1(2)27{
	local year = `k'+2007
	local v = `x'+1
	post `lgc' (table_pad[1,`v']) (table_pad[2,`v']) (table_pad[1,`x']) (table_pad[2,`x']) (`year')
	local ++k
}

postclose `lgc'

*04			Graph
preserve
use "`trend_age'", clear

foreach x in pad_young pad_old {
	g lbound_`x' = mean_`x'-1.96*stderr_`x'
	g ubound_`x' = mean_`x'+1.96*stderr_`x'
}

*	For all years
#delimit ;

twoway	(scatter mean_pad_young year , connect(direct))  
		(scatter mean_pad_old year , connect(direct))  if year>=2008, 
		ytitle("Proporción", size(medsmall) margin(medium)) xtitle("")
		graphregion(color(white)) yscale(r(0 1)) ylabel(0(0.1)1)
		legend(order(1 "Percepción de aumento de la delincuencia, menores de 40"
					2 "Percepción de aumento de la delincuencia, mayores de 40") size(small) r(2));

#delimit cr

graph export "$graphs/Tendencias de percepción, por edad.pdf", replace
graph export "$graphs/Tendencias de percepción, por edad.png", replace

*	2015 and more
#delimit ;

twoway	(scatter mean_pad_young year if year>=2015, connect(direct)) 
		(scatter mean_pad_old year if year>=2015, connect(direct)) if year>=2008, 
		ytitle("Proporción", size(medsmall) margin(medium)) xtitle("")
		graphregion(color(white)) yscale(r(0 1)) ylabel(0(0.1)1)
		legend(order(1 "Percepción de aumento de la delincuencia, menores de 40"
					2 "Percepción de aumento de la delincuencia, mayores de 40") size(small) r(2));

#delimit cr

graph export "$graphs/Tendencias de percepción, por edad, 2015 en adelante.pdf", replace
graph export "$graphs/Tendencias de percepción, por edad, 2015 en adelante.png", replace

restore

