/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01	Elections LAC Comparison, multiple DB, Plots
	Author:		Lucas García
	Date:		March 07, 2023
	Version:	Stata 17

	Summary:	This dofile plots Electoral institutions trust trends using 2 different data 
				sources: Latinobarometro and LAPOP. It compares LAC and Chile
				
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
*  			2. Latinobarometro				   *
************************************************

*00		Defining temporal file to fill and plot
tempname lgc
tempfile congress
postfile `lgc' str10 source double(mean year chile) using `congress', replace

*00		Opening 2020 dataset & cleaning
use "$usedata/latinobarometro", clear

*01		Collapse Annualy
collapse (mean) d_electoral_institution , by(year chile)
replace d_electoral_institution=. if d_electoral_institution==0

*02		Post in temporal file
forvalues v = 1/12{
	post `lgc' ("Latinobarometro") (d_electoral_institution[`v']) (year[`v']) (chile[`v'])
}	


************************************************
*  				2. LAPOP					   *
************************************************

*00		Use LAPOP all countries
use "$usedata/LAPOP all countries.dta", clear

*01		Collapse chilean average
g chile=(pais==13)

collapse (mean) elections_trust, by(year chile)

*02		Post in temporal file
forvalues v = 1/10{
	post `lgc' ("LAPOP") (elections_trust[`v']) (year[`v']) (chile[`v'])
}

************************************************
*  	3. Use Temporal File and plot			   *
************************************************

*00		Close post
postclose `lgc'

use "`congress'", clear
sort year

*01		Plot

twoway	(scatter mean year if source=="Latinobaro" & chile==0, connect(direct) msymbol(D) lcolor(navy) mcolor(navy) yaxis(1))	///
		(scatter mean year if source=="Latinobaro" & chile==1, connect(direct) msymbol(Dh) lcolor(navy) mcolor(navy) yaxis(1) lpattern(dash))	///
		(scatter mean year if source=="LAPOP" & chile==0, connect(direct) msymbol(S) lcolor(maroon) mcolor(maroon) yaxis(2))				///
		(scatter mean year if source=="LAPOP" & chile==1, connect(direct) msymbol(Sh) lcolor(maroon) mcolor(maroon) yaxis(2) lpattern(dash)),				///
		graphregion(color(white)) ylabel(0(0.1)1, axis(1)) ylabel(1(1)7, axis(2)) 		///
		ytitle("Proporción", axis(1)) xtitle("") ytitle("Nota", axis(2))		///
		legend(order(	1	"Proporción que confía, LAC, Latinobarómetro"	2	"Proporción que confía, Chile, Latinobarómetro"	///
						3	"Confianza (Nota), LAC, LAPOP"	4	"Confianza (Nota), Chile, LAPOP") r(4))
						
graph export "$graphs/Elections trust, Chile y LAC, multiple DB.pdf", replace