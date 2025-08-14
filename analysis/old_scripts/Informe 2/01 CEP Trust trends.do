/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01	CEP Trust trends
	Author:		Lucas García
	Date:		February 28, 2023
	Version:	Stata 17

	Summary:	This dofile plots institutional trust trends from 2015 til 2023, 
				for different periodicity and institutions.
				
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
*              1. Cleaning DB 				   *
************************************************

*00		Opening CEP historic dataset
use "$rawdata/base_consolidada_2000_2022_v2 CEP.dta", clear

*Keep relevant vars
keep pond estrato secu encuesta_a encuesta_m confianza_6_r confianza_6_h confianza_6_p confianza_6_d confianza_6_r confianza_6_k sexo edad gse


*01		Declaring as survey Data Set
svyset secu [pweight=pond], strata(estrato) singleunit(certainty) vce(linearized)

*02		Generating dummy variables from trust indicators
foreach var of varlist confianza_*{
	g dummy_`var'=(`var'<=2) 
}

*03		Generating Date vars
egen date_str = concat(encuesta_a encuesta_m) , punct("_")
gen date=date(date_str, "YM") 
format date %tdM_CY
drop date_str

*Unique values of date
unique date, by(date)
sort _Unique date

************************************************
*        2.	Historical Trends				   *
************************************************

*00		Preparing temporal file to input each date average of each var
tempname lgc
tempfile cep
postfile `lgc' str30 institution double(mean date) using `cep', replace

*01		Tribunales de Justicia
quietly svy: mean dummy_confianza_6_d , over(date)
mat table = e(b)

forvalues v = 1/47{
	post `lgc' ("Tribunales de Justicia") (table[1,`v']) (date[`v'])
}

*02		Carabineros
quietly svy: mean dummy_confianza_6_h , over(date)
mat table = e(b)

forvalues v = 1/47{
	post `lgc' ("Carabineros") (table[1,`v']) (date[`v'])
}

*03		Congress
quietly svy: mean dummy_confianza_6_k , over(date)
mat table = e(b)

forvalues v = 1/47{
	post `lgc' ("Congreso") (table[1,`v']) (date[`v'])
}

*04		Ministerio Público
quietly svy: mean dummy_confianza_6_p , over(date)
mat table = e(b)

forvalues v = 1/47{
	post `lgc' ("Ministerio Público") (table[1,`v']) (date[`v'])
}

*05		PDI
quietly svy: mean dummy_confianza_6_r , over(date)
mat table = e(b)

forvalues v = 1/47{
	post `lgc' ("PDI") (table[1,`v']) (date[`v'])
}

*06		Open Temporal File and plot
postclose `lgc'

preserve
use "`cep'", clear
format date %tdM_CY
g year = year(date)

*Declare as panel dataset
encode institution, gen(institucion)
drop institution
xtset institucion date

*Replace 0s as missing
replace mean=. if mean==0

*Plot
twoway	(scatter mean date if institucion==1 & date>=td(01apr2000) & date<=td(01dec2022), connect(direct) symbol(O) msize(small))	///
		(scatter mean date if institucion==2 & date>=td(01apr2000) & date<=td(01dec2022), connect(direct) symbol(D) msize(small))	///
		(scatter mean date if institucion==3 & date>=td(01apr2000) & date<=td(01dec2022), connect(direct) symbol(T) msize(small))	///
		(scatter mean date if institucion==4 & date>=td(01apr2000) & date<=td(01dec2022), connect(direct) symbol(S) msize(small))	///
		(scatter mean date if institucion==5 & date>=td(01apr2000) & date<=td(01dec2022), connect(direct) symbol(X) msize(small)), 	///
		graphregion(color(white)) ytitle("Proporción") xtitle("")				///
		legend(order(1 "Carabineros" 2 "Congreso" 3 "Ministerio Público" 		///
		4 "PDI" 5 "Tribunales de Justicia") size(small)) xlab(,labsize(small) angle(60)) ylab(0(0.1)1)

graph export "$graphs/Confianza en instituciones, CEP, serie histórica.pdf", replace

*Plot only congress
collapse (mean) mean, by(institucion year)
label var mean "Ministerio Público, CEP"
twoway 	(scatter mean year if year>=2011 & institucion==3, connect(direct) symbol(O) msize(small)),	///
		graphregion(color(white)) ytitle("Proporción") xtitle("") legend(on)	///
		ylab(0(0.1)1)

graph export "$graphs/Confianza en Ministerio Público, CEP, serie histórica.pdf", replace
		
		
restore