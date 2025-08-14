/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		02 Tendencias de las variables 
	Author:		Lucas García
	Date:		November 17, 2022
	Version:	Stata 17

	Summary:	This dofile sets the data as survey data and plots the trends of 
				different variables: The victimization
				
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
*       1. Defining data as survey      	   *
************************************************

*00		Open Database
use "$usedata/enusc_16_21"


*01		Set as survey
svyset enc_idr [pweight=Fact_pers], strata(VarStrat) singleunit(certainty)

************************************************
*  2. Plotting trends of vict & pad vars	   *
************************************************

*00		Trend of PAD Variable
tempname lgc
tempfile pad
postfile `lgc' mean_pais mean_comuna mean_barrio year using `pad', replace

*By geographic group
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
		(scatter mean_comuna year , connect(direct) msymbol(T)) 
		(scatter mean_barrio year , connect(direct) msymbol(square)) ,
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


*01		Trend of Future Victimization Variable
tempname lgc
tempfile pad
postfile `lgc' mean_future_victim year using `pad', replace

*By geographic group
svy: mean future_victimization, over(year)
mat table_future_victim = r(table)

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_future_victim[1,`y']) (`year')
}  
	
postclose `lgc'

preserve
use "`pad'", clear

*	Trend
#delimit ;

twoway	(scatter mean_future_victim year , connect(direct) msymbol(circle)),
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"Personas que creen que serán víctimas de un delito") size(small) r(3));

#delimit cr

graph export "$graphs/Future Victim, enusc 16-21.pdf", replace
graph export "$graphs/Future Victim, enusc 16-21.png", replace
graph export "$graphs/Future Victim, enusc 16-21.eps", replace
restore

**** By different categories
*00		Trend of PAD Variable
tempname lgc
tempfile pad
postfile `lgc' mean stderr educ year using `pad', replace

*01 Education levels
g low = 1 if (rph_nivel==0 | rph_nivel==1 | rph_nivel==2) & Kish==1 & year==2021
replace low = 1 if (rph_nivel<=8 | rph_nivel==90) & year<=2019
g high = 1 if (rph_nivel==3) & Kish==1 & year==2021
replace high = 1 if (rph_nivel>=9 & rph_nivel<=13) & year<=2019

*Low educ
svy: mean pad if low==1, over(year)
mat table = r(table)
mat list table
forvalues y = 1(1)4{
	local year = `y'+2015
	post `lgc' (table[1,`y']) (table[2,`y']) (0) (`year')
}  

local year = 2021
	post `lgc' (table[1,5]) (table[2,5]) (0) (`year')

*High educ
svy: mean pad if high==1, over(year)
mat table = r(table)

forvalues y = 1(1)4{
	local year = `y'+2015
	post `lgc' (table[1,`y']) (table[2,`y']) (1) (`year')
}  

local year = 2021
	post `lgc' (table[1,5]) (table[2,5]) (1) (`year')

postclose `lgc'

preserve
use "`pad'", clear

gen lbound = mean - 1.96*stderr
gen ubound = mean + 1.96*stderr

*	Trend
#delimit ;

twoway	(scatter mean year if educ==0, connect(direct)) 
		(scatter mean year if educ==1, connect(direct)) , 
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) ylabel(0(0.1)1)
		legend(order(	1	"Percepción de aumento de la delincuencia, sin educación superior"
						2	"Percepción de aumento de la delincuencia, con educación superior") size(small) r(2));

#delimit cr

graph export "$graphs/Tendencias de percepción, educación, 2016 en adelante.pdf", replace
graph export "$graphs/Tendencias de percepción, educación, 2016 en adelante.png", replace
restore


******	With each variable from agg
svyset enc_idr [pweight=Fact_Hog], strata(VarStrat) singleunit(certainty)
*00		Trend of Each Victimization Variable
tempname lgc
tempfile vict
postfile `lgc' mean stderr indicador year using `vict', replace

svy: mean A1 B1 C1 D1 E1 G1 H1, over(year)
mat table = r(table)

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table[1,`y']) (table[2,`y']) (1) (`year')
}  

forvalues y = 7(1)12{
	local year = `y'+2015-6
	post `lgc' (table[1,`y']) (table[2,`y']) (2) (`year')
}  

forvalues y = 13(1)18{
	local year = `y'+2015-12
	post `lgc' (table[1,`y']) (table[2,`y']) (3) (`year')
}  

forvalues y = 19(1)24{
	local year = `y'+2015-18
	post `lgc' (table[1,`y']) (table[2,`y']) (4) (`year')
}  

forvalues y = 25(1)30{
	local year = `y'+2015-24
	post `lgc' (table[1,`y']) (table[2,`y']) (5) (`year')
}  

forvalues y = 31(1)36{
	local year = `y'+2015-30
	post `lgc' (table[1,`y']) (table[2,`y']) (6) (`year')
}  

forvalues y = 37(1)42{
	local year = `y'+2015-36
	post `lgc' (table[1,`y']) (table[2,`y']) (7) (`year')
}  


postclose `lgc'

preserve
use "`vict'", clear
bys indicador year: sum mean

gen lbound = mean - 1.96*stderr
gen ubound = mean + 1.96*stderr

label def delito	1	"Robo con violencia"	///
					2	"Robo con sorpresa"		///
					3	"Robo con fuerza en la vivienda"	///
					4	"Hurto"					///
					5	"Lesiones"				///
					6	"Robo de vehículos"		///
					7	"Robo desde vehículos"
					
label val indicador delito

*	All crimes
#delimit ;

twoway	(scatter mean year if indicador==1, connect(direct) msymbol(D)) 
		(scatter mean year if indicador==2, connect(direct) msymbol(S)) 
		(scatter mean year if indicador==3, connect(direct) msymbol(T)) 
		(scatter mean year if indicador==4, connect(direct) msymbol(+)) 
		(scatter mean year if indicador==5, connect(direct) msymbol(X)) 
		(scatter mean year if indicador==6, connect(direct) msymbol(circle)) 
		(scatter mean year if indicador==7, connect(direct) msymbol(V)), 
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) 
		legend(order(	1	"Robo con violencia"
					2	"Robo con sorpresa"		
					3	"Robo con fuerza en la vivienda"	
					4	"Hurto"					
					5	"Lesiones"				
					6	"Robo de vehículos"		
					7	"Robo desde vehículos"));

#delimit cr

graph export "$graphs/Tendencias de delitos.pdf", replace
graph export "$graphs/Tendencias de delitos.png", replace
graph export "$graphs/Tendencias de delitos.eps", replace



*	Without "Robbery from vehicles" & "Theft"
#delimit ;

twoway	(scatter mean year if indicador==1, connect(direct) msymbol(D)) 
		(scatter mean year if indicador==2, connect(direct) msymbol(S)) 
		(scatter mean year if indicador==3, connect(direct) msymbol(T))  
		(scatter mean year if indicador==5, connect(direct) msymbol(X)) 
		(scatter mean year if indicador==6, connect(direct) msymbol(circle)), 
		ytitle("Proporción", size(medsmall)) xtitle("")
		graphregion(color(white)) 
		legend(order(	1	"Robo con violencia"
					2	"Robo con sorpresa"		
					3	"Robo con fuerza en la vivienda"					
					4	"Lesiones"				
					5	"Robo de vehículos"));

#delimit cr

graph export "$graphs/Tendencias de delitos, sin desde vehículos ni hurto.pdf", replace
graph export "$graphs/Tendencias de delitos, sin desde vehículos ni hurto.eps", replace
graph export "$graphs/Tendencias de delitos, sin desde vehículos ni hurto.png", replace

restore


************************************************
*		3. Reports rate trend over time        *
************************************************
******	Agregate
tempname lgc 
tempfile agg
postfile `lgc' mean stderr year using `agg', replace

svy: mean DEN_AGREG, over(year)
mat table = r(table)

forvalues x = 1/6{
	local year = `x'+2015
	post `lgc' (table[1,`x']) (table[2,`x']) (`year')
}


postclose `lgc'

preserve
import spss "$rawdata/base_interanual_enusc_2008_2021.sav", clear

*-01			Defining DB as survey first for PAD & individual Victimization 
svyset id_unico [pweight=fact_pers_2019_2021], strata(varstrat) singleunit(certainty)

*00 		Setting the temporal file
tempname abc 
tempfile trend
postfile `abc'  mean_vic_h year using `trend'

*02			Now for vict and revict
svyset idr [pweight=fact_hog_2019_2021], strata(varstrat) singleunit(certainty)

*Victimization
svy: mean va_dc , over(año)
mat table=r(table)


*03 		Now filling temporal file
forvalues x = 1/14{
	local year = `x'+2007
	di `year'
	post `abc' (table[1,`x']) (`year')
}

postclose `abc'

use "`trend'", clear

merge 1:1 year using "`agg'", nogen

replace mean= .43 if year==2008
replace mean= .456 if year==2009
replace mean= .437 if year==2010
replace mean= .46 if year==2011
replace mean= .458 if year==2012
replace mean= .439 if year==2013
replace mean= .404 if year==2014
replace mean= .435 if year==2015

gen lbound = mean - 1.96*stderr
gen ubound = mean + 1.96*stderr

g proporcion = mean*mean_vic_h

sort year
label var mean "Hogares que denuncian el delito del que fueron víctimas"

*	All crimes
#delimit ;

twoway	(scatter mean_vic_h year, yaxis(1) connect(direct))
		(line mean year, lpattern(dash) lwidth(thick) lcolor(gs4) yaxis(1)), 
		ytitle("Proporción", size(medsmall) axis(1)) 
		xtitle("")
		graphregion(color(white)) 
		ylabel(0(0.1)0.5, axis(1))	
		xlabel(2007(2)2021)
		legend(order(1 "Hogares víctimas de algún delito" 2 "Hogares victimizados que denuncian") rows(2));

#delimit cr

graph export "$graphs/Tendencias de denuncia de delitos agregada.pdf", replace
graph export "$graphs/Tendencias de denuncia de delitos agregada.png", replace
graph export "$graphs/Tendencias de denuncia de delitos agregada.eps", replace

restore

******	Each crime

*-01 Only for analysis effects, those who answer different from yes or no will be treated as no report
foreach x in denuncio_violencia denuncio_sorpresa denuncio_vivienda denuncio_hurto denuncio_lesiones denuncio_de_vehiculos denuncio_desde_vehiculos{
	replace `x'=0 if `x'>2 & `x'!=.
}

*00		Trend of Each Report Variable
tempname lgc
tempfile report
postfile `lgc' mean stderr indicador year using `report', replace

foreach x in denuncio_violencia denuncio_sorpresa denuncio_vivienda denuncio_hurto denuncio_lesiones denuncio_de_vehiculos denuncio_desde_vehiculos{
	svy: mean `x', over(year)
	mat table_`x' = r(table)
}

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_violencia[1,`y']) (table_denuncio_violencia[2,`y']) (1) (`year')
}  

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_sorpresa[1,`y']) (table_denuncio_sorpresa[2,`y']) (2) (`year')
}  

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_vivienda[1,`y']) (table_denuncio_vivienda[2,`y']) (3) (`year')
}  

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_hurto[1,`y']) (table_denuncio_hurto[2,`y']) (4) (`year')
}  

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_lesiones[1,`y']) (table_denuncio_lesiones[2,`y']) (5) (`year')
}  

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_de_vehiculos[1,`y']) (table_denuncio_de_vehiculos[2,`y']) (6) (`year')
}  

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_desde_vehiculos[1,`y']) (table_denuncio_desde_vehiculos[2,`y']) (7) (`year')
}  


postclose `lgc'

preserve
use "`report'", clear

gen lbound = mean - 1.96*stderr
gen ubound = mean + 1.96*stderr

label def delito	1	"Robo con violencia"	///
					2	"Robo con sorpresa"		///
					3	"Robo con fuerza en la vivienda"	///
					4	"Hurto"					///
					5	"Lesiones"				///
					6	"Robo de vehículos"		///
					7	"Robo desde vehículos"
					
label val indicador delito

*	All crimes
#delimit ;

twoway	(scatter mean year if indicador==1, connect(direct)) 
		(scatter mean year if indicador==2, connect(direct)) 
		(scatter mean year if indicador==3, connect(direct)) 
		(scatter mean year if indicador==4, connect(direct)) 
		(scatter mean year if indicador==5, connect(direct)) 
		(scatter mean year if indicador==6, connect(direct)) 
		(scatter mean year if indicador==7, connect(direct)), 
		ytitle("Promedio", size(medsmall)) xtitle("")
		graphregion(color(white)) 
		legend(order(	1	"Robo con violencia"
					2	"Robo con sorpresa"		
					3	"Robo con fuerza en la vivienda"	
					4	"Hurto"					
					5	"Lesiones"				
					6	"Robo de vehículos"		
					7	"Robo desde vehículos"));

#delimit cr

graph export "$graphs/Tendencias de denuncia de delitos.pdf", replace


*	Without "Stolen car" & year 2020
#delimit ;

twoway	(scatter mean year if indicador==1 & year!=2020, connect(direct)) 
		(scatter mean year if indicador==2 & year!=2020, connect(direct)) 
		(scatter mean year if indicador==3 & year!=2020, connect(direct)) 
		(scatter mean year if indicador==4 & year!=2020, connect(direct)) 
		(scatter mean year if indicador==5 & year!=2020, connect(direct)) 
		(scatter mean year if indicador==7 & year!=2020, connect(direct)), 
		ytitle("Promedio", size(medsmall)) xtitle("")
		graphregion(color(white)) 
		legend(order(	1	"Robo con violencia"
					2	"Robo con sorpresa"		
					3	"Robo con fuerza en la vivienda"	
					4	"Hurto"					
					5	"Lesiones"				
					6	"Robo desde vehículos"));

#delimit cr

graph export "$graphs/Tendencias de denuncia de delitos, sin de veh ni 2020.pdf", replace

restore


******	Agg & each crime together

*00		Trend of Each Report Variable
tempname lgc
tempfile report
postfile `lgc' mean stderr indicador year using `report', replace

foreach x in denuncio_violencia denuncio_sorpresa denuncio_vivienda denuncio_hurto denuncio_lesiones denuncio_de_vehiculos denuncio_desde_vehiculos DEN_AGREG{
	svy: mean `x', over(year)
	mat table_`x' = r(table)
}

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_violencia[1,`y']) (table_denuncio_violencia[2,`y']) (1) (`year')
}  

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_sorpresa[1,`y']) (table_denuncio_sorpresa[2,`y']) (2) (`year')
}  

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_vivienda[1,`y']) (table_denuncio_vivienda[2,`y']) (3) (`year')
}  

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_hurto[1,`y']) (table_denuncio_hurto[2,`y']) (4) (`year')
}  

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_lesiones[1,`y']) (table_denuncio_lesiones[2,`y']) (5) (`year')
}  

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_de_vehiculos[1,`y']) (table_denuncio_de_vehiculos[2,`y']) (6) (`year')
}  

forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_denuncio_desde_vehiculos[1,`y']) (table_denuncio_desde_vehiculos[2,`y']) (7) (`year')
}  


forvalues y = 1(1)6{
	local year = `y'+2015
	post `lgc' (table_DEN_AGREG[1,`y']) (table_DEN_AGREG[2,`y']) (8) (`year')
}  


postclose `lgc'

preserve
use "`report'", clear

gen lbound = mean - 1.96*stderr
gen ubound = mean + 1.96*stderr

label def delito	1	"Robo con violencia"	///
					2	"Robo con sorpresa"		///
					3	"Robo con fuerza en la vivienda"	///
					4	"Hurto"					///
					5	"Lesiones"				///
					6	"Robo de vehículos"		///
					7	"Robo desde vehículos"	///
					8	"Agregado"
					
label val indicador delito

*	All crimes
#delimit ;

twoway	(scatter mean year if indicador==1, connect(direct) msymbol(D)) 
		(scatter mean year if indicador==2, connect(direct) msymbol(S)) 
		(scatter mean year if indicador==3, connect(direct) msymbol(T)) 
		(scatter mean year if indicador==4, connect(direct) msymbol(+)) 
		(scatter mean year if indicador==5, connect(direct) msymbol(X)) 
		(scatter mean year if indicador==6, connect(direct) msymbol(circle)) 
		(scatter mean year if indicador==7, connect(direct) msymbol(V))
		(line mean year if indicador==8, lpattern(dash) lwidth(thick) lcolor(gs4)), 
		ytitle("Proporción", size(medsmall)) xtitle("") ylabel(0(0.1)1)
		graphregion(color(white)) 
		legend(order(	1	"Robo con violencia"
					2	"Robo con sorpresa"		
					3	"Robo con fuerza en la vivienda"	
					4	"Hurto"					
					5	"Lesiones"				
					6	"Robo de vehículos"		
					7	"Robo desde vehículos"
					8	"Agregado"));

#delimit cr

graph export "$graphs/Tendencias de denuncia de delitos, por separado y agg.pdf", replace
graph export "$graphs/Tendencias de denuncia de delitos, por separado y agg.png", replace


*	Without "Stolen car" & year 2020
#delimit ;

twoway	(scatter mean year if indicador==1 & year!=2020, connect(direct)) 
		(scatter mean year if indicador==2 & year!=2020, connect(direct)) 
		(scatter mean year if indicador==3 & year!=2020, connect(direct)) 
		(scatter mean year if indicador==4 & year!=2020, connect(direct)) 
		(scatter mean year if indicador==5 & year!=2020, connect(direct)) 
		(scatter mean year if indicador==7 & year!=2020, connect(direct))
		(connected mean year if indicador==8 & year!=2020, lpattern(dash) lwidth(thick) lcolor(gs4) mcolor(gs4)), 
		ytitle("Proporción", size(medsmall)) xtitle("") ylabel(0(0.1)1)
		graphregion(color(white)) 
		legend(order(	1	"Robo con violencia"
					2	"Robo con sorpresa"		
					3	"Robo con fuerza en la vivienda"	
					4	"Hurto"					
					5	"Lesiones"				
					6	"Robo desde vehículos"
					7	"Agregado"));

#delimit cr

graph export "$graphs/Tendencias de denuncia de delitos, sin de veh ni 2020, con agg.pdf", replace
graph export "$graphs/Tendencias de denuncia de delitos, sin de veh ni 2020, con agg.png", replace

restore




************************************************
*  4. Bar graph trend of how households report *
************************************************

*-01	Value label
label def como 	1	"Solo se dio aviso por teléfono a Carabineros/PDI"	///
				2	"Personalmente a Carabineros"						///
				3	"Personalmente a la Policía de Investigaciones"		///
				4	"Personalmente en Tribunales"						///
				5	"Personalmente en la Fiscalía (Ministerio Público)"

*00		How report violent crimes
tempname lgc
tempfile how_report_violence
postfile `lgc' prop category year using `how_report_violence', replace

forvalues x = 2016(1)2021{
	svy: tab como_denuncio_violencia if year==`x', nolabel
	mat table_`x' = e(Prop)
	mat list table_`x'
}

forvalues v = 1/5{
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

forvalues v = 1/3{
	post `lgc' (table_2017[`v',1]) (`v') (2017)
}

forvalues v = 1/3{
	post `lgc' (table_2018[`v',1]) (`v') (2018)
}

post `lgc' (table_2018[4,1]) (5) (2018)

forvalues v = 1/3{
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

post `lgc' (table_2019[4,1]) (5) (2019)

forvalues v = 1/5{
	post `lgc' (table_2020[`v',1]) (`v') (2020)
}

forvalues v = 1/3{
	post `lgc' (table_2021[`v',1]) (`v') (2021)
}

post `lgc' (table_2021[4,1]) (5) (2021)

postclose `lgc'

preserve
use "`how_report_violence'", clear

label val category como

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))		///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==5, by(year) bcolor(gold) barwidth(0.75)),	///
	 ytitle("Proporción") xtitle("") xlabel(none) note("") ///
	legend(order(	1	"Por teléfono a Carabineros/PDI"		///
					2	"Personalmente a Carabineros"			///
					3	"Personalmente a la Policía de Investigaciones"		///
					4	"Personalmente en Tribunales"						///
					5	"Personalmente en la Fiscalía (Ministerio Público)") size(vsmall))

graph export "$graphs/Como denuncia, violencia e intimidación.pdf", replace
restore


*01		How report Surprise robbery
tempname lgc
tempfile how_report_surprise
postfile `lgc' prop category year using `how_report_surprise', replace

forvalues x = 2016(1)2021{
	svy: tab como_denuncio_sorpresa if year==`x', nolabel
	*mat list table_`x'
	mat table_`x' = e(Prop)
}

forvalues v = 1/3{
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

forvalues v = 1/3{
	post `lgc' (table_2017[`v',1]) (`v') (2017)
}

post `lgc' (table_2017[4,1]) (5) (2017)

forvalues v = 1/3{
	post `lgc' (table_2018[`v',1]) (`v') (2018)
}

post `lgc' (table_2018[4,1]) (5) (2018)

forvalues v = 1/3{
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

post `lgc' (table_2019[4,1]) (5) (2019)

forvalues v = 1/3{
	post `lgc' (table_2020[`v',1]) (`v') (2020)
}

post `lgc' (table_2020[4,1]) (5) (2020)

forvalues v = 1/3{
	post `lgc' (table_2021[`v',1]) (`v') (2021)
}

post `lgc' (table_2021[4,1]) (5) (2021)

postclose `lgc'

preserve
use "`how_report_surprise'", clear

label val category como

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))	///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==5, by(year) bcolor(gold) barwidth(0.75)),	///
	 ytitle("Proporción") xtitle("") xlabel(none)	note("") ///
	legend(order(	1	"Por teléfono a Carabineros/PDI"		///
						2	"Personalmente a Carabineros"			///
						3	"Personalmente a la Policía de Investigaciones"		///
						5	"Personalmente en la Fiscalía (Ministerio Público)") size(vsmall))

graph export "$graphs/Como denuncia, sorpresa en las personas.pdf", replace
restore


*02		How report House robbery
tempname lgc
tempfile how_report_house
postfile `lgc' prop category year using `how_report_house', replace

forvalues x = 2016(1)2021{
	svy: tab como_denuncio_vivienda if year==`x', nolabel
	*mat list table_`x'
	mat table_`x' = e(Prop)
}

forvalues v = 1/5{
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

forvalues v = 1/5{
	post `lgc' (table_2017[`v',1]) (`v') (2017)
}

forvalues v = 1/3{
	post `lgc' (table_2018[`v',1]) (`v') (2018)
}

forvalues v = 1/5{
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

forvalues v = 1/5{
	post `lgc' (table_2020[`v',1]) (`v') (2020)
}

forvalues v = 1/5{
	post `lgc' (table_2021[`v',1]) (`v') (2021)
}

postclose `lgc'

preserve
use "`how_report_house'", clear

label val category como

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))	///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==5, by(year) bcolor(gold) barwidth(0.75)),	///
	 ytitle("Proporción") xtitle("") xlabel(none)	note("") ///
	legend(order(	1	"Por teléfono a Carabineros/PDI"		///
					2	"Personalmente a Carabineros"			///
					3	"Personalmente a la Policía de Investigaciones"		///
					4	"Personalmente en Tribunales"						///
					5	"Personalmente en la Fiscalía (Ministerio Público)") size(vsmall))

graph export "$graphs/Como denuncia, fuerza en la vivienda.pdf", replace
restore


*03		How report Theft
tempname lgc
tempfile how_report_theft
postfile `lgc' prop category year using `how_report_theft', replace

forvalues x = 2016(1)2021{
	svy: tab como_denuncio_hurto if year==`x', nolabel
	*mat list table_`x'
	mat table_`x' = e(Prop)
}

forvalues v = 1/3{
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

forvalues v = 1/3{
	post `lgc' (table_2017[`v',1]) (`v') (2017)
}

post `lgc' (table_2017[4,1]) (5) (2017)

forvalues v = 1/3{
	post `lgc' (table_2018[`v',1]) (`v') (2018)
}

post `lgc' (table_2018[4,1]) (5) (2018)

forvalues v = 1/4{
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

forvalues v = 1/3{
	post `lgc' (table_2020[`v',1]) (`v') (2020)
}

post `lgc' (table_2020[4,1]) (5) (2020)

forvalues v = 1/3{
	post `lgc' (table_2021[`v',1]) (`v') (2021)
}

post `lgc' (table_2021[4,1]) (5) (2021)

postclose `lgc'

preserve
use "`how_report_theft'", clear

label val category como

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))	///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==5, by(year) bcolor(gold) barwidth(0.7)),	///
	 ytitle("Proporción") xtitle("") xlabel(none)	note("") ///
	legend(order(	1	"Por teléfono a Carabineros/PDI"		///
					2	"Personalmente a Carabineros"			///
					3	"Personalmente a la Policía de Investigaciones"		///
					4	"Personalmente en Tribunales"						///
					5	"Personalmente en la Fiscalía (Ministerio Público)") size(vsmall))

graph export "$graphs/Como denuncia, hurto.pdf", replace
restore


*04		How report Injury
tempname lgc
tempfile how_report_injury
postfile `lgc' prop category year using `how_report_injury', replace

forvalues x = 2016(1)2021{
	svy: tab como_denuncio_lesiones if year==`x', nolabel
	*mat list table_`x'
	mat table_`x' = e(Prop)
}

forvalues v = 1/5{
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

forvalues v = 1/5{
	post `lgc' (table_2017[`v',1]) (`v') (2017)
}

forvalues v = 1/5{
	post `lgc' (table_2018[`v',1]) (`v') (2018)
}

forvalues v = 1/5{
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

forvalues v = 1/3{
	post `lgc' (table_2020[`v',1]) (`v') (2020)
}

post `lgc' (table_2020[4,1]) (5) (2020)

forvalues v = 1/3{
	post `lgc' (table_2021[`v',1]) (`v') (2021)
}

post `lgc' (table_2021[4,1]) (5) (2021)

postclose `lgc'

preserve
use "`how_report_injury'", clear

label val category como

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))	///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==5, by(year) bcolor(gold) barwidth(0.75)),	///
	 ytitle("Proporción") xtitle("") xlabel(none)	note("") ///
	legend(order(	1	"Por teléfono a Carabineros/PDI"		///
					2	"Personalmente a Carabineros"			///
					3	"Personalmente a la Policía de Investigaciones"		///
					4	"Personalmente en Tribunales"						///
					5	"Personalmente en la Fiscalía (Ministerio Público)") size(vsmall))

graph export "$graphs/Como denuncia, lesiones.pdf", replace
restore


*05		How report stolen vehicle
tempname lgc
tempfile how_report_stolen_vehicle
postfile `lgc' prop category year using `how_report_stolen_vehicle', replace

forvalues x = 2016(1)2021{
	svy: tab como_denuncio_de_vehiculos if year==`x', nolabel
	*mat list table_`x'
	mat table_`x' = e(Prop)
}

forvalues v = 1/3{
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

forvalues v = 1/3{
	post `lgc' (table_2017[`v',1]) (`v') (2017)
}

post `lgc' (table_2017[4,1]) (5) (2017)

forvalues v = 1/3{
	post `lgc' (table_2018[`v',1]) (`v') (2018)
}

forvalues v = 1/3{
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

post `lgc' (table_2019[4,1]) (5) (2019)

forvalues v = 1/3{
	post `lgc' (table_2020[`v',1]) (`v') (2020)
}

forvalues v = 1/3{
	post `lgc' (table_2021[`v',1]) (`v') (2021)
}

post `lgc' (table_2021[4,1]) (5) (2021)

postclose `lgc'

preserve
use "`how_report_stolen_vehicle'", clear

label val category como

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))	///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==5, by(year) bcolor(gold) barwidth(0.75)),	///
	 ytitle("Proporción") xtitle("") xlabel(none)	note("") ///
	legend(order(	1	"Por teléfono a Carabineros/PDI"		///
					2	"Personalmente a Carabineros"			///
					3	"Personalmente a la Policía de Investigaciones"		///
					4	"Personalmente en Tribunales"						///
					5	"Personalmente en la Fiscalía (Ministerio Público)") size(vsmall))

graph export "$graphs/Como denuncia, robo de vehículos.pdf", replace
restore


*05		How report robbery from vehicle
tempname lgc
tempfile how_report_robbery_from_vehicle
postfile `lgc' prop category year using `how_report_robbery_from_vehicle', replace

forvalues x = 2016(1)2021{
	svy: tab como_denuncio_desde_vehiculos if year==`x', nolabel
	*mat list table_`x'
	mat table_`x' = e(Prop)
}

forvalues v = 1/3{
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

post `lgc' (table_2016[4,1]) (5) (2016)

forvalues v = 1/3{
	post `lgc' (table_2017[`v',1]) (`v') (2017)
}

post `lgc' (table_2017[4,1]) (5) (2017)

forvalues v = 1/3{
	post `lgc' (table_2018[`v',1]) (`v') (2018)
}

forvalues v = 1/3{
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

forvalues v = 1/3{
	post `lgc' (table_2020[`v',1]) (`v') (2020)
}

post `lgc' (table_2020[4,1]) (5) (2020)

forvalues v = 1/3{
	post `lgc' (table_2021[`v',1]) (`v') (2021)
}

post `lgc' (table_2021[4,1]) (5) (2021)

postclose `lgc'

preserve
use "`how_report_robbery_from_vehicle'", clear

label val category como

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))	///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==5, by(year) bcolor(gold) barwidth(0.75)),	///
	 ytitle("Proporción") xtitle("") xlabel(none)	note("") ///
	legend(order(	1	"Por teléfono a Carabineros/PDI"		///
					2	"Personalmente a Carabineros"			///
					3	"Personalmente a la Policía de Investigaciones"		///
					4	"Personalmente en Tribunales"						///
					5	"Personalmente en la Fiscalía (Ministerio Público)") size(vsmall))

graph export "$graphs/Como denuncia, robo desde vehículos.pdf", replace
restore


************************************************
*4. Graph trend of why households don't report *
************************************************

*-01	Value label:	labels42 for all but injury, which has labels45

*00		Why don't report violent crimes
tempname lgc
tempfile why_not_report_violence
postfile `lgc' prop category year using `why_not_report_violence', replace

forvalues x = 2016(1)2021{
	svy: tab porque_no_denuncio_violencia if year==`x', nolabel
	mat table_`x' = e(Prop)
	*mat list table_`x'
}

forvalues v = 1/11{
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

forvalues v = 13/15{
	local x=`v'-1
	post `lgc' (table_2016[`x',1]) (`v') (2016)
}

post `lgc' (table_2016[15,1]) (77) (2016)

forvalues v = 1/4{
	post `lgc' (table_2017[`v',1]) (`v') (2017)
}

forvalues v = 6/11{
	local x=`v'-1
	post `lgc' (table_2017[`x',1]) (`v') (2017)
}

forvalues v = 13/15{
	local x=`v'-2
	post `lgc' (table_2017[`x',1]) (`v') (2017)
}

post `lgc' (table_2017[14,1]) (77) (2017)

forvalues v = 1/4{
	post `lgc' (table_2018[`v',1]) (`v') (2018)
}

forvalues v = 6/11{
	local x=`v'-1
	post `lgc' (table_2018[`x',1]) (`v') (2018)
}

forvalues v = 13/15{
	local x=`v'-2
	post `lgc' (table_2018[`x',1]) (`v') (2018)
}

post `lgc' (table_2018[14,1]) (77) (2018)

forvalues v = 1/4{
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

forvalues v = 6/11{
	local x=`v'-1
	post `lgc' (table_2019[`x',1]) (`v') (2019)
}

forvalues v = 13/15{
	local x=`v'-2
	post `lgc' (table_2019[`x',1]) (`v') (2019)
}

post `lgc' (table_2019[14,1]) (77) (2019)

forvalues v = 1/4{
	post `lgc' (table_2020[`v',1]) (`v') (2020)
}

forvalues v = 6/11{
	local x=`v'-1
	post `lgc' (table_2020[`x',1]) (`v') (2020)
}

post `lgc' (table_2020[11,1]) (13) (2020)

post `lgc' (table_2020[12,1]) (15) (2020)

post `lgc' (table_2020[13,1]) (77) (2020)

forvalues v = 1/4{
	post `lgc' (table_2021[`v',1]) (`v') (2021)
}

forvalues v = 6/11{
	local x=`v'-1
	post `lgc' (table_2021[`x',1]) (`v') (2021)
}

post `lgc' (table_2021[11,1]) (15) (2021)

post `lgc' (table_2021[12,1]) (77) (2021)

postclose `lgc'

preserve
use "`why_not_report_violence'", clear

label val category labels42

replace category=16 if category==77

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))		///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==5, by(year) bcolor(gold) barwidth(0.75))	///
	(bar prop category if category==6, by(year) bcolor(erose) barwidth(0.75))	///
	(bar prop category if category==7, by(year) bcolor(forest_green) barwidth(0.75))	///
	(bar prop category if category==8, by(year) bcolor(khaki) barwidth(0.75))	///
	(bar prop category if category==9, by(year) bcolor(gray) barwidth(0.75))	///
	(bar prop category if category==10, by(year) bcolor(cyan) barwidth(0.75))	///
	(bar prop category if category==11, by(year) bcolor(blue) barwidth(0.75))	///
	(bar prop category if category==12, by(year) bcolor(olive) barwidth(0.75))	///
	(bar prop category if category==13, by(year) bcolor(gs3) barwidth(0.75))	///
	(bar prop category if category==14, by(year) bcolor(mint) barwidth(0.75))	///
	(bar prop category if category==15, by(year) bcolor(sandb) barwidth(0.75))	///
	(bar prop category if category==16, by(year) bcolor(midgreen) barwidth(0.75))	///
	, ytitle("Proporción", size(small)) xtitle("") xlabel(none) note("") ///
	legend(order(	1	"Pérdida no suficientemente seria"	///
					2	"El problema se solucionó"			///
					3	"No tenía testigos"					///
					4	"Temor a amenazas/represalias"		///
					5	"No tenía seguro"					///
					6	"Conoce a los responsables"			///
					7	"Temor a encarar a los responsables en juicio"	///
					8	"Policía no podría haber hecho nada"			///
					9	"Responsables lo amenazaron"		///
					10	"Justicia (tribunales) no hubiera hecho nada"	///
					11	"Trámite demanda mucho tiempo"		///
					12	"Tiene parentesco con los responsables"			///
					13	"Policía no era necesaria"			///
					14	"Policía no hubiera hecho nada"		///
					15	"Policía recomendó no registrar la denuncia" ///
					16	"Otro") ///
					region(c(none)) size(vsmall) symysize(0.05cm) symxsize(0.15cm))

graph export "$graphs/Por qué no denuncia, violencia e intimidación.pdf", replace
restore


*01		Why don't report Surprise robbery
tempname lgc
tempfile why_not_report_surprise
postfile `lgc' prop category year using `why_not_report_surprise', replace

forvalues x = 2016(1)2021{
	svy: tab porque_no_denuncio_sorpresa if year==`x', nolabel
	mat table_`x' = e(Prop)
	*mat list table_`x'
}

forvalues v = 1/4{
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

forvalues v = 6/8{
	local x = `v'-1
	post `lgc' (table_2016[`x',1]) (`v') (2016)
}

forvalues v = 10/11{
	local x=`v'-2
	post `lgc' (table_2016[`x',1]) (`v') (2016)
}

forvalues v = 13/15{
	local x=`v'-3
	post `lgc' (table_2016[`x',1]) (`v') (2016)
}

post `lgc' (table_2016[13,1]) (77) (2016)

forvalues v = 1/11{
	post `lgc' (table_2017[`v',1]) (`v') (2017)
}

forvalues v = 13/15{
	local x=`v'-1
	post `lgc' (table_2017[`x',1]) (`v') (2017)
}

post `lgc' (table_2017[15,1]) (77) (2017)

forvalues v = 1/11{
	post `lgc' (table_2018[`v',1]) (`v') (2018)
}

forvalues v = 13/15{
	local x=`v'-1
	post `lgc' (table_2018[`x',1]) (`v') (2018)
}

post `lgc' (table_2018[15,1]) (77) (2018)

forvalues v = 1/8{
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

forvalues v = 10/15{
	local x=`v'-1
	post `lgc' (table_2019[`x',1]) (`v') (2019)
}

post `lgc' (table_2019[15,1]) (77) (2019)

forvalues v = 1/8{
	post `lgc' (table_2020[`v',1]) (`v') (2020)
}

forvalues v = 10/11{
	local x=`v'-1
	post `lgc' (table_2020[`x',1]) (`v') (2020)
}

post `lgc' (table_2020[11,1]) (13) (2020)

post `lgc' (table_2020[12,1]) (15) (2020)

post `lgc' (table_2020[13,1]) (77) (2020)

forvalues v = 1/4{
	post `lgc' (table_2021[`v',1]) (`v') (2021)
}

forvalues v = 6/8{
	local x=`v'-1
	post `lgc' (table_2021[`x',1]) (`v') (2021)
}

forvalues v = 10/11{
	local x=`v'-2
	post `lgc' (table_2021[`x',1]) (`v') (2021)
}

post `lgc' (table_2021[10,1]) (13) (2021)

post `lgc' (table_2021[11,1]) (15) (2021)

post `lgc' (table_2021[12,1]) (77) (2021)

postclose `lgc'

preserve
use "`why_not_report_surprise'", clear

label val category labels42

replace category=16 if category==77

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))		///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==5, by(year) bcolor(gold) barwidth(0.75))	///
	(bar prop category if category==6, by(year) bcolor(erose) barwidth(0.75))	///
	(bar prop category if category==7, by(year) bcolor(forest_green) barwidth(0.75))	///
	(bar prop category if category==8, by(year) bcolor(khaki) barwidth(0.75))	///
	(bar prop category if category==9, by(year) bcolor(gray) barwidth(0.75))	///
	(bar prop category if category==10, by(year) bcolor(cyan) barwidth(0.75))	///
	(bar prop category if category==11, by(year) bcolor(blue) barwidth(0.75))	///
	(bar prop category if category==12, by(year) bcolor(olive) barwidth(0.75))	///
	(bar prop category if category==13, by(year) bcolor(gs3) barwidth(0.75))	///
	(bar prop category if category==14, by(year) bcolor(mint) barwidth(0.75))	///
	(bar prop category if category==15, by(year) bcolor(sandb) barwidth(0.75))	///
	(bar prop category if category==16, by(year) bcolor(midgreen) barwidth(0.75))	///
	, ytitle("Proporción", size(small)) xtitle("") xlabel(none) note("") ///
	legend(order(	1	"Pérdida no suficientemente seria"	///
					2	"El problema se solucionó"			///
					3	"No tenía testigos"					///
					4	"Temor a amenazas/represalias"		///
					5	"No tenía seguro"					///
					6	"Conoce a los responsables"			///
					7	"Temor a encarar a los responsables en juicio"	///
					8	"Policía no podría haber hecho nada"			///
					9	"Responsables lo amenazaron"		///
					10	"Justicia (tribunales) no hubiera hecho nada"	///
					11	"Trámite demanda mucho tiempo"		///
					12	"Tiene parentesco con los responsables"			///
					13	"Policía no era necesaria"			///
					14	"Policía no hubiera hecho nada"		///
					15	"Policía recomendó no registrar la denuncia" ///
					16	"Otro") ///
					region(c(none)) size(vsmall) symysize(0.05cm) symxsize(0.15cm))

graph export "$graphs/Por qué no denuncia, sorpresa en las personas.pdf", replace
restore


*02		Why don't report House robbery
tempname lgc
tempfile why_not_report_house
postfile `lgc' prop category year using `why_not_report_house', replace

forvalues x = 2016(1)2021{
	svy: tab porque_no_denuncio_vivienda if year==`x', nolabel
	mat table_`x' = e(Prop)
	*mat list table_`x'
}

forvalues v = 1/15{
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

post `lgc' (table_2016[16,1]) (77) (2016)

forvalues v = 1/15{
	post `lgc' (table_2017[`v',1]) (`v') (2017)
}

post `lgc' (table_2017[16,1]) (77) (2017)

forvalues v = 1/8{
	post `lgc' (table_2018[`v',1]) (`v') (2018)
}

forvalues v = 10/15{
	local x=`v'-1
	post `lgc' (table_2018[`x',1]) (`v') (2018)
}

post `lgc' (table_2018[15,1]) (77) (2018)

forvalues v = 1/4{
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

forvalues v = 6/15{
	local x=`v'-1
	post `lgc' (table_2019[`x',1]) (`v') (2019)
}

post `lgc' (table_2019[15,1]) (77) (2019)

post `lgc' (table_2020[1,1]) (1) (2020)

forvalues v = 3/4{
	local x = `v'-1
	post `lgc' (table_2020[`x',1]) (`v') (2020)
}

post `lgc' (table_2020[4,1]) (6) (2020)

post `lgc' (table_2020[5,1]) (8) (2020)

post `lgc' (table_2020[6,1]) (10) (2020)

forvalues v = 11/13{
	local x=`v'-4
	post `lgc' (table_2020[`x',1]) (`v') (2020)
}

post `lgc' (table_2020[10,1]) (15) (2020)

post `lgc' (table_2020[11,1]) (77) (2020)

forvalues v = 1/6{
	post `lgc' (table_2021[`v',1]) (`v') (2021)
}

forvalues v = 8/13{
	local x=`v'-1
	post `lgc' (table_2021[`x',1]) (`v') (2021)
}

post `lgc' (table_2021[13,1]) (15) (2021)

post `lgc' (table_2021[14,1]) (77) (2021)

postclose `lgc'

preserve
use "`why_not_report_house'", clear

label val category labels42

replace category=16 if category==77

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))		///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==5, by(year) bcolor(gold) barwidth(0.75))	///
	(bar prop category if category==6, by(year) bcolor(erose) barwidth(0.75))	///
	(bar prop category if category==7, by(year) bcolor(forest_green) barwidth(0.75))	///
	(bar prop category if category==8, by(year) bcolor(khaki) barwidth(0.75))	///
	(bar prop category if category==9, by(year) bcolor(gray) barwidth(0.75))	///
	(bar prop category if category==10, by(year) bcolor(cyan) barwidth(0.75))	///
	(bar prop category if category==11, by(year) bcolor(blue) barwidth(0.75))	///
	(bar prop category if category==12, by(year) bcolor(olive) barwidth(0.75))	///
	(bar prop category if category==13, by(year) bcolor(gs3) barwidth(0.75))	///
	(bar prop category if category==14, by(year) bcolor(mint) barwidth(0.75))	///
	(bar prop category if category==15, by(year) bcolor(sandb) barwidth(0.75))	///
	(bar prop category if category==16, by(year) bcolor(midgreen) barwidth(0.75))	///
	, ytitle("Proporción", size(small)) xtitle("") xlabel(none) note("") ///
	legend(order(	1	"Pérdida no suficientemente seria"	///
					2	"El problema se solucionó"			///
					3	"No tenía testigos"					///
					4	"Temor a amenazas/represalias"		///
					5	"No tenía seguro"					///
					6	"Conoce a los responsables"			///
					7	"Temor a encarar a los responsables en juicio"	///
					8	"Policía no podría haber hecho nada"			///
					9	"Responsables lo amenazaron"		///
					10	"Justicia (tribunales) no hubiera hecho nada"	///
					11	"Trámite demanda mucho tiempo"		///
					12	"Tiene parentesco con los responsables"			///
					13	"Policía no era necesaria"			///
					14	"Policía no hubiera hecho nada"		///
					15	"Policía recomendó no registrar la denuncia" ///
					16	"Otro") ///
					region(c(none)) size(vsmall) symysize(0.05cm) symxsize(0.15cm))

graph export "$graphs/Por qué no denuncia, Robo con fuerza en la vivienda.pdf", replace
restore


*03		Why don't report Theft
tempname lgc
tempfile why_not_report_theft
postfile `lgc' prop category year using `why_not_report_theft', replace

forvalues x = 2016(1)2021{
	svy: tab porque_no_denuncio_hurto if year==`x', nolabel
	mat table_`x' = e(Prop)
	*mat list table_`x'
}

forvalues v = 1/15{
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

post `lgc' (table_2016[16,1]) (16) (2016)

forvalues v = 1/8{
	post `lgc' (table_2017[`v',1]) (`v') (2017)
}

forvalues v = 10/15{
	local x = `v'-1
	post `lgc' (table_2017[`x',1]) (`v') (2017)
}

post `lgc' (table_2017[15,1]) (16) (2017)

forvalues v = 1/15{
	post `lgc' (table_2018[`v',1]) (`v') (2018)
}

post `lgc' (table_2018[16,1]) (16) (2018)

forvalues v = 1/15{
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

post `lgc' (table_2019[16,1]) (16) (2019)

forvalues v = 1/6{
	post `lgc' (table_2020[`v',1]) (`v') (2020)
}

post `lgc' (table_2020[7,1]) (8) (2020)

forvalues v = 10/13{
	local x = `v'-2
	post `lgc' (table_2020[`x',1]) (`v') (2020)
}

post `lgc' (table_2020[12,1]) (15) (2020)

post `lgc' (table_2020[13,1]) (16) (2020)

forvalues v = 1/4{
	post `lgc' (table_2021[`v',1]) (`v') (2021)
}

forvalues v = 6/8{
	local x=`v'-1
	post `lgc' (table_2021[`x',1]) (`v') (2021)
}

forvalues v = 10/12{
	local x=`v'-2
	post `lgc' (table_2021[`x',1]) (`v') (2021)
}

post `lgc' (table_2021[11,1]) (13) (2021)

post `lgc' (table_2021[12,1]) (15) (2021)

post `lgc' (table_2021[13,1]) (16) (2021)

postclose `lgc'

preserve
use "`why_not_report_theft'", clear

label val category labels42

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))		///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==5, by(year) bcolor(gold) barwidth(0.75))	///
	(bar prop category if category==6, by(year) bcolor(erose) barwidth(0.75))	///
	(bar prop category if category==7, by(year) bcolor(forest_green) barwidth(0.75))	///
	(bar prop category if category==8, by(year) bcolor(khaki) barwidth(0.75))	///
	(bar prop category if category==9, by(year) bcolor(gray) barwidth(0.75))	///
	(bar prop category if category==10, by(year) bcolor(cyan) barwidth(0.75))	///
	(bar prop category if category==11, by(year) bcolor(blue) barwidth(0.75))	///
	(bar prop category if category==12, by(year) bcolor(olive) barwidth(0.75))	///
	(bar prop category if category==13, by(year) bcolor(gs3) barwidth(0.75))	///
	(bar prop category if category==14, by(year) bcolor(mint) barwidth(0.75))	///
	(bar prop category if category==15, by(year) bcolor(sandb) barwidth(0.75))	///
	(bar prop category if category==16, by(year) bcolor(midgreen) barwidth(0.75))	///
	, ytitle("Proporción", size(small)) xtitle("")	xlabel(none) note("") ///
	legend(order(	1	"Pérdida no suficientemente seria"	///
					2	"El problema se solucionó"			///
					3	"No tenía testigos"					///
					4	"Temor a amenazas/represalias"		///
					5	"No tenía seguro"					///
					6	"Conoce a los responsables"			///
					7	"Temor a encarar a los responsables en juicio"	///
					8	"Policía no podría haber hecho nada"			///
					9	"Responsables lo amenazaron"		///
					10	"Justicia (tribunales) no hubiera hecho nada"	///
					11	"Trámite demanda mucho tiempo"		///
					12	"Tiene parentesco con los responsables"			///
					13	"Policía no era necesaria"			///
					14	"Policía no hubiera hecho nada"		///
					15	"Policía recomendó no registrar la denuncia" ///
					16	"Otro") ///
					region(c(none)) size(vsmall) symysize(0.05cm) symxsize(0.15cm))

graph export "$graphs/Por qué no denuncia, hurto.pdf", replace
restore


*04		Why don't report Injury
tempname lgc
tempfile why_not_report_injury
postfile `lgc' prop category year using `why_not_report_injury', replace

forvalues x = 2016(1)2021{
	svy: tab porque_no_denuncio_lesiones if year==`x', nolabel
	mat table_`x' = e(Prop)
	*mat list table_`x'
}

forvalues v = 1/6{
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

forvalues v = 7/15{
	local x = `v'-1
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

post `lgc' (table_2016[15,1]) (16) (2016)

forvalues v = 1/4{
	post `lgc' (table_2017[`v',1]) (`v') (2017)
}

forvalues v = 6/8{
	local x = `v'-1
	post `lgc' (table_2017[`x',1]) (`v') (2017)
}

forvalues v = 10/15{
	local x = `v'-2
	post `lgc' (table_2017[`x',1]) (`v') (2017)
}

post `lgc' (table_2017[14,1]) (16) (2017)

forvalues v = 1/4{
	post `lgc' (table_2018[`v',1]) (`v') (2018)
}

post `lgc' (table_2018[5,1]) (6) (2018)

forvalues v = 8/15{
	local x = `v'-2
	post `lgc' (table_2018[`x',1]) (`v') (2018)
}

post `lgc' (table_2018[14,1]) (16) (2018)

forvalues v = 1/4{
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

forvalues v = 6/14{
	local x=`v'-1
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

post `lgc' (table_2019[14,1]) (16) (2019)

forvalues v = 1/4{
	post `lgc' (table_2020[`v',1]) (`v') (2020)
}

post `lgc' (table_2020[5,1]) (6) (2020)

post `lgc' (table_2020[6,1]) (8) (2020)

forvalues v = 9/13{
	local x = `v'-2
	post `lgc' (table_2020[`x',1]) (`v') (2020)
}

post `lgc' (table_2020[12,1]) (16) (2020)

forvalues v = 1/4{
	post `lgc' (table_2021[`v',1]) (`v') (2021)
}

post `lgc' (table_2021[5,1]) (6) (2021)

forvalues v = 8/13{
	local x=`v'-2
	post `lgc' (table_2021[`x',1]) (`v') (2021)
}

post `lgc' (table_2021[12,1]) (15) (2021)

post `lgc' (table_2021[13,1]) (16) (2021)

postclose `lgc'

preserve
use "`why_not_report_injury'", clear

label val category labels42

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))		///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==6, by(year) bcolor(erose) barwidth(0.75))	///
	(bar prop category if category==7, by(year) bcolor(forest_green) barwidth(0.75))	///
	(bar prop category if category==8, by(year) bcolor(khaki) barwidth(0.75))	///
	(bar prop category if category==9, by(year) bcolor(gray) barwidth(0.75))	///
	(bar prop category if category==10, by(year) bcolor(cyan) barwidth(0.75))	///
	(bar prop category if category==11, by(year) bcolor(blue) barwidth(0.75))	///
	(bar prop category if category==12, by(year) bcolor(olive) barwidth(0.75))	///
	(bar prop category if category==13, by(year) bcolor(gs3) barwidth(0.75))	///
	(bar prop category if category==14, by(year) bcolor(mint) barwidth(0.75))	///
	(bar prop category if category==15, by(year) bcolor(sandb) barwidth(0.75))	///
	(bar prop category if category==16, by(year) bcolor(midgreen) barwidth(0.75))	///
	, ytitle("Proporción", size(small)) xtitle("") xlabel(none)	note("") ///
	legend(order(	1	"Pérdida no suficientemente seria"	///
					2	"El problema se solucionó"			///
					3	"No tenía testigos"					///
					4	"Temor a amenazas/represalias"		///
					5	"Conoce a los responsables"			///
					6	"Temor a encarar a los responsables en juicio"	///
					7	"Policía no podría haber hecho nada"			///
					8	"Responsables lo amenazaron"		///
					9	"Justicia (tribunales) no hubiera hecho nada"	///
					10	"Trámite demanda mucho tiempo"		///
					11	"Tiene parentesco con los responsables"			///
					12	"Policía no era necesaria"			///
					13	"Policía no hubiera hecho nada"		///
					14	"Policía recomendó no registrar la denuncia" ///
					15	"Otro") ///
					region(c(none)) size(vsmall) symysize(0.05cm) symxsize(0.15cm))	

graph export "$graphs/Por qué no denuncia, lesiones.pdf", replace
restore


*05		Why don't report Stolen vehicle
tempname lgc
tempfile why_not_report_stolen_vehicle
postfile `lgc' prop category year using `why_not_report_stolen_vehicle', replace

forvalues x = 2016(1)2021{
	svy: tab porque_no_denuncio_de_vehiculo if year==`x', nolabel
	mat table_`x' = e(Prop)
	*mat list table_`x'
}

post `lgc' (table_2016[1,1]) (2) (2016)
post `lgc' (table_2016[2,1]) (6) (2016)
post `lgc' (table_2016[3,1]) (10) (2016)
post `lgc' (table_2016[4,1]) (11) (2016)
post `lgc' (table_2016[5,1]) (14) (2016)
post `lgc' (table_2016[6,1]) (15) (2016)
post `lgc' (table_2016[7,1]) (77) (2016)

post `lgc' (table_2017[1,1]) (2) (2017)
post `lgc' (table_2017[2,1]) (10) (2017)
post `lgc' (table_2017[3,1]) (14) (2017)
post `lgc' (table_2017[4,1]) (77) (2017)

post `lgc' (table_2018[1,1]) (2) (2018)
post `lgc' (table_2018[2,1]) (4) (2018)
post `lgc' (table_2018[3,1]) (11) (2018)
post `lgc' (table_2018[4,1]) (14) (2018)
post `lgc' (table_2018[5,1]) (77) (2018)

post `lgc' (table_2019[1,1]) (2) (2019)
post `lgc' (table_2019[2,1]) (3) (2019)
post `lgc' (table_2019[3,1]) (6) (2019)
post `lgc' (table_2019[4,1]) (10) (2019)
post `lgc' (table_2019[5,1]) (15) (2019)

post `lgc' (table_2020[1,1]) (2) (2020)
post `lgc' (table_2020[2,1]) (3) (2020)
post `lgc' (table_2020[3,1]) (6) (2020)
post `lgc' (table_2020[4,1]) (8) (2020)
post `lgc' (table_2020[5,1]) (10) (2020)
post `lgc' (table_2020[6,1]) (11) (2020)
post `lgc' (table_2020[7,1]) (77) (2020)

post `lgc' (table_2021[1,1]) (1) (2021)
post `lgc' (table_2021[2,1]) (2) (2021)
post `lgc' (table_2021[3,1]) (4) (2021)
post `lgc' (table_2021[4,1]) (6) (2021)
post `lgc' (table_2021[5,1]) (8) (2021)
post `lgc' (table_2021[6,1]) (10) (2021)
post `lgc' (table_2021[7,1]) (77) (2021)

postclose `lgc'

preserve
use "`why_not_report_stolen_vehicle'", clear

label val category labels42
replace category=16 if category==77

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))		///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==6, by(year) bcolor(erose) barwidth(0.75))	///
	(bar prop category if category==8, by(year) bcolor(khaki) barwidth(0.75))	///
	(bar prop category if category==10, by(year) bcolor(cyan) barwidth(0.75))	///
	(bar prop category if category==11, by(year) bcolor(blue) barwidth(0.75))	///
	(bar prop category if category==14, by(year) bcolor(mint) barwidth(0.75))	///
	(bar prop category if category==15, by(year) bcolor(sandb) barwidth(0.75))	///
	(bar prop category if category==16, by(year) bcolor(midgreen) barwidth(0.75))	///
	, ytitle("Proporción", size(small)) xtitle("") xlabel(none) note("")  ///
	legend(order(	1	"Pérdida no suficientemente seria"	///
					2	"El problema se solucionó"			///
					3	"No tenía testigos"					///
					4	"Temor a amenazas/represalias"		///
					5	"Conoce a los responsables"			///
					6	"Policía no podría haber hecho nada"			///
					7	"Justicia (tribunales) no hubiera hecho nada"	///
					8	"Trámite demanda mucho tiempo"		///
					9	"Policía no hubiera hecho nada"		///
					10	"Policía recomendó no registrar la denuncia"	///
					11	"Otro") ///
					region(c(none)) size(vsmall) symysize(0.05cm) symxsize(0.15cm))

graph export "$graphs/Por qué no denuncia, robo de vehículo.pdf", replace
restore


*06		Why don't report Robbery from vehicle
tempname lgc
tempfile why_not_report_from_vehicle
postfile `lgc' prop category year using `why_not_report_from_vehicle', replace

forvalues x = 2016(1)2021{
	svy: tab porque_no_denuncio_desde_veh if year==`x', nolabel
	mat table_`x' = e(Prop)
	*mat list table_`x'
}

forvalues v = 1/8{
	post `lgc' (table_2016[`v',1]) (`v') (2016)
}

forvalues v = 10/11{
	local x=`v'-1
	post `lgc' (table_2016[`x',1]) (`v') (2016)
}

forvalues v = 10/11{
	local x=`v'-1
	post `lgc' (table_2016[`x',1]) (`v') (2016)
}

forvalues v = 13/15{
	local x=`v'-2
	post `lgc' (table_2016[`x',1]) (`v') (2016)
}

post `lgc' (table_2016[14,1]) (16) (2016)

forvalues v = 1/6{
	post `lgc' (table_2017[`v',1]) (`v') (2017)
}

post `lgc' (table_2017[7,1]) (8) (2017)

forvalues v = 10/11{
	local x = `v'-2
	post `lgc' (table_2017[`x',1]) (`v') (2017)
}

forvalues v = 13/15{
	local x = `v'-3
	post `lgc' (table_2017[`x',1]) (`v') (2017)
}

post `lgc' (table_2017[13,1]) (16) (2017)

forvalues v = 1/8{
	post `lgc' (table_2018[`v',1]) (`v') (2018)
}

forvalues v = 10/11{
	local x = `v'-1
	post `lgc' (table_2018[`x',1]) (`v') (2018)
}

forvalues v = 13/15{
	local x = `v'-2
	post `lgc' (table_2018[`x',1]) (`v') (2018)
}

post `lgc' (table_2018[14,1]) (16) (2018)

forvalues v = 1/8{
	post `lgc' (table_2019[`v',1]) (`v') (2019)
}

forvalues v = 10/15{
	local x = `v'-1
	post `lgc' (table_2019[`x',1]) (`v') (2019)
}

post `lgc' (table_2019[15,1]) (16) (2019)

forvalues v = 1/6{
	post `lgc' (table_2020[`v',1]) (`v') (2020)
}

post `lgc' (table_2020[7,1]) (8) (2020)

forvalues v = 10/11{
	local x = `v'-2
	post `lgc' (table_2020[`x',1]) (`v') (2020)
}

post `lgc' (table_2020[9,1]) (13) (2020)

post `lgc' (table_2020[11,1]) (15) (2020)

post `lgc' (table_2020[12,1]) (16) (2020)

forvalues v = 1/6{
	post `lgc' (table_2021[`v',1]) (`v') (2021)
}

post `lgc' (table_2021[7,1]) (8) (2021)

forvalues v = 10/11{
	local x = `v'-2
	post `lgc' (table_2021[`x',1]) (`v') (2021)
}

post `lgc' (table_2021[10,1]) (13) (2021)

post `lgc' (table_2021[11,1]) (15) (2021)

post `lgc' (table_2021[12,1]) (16) (2021)

postclose `lgc'

preserve
use "`why_not_report_from_vehicle'", clear

label val category labels42

*Graph
twoway	///
	(bar prop category if category==1, by(year, graphregion(color(white)) note("")) bcolor(maroon) barwidth(0.75))		///
	(bar prop category if category==2, by(year) bcolor(midblue) barwidth(0.75))	///
	(bar prop category if category==3, by(year) bcolor(sand) barwidth(0.75))	///
	(bar prop category if category==4, by(year) bcolor(dknavy) barwidth(0.75))	///
	(bar prop category if category==6, by(year) bcolor(erose) barwidth(0.75))	///
	(bar prop category if category==8, by(year) bcolor(khaki) barwidth(0.75))	///
	(bar prop category if category==10, by(year) bcolor(cyan) barwidth(0.75))	///
	(bar prop category if category==11, by(year) bcolor(blue) barwidth(0.75))	///
	(bar prop category if category==14, by(year) bcolor(mint) barwidth(0.75))	///
	(bar prop category if category==15, by(year) bcolor(sandb) barwidth(0.75))	///
	(bar prop category if category==16, by(year) bcolor(midgreen) barwidth(0.75))	///
	, ytitle("Proporción", size(small)) xtitle("") xlabel(none)  ///
	legend(order(	1	"Pérdida no suficientemente seria"	///
					2	"El problema se solucionó"			///
					3	"No tenía testigos"					///
					4	"Temor a amenazas/represalias"		///
					5	"Conoce a los responsables"			///
					6	"Policía no podría haber hecho nada"			///
					7	"Justicia (tribunales) no hubiera hecho nada"	///
					8	"Trámite demanda mucho tiempo"		///
					9	"Policía no hubiera hecho nada"		///
					10	"Policía recomendó no registrar la denuncia"	///
					11	"Otro") ///
					region(c(none)) size(vsmall) symysize(0.05cm) symxsize(0.15cm))

graph export "$graphs/Por qué no denuncia, robo o hurtos desde vehículos.pdf", replace
restore
