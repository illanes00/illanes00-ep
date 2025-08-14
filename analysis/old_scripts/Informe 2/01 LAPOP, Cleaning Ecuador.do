/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01	LAPOP, Cleaning Ecuador
	Author:		Lucas García
	Date:		March 02, 2023
	Version:	Stata 17

	Summary:	This dofile cleans Ecuador LAPOP survey from 2010 until 2021.
				
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
	global rawdata "$path/01 RawData/LAPOP"
	global dofiles "$path/02 Code"
	global usedata "$path/04 Usedata"
	global graphs "$path/05 Graphs/Informe 2"
	global tables "$path/06 Tables"
	
	
************************************************
*              1. Cleaning 2021 DB			   *
************************************************

*00		Opening 2021 dataset, cleaning
use "$rawdata/ECU_2021_LAPOP_AmericasBarometer_v1.2_w.dta", clear

*01		Rename Confidence in elections, respect for institutions & democracy satisfaction
rename b47a elections_trust
rename b2 institutions_respect
rename pn4 democ_satisf

*02		Keep relevant variables	
keep pais year elections_trust institutions_respect democ_satisf

*03		Save as temporal file 
tempfile ecu_2021
save `ecu_2021', replace


************************************************
*              2. Cleaning 2019 DB			   *
************************************************

*00		Opening 2019 dataset, cleaning
use "$rawdata/Ecuador LAPOP AmericasBarometer 2019 v1.0_W.dta", clear

g year=2019

*01		Rename Confidence in elections, respect for institutions & democracy satisfaction
rename b47a elections_trust
rename b2 institutions_respect
rename pn4 democ_satisf
rename b12 FFAA
rename b13 congress
rename b18 police
rename b21 political_parties
rename aoj12 justice_punish
rename infrax police_response

*02		Keep relevant variables	
keep pais year elections_trust institutions_respect democ_satisf FFAA congress police political_parties justice_punish police_response

*03		Save as temporal file 
tempfile ecu_2019
save `ecu_2019', replace


************************************************
*              3. Cleaning 2017 DB			   *
************************************************

*00		Opening 2017 dataset, cleaning
use "$rawdata/1061044693Ecuador LAPOP AmericasBarometer 2016-17 V1.0_W.dta", clear

g year=2017

*01		Rename Confidence in elections, respect for institutions & democracy satisfaction
rename b47a elections_trust
rename b2 institutions_respect
rename pn4 democ_satisf
rename b12 FFAA
rename b13 congress
rename b18 police
rename b21 political_parties
rename aoj12 justice_punish
rename infrax police_response

*02		Keep relevant variables	
keep pais year elections_trust institutions_respect democ_satisf FFAA congress police political_parties justice_punish police_response

*03		Save as temporal file 
tempfile ecu_2017
save `ecu_2017', replace


************************************************
*              4. Cleaning 2014 DB			   *
************************************************

*00		Opening 2014 dataset, cleaning
use "$rawdata/244461055Ecuador LAPOP AmericasBarometer 2014 v3.0_W.dta", clear

g year=2014

*01		Rename Confidence in elections, respect for institutions & democracy satisfaction
rename b47a elections_trust
rename b2 institutions_respect
rename pn4 democ_satisf
rename b12 FFAA
rename b13 congress
rename b18 police
rename b21 political_parties
rename aoj12 justice_punish
rename infrax police_response

*02		Keep relevant variables	
keep pais year elections_trust institutions_respect democ_satisf FFAA congress police political_parties justice_punish police_response

*03		Save as temporal file 
tempfile ecu_2014
save `ecu_2014', replace


************************************************
*              5. Cleaning 2012 DB			   *
************************************************

*00		Opening 2012 dataset, cleaning
use "$rawdata/1782383684Ecuador LAPOP AmericasBarometer 2012 Rev1_W.dta", clear

*01		Rename Confidence in elections, respect for institutions & democracy satisfaction
rename b47a elections_trust
rename b2 institutions_respect
rename pn4 democ_satisf
rename b12 FFAA
rename b13 congress
rename b18 police
rename b21 political_parties
rename aoj12 justice_punish

*02		Keep relevant variables	
keep pais year elections_trust institutions_respect democ_satisf FFAA congress police political_parties justice_punish

*03		Save as temporal file 
tempfile ecu_2012
save `ecu_2012', replace


************************************************
*              6. Cleaning 2010 DB			   *
************************************************

*00		Opening 2010 dataset, cleaning
use "$rawdata/152597287Ecuador_LAPOP_AmericasBarometer 2010 data set  approved v3.dta", clear

*01		Rename Confidence in elections, respect for institutions & democracy satisfaction
rename b47 elections_trust
rename b2 institutions_respect
rename pn4 democ_satisf
rename b12 FFAA
rename b13 congress
rename b18 police
rename b21 political_parties
rename aoj12 justice_punish

*02		Keep relevant variables	
keep pais year elections_trust institutions_respect democ_satisf FFAA congress police political_parties justice_punish

*03		Save as temporal file 
tempfile ecu_2010
save `ecu_2010', replace


************************************************
*   	6. Append with the other years		   *
************************************************

*00		Append
append using `ecu_2021' `ecu_2019' `ecu_2017' `ecu_2014' `ecu_2012'

*01		Gen dummy vars
foreach var of varlist democ_satisf justice_punish{
	g d_`var'=(`var'<=2) if `var'!=. &  `var'!=.a & `var'!=.b & `var'!=.c
}

*02		Save Database
save "$usedata/LAPOP, Ecuador.dta", replace