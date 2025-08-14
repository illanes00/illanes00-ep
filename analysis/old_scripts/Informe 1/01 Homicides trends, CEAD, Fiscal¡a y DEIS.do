/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01 Homicides trends, CEAD, Fiscalía y DEIS
	Author:		Lucas García
	Date:		November 22, 2022
	Version:	Stata 17

	Summary:	This dofile plots homicides trends using data from CEAD and from
				Fiscalia
				
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
*              1. Data 16-21 CEAD y Fiscalia   *
************************************************

*00		Opening 2016-2021 dataset
use "$usedata/cead"

*01		Merge with fiscalia
merge 1:1 Año region using "$usedata/homicidios_fiscalia_16_22"

preserve
collapse (sum) Homicidios_Ingresados_now Homicidios_noweight, by(Año)
merge 1:1 Año using "$usedata/deis_2022_08_nov", nogen
tempfile db
save `db'

use "$usedata/ine_projections_16_22", clear
collapse (sum) poblacion, by(Año)
merge 1:1 Año using "`db'", nogen

*For 100000 habitants
replace Homicidios_Ingresados_now=Homicidios_Ingresados_now/poblacion*100000
replace Homicidios_noweight=Homicidios_noweight/poblacion*100000
replace unidad=unidad/poblacion*100000

*02		Each series mean to normalize
egen fiscalia_mean_aux = mean(Homicidios_Ingresados_now) if Año<=2018
replace fiscalia_mean_aux=1 if Año>2018
egen fiscalia_mean = max(fiscalia_mean_aux)

egen cead_mean_aux = mean(Homicidios_noweight) if Año<=2018
replace cead_mean_aux=1 if Año>2018
egen cead_mean = max(cead_mean_aux)

*First Only CEAD & Fiscalía, no weighting by 2016-2018 avg
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
		legend(order(1 "Ingresados totales en Fiscalía" 2 "Casos policiales de CEAD" 3  "Consumados según informe de Fiscalía") rows(3) size(small))

graph export "$graphs/Homicidios, CEAD, Fiscalía y consumados, 2021.pdf", replace
graph export "$graphs/Homicidios, CEAD, Fiscalía y consumados, 2021.png", replace
graph export "$graphs/Homicidios, CEAD, Fiscalía y consumados, 2021.eps", replace

replace Homicidios_Ingresados_now=Homicidios_Ingresados_now/fiscalia_mean
replace Homicidios_noweight=Homicidios_noweight/cead_mean

twoway	(scatter Homicidios_Ingresados_now Año if Año<=2021, connect(direct) msymbol(circle)) ///
		(scatter Homicidios_noweight Año if Año<=2021, connect(direct) msymbol(triangle) lpattern(dash)), graphregion(color(white)) ///
		ytitle("Cambio en Tasa, relativo al promedio 2016-2018", size(small)) xline(2018, lpattern(dash) lcolor(gs8)) xtitle("")	///
		legend(order(1 "Ingresados totales en Fiscalía" 2 "Casos policiales de CEAD") rows(2))

graph export "$graphs/Homicidios, CEAD y Fiscalía, 2021.pdf", replace
graph export "$graphs/Homicidios, CEAD y Fiscalía, 2021.png", replace
		
restore


************************************************
*              2. Data 16-22 CEAD y Fiscalia   *
************************************************

*00		Opening 2016-2022 dataset
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

egen deis_mean_aux = mean(unidad) if Año<=2018
replace deis_mean_aux=1 if Año>2018
egen deis_mean = max(deis_mean_aux)

*First Only CEAD & Fiscalía, no weighting by 2016-2018 avg
twoway	(scatter HomicidiosIngresados Año , msymbol(circle) connect(direct) lpattern(solid)) ///
		(scatter HomicidiosTrimestral Año , msymbol(triangle) connect(direct) lpattern(dash_dot)), graphregion(color(white)) ///
		ytitle("Incidentes cada 100 mil habitantes") xtitle("")	///
		legend(order(1 "Ingresados totales en Fiscalía" 2 "Casos policiales de CEAD") rows(2) size(small))

graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022, sin normalizar.pdf", replace
graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022, sin normalizar.png", replace
graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022, sin normalizar.eps", replace

replace HomicidiosIngresados=HomicidiosIngresados/fiscalia_mean
replace HomicidiosTrimestral=HomicidiosTrimestral/cead_mean
replace unidad=unidad/deis_mean

*First Only CEAD & Fiscalía
twoway	(scatter HomicidiosIngresados Año , msymbol(circle) connect(direct) lpattern(solid)) ///
		(scatter HomicidiosTrimestral Año , msymbol(triangle) connect(direct) lpattern(dash_dot)), graphregion(color(white)) ///
		ytitle("Cambio en Tasa, relativo al promedio 2016-2018", size(small)) xtitle("") xline(2018, lpattern(dash) lcolor(gs8))	///
		legend(order(1 "Ingresados totales en Fiscalía" 2 "Casos policiales de CEAD") rows(2) size(small))

graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022.pdf", replace
graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022.png", replace
graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022.eps", replace


*CEAD, Fiscalia & Deis
twoway	(scatter HomicidiosIngresados Año , msymbol(circle) connect(direct) lpattern(solid)) ///
		(scatter unidad Año , msymbol(square) connect(direct) lpattern(dash)) ///
		(scatter HomicidiosTrimestral Año , msymbol(triangle) connect(direct) lpattern(dash_dot)), graphregion(color(white)) ///
		ytitle("Tasa de Homicidios y defunciones") xtitle("")	///
		legend(order(1 "Ingresados en Fiscalía" 2 "Defunciones por armas de fuego, DEIS" 3 "Casos policiales de CEAD") size(small))

graph export "$graphs/Homicidios, CEAD, Fiscalía y Deis, 2022.pdf", replace
graph export "$graphs/Homicidios, CEAD, Fiscalía y Deis, 2022.png", replace