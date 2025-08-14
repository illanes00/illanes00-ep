/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01	Government trust, multiple DB, Plots
	Author:		Lucas García
	Date:		March 21, 2023
	Version:	Stata 17

	Summary:	This dofile plots Government trust trends using 3 different data 
				sources: CEP, Latinobarometro and Bicentenario UC. It also plots
				Government's mark performance trend according to Paz Ciudadana.
				
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
tempfile justice
postfile `lgc' str10 source double(mean year) using `justice', replace

*01		Opening CEP DB
use "$rawdata/base_consolidada_2000_2022_v2 CEP.dta", clear

*Keep relevant vars
keep pond estrato secu encuesta_a encuesta_m confianza_6_i 

*02		Declaring as survey Data Set
svyset secu [pweight=pond], strata(estrato) singleunit(certainty) vce(linearized)

*03		Generating dummy variables from trust indicators
foreach var of varlist confianza_*{
	g dummy_`var'=(`var'<=2)
}

*04		Justice Trust annual trend
drop if confianza_6_i==.
quietly svy: mean dummy_confianza_6_i , over(encuesta_a)
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
collapse (mean) d_government if chile==1, by(year)

*02		Post in temporal file
forvalues v = 1/6{
	post `lgc' ("Latinobarometro") (d_government[`v']) (year[`v'])
}	


************************************************
*  				3. Paz Ciudadana			   *
************************************************

*00		Use Paz Ciudadana
import excel using "$rawdata/Paz Ciudadana", firstr clear 

g year=year(date)
destring Gobierno, replace dpcomma

*Collapse Year level
collapse (mean) Gobierno, by(year)

label var Gobierno "Nota de desempeño del Gobierno, Paz Ciudadana"

*02		Plot
twoway	(scatter Gobierno year , connect(direct) msymbol(T) lcolor(maroon) mcolor(maroon)),				///
		graphregion(color(white)) ylabel(1(1)7)  		///
		ytitle("Nota") xtitle("")		///
		legend(on)
						
graph export "$graphs/Government performance, Paz Ciudadana.pdf", replace

************************************************
*  				4. Bicentenario UC			   *
************************************************

*00		Import Bicentenario UC survey
import excel using "$rawdata/Bicentenario UC", firstr clear 

*01		Rescale vars
foreach var of varlist Gobierno{
	replace `var'=`var'/100
}

*02		Post in temporal file
forvalues v = 1/6{
	post `lgc' ("Bicentenario UC") (Gobierno[`v']) (year[`v'])
}

	
************************************************
*  	5. Use Temporal File and plot			   *
************************************************

*00		Close post
postclose `lgc'

use "`justice'", clear
sort year

*01		Plot

twoway	(scatter mean year if source=="CEP", connect(direct) msymbol(O) lcolor(navy) mcolor(navy) yaxis(1))					///
		(scatter mean year if source=="Latinobaro", connect(direct) msymbol(D) lcolor(maroon) mcolor(maroon) yaxis(1))	///
		(scatter mean year if source=="Bicentenar", connect(direct) msymbol(T) lcolor(gold) mcolor(gold) yaxis(1)),				///
		graphregion(color(white)) ylabel(0(0.1)1, axis(1))  		///
		ytitle("Proporción") xtitle("")		///
		legend(order(	1	"Proporción que confía, Gobierno, CEP"	2	"Proporción que confía, Gobierno, Latinobarómetro"	///
						3	"Proporción que confía, Gobierno, Bicentenario UC") r(3) size(small))
						
graph export "$graphs/Government trust, multiple DB.pdf", replace