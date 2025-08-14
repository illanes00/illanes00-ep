/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01 Corr delta(perc-vict) - delta(homicides)
	Author:		Lucas García
	Date:		November 29, 2022
	Version:	Stata 17

	Summary:	This dofile plots the correlation between the delta of 2022 with
				2016 of the difference between individual perception and individual
				victimization, against the delta of region level homicides.
				
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
*              1. Data of ENUSC				   *	
************************************************

*******	2016-2021
*00			Opening DB
import spss "$rawdata/base_interanual_enusc_2008_2021.sav"

*01			Defining DB as survey first for PAD & individual Victimization 
svyset id_unico [pweight=fact_pers_2019_2021], strata(varstrat) singleunit(certainty)

*02			Keeping relevant info in a temporal file
*Setting the temporal file
tempname lgc 
tempfile database
postfile `lgc' mean_pad mean_vic_i Año region using `database'

*Keeping relevant years (2016-2021)
replace region16=8 if region16==16
replace region=region16 if region==.
keep if año==2016 | año==2021

*First for PAD & individual Victimization 
*PAD
svy: mean pad, over(año region)
mat table_pad=r(table)
mat list table_pad

*Victimization
svy: mean vp_dc, over(año region )
mat table_vic_i=r(table)
mat list table_vic_i

*03			Now filling temporal DB
forvalues r=1/15{
	local year = 2016
	post `lgc' (table_pad[1,`r']) (table_vic_i[1,`r']) (`year') (`r')
}

forvalues aux=1/15{
	local r=`aux'+15
	local year = 2021
	post `lgc' (table_pad[1,`r']) (table_vic_i[1,`r']) (`year') (`aux')
}


postclose `lgc'
use "`database'", clear
*ENUSC variables
g gap_2016=mean_pad-mean_vic_i if Año==2016
g gap_2021=mean_pad-mean_vic_i if Año==2021

g gap = .
replace gap=gap_2016 if Año==2016
replace gap=gap_2021 if Año==2021
drop gap_* mean_*
label var gap "Brecha pad-victimizacion"

g gap_aux=gap if Año==2021
bys region: egen gap_2021=max(gap_aux)
drop gap_aux
g diff_enusc=gap_2021-gap
drop if Año==2021
drop gap gap_2021 Año
 
save "`database'", replace
 
*04			Cleaning Fiscalia DB
use "$usedata/homicidios_fiscalia_16_21", clear

*Cleaning
keep if Año==2016 | Año==2021
keep region Año HomicidiosIngresados

*Fiscalia Variables
sort region Año
bys region: g homicidios_2021_aux=HomicidiosIngresados if Año==2021
bys region: egen homicidios_2021=max(homicidios_2021_aux)
drop homicidios_2021_aux

g diff_homicides=homicidios_2021-HomicidiosIngresados
drop HomicidiosIngresados homicidios_2021
drop if diff_homicides==0
drop Año

*05			Merging with temporal file
merge 1:1 region using "`database'", nogen

*06			Scatter plot
twoway	(scatter diff_homicides diff_enusc)	///
		(lfit diff_homicides diff_enusc), ///
xtitle("(Percepción-Victimización, 2021)-" "(Percepción-Victimización, 2016)")	///
ytitle("(Tasa Homicidios Ingresados, 2021) -" "(Tasa Homicidios Ingresados, 2016)")	///
legend(order(2 "Ajuste lineal")) graphregion(color(white)) note("Cada punto representa una región del país.")

graph export "$graphs/corr_pad_vict_homicidios_16_21.pdf", replace
graph export "$graphs/corr_pad_vict_homicidios_16_21.eps", replace


*******	2016-2018
*00			Opening DB
import spss "$rawdata/base_interanual_enusc_2008_2021.sav", clear

*01			Defining DB as survey first for PAD & individual Victimization 
svyset id_unico [pweight=fact_pers_2019_2021], strata(varstrat) singleunit(certainty)

*02			Keeping relevant info in a temporal file
*Setting the temporal file
tempname lgc 
tempfile database
postfile `lgc' mean_pad mean_vic_i Año region using `database'

*Keeping relevant years (2016-2018)
replace region16=8 if region16==16
replace region=region16 if region==.
keep if año==2016 | año==2018

*First for PAD & individual Victimization 
*PAD
svy: mean pad, over(año region)
mat table_pad=r(table)
mat list table_pad

*Victimization
svy: mean vp_dc, over(año region )
mat table_vic_i=r(table)
mat list table_vic_i

*03			Now filling temporal DB
forvalues r=1/15{
	local year = 2016
	post `lgc' (table_pad[1,`r']) (table_vic_i[1,`r']) (`year') (`r')
}

forvalues aux=1/15{
	local r=`aux'+15
	local year = 2018
	post `lgc' (table_pad[1,`r']) (table_vic_i[1,`r']) (`year') (`aux')
}


postclose `lgc'
use "`database'", clear
*ENUSC variables
g gap_2016=mean_pad-mean_vic_i if Año==2016
g gap_2021=mean_pad-mean_vic_i if Año==2018

g gap = .
replace gap=gap_2016 if Año==2016
replace gap=gap_2021 if Año==2018
drop gap_* mean_*
label var gap "Brecha pad-victimizacion"

g gap_aux=gap if Año==2018
bys region: egen gap_2021=max(gap_aux)
drop gap_aux
g diff_enusc=gap_2021-gap
drop if Año==2018
drop gap gap_2021 Año
 
save "`database'", replace
 
*04			Cleaning Fiscalia DB
use "$usedata/homicidios_fiscalia_16_21", clear

*Cleaning
keep if Año==2016 | Año==2018
keep region Año HomicidiosIngresados

*Fiscalia Variables
sort region Año
bys region: g homicidios_2021_aux=HomicidiosIngresados if Año==2018
bys region: egen homicidios_2021=max(homicidios_2021_aux)
drop homicidios_2021_aux

g diff_homicides=homicidios_2021-HomicidiosIngresados
drop HomicidiosIngresados homicidios_2021
drop if diff_homicides==0
drop Año

*05			Merging with temporal file
merge 1:1 region using "`database'", nogen

*06			Scatter plot
twoway	(scatter diff_homicides diff_enusc)	///
		(lfit diff_homicides diff_enusc), ///
xtitle("(Percepción-Victimización, 2018)-" "(Percepción-Victimización, 2016)")	///
ytitle("(Tasa Homicidios Ingresados, 2018) -" "(Tasa Homicidios Ingresados, 2016)")	///
legend(order(2 "Ajuste lineal")) graphregion(color(white)) note("Cada punto representa una región del país.")

graph export "$graphs/corr_pad_vict_homicidios_16_18.pdf", replace
graph export "$graphs/corr_pad_vict_homicidios_16_18.eps", replace



*******	2019-2021
*00			Opening DB
import spss "$rawdata/base_interanual_enusc_2008_2021.sav", clear

*01			Defining DB as survey first for PAD & individual Victimization 
svyset id_unico [pweight=fact_pers_2019_2021], strata(varstrat) singleunit(certainty)

*02			Keeping relevant info in a temporal file
*Setting the temporal file
tempname lgc 
tempfile database
postfile `lgc' mean_pad mean_vic_i Año region using `database'

*Keeping relevant years (2019-2021)
replace region16=8 if region16==16
replace region=region16 if region==.
keep if año==2019 | año==2021

*First for PAD & individual Victimization 
*PAD
svy: mean pad, over(año region)
mat table_pad=r(table)
mat list table_pad

*Victimization
svy: mean vp_dc, over(año region )
mat table_vic_i=r(table)
mat list table_vic_i

*03			Now filling temporal DB
forvalues r=1/15{
	local year = 2019
	post `lgc' (table_pad[1,`r']) (table_vic_i[1,`r']) (`year') (`r')
}

forvalues aux=1/15{
	local r=`aux'+15
	local year = 2021
	post `lgc' (table_pad[1,`r']) (table_vic_i[1,`r']) (`year') (`aux')
}


postclose `lgc'
use "`database'", clear
*ENUSC variables
g gap_2016=mean_pad-mean_vic_i if Año==2019
g gap_2021=mean_pad-mean_vic_i if Año==2021

g gap = .
replace gap=gap_2016 if Año==2019
replace gap=gap_2021 if Año==2021
drop gap_* mean_*
label var gap "Brecha pad-victimizacion"

g gap_aux=gap if Año==2021
bys region: egen gap_2021=max(gap_aux)
drop gap_aux
g diff_enusc=gap_2021-gap
drop if Año==2021
drop gap gap_2021 Año
 
save "`database'", replace
 
*04			Cleaning Fiscalia DB
use "$usedata/homicidios_fiscalia_16_21", clear

*Cleaning
keep if Año==2019 | Año==2021
keep region Año HomicidiosIngresados

*Fiscalia Variables
sort region Año
bys region: g homicidios_2021_aux=HomicidiosIngresados if Año==2021
bys region: egen homicidios_2021=max(homicidios_2021_aux)
drop homicidios_2021_aux

g diff_homicides=homicidios_2021-HomicidiosIngresados
drop HomicidiosIngresados homicidios_2021
drop if diff_homicides==0
drop Año

*05			Merging with temporal file
merge 1:1 region using "`database'", nogen

*06			Scatter plot
twoway	(scatter diff_homicides diff_enusc)	///
		(lfit diff_homicides diff_enusc), ///
xtitle("(Percepción-Victimización, 2021)-" "(Percepción-Victimización, 2019)")	///
ytitle("(Tasa Homicidios Ingresados, 2021) -" "(Tasa Homicidios Ingresados, 2019)")	///
legend(order(2 "Ajuste lineal")) graphregion(color(white)) note("Cada punto representa una región del país.")

graph export "$graphs/corr_pad_vict_homicidios_19_21.pdf", replace
graph export "$graphs/corr_pad_vict_homicidios_19_21.eps", replace

