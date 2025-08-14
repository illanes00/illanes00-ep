
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
	global UE "$path/UE"
	
*************************************************************

******* 1

import excel "/Users/raulfugellie/Downloads/articles-311931_doc_xls.xlsx", sheet("CFEGCT") cellrange(A6:L76) firstrow clear

tostring A, replace
gen A1= substr(A,1,3)
order A A1


keep if A1=="7" | A1=="703" | A=="701" | A=="702" | A=="704" | A=="705" | A=="706" | A=="707" | A=="708" | A=="709" | A=="710"

rename B Partida
rename C Pesos_2013
rename D Pesos_2014
rename E Pesos_2015
rename F Pesos_2016
rename G Pesos_2017
rename H Pesos_2018
rename I Pesos_2019
rename J Pesos_2020
rename K Pesos_2021
rename L Pesos_2022


tempfile data1
save `data1', replace

******* 2

import excel "/Users/raulfugellie/Downloads/articles-311931_doc_xls.xlsx", sheet("CFEGCT$22") cellrange(A6:L76) firstrow clear

tostring A, replace
gen A1= substr(A,1,3)
order A A1


keep if A1=="7" | A1=="703" | A=="701" | A=="702" | A=="704" | A=="705" | A=="706" | A=="707" | A=="708" | A=="709" | A=="710"

rename B Partida
rename C Pesos22_2013
rename D Pesos22_2014
rename E Pesos22_2015
rename F Pesos22_2016
rename G Pesos22_2017
rename H Pesos22_2018
rename I Pesos22_2019
rename J Pesos22_2020
rename K Pesos22_2021
rename L Pesos22_2022


tempfile data2
save `data2', replace


******* 3

import excel "/Users/raulfugellie/Downloads/articles-311931_doc_xls.xlsx", sheet("CFEGCT%PIB") cellrange(A6:L76) firstrow clear

tostring A, replace
gen A1= substr(A,1,3)
order A A1


keep if A1=="7" | A1=="703" | A=="701" | A=="702" | A=="704" | A=="705" | A=="706" | A=="707" | A=="708" | A=="709" | A=="710"

rename B Partida
rename C PIB_2013
rename D PIB_2014
rename E PIB_2015
rename F PIB_2016
rename G PIB_2017
rename H PIB_2018
rename I PIB_2019
rename J PIB_2020
rename K PIB_2021
rename L PIB_2022


tempfile data3
save `data3', replace


******* 4

import excel "/Users/raulfugellie/Downloads/articles-311931_doc_xls.xlsx", sheet("CFEGCT%GT") cellrange(A6:L76) firstrow clear

tostring A, replace
gen A1= substr(A,1,3)
order A A1


keep if A1=="7" | A1=="703" | A=="701" | A=="702" | A=="704" | A=="705" | A=="706" | A=="707" | A=="708" | A=="709" | A=="710"

rename B Partida
rename C GT_2013
rename D GT_2014
rename E GT_2015
rename F GT_2016
rename G GT_2017
rename H GT_2018
rename I GT_2019
rename J GT_2020
rename K GT_2021
rename L GT_2022


tempfile data4
save `data4', replace



******* 11

import excel "/Users/raulfugellie/Downloads/articles-189249_doc_xls.xlsx", sheet("CFEGCT") cellrange(A6:L76) firstrow clear

tostring A, replace
gen A1= substr(A,1,3)
order A A1


keep if A1=="7" | A1=="703" | A=="701" | A=="702" | A=="704" | A=="705" | A=="706" | A=="707" | A=="708" | A=="709" | A=="710"

rename B Partida
rename C Pesos_2009
rename D Pesos_2010
rename E Pesos_2011
rename F Pesos_2012
rename G Pesos_2013
rename H Pesos_2014
rename I Pesos_2015
rename J Pesos_2016
rename K Pesos_2017
rename L Pesos_2018


drop Pesos_2013 Pesos_2014 Pesos_2015 Pesos_2016 Pesos_2017 Pesos_2018

replace Partida="Actividades recreativas, cultura y religión" if Partida== "Actividades Recreativas, Cultura y Religión"
replace Partida="Asuntos económicos" if Partida== "Asuntos Económicos"
replace Partida="Orden público y seguridad" if Partida== "Orden Público y Seguridad"
replace Partida="Orden público y seguridad n.e.p." if Partida== "Orden Público y Seguridad n.e.p."
replace Partida="Protección del medio ambiente" if Partida== "Protección del Medio Ambiente"
replace Partida="Servicios públicos generales" if Partida== "Servicios Públicos Generales"
replace Partida="Servicios de policía" if Partida== "Servicios de Policía"
replace Partida="Servicios de protección contra incendios" if Partida== "Servicios de Protección contra Incendios"
replace Partida="Tribunales de justicia" if Partida== "Tribunales de Justicia"
replace Partida="Vivienda y servicios comunitarios" if Partida== "Vivienda y Servicios Comunitarios"
replace Partida="Servicios de protección contra incendios" if Partida== "Servicios de Protección contra Incendios"
replace Partida="Protección social" if Partida== "Protección Social"

tempfile data11
save `data11', replace

******* 22

import excel "/Users/raulfugellie/Downloads/articles-189249_doc_xls.xlsx", sheet("CFEGCT$18") cellrange(A6:L76) firstrow clear

tostring A, replace
gen A1= substr(A,1,3)
order A A1


keep if A1=="7" | A1=="703" | A=="701" | A=="702" | A=="704" | A=="705" | A=="706" | A=="707" | A=="708" | A=="709" | A=="710"

rename B Partida
rename C Pesos22_2009
rename D Pesos22_2010
rename E Pesos22_2011
rename F Pesos22_2012
rename G Pesos22_2013
rename H Pesos22_2014
rename I Pesos22_2015
rename J Pesos22_2016
rename K Pesos22_2017
rename L Pesos22_2018

replace Pesos22_2009=Pesos22_2009*1.2296
replace Pesos22_2010=Pesos22_2010*1.2296
replace Pesos22_2011=Pesos22_2011*1.2296
replace Pesos22_2012=Pesos22_2012*1.2296

drop Pesos22_2013 Pesos22_2014 Pesos22_2015 Pesos22_2016 Pesos22_2017 Pesos22_2018

replace Partida="Actividades recreativas, cultura y religión" if Partida== "Actividades Recreativas, Cultura y Religión"
replace Partida="Asuntos económicos" if Partida== "Asuntos Económicos"
replace Partida="Orden público y seguridad" if Partida== "Orden Público y Seguridad"
replace Partida="Orden público y seguridad n.e.p." if Partida== "Orden Público y Seguridad n.e.p."
replace Partida="Protección del medio ambiente" if Partida== "Protección del Medio Ambiente"
replace Partida="Servicios públicos generales" if Partida== "Servicios Públicos Generales"
replace Partida="Servicios de policía" if Partida== "Servicios de Policía"
replace Partida="Servicios de protección contra incendios" if Partida== "Servicios de Protección contra Incendios"
replace Partida="Tribunales de justicia" if Partida== "Tribunales de Justicia"
replace Partida="Vivienda y servicios comunitarios" if Partida== "Vivienda y Servicios Comunitarios"
replace Partida="Servicios de protección contra incendios" if Partida== "Servicios de Protección contra Incendios"
replace Partida="Protección social" if Partida== "Protección Social"

tempfile data22
save `data22', replace


******* 33

import excel "/Users/raulfugellie/Downloads/articles-189249_doc_xls.xlsx", sheet("CFEGCT%PIB") cellrange(A6:L76) firstrow clear

tostring A, replace
gen A1= substr(A,1,3)
order A A1


keep if A1=="7" | A1=="703" | A=="701" | A=="702" | A=="704" | A=="705" | A=="706" | A=="707" | A=="708" | A=="709" | A=="710"

rename B Partida
rename C PIB_2009
rename D PIB_2010
rename E PIB_2011
rename F PIB_2012
rename G PIB_2013
rename H PIB_2014
rename I PIB_2015
rename J PIB_2016
rename K PIB_2017
rename L PIB_2018

drop PIB_2013 PIB_2014 PIB_2015 PIB_2016 PIB_2017 PIB_2018

replace Partida="Actividades recreativas, cultura y religión" if Partida== "Actividades Recreativas, Cultura y Religión"
replace Partida="Asuntos económicos" if Partida== "Asuntos Económicos"
replace Partida="Orden público y seguridad" if Partida== "Orden Público y Seguridad"
replace Partida="Orden público y seguridad n.e.p." if Partida== "Orden Público y Seguridad n.e.p."
replace Partida="Protección del medio ambiente" if Partida== "Protección del Medio Ambiente"
replace Partida="Servicios públicos generales" if Partida== "Servicios Públicos Generales"
replace Partida="Servicios de policía" if Partida== "Servicios de Policía"
replace Partida="Servicios de protección contra incendios" if Partida== "Servicios de Protección contra Incendios"
replace Partida="Tribunales de justicia" if Partida== "Tribunales de Justicia"
replace Partida="Vivienda y servicios comunitarios" if Partida== "Vivienda y Servicios Comunitarios"
replace Partida="Servicios de protección contra incendios" if Partida== "Servicios de Protección contra Incendios"
replace Partida="Protección social" if Partida== "Protección Social"


tempfile data33
save `data33', replace


******* 44

import excel "/Users/raulfugellie/Downloads/articles-189249_doc_xls.xlsx", sheet("CFEGCT%GastoTotal") cellrange(A6:L76) firstrow clear

tostring A, replace
gen A1= substr(A,1,3)
order A A1


keep if A1=="7" | A1=="703" | A=="701" | A=="702" | A=="704" | A=="705" | A=="706" | A=="707" | A=="708" | A=="709" | A=="710"

rename B Partida
rename C GT_2009
rename D GT_2010
rename E GT_2011
rename F GT_2012
rename G GT_2013
rename H GT_2014
rename I GT_2015
rename J GT_2016
rename K GT_2017
rename L GT_2018

drop GT_2013 GT_2014 GT_2015 GT_2016 GT_2017 GT_2018

replace Partida="Actividades recreativas, cultura y religión" if Partida== "Actividades Recreativas, Cultura y Religión"
replace Partida="Asuntos económicos" if Partida== "Asuntos Económicos"
replace Partida="Orden público y seguridad" if Partida== "Orden Público y Seguridad"
replace Partida="Orden público y seguridad n.e.p." if Partida== "Orden Público y Seguridad n.e.p."
replace Partida="Protección del medio ambiente" if Partida== "Protección del Medio Ambiente"
replace Partida="Servicios públicos generales" if Partida== "Servicios Públicos Generales"
replace Partida="Servicios de policía" if Partida== "Servicios de Policía"
replace Partida="Servicios de protección contra incendios" if Partida== "Servicios de Protección contra Incendios"
replace Partida="Tribunales de justicia" if Partida== "Tribunales de Justicia"
replace Partida="Vivienda y servicios comunitarios" if Partida== "Vivienda y Servicios Comunitarios"
replace Partida="Servicios de protección contra incendios" if Partida== "Servicios de Protección contra Incendios"
replace Partida="Protección social" if Partida== "Protección Social"


tempfile data44
save `data44', replace



use `data1', clear
merge 1:1 Partida using `data2'
drop _merge
merge 1:1 Partida using `data3'
drop _merge
merge 1:1 Partida using `data4'
drop _merge
merge 1:1 Partida using `data11'
drop _merge
merge 1:1 Partida using `data22'
drop _merge
merge 1:1 Partida using `data33'
drop _merge
merge 1:1 Partida using `data44'
drop _merge



order A A1 Partida PIB_2009 PIB_2010 PIB_2011 PIB_2012 PIB_2013 PIB_2014 PIB_2015 PIB_2016 PIB_2017 PIB_2018 PIB_2019 PIB_2020 PIB_2021 PIB_2022 GT_2009 GT_2010 GT_2011 GT_2012 GT_2013 GT_2014 GT_2015 GT_2016 GT_2017 GT_2018 GT_2019 GT_2020 GT_2021 GT_2022 Pesos_2009 Pesos_2010 Pesos_2011 Pesos_2012 Pesos_2013 Pesos_2014 Pesos_2015 Pesos_2016 Pesos_2017 Pesos_2018 Pesos_2019 Pesos_2020 Pesos_2021 Pesos_2022 Pesos22_2009 Pesos22_2010 Pesos22_2011 Pesos22_2012 Pesos22_2013 Pesos22_2014 Pesos22_2015 Pesos22_2016 Pesos22_2017 Pesos22_2018 Pesos22_2019 Pesos22_2020 Pesos22_2021 Pesos22_2022

reshape long PIB_ GT_ Pesos_ Pesos22_, i(Partida) j(Year)

sort A1 A Year

*Aumento son 1500 millones 2023, los cuales se deprecian en relación a 2022 (inflación 2,5%), se pasan a pesos con el TC promedio del 2022 
gen Aumento= (((1500000000*100)/102.5)*859.51)/1000000
gen Pesos22_A= Pesos22_ + Aumento
gen PIB_A=(Pesos22_A*PIB_)/Pesos22_
gen GT_A=(Pesos22_A*GT_)/Pesos22_



cd "${usedata}"
replace Partida = subinstr(Partida, " ","", .)
save Dipres_SP, replace

**GRAFICOS

ssc install blindschemes
set scheme plotplain
set scheme plotplainblind
set scheme economist
set scheme sj
set scheme default, permanently


keep if Year>2012

preserve


drop if A=="7031"| A=="7032"| A=="7033"| A=="7034" | A=="7036"

twoway 	(line PIB_ Year if Partida=="Serviciospúblicosgenerales" , lcolor(blue))	///
		(line PIB_ Year if Partida=="Defensa" , lcolor(yellow))	///
		(line PIB_ Year if Partida=="Viviendayservicioscomunitarios" , lcolor(gs8)) ///
		(line PIB_ Year if Partida=="Actividadesrecreativas,culturayreligión" , lcolor(sand)) ///
		(line PIB_ Year if Partida=="Salud" , lcolor(orange)) ///
		(line PIB_ Year if Partida=="Educación" , lcolor(brown)) ///
		(line PIB_ Year if Partida=="Protecciónsocial" , lcolor(olive)) ///
		(line PIB_ Year if Partida=="Asuntoseconómicos" , lcolor(red)) ///
		(line PIB_ Year if Partida=="Proteccióndelmedioambiente" , lcolor(purple)) ///
		(line PIB_A Year if Partida=="Ordenpúblicoyseguridad" , lcolor(navy) lwidth(thick)) ///
		(line PIB_ Year if Partida=="Ordenpúblicoyseguridad" , lcolor(navy) lwidth(thick)),	///
		graphregion(color(white)) xla(2013(1)2022) ytitle("Porcentaje del PIB ") yscale(titlegap(*+6)) xtitle("") ///
		legend(cols(3) size(*1.10) pos(6) order(1 "Servicios Públicos" 2 "Defensa" 3 "Vivienda" 4 "Cultura" 5 "Salud" 6 "Educación" 7 "Protección Social" 8 "Asuntos económicos" 9 "Medioambiente" 10 "Seguridad Pública +" 11 "Seguridad Pública")) xline(2014 2018 2022)
		graph export "$graphs/GP como porcentaje del PIB.pdf", replace

		
twoway 	(line PIB_ Year if Partida=="Serviciospúblicosgenerales" , lcolor(blue))	///
		(line PIB_ Year if Partida=="Defensa" , lcolor(yellow))	///
		(line PIB_ Year if Partida=="Viviendayservicioscomunitarios" , lcolor(gs8)) ///
		(line PIB_ Year if Partida=="Actividadesrecreativas,culturayreligión" , lcolor(sand)) ///
		(line PIB_ Year if Partida=="Salud" , lcolor(orange)) ///
		(line PIB_ Year if Partida=="Educación" , lcolor(brown)) ///
		(line PIB_ Year if Partida=="Asuntoseconómicos" , lcolor(red))	///
		(line PIB_ Year if Partida=="Proteccióndelmedioambiente" , lcolor(purple)) ///
		(line PIB_A Year if Partida=="Ordenpúblicoyseguridad" , lcolor(navy) lpattern(dash) lwidth(thick)) ///
		(line PIB_ Year if Partida=="Ordenpúblicoyseguridad" , lcolor(navy) lwidth(thick)),	///
		graphregion(color(white)) xla(2013(1)2022,labsize(small)) ytitle("Gasto Público como porcentaje del PIB ")	yscale(titlegap(*+6)) xtitle("Año") ///
		legend(cols(3) size(*0.80) pos(5) order(1 "Servicios Públicos" 2 "Defensa" 3 "Vivienda" 4 "Cultura" 5 "Salud" 6 "Educación" 7 "Asuntos económicos" 8 "Medioambiente" 9 "Seguridad Pública +" 10 "Seguridad Pública")) xline(2014 2018 2022, lpattern(dash))
		graph export "$graphs/GP como porcentaje del PIB A.pdf", replace
		
		
twoway 	(line GT_ Year if Partida=="Serviciospúblicosgenerales" , lcolor(blue))	///
		(line GT_ Year if Partida=="Defensa" , lcolor(yellow))	///
		(line GT_ Year if Partida=="Viviendayservicioscomunitarios" , lcolor(gs8)) ///
		(line GT_ Year if Partida=="Actividadesrecreativas,culturayreligión" , lcolor(sand)) ///
		(line GT_ Year if Partida=="Salud" , lcolor(orange)) ///
		(line GT_ Year if Partida=="Educación" , lcolor(brown)) ///
		(line GT_ Year if Partida=="Protecciónsocial" , lcolor(olive)) ///
		(line GT_ Year if Partida=="Asuntoseconómicos" , lcolor(red)) ///
		(line GT_ Year if Partida=="Proteccióndelmedioambiente" , lcolor(purple)) ///
		(line GT_A Year if Partida=="Ordenpúblicoyseguridad" , lcolor(navy) lpattern(dash) lwidth(thick)) ///
		(line GT_ Year if Partida=="Ordenpúblicoyseguridad" , lcolor(navy) lwidth(thick)),	///
		graphregion(color(white))	xla(2013(1)2022,labsize(small)) xtitle("Año", size(medsmall))  ytitle("Partidas como porcentaje del Gasto Total", size(small)) yscale(titlegap(*+6)) xtitle("Año")	///
		legend(cols(3) size(*0.80) pos(5) order(1 "Servicios Públicos" 2 "Defensa" 3 "Vivienda" 4 "Cultura" 5 "Salud" 6 "Educación" 7 "Protección Social" 8 "Asuntos económicos" 9 "Medioambiente" 10 "Seguridad Pública +" 11 "Seguridad Pública")) xline(2014 2018 2022, lpattern(dash)) 
		graph export "$graphs/Partidas como porcentaje del GT.pdf", replace
		
restore

	
preserve
keep if Year>2012	
gen Z=100-GT_
replace GT_=(GT_*100)/72.13208 if Year==2013
replace GT_=(GT_*100)/72.9827 if Year==2014
replace GT_=(GT_*100)/73.47933 if Year==2015
replace GT_=(GT_*100)/74.41715 if Year==2016
replace GT_=(GT_*100)/74.84785 if Year==2017
replace GT_=(GT_*100)/75.9196 if Year==2018
replace GT_=(GT_*100)/75.31107 if Year==2019
replace GT_=(GT_*100)/70.46664 if Year==2020
replace GT_=(GT_*100)/56.83065 if Year==2021
replace GT_=(GT_*100)/70.90826 if Year==2022
replace GT_A=(Pesos22_A*GT_)/Pesos22_

twoway 	(line GT_ Year if Partida=="Serviciospúblicosgenerales" , lcolor(blue))	///
		(line GT_ Year if Partida=="Defensa" , lcolor(yellow))	///
		(line GT_ Year if Partida=="Viviendayservicioscomunitarios" , lcolor(gs8)) ///
		(line GT_ Year if Partida=="Actividadesrecreativas,culturayreligión" , lcolor(sand)) ///
		(line GT_ Year if Partida=="Salud" , lcolor(orange)) ///
		(line GT_ Year if Partida=="Educación" , lcolor(brown)) ///
		(line GT_ Year if Partida=="Asuntoseconómicos" , lcolor(red)) ///
		(line GT_ Year if Partida=="Proteccióndelmedioambiente" , lcolor(purple)) ///
		(line GT_A Year if Partida=="Ordenpúblicoyseguridad" , lcolor(navy) lpattern(dash) lwidth(thick)) ///
		(line GT_ Year if Partida=="Ordenpúblicoyseguridad" , lcolor(navy) lwidth(thick)),	///
		graphregion(color(white))	xla(2013(1)2022,labsize(small)) xtitle("Año", size(medsmall))  ytitle("Partidas como porcentaje del Gasto Total", size(small)) yscale(titlegap(*+6)) xtitle("Año")	///
		legend(cols(3) size(*0.80) pos(5) order(1 "Servicios Públicos" 2 "Defensa" 3 "Vivienda" 4 "Cultura" 5 "Salud" 6 "Educación" 7 "Asuntos económicos" 8 "Medioambiente" 9 "Seguridad Pública +" 10 "Seguridad Pública")) xline(2014 2018 2022, lpattern(dash)) 
		graph export "$graphs/Partidas como porcentaje del GT A.pdf", replace
restore

preserve
keep if Year>2012
replace Pesos22_ = Pesos22_ / 1000000
replace Pesos22_A = Pesos22_A / 1000000
		
twoway 	(line Pesos22_ Year if Partida=="Serviciospúblicosgenerales" , lcolor(blue))	///
		(line Pesos22_ Year if Partida=="Defensa" , lcolor(yellow))	///
		(line Pesos22_ Year if Partida=="Viviendayservicioscomunitarios" , lcolor(gs8)) ///
		(line Pesos22_ Year if Partida=="Actividadesrecreativas,culturayreligión" , lcolor(sand)) ///
		(line Pesos22_ Year if Partida=="Salud" , lcolor(orange)) ///
		(line Pesos22_ Year if Partida=="Educación" , lcolor(brown)) ///
		(line Pesos22_ Year if Partida=="Protecciónsocial" , lcolor(olive)) ///
		(line Pesos22_ Year if Partida=="Asuntoseconómicos" , lcolor(red)) ///
		(line Pesos22_ Year if Partida=="Proteccióndelmedioambiente" , lcolor(purple)) ///
		(line Pesos22_A Year if Partida=="Ordenpúblicoyseguridad" , lcolor(navy) lpattern(dash) lwidth(thick)) ///
		(line Pesos22_ Year if Partida=="Ordenpúblicoyseguridad" , lcolor(navy) lwidth(thick)),	///
		graphregion(color(white))	xla(2013(1)2022)  ytitle("Partidas en billones de pesos") yscale(titlegap(*+6))	///
		legend(cols(3) size(*0.80) pos(5) order(1 "Servicios Públicos" 2 "Defensa" 3 "Vivienda" 4 "Cultura" 5 "Salud" 6 "Educación" 7 "Protección Social" 8 "Asuntos económicos" 9 "Medioambiente" 10 "Seguridad Pública +" 11 "Seguridad Pública")) xline(2014 2018 2022)
		graph export "$graphs/Partidas en millones de millones de pesos 2022.pdf", replace
		
		
twoway 	(line Pesos22_ Year if Partida=="Serviciospúblicosgenerales" , lcolor(blue))	///
		(line Pesos22_ Year if Partida=="Defensa" , lcolor(yellow))	///
		(line Pesos22_ Year if Partida=="Viviendayservicioscomunitarios" , lcolor(gs8)) ///
		(line Pesos22_ Year if Partida=="Actividadesrecreativas,culturayreligión" , lcolor(sand)) ///
		(line Pesos22_ Year if Partida=="Salud" , lcolor(orange)) ///
		(line Pesos22_ Year if Partida=="Educación" , lcolor(brown)) ///
		(line Pesos22_ Year if Partida=="Asuntoseconómicos" , lcolor(red)) ///
		(line Pesos22_ Year if Partida=="Proteccióndelmedioambiente" , lcolor(purple)) ///
		(line Pesos22_A Year if Partida=="Ordenpúblicoyseguridad" , lcolor(navy) lpattern(dash) lwidth(thick)) ///
		(line Pesos22_ Year if Partida=="Ordenpúblicoyseguridad" , lcolor(navy) lwidth(thick)),	///
		graphregion(color(white))	xla(2013(1)2022)  ytitle("Partidas en billones de pesos") yscale(titlegap(*+6))	///
		legend(cols(3) size(*0.80) pos(5) order(1 "Servicios Públicos" 2 "Defensa" 3 "Vivienda" 4 "Cultura" 5 "Salud" 6 "Educación" 7 "Asuntos económicos" 8 "Medioambiente" 9 "Seguridad Pública +" 10 "Seguridad Pública")) xline(2014 2018 2022)
		graph export "$graphs/Partidas en millones de millones de pesos 2022 sin PS.pdf", replace
		
		
		
twoway 	(line Pesos22_ Year if Partida=="Ordenpúblicoyseguridad" , lcolor(navy)) ///
		(line Pesos22_A Year if Partida=="Ordenpúblicoyseguridad" , lcolor(red) lpattern(dash)),	///
		graphregion(color(white)) xla(2013(1)2022,labsize(small)) ytitle("Seguridad en millones de millones de pesos 2022")	///
		legend(order(1 "Seguridad Pública" 2 "Seguridad Pública + Aumento" )) xline(2014 2018 2022, lpattern(dash))
		graph export "$graphs/Seguridad en millones de millones de pesos 2022 Aumento.pdf", replace
		
restore
		
preserve 
drop if A=="7031"| A=="7032"| A=="7033"| A=="7034" | A=="7036"
replace Partida = subinstr(Partida, " ","", .)
keep if Year>2012

gen X=1 if Partida=="Ordenpúblicoyseguridad"
replace X=2 if Partida=="Serviciospúblicosgenerales"
replace X=3 if Partida=="Defensa"
replace X=4 if Partida=="Viviendayservicioscomunitarios" 
replace X=5 if Partida=="Actividadesrecreativas,culturayreligión" 
replace X=6 if Partida=="Salud"
replace X=7 if Partida=="Educación"
replace X=8 if Partida=="Protecciónsocial" 
replace X=9 if Partida=="Asuntoseconómicos" 
replace X=10 if Partida=="Proteccióndelmedioambiente" 
replace X=11 if Partida=="GASTOTOTAL" 
drop Partida A A1 Pesos22_A PIB_A GT_A
reshape wide PIB_ GT_ Pesos_ Pesos22_, i(Year) j(X)


replace PIB_2 = PIB_2 + PIB_1
replace PIB_3 = PIB_3 + PIB_2
replace PIB_4 = PIB_4 + PIB_3
replace PIB_5 = PIB_5 + PIB_4
replace PIB_6 = PIB_6 + PIB_5
replace PIB_7 = PIB_7 + PIB_6
replace PIB_9 = PIB_9 + PIB_7
replace PIB_10 = PIB_10 + PIB_9

replace GT_2 = GT_2 + GT_1
replace GT_3 = GT_3 + GT_2
replace GT_4 = GT_4 + GT_3
replace GT_5 = GT_5 + GT_4
replace GT_6 = GT_6 + GT_5
replace GT_7 = GT_7 + GT_6
replace GT_9 = GT_9 + GT_7
replace GT_10 = GT_10 + GT_9

gen zero = 0 
twoway rarea zero PIB_1 Year /// 
    || rarea PIB_1 PIB_2 Year  /// 
    || rarea PIB_2 PIB_3 Year  /// 
	|| rarea PIB_3 PIB_4 Year  /// 
	|| rarea PIB_4 PIB_5 Year  /// 
	|| rarea PIB_5 PIB_6 Year  /// 
	|| rarea PIB_6 PIB_7 Year  /// 
	|| rarea PIB_7 PIB_9 Year  /// 
	|| rarea PIB_9 PIB_10 Year  /// 
    ||, legend(cols(3) size(*0.80) pos(6) order(1 "Seguridad Pública" 2 "Servicios Públicos" 3 "Defensa" 4 "Vivienda" 5 "Cultura" 6 "Salud" 7 "Educación" 8 "Asuntos económicos" 9 "Medioambiente")) /// 
     xla(2013(1)2022) ytitle(Porcentaje del PIB)
	 graph export "$graphs/Gasto Público como porcentaje del PIB - 2 A.pdf", replace
	 
twoway rarea zero GT_1 Year /// 
    || rarea GT_1 GT_2 Year  /// 
    || rarea GT_2 GT_3 Year  /// 
	|| rarea GT_3 GT_4 Year  /// 
	|| rarea GT_4 GT_5 Year  /// 
	|| rarea GT_5 GT_6 Year  /// 
	|| rarea GT_6 GT_7 Year  /// 
	|| rarea GT_7 GT_9 Year  /// 
	|| rarea GT_9 GT_10 Year  /// 
    ||, legend(cols(3) size(*0.80) pos(6) order(1 "Seguridad Pública" 2 "Servicios Públicos" 3 "Defensa" 4 "Vivienda" 5 "Cultura" 6 "Salud" 7 "Educación" 8 "Asuntos económicos" 9 "Medioambiente")) /// 
     xla(2013(1)2022) ytitle(Porcentaje del Gasto Total)
	 graph export "$graphs/Partidas como porcentaje del Gasto Total - 2 A.pdf", replace

restore

preserve

drop if A=="7031"| A=="7032"| A=="7033"| A=="7034" | A=="7036"
replace Partida = subinstr(Partida, " ","", .)
keep if Year>2012

gen X=1 if Partida=="Ordenpúblicoyseguridad"
replace X=2 if Partida=="Serviciospúblicosgenerales"
replace X=3 if Partida=="Defensa"
replace X=4 if Partida=="Viviendayservicioscomunitarios" 
replace X=5 if Partida=="Actividadesrecreativas,culturayreligión" 
replace X=6 if Partida=="Salud"
replace X=7 if Partida=="Educación"
replace X=8 if Partida=="Protecciónsocial" 
replace X=9 if Partida=="Asuntoseconómicos" 
replace X=10 if Partida=="Proteccióndelmedioambiente" 
replace X=11 if Partida=="GASTOTOTAL" 
drop Partida A A1 Pesos22_A PIB_A GT_A
reshape wide PIB_ GT_ Pesos_ Pesos22_, i(Year) j(X)


replace PIB_2 = PIB_2 + PIB_1
replace PIB_3 = PIB_3 + PIB_2
replace PIB_4 = PIB_4 + PIB_3
replace PIB_5 = PIB_5 + PIB_4
replace PIB_6 = PIB_6 + PIB_5
replace PIB_7 = PIB_7 + PIB_6
replace PIB_8 = PIB_8 + PIB_7
replace PIB_9 = PIB_9 + PIB_8
replace PIB_10 = PIB_10 + PIB_9

replace GT_2 = GT_2 + GT_1
replace GT_3 = GT_3 + GT_2
replace GT_4 = GT_4 + GT_3
replace GT_5 = GT_5 + GT_4
replace GT_6 = GT_6 + GT_5
replace GT_7 = GT_7 + GT_6
replace GT_8 = GT_8 + GT_7
replace GT_9 = GT_9 + GT_8
replace GT_10 = GT_10 + GT_9

gen zero = 0 
twoway rarea zero PIB_1 Year /// 
    || rarea PIB_1 PIB_2 Year  /// 
    || rarea PIB_2 PIB_3 Year  /// 
	|| rarea PIB_3 PIB_4 Year  /// 
	|| rarea PIB_4 PIB_5 Year  /// 
	|| rarea PIB_5 PIB_6 Year  /// 
	|| rarea PIB_6 PIB_7 Year  /// 
	|| rarea PIB_7 PIB_8 Year  /// 
	|| rarea PIB_8 PIB_9 Year  /// 
	|| rarea PIB_9 PIB_10 Year  /// 
    ||, legend(cols(3) size(*0.80) pos(6) order(1 "Seguridad Pública" 2 "Servicios Públicos" 3 "Defensa" 4 "Vivienda" 5 "Cultura" 6 "Salud" 7 "Educación" 8 "Protección social" 9 "Asuntos económicos" 10 "Medioambiente")) /// 
     xla(2013(1)2022) ytitle(Porcentaje del PIB)
	 graph export "$graphs/Gasto Público como porcentaje del PIB - 2.pdf", replace
	 
twoway rarea zero GT_1 Year /// 
    || rarea GT_1 GT_2 Year  /// 
    || rarea GT_2 GT_3 Year  /// 
	|| rarea GT_3 GT_4 Year  /// 
	|| rarea GT_4 GT_5 Year  /// 
	|| rarea GT_5 GT_6 Year  /// 
	|| rarea GT_6 GT_7 Year  /// 
	|| rarea GT_7 GT_8 Year  /// 
	|| rarea GT_8 GT_9 Year  /// 
	|| rarea GT_9 GT_10 Year  /// 
    ||, legend(cols(3) size(*0.80) pos(6) order(1 "Seguridad Pública" 2 "Servicios Públicos" 3 "Defensa" 4 "Vivienda" 5 "Cultura" 6 "Salud" 7 "Educación" 8 "Protección social" 9 "Asuntos económicos" 10 "Medioambiente")) /// 
     xla(2013(1)2022) ytitle(Porcentaje del Gasto Total)
	 graph export "$graphs/Partidas como porcentaje del Gasto Total - 2.pdf", replace




restore




preserve
drop if A=="7031"| A=="7032"| A=="7033"| A=="7034" | A=="7036"
replace Partida = subinstr(Partida, " ","", .)
keep if Year>2012
gen Z=100-GT_
replace GT_=(GT_*100)/72.13208 if Year==2013
replace GT_=(GT_*100)/72.9827 if Year==2014
replace GT_=(GT_*100)/73.47933 if Year==2015
replace GT_=(GT_*100)/74.41715 if Year==2016
replace GT_=(GT_*100)/74.84785 if Year==2017
replace GT_=(GT_*100)/75.9196 if Year==2018
replace GT_=(GT_*100)/75.31107 if Year==2019
replace GT_=(GT_*100)/70.46664 if Year==2020
replace GT_=(GT_*100)/56.83065 if Year==2021
replace GT_=(GT_*100)/70.90826 if Year==2022

gen X=1 if Partida=="Ordenpúblicoyseguridad"
replace X=2 if Partida=="Serviciospúblicosgenerales"
replace X=3 if Partida=="Defensa"
replace X=4 if Partida=="Viviendayservicioscomunitarios" 
replace X=5 if Partida=="Actividadesrecreativas,culturayreligión" 
replace X=6 if Partida=="Salud"
replace X=7 if Partida=="Educación"
replace X=8 if Partida=="Protecciónsocial" 
replace X=9 if Partida=="Asuntoseconómicos" 
replace X=10 if Partida=="Proteccióndelmedioambiente" 
replace X=11 if Partida=="GASTOTOTAL" 
drop Partida A A1 Pesos22_A PIB_A GT_A
drop Z
reshape wide PIB_ GT_ Pesos_ Pesos22_, i(Year) j(X)


replace PIB_2 = PIB_2 + PIB_1
replace PIB_3 = PIB_3 + PIB_2
replace PIB_4 = PIB_4 + PIB_3
replace PIB_5 = PIB_5 + PIB_4
replace PIB_6 = PIB_6 + PIB_5
replace PIB_7 = PIB_7 + PIB_6
replace PIB_9 = PIB_9 + PIB_7
replace PIB_10 = PIB_10 + PIB_9

replace GT_2 = GT_2 + GT_1
replace GT_3 = GT_3 + GT_2
replace GT_4 = GT_4 + GT_3
replace GT_5 = GT_5 + GT_4
replace GT_6 = GT_6 + GT_5
replace GT_7 = GT_7 + GT_6
replace GT_9 = GT_9 + GT_7
replace GT_10 = GT_10 + GT_9

gen zero = 0  
twoway rarea zero GT_1 Year /// 
    || rarea GT_1 GT_2 Year  /// 
    || rarea GT_2 GT_3 Year  /// 
	|| rarea GT_3 GT_4 Year  /// 
	|| rarea GT_4 GT_5 Year  /// 
	|| rarea GT_5 GT_6 Year  /// 
	|| rarea GT_6 GT_7 Year  /// 
	|| rarea GT_7 GT_9 Year  /// 
	|| rarea GT_9 GT_10 Year  /// 
    ||, legend(cols(3) size(*0.80) pos(6) order(1 "Seguridad Pública" 2 "Servicios Públicos" 3 "Defensa" 4 "Vivienda" 5 "Cultura" 6 "Salud" 7 "Educación" 8 "Asuntos económicos" 9 "Medioambiente")) /// 
     xla(2013(1)2022) ytitle(Porcentaje del Gasto Total)
	 graph export "$graphs/Partidas como porcentaje del Gasto Total - 2 A.pdf", replace
	 
restore




******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************




preserve
drop if A=="703"
keep if A1=="703"
replace Partida="Otro" if Partida=="Serviciosdeproteccióncontraincendios"
replace Partida="Otro" if Partida=="Ordenpúblicoyseguridadn.e.p."
drop Pesos22_A Aumento
replace Pesos22_ = Pesos22_ / 1000000
collapse (sum) PIB_ GT_ Pesos_ Pesos22_, by(Year Partida)
gen X=1 if Partida=="Serviciosdepolicía"
replace X=2 if Partida=="Tribunalesdejusticia"
replace X=3 if Partida=="Prisiones"
replace X=4 if Partida=="Otro"
drop Partida
reshape wide PIB_ GT_ Pesos_ Pesos22_, i(Year) j(X)



*Apiladas
graph bar (sum) PIB_*, over(Year) stack legend(order(1 "Servicios de policía" 2 "Tribunales de justicia" 3 "Prisiones" 4 "Otro")) blabel(bar, color(white) position(base) format(%3.1f)) ytitle(Porcentaje del PIB) 
graph export "$graphs/Gasto en Seguridad por ítem como porcentaje del PIB.pdf", replace


graph bar (sum) GT_*, over(Year) stack legend(order(1 "Servicios de policía" 2 "Tribunales de justicia" 3 "Prisiones" 4 "Otro")) blabel(bar, color(white) position(base) format(%3.1f)) ytitle(Porcentaje del Gasto Total)
graph export "$graphs/Gasto en Seguridad por ítem como porcentaje del Gasto Total.pdf", replace


graph bar (sum) Pesos22_*, over(Year) stack legend(order(1 "Servicios de policía" 2 "Tribunales de justicia" 3 "Prisiones" 4 "Otro")) blabel(bar, color(white) position(base) format(%3.1f)) ytitle(Gasto en millones de millones de pesos 2022)
graph export "$graphs/Gasto en Seguridad en pesos 2022.pdf", replace

*Apiladas al 100
graph bar (sum) PIB_*, over(Year) stack legend(order(1 "Servicios de policía" 2 "Tribunales de justicia" 3 "Prisiones" 4 "Otro")) blabel(bar, color(white) position(inside) format(%3.0f)) ytitle(Porcentaje del PIB) percent 

graph bar (sum) GT_*, over(Year) stack legend(order(1 "Servicios de policía" 2 "Tribunales de justicia" 3 "Prisiones" 4 "Otro")) blabel(bar, color(white) position(base) format(%3.0f)) ytitle(Porcentaje del Gasto Total) percent 
graph export "$graphs/Gasto en Seguridad por ítem como porcentaje del Gasto Total Normalizado.pdf", replace

graph bar (sum) Pesos22_*, over(Year) stack legend(order(1 "Servicios de policía" 2 "Tribunales de justicia" 3 "Prisiones" 4 "Otro")) blabel(bar, color(white) position(base) format(%3.0f)) ytitle(Gasto en pesos 2022) percent 
graph export "$graphs/Gasto en Seguridad en pesos 2022 Normalizado.pdf", replace


restore




******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************



use Dipres_SP, replace
drop A A1 Pesos_ Pesos22_ Pesos22_A Aumento
replace Partida = subinstr(Partida, " ","", .)
replace Partida="Chile" if Partida=="Ordenpúblicoyseguridad" 
keep if Partida=="Chile"
rename Partida Países
tempfile B1
save `B1', replace

import excel "/Users/raulfugellie/Dropbox/Seguridad Pública/Fuentes de Datos/UE/PO y S PIB.xlsx", sheet("Sheet 1") cellrange(A12:Z45) firstrow clear

drop C E G I K M O Q S U W Y
rename B PIB_2009
rename D PIB_2010
rename F PIB_2011
rename H PIB_2012
rename J PIB_2013
rename L PIB_2014
rename N PIB_2015
rename P PIB_2016
rename R PIB_2017
rename T PIB_2018
rename V PIB_2019
rename X PIB_2020
rename Z PIB_2021
rename GEOLabels Países
replace Países="Germany" if Países=="Germany (until 1990 former territory of the FRG)"
reshape long PIB_, i(Países) j(Year)
tempfile B2
save `B2', replace

import excel "/Users/raulfugellie/Downloads/API_NY.GDP.PCAP.PP.CD_DS2_es_excel_v2_5552700.xls", sheet("Data") cellrange(A4:BO270) firstrow clear

keep if CountryName=="Chile" | CountryName=="Bélgica" | CountryName=="Bulgaria" | CountryName=="Austria" | CountryName=="Croacia" | CountryName=="Chipre" | CountryName=="República Checa" | CountryName=="Dinamarca" | CountryName=="Estonia" | CountryName=="Finlandia" | CountryName=="Alemania" | CountryName=="Grecia" | CountryName=="Hungría" | CountryName=="Islandia" | CountryName=="Irlanda" | CountryName=="Italia" | CountryName=="Letonia" | CountryName=="Lituania" | CountryName=="Luxemburgo" | CountryName=="Malta" | CountryName=="Países Bajos" | CountryName=="Noruega" | CountryName=="Polonia" | CountryName=="Portugal" | CountryName=="Rumania" | CountryName=="República Eslovaca" | CountryName=="Eslovenia" | CountryName=="España" | CountryName=="Suecia" | CountryName=="Suiza" | CountryName=="Francia" | CountryName=="Zona del Euro" | CountryName=="Unión Europea" | CountryName=="Argentina" | CountryName=="Brasil" | CountryName=="Costa Rica" | CountryName=="El Salvador" | CountryName=="Guatemala" | CountryName=="Australia" | CountryName=="Colombia" | CountryName=="Reino Unido" | CountryName=="Japón" | CountryName=="Corea, República de" | CountryName=="Estados Unidos" | CountryName=="Israel"

keep CountryName CountryCode BB BC BD BE BF BG BH BI BJ BK BL BM BN

replace CountryName="Belgium" if CountryName=="Bélgica"
replace CountryName="Croatia" if CountryName=="Croacia"
replace CountryName="Cyprus" if CountryName=="Chipre"
replace CountryName="Czechia" if CountryName=="República Checa"
replace CountryName="Denmark" if CountryName=="Dinamarca"
replace CountryName="Finland" if CountryName=="Finlandia" 
replace CountryName="Germany" if CountryName=="Alemania"
replace CountryName="Greece" if CountryName=="Grecia"
replace CountryName="Hungary" if CountryName=="Hungría"
replace CountryName="Iceland" if CountryName=="Islandia"
replace CountryName="Ireland" if CountryName=="Irlanda"
replace CountryName="Italy" if CountryName=="Italia"
replace CountryName="Latvia" if CountryName=="Letonia"
replace CountryName="Lithuania" if CountryName=="Lituania"
replace CountryName="Luxembourg" if CountryName=="Luxemburgo"
replace CountryName="Netherlands" if CountryName=="Países Bajos"
replace CountryName="Norway" if CountryName=="Noruega"
replace CountryName="Poland" if CountryName=="Polonia"
replace CountryName="Romania" if CountryName=="Rumania"
replace CountryName="Slovakia" if CountryName=="República Eslovaca"
replace CountryName="Slovenia" if CountryName=="Eslovenia"
replace CountryName="Spain"  if CountryName=="España"
replace CountryName="Sweden" if CountryName=="Suecia"
replace CountryName="Switzerland" if CountryName=="Suiza"
replace CountryName="France" if CountryName=="Francia"
replace CountryName="Euro area - 19 countries  (2015-2022)" if CountryName=="Zona del Euro"
replace CountryName="European Union - 27 countries (from 2020)" if CountryName=="Unión Europea"


rename CountryName Países
rename BB PIB_per2009
rename BC PIB_per2010
rename BD PIB_per2011
rename BE PIB_per2012
rename BF PIB_per2013
rename BG PIB_per2014
rename BH PIB_per2015
rename BI PIB_per2016
rename BJ PIB_per2017
rename BK PIB_per2018
rename BL PIB_per2019
rename BM PIB_per2020
rename BN PIB_per2021

reshape long PIB_per, i(Países CountryCode) j(Year)
tempfile B3
save `B3', replace


import excel "/Users/raulfugellie/Dropbox/Seguridad Pública/Fuentes de Datos/Dipres/Expenditure LA/Functional_Expenditures_COFOG PIB Argentina.xlsx", sheet("Table 7_ COFOG- Time Series") cellrange(B9:J34) clear
rename B Partida
rename C PIB_2014
rename D PIB_2015
rename E PIB_2016
rename F PIB_2017
rename G PIB_2018
rename H PIB_2019
rename I PIB_2020
rename J PIB_2021
gen Países="Argentina"

tempfile A1
save `A1', replace

import excel "/Users/raulfugellie/Dropbox/Seguridad Pública/Fuentes de Datos/Dipres/Expenditure LA/Functional_Expenditures_COFOG PIB Brasil", sheet("Table 7_ COFOG- Time Series") cellrange(B9:N34) clear
rename B Partida
rename C PIB_2010
rename D PIB_2011
rename E PIB_2012
rename F PIB_2013
rename G PIB_2014
rename H PIB_2015
rename I PIB_2016
rename J PIB_2017
rename K PIB_2018
rename L PIB_2019
rename M PIB_2020
rename N PIB_2021
gen Países="Brasil"

tempfile A2
save `A2', replace

import excel "/Users/raulfugellie/Dropbox/Seguridad Pública/Fuentes de Datos/Dipres/Expenditure LA/Functional_Expenditures_COFOG PIB Costa Rica", sheet("Table 7_ COFOG- Time Series") cellrange(B9:S34) clear
rename B Partida
drop C D E F G H I J
rename K PIB_2013
rename L PIB_2014
rename M PIB_2015
rename N PIB_2016
rename O PIB_2017
rename P PIB_2018
rename Q PIB_2019
rename R PIB_2020
rename S PIB_2021
gen Países="Costa Rica"

tempfile A3
save `A3', replace

import excel "/Users/raulfugellie/Dropbox/Seguridad Pública/Fuentes de Datos/Dipres/Expenditure LA/Functional_Expenditures_COFOG PIB El Salvador", sheet("Table 7_ COFOG- Time Series") cellrange(B9:S34) clear
rename B Partida
drop C D E F
rename G PIB_2009
rename H PIB_2010
rename I PIB_2011
rename J PIB_2012
rename K PIB_2013
rename L PIB_2014
rename M PIB_2015
rename N PIB_2016
rename O PIB_2017
rename P PIB_2018
rename Q PIB_2019
rename R PIB_2020
rename S PIB_2021
gen Países="El Salvador"

tempfile A4
save `A4', replace

import excel "/Users/raulfugellie/Dropbox/Seguridad Pública/Fuentes de Datos/Dipres/Expenditure LA/Functional_Expenditures_COFOG PIB Guatemala", sheet("Table 7_ COFOG- Time Series") cellrange(B9:J34) clear
rename B Partida
rename C PIB_2014
rename D PIB_2015
rename E PIB_2016
rename F PIB_2017
rename G PIB_2018
rename H PIB_2019
rename I PIB_2020
rename J PIB_2021
gen Países="Guatemala"

tempfile A5
save `A5', replace


use `A1', clear
append using `A2'
append using `A3'
append using `A4'
append using `A5'
keep if Partida=="Public order & safety"
drop Partida
reshape long PIB_, i(Países) j(Year)
destring PIB_, replace
tempfile A6
save `A6', replace



import excel "/Users/raulfugellie/Dropbox/Seguridad Pública/Fuentes de Datos/Dipres/Expenditure LA/Functional_Expenditures_COFOG PorcentajeGT Argentina.xlsx", sheet("Table 7_ COFOG- Time Series") cellrange(B9:J34) clear
rename B Partida
rename C GT_2014
rename D GT_2015
rename E GT_2016
rename F GT_2017
rename G GT_2018
rename H GT_2019
rename I GT_2020
rename J GT_2021
gen Países="Argentina"

tempfile A11
save `A11', replace

import excel "/Users/raulfugellie/Dropbox/Seguridad Pública/Fuentes de Datos/Dipres/Expenditure LA/Functional_Expenditures_COFOG PorcentajeGT Brasil", sheet("Table 7_ COFOG- Time Series") cellrange(B9:N34) clear
rename B Partida
rename C GT_2010
rename D GT_2011
rename E GT_2012
rename F GT_2013
rename G GT_2014
rename H GT_2015
rename I GT_2016
rename J GT_2017
rename K GT_2018
rename L GT_2019
rename M GT_2020
rename N GT_2021
gen Países="Brasil"

tempfile A22
save `A22', replace

import excel "/Users/raulfugellie/Dropbox/Seguridad Pública/Fuentes de Datos/Dipres/Expenditure LA/Functional_Expenditures_COFOG PorcentajeGT Costa Rica", sheet("Table 7_ COFOG- Time Series") cellrange(B9:S34) clear
rename B Partida
drop C D E F G H I J
rename K GT_2013
rename L GT_2014
rename M GT_2015
rename N GT_2016
rename O GT_2017
rename P GT_2018
rename Q GT_2019
rename R GT_2020
rename S GT_2021
gen Países="Costa Rica"

tempfile A33
save `A33', replace

import excel "/Users/raulfugellie/Dropbox/Seguridad Pública/Fuentes de Datos/Dipres/Expenditure LA/Functional_Expenditures_COFOG PorcentajeGT El Salvador", sheet("Table 7_ COFOG- Time Series") cellrange(B9:S34) clear
rename B Partida
drop C D E F
rename G GT_2009
rename H GT_2010
rename I GT_2011
rename J GT_2012
rename K GT_2013
rename L GT_2014
rename M GT_2015
rename N GT_2016
rename O GT_2017
rename P GT_2018
rename Q GT_2019
rename R GT_2020
rename S GT_2021
gen Países="El Salvador"

tempfile A44
save `A44', replace

import excel "/Users/raulfugellie/Dropbox/Seguridad Pública/Fuentes de Datos/Dipres/Expenditure LA/Functional_Expenditures_COFOG PorcentajeGT Guatemala", sheet("Table 7_ COFOG- Time Series") cellrange(B9:J34) clear
rename B Partida
rename C GT_2014
rename D GT_2015
rename E GT_2016
rename F GT_2017
rename G GT_2018
rename H GT_2019
rename I GT_2020
rename J GT_2021
gen Países="Guatemala"

tempfile A55
save `A55', replace


use `A11', clear
append using `A22'
append using `A33'
append using `A44'
append using `A55'
keep if Partida=="Public order & safety"
drop Partida
reshape long GT_, i(Países) j(Year)
destring GT_, replace
tempfile A66
save `A66', replace

merge 1:1 Países Year using `A6'
drop _merge 

tempfile A7
save `A7', replace

import delimited "/Users/raulfugellie/Downloads/DP_LIVE_14072023031156216.csv", clear
drop flagcodes frequency measure indicator
keep if subject=="PUBORD"
keep if location=="OAVG" | location=="OECD" | location=="COL" 
drop subject
rename location CountryCode
rename time Year
rename value GT_
gen Países="Colombia" if CountryCode=="COL"
replace Países="OECD" if CountryCode=="OECD"
replace Países="OAVG" if CountryCode=="OAVG"
tempfile A8
save `A8', replace


import delimited "/Users/raulfugellie/Downloads/DP_LIVE_09072023042236865.csv", clear
drop flagcodes frequency measure indicator
keep if subject=="PUBORD"
keep if location=="USA" | location=="COL" | location=="ISR" | location=="KOR" | location=="GBR" | location=="JPN" | location=="CRI" | location=="CHL" | location=="AUS"
drop subject
rename location CountryCode
rename time Year
rename value PIB_
gen Países="Estados Unidos" if CountryCode=="USA"
replace Países="Colombia" if CountryCode=="COL"
replace Países="Israel" if CountryCode=="ISR"
replace Países="Corea, República de" if CountryCode=="KOR"
replace Países="Reino Unido" if CountryCode=="GBR"
replace Países="Japón" if CountryCode=="JPN"
replace Países="Costa Rica" if CountryCode=="CRI"
replace Países="Chile" if CountryCode=="CHL"
replace Países="Australia" if CountryCode=="AUS"
tempfile A9
save `A9', replace


keep if Países=="Chile" 
gen W=1
tempfile A100
save `A100', replace


import excel "/Users/raulfugellie/Dropbox/Seguridad Pública/Fuentes de Datos/UE/PO y S GT.xlsx", sheet("Sheet 1") cellrange(A12:Z45) firstrow clear

drop C E G I K M O Q S U W Y
rename B GT_2009
rename D GT_2010
rename F GT_2011
rename H GT_2012
rename J GT_2013
rename L GT_2014
rename N GT_2015
rename P GT_2016
rename R GT_2017
rename T GT_2018
rename V GT_2019
rename X GT_2020
rename Z GT_2021
rename GEOLabels Países
replace Países="Germany" if Países=="Germany (until 1990 former territory of the FRG)"
reshape long GT_, i(Países) j(Year)
tempfile A10
save `A10', replace



merge 1:1 Países Year using `B2'
drop _merge
append using `B1'
append using `A7'
append using `A8'
append using `A9'
append using `A100'
merge m:1 Países Year using `B3'
drop _merge

drop if Year==2022
drop if Países=="Euro area – 20 countries (from 2023)"
gen PIB_per_PPA_GS= PIB_per*(PIB_/100)
keep if Year>2012

preserve
gen dif=PIB_A-PIB_
drop if dif==.
keep Países Year dif
tempfile T1
save `T1', replace
restore


merge m:1 Países Year using `T1'
drop _merge
replace PIB_A=PIB_ + dif
gen PIB_per_PPA_GS_A= PIB_per*(PIB_A/100)



preserve
drop if Países=="Chile" & CountryCode==""
drop if Países=="Costa Rica" & CountryCode==""
replace PIB_per_PPA_GS=PIB_per_PPA_GS_A if W==1
replace Países="Chile2.0" if W==1
drop if PIB_per_PPA_GS==.
keep if Year==2021
twoway (scatter PIB_per_PPA_GS PIB_per, mlabel(Países) msymbol(circle_hollow) xline(28367.936) xtitle(PIB per cápita PPA 2021) ytitle(Gasto en Seguridad per cápita PPA 2021), by(foreign,  graphregion(fcolor(white)))) 
graph export "$graphs/Scatter.pdf", replace

replace PIB_=PIB_A if W==1
twoway (scatter PIB_ PIB_per, mlabel(Países) msymbol(circle_hollow) xline(28367.936) xtitle(PIB per cápita PPA 2021) ytitle(Gasto en Seguridad como porcentaje del PIB 2021), by(foreign,  graphregion(fcolor(white)))) 
graph export "$graphs/Scatter2.pdf", replace
restore



*twoway 	(line PIB_ Year if Países=="Chile" , lcolor(green) lwidth(thick))	///
		*(line PIB_ Year if Países=="Belgium" , lcolor(navy)) ///
		*(line PIB_ Year if Países=="Bulgaria" , lcolor(blue))	///
		*(line PIB_ Year if Países=="Austria" , lcolor(yellow))	///
		*(line PIB_ Year if Países=="Croatia" , lcolor(gs8)) ///
		*(line PIB_ Year if Países=="Cyprus" , lcolor(sand)) ///
		*(line PIB_ Year if Países=="Czechia" , lcolor(orange)) ///
		*(line PIB_ Year if Países=="Denmark" , lcolor(brown)) ///
		*(line PIB_ Year if Países=="Estonia" , lcolor(olive)) ///
		*(line PIB_ Year if Países=="Finland" , lcolor(red))	///
		*(line PIB_ Year if Países=="Germany" , lcolor(cranberry))	///
		*(line PIB_ Year if Países=="Greece" , lcolor(cyan))	///
		*(line PIB_ Year if Países=="Hungary" , lcolor(emerald)) ///
		*(line PIB_ Year if Países=="Iceland" , lcolor(gold)) ///
		*(line PIB_ Year if Países=="Ireland" , lcolor(lavender)) ///
		*(line PIB_ Year if Países=="Italy" , lcolor(lime)) ///
		*(line PIB_ Year if Países=="Latvia" , lcolor(midblue)) ///
		*(line PIB_ Year if Países=="Lithuania" , lcolor(mint))	///
		*(line PIB_ Year if Países=="Luxembourg" , lcolor(pink)) ///
		*(line PIB_ Year if Países=="Malta" , lcolor(sienna)) ///
		*(line PIB_ Year if Países=="Netherlands" , lcolor(teal)) ///
		*(line PIB_ Year if Países=="Norway" , lcolor(ebblue))	///
		*(line PIB_ Year if Países=="Poland" , lcolor(eltgreen))	///
		*(line PIB_ Year if Países=="Portugal" , lcolor(maroon))	///
		*(line PIB_ Year if Países=="Romania" , lcolor(magenta)) ///
		*(line PIB_ Year if Países=="Slovakia" , lcolor(khaki)) ///
		*(line PIB_ Year if Países=="Slovenia" , lcolor(eggshell)) ///
		*(line PIB_ Year if Países=="Spain" , lcolor(forest_green)) ///
		*(line PIB_ Year if Países=="Sweden" , lcolor(bluishgray)) ///
		*(line PIB_ Year if Países=="Switzerland" , lcolor(gs15))	///
		*(line PIB_ Year if Países=="France" , lcolor(purple)),	///
		*graphregion(color(white)) xla(2009(1)2021) ytitle("Gasto Público como porcentaje del PIB ")	///
		*legend(cols(7) size(*0.55) pos(6) order(1 "Chile" 2 "Bélgica" 3 "Bulgaria" 4 "Austria" 5 "Croacia" 6 "Chipre" 7 "R.Checa" 8 "Dinamarca" 9 "Estonia" 10 "Finlandia" 11 "Alemania" 12 "Grecia" 13 "Hungría" 14 "Islandia" 15 "Irlanda" 16 "Italia" 17 "Letonia" 18 "Lituania" 19 "Luxemburgo" 20 "Malta" 21 "Países Bajos" 22 "Noruega" 23 "Polonia" 24 "Portugal" 25 "Rumania" 26 "Eslovaquia" 27 "Eslovenia" 28 "España" 29 "Suecia" 30 "Suiza" 31 "Francia")) xline(2010 2014 2018 2022)
		*graph export "$graphs/Gasto en Seguridad como porcentaje del PIB.pdf", replace

		
***Gris***

preserve
keep if Year>2012
drop if Países=="Chile" & CountryCode==""
twoway 	(line PIB_ Year if Países=="France" , lcolor(gs12))	///
		(line PIB_ Year if Países=="Belgium" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Bulgaria" , lcolor(gs12))	///
		(line PIB_ Year if Países=="Austria" , lcolor(gs12))	///
		(line PIB_ Year if Países=="Croatia" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Cyprus" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Czechia" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Denmark" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Estonia" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Finland" , lcolor(gs12))	///
		(line PIB_ Year if Países=="Germany" , lcolor(gs12))	///
		(line PIB_ Year if Países=="Greece" , lcolor(gs12))	///
		(line PIB_ Year if Países=="Hungary" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Iceland" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Ireland" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Italy" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Latvia" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Lithuania" , lcolor(gs12))	///
		(line PIB_ Year if Países=="Luxembourg" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Malta" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Netherlands" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Norway" , lcolor(gs12))	///
		(line PIB_ Year if Países=="Poland" , lcolor(gs12))	///
		(line PIB_ Year if Países=="Portugal" , lcolor(gs12))	///
		(line PIB_ Year if Países=="Romania" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Slovakia" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Slovenia" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Spain" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Sweden" , lcolor(gs12)) ///
		(line PIB_ Year if Países=="Switzerland" , lcolor(gs12))	///
		(line PIB_ Year if Países=="Chile" , lcolor(green) lwidth(thick))	///
		(line PIB_A Year if Países=="Chile" , lcolor(green) lwidth(thick) lpattern(dash)) 	///
		(line PIB_ Year if Países=="European Union - 27 countries (from 2020)" , lcolor(gold) lwidth(thick)) 	///
		(line PIB_ Year if Países=="Euro area - 19 countries  (2015-2022)" , lcolor(midblue) lwidth(thick)),	///
		graphregion(color(white)) xla(2013(1)2021) ytitle("Gasto Público en Seguridad como porcentaje del PIB ")	///
		legend(cols(7) size(*0.55) pos(6) order(31 "Chile" 32 "Chile + Aumento" 33 "UE" 34 "Zona Euro")) xline(2014 2018 2022, lpattern(dash))
		graph export "$graphs/Gasto en Seguridad como porcentaje del PIB.pdf", replace		

restore

preserve

***Gris***
keep if Year>2012
drop if Países=="Chile" & CountryCode=="CHL"
twoway 	(line GT_ Year if Países=="France" , lcolor(gs12))	///
		(line GT_ Year if Países=="Belgium" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Bulgaria" , lcolor(gs12))	///
		(line GT_ Year if Países=="Austria" , lcolor(gs12))	///
		(line GT_ Year if Países=="Croatia" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Cyprus" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Czechia" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Denmark" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Estonia" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Finland" , lcolor(gs12))	///
		(line GT_ Year if Países=="Germany" , lcolor(gs12))	///
		(line GT_ Year if Países=="Greece" , lcolor(gs12))	///
		(line GT_ Year if Países=="Hungary" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Iceland" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Ireland" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Italy" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Latvia" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Lithuania" , lcolor(gs12))	///
		(line GT_ Year if Países=="Luxembourg" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Malta" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Netherlands" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Norway" , lcolor(gs12))	///
		(line GT_ Year if Países=="Poland" , lcolor(gs12))	///
		(line GT_ Year if Países=="Portugal" , lcolor(gs12))	///
		(line GT_ Year if Países=="Romania" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Slovakia" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Slovenia" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Spain" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Sweden" , lcolor(gs12)) ///
		(line GT_ Year if Países=="Switzerland" , lcolor(gs12))	///
		(line GT_ Year if Países=="Chile" , lcolor(green) lwidth(thick))	///
		(line GT_A Year if Países=="Chile" , lcolor(green) lwidth(thick) lpattern(dash))	///
		(line GT_ Year if Países=="European Union - 27 countries (from 2020)" , lcolor(gold) lwidth(thick)) 	///
		(line GT_ Year if Países=="Euro area - 19 countries  (2015-2022)" , lcolor(midblue) lwidth(thick)),	///
		graphregion(color(white)) xla(2013(1)2021) ytitle("Gasto Público en Seguridad como porcentaje del GT")	///
		legend(cols(6) size(*0.45) pos(6) order(31 "Chile" 32 "Chile + Aumento" 33 "UE" 34 "Zona Euro")) legend(size(small)) xline(2014 2018 2022, lpattern(dash))
		graph export "$graphs/Gasto en Seguridad como porcentaje del Gasto Total.pdf", replace
		

restore

preserve

***Gris***
keep if Year>2012
drop if Países=="Chile" & CountryCode==""
twoway 	(line PIB_per_PPA_GS Year if Países=="France" , lcolor(gs12))	///
		(line PIB_per_PPA_GS Year if Países=="Belgium" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Bulgaria" , lcolor(gs12))	///
		(line PIB_per_PPA_GS Year if Países=="Austria" , lcolor(gs12))	///
		(line PIB_per_PPA_GS Year if Países=="Croatia" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Cyprus" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Czechia" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Denmark" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Estonia" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Finland" , lcolor(gs12))	///
		(line PIB_per_PPA_GS Year if Países=="Germany" , lcolor(gs12))	///
		(line PIB_per_PPA_GS Year if Países=="Greece" , lcolor(gs12))	///
		(line PIB_per_PPA_GS Year if Países=="Hungary" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Iceland" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Ireland" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Italy" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Latvia" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Lithuania" , lcolor(gs12))	///
		(line PIB_per_PPA_GS Year if Países=="Luxembourg" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Malta" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Netherlands" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Norway" , lcolor(gs12))	///
		(line PIB_per_PPA_GS Year if Países=="Poland" , lcolor(gs12))	///
		(line PIB_per_PPA_GS Year if Países=="Portugal" , lcolor(gs12))	///
		(line PIB_per_PPA_GS Year if Países=="Romania" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Slovakia" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Slovenia" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Spain" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Sweden" , lcolor(gs12)) ///
		(line PIB_per_PPA_GS Year if Países=="Switzerland" , lcolor(gs12))	///
		(line PIB_per_PPA_GS Year if Países=="Chile" , lcolor(green) lwidth(thick))	///
		(line PIB_per_PPA_GS_A Year if Países=="Chile" , lcolor(green) lwidth(thick) lpattern(dash))	///
		(line PIB_per_PPA_GS Year if Países=="European Union - 27 countries (from 2020)" , lcolor(gold) lwidth(thick)) 	///
		(line PIB_per_PPA_GS Year if Países=="Euro area - 19 countries  (2015-2022)" , lcolor(midblue) lwidth(thick)),	///
		graphregion(color(white)) xla(2013(1)2021)  ytitle("Gasto_per_cápita PPA")	yscale(titlegap(*+4)) ///
		legend(cols(6) size(*0.45) pos(6) order(31 "Chile" 32 "Chile + Aumento" 33 "UE" 34 "Zona Euro")) legend(size(small)) xline(2014 2018 2022, lpattern(dash))
		graph export "$graphs/Gasto_per_cápita PPA.pdf", replace
		
restore
		
		

		
		
		
*******************************************************************		
*******************************************************************	
		
***************************************	
***************************************	
**************AMERICANOS***************
***************************************	
***************************************	

*******************************************************************	
*******************************************************************	


preserve
drop if Países=="Chile" & CountryCode=="CHL"
drop if Países=="Costa Rica" & CountryCode=="CRI"
drop if Países=="Colombia" & GT_==.
twoway 	(line GT_ Year if Países=="Chile" , lcolor(green) lwidth(thick)) 	///
		(line GT_A Year if Países=="Chile" , lcolor(green) lwidth(thick) lpattern(dash)) 	///
		(line GT_ Year if Países=="OECD" , lcolor(purple) lwidth(thick)) ///
		(line GT_ Year if Países=="OAVG" , lcolor(orange) lwidth(thick)) ///
		(line GT_ Year if Países=="Argentina" , lcolor(brown)) ///
		(line GT_ Year if Países=="Brasil" , lcolor(red))	///
		(line GT_ Year if Países=="El Salvador" , lcolor(cranberry))	///
		(line GT_ Year if Países=="Guatemala" , lcolor(lavender)) ///
		(line GT_ Year if Países=="Colombia" , lcolor(maroon)) ///
		(line GT_ Year if Países=="Costa Rica" , lcolor(lime)),	///
		graphregion(color(white)) xla(2013(1)2021) ytitle("Gasto en Seguridad como % del GT")	///
		legend(order(1 "Chile" 2 "Chile + Aumento" 3 "OECD" 4 "OAVG" 5 "Argentina" 6 "Brasil" 7 "El Salvador" 8 "Guatemala" 9 "Colombia" 10 "Costa Rica"))  xline(2014 2018 2022, lpattern(dash))
		graph export "$graphs/Gasto en Seguridad como porcentaje del Gasto Total AMERICANOS.pdf", replace
		
restore	
	
preserve
drop if Países=="Chile" & CountryCode==""
drop if Países=="Costa Rica" & CountryCode==""
drop if Países=="Colombia" & PIB_==.
twoway 	(line PIB_ Year if Países=="Chile" , lcolor(green) lwidth(thick)) 	///
		(line PIB_A Year if Países=="Chile" , lcolor(green) lwidth(thick) lpattern(dash)) 	///
		(line PIB_ Year if Países=="Estados Unidos" , lcolor(gold) lwidth(thick)) 	///
		(line PIB_ Year if Países=="Argentina" , lcolor(brown)) ///
		(line PIB_ Year if Países=="Brasil" , lcolor(red))	///
		(line PIB_ Year if Países=="El Salvador" , lcolor(cranberry))	///
		(line PIB_ Year if Países=="Guatemala" , lcolor(lavender)) ///
		(line PIB_ Year if Países=="Colombia" , lcolor(maroon)) ///
		(line PIB_ Year if Países=="Costa Rica" , lcolor(lime)),	///
		graphregion(color(white)) xla(2013(1)2021) ytitle("Gasto en Seguridad como % del PIB ")	///
		legend(order(1 "Chile" 2 "Chile + Aumento" 3 "Estados Unidos" 4 "Argentina" 5 "Brasil" 6 "El Salvador" 7 "Guatemala" 8 "Colombia"  9 "Costa Rica"))  xline(2014 2018 2022, lpattern(dash))
		graph export "$graphs/Gasto en Seguridad como porcentaje del PIB AMERICANOS.pdf", replace
		
		
		

twoway 	(line PIB_per_PPA_GS Year if Países=="Chile" , lcolor(green) lwidth(thick)) 	///
		(line PIB_per_PPA_GS_A Year if Países=="Chile" , lcolor(green) lwidth(thick) lpattern(dash)) 	///
		(line PIB_per_PPA_GS Year if Países=="Estados Unidos" , lcolor(gold) lwidth(thick)) ///
		(line PIB_per_PPA_GS Year if Países=="Argentina" , lcolor(brown)) ///
		(line PIB_per_PPA_GS Year if Países=="Brasil" , lcolor(red))	///
		(line PIB_per_PPA_GS Year if Países=="El Salvador" , lcolor(cranberry))	///
		(line PIB_per_PPA_GS Year if Países=="Guatemala" , lcolor(lavender)) ///
		(line PIB_per_PPA_GS Year if Países=="Colombia" , lcolor(maroon)) ///
		(line PIB_per_PPA_GS Year if Países=="Costa Rica" , lcolor(lime)),	///
		graphregion(color(white)) xla(2013(1)2021) ytitle("Gasto_per_cápita PPA")	///
		legend(order(1 "Chile" 2 "Chile + Aumento" 3 "Estados Unidos" 4 "Argentina" 5 "Brasil" 6 "El Salvador" 7 "Guatemala" 8 "Colombia"  9 "Costa Rica"))  xline(2014 2018 2022, lpattern(dash))
		graph export "$graphs/Gasto_per_cápita PPA AMERICANOS.pdf", replace
		
restore
	

******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************


use Dipres_SP, replace
keep if A=="7031"  | A=="7033" | A=="7034" 
drop A A1 GT_ Pesos_ Pesos22_ Aumento Pesos22_A
gen País="Chile"
tempfile A1
save `A1', replace
import excel "/Users/raulfugellie/Downloads/gov_10a_exp__custom_6827692_spreadsheet.xlsx", sheet("Sheet 1") cellrange(A13:AA45) clear
drop C E G I K M O Q S U W Y AA
rename B PIB_2009
rename D PIB_2010
rename F PIB_2011
rename H PIB_2012
rename J PIB_2013
rename L PIB_2014
rename N PIB_2015
rename P PIB_2016
rename R PIB_2017
rename T PIB_2018
rename V PIB_2019
rename X PIB_2020
rename Z PIB_2021
rename A País
replace País="Germany" if País=="Germany (until 1990 former territory of the FRG)"
reshape long PIB_, i(País) j(Year)
destring PIB_, replace
gen Partida="Serviciosdepolicía"
tempfile A2
save `A2', replace
import excel "/Users/raulfugellie/Downloads/gov_10a_exp__custom_6827692_spreadsheet.xlsx", sheet("Sheet 3") cellrange(A13:AA45) clear
drop C E G I K M O Q S U W Y AA
rename B PIB_2009
rename D PIB_2010
rename F PIB_2011
rename H PIB_2012
rename J PIB_2013
rename L PIB_2014
rename N PIB_2015
rename P PIB_2016
rename R PIB_2017
rename T PIB_2018
rename V PIB_2019
rename X PIB_2020
rename Z PIB_2021
rename A País
replace País="Germany" if País=="Germany (until 1990 former territory of the FRG)"
reshape long PIB_, i(País) j(Year)
gen Partida="Tribunalesdejusticia"
destring PIB_, replace
tempfile A3
save `A3', replace
import excel "/Users/raulfugellie/Downloads/gov_10a_exp__custom_6827692_spreadsheet.xlsx", sheet("Sheet 4") cellrange(A13:AA45) clear
drop C E G I K M O Q S U W Y AA
rename B PIB_2009
rename D PIB_2010
rename F PIB_2011
rename H PIB_2012
rename J PIB_2013
rename L PIB_2014
rename N PIB_2015
rename P PIB_2016
rename R PIB_2017
rename T PIB_2018
rename V PIB_2019
rename X PIB_2020
rename Z PIB_2021
rename A País
replace País="Germany" if País=="Germany (until 1990 former territory of the FRG)"
reshape long PIB_, i(País) j(Year)
gen Partida="Prisiones"
destring PIB_, replace
tempfile A4
save `A4', replace


append using `A1'
append using `A2'
append using `A3'



preserve

keep if Partida=="Prisiones"
***Gris***

keep if Year>2012
keep if Year<2022
twoway 	(line PIB_ Year if País=="Belgium" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Bulgaria" , lcolor(gs12))	///
		(line PIB_ Year if País=="Croatia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Cyprus" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Czechia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Denmark" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Estonia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Finland" , lcolor(gs12))	///
		(line PIB_ Year if País=="Greece" , lcolor(gs12))	///
		(line PIB_ Year if País=="Hungary" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Iceland" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Ireland" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Italy" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Latvia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Lithuania" , lcolor(gs12))	///
		(line PIB_ Year if País=="Luxembourg" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Malta" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Netherlands" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Norway" , lcolor(gs12))	///
		(line PIB_ Year if País=="Poland" , lcolor(gs12))	///
		(line PIB_ Year if País=="Portugal" , lcolor(gs12))	///
		(line PIB_ Year if País=="Romania" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Slovakia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Slovenia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Spain" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Sweden" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Switzerland" , lcolor(gs12))	///
		(line PIB_ Year if País=="France" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Chile" , lcolor(green) lwidth(thick))	///
		(line PIB_ Year if País=="European Union - 27 countries (from 2020)" , lcolor(gold) lwidth(thick)) 	///
		(line PIB_ Year if País=="Euro area - 19 countries  (2015-2022)" , lcolor(midblue) lwidth(thick)),	///
		graphregion(color(white)) xla(2013(1)2021) ytitle("Gasto en Prisiones como porcentaje del PIB ")	///
		legend(cols(7) size(*0.55) pos(6) order(29 "Chile" 30 "UE" 31 "Zona Euro")) ylabel(0(0.1)1) xline(2014 2018 2022, lpattern(dash))
		graph export "$graphs/Gasto en Prisiones como porcentaje del PIB.pdf", replace	

keep if País=="European Union - 27 countries (from 2020)" | País=="Euro area - 19 countries  (2015-2022)" | País=="Chile"
replace País="UE" if País=="European Union - 27 countries (from 2020)"
replace País="Zona Euro" if País=="Euro area - 19 countries  (2015-2022)"

graph hbar (mean) PIB_ , over(País) ytitle("Porcentaje del PIB") title("Inversión en prisiones promedio 2013-2021")	
	graph export "$graphs/Gasto en Prisiones como porcentaje del PIB A.pdf", replace	

restore 


preserve

keep if Partida=="Serviciosdepolicía"
***Gris***

keep if Year>2012
keep if Year<2022
twoway 	(line PIB_ Year if País=="Belgium" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Bulgaria" , lcolor(gs12))	///
		(line PIB_ Year if País=="Croatia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Cyprus" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Czechia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Denmark" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Estonia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Finland" , lcolor(gs12))	///
		(line PIB_ Year if País=="Greece" , lcolor(gs12))	///
		(line PIB_ Year if País=="Hungary" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Iceland" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Ireland" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Italy" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Latvia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Lithuania" , lcolor(gs12))	///
		(line PIB_ Year if País=="Luxembourg" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Malta" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Netherlands" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Norway" , lcolor(gs12))	///
		(line PIB_ Year if País=="Poland" , lcolor(gs12))	///
		(line PIB_ Year if País=="Portugal" , lcolor(gs12))	///
		(line PIB_ Year if País=="Romania" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Slovakia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Slovenia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Spain" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Sweden" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Switzerland" , lcolor(gs12))	///
		(line PIB_ Year if País=="France" , lcolor(gs12))	///
		(line PIB_ Year if País=="Chile" , lcolor(green) lwidth(thick))	///
		(line PIB_ Year if País=="European Union - 27 countries (from 2020)" , lcolor(gold) lwidth(thick)) 	///
		(line PIB_ Year if País=="Euro area - 19 countries  (2015-2022)" , lcolor(midblue) lwidth(thick)),	///
		graphregion(color(white)) xla(2013(1)2021) ytitle("Gasto en Policías como porcentaje del PIB ")	///
		legend(cols(7) size(*0.55) pos(6) order(29 "Chile" 30 "UE" 31 "Zona Euro")) xline(2014 2018 2022, lpattern(dash))
		graph export "$graphs/Gasto en Policías como porcentaje del PIB.pdf", replace	
		
keep if País=="European Union - 27 countries (from 2020)" | País=="Euro area - 19 countries  (2015-2022)" | País=="Chile"
replace País="UE" if País=="European Union - 27 countries (from 2020)"
replace País="Zona Euro" if País=="Euro area - 19 countries  (2015-2022)"

graph hbar (mean) PIB_ , over(País) ytitle("Porcentaje del PIB") title("Inversión en policías promedio 2013-2021")	
	graph export "$graphs/Gasto en Policías como porcentaje del PIB A.pdf", replace	

restore 



preserve

keep if Partida=="Tribunalesdejusticia"
***Gris***

keep if Year>2012
keep if Year<2022
twoway 	(line PIB_ Year if País=="Belgium" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Bulgaria" , lcolor(gs12))	///
		(line PIB_ Year if País=="Croatia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Cyprus" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Czechia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Denmark" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Estonia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Finland" , lcolor(gs12))	///
		(line PIB_ Year if País=="Greece" , lcolor(gs12))	///
		(line PIB_ Year if País=="Hungary" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Iceland" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Ireland" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Italy" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Latvia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Lithuania" , lcolor(gs12))	///
		(line PIB_ Year if País=="Luxembourg" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Malta" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Netherlands" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Norway" , lcolor(gs12))	///
		(line PIB_ Year if País=="Poland" , lcolor(gs12))	///
		(line PIB_ Year if País=="Portugal" , lcolor(gs12))	///
		(line PIB_ Year if País=="Romania" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Slovakia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Slovenia" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Spain" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Sweden" , lcolor(gs12)) ///
		(line PIB_ Year if País=="Switzerland" , lcolor(gs12))	///
		(line PIB_ Year if País=="France" , lcolor(gs12))	///
		(line PIB_ Year if País=="Chile" , lcolor(green) lwidth(thick))	///
		(line PIB_ Year if País=="European Union - 27 countries (from 2020)" , lcolor(gold) lwidth(thick)) 	///
		(line PIB_ Year if País=="Euro area - 19 countries  (2015-2022)" , lcolor(midblue) lwidth(thick)),	///
		graphregion(color(white)) xla(2013(1)2021) ytitle("Gasto en Tribunales como porcentaje del PIB ")	///
		legend(cols(7) size(*0.55) pos(6) order(29 "Chile" 30 "UE" 31 "Zona Euro")) xline(2014 2018 2022, lpattern(dash))
		graph export "$graphs/Gasto en Tribunales como porcentaje del PIB.pdf", replace	
		
keep if País=="European Union - 27 countries (from 2020)" | País=="Euro area - 19 countries  (2015-2022)" | País=="Chile"
replace País="UE" if País=="European Union - 27 countries (from 2020)"
replace País="Zona Euro" if País=="Euro area - 19 countries  (2015-2022)"

graph hbar (mean) PIB_ , over(País) ytitle("Porcentaje del PIB") title("Inversión en tribunales promedio 2013-2021")	
	graph export "$graphs/Gasto en Tribunales como porcentaje del PIB A.pdf", replace	

restore 

keep if Partida=="Serviciosdepolicía" | Partida=="Tribunalesdejusticia" | Partida=="Prisiones"
keep if Year>2012
keep if Year<2022
keep if País=="European Union - 27 countries (from 2020)" | País=="Euro area - 19 countries  (2015-2022)" | País=="Chile"
replace País="UE" if País=="European Union - 27 countries (from 2020)"
replace País="Zona Euro" if País=="Euro area - 19 countries  (2015-2022)"

graph hbar (mean) PIB_ , over(País, relabel(1 "Chile" 2 "UE" 3 "Zona Euro")) over(Partida, relabel(1 "Prisiones" 2 "Policías" 3 "Tribunales")) ytitle("Porcentaje del PIB") title("Inversión por subsector promedio 2013-2021")	
	graph export "$graphs/Inversión por subsector promedio 2013-2021.pdf", replace

	
	
	
	

******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************


import excel "/Users/raulfugellie/Downloads/data_cts_access_and_functioning_of_justice.xlsx", sheet("data_cts_access_and_functioning") cellrange(A3:M96286) firstrow clear

keep if Country=="Chile" | Country=="Belgium" | Country=="Bulgaria" | Country=="Austria" | Country=="Croatia" | Country=="Cyprus" | Country=="Czechia" | Country=="Denmark" | Country=="Estonia" | Country=="Finland" | Country=="Germany" | Country=="Greece" | Country=="Hungary" | Country=="Iceland" | Country=="Ireland" | Country=="Italy" | Country=="Latvia" | Country=="Lithuania" | Country=="Luxembourg" | Country=="Malta" | Country=="Netherlands" | Country=="Norway" | Country=="Poland" | Country=="Portugal" | Country=="Romania" | Country=="Slovakia" | Country=="Slovenia" | Country=="Spain" | Country=="Sweden" | Country=="Switzerland" | Country=="France" | Country=="Argentina" | Country=="Brazil" | Country=="Costa Rica" | Country=="El Salvador" | Country=="Guatemala" | Country=="Australia" | Country=="Colombia" | Country=="Japan" | Country=="Republic of Korea" | Country=="United States of America" | Country=="Israel"

keep if Sex=="Total"
keep if Unitofmeasurement=="Rate per 100,000 population"
keep if Year<2018 & Year>2013
keep if Indicator=="Criminal Justice Personnel"
keep if Category=="Police personel"
collapse (mean) VALUE, by(Country)
gen counter = _n
table (counter) (), statistic(mean VALUE) nototals
collect label levels counter 1 "Argentina" 2 "Australia" 3 "Austria" 4 "Bélgica" 5 "Bulgaria" 6 "Chile" 7 "Colombia" 8 "Costa Rica" 9 "Croacia" 10 "Chipre" 11 "República Checa" 12 "Dinamarca" 13 "El Salvador" 14 "Estonia" 15 "Finlandia" 16 "Francia" 17 "Alemania" 18 "Grecia" 19 "Guatemala" 20 "Hungría" 21 "Islandia" 22 "Irlanda" 23 "Italia" 24 "Japón" 25 "Letonia" 26 "Lituania" 27 "Luxemburgo" 28 "Malta" 29 "Países Bajos" 30 "Noruega" 31 "Polonia" 32 "Portugal" 33 "Corea del Sur" 34 "Rumania" 35 "Eslovaquia" 36 "Eslovenia" 37 "España" 38 "Suecia" 39 "Suiza" 40 "USA"
collect label dim result "Media Policías x 100 mil habitantes", modify
collect label dim counter "País", modify
collect preview
collect export "$graphs/tabla_policías.tex", tableonly replace
collect clear





 