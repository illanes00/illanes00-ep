/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01	Congress trust, multiple DB, Plots
	Author:		Lucas García
	Date:		March 07, 2023
	Version:	Stata 17

	Summary:	This dofile plots Congress trust trends using 3 different data 
				sources: CEP, Latinobarometro and LAPOP.
				
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
*  1. Setting temporal file & Opening CEP DB   *
************************************************

*00		Defining temporal file to fill and plot
tempname lgc
tempfile congress
postfile `lgc' str10 source double(mean year) using `congress', replace

*01		Opening CEP DB
use "$rawdata/base_consolidada_2000_2022_v2 CEP.dta", clear

*Keep relevant vars
keep pond estrato secu encuesta_a encuesta_m confianza_6_k 

*02		Declaring as survey Data Set
svyset secu [pweight=pond], strata(estrato) singleunit(certainty) vce(linearized)

*03		Generating dummy variables from trust indicators
foreach var of varlist confianza_*{
	g dummy_`var'=(`var'<=2)
}

*04		Justice Trust annual trend
drop if confianza_6_k==.
quietly svy: mean dummy_confianza_6_k , over(encuesta_a)
mat table = e(b)

*05		Unique values of date
unique encuesta_a, by(encuesta_a)
sort _Unique encuesta_a

*05		Post in temporal file
forvalues v = 4/14{
	post `lgc' ("CEP") (table[1,`v']) (encuesta_a[`v'])
}


************************************************
*  			2. Latinobarometro				   *
************************************************

*00		Opening 2020 dataset & cleaning
use "$usedata/latinobarometro", clear

*01		Collapse Annualy
collapse (mean) d_congress if chile==1, by(year)

*02		Post in temporal file
forvalues v = 1/6{
	post `lgc' ("Latinobarometro") (d_congress[`v']) (year[`v'])
}	


************************************************
*  				3. LAPOP					   *
************************************************

*00		Use LAPOP all countries
use "$usedata/LAPOP all countries.dta", clear

*01		Collapse chilean average
g chile=(pais==13)

collapse (mean) congress if chile==1, by(year)

*02		Post in temporal file
forvalues v = 1/5{
	post `lgc' ("LAPOP") (congress[`v']) (year[`v'])
}


************************************************
*  				4. Bicentenario UC			   *
************************************************

*00		Import Bicentenario UC survey
import excel using "$rawdata/Bicentenario UC", firstr clear 

*01		Rescale vars
foreach var of varlist Parlamentarios TribunalesdeJusticia{
	replace `var'=`var'/100
}

*02		Post in temporal file
forvalues v = 1/6{
	post `lgc' ("Bicentenario UC") (Parlamentarios[`v']) (year[`v'])
}


************************************************
*  	5. Use Temporal File and plot			   *
************************************************

*00		Close post
postclose `lgc'

use "`congress'", clear
sort year

*01		Plot

twoway	(scatter mean year if source=="CEP", connect(direct) msymbol(O) lcolor(navy) mcolor(navy) yaxis(1))					///
		(scatter mean year if source=="Latinobaro", connect(direct) msymbol(D) lcolor(maroon) mcolor(maroon) yaxis(1))	///
		(scatter mean year if source=="Bicentenar", connect(direct) msymbol(T) lcolor(gold) mcolor(gold) yaxis(1))	///
		(scatter mean year if source=="LAPOP", connect(direct) msymbol(S) lcolor(dkgreen) mcolor(dkgreen) yaxis(2)),				///
		graphregion(color(white)) ylabel(0(0.1)1, axis(1)) ylabel(1(1)7, axis(2)) 		///
		ytitle("Proporción", axis(1)) xtitle("") ytitle("Nota", axis(2))		///
		legend(order(	1	"Proporción que confía, CEP"	2	"Proporción que confía, Latinobarómetro"	///
						3	"Proporción que confía, Bicentenario UC"	4	"Confianza (Nota), LAPOP") r(4))
						
graph export "$graphs/Congress trust, multiple DB.pdf", replace