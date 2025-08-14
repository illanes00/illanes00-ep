/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01 Homicides trends, CEAD
	Author:		Lucas García
	Date:		November 21, 2022
	Version:	Stata 17

	Summary:	This dofile plots homicides trends using data from CEAD.
				It plots the trend of all homicides from 2016 to 2021.
				
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
*              1. Data 16-21, 				   *
************************************************

*00		Opening 2016-2021 dataset and merge with ine projections
import excel using "$rawdata/reportesEstadisticos-unidadTerritorial, CEAD", firstr sh("Hoja1")

*Merging
merge 1:1 region Año using "$usedata/ine_projections_16_22", nogen


*01		Plotting Country level trends
preserve
collapse (sum) Homicidios poblacion, by(Año)
twoway	(scatter Homicidios Año if Año<2022, connect(direct)) , graphregion(color(white)) ///
		ytitle("Frecuencia Homicidios") xtitle("")	///
		 ylabel(0(500)1000)

graph export "$graphs/Homicidios, Casos policiales, CEAD.pdf", replace
graph export "$graphs/Homicidios, Casos policiales, CEAD.png", replace		
restore

*By 100000 individuals
g homicidios = Homicidios/poblacion*100000
rename Homicidios Homicidios_noweight
rename homicidios Homicidios

*02		Plotting Region level trends 
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

save "$usedata/cead", replace


***	Checking the rate, country level
*preserve
collapse (sum) Homicidios_no poblacion, by(Año)
g rate=Homicidios/poblacion*100000
twoway	(scatter rate Año if Año<2022, connect(direct)) , graphregion(color(white)) ///
		ytitle("Tasa Homicidios, Casos Policiales") xtitle("") legend(order(1 "Homicidios cada 100 mil habitantes, Casos Policiales"))

graph export "$graphs/Tasa Homicidios país, Casos policiales, CEAD.pdf", replace
graph export "$graphs/Tasa Homicidios país, Casos policiales, CEAD.eps", replace
graph export "$graphs/Tasa Homicidios país, Casos policiales, CEAD.png", replace
restore

************************************************
*              2. Data 16-22 				   *
************************************************

*00		Opening 2016-2022 dataset
import excel using "$rawdata/reportesEstadisticos-unidadTerritorial, hasta segundo trimestre 2016-2022", firstr sh("Hoja1") clear

**	This database comes weighted with Censo 2017 estimations.

*01		Plotting Region level trends 
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