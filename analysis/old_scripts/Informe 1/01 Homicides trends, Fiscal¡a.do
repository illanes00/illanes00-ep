/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01 Homicides trends, Fiscalía
	Author:		Lucas García
	Date:		November 20, 2022
	Version:	Stata 17

	Summary:	This dofile plots homicides trends using data from Fiscalia.
				First it plots the trend of all homicides from 2016 to 2021 and 
				then just the cumulative homicides from january to december from
				2016 to 2022.
				
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
*              1. Data 16-21     			   *
************************************************


*00		Opening 2016-2021 dataset
import excel using "$rawdata/Delitos ingresados, enero - diciembre 2016 2021, rm unificada", firstr clear

*Year total population and region proportion, from censo 2017 (INE)
g population_censo2017 = .
replace population_censo2017=226068 if region==15
replace population_censo2017=330558 if region==1
replace population_censo2017=607534 if region==2
replace population_censo2017=286168 if region==3
replace population_censo2017=757586 if region==4
replace population_censo2017=1815902 if region==5
replace population_censo2017=7112808 if region==13
replace population_censo2017=914555 if region==6
replace population_censo2017=1044950 if region==7
replace population_censo2017=480609+1556805 if region==8
replace population_censo2017=957224 if region==9
replace population_censo2017=384837 if region==14
replace population_censo2017=828708 if region==10
replace population_censo2017=103158 if region==11
replace population_censo2017=166533 if region==12

*01 	Total homicides variable, weighted by pop_prop
g HomicidiosIngresados = ImputadosConocidos + ImputadosDesconocidos

*Known
g imputados_conocidos = ImputadosConocidos/population_censo2017*100000
rename ImputadosConocidos Imputados_Conocidos_now
rename imputados_conocidos ImputadosConocidos 
label var ImputadosConocidos "Imputados Conocidos"
label var Imputados_Conocidos_now "Imputados Conocidos, sin ponderar"

*Unknown
g imputados_desconocidos = ImputadosDesconocidos/population_censo2017*100000
rename ImputadosDesconocidos Imputados_Desconocidos_now
rename imputados_desconocidos ImputadosDesconocidos 
label var ImputadosDesconocidos "Imputados Desconocidos"
label var Imputados_Desconocidos_now "Imputados Desconocidos, sin ponderar"

*Total
g homicidios_ingresados = HomicidiosIngresados/population_censo2017*100000
rename HomicidiosIngresados Homicidios_Ingresados_now
rename homicidios_ingresados HomicidiosIngresados 
label var HomicidiosIngresados "Homicidios Ingresados"
label var Homicidios_Ingresados_now "Homicidios Ingresados, sin ponderar"

*Save DB
save "$usedata/homicidios_fiscalia_16_21", replace

*02		Country level trend
preserve 
collapse (sum) Imputados_Conocidos_now Imputados_Desconocidos_now Homicidios_Ingresados_now , by(Año)
*Known/Unknown
g tasa_conocido_total = Imputados_Conocidos_now/Homicidios_Ingresados_now
label var tasa_conocido_total "Conocidos/Totales"

twoway	(scatter Imputados_Conocidos_now Año, connect(direct) yaxis(1) msymbol(D))	///
		(scatter Imputados_Desconocidos_now Año, connect(direct) yaxis(1) msymbol(T))	///
		(scatter Homicidios_Ingresados_now Año, connect(direct) yaxis(1) lwidth(thick) msymbol(S))	///
		(line tasa_conocido_total Año, connect(direct) yaxis(2) lpattern(dash) lwidth(medthick) lcolor(gs4)),	///
		graphregion(color(white)) ytitle("Homicidios Ingresados", axis(1)) ytitle("Proporción", axis(2)) ylabel(0(0.1)1, axis(2)) xtitle("") 		///
		legend(order(1 "H: con Imputados conocidos" 2 "H: con Imputados desconocidos" 3 "Homicidios totales" 4 "Proporción con imputados conocidos") size(vsmall))	///
		yscale(range(0 1))
		
graph export "$graphs/Tendencia país de homicidios ingresados, Fiscalía, 2016 a 2021.pdf", replace
graph export "$graphs/Tendencia país de homicidios ingresados, Fiscalía, 2016 a 2021.png", replace
graph export "$graphs/Tendencia país de homicidios ingresados, Fiscalía, 2016 a 2021.eps", replace
		
restore

*03 	By Region each indicator
replace Región = "VIII" if Región=="VIII + XVI"

*Known suspect
bys Año: egen mean_imp_conocidos_21 = mean(ImputadosConocidos)
twoway 	(line ImputadosConocidos Año if Región=="I" , lcolor(midblue))	///
		(line ImputadosConocidos Año if Región=="II" , lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="III", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="IV", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="V", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="VI", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="VII", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="VIII", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="IX", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="X", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="XI", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="XII", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="XIV", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="XV", lcolor(gs8)) 	///
		(line mean_imp_conocidos_21 Año , lwidth(thick) lcolor(gs4) lpattern(dash)) 	///
		(line ImputadosConocidos Año if Región=="RM", lcolor(gs8)) ,	///
		graphregion(color(white))	///
		legend(order(	1	"Tarapacá" 15 "Promedio país")	 size(small))		
		
graph export "$graphs/Tendencia Imputados Conocidos, 2016 a 2021, por region.pdf", replace
graph export "$graphs/Tendencia Imputados Conocidos, 2016 a 2021, por region.png", replace


*Unknown suspect 
bys Año: egen mean_imp_desconocidos_21 = mean(ImputadosDesconocidos)
twoway 	(line ImputadosDesconocidos Año if Región=="I" , lcolor(midblue))	///
		(line ImputadosDesconocidos Año if Región=="II" , lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="III", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="IV", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="V", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="VI", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="VII", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="VIII", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="IX", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="X", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="XI", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="XII", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="XIV", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="XV", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="RM", lcolor(gs8))	///
		(line mean_imp_desconocidos_21 Año , lwidth(thick) lcolor(gs4) lpattern(dash)) ,	///
		graphregion(color(white))	///
		legend(order(	1	"Tarapacá"		///
						16 "Promedio País") size(small))
		
graph export "$graphs/Tendencia Imputados Desconocidos, 2016 a 2021, por region.pdf", replace
graph export "$graphs/Tendencia Imputados Desconocidos, 2016 a 2021, por region.png", replace


*All Homicides
bys Año: egen mean_h_ingresados_21 = mean(HomicidiosIngresados)
twoway 	(line HomicidiosIngresados Año if Región=="I" , lcolor(midblue))	///
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
		(line mean_h_ingresados_21 Año , lwidth(thick) lcolor(gs4) lpattern(dash)) ,	///
		graphregion(color(white))	///
		legend(order(	1	"Tarapacá"	///
						16	"Promedio País"	) size(small))	
		
graph export "$graphs/Tendencia Homicidios Ingresados, 2016 a 2021, por region.pdf", replace
graph export "$graphs/Tendencia Homicidios Ingresados, 2016 a 2021, por region.png", replace


************************************************
*              2. Data 16-22     			   *
************************************************

*00		Opening 2016-2021 dataset
import excel using "$rawdata/Delitos ingresados, enero - septiembre, 2016 2022, rm unificada", firstr clear

*Merging
merge 1:1 region Año using "$usedata/ine_projections_16_22", nogen

*01 	Total homicides variable, weighted by pop_prop
g HomicidiosIngresados = ImputadosConocidos + ImputadosDesconocidos

*Known
g imputados_conocidos = ImputadosConocidos/poblacion*100000
rename ImputadosConocidos Imputados_Conocidos_now
rename imputados_conocidos ImputadosConocidos 
label var ImputadosConocidos "Imputados Conocidos"
label var Imputados_Conocidos_now "Imputados Conocidos, sin ponderar"

*Unknown
g imputados_desconocidos = ImputadosDesconocidos/poblacion*100000
rename ImputadosDesconocidos Imputados_Desconocidos_now
rename imputados_desconocidos ImputadosDesconocidos 
label var ImputadosDesconocidos "Imputados Desconocidos"
label var Imputados_Desconocidos_now "Imputados Desconocidos, sin ponderar"

*Total
g homicidios_ingresados = HomicidiosIngresados/poblacion*100000
rename HomicidiosIngresados Homicidios_Ingresados_now
rename homicidios_ingresados HomicidiosIngresados 
label var HomicidiosIngresados "Homicidios Ingresados"
label var Homicidios_Ingresados_now "Homicidios Ingresados, sin ponderar"

*Save DB
save "$usedata/homicidios_fiscalia_16_21", replace

*02		Country level trend
preserve 
collapse (sum) Imputados_Conocidos_now Imputados_Desconocidos_now Homicidios_Ingresados_now , by(Año)
*Known/Unknown
g tasa_conocido_total = Imputados_Conocidos_now/Homicidios_Ingresados_now
label var tasa_conocido_total "Conocidos/Totales"


twoway	(scatter Imputados_Conocidos_now Año, connect(direct) yaxis(1) msymbol(D))	///
		(scatter Imputados_Desconocidos_now Año, connect(direct) yaxis(1) msymbol(T))	///
		(scatter Homicidios_Ingresados_now Año, connect(direct) yaxis(1) lwidth(thick) msymbol(S))	///
		(line tasa_conocido_total Año, connect(direct) yaxis(2) lpattern(dash) lwidth(medthick) lcolor(gs4)),	///
		graphregion(color(white)) ytitle("Homicidios") ylabel(0(0.1)1, axis(2)) 		///
		legend(order(1 "H: con Imputados conocidos" 2 "H: con Imputados desconocidos" 3 "Homicidios totales" 4 "H: Con Imp conocidos/H totales") size(vsmall))	///
		yscale(range(0 1))		
		
graph export "$graphs/Tendencia país de homicidios ingresados, Fiscalía, 2016 a 2022.pdf", replace
graph export "$graphs/Tendencia país de homicidios ingresados, Fiscalía, 2016 a 2022.eps", replace
graph export "$graphs/Tendencia país de homicidios ingresados, Fiscalía, 2016 a 2022.png", replace
		
restore

*03 	By Region each indicator
replace Región = "VIII" if Región=="VIII + XVI"

*Known suspect
bys Año: egen mean_imp_conocidos_22 = mean(ImputadosConocidos)
twoway 	(line ImputadosConocidos Año if Región=="I" , lcolor(midblue))	///
		(line ImputadosConocidos Año if Región=="II" , lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="III", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="IV", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="V", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="VI", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="VII", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="VIII", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="IX", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="X", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="XI", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="XII", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="XIV", lcolor(gs8))	///
		(line ImputadosConocidos Año if Región=="XV", lcolor(gs8)) 	///
		(line mean_imp_conocidos_22 Año , lwidth(thick) lcolor(gs4) lpattern(dash)) 	///
		(line ImputadosConocidos Año if Región=="RM", lcolor(gs8)) ,	///
		graphregion(color(white))	ytitle("Tasa de Homicidios")	///
		legend(order(	1	"Tarapacá" 15 "Promedio país")	 size(small))		
		
graph export "$graphs/Tendencia Imputados Conocidos, 2016 a 2022, por region.pdf", replace
graph export "$graphs/Tendencia Imputados Conocidos, 2016 a 2022, por region.png", replace


*Unknown suspect 
bys Año: egen mean_imp_desconocidos_22 = mean(ImputadosDesconocidos)
twoway 	(line ImputadosDesconocidos Año if Región=="I" , lcolor(midblue) lpattern(dash_dot))	///
		(line ImputadosDesconocidos Año if Región=="II" , lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="III", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="IV", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="V", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="VI", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="VII", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="VIII", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="IX", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="X", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="XI", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="XII", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="XIV", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="XV", lcolor(gs8))	///
		(line ImputadosDesconocidos Año if Región=="RM", lcolor(gs8))	///
		(line mean_imp_desconocidos_22 Año , lwidth(thick) lcolor(gs4) lpattern(dash)) ,	///
		graphregion(color(white))	ytitle("Tasa de Homicidios")	///
		legend(order(	1	"Tarapacá"		///
						16 "Promedio Entre Regiones") size(small))
		
graph export "$graphs/Tendencia Imputados Desconocidos, 2016 a 2022, por region.pdf", replace
graph export "$graphs/Tendencia Imputados Desconocidos, 2016 a 2022, por region.png", replace
graph export "$graphs/Tendencia Imputados Desconocidos, 2016 a 2022, por region.eps", replace


*All Homicides
bys Año: egen mean_h_ingresados_22 = sum(Homicidios_Ingresados_now)
twoway 	(line HomicidiosIngresados Año if Región=="I" , lcolor(midblue))	///
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
		graphregion(color(white))	ytitle("Tasa de Homicidios")	///
		legend(order(	1	"Tarapacá"	///
						16	"Promedio País"	) size(small))	
		
graph export "$graphs/Tendencia Homicidios Ingresados, 2016 a 2022, por region.pdf", replace
graph export "$graphs/Tendencia Homicidios Ingresados, 2016 a 2022, por region.png", replace

*Save DB
save "$usedata/homicidios_fiscalia_16_22", replace


*****	Til June of each year

import excel using "$rawdata/homicidios ingresados, 2do trimestre 2016 - 2022", firstr sh("Hoja2") clear
replace Región="VIII" if Región=="VIII + XVI"

*Merging
merge 1:1 region Año using "$usedata/ine_projections_16_22", nogen

*01 	Total homicides variable, weighted by pop_prop
g HomicidiosIngresados = ImputadosConocidos + ImputadosDesconocidos

*Known
g imputados_conocidos = ImputadosConocidos/poblacion*100000
rename ImputadosConocidos Imputados_Conocidos_now
rename imputados_conocidos ImputadosConocidos 
label var ImputadosConocidos "Imputados Conocidos"
label var Imputados_Conocidos_now "Imputados Conocidos, sin ponderar"

*Unknown
g imputados_desconocidos = ImputadosDesconocidos/poblacion*100000
rename ImputadosDesconocidos Imputados_Desconocidos_now
rename imputados_desconocidos ImputadosDesconocidos 
label var ImputadosDesconocidos "Imputados Desconocidos"
label var Imputados_Desconocidos_now "Imputados Desconocidos, sin ponderar"

*Total
g homicidios_ingresados = HomicidiosIngresados/poblacion*100000
rename HomicidiosIngresados Homicidios_Ingresados_now
rename homicidios_ingresados HomicidiosIngresados 
label var HomicidiosIngresados "Homicidios Ingresados"
label var Homicidios_Ingresados_now "Homicidios Ingresados, sin ponderar"


*All Homicides
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
