/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01 How people inform, ENUSC
	Author:		Lucas García
	Date:		November 11, 2022
	Version:	Stata 17

	Summary:	This dofile plots a bar graph woth how people inform using enusc
				2016, 2017, 2017, 2019 & 2021.
				
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
*              1. Preparing data, 2021         *
************************************************

*00			Opening DB
use "$usedata/enusc_16_21", clear

*01 		Set as survey, individual level
svyset rph_ID [pweight=Fact_pers], strata(VarStrat) singleunit(certainty)

*02			Tabulating and keeping info of how people inform
svy: tab info_pais_frst if year==2021, nolabel
mat table_aux=e(Prop)
mat list table_aux

local aux = table_aux[7,1]
local aux_2 = table_aux[8,1]
local aux_3 = `aux'+`aux_2'

local aux_4 = table_aux[2,1]
local aux_5 = table_aux[3,1]
local aux_6 = `aux_4'+`aux_5'

mat table=J(8,1,1)

mat table[1,1]=table_aux[1,1]
mat table[2,1]=`aux_6'
mat table[3,1]=table_aux[4,1]
mat table[4,1]=table_aux[5,1]
mat table[5,1]=table_aux[6,1]
mat table[6,1]=`aux_3'
mat table[7,1]=table_aux[9,1]
mat table[8,1]=table_aux[10,1]
mat list table

*03			Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop indicador using `inform', replace

*03 		Now filling temporal file
post `lgc' (table[4,1]) (1)
post `lgc' (table[3,1]) (2)
post `lgc' (table[1,1]) (3)
post `lgc' (table[2,1]) (4)
post `lgc' (table[5,1]) (5)
post `lgc' (table[7,1]) (6)
post `lgc' (table[6,1]) (7)
post `lgc' (table[8,1]) (77)

postclose `lgc'

preserve 
use "`inform'", clear

label val indicador labels27
replace indicador = 8 if indicador==77

twoway	(bar prop indicador if indicador==1, bcolor(maroon) barwidth(0.75))		///
		(bar prop indicador if indicador==2, bcolor(midblue) barwidth(0.75))		///
		(bar prop indicador if indicador==3, bcolor(sand) barwidth(0.75))		///
		(bar prop indicador if indicador==4, bcolor(dknavy) barwidth(0.75))		///
		(bar prop indicador if indicador==5, bcolor(gold) barwidth(0.75))		///
		(bar prop indicador if indicador==6, bcolor(erose) barwidth(0.75))		///
		(bar prop indicador if indicador==7, bcolor(forest_green) barwidth(0.75))		///
		(bar prop indicador if indicador==8, bcolor(midgreen) barwidth(0.75)),	///
		ytitle("Proporción", size(small)) xtitle("") xlabel(none)	///
		graphregion(color(white))		///
		legend(order(	1	"Noticias en televisión"	///
						2	"Información recogida en redes sociales"	///
						3	"Experiencia personal"		///
						4	"Información de otras personas, conocidos o familiares"	///
						5	"Programas en televisión (no noticias)"		///
						6	"La radio"	///
						7	"Periódicos nacionales, regionales o locales (papel y/o electrónico)"	///
						8	"Otros") size(tiny) symysize(0.05cm) symxsize(0.15cm)	///
						region(c(none)))	
						
graph export "$graphs/Cómo se informan 2021.pdf", replace
graph export "$graphs/Cómo se informan 2021.png", replace
restore

*04			Do they inform differently by age?
g young = (rph_edad>=5) if Kish==1 & year==2021

*	Proportion of the group
svy: mean young
mat aux = e(b)
local mean = aux[1,1]
local old  = 1-`mean'
local old = round(`old', .0001)
local old =`old'*100

*	Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop indicador young  using `inform', replace

*	Now filling temporal file

*Olders
svy: tab info_pais_frst if young==0, nolabel
mat table_aux=e(Prop)
local aux = table_aux[7,1]
local aux_2 = table_aux[8,1]
local aux_3 = `aux'+`aux_2'

mat table=J(9,1,1)
forvalues x = 1/6{
	local v = table_aux[`x',1] 
	mat table[`x',1]=`v'	
}
mat table[7,1]=`aux_3'
mat table[8,1]=table_aux[9,1]
mat table[9,1]=table_aux[10,1]
mat list table

post `lgc' (table[5,1]) (1) (1)
post `lgc' (table[1,1]) (2) (1)
post `lgc' (table[4,1]) (3) (1)
post `lgc' (table[3,1]) (4) (1) 
post `lgc' (table[6,1]) (5) (1)
post `lgc' (table[7,1]) (6) (1)
post `lgc' (table[2,1]) (7) (1)
post `lgc' (table[8,1]) (8) (1)
post `lgc' (table[9,1]) (77) (1)


*Youngsters
svy: tab info_pais_frst if young==1, nolabel
mat table_aux=e(Prop)
local aux = table_aux[7,1]
local aux_2 = table_aux[8,1]
local aux_3 = `aux'+`aux_2'

mat table=J(9,1,1)
forvalues x = 1/6{
	local v = table_aux[`x',1] 
	mat table[`x',1]=`v'	
}
mat table[7,1]=`aux_3'
mat table[8,1]=table_aux[9,1]
mat table[9,1]=table_aux[10,1]
mat list table

post `lgc' (table[5,1]) (1) (0)
post `lgc' (table[1,1]) (2) (0)
post `lgc' (table[4,1]) (3) (0)
post `lgc' (table[3,1]) (4) (0)
post `lgc' (table[6,1]) (5) (0)
post `lgc' (table[7,1]) (6) (0)
post `lgc' (table[2,1]) (7) (0)
post `lgc' (table[8,1]) (8) (0)
post `lgc' (table[9,1]) (77) (0)

postclose `lgc'

preserve 
use "`inform'", clear

label val indicador labels27
replace indicador = 9 if indicador==77

label def young 0 "Mayores de 40" 1  "Menores de 40" 
label val young young

twoway	(bar prop indicador if indicador==1, by(young, note("") graphregion(color(white))) bcolor(maroon) barwidth(0.75))		///
		(bar prop indicador if indicador==2, by(young) bcolor(midblue) barwidth(0.75))		///
		(bar prop indicador if indicador==3, by(young) bcolor(sand) barwidth(0.75))		///
		(bar prop indicador if indicador==4, by(young) bcolor(dknavy) barwidth(0.75))		///
		(bar prop indicador if indicador==5, by(young) bcolor(gold) barwidth(0.75))		///
		(bar prop indicador if indicador==6, by(young) bcolor(erose) barwidth(0.75))		///
		(bar prop indicador if indicador==7, by(young) bcolor(forest_green) barwidth(0.75))		///
		(bar prop indicador if indicador==8, by(young) bcolor(khaki) barwidth(0.75))		///
		(bar prop indicador if indicador==9, by(young) bcolor(gray) barwidth(0.75)),		///
		ytitle("Proporción", size(small)) xtitle("") xlabel(none)	///
		legend(order(	1	"Noticias en televisión"	///
						2	"Experiencia personal"		///
						3	"Información recogida en redes sociales"			///
						4	"Información de otras personas"	///
						5	"Programas en televisión (no noticias)"		///
						6	"Periódicos nacionales, regionales o locales (papel y/o electrónico)"	///
						7	"Información proporcionada por familiares"	///
						8	"La radio"	///
						9	"Otros") size(vsmall) symysize(0.05cm) symxsize(0.15cm)	///
						region(c(none)))	
						
graph export "$graphs/Cómo se informan 2021, por edad.pdf", replace
restore



*04			Do they inform differently by education?
g low = 1 if (rph_nivel==0 | rph_nivel==1 | rph_nivel==2) & Kish==1 & year==2021
replace low = 1 if (rph_nivel<=8 | rph_nivel==90) & year<=2019
g high = 1 if (rph_nivel==3) & Kish==1 & year==2021
replace high = 1 if (rph_nivel>=9 & rph_nivel<=13) & year<=2019

*	Proportion of the group
replace low=0 if (high==1) 

foreach v in low {
	svy: mean `v'
	mat aux = e(b)
	mat list aux
	local mean = aux[1,1]
	di `mean'
	local `v'_aux = round(`mean', .0001)
	local `v'_aux =``v'_aux'*100	
}

di `low_aux'


*	Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop indicador nivel using `inform', replace

*	Now filling temporal file

*Low
svy: tab info_pais_frst if low==1 & year==2021,  nolabel
mat table_aux=e(Prop)
local aux = table_aux[7,1]
local aux_2 = table_aux[8,1]
local aux_3 = `aux'+`aux_2'

mat table=J(9,1,1)
forvalues x = 1/6{
	local v = table_aux[`x',1] 
	mat table[`x',1]=`v'	
}
mat table[7,1]=`aux_3'
mat table[8,1]=table_aux[9,1]
mat table[9,1]=table_aux[10,1]
mat list table

post `lgc' (table[5,1]) (1) (0)
post `lgc' (table[4,1]) (2) (0)
post `lgc' (table[1,1]) (3) (0)
post `lgc' (table[3,1]) (4) (0)
post `lgc' (table[6,1]) (5) (0)
post `lgc' (table[8,1]) (6) (0)
post `lgc' (table[2,1]) (7) (0)
post `lgc' (table[7,1]) (8) (0)
post `lgc' (table[9,1]) (77) (0)

*Medium
svy: tab info_pais_frst if high==1 & year==2021, nolabel
mat table_aux=e(Prop)
local aux = table_aux[7,1]
local aux_2 = table_aux[8,1]
local aux_3 = `aux'+`aux_2'

mat table=J(9,1,1)
forvalues x = 1/6{
	local v = table_aux[`x',1] 
	mat table[`x',1]=`v'	
}
mat table[7,1]=`aux_3'
mat table[8,1]=table_aux[9,1]
mat table[9,1]=table_aux[10,1]
mat list table

post `lgc' (table[5,1]) (1) (1)
post `lgc' (table[4,1]) (2) (1)
post `lgc' (table[1,1]) (3) (1)
post `lgc' (table[3,1]) (4) (1)
post `lgc' (table[6,1]) (5) (1)
post `lgc' (table[8,1]) (6) (1)
post `lgc' (table[2,1]) (7) (1)
post `lgc' (table[7,1]) (8) (1)
post `lgc' (table[9,1]) (77) (1)

postclose `lgc'

preserve 
use "`inform'", clear

label val indicador labels27
replace indicador = 10 if indicador==77

label def educ 0 "Sin educación superior" 1 "Con educación superior"
label val nivel educ

twoway	(bar prop indicador if indicador==1, by(nivel, note("") graphregion(color(white))) subtitle(, size(small)) bcolor(maroon) barwidth(0.75))		///
		(bar prop indicador if indicador==2, by(nivel) bcolor(midblue) barwidth(0.75))		///
		(bar prop indicador if indicador==3, by(nivel) bcolor(sand) barwidth(0.75))		///
		(bar prop indicador if indicador==4, by(nivel) bcolor(dknavy) barwidth(0.75))		///
		(bar prop indicador if indicador==5, by(nivel) bcolor(gold) barwidth(0.75))		///
		(bar prop indicador if indicador==6, by(nivel) bcolor(erose) barwidth(0.75))		///
		(bar prop indicador if indicador==7, by(nivel) bcolor(forest_green) barwidth(0.75))		///
		(bar prop indicador if indicador==8, by(nivel) bcolor(midgreen) barwidth(0.75))		///
		(bar prop indicador if indicador==9, by(nivel) bcolor(cyan) barwidth(0.75)),		///
		ytitle("Proporción", size(small)) xtitle("") xlabel(none)	///
		legend(order(	1	"Noticias en televisión"	///
						2	"Información recogida en redes sociales"			///
						3	"Experiencia personal" 			///
						4	"Información de otras personas"	///
						5	"Programas en televisión (no noticias)"		///
						6	"La radio"	///
						7	"Información proporcionada por familiares"	///
						8	"Periódicos nacionales, regionales o locales (papel y/o electrónico)")	///
						size(vsmall) symysize(0.05cm) symxsize(0.15cm)	///
						region(c(none)))	
						
graph export "$graphs/Cómo se informan 2021, educación.pdf", replace
restore



*05			Do they inform differently by gender?
g hombre = 1 if rph_sexo==1 & Kish==1 & year==2021
g mujer = 1 if rph_sexo==2 & Kish==1 & year==2021

*	Proportion of the group
replace hombre=0 if (mujer==1) & year==2021

foreach v in hombre {
	svy: mean `v'
	mat aux = e(b)
	mat list aux
	local mean = aux[1,1]
	di `mean'
	local `v'_aux = round(`mean', .0001)
	local `v'_aux =``v'_aux'*100	
}

di `hombre_aux'


*	Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop indicador nivel using `inform', replace

*	Now filling temporal file

*Hombre
svy: tab info_pais_frst if hombre==1 & year==2021, nolabel
mat table_aux=e(Prop)
local aux = table_aux[7,1]
local aux_2 = table_aux[8,1]
local aux_3 = `aux'+`aux_2'

mat table=J(9,1,1)
forvalues x = 1/6{
	local v = table_aux[`x',1] 
	mat table[`x',1]=`v'	
}
mat table[7,1]=`aux_3'
mat table[8,1]=table_aux[9,1]
mat table[9,1]=table_aux[10,1]
mat list table

post `lgc' (table[5,1]) (1) (0)
post `lgc' (table[4,1]) (2) (0)
post `lgc' (table[1,1]) (3) (0)
post `lgc' (table[3,1]) (4) (0)
post `lgc' (table[6,1]) (5) (0)
post `lgc' (table[7,1]) (6) (0)
post `lgc' (table[8,1]) (7) (0)
post `lgc' (table[2,1]) (8) (0)
post `lgc' (table[9,1]) (77) (0)

*Mujer
svy: tab info_pais_frst if mujer==1 & year==2021, nolabel
mat table_aux=e(Prop)
local aux = table_aux[7,1]
local aux_2 = table_aux[8,1]
local aux_3 = `aux'+`aux_2'

mat table=J(9,1,1)
forvalues x = 1/6{
	local v = table_aux[`x',1] 
	mat table[`x',1]=`v'	
}
mat table[7,1]=`aux_3'
mat table[8,1]=table_aux[9,1]
mat table[9,1]=table_aux[10,1]
mat list table

post `lgc' (table[5,1]) (1) (1)
post `lgc' (table[4,1]) (2) (1)
post `lgc' (table[1,1]) (3) (1)
post `lgc' (table[3,1]) (4) (1)
post `lgc' (table[6,1]) (5) (1)
post `lgc' (table[8,1]) (6) (1)
post `lgc' (table[7,1]) (7) (1)
post `lgc' (table[2,1]) (8) (1)
post `lgc' (table[9,1]) (77) (1)

postclose `lgc'

preserve 
use "`inform'", clear

label def sexo 0 "Hombre" 1 "Mujer"
label val nivel sexo

twoway	(bar prop indicador if indicador==1, by(nivel,note("") graphregion(color(white)) ) subtitle(, size(small)) bcolor(maroon) barwidth(0.75))		///
		(bar prop indicador if indicador==2, by(nivel) bcolor(midblue) barwidth(0.75))		///
		(bar prop indicador if indicador==3, by(nivel) bcolor(sand) barwidth(0.75))		///
		(bar prop indicador if indicador==4, by(nivel) bcolor(dknavy) barwidth(0.75))		///
		(bar prop indicador if indicador==5, by(nivel) bcolor(gold) barwidth(0.75))		///
		(bar prop indicador if indicador==6, by(nivel) bcolor(erose) barwidth(0.75))		///
		(bar prop indicador if indicador==7, by(nivel) bcolor(forest_green) barwidth(0.75))		///
		(bar prop indicador if indicador==8, by(nivel) bcolor(midgreen) barwidth(0.75)),		///
		ytitle("Proporción", size(small)) xtitle("") xlabel(none)	///
		legend(order(	1	"Noticias en televisión"	///
						2	"Información recogida en redes sociales"			///
						3	"Experiencia personal" 			///
						4	"Información de otras personas"	///
						5	"Programas en televisión (no noticias)"		///
						6	"La radio"	///
						7	"Periódicos nacionales, regionales o locales (papel y/o electrónico)"	///
						8	"Información proporcionada por familiares")	///
						size(vsmall) symysize(0.05cm) symxsize(0.15cm)	///
						region(c(none)))	
						
graph export "$graphs/Cómo se informan 2021, sexo.pdf", replace
restore


************************************************
*              1. Preparing data, 2016-2019    *
************************************************

		***			Country level, first option
*00			Opening DB
use "$usedata/enusc_16_21", clear

*01 		Set as survey, individual level
svyset rph_ID [pweight=Fact_pers], strata(VarStrat) singleunit(certainty)
replace rph_ID=_n if year==2016

*02			Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop indicador year using `inform', replace

*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_pais_frst if year==201`x', nolabel 
mat table_`x'_aux=e(Prop)	
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

local aux_4 = table_`x'_aux[2,1]
local aux_5 = table_`x'_aux[3,1]
local aux_6 = `aux_4'+`aux_5'

mat table_`x'=J(7,1,1)
	local v = table_`x'_aux[1,1] 
	mat table_`x'[1,1]=`v'
	
	mat table_`x'[2,1]=`aux_6'
	
forvalues k = 4/5{
	local v = table_`x'_aux[`k',1] 
	local b = `k'-1
	mat table_`x'[`b',1]=`v'	
}
mat table_`x'[5,1]=`aux_3'
mat table_`x'[6,1]=table_`x'_aux[8,1]
mat table_`x'[7,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[3,1]) (1) (201`x')
post `lgc' (table_`x'[2,1]) (2) (201`x')
post `lgc' (table_`x'[1,1]) (3) (201`x')
post `lgc' (table_`x'[4,1]) (4) (201`x')
post `lgc' (table_`x'[6,1]) (5) (201`x')
post `lgc' (table_`x'[5,1]) (6) (201`x')
post `lgc' (table_`x'[7,1]) (7) (201`x')
}


postclose `lgc'

preserve 
use "`inform'", clear

label val indicador labels27

twoway	(bar prop indicador if indicador==1, by(year, note("") graphregion(color(white)) ) subtitle(, size(small)) bcolor(maroon) barwidth(0.75))		///
		(bar prop indicador if indicador==2, by(year) bcolor(midblue) barwidth(0.75))		///
		(bar prop indicador if indicador==3, by(year) bcolor(sand) barwidth(0.75))		///
		(bar prop indicador if indicador==4, by(year) bcolor(dknavy) barwidth(0.75))		///
		(bar prop indicador if indicador==5, by(year) bcolor(gold) barwidth(0.75))		///
		(bar prop indicador if indicador==6, by(year) bcolor(erose) barwidth(0.75))		///
		(bar prop indicador if indicador==7, by(year) bcolor(forest_green) barwidth(0.75)),		///
		ytitle("Proporción", size(small)) xtitle("") xlabel(none)	///
		legend(order(	1	"Noticias en televisión"	///
						2	"Información de otras personas, familiares, por boca a boca o internet"	///
						3	"Experiencia personal"  ///
						4	"Programas en televisión (no noticias)"	///
						5	"La radio"	///
						6	"Periódicos nacionales, regionales o locales (papel y/o electrónico)"	///
						7	"Otros") size(tiny) symysize(0.05cm) symxsize(0.15cm)	///
						region(c(none)))	
						
graph export "$graphs/Cómo se informan país 2016-2019.pdf", replace
graph export "$graphs/Cómo se informan país 2016-2019.png", replace
restore


*04			Do they inform differently by age?
g young = (rph_edad<5) if Kish==1

*	Proportion of the group
svy: mean young
mat aux = e(b)
local mean = aux[1,1]
local young = round(`mean', .0001)
local young =`young'*100

*	Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop indicador young year using `inform', replace

*		Youngsters	
*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_pais_frst if year==201`x' & young==1, nolabel 
mat table_`x'_aux=e(Prop)	
mat table_`x'_aux=e(Prop)
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

mat table_`x'=J(8,1,1)
forvalues k = 1/6{
	local v = table_`x'_aux[`k',1] 
	mat table_`x'[`k',1]=`v'	
}
mat table_`x'[6,1]=`aux_3'
mat table_`x'[7,1]=table_`x'_aux[8,1]
mat table_`x'[8,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[4,1]) (1) (0) (201`x')
post `lgc' (table_`x'[3,1]) (2) (0) (201`x')
post `lgc' (table_`x'[1,1]) (3) (0) (201`x')
post `lgc' (table_`x'[2,1]) (4) (0) (201`x')
post `lgc' (table_`x'[5,1]) (5) (0) (201`x')
post `lgc' (table_`x'[6,1]) (6) (0) (201`x')
post `lgc' (table_`x'[7,1]) (7) (0) (201`x')
post `lgc' (table_`x'[8,1]) (8) (0) (201`x')
}

*		Olders
*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_pais_frst if year==201`x' & young==0, nolabel 
mat table_`x'_aux=e(Prop)	
mat table_`x'_aux=e(Prop)
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

mat table_`x'=J(8,1,1)
forvalues k = 1/6{
	local v = table_`x'_aux[`k',1] 
	mat table_`x'[`k',1]=`v'	
}
mat table_`x'[6,1]=`aux_3'
mat table_`x'[7,1]=table_`x'_aux[8,1]
mat table_`x'[8,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[4,1]) (1) (1) (201`x')
post `lgc' (table_`x'[3,1]) (2) (1) (201`x')
post `lgc' (table_`x'[1,1]) (3) (1) (201`x')
post `lgc' (table_`x'[2,1]) (4) (1) (201`x')
post `lgc' (table_`x'[5,1]) (5) (1) (201`x')
post `lgc' (table_`x'[6,1]) (6) (1) (201`x')
post `lgc' (table_`x'[7,1]) (7) (1) (201`x')
post `lgc' (table_`x'[8,1]) (8) (1) (201`x')
}
postclose `lgc'

preserve 
use "`inform'", clear

label val indicador labels27
replace indicador = 10 if indicador==77

label def young 0 "Menores de 40" 1 "Mayores de 40"
label val young young

forvalues  year = 2016/2019{
twoway	(bar prop indicador if indicador==1 & year==`year', by(young, note("") graphregion(color(white))) bcolor(maroon) barwidth(0.75))		///
		(bar prop indicador if indicador==2 & year==`year', by(young) bcolor(midblue) barwidth(0.75))		///
		(bar prop indicador if indicador==3 & year==`year', by(young) bcolor(sand) barwidth(0.75))		///
		(bar prop indicador if indicador==4 & year==`year', by(young) bcolor(dknavy) barwidth(0.75))		///
		(bar prop indicador if indicador==5 & year==`year', by(young) bcolor(gold) barwidth(0.75))		///
		(bar prop indicador if indicador==6 & year==`year', by(young) bcolor(erose) barwidth(0.75))		///
		(bar prop indicador if indicador==7 & year==`year', by(young) bcolor(forest_green) barwidth(0.75))		///
		(bar prop indicador if indicador==8 & year==`year', by(young) bcolor(midgreen) barwidth(0.75)),		///
		ytitle("Proporción", size(small)) xtitle("") xlabel(none)	///
		legend(order(	1	"Noticias en televisión"	///
						2	"Información de otras personas, por boca a boca o internet"	///
						3	"Experiencia personal" ///
						4	"Información proporcionada por familiares, por boca a boca o internet"	///
						5	"Programas en televisión (no noticias)"	///
						6	"Periódicos nacionales, regionales o locales (papel y/o electrónico)" ///
						7	"La radio"		///
						8	"Otros") size(tiny) symysize(0.05cm) symxsize(0.15cm)	///
						region(c(none)))
						
graph export "$graphs/Cómo se informan país `year', por edad.pdf", replace
}

restore



*04			Do they inform differently by education?
g low = 1 if (rph_nivel==0 | rph_nivel==1 | rph_nivel==2) & Kish==1 & year==2021
replace low = 1 if (rph_nivel<=8 | rph_nivel==90) & year<=2019
g high = 1 if (rph_nivel==3) & Kish==1 & year==2021
replace high = 1 if (rph_nivel>=9 & rph_nivel<=13) & year<=2019

*	Proportion of the group
replace low=0 if (high==1)

foreach v in low {
	svy: mean `v'
	mat aux = e(b)
	mat list aux
	local mean = aux[1,1]
	di `mean'
	local `v'_aux = round(`mean', .0001)
	local `v'_aux =``v'_aux'*100	
}

di `low_aux'

*	Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop  indicador nivel year using `inform', replace

*		Low	
*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_pais_frst if year==201`x' & low==1, nolabel 
mat table_`x'_aux=e(Prop)	
mat table_`x'_aux=e(Prop)
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

mat table_`x'=J(8,1,1)
forvalues k = 1/6{
	local v = table_`x'_aux[`k',1] 
	mat table_`x'[`k',1]=`v'	
}
mat table_`x'[6,1]=`aux_3'
mat table_`x'[7,1]=table_`x'_aux[8,1]
mat table_`x'[8,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[4,1]) (1) (0) (201`x')
post `lgc' (table_`x'[1,1]) (2) (0) (201`x')
post `lgc' (table_`x'[3,1]) (3) (0) (201`x')
post `lgc' (table_`x'[2,1]) (4) (0) (201`x')
post `lgc' (table_`x'[5,1]) (5) (0) (201`x')
post `lgc' (table_`x'[7,1]) (6) (0) (201`x')
post `lgc' (table_`x'[6,1]) (7) (0) (201`x')
post `lgc' (table_`x'[8,1]) (8) (0) (201`x')
}

*		High
*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_pais_frst if year==201`x' & low==0, nolabel 
mat table_`x'_aux=e(Prop)	
mat table_`x'_aux=e(Prop)
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

mat table_`x'=J(8,1,1)
forvalues k = 1/6{
	local v = table_`x'_aux[`k',1] 
	mat table_`x'[`k',1]=`v'	
}
mat table_`x'[6,1]=`aux_3'
mat table_`x'[7,1]=table_`x'_aux[8,1]
mat table_`x'[8,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[4,1]) (1) (1) (201`x')
post `lgc' (table_`x'[1,1]) (2) (1) (201`x')
post `lgc' (table_`x'[3,1]) (3) (1) (201`x')
post `lgc' (table_`x'[2,1]) (4) (1) (201`x')
post `lgc' (table_`x'[5,1]) (5) (1) (201`x')
post `lgc' (table_`x'[7,1]) (6) (1) (201`x')
post `lgc' (table_`x'[6,1]) (7) (1) (201`x')
post `lgc' (table_`x'[8,1]) (8) (1) (201`x')
}
postclose `lgc'

preserve 
use "`inform'", clear

label def educ 0 "Sin educación superior" 1 "Con educación superior"
label val nivel educ

forvalues  year = 2016/2019{
twoway	(bar prop indicador if indicador==1 & year==`year', by(nivel, note("") graphregion(color(white)) ) bcolor(maroon) barwidth(0.75))		///
		(bar prop indicador if indicador==2 & year==`year', by(nivel) bcolor(midblue) barwidth(0.75))		///
		(bar prop indicador if indicador==3 & year==`year', by(nivel) bcolor(sand) barwidth(0.75))		///
		(bar prop indicador if indicador==4 & year==`year', by(nivel) bcolor(dknavy) barwidth(0.75))		///
		(bar prop indicador if indicador==5 & year==`year', by(nivel) bcolor(gold) barwidth(0.75))		///
		(bar prop indicador if indicador==6 & year==`year', by(nivel) bcolor(erose) barwidth(0.75))		///
		(bar prop indicador if indicador==7 & year==`year', by(nivel) bcolor(forest_green) barwidth(0.75))		///
		(bar prop indicador if indicador==8 & year==`year', by(nivel) bcolor(midgreen) barwidth(0.75)),		///
		ytitle("Proporción", size(small)) xtitle("") xlabel(none)	///
		legend(order(	1	"Noticias en televisión"	///
						2	"Experiencia personal" 	///
						3	"Información de otras personas, por boca a boca o internet" ///
						4	"Información proporcionada por familiares, por boca a boca o internet"	///
						5	"Programas en televisión (no noticias)"	///
						6	"Periódicos nacionales, regionales o locales (papel y/o electrónico)" ///
						7	"La radio"		///
						8	"Otros") size(tiny) symysize(0.05cm) symxsize(0.15cm)	///
						region(c(none)))
						
graph export "$graphs/Cómo se informan país `year', por educación.pdf", replace
}

restore


*05			Do they inform differently by gender?
g hombre = 1 if rph_sexo==1 & Kish==1
g mujer = 1 if rph_sexo==2 & Kish==1

*	Proportion of the group
replace hombre=0 if (mujer==1)

foreach v in hombre {
	svy: mean `v'
	mat aux = e(b)
	mat list aux
	local mean = aux[1,1]
	di `mean'
	local `v'_aux = round(`mean', .0001)
	local `v'_aux =``v'_aux'*100	
}

di `hombre_aux'

*	Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop  indicador nivel year using `inform', replace

*		Hombre
*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_pais_frst if year==201`x' & hombre==1, nolabel 
mat table_`x'_aux=e(Prop)	
mat table_`x'_aux=e(Prop)
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

mat table_`x'=J(8,1,1)
forvalues k = 1/6{
	local v = table_`x'_aux[`k',1] 
	mat table_`x'[`k',1]=`v'	
}
mat table_`x'[6,1]=`aux_3'
mat table_`x'[7,1]=table_`x'_aux[8,1]
mat table_`x'[8,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[4,1]) (1) (0) (201`x')
post `lgc' (table_`x'[1,1]) (2) (0) (201`x')
post `lgc' (table_`x'[3,1]) (3) (0) (201`x')
post `lgc' (table_`x'[2,1]) (4) (0) (201`x')
post `lgc' (table_`x'[5,1]) (5) (0) (201`x')
post `lgc' (table_`x'[7,1]) (6) (0) (201`x')
post `lgc' (table_`x'[6,1]) (7) (0) (201`x')
post `lgc' (table_`x'[8,1]) (8) (0) (201`x')
}

*		Mujer
*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_pais_frst if year==201`x' & hombre==0, nolabel 
mat table_`x'_aux=e(Prop)	
mat table_`x'_aux=e(Prop)
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

mat table_`x'=J(8,1,1)
forvalues k = 1/6{
	local v = table_`x'_aux[`k',1] 
	mat table_`x'[`k',1]=`v'	
}
mat table_`x'[6,1]=`aux_3'
mat table_`x'[7,1]=table_`x'_aux[8,1]
mat table_`x'[8,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[4,1]) (1) (1) (201`x')
post `lgc' (table_`x'[1,1]) (2) (1) (201`x')
post `lgc' (table_`x'[3,1]) (3) (1) (201`x')
post `lgc' (table_`x'[2,1]) (4) (1) (201`x')
post `lgc' (table_`x'[5,1]) (5) (1) (201`x')
post `lgc' (table_`x'[7,1]) (6) (1) (201`x')
post `lgc' (table_`x'[6,1]) (7) (1) (201`x')
post `lgc' (table_`x'[8,1]) (8) (1) (201`x')
}
postclose `lgc'

preserve 
use "`inform'", clear

label def mujer 0 "Hombre" 1 "Mujer"
label val nivel mujer

forvalues  year = 2016/2019{
twoway	(bar prop indicador if indicador==1 & year==`year', by(nivel, note("") graphregion(color(white))) bcolor(maroon) barwidth(0.75))		///
		(bar prop indicador if indicador==2 & year==`year', by(nivel) bcolor(midblue) barwidth(0.75))		///
		(bar prop indicador if indicador==3 & year==`year', by(nivel) bcolor(sand) barwidth(0.75))		///
		(bar prop indicador if indicador==4 & year==`year', by(nivel) bcolor(dknavy) barwidth(0.75))		///
		(bar prop indicador if indicador==5 & year==`year', by(nivel) bcolor(gold) barwidth(0.75))		///
		(bar prop indicador if indicador==6 & year==`year', by(nivel) bcolor(erose) barwidth(0.75))		///
		(bar prop indicador if indicador==7 & year==`year', by(nivel) bcolor(forest_green) barwidth(0.75))		///
		(bar prop indicador if indicador==8 & year==`year', by(nivel) bcolor(midgreen) barwidth(0.75)),		///
		ytitle("Proporción", size(small)) xtitle("") xlabel(none)	///
		legend(order(	1	"Noticias en televisión"	///
						2	"Experiencia personal" 	///
						3	"Información de otras personas, por boca a boca o internet" ///
						4	"Información proporcionada por familiares, por boca a boca o internet"	///
						5	"Programas en televisión (no noticias)"	///
						6	"Periódicos nacionales, regionales o locales (papel y/o electrónico)" ///
						7	"La radio"		///
						8	"Otros") size(tiny) symysize(0.05cm) symxsize(0.15cm)	///
						region(c(none)))
						
graph export "$graphs/Cómo se informan país `year', por sexo.pdf", replace
}

restore


		***			Municipality level, first option
*00			Opening DB

*02			Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop indicador year using `inform', replace

*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_comuna_frst if year==201`x', nolabel 
mat table_`x'_aux=e(Prop)	
mat table_`x'_aux=e(Prop)
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

mat table_`x'=J(8,1,1)
forvalues k = 1/6{
	local v = table_`x'_aux[`k',1] 
	mat table_`x'[`k',1]=`v'	
}
mat table_`x'[6,1]=`aux_3'
mat table_`x'[7,1]=table_`x'_aux[8,1]
mat table_`x'[8,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[4,1]) (1) (201`x')
post `lgc' (table_`x'[1,1]) (2) (201`x')
post `lgc' (table_`x'[3,1]) (3) (201`x')
post `lgc' (table_`x'[2,1]) (4) (201`x')
post `lgc' (table_`x'[5,1]) (5) (201`x')
post `lgc' (table_`x'[7,1]) (6) (201`x')
post `lgc' (table_`x'[6,1]) (7) (201`x')
post `lgc' (table_`x'[8,1]) (8) (201`x')
}


postclose `lgc'

preserve 
use "`inform'", clear

label val indicador labels27

twoway	(bar prop indicador if indicador==1, by(year, note("") graphregion(color(white))) subtitle(, size(small)) bcolor(maroon) barwidth(0.75))		///
		(bar prop indicador if indicador==2, by(year) bcolor(midblue) barwidth(0.75))		///
		(bar prop indicador if indicador==3, by(year) bcolor(sand) barwidth(0.75))		///
		(bar prop indicador if indicador==4, by(year) bcolor(dknavy) barwidth(0.75))		///
		(bar prop indicador if indicador==5, by(year) bcolor(gold) barwidth(0.75))		///
		(bar prop indicador if indicador==6, by(year) bcolor(erose) barwidth(0.75))		///
		(bar prop indicador if indicador==7, by(year) bcolor(forest_green) barwidth(0.75))		///
		(bar prop indicador if indicador==8, by(year) bcolor(midgreen) barwidth(0.75)),		///
		ytitle("Proporción", size(small)) xtitle("") xlabel(none)	///
		legend(order(	1	"Noticias en televisión"	///
						2	"Experiencia personal"	///
						3	"Información de otras personas, por boca a boca o internet" ///
						4	"Información proporcionada por familiares, por boca a boca o internet"	///
						5	"Programas en televisión (no noticias)"	///
						6	"La radio"	///
						7	"Periódicos nacionales, regionales o locales (papel y/o electrónico)"	///
						8	"Otros") size(tiny) symysize(0.05cm) symxsize(0.15cm)	///
						region(c(none)))	
						
graph export "$graphs/Cómo se informan comuna 2016-2019.pdf", replace
restore


*04			Do they inform differently by age?
*	Proportion of the group
svy: mean young
mat aux = e(b)
local mean = aux[1,1]
local young = round(`mean', .0001)
local young =`young'*100

*	Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop indicador young year using `inform', replace

*		Youngsters	
*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_comuna_frst if year==201`x' & young==1, nolabel 
mat table_`x'_aux=e(Prop)	
mat table_`x'_aux=e(Prop)
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

mat table_`x'=J(8,1,1)
forvalues k = 1/6{
	local v = table_`x'_aux[`k',1] 
	mat table_`x'[`k',1]=`v'	
}
mat table_`x'[6,1]=`aux_3'
mat table_`x'[7,1]=table_`x'_aux[8,1]
mat table_`x'[8,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[4,1]) (1) (0) (201`x')
post `lgc' (table_`x'[3,1]) (2) (0) (201`x')
post `lgc' (table_`x'[1,1]) (3) (0) (201`x')
post `lgc' (table_`x'[2,1]) (4) (0) (201`x')
post `lgc' (table_`x'[5,1]) (5) (0) (201`x')
post `lgc' (table_`x'[6,1]) (6) (0) (201`x')
post `lgc' (table_`x'[7,1]) (7) (0) (201`x')
post `lgc' (table_`x'[8,1]) (8) (0) (201`x')
}

*		Olders
*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_comuna_frst if year==201`x' & young==0, nolabel 
mat table_`x'_aux=e(Prop)	
mat table_`x'_aux=e(Prop)
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

mat table_`x'=J(8,1,1)
forvalues k = 1/6{
	local v = table_`x'_aux[`k',1] 
	mat table_`x'[`k',1]=`v'	
}
mat table_`x'[6,1]=`aux_3'
mat table_`x'[7,1]=table_`x'_aux[8,1]
mat table_`x'[8,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[4,1]) (1) (1) (201`x')
post `lgc' (table_`x'[3,1]) (2) (1) (201`x')
post `lgc' (table_`x'[1,1]) (3) (1) (201`x')
post `lgc' (table_`x'[2,1]) (4) (1) (201`x')
post `lgc' (table_`x'[5,1]) (5) (1) (201`x')
post `lgc' (table_`x'[6,1]) (6) (1) (201`x')
post `lgc' (table_`x'[7,1]) (7) (1) (201`x')
post `lgc' (table_`x'[8,1]) (8) (1) (201`x')
}
postclose `lgc'

preserve 
use "`inform'", clear

label val indicador labels27
replace indicador = 10 if indicador==77

label def young 0 "Menores de 40" 1 "Mayores de 40"
label val young young

forvalues  year = 2016/2019{
twoway	(bar prop indicador if indicador==1 & year==`year', by(young, note("") graphregion(color(white)) ) bcolor(maroon) barwidth(0.75))		///
		(bar prop indicador if indicador==2 & year==`year', by(young) bcolor(midblue) barwidth(0.75))		///
		(bar prop indicador if indicador==3 & year==`year', by(young) bcolor(sand) barwidth(0.75))		///
		(bar prop indicador if indicador==4 & year==`year', by(young) bcolor(dknavy) barwidth(0.75))		///
		(bar prop indicador if indicador==5 & year==`year', by(young) bcolor(gold) barwidth(0.75))		///
		(bar prop indicador if indicador==6 & year==`year', by(young) bcolor(erose) barwidth(0.75))		///
		(bar prop indicador if indicador==7 & year==`year', by(young) bcolor(forest_green) barwidth(0.75))		///
		(bar prop indicador if indicador==8 & year==`year', by(young) bcolor(midgreen) barwidth(0.75)),		///
		ytitle("Proporción", size(small)) xtitle("") xlabel(none)	///
		legend(order(	1	"Noticias en televisión"	///
						2	"Información de otras personas, por boca a boca o internet"	///
						3	"Experiencia personal" ///
						4	"Información proporcionada por familiares, por boca a boca o internet"	///
						5	"Programas en televisión (no noticias)"	///
						6	"Periódicos nacionales, regionales o locales (papel y/o electrónico)" ///
						7	"La radio"		///
						8	"Otros") size(tiny) symysize(0.05cm) symxsize(0.15cm)	///
						region(c(none)))
						
graph export "$graphs/Cómo se informan comuna `year', por edad.pdf", replace
}

restore



*04			Do they inform differently by education?
*	Proportion of the group
foreach v in low {
	svy: mean `v'
	mat aux = e(b)
	mat list aux
	local mean = aux[1,1]
	di `mean'
	local `v'_aux = round(`mean', .0001)
	local `v'_aux =``v'_aux'*100	
}

di `low_aux'

*	Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop  indicador nivel year using `inform', replace

*		Low	
*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_comuna_frst if year==201`x' & low==1, nolabel 
mat table_`x'_aux=e(Prop)	
mat table_`x'_aux=e(Prop)
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

mat table_`x'=J(8,1,1)
forvalues k = 1/6{
	local v = table_`x'_aux[`k',1] 
	mat table_`x'[`k',1]=`v'	
}
mat table_`x'[6,1]=`aux_3'
mat table_`x'[7,1]=table_`x'_aux[8,1]
mat table_`x'[8,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[4,1]) (1) (0) (201`x')
post `lgc' (table_`x'[1,1]) (2) (0) (201`x')
post `lgc' (table_`x'[3,1]) (3) (0) (201`x')
post `lgc' (table_`x'[2,1]) (4) (0) (201`x')
post `lgc' (table_`x'[5,1]) (5) (0) (201`x')
post `lgc' (table_`x'[7,1]) (6) (0) (201`x')
post `lgc' (table_`x'[6,1]) (7) (0) (201`x')
post `lgc' (table_`x'[8,1]) (8) (0) (201`x')
}

*		High
*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_comuna_frst if year==201`x' & low==0, nolabel 
mat table_`x'_aux=e(Prop)	
mat table_`x'_aux=e(Prop)
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

mat table_`x'=J(8,1,1)
forvalues k = 1/6{
	local v = table_`x'_aux[`k',1] 
	mat table_`x'[`k',1]=`v'	
}
mat table_`x'[6,1]=`aux_3'
mat table_`x'[7,1]=table_`x'_aux[8,1]
mat table_`x'[8,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[4,1]) (1) (1) (201`x')
post `lgc' (table_`x'[1,1]) (2) (1) (201`x')
post `lgc' (table_`x'[3,1]) (3) (1) (201`x')
post `lgc' (table_`x'[2,1]) (4) (1) (201`x')
post `lgc' (table_`x'[5,1]) (5) (1) (201`x')
post `lgc' (table_`x'[7,1]) (6) (1) (201`x')
post `lgc' (table_`x'[6,1]) (7) (1) (201`x')
post `lgc' (table_`x'[8,1]) (8) (1) (201`x')
}
postclose `lgc'

preserve 
use "`inform'", clear

label def educ 0 "Sin educación superior" 1 "Con educación superior"
label val nivel educ

forvalues  year = 2016/2019{
twoway	(bar prop indicador if indicador==1 & year==`year', by(nivel, note("") graphregion(color(white)) ) bcolor(maroon) barwidth(0.75))		///
		(bar prop indicador if indicador==2 & year==`year', by(nivel) bcolor(midblue) barwidth(0.75))		///
		(bar prop indicador if indicador==3 & year==`year', by(nivel) bcolor(sand) barwidth(0.75))		///
		(bar prop indicador if indicador==4 & year==`year', by(nivel) bcolor(dknavy) barwidth(0.75))		///
		(bar prop indicador if indicador==5 & year==`year', by(nivel) bcolor(gold) barwidth(0.75))		///
		(bar prop indicador if indicador==6 & year==`year', by(nivel) bcolor(erose) barwidth(0.75))		///
		(bar prop indicador if indicador==7 & year==`year', by(nivel) bcolor(forest_green) barwidth(0.75))		///
		(bar prop indicador if indicador==8 & year==`year', by(nivel) bcolor(midgreen) barwidth(0.75)),		///
		ytitle("Proporción", size(small)) xtitle("") xlabel(none)	///
		legend(order(	1	"Noticias en televisión"	///
						2	"Experiencia personal" 	///
						3	"Información de otras personas, por boca a boca o internet" ///
						4	"Información proporcionada por familiares, por boca a boca o internet"	///
						5	"Programas en televisión (no noticias)"	///
						6	"Periódicos nacionales, regionales o locales (papel y/o electrónico)" ///
						7	"La radio"		///
						8	"Otros") size(tiny) symysize(0.05cm) symxsize(0.15cm)	///
						region(c(none)))
						
graph export "$graphs/Cómo se informan comuna `year', por educación.pdf", replace
}

restore


*05			Do they inform differently by gender?
*	Proportion of the group
foreach v in hombre {
	svy: mean `v'
	mat aux = e(b)
	mat list aux
	local mean = aux[1,1]
	di `mean'
	local `v'_aux = round(`mean', .0001)
	local `v'_aux =``v'_aux'*100	
}

di `hombre_aux'

*	Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop  indicador nivel year using `inform', replace

*		Hombre
*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_comuna_frst if year==201`x' & hombre==1, nolabel 
mat table_`x'_aux=e(Prop)	
mat table_`x'_aux=e(Prop)
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

mat table_`x'=J(8,1,1)
forvalues k = 1/6{
	local v = table_`x'_aux[`k',1] 
	mat table_`x'[`k',1]=`v'	
}
mat table_`x'[6,1]=`aux_3'
mat table_`x'[7,1]=table_`x'_aux[8,1]
mat table_`x'[8,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[4,1]) (1) (0) (201`x')
post `lgc' (table_`x'[1,1]) (2) (0) (201`x')
post `lgc' (table_`x'[3,1]) (3) (0) (201`x')
post `lgc' (table_`x'[2,1]) (4) (0) (201`x')
post `lgc' (table_`x'[5,1]) (5) (0) (201`x')
post `lgc' (table_`x'[7,1]) (6) (0) (201`x')
post `lgc' (table_`x'[6,1]) (7) (0) (201`x')
post `lgc' (table_`x'[8,1]) (8) (0) (201`x')
}

*		Mujer
*03			Tabulating and keeping info of how people inform
forvalues x = 6/9{
svy: tab info_comuna_frst if year==201`x' & hombre==0, nolabel 
mat table_`x'_aux=e(Prop)	
mat table_`x'_aux=e(Prop)
local aux = table_`x'_aux[6,1]
local aux_2 = table_`x'_aux[7,1]
local aux_3 = `aux'+`aux_2'

mat table_`x'=J(8,1,1)
forvalues k = 1/6{
	local v = table_`x'_aux[`k',1] 
	mat table_`x'[`k',1]=`v'	
}
mat table_`x'[6,1]=`aux_3'
mat table_`x'[7,1]=table_`x'_aux[8,1]
mat table_`x'[8,1]=table_`x'_aux[9,1]
}

*04 		Now filling temporal file
forvalues x = 6/9{
mat list table_`x'
post `lgc' (table_`x'[4,1]) (1) (1) (201`x')
post `lgc' (table_`x'[1,1]) (2) (1) (201`x')
post `lgc' (table_`x'[3,1]) (3) (1) (201`x')
post `lgc' (table_`x'[2,1]) (4) (1) (201`x')
post `lgc' (table_`x'[5,1]) (5) (1) (201`x')
post `lgc' (table_`x'[7,1]) (6) (1) (201`x')
post `lgc' (table_`x'[6,1]) (7) (1) (201`x')
post `lgc' (table_`x'[8,1]) (8) (1) (201`x')
}
postclose `lgc'

preserve 
use "`inform'", clear

label def mujer 0 "Hombre" 1 "Mujer"
label val nivel mujer

forvalues  year = 2016/2019{
twoway	(bar prop indicador if indicador==1 & year==`year', by(nivel, note("") graphregion(color(white)) ) bcolor(maroon) barwidth(0.75))		///
		(bar prop indicador if indicador==2 & year==`year', by(nivel) bcolor(midblue) barwidth(0.75))		///
		(bar prop indicador if indicador==3 & year==`year', by(nivel) bcolor(sand) barwidth(0.75))		///
		(bar prop indicador if indicador==4 & year==`year', by(nivel) bcolor(dknavy) barwidth(0.75))		///
		(bar prop indicador if indicador==5 & year==`year', by(nivel) bcolor(gold) barwidth(0.75))		///
		(bar prop indicador if indicador==6 & year==`year', by(nivel) bcolor(erose) barwidth(0.75))		///
		(bar prop indicador if indicador==7 & year==`year', by(nivel) bcolor(forest_green) barwidth(0.75))		///
		(bar prop indicador if indicador==8 & year==`year', by(nivel) bcolor(midgreen) barwidth(0.75)),		///
		ytitle("Proporción", size(small)) xtitle("") xlabel(none)	///
		legend(order(	1	"Noticias en televisión"	///
						2	"Experiencia personal" 	///
						3	"Información de otras personas, por boca a boca o internet" ///
						4	"Información proporcionada por familiares, por boca a boca o internet"	///
						5	"Programas en televisión (no noticias)"	///
						6	"Periódicos nacionales, regionales o locales (papel y/o electrónico)" ///
						7	"La radio"		///
						8	"Otros") size(tiny) symysize(0.05cm) symxsize(0.15cm)	///
						region(c(none)))
						
graph export "$graphs/Cómo se informan comuna `year', por sexo.pdf", replace
}

restore