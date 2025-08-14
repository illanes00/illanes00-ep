/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01 Cleaning Data, ENUSC 16-21 
	Author:		Lucas García
	Date:		November 11, 2022
	Version:	Stata 17

	Summary:	This dofile sets the data to check different tendencies of the 
				different common variables between the ENUSC surveys of 2016 to
				2021.			
				
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
	global graphs "$path/05 Graphs/Enusc 16 21"
	global tables "$path/06 Tables"
	

************************************************
*              1. Cleaning data                *
************************************************

*00			Opening each DB to be saved as tempfile
*01		2016
import spss "${rawdata}\base-de-datos---enusc-xiii.sav", clear
g year=2016
destring VarStrat, replace
*Other crimes
rename P14_13_1 fv_other
*Temporal file
tempfile enusc_2016
save `enusc_2016', replace

*02		2017
import spss "$rawdata/base-de-datos---xiv-enusc-2017.sav", clear
g year=2017
*Other crimes
rename P14_13_1 fv_other
*Temporal file
tempfile enusc_2017
save `enusc_2017', replace

*03		2018
import spss "$rawdata/base-de-datos---xv-enusc-2018.sav", clear
g year=2018
*Other crimes
rename P14_13_1 fv_other
*Temporal file
tempfile enusc_2018
save `enusc_2018', replace

*04		2019
import spss "$rawdata/base-de-datos---xvi-enusc-2019-(sav).sav", clear
g year=2019
rename Fact_Pers Fact_pers
*Other crimes
rename P14_77_1 fv_other
*Trust in institutions missings
forvalues val = 1/8{
	g P21a_`val'_1=.
	g P21b_`val'_1=.
}
*Temporal file
tempfile enusc_2019
rename rph_p13 rph_p12
save `enusc_2019', replace

*05		Renaming each DB to use it and append them:
foreach x in 16 17 18 19{
	*000	Año `x'
	use `enusc_20`x'', clear
	
	*000	Percepción
	*PAD
	rename P3_1_1 pad
	replace pad = 0 if pad>1 & pad!=.
	
	rename P3_2_1 pad_comuna
	replace pad_comuna = 0 if pad_comuna>1 & pad_comuna!=.
	
	rename P3_3_1 pad_barrio
	replace pad_barrio = 0 if pad_barrio>1 & pad_barrio!=.
	
	*Future Victimization
	rename P13_1_1 future_victimization
	replace future_victimization = 0 if future_victimization>1 & future_victimization!=.
	
	*¿Cuál diría usted que es la principal fuente de información que le permite
	*formarse esa opinión? País, primera opción
	rename P4_1_1 info_pais_frst
	
	*¿Cuál diría usted que es la principal fuente de información que le permite
	*formarse esa opinión? País, segunda opción
	rename P4_1_2 info_pais_scnd
	
	*¿Cuál diría usted que es la principal fuente de información que le permite
	*formarse esa opinión? Comuna, primera opción
	rename P5_1_1 info_comuna_frst
	
	*¿Cuál diría usted que es la principal fuente de información que le permite
	*formarse esa opinión? Comuna, segunda opción
	rename P5_1_2 info_comuna_scnd
	
	
	*001	Robo con violencia e intimidación
	*La última vez, ¿usted o alguien denunció el hecho?
	rename A13_1_1 denuncio_violencia

	*¿Cómo se hizo la denuncia?
	rename A14_1_1 como_denuncio_violencia

	*¿Cuál fue el principal motivo para no denunciar?
	rename A18_1_1 porque_no_denuncio_violencia


	*002	Robo por sorpresa en las personas
	*La última vez, ¿usted o alguien denunció el hecho?
	rename B10_1_1 denuncio_sorpresa

	*¿Cómo se hizo la denuncia?
	rename B11_1_1 como_denuncio_sorpresa

	*¿Cuál fue el principal motivo para no denunciar?
	rename B15_1_1 porque_no_denuncio_sorpresa


	*003	Robo con fuerza en su vivienda
	*La última vez, ¿usted o alguien denunció el hecho?
	rename C10_1_1 denuncio_vivienda

	*¿Cómo se hizo la denuncia?
	rename C11_1_1 como_denuncio_vivienda

	*¿Cuál fue el principal motivo para no denunciar?
	rename C15_1_1 porque_no_denuncio_vivienda


	*004	Hurto
	*La última vez, ¿usted o alguien denunció el hecho?
	rename D7_1_1 denuncio_hurto

	*¿Cómo se hizo la denuncia?
	rename D8_1_1 como_denuncio_hurto

	*¿Cuál fue el principal motivo para no denunciar?
	rename D12_1_1 porque_no_denuncio_hurto


	*005	Lesiones
	*La última vez, ¿usted o alguien denunció el hecho?
	rename E10_1_1 denuncio_lesiones

	*¿Cómo se hizo la denuncia?
	rename E11_1_1 como_denuncio_lesiones

	*¿Cuál fue el principal motivo para no denunciar?
	rename E15_1_1 porque_no_denuncio_lesiones


	*006	Robo o hurtos de vehículos
	*La última vez, ¿usted o alguien denunció el hecho?
	rename G10_1_1 denuncio_de_vehiculos

	*¿Cómo se hizo la denuncia?
	rename G12_1_1 como_denuncio_de_vehiculos

	*¿Cuál fue el principal motivo para no denunciar?
	rename G16_1_1 porque_no_denuncio_de_vehiculos


	*007	Robo o hurtos desde vehículos
	*La última vez, ¿usted o alguien denunció el hecho?
	rename H9_1_1 denuncio_desde_vehiculos

	*¿Cómo se hizo la denuncia?
	rename H10_1_1 como_denuncio_desde_vehiculos

	*¿Cuál fue el principal motivo para no denunciar?
	rename H14_1_1 porque_no_denuncio_desde_veh	

	
	*008	Laboral situation
	rename rph_p12 working
	
	
	*009	Insecurity sensation at night in: 
	*Walking alone in her neighborhood
	rename P10_1_1 dk_walk_alone
	
	*Alone at home
	rename P10_2_1 dk_house_alone
	
	*Waiting the public transport
	rename P10_3_1 dk_waiting_pt
	
	
	*010	What crime you think you'll be a victim in the next 12 months?
	*Burglary
	rename P14_1_1 fv_burglary
	
	*MVT
	rename P14_2_1 fv_mvt
	
	*MVT from vehicle
	rename P14_3_1 fv_mvt_fromvehicle
	
	*Larceny
	rename P14_4_1 fv_larceny
	
	*Robbery
	rename P14_5_1 fv_robbery
	
	*Theft
	rename P14_6_1 fv_theft
	
	*Assault
	rename P14_7_1 fv_assault
	
	*Economic
	rename P14_8_1 fv_economic
	
	*Threats
	rename P14_9_1 fv_threat
	
	*Graffiti
	rename P14_10_1 fv_graffiti
	
	*Vandalism
	rename P14_11_1 fv_vandalism
	
	*Cibercrimes
	rename P14_12_1 fv_ciber

	*Sexual crimes, not present in these DB
	g fv_sexual=.
	
	*011	Temporal file
	save `enusc_20`x'', replace
}


*06		2020
import spss "$rawdata/base-usuario-17-enusc-2020-sav.sav", clear
g year=2020
rename Fact_Pers Fact_pers
g rph_nivel=.
rename P3_1_1 future_victimization
replace future_victimization = 0 if future_victimization>1 & future_victimization!=.
g info_pais_frst=.
*Trust in institutions missings
forvalues val = 1/8{
	g P21a_`val'_1=.
	g P21b_`val'_1=.
}
rename rph_p9 working
*		Insecurity sensation at night in: 
	*Walking alone in her neighborhood
	rename P2_1_1 dk_walk_alone
	
	*Alone at home
	rename P2_2_1 dk_house_alone
	
	*Waiting the public transport
	rename P2_3_1 dk_waiting_pt

*		What crime you think you'll be a victim in the next 12 months?
	*Burglary
	rename P4_1_1 fv_burglary
	
	*MVT
	rename P4_2_1 fv_mvt
	
	*MVT from vehicle
	rename P4_3_1 fv_mvt_fromvehicle
	
	*Larceny
	rename P4_4_1 fv_larceny
	
	*Robbery
	rename P4_5_1 fv_robbery
	
	*Theft
	rename P4_6_1 fv_theft
	
	*Assault
	rename P4_7_1 fv_assault
	
	*Economic
	rename P4_8_1 fv_economic
	
	*Threats
	rename P4_9_1 fv_threat
	
	*Graffiti
	rename P4_10_1 fv_graffiti
	
	*Vandalism
	rename P4_11_1 fv_vandalism
	
	*Cibercrimes
	rename P4_12_1 fv_ciber
	
	*Sexual
	rename P4_13_1 fv_sexual
	
	*Other crimes
	rename P4_77_1 fv_other
*Temporal file
tempfile enusc_2020
save `enusc_2020', replace

*07		2021
import spss "$rawdata/base-usuario-18-enusc-2021-sav05142b868f1445af8f592cf582239857", clear
g year=2021
rename Fact_Pers Fact_pers
rename P4_1_1 future_victimization
replace future_victimization = 0 if future_victimization>1 & future_victimization!=.
*Trust in institutions missings
forvalues val = 1/8{
	g P21a_`val'_1=.
	g P21b_`val'_1=.
}
rename rph_situacion_laboral_a working
*		Insecurity sensation at night in: 
	*Walking alone in her neighborhood
	rename P3_1_1 dk_walk_alone
	
	*Alone at home
	rename P3_2_1 dk_house_alone
	
	*Waiting the public transport
	rename P3_3_1 dk_waiting_pt
	
*		What crime you think you'll be a victim in the next 12 months?
	*Burglary
	rename P5_1_1 fv_burglary
	
	*MVT
	rename P5_2_1 fv_mvt
	
	*MVT from vehicle
	rename P5_3_1 fv_mvt_fromvehicle
	
	*Larceny
	rename P5_4_1 fv_larceny
	
	*Robbery
	rename P5_5_1 fv_robbery
	
	*Theft
	rename P5_6_1 fv_theft
	
	*Assault
	rename P5_7_1 fv_assault
	
	*Economic
	rename P5_8_1 fv_economic
	
	*Threats
	rename P5_9_1 fv_threat
	
	*Graffiti
	rename P5_10_1 fv_graffiti
	
	*Vandalism
	rename P5_11_1 fv_vandalism
	
	*Cibercrimes
	rename P5_12_1 fv_ciber
	
	*Sexual
	rename P5_13_1 fv_sexual
	
	*Other crimes
	rename P5_77_1 fv_other

*¿Cuál diría usted que es la principal fuente de información que le permite
	*formarse esa opinión? País, primera opción
	rename P2_1_1 info_pais_frst
	
*¿Cuál diría usted que es la principal fuente de información que le permite
	*formarse esa opinión? País, segunda opción
	g info_pais_scnd=.
	
*¿Cuál diría usted que es la principal fuente de información que le permite
	*formarse esa opinión? Comuna, primera opción
	g info_comuna_frst=.
	
*¿Cuál diría usted que es la principal fuente de información que le permite
	*formarse esa opinión? Comuna, segunda opción
	g info_comuna_scnd=.
*Temporal file
tempfile enusc_2021
save `enusc_2021', replace

*08		Renaming each DB to use it and append them:
foreach x in 20 21{
	*000	Año `x'
	use `enusc_20`x'', clear
	
	*000	Percepción
	*PAD
	rename P1_1_1 pad
	replace pad = 0 if pad>1 & pad!=.
	
	rename P1_2_1 pad_comuna
	replace pad_comuna = 0 if pad_comuna>1 & pad_comuna!=.
	
	rename P1_3_1 pad_barrio
	replace pad_barrio = 0 if pad_barrio>1 & pad_barrio!=.
	
	
	*001	Robo con violencia e intimidación
	*La última vez, ¿usted o alguien denunció el hecho?
	rename A4_1_1 denuncio_violencia

	*¿Cómo se hizo la denuncia?
	rename A5_1_1 como_denuncio_violencia

	*¿Cuál fue el principal motivo para no denunciar?
	rename A6_1_1 porque_no_denuncio_violencia


	*002	Robo por sorpresa en las personas
	*La última vez, ¿usted o alguien denunció el hecho?
	rename B4_1_1 denuncio_sorpresa

	*¿Cómo se hizo la denuncia?
	rename B5_1_1 como_denuncio_sorpresa

	*¿Cuál fue el principal motivo para no denunciar?
	rename B6_1_1 porque_no_denuncio_sorpresa


	*003	Robo con fuerza en su vivienda
	*La última vez, ¿usted o alguien denunció el hecho?
	rename C3_1_1 denuncio_vivienda

	*¿Cómo se hizo la denuncia?
	rename C4_1_1 como_denuncio_vivienda

	*¿Cuál fue el principal motivo para no denunciar?
	rename C5_1_1 porque_no_denuncio_vivienda


	*004	Hurto
	*La última vez, ¿usted o alguien denunció el hecho?
	rename D4_1_1 denuncio_hurto

	*¿Cómo se hizo la denuncia?
	rename D5_1_1 como_denuncio_hurto

	*¿Cuál fue el principal motivo para no denunciar?
	rename D6_1_1 porque_no_denuncio_hurto


	*005	Lesiones
	*La última vez, ¿usted o alguien denunció el hecho?
	rename E4_1_1 denuncio_lesiones

	*¿Cómo se hizo la denuncia?
	rename E5_1_1 como_denuncio_lesiones

	*¿Cuál fue el principal motivo para no denunciar?
	rename E6_1_1 porque_no_denuncio_lesiones


	*006	Robo o hurtos de vehículos
	*La última vez, ¿usted o alguien denunció el hecho?
	rename G3_1_1 denuncio_de_vehiculos

	*¿Cómo se hizo la denuncia?
	rename G4_1_1 como_denuncio_de_vehiculos

	*¿Cuál fue el principal motivo para no denunciar?
	rename G5_1_1 porque_no_denuncio_de_vehiculos


	*007	Robo o hurtos desde vehículos
	*La última vez, ¿usted o alguien denunció el hecho?
	rename H3_1_1 denuncio_desde_vehiculos

	*¿Cómo se hizo la denuncia?
	rename H4_1_1 como_denuncio_desde_vehiculos

	*¿Cuál fue el principal motivo para no denunciar?
	rename H5_1_1 porque_no_denuncio_desde_veh	
	
	
	*008	Temporal file
	save `enusc_20`x'', replace
}


*09		Appending Datasets
*variables to be kept:
local append_vars "rph_ID enc_idr enc_region rph_edad rph_sexo rph_nivel Fact_pers Kish Fact_Hog VarStrat Conglomerado year pad* info_* VA_DC A1_1_1 B1_1_1 C1_1_1 D1_1_1 E1_1_1 G1_1_1 H1_1_1 DEN_AGREG denuncio_* como_denuncio_* porque_no_denuncio_* RVA_DC future_victimization working dk_* fv_* P21a* P21b*"
use `enusc_2016', clear

append using `enusc_2017' `enusc_2018' `enusc_2019' `enusc_2020' `enusc_2021', keep(`append_vars')

*10		Coding as Binary first question of each crime
label def binary 0 "No" 1 "Sí"
foreach x in A1_1_1 B1_1_1 C1_1_1 D1_1_1 E1_1_1 G1_1_1 H1_1_1{
	replace `x' = 0 if `x'==2
	replace `x' = . if `x'>1
	label val `x' binary 
}

*11		Replacing and labelling report variables
foreach x in denuncio_violencia denuncio_sorpresa denuncio_vivienda denuncio_hurto denuncio_lesiones denuncio_de_vehiculos denuncio_desde_vehiculos{
	replace `x' = 0 if `x'==2
	label val `x' binary
}

*12 	Checking the important variables to be appended
*Add persona ID in 2016
local append_vars "rph_ID enc_idr enc_region rph_edad rph_sexo rph_nivel Fact_pers Kish Fact_Hog VarStrat Conglomerado year pad* info_* VA_DC A1_1_1 B1_1_1 C1_1_1 D1_1_1 E1_1_1 G1_1_1 H1_1_1 DEN_AGREG denuncio_* como_denuncio_* porque_no_denuncio_* RVA_DC future_victimization working dk_* fv_* P21a* P21b*"
sum `append_vars'


*13		Coding correctly "Por qué razón no denuncia"
foreach var in porque_no_denuncio_violencia porque_no_denuncio_sorpresa porque_no_denuncio_vivienda porque_no_denuncio_hurto porque_no_denuncio_de_vehiculos porque_no_denuncio_desde_veh{
	replace `var' = 15 if `var'==14 & (year==2020 | year==2021)
}	

*First adequating each year to reference year = 2020
foreach var in porque_no_denuncio_lesiones{
	replace `var' = `var'+1 if `var'>=5 & `var'<77 & year!=2020
}

*Second adequating 2020 & 2021 to 2019 & lowers
foreach var in porque_no_denuncio_lesiones{
	replace `var' = 15 if `var' == 14 & (year==2020 | year==2021)
}
								
								
*14		Grouping age for 2016, 2017 & 2018								
g edad_aux = rph_edad if year <2019
replace rph_edad = 0 if edad_aux>=0 & edad_aux<= 14 & year<2019
replace rph_edad = 1 if edad_aux>=15 & edad_aux<= 19 & year<2019
replace rph_edad = 2 if edad_aux>=20 & edad_aux<= 24 & year<2019
replace rph_edad = 3 if edad_aux>=25 & edad_aux<= 29 & year<2019
forvalues x = 4/9{
	local y=`x'*10-10
	local z=`x'*10-1
	replace rph_edad = `x' if edad_aux>=`y' & edad_aux<= `z' & year<2019
}
replace rph_edad = 10 if edad_aux>=90 & year<2019
drop edad_aux

label def edades 	0	"Menores de 15 años"	///
					1	"15 a 19 años"			///
					2	"20 a 24 años"			///
					3	"25 a 29 años"			///
					4	"30 a 39 años"			///
					5	"40 a 49 años"			///
					6	"50 a 59 años"			///
					7	"60 a 69 años"			///
					8	"70 a 79 años"			///
					9	"80 a 89 años"			///
					10	"90 años y más"

label val rph_edad edades
	
*15		Coding correctly Information source in 2020 (non existing question that year)
replace info_pais_frst=. if year==2020	
	
*15		Save New Dataset
local append_vars "rph_ID enc_idr enc_region rph_edad rph_sexo rph_nivel Fact_pers Kish Fact_Hog VarStrat Conglomerado year pad* info_* VA_DC A1_1_1 B1_1_1 C1_1_1 D1_1_1 E1_1_1 G1_1_1 H1_1_1 DEN_AGREG denuncio_* como_denuncio_* porque_no_denuncio_* RVA_DC future_victimization working dk_* fv_* P21a* P21b*"
keep `append_vars'
save "$usedata/enusc_16_21", replace

