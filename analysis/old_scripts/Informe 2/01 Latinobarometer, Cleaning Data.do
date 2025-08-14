/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01	Latinobarometer, Cleaning Data
	Author:		Lucas García
	Date:		March 01, 2023
	Version:	Stata 17

	Summary:	This dofile cleans latinobarometer data bases
				
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
	global graphs "$path/05 Graphs/Informe 2"
	global tables "$path/06 Tables"	
	
************************************************
*              1. Cleaning 2020 DB			   *
************************************************

*00		Opening 2020 dataset & cleaning
use "$rawdata/Latinobarometro_2020_Eng_Stata_v1_0", clear

*01		Renaming Trust Variables and others
rename (P13STGBS_A P13STGBS_B) (FFAA police)
rename p13st* (church congress government judiciary political_parties electoral_institution president) , sort
rename reeduc_1 REEDUC_1
rename numinves year

*02		Chilean dummy
gen chile=(idenpa==152)
	
*03		Keep relevant vars
keep year chile FFAA police church congress government judiciary political_parties electoral_institution REEDUC_1 sexo reedad idenpa

*04		Save as temporal file
tempfile latinobar_2020
save `latinobar_2020', replace


************************************************
*        		2. Cleaning 2018 DB			   *
************************************************

*00		Importing excel 
import excel "$rawdata/latinobarometro_2018.xlsx", clear

*01		Reformatting Vars with "."
foreach var of varlist A-OE {
	replace `var'=subinstr(`var',".","",.)	
}

*02		Renaming Vars
foreach v of varlist * {
   local vname = strtoname(`v'[1])
   rename `v' `vname'
}
drop in 1

*03		Gen Numeric Vars from strings
destring NUMINVES, gen(year)

g FFAA=(P15STGBSCA=="Mucha" | P15STGBSCA=="Algo")
g police=(P15STGBSCB=="Mucha" | P15STGBSCB=="Algo")
g church=(P15STGBSCC=="Mucha" | P15STGBSCC=="Algo")
g congress=(P15STGBSCD=="Mucha" | P15STGBSCD=="Algo")
g government=(P15STGBSCE=="Mucha" | P15STGBSCE=="Algo")
g judiciary=(P15STGBSCF=="Mucha" | P15STGBSCF=="Algo")
g political_parties=(P15STGBSCG=="Mucha" | P15STGBSCG=="Algo")
g electoral_institution=(P15STGBSCH=="Mucha" | P15STGBSCH=="Algo")

g chile=(IDENPA=="[%152%] C")

*Split IDENPA & subinstr
split IDENPA

replace IDENPA1=subinstr(IDENPA1, "[", "", 1)
replace IDENPA1=subinstr(IDENPA1, "%", "", 1)
replace IDENPA1=subinstr(IDENPA1, "%", "", 2)
replace IDENPA1=subinstr(IDENPA1, "]", "", 1)
destring IDENPA1, gen(idenpa)

*04		Sex, education and age
g sexo=1 if SEXO=="Hombre"
replace sexo=2 if SEXO=="Mujer"

g REEDUC_1=3 if REEDUC1=="Basica y"
replace REEDUC_1=5 if REEDUC1=="Secundari"
replace REEDUC_1=7 if REEDUC1=="Superior"

g reedad=1 if REEDAD=="De 16 a 2"
replace reedad=2 if REEDAD=="26 a 40"
replace reedad=3 if REEDAD=="41 a 60"
replace reedad=4 if REEDAD=="61 y mas"

*05		Keep relevant vars
keep year chile FFAA police church congress government judiciary political_parties electoral_institution REEDUC_1 sexo reedad idenpa

*06		Save as temporal file
tempfile latinobar_2018
save `latinobar_2018', replace

************************************************
*        		3. Cleaning 2017 DB			   *
************************************************

*00		Opening 2017 dataset & cleaning
use "$rawdata/Latinobarometro2017Eng_v20180117", clear

*01		Renaming Trust Variables and others
rename (P14STGBS_A P14STGBS_B) (FFAA police)
rename (P14ST_C P14ST_D P14ST_E P14ST_F P14ST_G P14ST_H) (church congress government judiciary political_parties electoral_institution) , sort
rename numinves year

*02		Chilean dummy
gen chile=(idenpa==152)
	
*03		Keep relevant vars
keep year chile FFAA police church congress government judiciary political_parties electoral_institution REEDUC_1 sexo reedad idenpa

*04		Save as temporal file
tempfile latinobar_2017
save `latinobar_2017', replace


************************************************
*        		4. Cleaning 2016 DB			   *
************************************************

*00		Opening 2016 dataset & cleaning
use "$rawdata/Latinobarometro2016Eng_v20170205", clear

*01		Renaming Trust Variables and others
rename (P13STGBSA P13STGBSB) (FFAA police)
rename (P13STC P13STD P13STE P13STF P13STG P13STH) (church congress government judiciary political_parties electoral_institution) , sort
rename numinves year

*02		Chilean dummy
gen chile=(idenpa==152)
	
*03		Keep relevant vars
keep year chile FFAA police church congress government judiciary political_parties electoral_institution REEDUC_1 sexo reedad idenpa

*04		Save as temporal file
tempfile latinobar_2016
save `latinobar_2016', replace


************************************************
*        		5. Cleaning 2015 DB			   *
************************************************

*00		Opening 2015 dataset & cleaning
use "$rawdata/Latinobarometro_2015_Eng", clear

*01		Renaming Trust Variables and others
rename (P16TGB_A P16TGB_B) (FFAA police)
rename (P16ST_E P16ST_F P16ST_G P16ST_H P19ST_C P19N_H) (church congress government judiciary political_parties electoral_institution) , sort
rename numinves year
rename S12 sexo

*02		Chilean dummy
gen chile=(idenpa==152)
	
*03		Keep relevant vars
keep year chile FFAA police church congress government judiciary political_parties electoral_institution REEDUC_1 sexo reedad idenpa

*04		Save as temporal file
tempfile latinobar_2015
save `latinobar_2015', replace


************************************************
*        		6. Cleaning 2013 DB			   *
************************************************

*00		Opening 2015 dataset & cleaning
use "$rawdata/Latinobarometro2013Eng", clear

*01		Renaming Trust Variables and others
rename (P28TGB_A P28TGB_B) (FFAA police)
rename (P28ST_E P26TGB_C P26TGB_B P26TGB_E P26TGB_G) (church congress government judiciary political_parties) , sort
rename numinves year
rename S10 sexo

*02		Chilean dummy
gen chile=(idenpa==152)
	
*03		Keep relevant vars
keep year chile FFAA police church congress government judiciary political_parties REEDUC_1 sexo reedad idenpa

************************************************
*   	7. Append with the other years		   *
************************************************

*00		Append
append using `latinobar_2020' `latinobar_2018' `latinobar_2017' `latinobar_2016' `latinobar_2015' `latinobar_2013'

*01		Replace year values of 2013 & 2015
replace year=2013 if year==17
replace year=2015 if year==18

*02		Make dummy variables
foreach var of varlist FFAA police congress government judiciary political_parties electoral_institution{
	g d_`var'=(`var'==1 | `var'==2)
}

*03		Save as new dataset
save "$usedata/latinobarometro.dta", replace