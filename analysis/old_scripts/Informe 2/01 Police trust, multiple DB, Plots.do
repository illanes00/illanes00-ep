/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01	Police trust, multiple DB, Plots
	Author:		Lucas García
	Date:		March 02, 2023
	Version:	Stata 17

	Summary:	This dofile plots Police trust trends using 4 different data 
				sources: CEP, CADEM, Latinobarometro and LAPOP.
				
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
tempfile police
postfile `lgc' str10 source double(mean year) using `police', replace

*01		Opening CEP DB
use "$rawdata/base_consolidada_2000_2022_v2 CEP.dta", clear

*Keep relevant vars
keep pond estrato secu encuesta_a encuesta_m confianza_6_h 

*02		Declaring as survey Data Set
svyset secu [pweight=pond], strata(estrato) singleunit(certainty) vce(linearized)

*03		Generating dummy variables from trust indicators
foreach var of varlist confianza_*{
	g dummy_`var'=(`var'<=2)
}

*04		Police Trust annual trend
drop if confianza_6_h==.
quietly svy: mean dummy_confianza_6_h , over(encuesta_a)
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
collapse (mean) d_police if chile==1, by(year)

*02		Post in temporal file
forvalues v = 1/6{
	post `lgc' ("Latinobarometro") (d_police[`v']) (year[`v'])
}	


************************************************
*  				3. LAPOP					   *
************************************************

*00		Use LAPOP all countries
use "$usedata/LAPOP all countries.dta", clear

*01		Collapse chilean average
g chile=(pais==13)

collapse (mean) police if chile==1, by(year)

*02		Post in temporal file
forvalues v = 1/5{
	post `lgc' ("LAPOP") (police[`v']) (year[`v'])
}


************************************************
*  				4. Paz Ciudadana			   *
************************************************

*00		Use Paz Ciudadana
import excel using "$rawdata/Paz Ciudadana", firstr clear 

g year=year(date)
destring ConfianzaCarabineros, replace dpcomma
replace ConfianzaCarabineros = ConfianzaCarabineros/100

*Collapse Year level
collapse (mean) ConfianzaCarabineros, by(year)

*02		Post in temporal file
forvalues v = 1/11{
	post `lgc' ("PC") (ConfianzaCarabineros[`v']) (year[`v'])
}


************************************************
*  				5. ENUSC					   *
************************************************

*2015
import spss "$rawdata/8. ENUSC XII Base Usuario 2015.sav", clear
g year=2015
egen VarStrat = concat(year enc_comuna)
svyset enc_idr [pweight=Fact_pers_15reg_nuevo], strata(VarStrat) singleunit(certainty)
g police = (P21b_1_1==3 | P21b_1_1==4) if P21b_1_1<=4 & P21a_1_1==1
svy: mean police
mat table = r(table)

post `lgc' ("ENUSC") (table[1,1]) (2015)

*00		Open Database
use "$usedata/enusc_16_21", clear

*01		Set as survey
svyset enc_idr [pweight=Fact_pers], strata(VarStrat) singleunit(certainty)

*Adapt variable in order to make it binary
g police = (P21b_1_1==3 | P21b_1_1==4) if P21b_1_1<=4 & P21a_1_1==1

svy: mean police, over(year)
mat table = r(table)

forvalues val = 1/3{
	local year = `val'+2015
	post `lgc' ("ENUSC") (table[1,`val']) (`year')
}



************************************************
*  	6. Use Temporal File and plot			   *
************************************************

*00		Close post
postclose `lgc'

use "`police'", clear

*01		Plot
twoway	(scatter mean year if source=="CEP", connect(direct) msymbol(O) lcolor(navy) mcolor(navy) yaxis(1))					///
		(scatter mean year if source=="Latinobaro", connect(direct) msymbol(D) lcolor(maroon) mcolor(maroon) yaxis(1))	///
		(scatter mean year if source=="PC", connect(direct) msymbol(T) lcolor(gold) mcolor(gold) yaxis(1))	///
		(scatter mean year if source=="LAPOP", connect(direct) msymbol(S) lcolor(dkgreen) mcolor(dkgreen) yaxis(2)),				///
		graphregion(color(white)) ylabel(0(0.1)1, axis(1)) ylabel(1(1)7, axis(2)) 		///
		ytitle("Proporción que confía", axis(1)) ytitle("Nota", axis(2)) xtitle("")		///
		legend(order(	1	"Proporción que confía, CEP"	3	"Proporción que confía, Paz Ciudadana"	///
						2	"Proporción que confía, Latinobarómetro"	4	"Confianza (Nota), LAPOP") r(4))
						
graph export "$graphs/Police trust, multiple DB.pdf", replace

*02		Plot with ENUSC
twoway	(scatter mean year if source=="CEP", connect(direct) msymbol(O) lcolor(navy) mcolor(navy) yaxis(1))					///
		(scatter mean year if source=="Latinobaro", connect(direct) msymbol(D) lcolor(maroon) mcolor(maroon) yaxis(1))	///
		(scatter mean year if source=="PC", connect(direct) msymbol(T) lcolor(gold) mcolor(gold) yaxis(1))	///
		(scatter mean year if source=="ENUSC", connect(direct) msymbol(X) lcolor(purple) mcolor(purple) yaxis(1))	///
		(scatter mean year if source=="LAPOP", connect(direct) msymbol(S) lcolor(dkgreen) mcolor(dkgreen) yaxis(2)),				///
		graphregion(color(white)) ylabel(0(0.1)1, axis(1)) ylabel(1(1)7, axis(2)) 		///
		ytitle("Proporción que confía", axis(1)) ytitle("Nota", axis(2)) xtitle("")		///
		legend(order(	1	"Proporción que confía, CEP"	3	"Proporción que confía, Paz Ciudadana"	///
						2	"Proporción que confía, Latinobarómetro"	5	"Confianza (Nota), LAPOP"	///
						4	"Proporción que confía, ENUSC") r(5))
	
graph export "$graphs/Police trust, multiple DB, with ENUSC.pdf", replace