/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01 Homicides trends, Minsal
	Author:		Lucas García
	Date:		November 20, 2022
	Version:	Stata 17

	Summary:	This dofile plots gun shot deaths trends using data from Health 
				Ministery.
				
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
*              1. Data 		     			   *
************************************************

*00		Open DB
import delimited using "$rawdata/DEFUNCIONES_FUENTE_DEIS_2016_2022_10112022", clear

*01 	Renaming variables
rename	(v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18 v19 v20 v21 v22 v23 v24 v25 v26 v27)	///
		(Año Fecha Sexo Edad_tipo Edad_cant codigo_Comuna glosa_comuna glosa_region diag1 capitulo_diag1 glosa_capitulo_diag1 codigo_grupo_diag1 glosa_grupo_diag1 codigo_categoria_diag1 glosa_categoria_diag1 codigo_subcategoria_diag1 glosa_subcategoria_diag1 diag2 capitulo_diag2 glosa_capitulo_diag2 codigo_grupo_diag2 glosa_grupo_diag2 codigo_categoria_diag2 glosa_categoria_diag2 codigo_subcategoria_diag2 glosa_subcategoria_diag2 lugar_defuncion)
		
*02		Encoding reasons of death (glosa_categoria_diag2)
encode glosa_categoria_diag2, gen(razones)

tab razones

*03		Keeping relevant info
preserve
keep if razones==7 | razones==8 | razones==9 | razones==81 | razones==82
g unidad = 1

*04		Unifying info
collapse (sum) unidad , by(Año)
twoway	(scatter unidad Año, connect(direct)) , graphregion(color(white))  ///
		ytitle("Frecuencia") xtitle("")
		
graph export "$graphs/DEIS, defunciones por disparos de armas de fuego, 2022 08 noviembre.pdf", replace
graph export "$graphs/DEIS, defunciones por disparos de armas de fuego, 2022 08 noviembre.png", replace
save "$usedata/deis_2022_08_nov", replace
restore

*			Now each year until november eighth
*00		Encoding "Fecha"
encode Fecha, gen(fecha_code)

*03		Keeping relevant info
preserve
keep if razones==7 | razones==8 | razones==9 | razones==81 | razones==82
g unidad = 1

drop if (fecha_code>=322 & fecha<=361) | (fecha_code>=679 & fecha<=728) | (fecha_code>=1045 & fecha<=1096) | (fecha_code>=1409 & fecha<=1461) | (fecha_code>=1775 & fecha<=1827) | (fecha_code>=2141 & fecha<=2192)

*04		Unifying info
collapse (sum) unidad , by(Año)
twoway	(scatter unidad Año, connect(direct)) , graphregion(color(white))  ///
		ytitle("Frecuencia") xtitle("")
		
graph export "$graphs/DEIS, defunciones por disparos de armas de fuego, todos 08 noviembre.pdf", replace
graph export "$graphs/DEIS, defunciones por disparos de armas de fuego, todos 08 noviembre.png", replace

save "$usedata/deis_08_nov", replace
restore


