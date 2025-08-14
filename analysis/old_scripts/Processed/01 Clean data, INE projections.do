/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01 Clean data, INE projections
	Author:		Lucas García
	Date:		November 29, 2022
	Version:	Stata 17

	Summary:	This dofile sets the population projections from INE for each region
				from 2002 to 2035. It keeps jist 2016-2022
				
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
*              1. Cleaning data				   *
************************************************

*00 	Open DB
import delimited using "$rawdata/ine_estimaciones-y-proyecciones-2002-2035_base-2017_region_base", clear 

*01		Collapsing to sum each region and year
collapse (sum) a2002-a2035, by(region) 

*02		Keeping relevant years
keep region a2016-a2022

*03 	Reshaping
reshape long a, i(region) j(Año)
rename a poblacion

*04		15 regions
g pob_aux= poblacion if region==16
bys Año: egen pob_aux2=max(pob_aux)
replace poblacion=poblacion+pob_aux2 if region==8
drop pob_aux pob_aux2
drop if region==16

*04		Save DB
save "$usedata/ine_projections_16_22", replace