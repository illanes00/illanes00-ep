/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		00 Master Do file, Informe 1
	Author:		Lucas García
	Date:		December 13, 2022
	Version:	Stata 17

	Summary:	This dofile prepares the data to plot each one of the Figures of
				the article "Informe de Seguridad Pública: Tendencias recientes
				en crimen". To be used, you must check the address of each dofile
				called and of each folder where the figures are saved.
				
*******************************************************************************/

clear all

*************************************************
*                0. Key Macros                  *
*************************************************

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

	
version 17.0	
	
******************************************************
* 1. Cleaning data and Figures 2.1, 6.1, 2.2 and 6.2 *
******************************************************

do "$dofiles/01 Cleaning Data, ENUSC 16-21"

*		Open Database
use "$usedata/enusc_16_21"

svyset enc_idr [pweight=Fact_Hog], strata(VarStrat) singleunit(certainty)
*		Trend of Each Victimization Variable
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

label def delito	1	"Robo con violencia"	///
					2	"Robo con sorpresa"		///
					3	"Robo con fuerza en la vivienda"	///
					4	"Hurto"					///
					5	"Lesiones"				///
					6	"Robo de vehículos"		///
					7	"Robo desde vehículos"
					
label val indicador delito

*	Figure: 2.1	All crimes
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


*	Figure: 6.1 Without "Robbery from vehicles" & "Theft"
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

*	Figure 2.2	Report Rate Trend
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

*	Figure 6.2	Anual crimes with different DB and 2022 projection
do "$dofiles/01 DMCS Cead y ENUSC"


*************************************************
*		2. Figures 3.1, 6.3, 6.4 and 6.5		*
*************************************************
*00			Opening DB
import spss "$rawdata/base_interanual_enusc_2008_2021.sav", clear

*01			Defining DB as survey first for PAD & individual Victimization 
svyset id_unico [pweight=fact_pers_2019_2021], strata(varstrat) singleunit(certainty)


*01 		Setting the temporal file
tempname lgc 
tempfile trend
postfile `lgc' mean_pad stderr_pad mean_vic_i stderr_vic_i mean_vic_h stderr_vic_h mean_revic stderr_revic year using `trend'

*02			First for PAD & individual Victimization 
*PAD
svy: mean pad, over(año)
mat table_pad=r(table)
mat list table_pad

*Victimization
svy: mean vp_dc, over(año)
mat table_vic_i=r(table)


*03			Now for vict and revict
svyset idr [pweight=fact_hog_2019_2021], strata(varstrat) singleunit(certainty)

*Victimization
svy: mean va_dc , over(año)
mat table_vic_h=r(table)

*Re-Victimization
svy: mean rva_dc , over(año)
mat table_revic=r(table)


*04 		Now filling temporal file
forvalues x = 1/14{
	local year = `x'+2007
	local v = `x'*2
	post `lgc' (table_pad[1,`x']) (table_pad[2,`x']) (table_vic_i[1,`x']) (table_vic_i[2,`x']) (table_vic_h[1,`x']) (table_vic_h[2,`x']) (table_revic[1,`x']) (table_revic[2,`x']) (`year')
}

postclose `lgc'

preserve
use "`trend'", clear

*	Figure 3.1	Victimization and perception trends
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


*	Figure 6.3	Victimization and perception trends, 2008-2021
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


*	Figure 6.5	Perception and Victimization, different axis
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

restore


*	Figure 6.4	Perception of rising delinquency, country, municipality and neighborhood
use "$usedata/enusc_16_21", clear

svyset enc_idr [pweight=Fact_pers], strata(VarStrat) singleunit(certainty)

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


***********************************************************
* 3. Figures 4.1, 6.6, 6.7, 6.8, 4.2, 6.9a, 6.9b, and 4.3 *
***********************************************************

import excel using "$rawdata/reportesEstadisticos-porDelito, hasta 2do trimestre de c año", firstr sh("Hoja1") clear

tempfile cead
save `cead'

import excel using "$rawdata/homicidios ingresados, 2do trimestre 2016 - 2022", firstr sh("Hoja1") clear

*01		Merge with fiscalia, deis and ine estimations
merge 1:1 Año using "`cead'", nogen

merge 1:1 Año using "$usedata/deis_08_nov", nogen

tempfile db
save `db'

use "$usedata/ine_projections_16_22", clear
collapse (sum) poblacion, by(Año)
merge 1:1 Año using "`db'", nogen

*For 100000 habitants
replace HomicidiosIngresados=HomicidiosIngresados/poblacion*100000
replace HomicidiosTrimestral=HomicidiosTrimestral/poblacion*100000
replace unidad=unidad/poblacion*100000

*02		Each series mean to normalize
egen fiscalia_mean_aux = mean(HomicidiosIngresados) if Año<=2018
replace fiscalia_mean_aux=1 if Año>2018
egen fiscalia_mean = max(fiscalia_mean_aux)

egen cead_mean_aux = mean(HomicidiosTrimestral) if Año<=2018
replace cead_mean_aux=1 if Año>2018
egen cead_mean = max(cead_mean_aux)

*	Figure 6.8 Homicides, CEAD & Fiscalia until june of each year, w/o normalizing
twoway	(scatter HomicidiosIngresados Año , msymbol(circle) connect(direct) lpattern(solid)) ///
		(scatter HomicidiosTrimestral Año , msymbol(triangle) connect(direct) lpattern(dash_dot)), graphregion(color(white)) ///
		ytitle("Incidentes cada 100 mil habitantes") xtitle("")	///
		legend(order(1 "Ingresados totales en Fiscalía" 2 "Casos policiales de CEAD") rows(2) size(small))

graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022, sin normalizar.pdf", replace
graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022, sin normalizar.png", replace
graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022, sin normalizar.eps", replace
		
		
*	Figure 4.1 Homicides, CEAD & Fiscalia, until june of each year, normalized
replace HomicidiosIngresados=HomicidiosIngresados/fiscalia_mean
replace HomicidiosTrimestral=HomicidiosTrimestral/cead_mean
replace unidad=unidad/deis_mean

twoway	(scatter HomicidiosIngresados Año , msymbol(circle) connect(direct) lpattern(solid)) ///
		(scatter HomicidiosTrimestral Año , msymbol(triangle) connect(direct) lpattern(dash_dot)), graphregion(color(white)) ///
		ytitle("Incidentes cada 100 mil habitantes, normalizado", size(small)) xtitle("") xline(2018, lpattern(dash) lcolor(gs8))	///
		legend(order(1 "Ingresados totales en Fiscalía" 2 "Casos policiales de CEAD") rows(2) size(small))

graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022.pdf", replace
graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022.png", replace
graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022.eps", replace


*	Figure 6.7 Homicides rate, CEAD, Fiscalia and Fiscalia report, w/o normalizing
use "$usedata/cead", clear

merge 1:1 Año region using "$usedata/homicidios_fiscalia_16_22"

preserve
collapse (sum) Homicidios_Ingresados_now Homicidios_noweight, by(Año)
merge 1:1 Año using "$usedata/deis_2022_08_nov", nogen
tempfile db
save `db'

use "$usedata/ine_projections_16_22", clear
collapse (sum) poblacion, by(Año)
merge 1:1 Año using "`db'", nogen

replace Homicidios_Ingresados_now=Homicidios_Ingresados_now/poblacion*100000
replace Homicidios_noweight=Homicidios_noweight/poblacion*100000
replace unidad=unidad/poblacion*100000

egen fiscalia_mean_aux = mean(Homicidios_Ingresados_now) if Año<=2018
replace fiscalia_mean_aux=1 if Año>2018
egen fiscalia_mean = max(fiscalia_mean_aux)

egen cead_mean_aux = mean(Homicidios_noweight) if Año<=2018
replace cead_mean_aux=1 if Año>2018
egen cead_mean = max(cead_mean_aux)

g consumados = .
replace consumados = 4.2 if Año==2016
replace consumados = 4.6 if Año==2017
replace consumados = 4.7 if Año==2018
replace consumados = 4.8 if Año==2019
replace consumados = 5.7 if Año==2020

twoway	(scatter Homicidios_Ingresados_now Año if Año<=2021, msymbol(circle) connect(direct) lpattern(solid)) ///
		(scatter Homicidios_noweight Año if Año<=2021, msymbol(triangle) connect(direct) lpattern(dash_dot))	///
		(scatter consumados Año if Año<=2021, msymbol(diamond) connect(direct) lpattern(dash)) , graphregion(color(white)) ///
		ytitle("Incidentes cada 100 mil habitantes") xtitle("") ylabel(0(2)12)	///
		legend(order(1 "Ingresados Totales en Fiscalía" 2 "Casos policiales de CEAD" 3  "Consumados según informe de Fiscalía") rows(3) size(small))

graph export "$graphs/Homicidios, CEAD, Fiscalía y consumados, 2021.pdf", replace
graph export "$graphs/Homicidios, CEAD, Fiscalía y consumados, 2021.png", replace
graph export "$graphs/Homicidios, CEAD, Fiscalía y consumados, 2021.eps", replace


*	Figure 6.6 Homicides, CEAD & Fiscalia, until 2021, normalized
replace Homicidios_Ingresados_now=Homicidios_Ingresados_now/fiscalia_mean
replace Homicidios_noweight=Homicidios_noweight/cead_mean

twoway	(scatter Homicidios_Ingresados_now Año if Año<=2021, connect(direct) msymbol(circle)) ///
		(scatter Homicidios_noweight Año if Año<=2021, connect(direct) msymbol(triangle) lpattern(dash)), graphregion(color(white)) ///
		ytitle("Incidentes cada 100 mil habitantes, normalizado", size(small)) xline(2018, lpattern(dash) lcolor(gs8)) xtitle("")	///
		legend(order(1 "Ingresados totales en Fiscalía" 2 "Casos policiales de CEAD") rows(2))

graph export "$graphs/Homicidios, CEAD y Fiscalía, 2021.pdf", replace
graph export "$graphs/Homicidios, CEAD y Fiscalía, 2021.png", replace
		
restore


*	Figure 4.2 Regional Homicide rate, until 2021, CEAD
import excel using "$rawdata/reportesEstadisticos-unidadTerritorial, CEAD", firstr sh("Hoja1") clear

merge 1:1 region Año using "$usedata/ine_projections_16_22", nogen

preserve
collapse (sum) Homicidios poblacion, by(Año)
twoway	(scatter Homicidios Año if Año<2022, connect(direct)) , graphregion(color(white)) ///
		ytitle("Frecuencia Homicidios") xtitle("")	///
		 ylabel(0(500)1000)

graph export "$graphs/Homicidios, Casos policiales, CEAD.pdf", replace
graph export "$graphs/Homicidios, Casos policiales, CEAD.png", replace		
restore

g homicidios = Homicidios/poblacion*100000
rename Homicidios Homicidios_noweight
rename homicidios Homicidios

bys Año: egen mean_homicidios_pais_21 = sum(Homicidios_noweight)
bys Año: egen sum_poblacion = sum(poblacion)
replace mean_homicidios_pais_21=mean_homicidios_pais_21/sum_poblacion*100000
twoway 	(line Homicidios Año if Región=="I" & Año<2022, lcolor(midblue) lpattern(dash_dot))	///
		(line Homicidios Año if Región=="II" & Año<2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="III" & Año<2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="IV" & Año<2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="V" & Año<2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="VI" & Año<2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="VII" & Año<2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="VIII" & Año<2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="IX" & Año<2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="X" & Año<2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="XI" & Año<2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="XII" & Año<2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="XIV" & Año<2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="XV" & Año<2022, lcolor(gs8)) 	///
		(line Homicidios Año if Región=="RM" & Año<2022, lcolor(gs8))	///
		(line mean_homicidios_pais_21 Año if Año<2022, lwidth(thick) lcolor(gs4) lpattern(dash)) ,	///
		graphregion(color(white)) xtitle("")	///
		legend(order(	1	"Tarapacá" 16 "Tasa país") size(small))	///
		ytitle("Incidentes cada 100 mil habitantes")
		
graph export "$graphs/Homicidios, Casos policiales, por Región, CEAD.pdf", replace
graph export "$graphs/Homicidios, Casos policiales, por Región, CEAD.png", replace
graph export "$graphs/Homicidios, Casos policiales, por Región, CEAD.eps", replace


*	Figure 6.9a Regional Homicide rate, until 2022, june of each year, CEAD
import excel using "$rawdata/reportesEstadisticos-unidadTerritorial, hasta segundo trimestre 2016-2022", firstr sh("Hoja1") clear

**	This database comes weighted with Censo 2017 estimations.

gen mean_homicidios_pais_22=.
replace mean_homicidios_pais_22=1.2 if Año==2016
replace mean_homicidios_pais_22=1.6 if Año==2017
replace mean_homicidios_pais_22=1.8 if Año==2018
replace mean_homicidios_pais_22=1.8 if Año==2019
replace mean_homicidios_pais_22=2.3 if Año==2020
replace mean_homicidios_pais_22=1.6 if Año==2021
replace mean_homicidios_pais_22=2.3 if Año==2022

sort Año Región

twoway 	(line Homicidios Año if Región=="I" , lcolor(midblue) lpattern(dash_dot))	///
		(line Homicidios Año if Región=="II" , lcolor(gs8))	///
		(line Homicidios Año if Región=="III" , lcolor(gs8))	///
		(line Homicidios Año if Región=="IV" , lcolor(gs8))	///
		(line Homicidios Año if Región=="V" , lcolor(gs8))	///
		(line Homicidios Año if Región=="VI" , lcolor(gs8))	///
		(line Homicidios Año if Región=="VII" , lcolor(gs8))	///
		(line Homicidios Año if Región=="VIII" , lcolor(gs8))	///
		(line Homicidios Año if Región=="IX" , lcolor(gs8))	///
		(line Homicidios Año if Región=="X" , lcolor(gs8))	///
		(line Homicidios Año if Región=="XI" , lcolor(gs8))	///
		(line Homicidios Año if Región=="XII" , lcolor(gs8))	///
		(line Homicidios Año if Región=="XIV" , lcolor(gs8))	///
		(line Homicidios Año if Región=="XV" , lcolor(gs8)) 	///
		(line Homicidios Año if Región=="RM" , lcolor(gs8))	///
		(line mean_homicidios_pais_22 Año , lwidth(thick) lcolor(gs4) lpattern(dash)) ,	///
		graphregion(color(white)) xtitle("")	///
		legend(order(	1	"Tarapacá" 16 "Tasa país") size(small))	///
		ytitle("Incidentes cada 100 mil habitantes")
		
graph export "$graphs/Homicidios, Casos policiales, por Región, CEAD hasta 2022.pdf", replace
graph export "$graphs/Homicidios, Casos policiales, por Región, CEAD hasta 2022.png", replace
graph export "$graphs/Homicidios, Casos policiales, por Región, CEAD hasta 2022.eps", replace


*	Figure 6.9b Regional Homicide rate, until 2022, june of each year, Fiscalia
import excel using "$rawdata/homicidios ingresados, 2do trimestre 2016 - 2022", firstr sh("Hoja2") clear
replace Región="VIII" if Región=="VIII + XVI"

merge 1:1 region Año using "$usedata/ine_projections_16_22", nogen

g HomicidiosIngresados = ImputadosConocidos + ImputadosDesconocidos

g homicidios_ingresados = HomicidiosIngresados/poblacion*100000
rename HomicidiosIngresados Homicidios_Ingresados_now
rename homicidios_ingresados HomicidiosIngresados 
label var HomicidiosIngresados "Homicidios Ingresados"
label var Homicidios_Ingresados_now "Homicidios Ingresados, sin ponderar"

bys Año: egen mean_h_ingresados_22 = sum(Homicidios_Ingresados_now)
bys Año: egen sum_poblacion = sum(poblacion)
replace mean_h_ingresados_22 = mean_h_ingresados_22/sum_poblacion*100000
twoway 	(line HomicidiosIngresados Año if Región=="I" , lcolor(midblue) lpattern(dash_dot))	///
		(line HomicidiosIngresados Año if Región=="II" , lcolor(gs8))	///
		(line HomicidiosIngresados Año if Región=="III", lcolor(gs8))	///
		(line HomicidiosIngresados Año if Región=="IV", lcolor(gs8))	///
		(line HomicidiosIngresados Año if Región=="V", lcolor(gs8))	///
		(line HomicidiosIngresados Año if Región=="VI", lcolor(gs8))	///
		(line HomicidiosIngresados Año if Región=="VII", lcolor(gs8))	///
		(line HomicidiosIngresados Año if Región=="VIII", lcolor(gs8))	///
		(line HomicidiosIngresados Año if Región=="IX", lcolor(gs8))	///
		(line HomicidiosIngresados Año if Región=="X", lcolor(gs8))	///
		(line HomicidiosIngresados Año if Región=="XI", lcolor(gs8))	///
		(line HomicidiosIngresados Año if Región=="XII", lcolor(gs8))	///
		(line HomicidiosIngresados Año if Región=="XIV", lcolor(gs8))	///
		(line HomicidiosIngresados Año if Región=="XV", lcolor(gs8)) ///
		(line HomicidiosIngresados Año if Región=="RM", lcolor(gs8)) 	///
		(line mean_h_ingresados_22 Año , lwidth(thick) lcolor(gs4) lpattern(dash)) ,	///
		graphregion(color(white))	ytitle("Incidentes cada 100 mil habitantes")	///	
		xtitle("")	///
		legend(order(	1	"Tarapacá"	///
						16	"Tasa país"	) size(small))	
		
graph export "$graphs/Tendencia Homicidios Ingresados, 2016 a 2022, por region, hasta junio de cada año.pdf", replace
graph export "$graphs/Tendencia Homicidios Ingresados, 2016 a 2022, por region, hasta junio de cada año.png", replace
graph export "$graphs/Tendencia Homicidios Ingresados, 2016 a 2022, por region, hasta junio de cada año.eps", replace


*	Figure 4.3 Homicides trends by defendant category
import excel using "$rawdata/Delitos ingresados, enero - diciembre 2016 2021, rm unificada", firstr clear

preserve 
collapse (sum) ImputadosConocidos ImputadosDesconocidos HomicidiosIngresados , by(Año)

g tasa_conocido_total = ImputadosConocidos/HomicidiosIngresados
label var tasa_conocido_total "Conocidos/Totales"

twoway	(scatter ImputadosConocidos Año, connect(direct) yaxis(1) msymbol(D))	///
		(scatter ImputadosDesconocidos Año, connect(direct) yaxis(1) msymbol(T))	///
		(scatter HomicidiosIngresados Año, connect(direct) yaxis(1) lwidth(thick) msymbol(S))	///
		(line tasa_conocido_total Año, connect(direct) yaxis(2) lpattern(dash) lwidth(medthick) lcolor(gs4)),	///
		graphregion(color(white)) ytitle("Homicidios Ingresados", axis(1)) ytitle("Proporción", axis(2)) ylabel(0(0.1)1, axis(2)) xtitle("") 		///
		legend(order(1 "H: con Imputados conocidos" 2 "H: con Imputados desconocidos" 3 "Homicidios totales" 4 "Proporción con imputados conocidos") size(vsmall))	///
		yscale(range(0 1))
		
graph export "$graphs/Tendencia país de homicidios ingresados, Fiscalía, 2016 a 2021.pdf", replace
graph export "$graphs/Tendencia país de homicidios ingresados, Fiscalía, 2016 a 2021.png", replace
graph export "$graphs/Tendencia país de homicidios ingresados, Fiscalía, 2016 a 2021.eps", replace
		
restore