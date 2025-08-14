/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01 Theft trends, Fiscalía
	Author:		Lucas García
	Date:		November 20, 2022
	Version:	Stata 17

	Summary:	This dofile plots theft trends using data from Fiscalia.
				
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
*              1. Data 16-21     			   *
************************************************

*Use Ine projections and Collapse to keep relevant info
use "$usedata/ine_projections_16_22", clear

collapse (sum) poblacion, by(Año)

tempfile data
save `data'

*Import Fiscalia Dataset with thefts
import excel using "$rawdata/Robos, Imputados Conocidos y Desconocidos a nivel país, hasta 2021", firstr clear

merge 1:1  Año using "`data'", nogen

*Graph
twoway	(scatter ConocidosTotales Año if Año<2022, connect(direct)), ///
		graphregion(color(white)) ylabel(0(0.1)0.2)