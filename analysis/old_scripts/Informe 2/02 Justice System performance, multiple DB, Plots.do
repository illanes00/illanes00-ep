/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		02	Justice System performance, multiple DB, Plots
	Author:		Lucas García
	Date:		March 07, 2023
	Version:	Stata 17

	Summary:	This dofile plots Justice System performance trends using 2 different data 
				sources: CADEM, Paz Ciudadana.
				
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
*  1. Setting temporal file 				   *
************************************************

*00		Defining temporal file to fill and plot
tempname lgc
tempfile police
postfile `lgc' str10 source double(mean year) using `police', replace

*01		Opening CADEM DB
import excel using "$rawdata/Cadem, evolutivo evaluación Instituciones", firstr clear sheet("Serie")

*01		Rescaling % variables
foreach var of varlist PDI-Congreso{
	replace `var'=`var'/100
}

*02		Generating Date vars
gen fake_date = _n
g year = _n+2014 if _n<=6
replace year = 2021 if _n>=7 & _n<=16
replace year = 2022 if _n>=17 & _n<=25
replace year = 2023 if _n>=26 & _n<=27

*03		Collapse by year
collapse (mean) TribunalesdeJusticia, by (year)

*04		Post in temporal file
forvalues v = 1/9{
	post `lgc' ("CADEM") (TribunalesdeJusticia[`v']) (year[`v'])
}

************************************************
*  			2. Paz Ciudadana				   *
************************************************

*00		Use Paz Ciudadana
import excel using "$rawdata/Paz Ciudadana", firstr clear 

g year=year(date)
destring TribunalesdeJusticia, replace dpcomma

*Collapse Year level
collapse (mean) TribunalesdeJusticia, by(year)

*02		Post in temporal file
forvalues v = 1/11{
	post `lgc' ("PC") (TribunalesdeJusticia[`v']) (year[`v'])
}

	
************************************************
*  	3. Use Temporal File and plot			   *
************************************************

*00		Close post
postclose `lgc'

use "`police'", clear

*01		Plot
twoway	(scatter mean year if source=="CADEM", connect(direct) msymbol(O) lcolor(navy) mcolor(navy) yaxis(1))					///
		(scatter mean year if source=="PC", connect(direct) msymbol(T) lcolor(maroon) mcolor(maroon) yaxis(2)),				///
		graphregion(color(white)) ylabel(0(0.1)1, axis(1)) ylabel(1(1)7, axis(2)) 		///
		ytitle("Proporción", axis(1)) ytitle("Nota", axis(2)) xtitle("")		///
		legend(order(	1	"Proporción que Aprueba, CADEM"	2	"Nota de desempeño, Paz Ciudadana") r(2))
						
graph export "$graphs/Justice System performance, multiple DB.pdf", replace