/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01 Cleaning Data, ENUSC 08-15, incomplete 
	Author:		Lucas García
	Date:		December 02, 2022
	Version:	Stata 17

	Summary:	This dofile sets the data to check different tendencies of the 
				different common variables between the ENUSC surveys of 2008 to
				2015.			
				
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
	global graphs "$path/05 Graphs/Enusc 08 15"
	global tables "$path/06 Tables"
	

************************************************
*              1. Cleaning data                *
************************************************

*00			Opening each DB to be saved as tempfile
*01		2008
import spss "$rawdata/1. ENUSC V Base de Usuario 2008.sav", clear
g year=2008
egen VarStrat = concat(year enc_rpc)
destring VarStrat, replace
rename enc_folio ID_vivienda
rename Kish kish
rename P22_NVeces vict_gral_n
rename P23_Ncasos denuncias_gral_n
local keeping year ID_vivienda Fact_Hog_15reg_nuevo VarStrat kish vict_gral_n denuncias_gral_n
keep `keeping'
*Temporal file
tempfile enusc_2008
save `enusc_2008', replace

*02		2009
import spss "$rawdata/2. ENUSC VI Base Usuaro 2009.sav", clear
g year=2009
egen VarStrat = concat(year enc_comuna)
destring VarStrat, replace
rename enc_idr ID_vivienda
rename P22_nveces vict_gral_n
rename p23_ncasos denuncias_gral_n
keep `keeping'
*Temporal file
tempfile enusc_2009
save `enusc_2009', replace

*03		2010
import spss "$rawdata/3. ENUSC VII Base Usuario 2010.sav", clear
g year=2010
egen VarStrat = concat(year enc_comuna)
destring VarStrat, replace
rename P24_NVeces vict_gral_n
rename P25_Ncasos denuncias_gral_n
keep `keeping'
*Temporal file
tempfile enusc_2010
save `enusc_2010', replace

*04		2011
import spss "$rawdata/4. ENUSC VIII Base Usuario 2011.sav", clear
g year=2011
egen VarStrat = concat(year enc_comuna)
destring VarStrat, replace
rename ID_Vivienda ID_vivienda
rename P20_Nveces vict_gral_n
rename P21_Ncasos denuncias_gral_n
keep `keeping'
*Temporal file
tempfile enusc_2011
save `enusc_2011', replace

*05		2012
import spss "$rawdata/5. ENUSC IX  Base Usuario 2012.sav", clear
g year=2012
egen VarStrat = concat(year enc_comuna)
destring VarStrat, replace
rename ID_Vivienda ID_vivienda
rename P20_Nveces vict_gral_n
rename P21_Ncasos denuncias_gral_n
keep `keeping'
*Temporal file
tempfile enusc_2012
save `enusc_2012', replace

*06		2013
import spss "$rawdata/6. ENUSC X Base Usuario 2013.sav", clear
g year=2013
egen VarStrat = concat(year enc_comuna)
destring VarStrat, replace
rename ID_Vivienda ID_vivienda
rename P20_Nveces vict_gral_n
rename P21_Ncasos denuncias_gral_n
keep `keeping'
*Temporal file
tempfile enusc_2013
save `enusc_2013', replace

*06		2014
import spss "$rawdata/7. ENUSC XI Base Usuario 2014.sav", clear
g year=2014
egen VarStrat = concat(year enc_comuna)
destring VarStrat, replace
rename ID_Vivienda ID_vivienda
rename P20_Nveces vict_gral_n
rename P21_Ncasos denuncias_gral_n
keep `keeping'
*Temporal file
tempfile enusc_2014
save `enusc_2014', replace

/*
*06		2015
import spss "$rawdata/8. ENUSC XII Base Usuario 2015.sav", clear
g year=2015
*Temporal file
tempfile enusc_2015
save `enusc_2015', replace
*/

*07		2016
import spss "${rawdata}\base-de-datos---enusc-xiii.sav", clear
rename enc_idr ID_vivienda
rename Fact_Hog Fact_Hog_15reg_nuevo
destring VarStrat, replace
rename Kish kish
g vict_gral_n=.
foreach x in A1_1_1_N_Veces B1_1_1_N_Veces C1_1_1_N_Veces D1_1_1_N_Veces E1_1_1_N_Veces G1_1_1_N_Veces H1_1_1_N_Veces{
replace vict_gral_n=`x' if `x'!=.	
}
g denuncias_gral_n=.
foreach x in A2_1_1_N_Veces B2_1_1_N_Veces C2_1_1_N_Veces D2_1_1_N_Veces E2_1_1_N_Veces G2_1_1_N_Veces H2_1_1_N_Veces{
replace denuncias_gral_n=`x' if `x'!=.	
}
g year=2016
keep `keeping'
*Temporal file
tempfile enusc_2016
save `enusc_2016', replace

*08		2017
import spss "$rawdata/base-de-datos---xiv-enusc-2017.sav", clear
rename enc_idr ID_vivienda
rename Fact_Hog Fact_Hog_15reg_nuevo
rename Kish kish
g year=2017
g vict_gral_n=.
foreach x in A1_1_1_N_Veces B1_1_1_N_Veces C1_1_1_N_Veces D1_1_1_N_Veces E1_1_1_N_Veces G1_1_1_N_Veces H1_1_1_N_Veces{
replace vict_gral_n=`x' if `x'!=.	
}
g denuncias_gral_n=.
foreach x in A2_1_1_N_Veces B2_1_1_N_Veces C2_1_1_N_Veces D2_1_1_N_Veces E2_1_1_N_Veces G2_1_1_N_Veces H2_1_1_N_Veces{
replace denuncias_gral_n=`x' if `x'!=.	
}
keep `keeping'
*Temporal file
tempfile enusc_2017
save `enusc_2017', replace

*09		2018
import spss "$rawdata/base-de-datos---xv-enusc-2018.sav", clear
g year=2018
rename enc_idr ID_vivienda
rename Fact_Hog Fact_Hog_15reg_nuevo
rename Kish kish
g vict_gral_n=.
foreach x in A1_1_1_N_Veces B1_1_1_N_Veces C1_1_1_N_Veces D1_1_1_N_Veces E1_1_1_N_Veces G1_1_1_N_Veces H1_1_1_N_Veces{
replace vict_gral_n=`x' if `x'!=.	
}
g denuncias_gral_n=.
foreach x in A2_1_1_N_Veces B2_1_1_N_Veces C2_1_1_N_Veces D2_1_1_N_Veces E2_1_1_N_Veces G2_1_1_N_Veces H2_1_1_N_Veces{
replace denuncias_gral_n=`x' if `x'!=.	
}
keep `keeping'
*Temporal file
tempfile enusc_2018
save `enusc_2018', replace

*10		2019
import spss "$rawdata/base-de-datos---xvi-enusc-2019-(sav).sav", clear
g year=2019
rename enc_idr ID_vivienda
rename Fact_Hog Fact_Hog_15reg_nuevo
rename Kish kish
g vict_gral_n=.
foreach x in A1_1_1_N_Veces B1_1_1_N_Veces C1_1_1_N_Veces D1_1_1_N_Veces E1_1_1_N_Veces G1_1_1_N_Veces H1_1_1_N_Veces{
replace vict_gral_n=`x' if `x'!=.	
}
g denuncias_gral_n=.
foreach x in A2_1_1_N_Veces B2_1_1_N_Veces C2_1_1_N_Veces D2_1_1_N_Veces E2_1_1_N_Veces G2_1_1_N_Veces H2_1_1_N_Veces{
replace denuncias_gral_n=`x' if `x'!=.	
}
keep `keeping'
*Temporal file
tempfile enusc_2019
save `enusc_2019', replace

*11		2020
import spss "$rawdata/base-usuario-17-enusc-2020-sav.sav", clear
g year=2020
rename enc_idr ID_vivienda
rename Fact_Hog Fact_Hog_15reg_nuevo
rename Kish kish
g vict_gral_n=.
foreach x in A1_1_1_N_Veces B1_1_1_N_Veces C1_1_1_N_Veces D1_1_1_N_Veces E1_1_1_N_Veces G1_1_1_N_Veces H1_1_1_N_Veces{
replace vict_gral_n=`x' if `x'!=.	
}
g denuncias_gral_n=.
foreach x in A2_1_1_N_Veces B2_1_1_N_Veces C2_1_1_N_Veces D2_1_1_N_Veces E2_1_1_N_Veces G2_1_1_N_Veces H2_1_1_N_Veces{
replace denuncias_gral_n=`x' if `x'!=.	
}
keep `keeping'
*Temporal file
tempfile enusc_2020
save `enusc_2020', replace

*12		2021
import spss "$rawdata/base-usuario-18-enusc-2021-sav05142b868f1445af8f592cf582239857", clear
rename enc_idr ID_vivienda
rename Fact_Hog Fact_Hog_15reg_nuevo
rename Kish kish
g year=2021
g vict_gral_n=.
foreach x in A1_1_1_N_Veces B1_1_1_N_Veces C1_1_1_N_Veces D1_1_1_N_Veces E1_1_1_N_Veces G1_1_1_N_Veces H1_1_1_N_Veces{
replace vict_gral_n=`x' if `x'!=.	
}
g denuncias_gral_n=.
foreach x in A2_1_1_N_Veces B2_1_1_N_Veces C2_1_1_N_Veces D2_1_1_N_Veces E2_1_1_N_Veces G2_1_1_N_Veces H2_1_1_N_Veces{
replace denuncias_gral_n=`x' if `x'!=.	
}
keep `keeping'
*Temporal file
tempfile enusc_2021
save `enusc_2021', replace


*13		Append DB
use `enusc_2008', clear
append using `enusc_2009' `enusc_2010' `enusc_2011' `enusc_2012' `enusc_2013' `enusc_2014' `enusc_2016' `enusc_2017' `enusc_2018' `enusc_2019' `enusc_2020' `enusc_2021'

keep if kish==1

*14		Save Appended DB
save "$usedata/enusc_08_21_manual", replace
use "$usedata/enusc_08_21_manual", clear

*15		Merge with unificada
svyset ID_vivienda [pweight=Fact_Hog_15reg_nuevo], strata(VarStrat) singleunit(certainty)
tempname lgc 
tempfile agg
postfile `lgc' sum_vict sum_denuncia year using `agg', replace

svy: total vict_gral_n, over(year)
mat table_vict = r(table)
svy: total denuncias_gral_n, over(year)
mat table_denuncia = r(table)

forvalues x = 1/7{
	local year = `x'+2007
	post `lgc' (table_vict[1,`x']) (table_denuncia[1,`x']) (`year')
}

forvalues b = 1/6{
	local year = `b'+2015
	local x = `b'+7
	post `lgc' (table_vict[1,`x']) (table_denuncia[1,`x']) (`year')
}

postclose `lgc'

preserve
import spss "$rawdata/base_interanual_enusc_2008_2021.sav", clear

*-01	Defining DB as survey first for PAD & individual Victimization 
svyset id_unico [pweight=fact_pers_2019_2021], strata(varstrat) singleunit(certainty)

*00 	Setting the temporal file
tempname abc 
tempfile trend
postfile `abc'  mean_vic_h year using `trend'

*02		Now for vict and revict
svyset idr [pweight=fact_hog_2019_2021], strata(varstrat) singleunit(certainty)

*Victimization
svy: mean va_dc , over(año)
mat table=r(table)


*03 	Now filling temporal file
forvalues x = 1/14{
	local year = `x'+2007
	di `year'
	post `abc' (table[1,`x']) (`year')
}

postclose `abc'

use "`trend'", clear

merge 1:1 year using "`agg'", nogen

*04		Generating proportion of interest
g prop_denuncias=sum_denuncia/sum_vict

*05		Plotting
twoway	(scatter prop_denuncias year , connect(direct))		///
		(scatter mean_vic_h year , connect(direct)),		///
		graphregion(color(white)) ytitle("Proporción")		///
		legend(order(1 "Delitos denunciados" 2 "Hogares victimizados"))	///
		xtitle("") ylabel(0(0.1)0.5)
		
graph export "$graphs/Proporción delitos denunciados, enusc manual.pdf", replace
graph export "$graphs/Proporción delitos denunciados, enusc manual.png", replace
graph export "$graphs/Proporción delitos denunciados, enusc manual.eps", replace

restore