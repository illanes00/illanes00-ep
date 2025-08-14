/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		Update, Homicides trends, CEAD 2022 complete
	Author:		Lucas García
	Date:		February 16, 2023
	Version:	Stata 17

	Summary:	This dofile plots homicides trends using data from CEAD.
				It plots the trend of all homicides from 2016 to 2022.
				
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
*              1. Data 16-22, 				   *
************************************************

*00		Opening 2016-2022 dataset, cleaning it and merge with ine projections
import excel using "$rawdata/reportesEstadisticos-unidadTerritorial, CEAD homicidios con 2022 año completo", firstr sh("Hoja1")

*Renaming Year Variables
rename B Año2016
rename C Año2017
rename D Año2018
rename E Año2019
rename F Año2020
rename G Año2021
rename H Año2022

*Re-scaling Year Variables
forvalues k = 16/22{
	replace Año20`k' = Año20`k'/10000000000
}

*Renaming Region Variables
rename A Región
drop if Región=="Unidad Territorial"

*Coding Regions
replace Región="XV" if Región=="RegiÃ³n de Arica y Parinacota"
replace Región="I" if Región=="RegiÃ³n de TarapacÃ¡"
replace Región="II" if Región=="RegiÃ³n de Antofagasta"
replace Región="III" if Región=="RegiÃ³n de Atacama"
replace Región="IV" if Región=="RegiÃ³n de Coquimbo"
replace Región="V" if Región=="RegiÃ³n de ValparaÃ­so"
replace Región="RM" if Región=="RegiÃ³n Metropolitana"
replace Región="VI" if Región=="RegiÃ³n del Lib. Bernardo O'Higgins"
replace Región="VII" if Región=="RegiÃ³n del Maule"
replace Región="XVI" in 11
replace Región="VIII" if Región=="RegiÃ³n del BiobÃ­o"
replace Región="IX" if Región=="RegiÃ³n de La AraucanÃ­a"
replace Región="XIV" if Región=="RegiÃ³n de Los RÃ­os"
replace Región="X" if Región=="RegiÃ³n de Los Lagos"
replace Región="XI" if Región=="RegiÃ³n de AysÃ©n"
replace Región="XII" if Región=="RegiÃ³n de Magallanes"

g region=.
replace region=1 if Región=="I"
replace region=2 if Región=="II"
replace region=3 if Región=="III"
replace region=4 if Región=="IV"
replace region=5 if Región=="V"
replace region=6 if Región=="VI"
replace region=7 if Región=="VII"
replace region=8 if Región=="VIII"
replace region=9 if Región=="IX"
replace region=10 if Región=="X"
replace region=11 if Región=="XI"
replace region=12 if Región=="XII"
replace region=13 if Región=="RM"
replace region=14 if Región=="XIV"
replace region=15 if Región=="XV"
replace region=8 if Región=="XVI"

replace Región="VIII" if Región=="XVI"

collapse (sum) Año* , by(region Región)

replace Región="Total país" if Región=="TOTAL PAÃS"

*Reshape
reshape long Año, i(region Región) j(Año_aux)
rename Año Homicidios
rename Año_aux Año

*Merging
merge 1:1 region Año using "$usedata/ine_projections_16_22", nogen

*By 100000 individuals
g homicidios = Homicidios/poblacion*100000
rename Homicidios Homicidios_noweight
rename homicidios Homicidios

bys Año: egen sum_poblacion = sum(poblacion)
replace Homicidios=Homicidios_noweight/sum_poblacion*100000 if Región=="Total país"

*01		Plotting Region level trends 
twoway 	(line Homicidios Año if Región=="I" & Año<=2022, lcolor(midblue) lpattern(dash_dot))	///
		(line Homicidios Año if Región=="II" & Año<=2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="III" & Año<=2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="IV" & Año<=2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="V" & Año<=2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="VI" & Año<=2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="VII" & Año<=2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="VIII" & Año<=2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="IX" & Año<=2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="X" & Año<=2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="XI" & Año<=2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="XII" & Año<=2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="XIV" & Año<=2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="XV" & Año<=2022, lcolor(gs8)) 	///
		(line Homicidios Año if Región=="RM" & Año<=2022, lcolor(gs8))	///
		(line Homicidios Año if Región=="Total país" & Año<=2022, lwidth(thick) lcolor(gs4) lpattern(dash)) ,	///
		graphregion(color(white)) xtitle("")	///
		legend(order(	1	"Tarapacá" 16 "Tasa país") size(small))	///
		ytitle("Incidentes cada 100 mil habitantes")
		
graph export "$graphs/Homicidios, Casos policiales, por Región, CEAD hasta 2022.pdf", replace
graph export "$graphs/Homicidios, Casos policiales, por Región, CEAD hasta 2022.png", replace
graph export "$graphs/Homicidios, Casos policiales, por Región, CEAD hasta 2022.eps", replace


*01		Plotting Country level trends normalized
*Normalizing
egen cead_mean_aux = mean(Homicidios) if Año<=2018 & Región=="Total país"
replace cead_mean_aux=1 if Año>2018 & Región=="Total país"
egen cead_mean = max(cead_mean_aux) if Región=="Total país"
drop cead_mean_aux

g Homicidios_norm=Homicidios/cead_mean if Región=="Total país"

*Only Normalized
twoway	(scatter Homicidios_norm Año if Región=="Total país", msymbol(triangle) connect(direct) ///
		lpattern(dash_dot) lcolor(maroon) mcolor(maroon)), graphregion(color(white)) ///
		ytitle("Cambio en Tasa, relativo al promedio 2016-2018", size(small)) xtitle("") xline(2018, lpattern(dash) lcolor(gs8))	///
		legend(on lab(1 "Casos policiales de CEAD") size(small))

graph export "$graphs/Homicidios país normalizado, CEAD, 2022 completo.pdf", replace
graph export "$graphs/Homicidios país normalizado, CEAD, 2022 completo.png", replace
graph export "$graphs/Homicidios país normalizado, CEAD, 2022 completo.eps", replace

*Only rate
twoway	(scatter Homicidios Año if Región=="Total país", msymbol(O) connect(direct) ///
		lcolor(navy) mcolor(navy)), graphregion(color(white)) ///
		ytitle("Incidentes cada 100 mil habitantes", size(small) axis(1))		///
		xtitle("") ylabel(0(1)5)	///
		legend(on lab(1 "Incidentes cada 100 mil habitantes") r(1) size(small))

graph export "$graphs/Homicidios país solo tasa, CEAD, 2022 completo.pdf", replace
graph export "$graphs/Homicidios país solo tasa, CEAD, 2022 completo.png", replace
graph export "$graphs/Homicidios país solo tasa, CEAD, 2022 completo.eps", replace

*Both Normalized & rate
twoway	(scatter Homicidios Año if Región=="Total país", msymbol(O) connect(direct) ///
		lcolor(navy) mcolor(navy) yaxis(1)) ///
		(scatter Homicidios_norm Año if Región=="Total país", msymbol(triangle) connect(direct) ///
		lpattern(dash_dot) lcolor(maroon) mcolor(maroon) yaxis(2)), graphregion(color(white)) ///
		ytitle("Incidentes cada 100 mil habitantes", size(small) axis(1))		///
		ytitle("Cambio en Tasa, relativo al promedio 2016-2018", size(small) axis(2)) ///
		xtitle("") xline(2018, lpattern(dash) lcolor(gs8))	///
		ylabel(0(1)5, axis(1)) ylabel(0.8(0.2)1.6, axis(2))	/// 
		legend(order(1 "Incidentes cada 100 mil habitantes" 2 "Cambio en Tasa, relativo al promedio 2016-2018") r(2) size(small))

graph export "$graphs/Homicidios país, CEAD, 2022 completo.pdf", replace
graph export "$graphs/Homicidios país, CEAD, 2022 completo.png", replace
graph export "$graphs/Homicidios país, CEAD, 2022 completo.eps", replace