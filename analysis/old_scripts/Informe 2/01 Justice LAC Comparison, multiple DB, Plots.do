/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01	Justice LAC Comparison, multiple DB, Plots
	Author:		Lucas García
	Date:		March 07, 2023
	Version:	Stata 17

	Summary:	This dofile plots Justice trust trends using 2 different data 
				sources: Latinobarometro, LAPOP. It compares LAC with Chile
				
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
tempfile justice
postfile `lgc' str10 source double(mean year chile) using `justice', replace


************************************************
*  			2. Latinobarometro				   *
************************************************

*00		Opening 2020 dataset & cleaning
use "$usedata/latinobarometro", clear

*01		Collapse Annualy
collapse (mean) d_judiciary,   by(year chile)

*02		Post in temporal file
forvalues v = 1/12{
	post `lgc' ("Latinobarometro") (d_judiciary[`v']) (year[`v']) (chile[`v'])
}	


************************************************
*  				3. LAPOP					   *
************************************************

*00		Use LAPOP all countries
use "$usedata/LAPOP all countries.dta", clear

*01		Collapse chilean average
g chile=(pais==13)

collapse (mean) d_justice_punish , by(year chile)

*02		Post in temporal file
forvalues v = 1/10{
	post `lgc' ("LAPOP") (d_justice_punish[`v']) (year[`v']) (chile[`v'])
}

************************************************
*  	4. Use Temporal File and plot			   *
************************************************

*00		Close post
postclose `lgc'

use "`justice'", clear
sort year

*01		Plot

twoway	(scatter mean year if source=="Latinobaro" & chile==0, connect(direct) msymbol(D) lcolor(navy) mcolor(navy) yaxis(1))	///
		(scatter mean year if source=="Latinobaro" & chile==1, connect(direct) msymbol(Dh) lcolor(navy) mcolor(navy) yaxis(1) lpattern(dash))	///
		(scatter mean year if source=="LAPOP" & chile==0, connect(direct) msymbol(S) lcolor(maroon) mcolor(maroon) yaxis(1))					///
		(scatter mean year if source=="LAPOP" & chile==1, connect(direct) msymbol(Sh) lcolor(maroon) mcolor(maroon) yaxis(1) lpattern(dash)),				///
		graphregion(color(white)) ylabel(0(0.1)1, axis(1))  		///
		ytitle("Proporción") xtitle("")		///
		legend(order(	1	"Proporción que confía en el Poder Judicial, LAC, Latinobarómetro"	2	"Proporción que confía en el Poder Judicial, Chile, Latinobarómetro"	///
						3	"Proporción que confía que el sistema judicial castiga a los culpables, LAC, LAPOP"	4	"Proporción que confía que el sistema judicial castiga a los culpables, Chile, LAPOP") r(4) ///
						symxsize(*0.6) size(small))
						
graph export "$graphs/Justice trust, Chile y LAC, multiple DB.pdf", replace