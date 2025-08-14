/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01 Homicides trends, CEAD y Fiscalía
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
*02		Each series mean to normalize
egen fiscalia_mean_aux = mean(Homicidios_Ingresados_now) if Año<=2018
replace fiscalia_mean_aux=1 if Año>2018
egen fiscalia_mean = max(fiscalia_mean_aux)

egen cead_mean_aux = mean(Homicidios_noweight) if Año<=2018
replace cead_mean_aux=1 if Año>2018
egen cead_mean = max(cead_mean_aux)

replace Homicidios_Ingresados_now=Homicidios_Ingresados_now/fiscalia_mean
replace Homicidios_noweight=Homicidios_noweight/cead_mean

twoway	(scatter Homicidios_Ingresados_now Año if Año<=2021, connect(direct)) ///
		(scatter Homicidios_noweight Año if Año<=2021, connect(direct)), graphregion(color(white)) ///
		title("Homicidios, CEAD y Fiscalía") ytitle("Tasa de Homicidios") xtitle("")	///
		legend(order(1 "Ingresados en Fiscalía" 2 "Casos policiales de CEAD"))

graph export "$graphs/Homicidios, CEAD y Fiscalía, 2021.pdf", replace
graph export "$graphs/Homicidios, CEAD y Fiscalía, 2021.png", replace
		
restore

************************************************
*              1. Data 16-22 CEAD y Fiscalia   *
************************************************

*00		Opening 2016-2022 dataset
import excel using "$rawdata/reportesEstadisticos-porDelito, hasta 2do trimestre de c año", firstr sh("Hoja1") clear

tempfile cead
save `cead'

import excel using "$rawdata/homicidios ingresados, 2do trimestre 2016 - 2022", firstr sh("Hoja1") clear

*01		Merge with fiscalia
merge 1:1 Año using "`cead'", nogen

*02		Each series mean to normalize
egen fiscalia_mean_aux = mean(HomicidiosIngresados) if Año<=2018
replace fiscalia_mean_aux=1 if Año>2018
egen fiscalia_mean = max(fiscalia_mean_aux)

egen cead_mean_aux = mean(HomicidiosTrimestral) if Año<=2018
replace cead_mean_aux=1 if Año>2018
egen cead_mean = max(cead_mean_aux)

replace HomicidiosIngresados=HomicidiosIngresados/fiscalia_mean
replace HomicidiosTrimestral=HomicidiosTrimestral/cead_mean

twoway	(scatter HomicidiosIngresados Año , connect(direct)) ///
		(scatter HomicidiosTrimestral Año , connect(direct)), graphregion(color(white)) ///
		ytitle("Tasa de Homicidios") xtitle("")	///
		legend(order(1 "Ingresados en Fiscalía" 2 "Casos policiales de CEAD"))

graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022.pdf", replace
graph export "$graphs/Homicidios, CEAD y Fiscalía, 2022.png", replace