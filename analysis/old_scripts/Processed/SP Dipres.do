/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		Gráficos evolución presupuestos SP Dipres
	Author:		Raúl Fugellie
	Date:		May 11, 2023
	Version:	Stata 17

	Summary:	
				
*******************************************************************************/

clear all

************************************************
*                0. Key Macros                 *
************************************************

*Folder globals

di "current user: `c(username)'"
if "`c(username)'" == "raulfugellie"{
	global path "/Users/raulfugellie/Dropbox/Seguridad Pública/Fuentes de Datos"
}
else if "`c(username)'" == "add user name"{
	global path ""	//	Escribir Dirección
}
	
	global Carabineros "$path/Dipres/Carabineros"
	global Defensoria "$path/Dipres/Defensoría Penal Pública"
	global Formacion "$path/Dipres/Formación y Perfeccionamiento policial"
	global Gendarmeria "$path/Dipres/Gendarmería"
	global MP "$path/Dipres/Ministerio Público"
	global PDI "$path/Dipres/PDI"
	global SML "$path/Dipres/SML"
	global usedata "$path/Dipres/Data consolidada"
	global graphs "$path/Dipres/Tablas y gráficos"
	
	
*************************************************************


**** Carabineros

foreach k in "2012" "2013" "2014" "2015" "2016" "2017" "2018" "2019" "2020" "2021" "2022" {

import excel "${Carabineros}/Informe Ejecución Programa Carabineros, 4to trimestre `k'", sheet("Programa 3101") cellrange(B6) firstrow clear
gen year = "`k'"
tempfile data`k'
save `data`k''

}

use `data2012', clear

append using `data2013'
append using `data2014'
append using `data2015'
append using `data2016'
append using `data2017'
append using `data2018'
append using `data2019'
append using `data2020'
append using `data2021'
append using `data2022'

cd "${usedata}"
gen Tipo="Carabineros de Chile"
compress
save Carabineros_Consolidado, replace



**** Formación y Perfeccionamiento policial

import excel "${Formacion}/Informe Ejecución Programa Formación y Perfeccionamiento policial, 4to trimestre 2022", sheet("Programa 3102") cellrange(B6) firstrow clear
gen year="2022"
gen Tipo="Formación y Perfeccionamiento policial"
cd "${usedata}"
compress
save Formacion_Consolidado, replace



**** Defensoría Penal Pública

foreach k in "2012" "2013" "2014" "2015" "2016" "2017" "2018" "2019" "2020" "2021" "2022" {

import excel "${Defensoria}/Informe Ejecución Programa Defensoría Penal Pública, 4to trimestre `k'", sheet("Programa 0901") cellrange(B6) firstrow clear
gen year = "`k'"
tempfile data`k'
save `data`k''

}

use `data2012', clear

append using `data2013'
append using `data2014'
append using `data2015'
append using `data2016'
append using `data2017'
append using `data2018'
append using `data2019'
append using `data2020'
append using `data2021'
append using `data2022'

cd "${usedata}"
gen Tipo="Defensoría Penal Pública"
compress
save Defensoria_Consolidado, replace




**** Gendarmería

foreach k in "2012" "2013" "2014" "2015" "2016" "2017" "2018" "2019" "2020" "2021" "2022" {

import excel "${Gendarmeria}/Informe Ejecución Programa Gendarmería, 4to trimestre `k'", sheet("Programa 0401") cellrange(B6) firstrow clear
gen year = "`k'"
tempfile data`k'
save `data`k''

}

use `data2012', clear

append using `data2013'
append using `data2014'
append using `data2015'
append using `data2016'
append using `data2017'
append using `data2018'
append using `data2019'
append using `data2020'
append using `data2021'
append using `data2022'

cd "${usedata}"
gen Tipo="Gendarmeria"
compress
save Gendarmeria_Consolidado, replace


**** Ministerio Público

foreach k in "2012" "2013" "2014" "2015" "2016" "2017" "2018" "2019" "2020" "2021" "2022" {

import excel "${MP}/Informe Ejecución Programa Ministerio Público, 4to trimestre `k'", sheet("Programa 0101") cellrange(B6) firstrow clear
gen year = "`k'"
tempfile data`k'
save `data`k''

}

use `data2012', clear

append using `data2013'
append using `data2014'
append using `data2015'
append using `data2016'
append using `data2017'
append using `data2018'
append using `data2019'
append using `data2020'
append using `data2021'
append using `data2022'

cd "${usedata}"
gen Tipo="Ministerio Público"
compress
save MP_Consolidado, replace


**** PDI

foreach k in "2012" "2013" "2014" "2015" "2016" "2017" "2018" "2019" "2020" "2021" "2022" {

import excel "${PDI}/Informe Ejecución Programa PDI, 4to trimestre `k'", sheet("Programa 3301") cellrange(B6) firstrow clear
gen year = "`k'"
tempfile data`k'
save `data`k''

}

use `data2012', clear

append using `data2013'
append using `data2014'
append using `data2015'
append using `data2016'
append using `data2017'
append using `data2018'
append using `data2019'
append using `data2020'
append using `data2021'
append using `data2022'

cd "${usedata}"
gen Tipo="PDI"
compress
save PDI_Consolidado, replace


**** SML

foreach k in "2012" "2013" "2014" "2015" "2016" "2017" "2018" "2019" "2020" "2021" "2022" {

import excel "${SML}/Informe Ejecucion Programa SML, 4to trimestre `k'", sheet("Programa 0301") cellrange(B6) firstrow clear
gen year = "`k'"
tempfile data`k'
save `data`k''

}

use `data2012', clear

append using `data2013'
append using `data2014'
append using `data2015'
append using `data2016'
append using `data2017'
append using `data2018'
append using `data2019'
append using `data2020'
append using `data2021'
append using `data2022'

cd "${usedata}"
gen Tipo="SML"
compress
save SML_Consolidado, replace


use Carabineros_Consolidado, replace
append using Defensoria_Consolidado
append using Gendarmeria_Consolidado
append using MP_Consolidado
append using PDI_Consolidado
append using SML_Consolidado
append using Formacion_Consolidado
destring year, replace
replace ClasificaciónEconómica = subinstr(ClasificaciónEconómica, " ","", .)


gen Ingresos= PresupuestoVigente if ClasificaciónEconómica=="INGRESOS"
gen Aporte_Fiscal= PresupuestoVigente if ClasificaciónEconómica=="APORTEFISCAL"
gen Gastos= PresupuestoVigente if ClasificaciónEconómica=="GASTOS"
gen Gastos_personal= PresupuestoVigente if ClasificaciónEconómica=="GASTOSENPERSONAL"
gen Gastos_consumo= PresupuestoVigente if ClasificaciónEconómica=="BIENESYSERVICIOSDECONSUMO"
save Consolidado, replace


**Ajuste IPC

import excel "${path}/IPC General.xlsx", sheet("Cuadro") cellrange(A3:B135) firstrow clear
gen year= year(Periodo)
drop Periodo
collapse(sum) IPCGeneral, by (year)
replace year=year-1
drop if year==2011
gsort -year 
gen Inflacion_acumulada = sum(IPCGeneral)
replace Inflacion_acumulada=0 if Inflacion_acumulada==.
drop IPCGeneral
save Inflacion, replace
use Consolidado,replace
merge m:1 year using "${usedata}/Inflacion.dta"
drop _merge
gen ponderador=(Inflacion_acumulada/100)+1
replace ponderador=1 if ponderador==.
save Consolidado, replace


**Tipo de Cambio

import excel "${path}/TC nominal.xlsx", sheet("Cuadro") cellrange(A3:B163) firstrow clear
gen year= year(Periodo)
gen mes= month(Periodo)
drop if year >2022 | year<2012
drop if mes!=12
drop Periodo mes
save TC_nominal, replace
use Consolidado,replace
merge m:1 year using "${usedata}/TC_nominal.dta"
drop _merge
save Consolidado, replace


**PIB en dólares

import excel "${path}/PIB en dolares.xlsx", sheet("Cuadro") cellrange(A3:B47) firstrow clear
gen year= year(Periodo)
gen mes= month(Periodo)
drop if mes!=12
drop Periodo mes
replace PIBmillonesUSDúltimos12=PIBmillonesUSDúltimos12*1000000
save PIB, replace
use Consolidado,replace
merge m:1 year using "${usedata}/PIB.dta"
drop _merge
save Consolidado, replace


**Gasto Total

foreach k in "2012" "2013" "2014" "2015" "2016" "2017" "2018" "2019" "2020" "2022" {

import excel "${path}/Dipres/Gasto Público/Estado de Operaciones del gobierno `k'.xlsx", sheet("Table 2") firstrow clear
keep if A=="TOTAL GASTOS 3/"
keep A TotalAño 
gen year = `k'
tempfile data`k'
save `data`k''

}

import excel "${path}/Dipres/Gasto Público/Estado de Operaciones del gobierno 2021.xlsx", sheet("Table 2") firstrow clear
keep if A=="TOTAL GASTOS 3/"
gen TotalAño=TotalAnual
keep A TotalAño 
gen year = 2021
tempfile data2021
save `data2021'


use `data2012', clear

append using `data2013'
append using `data2014'
append using `data2015'
append using `data2016'
append using `data2017'
append using `data2018'
append using `data2019'
append using `data2020'
append using `data2021'
append using `data2022'

cd "${usedata}"
compress
save Gasto_Total, replace
use Consolidado,replace
merge m:1 year using "${usedata}/Gasto_Total.dta"
drop _merge
replace TotalAño=TotalAño*1000000
save Consolidado, replace


**Figuras

foreach k in "Ingresos" "Aporte_Fiscal" "Gastos" "Gastos_personal" "Gastos_consumo" {

use Consolidado,replace
keep year Tipo `k' Inflacion_acumulada PIBmillonesUSDúltimos12 Tipodecambionominaldól ponderador TotalAño
drop if `k'==.
replace `k'=`k'*1000
tempfile data`k'
save `data`k''

}

use `dataIngresos', clear
merge 1:1 year Tipo using `dataAporte_Fiscal'
drop _merge
merge 1:1 year Tipo using `dataGastos'
drop _merge
merge 1:1 year Tipo using `dataGastos_personal'
drop _merge
merge 1:1 year Tipo using `dataGastos_consumo'
drop _merge


gen Otros_Ingresos=Ingresos-Aporte_Fiscal
gen Otros_Gastos=Gastos-Gastos_personal-Gastos_consumo



*Normalizado al 2022 por inflación
gen Ingresos1=Ingresos*ponderador
gen Aporte_Fiscal1=Aporte_Fiscal*ponderador
gen Otros_Ingresos1=Otros_Ingresos*ponderador
gen Gastos1=Gastos*ponderador
gen Gastos_personal1=Gastos_personal*ponderador
gen Gastos_consumo1=Gastos_consumo*ponderador
gen Otros_Gastos1=Otros_Gastos*ponderador

*Porcentaje del PIB
gen Ingresos2=((Ingresos/Tipodecambionominaldól)/PIBmillonesUSDúltimos12)*100
gen Aporte_Fiscal2=((Aporte_Fiscal/Tipodecambionominaldól)/PIBmillonesUSDúltimos12)*100
gen Otros_Ingresos2=((Otros_Ingresos/Tipodecambionominaldól)/PIBmillonesUSDúltimos12)*100
gen Gastos2=((Gastos/Tipodecambionominaldól)/PIBmillonesUSDúltimos12)*100
gen Gastos_personal2=((Gastos_personal/Tipodecambionominaldól)/PIBmillonesUSDúltimos12)*100
gen Gastos_consumo2=((Gastos_consumo/Tipodecambionominaldól)/PIBmillonesUSDúltimos12)*100
gen Otros_Gastos2=((Otros_Gastos/Tipodecambionominaldól)/PIBmillonesUSDúltimos12)*100

*Porcentaje del gasto total
gen Ingresos3=(Ingresos/TotalAño)*100
gen Aporte_Fiscal3=(Aporte_Fiscal/TotalAño)*100
gen Otros_Ingresos3=(Otros_Ingresos/TotalAño)*100
gen Gastos3=(Gastos/TotalAño)*100
gen Gastos_personal3=(Gastos_personal/TotalAño)*100
gen Gastos_consumo3=(Gastos_consumo/TotalAño)*100
gen Otros_Gastos3=(Otros_Gastos/TotalAño)*100




*Figura Normalizado por inflación

preserve
keep if Tipo=="Carabineros de Chile"
twoway (area Aporte_Fiscal1 Otros_Ingresos1 year, graphregion(color(white)) ytitle("Ingresos en Carabineros en pesos 2022")xlab(2012(1) 2022) color(gs4 gs8 gs12 gs 16))
graph export "$graphs/Carabineros Presupuesto Ingreso Vigente Normalizado por inflación.pdf", replace
restore

preserve
keep if Tipo=="Carabineros de Chile"
twoway (area Gastos_personal1 Gastos_consumo1 Otros_Gastos1 year, graphregion(color(white)) ytitle("Gasto en Carabineros en pesos") xlab(2012(1) 2022) xline(2014 2018) color(gs4 gs8 gs12 gs 16)) 
graph export "$graphs/Carabineros Presupuesto Gasto Vigente Normalizado por inflación.pdf", replace
restore

preserve
collapse (sum) Gastos_personal1 Gastos_consumo1 Otros_Gastos1, by (year)
twoway (area Gastos_personal1 Gastos_consumo1 Otros_Gastos1 year, graphregion(color(white)) ytitle("Gastos totales en seguridad en pesos") xlab(2012(1) 2022) xline(2014 2018) color(gs4 gs8 gs12 gs 16)) 
graph export "$graphs/Presupuesto Gasto Total Vigente Normalizado por inflación.pdf", replace
restore


*Figura % del pib

preserve
keep if Tipo=="Carabineros de Chile"
twoway (area Aporte_Fiscal2 Otros_Ingresos2 year, graphregion(color(white)) ytitle("Ingresos en Carabineros % del PIB")xlab(2012(1) 2022) color(gs4 gs8 gs12 gs 16))
graph export "$graphs/Carabineros Presupuesto Ingreso Vigente % del PIB.pdf", replace
restore

preserve
keep if Tipo=="Carabineros de Chile"
twoway (area Gastos_personal2 Gastos_consumo2 Otros_Gastos2 year, graphregion(color(white)) ytitle("Gasto en Carabineros % del PIB") xlab(2012(1) 2022) xline(2014 2018) color(gs4 gs8 gs12 gs 16)) 
graph export "$graphs/Carabineros Presupuesto Gasto Vigente % del PIB.pdf", replace
restore

preserve
keep if Tipo=="Carabineros de Chile" | Tipo=="PDI"
collapse (sum) Gastos_personal2 Gastos_consumo2 Otros_Gastos2, by (year)
twoway (area Gastos_personal2 Gastos_consumo2 Otros_Gastos2 year, graphregion(color(white)) ytitle("Gasto en Policías % del PIB") xlab(2012(1) 2022) xline(2014 2018) color(gs4 gs8 gs12 gs 16)) 
graph export "$graphs/Policías Presupuesto Gasto Vigente % del PIB.pdf", replace
restore

preserve
keep if Tipo=="Defensoría Penal Pública" | Tipo=="Ministerio Público"
collapse (sum) Gastos_personal2 Gastos_consumo2 Otros_Gastos2, by (year)
twoway (area Gastos_personal2 Gastos_consumo2 Otros_Gastos2 year, graphregion(color(white)) ytitle("Gasto en Defensoría y MP % del PIB") xlab(2012(1) 2022) xline(2014 2018) color(gs4 gs8 gs12 gs 16)) 
graph export "$graphs/Defensoría y MP Presupuesto Gasto Vigente % del PIB.pdf", replace
restore


preserve
keep if Tipo=="Carabineros de Chile"
twoway (area Gastos_personal2 Gastos_consumo2 Otros_Gastos2 year, graphregion(color(white)) ytitle("Gasto en Carabineros % del PIB") xlab(2012(1) 2022) xline(2014 2018) color(gs4 gs8 gs12 gs 16)) 
graph export "$graphs/Carabineros Presupuesto Gasto Vigente % del PIB.pdf", replace
restore

preserve
collapse (sum) Gastos_personal2 Gastos_consumo2 Otros_Gastos2, by (year)
twoway (area Gastos_personal2 Gastos_consumo2 Otros_Gastos2 year, graphregion(color(white)) ytitle("Gastos totales en seguridad % del PIB") xlab(2012(1) 2022) xline(2014 2018) color(gs4 gs8 gs12 gs 16)) 
graph export "$graphs/Presupuesto Gasto Total Vigente % del PIB.pdf", replace
restore


*Figura % del gasto

preserve
keep if Tipo=="Carabineros de Chile"
twoway (area Aporte_Fiscal3 Otros_Ingresos3 year, graphregion(color(white)) ytitle("Ingresos en Carabineros % del Gasto Público")xlab(2012(1) 2022) color(gs4 gs8 gs12 gs 16))
graph export "$graphs/Carabineros Presupuesto Ingreso Vigente % del Gasto Público.pdf", replace
restore

preserve
keep if Tipo=="Carabineros de Chile"
twoway (area Gastos_personal3 Gastos_consumo3 Otros_Gastos3 year, graphregion(color(white)) ytitle("Gasto en Carabineros % del Gasto Público") xlab(2012(1) 2022) xline(2014 2018) color(gs4 gs8 gs12 gs 16)) 
graph export "$graphs/Carabineros Presupuesto Gasto Vigente % del Gasto Público.pdf", replace
restore

preserve
collapse (sum) Gastos_personal3 Gastos_consumo3 Otros_Gastos3, by (year)
twoway (area Gastos_personal3 Gastos_consumo3 Otros_Gastos3 year, graphregion(color(white)) ytitle("Gastos totales en seguridad % del Gasto Público") xlab(2012(1) 2022) xline(2014 2018) color(gs4 gs8 gs12 gs 16)) 
graph export "$graphs/Presupuesto Gasto Total Vigente % del Gasto Público.pdf", replace
restore


*Gráfico por partidas Normalizado por inflación

preserve

use Consolidado,replace

keep if ClasificaciónEconómica=="GASTOS"

replace PresupuestoVigente= PresupuestoVigente*ponderador

twoway 	(line PresupuestoVigente year if Tipo=="Carabineros de Chile" , lcolor(green))	///
		(line PresupuestoVigente year if Tipo=="Defensoría Penal Pública" , lcolor(blue))	///
		(line PresupuestoVigente year if Tipo=="Gendarmeria" , lcolor(yellow))	///
		(line PresupuestoVigente year if Tipo=="Ministerio Público" , lcolor(gs8)) ///
		(line PresupuestoVigente year if Tipo=="SML" , lcolor(red)) ///
		(line PresupuestoVigente year if Tipo=="PDI" , lcolor(purple)),	///
		graphregion(color(white))	ytitle("Gasto total por sector en miles de pesos")	///
		legend(order(1 "Carabineros de Chile" 2 "Defensoría Penal Pública" 3 "Gendarmeria" 4 "Ministerio Público" 5 "SML" 6 "PDI")) xline(2014 2018)
		
graph export "$graphs/Presupuesto Vigente en miles de pesos.pdf", replace

restore





foreach j of num 1/3{ 
	preserve
	keep if Tipo=="Carabineros de Chile"
	twoway (area Aporte_Fiscal`j' Otros_Ingresos`j' year, graphregion(color(white)) yla(0(1000000000)1000000000) ytitle("Ingresos en Carabineros")xlab(2012(1) 2022) color(gs4 gs8 gs12 gs 16))
	graph export "$graphs/Presupuesto Ingreso Vigente `j'.pdf", replace
	restore

	preserve
	keep if Tipo=="Carabineros de Chile"
	twoway (area Gastos_personal`j' Gastos_consumo`j' Otros_Gastos`j' year, graphregion(color(white)) ytitle("Gasto en Carabineros") xlab(2012(1) 2022) xline(2014 2018) color(gs4 gs8 gs12 gs 16)) 
	graph export "$graphs/Presupuesto Gasto Vigente `j'.pdf", replace
	restore

	preserve
	collapse (sum) Gastos_personal`j' Gastos_consumo`j' Otros_Gastos`j', by (year)
	twoway (area Gastos_personal`j' Gastos_consumo`j' Otros_Gastos`j' year, graphregion(color(white)) ytitle("Gastos totales en seguridad") xlab(2012(1) 2022) xline(2014 2018) color(gs4 gs8 gs12 gs 16)) 
	graph export "$graphs/Presupuesto Gasto Total Vigente `j'.pdf", replace
	restore
		
}






