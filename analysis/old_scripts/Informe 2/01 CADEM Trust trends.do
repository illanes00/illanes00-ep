/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01	CADEM Trust trends
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

*00		Opening 2016-2022 dataset
import excel using "$rawdata/Cadem, evolutivo evaluación Instituciones", firstr clear sheet("Serie")

*01		Rescaling % variables
foreach var of varlist PDI-Congreso{
	replace `var'=`var'/100
}

*03		Generating Date vars
gen fake_date = _n

************************************************
*        2.	Historical Trends				   *
************************************************

*00		Plot
twoway	(scatter PDI fake_date, connect(direct) symbol(O) msize(small))						///
		(scatter Carabineros fake_date, connect(direct) symbol(D) msize(small))				///
		(scatter Fiscalía fake_date, connect(direct) symbol(T) msize(small))				///
		(scatter TribunalesdeJusticia fake_date, connect(direct) symbol(S) msize(small))	///
		(scatter Congreso fake_date, connect(direct) symbol(S) msize(small))				///
		(scatter DefensoríaPenalPública fake_date, connect(direct) symbol(X) msize(small)),	///
		graphregion(color(white)) ytitle("Proporción") xtitle("") xline(6.5, lpattern(dash))	///
		xlab(1 "2015" 2 "2016" 3 "2017" 4 "2018" 5 "2019" 6 "2020" 7 "2021m1" 12 "2021m6" 	///
		17 "2022m1" 21 "2022m6" 26 "2023m1", valuelabel labsize(small) 	///
		angle(60)) ylab(0(0.1)1) text(0.9 3.5 "Promedios Anuales", size(small))	///
		legend(on size(small))
		
graph export "$graphs/CADEM, Confianza en instituciones, serie histórica.pdf", replace