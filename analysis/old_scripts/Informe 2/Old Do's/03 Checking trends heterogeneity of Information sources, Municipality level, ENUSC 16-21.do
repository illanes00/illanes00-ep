/*******************************************************************************
	Project:	Seguridad Pública EP, Informe 2
	
	Title:		03 Checking trends heterogeneity of Information sources, Municipality level, ENUSC 16-21
	Author:		Lucas García
	Date:		February 07, 2023
	Version:	Stata 17

	Summary:	This dofile uses enusc_16_21 from use data to plot the trends 
				of information sources related to the perception of rise in 
				crime rates at municipality level. As there is no information of
				this question on 2020 & 2021, it uses only until 2019.
				
				First Section plots the trend 2016-2019. 
				
				Second section plots checking heterogeneity by gender.
				
				Third section plots checking heterogeneity by education level.
				
				Fourth section plots checking heterogeneity by laboral situation.
				
				Fifth section plots checking heterogeneity by age range.
				
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
*     1. Information source trends	           *
************************************************

*00			Open DB & defining data as survey
use "$usedata/enusc_16_21", clear

*	Set as survey
svyset enc_idr [pweight=Fact_pers], strata(VarStrat) singleunit(certainty)

*01			Information Source trend (2016-2019), without checking heterogeneity, country level
foreach x in 2016 2017 2018 2019{
	svy: tab info_comuna_frst if year==`x', nolabel
	mat table_`x' = e(Prop)
}

*	2016-2019
forvalues n = 2016/2019{
	*Grouping family or other acquaintances
	local family = table_`n'[2,1]
	local acquaintances = table_`n'[3,1]
	local word_of_mouth = `family' + `acquaintances'

	*Grouping newspaper sources
	local newspaper_national = table_`n'[6,1]
	local newspaper_local = table_`n'[7,1]
	local newspaper = `newspaper_local'+`newspaper_national'

	*Preparing table to be plotted
	mat info_`n'=J(7,1,1)

	mat info_`n'[1,1]=table_`n'[1,1]
	mat info_`n'[2,1]=`word_of_mouth'
	mat info_`n'[3,1]=table_`n'[4,1]
	mat info_`n'[4,1]=table_`n'[5,1]
	mat info_`n'[5,1]=`newspaper'
	mat info_`n'[6,1]=table_`n'[8,1]
	mat info_`n'[7,1]=table_`n'[9,1]
}

*Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop indicador using `inform', replace

post `lgc' (info_2016[1,1]) (1)
post `lgc' (info_2016[2,1]) (2)
post `lgc' (info_2016[3,1]) (3)
post `lgc' (info_2016[4,1]) (4)
post `lgc' (info_2016[5,1]) (5)
post `lgc' (info_2016[6,1]) (6)
post `lgc' (info_2016[7,1]) (7)

post `lgc' (info_2017[1,1]) (9)
post `lgc' (info_2017[2,1]) (10)
post `lgc' (info_2017[3,1]) (11)
post `lgc' (info_2017[4,1]) (12)
post `lgc' (info_2017[5,1]) (13)
post `lgc' (info_2017[6,1]) (14)
post `lgc' (info_2017[7,1]) (15)

post `lgc' (info_2018[1,1]) (17)
post `lgc' (info_2018[2,1]) (18)
post `lgc' (info_2018[3,1]) (19)
post `lgc' (info_2018[4,1]) (20)
post `lgc' (info_2018[5,1]) (21)
post `lgc' (info_2018[6,1]) (22)
post `lgc' (info_2018[7,1]) (23)

post `lgc' (info_2019[1,1]) (25)
post `lgc' (info_2019[2,1]) (26)
post `lgc' (info_2019[3,1]) (27)
post `lgc' (info_2019[4,1]) (28)
post `lgc' (info_2019[5,1]) (29)
post `lgc' (info_2019[6,1]) (30)
post `lgc' (info_2019[7,1]) (31)

postclose `lgc'

*Using temporal file and bar plot of information source
preserve
use "`inform'", clear

twoway	(bar prop indicador if indicador==1 | indicador==9 | indicador==17 | indicador==25)		///
		(bar prop indicador if indicador==2 | indicador==10 | indicador==18 | indicador==26)	///
		(bar prop indicador if indicador==3 | indicador==11 | indicador==19 | indicador==27)	///
		(bar prop indicador if indicador==4 | indicador==12 | indicador==20 | indicador==28)	///
		(bar prop indicador if indicador==5 | indicador==13 | indicador==21 | indicador==29)	///
		(bar prop indicador if indicador==6 | indicador==14 | indicador==22 | indicador==30)	///
		(bar prop indicador if indicador==7 | indicador==15 | indicador==23 | indicador==31),	///
		ytitle("Proporción") xtitle("") xlabel(none)					///
		graphregion(color(white))										///
		legend(order(	1	"Experiencia personal"						///
						2	"Familiares, conocidos o internet (RRSS)"	///
						3	"Noticias en televisión"					///
						4	"Televisión (no noticias)"					///
						5	"Periódicos (papel o electrónico)"			///
						6	"La radio"									///
						7	"Otros") size(small) region(c(none))) 		///
						xlabel(3 "2016" 11 "2017"	19 "2018" 27 "2019")

graph export "$graphs/Cómo se informan 2016-2019, Comuna.pdf", replace
graph export "$graphs/Cómo se informan 2016-2019, Comuna.eps", replace
graph export "$graphs/Cómo se informan 2016-2019, Comuna.png", replace
restore


************************************************
*     			2. By Gender		           *
************************************************

*01			Information Source trend (2016-2019), checking gender heterogeneity, country level
foreach x in 2016 2017 2018 2019{
	svy: tab info_comuna_frst if year==`x' & rph_sexo==1, nolabel
	mat table_`x'_hombre = e(Prop)
	
	svy: tab info_comuna_frst if year==`x' & rph_sexo==2, nolabel
	mat table_`x'_mujer = e(Prop)
}

foreach gender in hombre mujer{
	*	2016-2019
	forvalues n = 2016/2019{
		*Grouping family or other acquaintances
		local family = table_`n'_`gender'[2,1]
		local acquaintances = table_`n'_`gender'[3,1]
		local word_of_mouth = `family' + `acquaintances'

		*Grouping newspaper sources
		local newspaper_national = table_`n'_`gender'[6,1]
		local newspaper_local = table_`n'_`gender'[7,1]
		local newspaper = `newspaper_local'+`newspaper_national'

		*Preparing table to be plotted
		mat info_`n'_`gender'=J(7,1,1)

		mat info_`n'_`gender'[1,1]=table_`n'_`gender'[1,1]
		mat info_`n'_`gender'[2,1]=`word_of_mouth'
		mat info_`n'_`gender'[3,1]=table_`n'_`gender'[4,1]
		mat info_`n'_`gender'[4,1]=table_`n'_`gender'[5,1]
		mat info_`n'_`gender'[5,1]=`newspaper'
		mat info_`n'_`gender'[6,1]=table_`n'_`gender'[8,1]
		mat info_`n'_`gender'[7,1]=table_`n'_`gender'[9,1]
	}
}


*Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop indicador gender using `inform', replace

post `lgc' (info_2016_hombre[1,1]) (1) (0)
post `lgc' (info_2016_hombre[2,1]) (2) (0)
post `lgc' (info_2016_hombre[3,1]) (3) (0)
post `lgc' (info_2016_hombre[4,1]) (4) (0)
post `lgc' (info_2016_hombre[5,1]) (5) (0)
post `lgc' (info_2016_hombre[6,1]) (6) (0)
post `lgc' (info_2016_hombre[7,1]) (7) (0)

post `lgc' (info_2017_hombre[1,1]) (9) (0)
post `lgc' (info_2017_hombre[2,1]) (10) (0)
post `lgc' (info_2017_hombre[3,1]) (11) (0)
post `lgc' (info_2017_hombre[4,1]) (12) (0)
post `lgc' (info_2017_hombre[5,1]) (13) (0)
post `lgc' (info_2017_hombre[6,1]) (14) (0)
post `lgc' (info_2017_hombre[7,1]) (15) (0)

post `lgc' (info_2018_hombre[1,1]) (17) (0)
post `lgc' (info_2018_hombre[2,1]) (18) (0)
post `lgc' (info_2018_hombre[3,1]) (19) (0)
post `lgc' (info_2018_hombre[4,1]) (20) (0)
post `lgc' (info_2018_hombre[5,1]) (21) (0)
post `lgc' (info_2018_hombre[6,1]) (22) (0)
post `lgc' (info_2018_hombre[7,1]) (23) (0)

post `lgc' (info_2019_hombre[1,1]) (25) (0)
post `lgc' (info_2019_hombre[2,1]) (26) (0)
post `lgc' (info_2019_hombre[3,1]) (27) (0)
post `lgc' (info_2019_hombre[4,1]) (28) (0)
post `lgc' (info_2019_hombre[5,1]) (29) (0)
post `lgc' (info_2019_hombre[6,1]) (30) (0)
post `lgc' (info_2019_hombre[7,1]) (31) (0)

post `lgc' (info_2016_mujer[1,1]) (1) (1)
post `lgc' (info_2016_mujer[2,1]) (2) (1)
post `lgc' (info_2016_mujer[3,1]) (3) (1)
post `lgc' (info_2016_mujer[4,1]) (4) (1)
post `lgc' (info_2016_mujer[5,1]) (5) (1)
post `lgc' (info_2016_mujer[6,1]) (6) (1)
post `lgc' (info_2016_mujer[7,1]) (7) (1)

post `lgc' (info_2017_mujer[1,1]) (9) (1)
post `lgc' (info_2017_mujer[2,1]) (10) (1)
post `lgc' (info_2017_mujer[3,1]) (11) (1)
post `lgc' (info_2017_mujer[4,1]) (12) (1)
post `lgc' (info_2017_mujer[5,1]) (13) (1)
post `lgc' (info_2017_mujer[6,1]) (14) (1)
post `lgc' (info_2017_mujer[7,1]) (15) (1)

post `lgc' (info_2018_mujer[1,1]) (17) (1)
post `lgc' (info_2018_mujer[2,1]) (18) (1)
post `lgc' (info_2018_mujer[3,1]) (19) (1)
post `lgc' (info_2018_mujer[4,1]) (20) (1)
post `lgc' (info_2018_mujer[5,1]) (21) (1)
post `lgc' (info_2018_mujer[6,1]) (22) (1)
post `lgc' (info_2018_mujer[7,1]) (23) (1)

post `lgc' (info_2019_mujer[1,1]) (25) (1)
post `lgc' (info_2019_mujer[2,1]) (26) (1)
post `lgc' (info_2019_mujer[3,1]) (27) (1)
post `lgc' (info_2019_mujer[4,1]) (28) (1)
post `lgc' (info_2019_mujer[5,1]) (29) (1)
post `lgc' (info_2019_mujer[6,1]) (30) (1)
post `lgc' (info_2019_mujer[7,1]) (31) (1)

postclose `lgc'

*Using temporal file and bar plot of information source
preserve
use "`inform'", clear

twoway	(bar prop indicador if gender==0 & (indicador==1 | indicador==9 | indicador==17 | indicador==25))	///
		(bar prop indicador if gender==0 & (indicador==2 | indicador==10 | indicador==18 | indicador==26))	///
		(bar prop indicador if gender==0 & (indicador==3 | indicador==11 | indicador==19 | indicador==27))	///
		(bar prop indicador if gender==0 & (indicador==4 | indicador==12 | indicador==20 | indicador==28))	///
		(bar prop indicador if gender==0 & (indicador==5 | indicador==13 | indicador==21 | indicador==29))	///
		(bar prop indicador if gender==0 & (indicador==6 | indicador==14 | indicador==22 | indicador==30))	///
		(bar prop indicador if gender==0 & (indicador==7 | indicador==15 | indicador==23 | indicador==31)),	///
		ytitle("Proporción") xtitle("Hombres") xlabel(none)					///
		graphregion(color(white))										///
		legend(order(	1	"Experiencia personal"						///
						2	"Familiares, conocidos o internet (RRSS)"	///
						3	"Noticias en televisión"					///
						4	"Televisión (no noticias)"					///
						5	"Periódicos (papel o electrónico)"			///
						6	"La radio"									///
						7	"Otros") size(vsmall) region(c(none)) symy(2) symx(4)) 		///
						xlabel(3 "2016" 11 "2017"	19 "2018" 27 "2019")	///
						name(gph_0, replace)
						
twoway	(bar prop indicador if gender==1 & (indicador==1 | indicador==9 | indicador==17 | indicador==25))	///
		(bar prop indicador if gender==1 & (indicador==2 | indicador==10 | indicador==18 | indicador==26))	///
		(bar prop indicador if gender==1 & (indicador==3 | indicador==11 | indicador==19 | indicador==27))	///
		(bar prop indicador if gender==1 & (indicador==4 | indicador==12 | indicador==20 | indicador==28))	///
		(bar prop indicador if gender==1 & (indicador==5 | indicador==13 | indicador==21 | indicador==29))	///
		(bar prop indicador if gender==1 & (indicador==6 | indicador==14 | indicador==22 | indicador==30))	///
		(bar prop indicador if gender==1 & (indicador==7 | indicador==15 | indicador==23 | indicador==31)),	///
		ytitle("Proporción") xtitle("Mujeres") xlabel(none)					///
		graphregion(color(white))										///
		legend(order(	1	"Experiencia personal"						///
						2	"Familiares, conocidos o internet (RRSS)"	///
						3	"Noticias en televisión"					///
						4	"Televisión (no noticias)"					///
						5	"Periódicos (papel o electrónico)"			///
						6	"La radio"									///
						7	"Otros") size(small) region(c(none))) 		///
						xlabel(3 "2016" 11 "2017"	19 "2018" 27 "2019")	///
						name(gph_1, replace)

grc1leg gph_0 gph_1, legendfrom(gph_0) ycommon r(2) graphregion(color(white)) iscale(0.75)

graph export "$graphs/Cómo se informan 2016-2019, Hombres y Mujeres, Comuna.pdf", replace
graph export "$graphs/Cómo se informan 2016-2019, Hombres y Mujeres, Comuna.eps", replace
graph export "$graphs/Cómo se informan 2016-2019, Hombres y Mujeres, Comuna.png", replace
restore


************************************************
*     			3. By Education level          *
************************************************

*00			Education levels
g low = 1 if (rph_nivel==0 | rph_nivel==1 | rph_nivel==2) & Kish==1 & year==2021
replace low = 1 if (rph_nivel<=8 | rph_nivel==90) & year<=2019

g high = 1 if (rph_nivel==3) & Kish==1 & year==2021
replace high = 1 if (rph_nivel>=9 & rph_nivel<=13) & year<=2019
replace high=0 if low==1

*01			Information Source trend (2016-2019), checking education heterogeneity, country level
foreach x in 2016 2017 2018 2019{
	svy: tab info_comuna_frst if year==`x' & high==1, nolabel
	mat table_`x'_high = e(Prop)
	
	svy: tab info_comuna_frst if year==`x' & high==0, nolabel
	mat table_`x'_low = e(Prop)
}

foreach level in high low{
	*	2016-2019
	forvalues n = 2016/2019{
		*Grouping family or other acquaintances
		local family = table_`n'_`level'[2,1]
		local acquaintances = table_`n'_`level'[3,1]
		local word_of_mouth = `family' + `acquaintances'

		*Grouping newspaper sources
		local newspaper_national = table_`n'_`level'[6,1]
		local newspaper_local = table_`n'_`level'[7,1]
		local newspaper = `newspaper_local'+`newspaper_national'

		*Preparing table to be plotted
		mat info_`n'_`level'=J(7,1,1)

		mat info_`n'_`level'[1,1]=table_`n'_`level'[1,1]
		mat info_`n'_`level'[2,1]=`word_of_mouth'
		mat info_`n'_`level'[3,1]=table_`n'_`level'[4,1]
		mat info_`n'_`level'[4,1]=table_`n'_`level'[5,1]
		mat info_`n'_`level'[5,1]=`newspaper'
		mat info_`n'_`level'[6,1]=table_`n'_`level'[8,1]
		mat info_`n'_`level'[7,1]=table_`n'_`level'[9,1]
	}
}


*Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop indicador level using `inform', replace

post `lgc' (info_2016_low[1,1]) (1) (0)
post `lgc' (info_2016_low[2,1]) (2) (0)
post `lgc' (info_2016_low[3,1]) (3) (0)
post `lgc' (info_2016_low[4,1]) (4) (0)
post `lgc' (info_2016_low[5,1]) (5) (0)
post `lgc' (info_2016_low[6,1]) (6) (0)
post `lgc' (info_2016_low[7,1]) (7) (0)

post `lgc' (info_2017_low[1,1]) (9) (0)
post `lgc' (info_2017_low[2,1]) (10) (0)
post `lgc' (info_2017_low[3,1]) (11) (0)
post `lgc' (info_2017_low[4,1]) (12) (0)
post `lgc' (info_2017_low[5,1]) (13) (0)
post `lgc' (info_2017_low[6,1]) (14) (0)
post `lgc' (info_2017_low[7,1]) (15) (0)

post `lgc' (info_2018_low[1,1]) (17) (0)
post `lgc' (info_2018_low[2,1]) (18) (0)
post `lgc' (info_2018_low[3,1]) (19) (0)
post `lgc' (info_2018_low[4,1]) (20) (0)
post `lgc' (info_2018_low[5,1]) (21) (0)
post `lgc' (info_2018_low[6,1]) (22) (0)
post `lgc' (info_2018_low[7,1]) (23) (0)

post `lgc' (info_2019_low[1,1]) (25) (0)
post `lgc' (info_2019_low[2,1]) (26) (0)
post `lgc' (info_2019_low[3,1]) (27) (0)
post `lgc' (info_2019_low[4,1]) (28) (0)
post `lgc' (info_2019_low[5,1]) (29) (0)
post `lgc' (info_2019_low[6,1]) (30) (0)
post `lgc' (info_2019_low[7,1]) (31) (0)

post `lgc' (info_2016_high[1,1]) (1) (1)
post `lgc' (info_2016_high[2,1]) (2) (1)
post `lgc' (info_2016_high[3,1]) (3) (1)
post `lgc' (info_2016_high[4,1]) (4) (1)
post `lgc' (info_2016_high[5,1]) (5) (1)
post `lgc' (info_2016_high[6,1]) (6) (1)
post `lgc' (info_2016_high[7,1]) (7) (1)

post `lgc' (info_2017_high[1,1]) (9) (1)
post `lgc' (info_2017_high[2,1]) (10) (1)
post `lgc' (info_2017_high[3,1]) (11) (1)
post `lgc' (info_2017_high[4,1]) (12) (1)
post `lgc' (info_2017_high[5,1]) (13) (1)
post `lgc' (info_2017_high[6,1]) (14) (1)
post `lgc' (info_2017_high[7,1]) (15) (1)

post `lgc' (info_2018_high[1,1]) (17) (1)
post `lgc' (info_2018_high[2,1]) (18) (1)
post `lgc' (info_2018_high[3,1]) (19) (1)
post `lgc' (info_2018_high[4,1]) (20) (1)
post `lgc' (info_2018_high[5,1]) (21) (1)
post `lgc' (info_2018_high[6,1]) (22) (1)
post `lgc' (info_2018_high[7,1]) (23) (1)

post `lgc' (info_2019_high[1,1]) (25) (1)
post `lgc' (info_2019_high[2,1]) (26) (1)
post `lgc' (info_2019_high[3,1]) (27) (1)
post `lgc' (info_2019_high[4,1]) (28) (1)
post `lgc' (info_2019_high[5,1]) (29) (1)
post `lgc' (info_2019_high[6,1]) (30) (1)
post `lgc' (info_2019_high[7,1]) (31) (1)

postclose `lgc'

*Using temporal file and bar plot of information source
preserve
use "`inform'", clear

twoway	(bar prop indicador if level==0 & (indicador==1 | indicador==9 | indicador==17 | indicador==25))	///
		(bar prop indicador if level==0 & (indicador==2 | indicador==10 | indicador==18 | indicador==26))	///
		(bar prop indicador if level==0 & (indicador==3 | indicador==11 | indicador==19 | indicador==27))	///
		(bar prop indicador if level==0 & (indicador==4 | indicador==12 | indicador==20 | indicador==28))	///
		(bar prop indicador if level==0 & (indicador==5 | indicador==13 | indicador==21 | indicador==29))	///
		(bar prop indicador if level==0 & (indicador==6 | indicador==14 | indicador==22 | indicador==30))	///
		(bar prop indicador if level==0 & (indicador==7 | indicador==15 | indicador==23 | indicador==31)),	///
		ytitle("Proporción") xtitle("Sin Educación Superior") xlabel(none)					///
		graphregion(color(white))										///
		legend(order(	1	"Experiencia personal"						///
						2	"Familiares, conocidos o internet (RRSS)"	///
						3	"Noticias en televisión"					///
						4	"Televisión (no noticias)"					///
						5	"Periódicos (papel o electrónico)"			///
						6	"La radio"									///
						7	"Otros") size(vsmall) region(c(none)) symy(2) symx(4)) 		///
						xlabel(3 "2016" 11 "2017"	19 "2018" 27 "2019")	///
						name(gph_0, replace)
						
twoway	(bar prop indicador if level==1 & (indicador==1 | indicador==9 | indicador==17 | indicador==25))	///
		(bar prop indicador if level==1 & (indicador==2 | indicador==10 | indicador==18 | indicador==26))	///
		(bar prop indicador if level==1 & (indicador==3 | indicador==11 | indicador==19 | indicador==27))	///
		(bar prop indicador if level==1 & (indicador==4 | indicador==12 | indicador==20 | indicador==28))	///
		(bar prop indicador if level==1 & (indicador==5 | indicador==13 | indicador==21 | indicador==29))	///
		(bar prop indicador if level==1 & (indicador==6 | indicador==14 | indicador==22 | indicador==30))	///
		(bar prop indicador if level==1 & (indicador==7 | indicador==15 | indicador==23 | indicador==31)),	///
		ytitle("Proporción") xtitle("Con Educación Superior") xlabel(none)					///
		graphregion(color(white))										///
		legend(order(	1	"Experiencia personal"						///
						2	"Familiares, conocidos o internet (RRSS)"	///
						3	"Noticias en televisión"					///
						4	"Televisión (no noticias)"					///
						5	"Periódicos (papel o electrónico)"			///
						6	"La radio"									///
						7	"Otros") size(small) region(c(none))) 		///
						xlabel(3 "2016" 11 "2017"	19 "2018" 27 "2019")	///
						name(gph_1, replace)

grc1leg gph_0 gph_1, legendfrom(gph_0) ycommon r(2) graphregion(color(white)) iscale(0.75)

graph export "$graphs/Cómo se informan 2016-2019, Educación, Comuna.pdf", replace
graph export "$graphs/Cómo se informan 2016-2019, Educación, Comuna.eps", replace
graph export "$graphs/Cómo se informan 2016-2019, Educación, Comuna.png", replace
restore


************************************************
*     		4. By Laboral Situation            *
************************************************

*00			Laboral situation
replace working=. if working>2 | Kish==0
replace working=0 if working==2

*01			Information Source trend (2016-2019), checking laboral heterogeneity, country level
foreach x in 2016 2017 2018 2019{
	svy: tab info_comuna_frst if year==`x' & working==1, nolabel
	mat table_`x'_work = e(Prop)
	
	svy: tab info_comuna_frst if year==`x' & working==0, nolabel
	mat table_`x'_nowork = e(Prop)
}

foreach labor in work nowork{
	*	2016-2019
	forvalues n = 2016/2019{
		*Grouping family or other acquaintances
		local family = table_`n'_`labor'[2,1]
		local acquaintances = table_`n'_`labor'[3,1]
		local word_of_mouth = `family' + `acquaintances'

		*Grouping newspaper sources
		local newspaper_national = table_`n'_`labor'[6,1]
		local newspaper_local = table_`n'_`labor'[7,1]
		local newspaper = `newspaper_local'+`newspaper_national'

		*Preparing table to be plotted
		mat info_`n'_`labor'=J(7,1,1)

		mat info_`n'_`labor'[1,1]=table_`n'_`labor'[1,1]
		mat info_`n'_`labor'[2,1]=`word_of_mouth'
		mat info_`n'_`labor'[3,1]=table_`n'_`labor'[4,1]
		mat info_`n'_`labor'[4,1]=table_`n'_`labor'[5,1]
		mat info_`n'_`labor'[5,1]=`newspaper'
		mat info_`n'_`labor'[6,1]=table_`n'_`labor'[8,1]
		mat info_`n'_`labor'[7,1]=table_`n'_`labor'[9,1]
	}
}


*Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop indicador labor using `inform', replace

post `lgc' (info_2016_nowork[1,1]) (1) (0)
post `lgc' (info_2016_nowork[2,1]) (2) (0)
post `lgc' (info_2016_nowork[3,1]) (3) (0)
post `lgc' (info_2016_nowork[4,1]) (4) (0)
post `lgc' (info_2016_nowork[5,1]) (5) (0)
post `lgc' (info_2016_nowork[6,1]) (6) (0)
post `lgc' (info_2016_nowork[7,1]) (7) (0)

post `lgc' (info_2017_nowork[1,1]) (9) (0)
post `lgc' (info_2017_nowork[2,1]) (10) (0)
post `lgc' (info_2017_nowork[3,1]) (11) (0)
post `lgc' (info_2017_nowork[4,1]) (12) (0)
post `lgc' (info_2017_nowork[5,1]) (13) (0)
post `lgc' (info_2017_nowork[6,1]) (14) (0)
post `lgc' (info_2017_nowork[7,1]) (15) (0)

post `lgc' (info_2018_nowork[1,1]) (17) (0)
post `lgc' (info_2018_nowork[2,1]) (18) (0)
post `lgc' (info_2018_nowork[3,1]) (19) (0)
post `lgc' (info_2018_nowork[4,1]) (20) (0)
post `lgc' (info_2018_nowork[5,1]) (21) (0)
post `lgc' (info_2018_nowork[6,1]) (22) (0)
post `lgc' (info_2018_nowork[7,1]) (23) (0)

post `lgc' (info_2019_nowork[1,1]) (25) (0)
post `lgc' (info_2019_nowork[2,1]) (26) (0)
post `lgc' (info_2019_nowork[3,1]) (27) (0)
post `lgc' (info_2019_nowork[4,1]) (28) (0)
post `lgc' (info_2019_nowork[5,1]) (29) (0)
post `lgc' (info_2019_nowork[6,1]) (30) (0)
post `lgc' (info_2019_nowork[7,1]) (31) (0)

post `lgc' (info_2016_work[1,1]) (1) (1)
post `lgc' (info_2016_work[2,1]) (2) (1)
post `lgc' (info_2016_work[3,1]) (3) (1)
post `lgc' (info_2016_work[4,1]) (4) (1)
post `lgc' (info_2016_work[5,1]) (5) (1)
post `lgc' (info_2016_work[6,1]) (6) (1)
post `lgc' (info_2016_work[7,1]) (7) (1)

post `lgc' (info_2017_work[1,1]) (9) (1)
post `lgc' (info_2017_work[2,1]) (10) (1)
post `lgc' (info_2017_work[3,1]) (11) (1)
post `lgc' (info_2017_work[4,1]) (12) (1)
post `lgc' (info_2017_work[5,1]) (13) (1)
post `lgc' (info_2017_work[6,1]) (14) (1)
post `lgc' (info_2017_work[7,1]) (15) (1)

post `lgc' (info_2018_work[1,1]) (17) (1)
post `lgc' (info_2018_work[2,1]) (18) (1)
post `lgc' (info_2018_work[3,1]) (19) (1)
post `lgc' (info_2018_work[4,1]) (20) (1)
post `lgc' (info_2018_work[5,1]) (21) (1)
post `lgc' (info_2018_work[6,1]) (22) (1)
post `lgc' (info_2018_work[7,1]) (23) (1)

post `lgc' (info_2019_work[1,1]) (25) (1)
post `lgc' (info_2019_work[2,1]) (26) (1)
post `lgc' (info_2019_work[3,1]) (27) (1)
post `lgc' (info_2019_work[4,1]) (28) (1)
post `lgc' (info_2019_work[5,1]) (29) (1)
post `lgc' (info_2019_work[6,1]) (30) (1)
post `lgc' (info_2019_work[7,1]) (31) (1)

postclose `lgc'

*Using temporal file and bar plot of information source
preserve
use "`inform'", clear

twoway	(bar prop indicador if labor==0 & (indicador==1 | indicador==9 | indicador==17 | indicador==25))	///
		(bar prop indicador if labor==0 & (indicador==2 | indicador==10 | indicador==18 | indicador==26))	///
		(bar prop indicador if labor==0 & (indicador==3 | indicador==11 | indicador==19 | indicador==27))	///
		(bar prop indicador if labor==0 & (indicador==4 | indicador==12 | indicador==20 | indicador==28))	///
		(bar prop indicador if labor==0 & (indicador==5 | indicador==13 | indicador==21 | indicador==29))	///
		(bar prop indicador if labor==0 & (indicador==6 | indicador==14 | indicador==22 | indicador==30))	///
		(bar prop indicador if labor==0 & (indicador==7 | indicador==15 | indicador==23 | indicador==31)),	///
		ytitle("Proporción") xtitle("No trabajó la semana pasada") xlabel(none)					///
		graphregion(color(white))										///
		legend(order(	1	"Experiencia personal"						///
						2	"Familiares, conocidos o internet (RRSS)"	///
						3	"Noticias en televisión"					///
						4	"Televisión (no noticias)"					///
						5	"Periódicos (papel o electrónico)"			///
						6	"La radio"									///
						7	"Otros") size(vsmall) region(c(none)) symy(2) symx(4)) 		///
						xlabel(3 "2016" 11 "2017"	19 "2018" 27 "2019")	///
						name(gph_0, replace)
						
twoway	(bar prop indicador if labor==1 & (indicador==1 | indicador==9 | indicador==17 | indicador==25))	///
		(bar prop indicador if labor==1 & (indicador==2 | indicador==10 | indicador==18 | indicador==26))	///
		(bar prop indicador if labor==1 & (indicador==3 | indicador==11 | indicador==19 | indicador==27))	///
		(bar prop indicador if labor==1 & (indicador==4 | indicador==12 | indicador==20 | indicador==28))	///
		(bar prop indicador if labor==1 & (indicador==5 | indicador==13 | indicador==21 | indicador==29))	///
		(bar prop indicador if labor==1 & (indicador==6 | indicador==14 | indicador==22 | indicador==30))	///
		(bar prop indicador if labor==1 & (indicador==7 | indicador==15 | indicador==23 | indicador==31)),	///
		ytitle("Proporción") xtitle("Trabajó la semana pasada") xlabel(none)					///
		graphregion(color(white))										///
		legend(order(	1	"Experiencia personal"						///
						2	"Familiares, conocidos o internet (RRSS)"	///
						3	"Noticias en televisión"					///
						4	"Televisión (no noticias)"					///
						5	"Periódicos (papel o electrónico)"			///
						6	"La radio"									///
						7	"Otros") size(small) region(c(none))) 		///
						xlabel(3 "2016" 11 "2017"	19 "2018" 27 "2019")	///
						name(gph_1, replace)

grc1leg gph_0 gph_1, legendfrom(gph_0) ycommon r(2) graphregion(color(white)) iscale(0.75)

graph export "$graphs/Cómo se informan 2016-2019, Trabajo, Comuna.pdf", replace
graph export "$graphs/Cómo se informan 2016-2019, Trabajo, Comuna.eps", replace
graph export "$graphs/Cómo se informan 2016-2019, Trabajo, Comuna.png", replace
restore



************************************************
*     		5. By Age Range					   *
************************************************

*00			Age ranges
g age_range = 1 if (rph_edad==1 | rph_edad==2) & Kish==1
replace age_range = 2 if (rph_edad==3 | rph_edad==4) & Kish==1
replace age_range = 3 if (rph_edad==5 | rph_edad==6) & Kish==1
replace age_range = 4 if (rph_edad==7 | rph_edad==8) & Kish==1
replace age_range = 5 if (rph_edad==9 | rph_edad==10) & Kish==1

*01			Information Source trend (2016-2019), checking laboral heterogeneity, country level
foreach year in 2016 2017 2018 2019{
	forvalues age = 1/5{
		svy: tab info_comuna_frst if year==`year' & age_range==`age', nolabel
		mat table_`year'_`age' = e(Prop)	
	}	
}

forvalues age = 1/5{
	*	2016-2019
	forvalues n = 2016/2019{
		*Grouping family or other acquaintances
		local family = table_`n'_`age'[2,1]
		local acquaintances = table_`n'_`age'[3,1]
		local word_of_mouth = `family' + `acquaintances'

		*Grouping newspaper sources
		local newspaper_national = table_`n'_`age'[6,1]
		local newspaper_local = table_`n'_`age'[7,1]
		local newspaper = `newspaper_local'+`newspaper_national'

		*Preparing table to be plotted
		mat info_`n'_`age'=J(7,1,1)

		mat info_`n'_`age'[1,1]=table_`n'_`age'[1,1]
		mat info_`n'_`age'[2,1]=`word_of_mouth'
		mat info_`n'_`age'[3,1]=table_`n'_`age'[4,1]
		mat info_`n'_`age'[4,1]=table_`n'_`age'[5,1]
		mat info_`n'_`age'[5,1]=`newspaper'
		mat info_`n'_`age'[6,1]=table_`n'_`age'[8,1]
		mat info_`n'_`age'[7,1]=table_`n'_`age'[9,1]
	}
}


*Setting the temporal file
tempname lgc 
tempfile inform
postfile `lgc' prop indicador age using `inform', replace

forvalues age = 1/5{
	post `lgc' (info_2016_`age'[1,1]) (1) (`age')
	post `lgc' (info_2016_`age'[2,1]) (2) (`age')
	post `lgc' (info_2016_`age'[3,1]) (3) (`age')
	post `lgc' (info_2016_`age'[4,1]) (4) (`age')
	post `lgc' (info_2016_`age'[5,1]) (5) (`age')
	post `lgc' (info_2016_`age'[6,1]) (6) (`age')
	post `lgc' (info_2016_`age'[7,1]) (7) (`age')

	post `lgc' (info_2017_`age'[1,1]) (9) (`age')
	post `lgc' (info_2017_`age'[2,1]) (10) (`age')
	post `lgc' (info_2017_`age'[3,1]) (11) (`age')
	post `lgc' (info_2017_`age'[4,1]) (12) (`age')
	post `lgc' (info_2017_`age'[5,1]) (13) (`age')
	post `lgc' (info_2017_`age'[6,1]) (14) (`age')
	post `lgc' (info_2017_`age'[7,1]) (15) (`age')

	post `lgc' (info_2018_`age'[1,1]) (17) (`age')
	post `lgc' (info_2018_`age'[2,1]) (18) (`age')
	post `lgc' (info_2018_`age'[3,1]) (19) (`age')
	post `lgc' (info_2018_`age'[4,1]) (20) (`age')
	post `lgc' (info_2018_`age'[5,1]) (21) (`age')
	post `lgc' (info_2018_`age'[6,1]) (22) (`age')
	post `lgc' (info_2018_`age'[7,1]) (23) (`age')

	post `lgc' (info_2019_`age'[1,1]) (25) (`age')
	post `lgc' (info_2019_`age'[2,1]) (26) (`age')
	post `lgc' (info_2019_`age'[3,1]) (27) (`age')
	post `lgc' (info_2019_`age'[4,1]) (28) (`age')
	post `lgc' (info_2019_`age'[5,1]) (29) (`age')
	post `lgc' (info_2019_`age'[6,1]) (30) (`age')
	post `lgc' (info_2019_`age'[7,1]) (31) (`age')
}

postclose `lgc'

*Using temporal file and bar plot of information source
preserve
use "`inform'", clear

twoway	(bar prop indicador if age==1 & (indicador==1 | indicador==9 | indicador==17 | indicador==25))		///
		(bar prop indicador if age==1 & (indicador==2 | indicador==10 | indicador==18 | indicador==26))		///
		(bar prop indicador if age==1 & (indicador==3 | indicador==11 | indicador==19 | indicador==27))		///
		(bar prop indicador if age==1 & (indicador==4 | indicador==12 | indicador==20 | indicador==28))		///
		(bar prop indicador if age==1 & (indicador==5 | indicador==13 | indicador==21 | indicador==29))		///
		(bar prop indicador if age==1 & (indicador==6 | indicador==14 | indicador==22 | indicador==30))		///
		(bar prop indicador if age==1 & (indicador==7 | indicador==15 | indicador==23 | indicador==31)),	///
		ytitle("Proporción") xtitle("15 a 24 años") xlabel(none)					///
		graphregion(color(white))										///
		legend(order(	1	"Experiencia personal"						///
						2	"Familiares, conocidos o internet (RRSS)"	///
						3	"Noticias en televisión"					///
						4	"Televisión (no noticias)"					///
						5	"Periódicos (papel o electrónico)"			///
						6	"La radio"									///
						7	"Otros") size(tiny) region(c(none)) symy(0.5) symx(1)) 		///
						xlabel(3 "2016" 11 "2017"	19 "2018" 27 "2019")	///
						name(gph_0, replace)
						
twoway	(bar prop indicador if age==2 & (indicador==1 | indicador==9 | indicador==17 | indicador==25))		///
		(bar prop indicador if age==2 & (indicador==2 | indicador==10 | indicador==18 | indicador==26))	///
		(bar prop indicador if age==2 & (indicador==3 | indicador==11 | indicador==19 | indicador==27))	///
		(bar prop indicador if age==2 & (indicador==4 | indicador==12 | indicador==20 | indicador==28))	///
		(bar prop indicador if age==2 & (indicador==5 | indicador==13 | indicador==21 | indicador==29))	///
		(bar prop indicador if age==2 & (indicador==6 | indicador==14 | indicador==22 | indicador==30))	///
		(bar prop indicador if age==2 & (indicador==7 | indicador==15 | indicador==23 | indicador==31)),	///
		ytitle("Proporción") xtitle("24 a 39 años") xlabel(none)							///
		graphregion(color(white)) xlabel(3 "2016" 11 "2017"	19 "2018" 27 "2019")	///
		name(gph_1, replace)
		
twoway	(bar prop indicador if age==3 & (indicador==1 | indicador==9 | indicador==17 | indicador==25))		///
		(bar prop indicador if age==3 & (indicador==2 | indicador==10 | indicador==18 | indicador==26))	///
		(bar prop indicador if age==3 & (indicador==3 | indicador==11 | indicador==19 | indicador==27))	///
		(bar prop indicador if age==3 & (indicador==4 | indicador==12 | indicador==20 | indicador==28))	///
		(bar prop indicador if age==3 & (indicador==5 | indicador==13 | indicador==21 | indicador==29))	///
		(bar prop indicador if age==3 & (indicador==6 | indicador==14 | indicador==22 | indicador==30))	///
		(bar prop indicador if age==3 & (indicador==7 | indicador==15 | indicador==23 | indicador==31)),	///
		ytitle("Proporción") xtitle("40 a 59 años") xlabel(none)							///
		graphregion(color(white)) xlabel(3 "2016" 11 "2017"	19 "2018" 27 "2019")	///
		name(gph_2, replace)
		
twoway	(bar prop indicador if age==4 & (indicador==1 | indicador==9 | indicador==17 | indicador==25))		///
		(bar prop indicador if age==4 & (indicador==2 | indicador==10 | indicador==18 | indicador==26))	///
		(bar prop indicador if age==4 & (indicador==3 | indicador==11 | indicador==19 | indicador==27))	///
		(bar prop indicador if age==4 & (indicador==4 | indicador==12 | indicador==20 | indicador==28))	///
		(bar prop indicador if age==4 & (indicador==5 | indicador==13 | indicador==21 | indicador==29))	///
		(bar prop indicador if age==4 & (indicador==6 | indicador==14 | indicador==22 | indicador==30))	///
		(bar prop indicador if age==4 & (indicador==7 | indicador==15 | indicador==23 | indicador==31)),	///
		ytitle("Proporción") xtitle("60 a 79 años") xlabel(none)							///
		graphregion(color(white)) xlabel(3 "2016" 11 "2017"	19 "2018" 27 "2019")	///
		name(gph_3, replace)
		
twoway	(bar prop indicador if age==5 & (indicador==1 | indicador==9 | indicador==17 | indicador==25))		///
		(bar prop indicador if age==5 & (indicador==2 | indicador==10 | indicador==18 | indicador==26))	///
		(bar prop indicador if age==5 & (indicador==3 | indicador==11 | indicador==19 | indicador==27))	///
		(bar prop indicador if age==5 & (indicador==4 | indicador==12 | indicador==20 | indicador==28))	///
		(bar prop indicador if age==5 & (indicador==5 | indicador==13 | indicador==21 | indicador==29))	///
		(bar prop indicador if age==5 & (indicador==6 | indicador==14 | indicador==22 | indicador==30))	///
		(bar prop indicador if age==5 & (indicador==7 | indicador==15 | indicador==23 | indicador==31)),	///
		ytitle("Proporción") xtitle("80 años o más") xlabel(none)							///
		graphregion(color(white)) xlabel(3 "2016" 11 "2017"	19 "2018" 27 "2019")	///
		name(gph_4, replace)

grc1leg gph_0 gph_1 gph_2 gph_3 gph_4, legendfrom(gph_0) ycommon r(5) graphregion(color(white)) iscale(0.45)

graph export "$graphs/Cómo se informan 2016-2019, Tramos de edad, Comuna.pdf", replace
graph export "$graphs/Cómo se informan 2016-2019, Tramos de edad, Comuna.eps", replace
graph export "$graphs/Cómo se informan 2016-2019, Tramos de edad, Comuna.png", replace
restore