/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01 ENUSC Variables 
	Author:		Lucas García
	Date:		March 03, 2023
	Version:	Stata 17

	Summary:	This dofile uses ENUSC Database in order to plot the trends of
				Police Trust from 2016 until 2019.
				
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
	global graphs "$path/05 Graphs"
	global tables "$path/06 Tables"
	

************************************************
*       1. Defining data as survey      	   *
************************************************

*00		Open Database
use "$usedata/enusc_16_21", clear

*01		Set as survey
svyset enc_idr [pweight=Fact_pers], strata(VarStrat) singleunit(certainty)


************************************************
*  2. Plotting trends of police trust		   *
************************************************

*00		Trend of PAD Variable
tempname lgc
tempfile police
postfile `lgc' mean_pais year using `police', replace

*Adapt variable in order to make it binary
g police = (P21b_1_1==3 | P21b_1_1==4) if P21b_1_1<=4 & P21a_1_1==1

svy: mean police, over(year)
mat table = r(table)

forvalues val = 1/3{
	local year = `val'+2015
	post `lgc' (table[1,`val']) (`year')
}

postclose `lgc'

use "`police'", clear

label var mean_pais "Confianza en la policía, ENUSC"

twoway (scatter mean_pais year, connect(direct) lcolor(navy) mcolor(navy)), ytitle("Proporción") ylabel(0(0.1)1) legend(on) xtitle("") xlabel(2016(1)2018)