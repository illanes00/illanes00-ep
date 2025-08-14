/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		02	LAPOP, Appending and plotting
	Author:		Lucas García
	Date:		February 28, 2023
	Version:	Stata 17

	Summary:	This dofile appends each country LAPOP survey, saves a new DB,
				erases the individual LAPOP surveys and then plots each variable
				trend.
				
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
	global rawdata "$path/01 RawData/LAPOP"
	global dofiles "$path/02 Code"
	global usedata "$path/04 Usedata"
	global graphs "$path/05 Graphs/Informe 2"
	global tables "$path/06 Tables"
	
	
************************************************
*      1. Appending each country DB			   *
************************************************
/*
*00		Opening Chilean dataset, cleaning
use "$usedata/LAPOP, Chile.dta", clear

*01		Append with the rest of the countries LAPOP DB
append using	"$usedata/LAPOP, Argentina.dta" "$usedata/LAPOP, Bolivia.dta"	///
				"$usedata/LAPOP, Colombia.dta"	"$usedata/LAPOP, Ecuador.dta"	///
				"$usedata/LAPOP, Mexico.dta"	"$usedata/LAPOP, Paraguay.dta"	///
				"$usedata/LAPOP, Uruguay.dta"	"$usedata/LAPOP, Venezuela.dta"	///
				"$usedata/LAPOP, Brazil.dta"	"$usedata/LAPOP, Peru.dta"

*02		Saving DB as one LAPOP
save "$usedata/LAPOP all countries.dta", replace

*03		Erasing each country DB
foreach pais in Chile Argentina Bolivia Colombia Ecuador Mexico Paraguay Uruguay Venezuela Brazil Peru{
	erase	"$usedata/LAPOP, `pais'.dta"	
}
*/

*04		Use LAPOP all countries
use "$usedata/LAPOP all countries.dta", clear

************************************************
*              2. Plotting Trends			   *
************************************************

*00		Collapse to keep LA average and Chilean separated
g chile=(pais==13)

preserve
collapse (mean) justice_punish institutions_respect FFAA congress police political_parties elections_trust democ_satisf d_democ_satisf d_justice_punish, by(chile year)

*01		Plot Trust in justice punish and democracy satisfaction trends
twoway	(scatter d_justice_punish year if chile==0, connect(direct) lcolor(navy) mcolor(navy) msymbol(O))		///
		(scatter d_justice_punish year if chile==1, connect(direct) lcolor(navy) mcolor(navy) msymbol(Oh) lpattern(dash))		///
		(scatter d_democ_satisf year if chile==0, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(T))		///
		(scatter d_democ_satisf year if chile==1, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(Th) lpattern(dash)),		///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1) 		///
		legend(order(	1	"Confía que Sistema Judicial castiga a los culpables, LA"		///
						2	"Confía que Sistema Judicial castiga a los culpables, Chile"	///
						3	"Satisfacción con la democracia, LA"				///
						4	"Satisfacción con la democracia, Chile") r(4))
						
graph export "$graphs/LAPOP, sistema judicial y satisfacción con la democracia.pdf", replace

twoway	(scatter d_democ_satisf year if chile==0, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(S))		///
		(scatter d_democ_satisf year if chile==1, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(Sh) lpattern(dash)),		///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1) 		///
		legend(order(	1	"Satisfacción con la democracia, LA"				///
						2	"Satisfacción con la democracia, Chile") r(2))
						
graph export "$graphs/LAPOP, satisfacción con la democracia.pdf", replace

*02		Plot Trust in FFAA & police trends
twoway	(scatter FFAA year if chile==0, connect(direct) lcolor(navy) mcolor(navy) msymbol(O))		///
		(scatter FFAA year if chile==1, connect(direct) lcolor(navy) mcolor(navy) msymbol(Oh) lpattern(dash))		///
		(scatter police year if chile==0, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(T))		///
		(scatter police year if chile==1, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(Th) lpattern(dash)),		///
		graphregion(color(white)) ytitle("Nota") xtitle("") ylabel(1(1)7)  		///
		legend(order(	1	"Confía en FFAA, LA"		///
						2	"Confía en FFAA, Chile"	///
						3	"Confía en policía nacional, LA"				///
						4	"Confía en policía nacional, Chile") r(4))
						
graph export "$graphs/LAPOP, confianza en FFAA y policia.pdf", replace

*03		Plot Trust in congress, elections, political parties and institutional respect
twoway	(scatter institutions_respect year if chile==0, connect(direct) lcolor(navy) mcolor(navy) msymbol(O))		///
		(scatter institutions_respect year if chile==1, connect(direct) lcolor(navy) mcolor(navy) msymbol(Oh) lpattern(dash))		///
		(scatter congress year if chile==0, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(T))		///
		(scatter congress year if chile==1, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(Th) lpattern(dash))	///
		(scatter political_parties year if chile==0, connect(direct) lcolor(dkgreen) mcolor(dkgreen) msymbol(D))		///
		(scatter political_parties year if chile==1, connect(direct) lcolor(dkgreen) mcolor(dkgreen) msymbol(Dh) lpattern(dash))		///
		(scatter elections_trust year if chile==0, connect(direct) lcolor(gold) mcolor(gold) msymbol(S))		///
		(scatter elections_trust year if chile==1, connect(direct) lcolor(gold) mcolor(gold) msymbol(Sh) lpattern(dash)),		///
		graphregion(color(white)) ytitle("Nota") xtitle("") ylabel(1(1)7)  		///
		legend(order(	1	"Respeto institucional, LA"		///
						2	"Respeto institucional, Chile"	///
						3	"Confianza en el Congreso, LA"				///
						4	"Confianza en el Congreso, Chile"			///
						5	"Confianza en Partidos políticos, LA"				///
						6	"Confianza en Partidos políticos, Chile"				///
						7	"Confianza en elecciones, LA"				///
						8	"Confianza en elecciones, Chile") r(4) size(small) symxsize(*0.65))
						
graph export "$graphs/LAPOP, confianza en congreso, elecciones, partidos politicos y respeto institucional.pdf", replace

*03		Plot Trust in congress, elections, political parties and institutional respect
twoway	(scatter institutions_respect year if chile==0, connect(direct) lcolor(navy) mcolor(navy) msymbol(O))		///
		(scatter institutions_respect year if chile==1, connect(direct) lcolor(navy) mcolor(navy) msymbol(Oh) lpattern(dash)),		///
		graphregion(color(white)) ytitle("Nota") xtitle("") ylabel(1(1)7)  		///
		legend(order(	1	"Respeto institucional, LA"		///
						2	"Respeto institucional, Chile") ///
						r(2) size(small) symxsize(*0.65))
						
graph export "$graphs/LAPOP, respeto institucional.pdf", replace

restore

preserve
*04		Collapse to keep each LA average and Chilean separated
collapse (mean) justice_punish institutions_respect FFAA congress police political_parties elections_trust democ_satisf d_democ_satisf d_justice_punish, by(pais year)

*05		Plot Trust in police trends
twoway	(line police year if pais==1, connect(direct) lcolor(gs12))		///
		(line police year if pais==8, connect(direct) lcolor(gs12))		///
		(line police year if pais==9, connect(direct) lcolor(gs12))		///
		(line police year if pais==10, connect(direct) lcolor(gs12))		///
		(line police year if pais==11, connect(direct) lcolor(gs12))		///
		(line police year if pais==12, connect(direct) lcolor(gs12))		///
		(line police year if pais==14, connect(direct) lcolor(gs12))		///
		(line police year if pais==15, connect(direct) lcolor(gs12))		///
		(line police year if pais==16, connect(direct) lcolor(gs12))		///
		(line police year if pais==17, connect(direct) lcolor(gs12))		///
		(line police year if pais==13, connect(direct) lcolor(maroon) mcolor(maroon) lpattern(dash)),		///
		graphregion(color(white)) ytitle("Nota") xtitle("") ylabel(1(1)7)  		///
		legend(order(	11	"Confía en policía nacional, Chile") )
						
graph export "$graphs/LAPOP, confianza en policia, Chile y LA tallarin.pdf", replace

*06		Plot Trust in Congress trends
twoway	(line congress year if pais==1, connect(direct) lcolor(gs12))		///
		(line congress year if pais==8, connect(direct) lcolor(gs12))		///
		(line congress year if pais==9, connect(direct) lcolor(gs12))		///
		(line congress year if pais==10, connect(direct) lcolor(gs12))		///
		(line congress year if pais==11, connect(direct) lcolor(gs12))		///
		(line congress year if pais==12, connect(direct) lcolor(gs12))		///
		(line congress year if pais==14, connect(direct) lcolor(gs12))		///
		(line congress year if pais==15, connect(direct) lcolor(gs12))		///
		(line congress year if pais==16, connect(direct) lcolor(gs12))		///
		(line congress year if pais==17, connect(direct) lcolor(gs12))		///
		(line congress year if pais==13, connect(direct) lcolor(maroon) mcolor(maroon) lpattern(dash)),		///
		graphregion(color(white)) ytitle("Nota") xtitle("") ylabel(1(1)7)  		///
		legend(order(	11	"Confía en el Congreso, Chile") )
						
graph export "$graphs/LAPOP, confianza en el Congreso, Chile y LA tallarin.pdf", replace


*07		Plot Trust in Judicary system trends
twoway	(line d_justice_punish year if pais==1, connect(direct) lcolor(gs12))		///
		(line d_justice_punish year if pais==8, connect(direct) lcolor(gs12))		///
		(line d_justice_punish year if pais==9, connect(direct) lcolor(gs12))		///
		(line d_justice_punish year if pais==10, connect(direct) lcolor(gs12))		///
		(line d_justice_punish year if pais==11, connect(direct) lcolor(gs12))		///
		(line d_justice_punish year if pais==12, connect(direct) lcolor(gs12))		///
		(line d_justice_punish year if pais==14, connect(direct) lcolor(gs12))		///
		(line d_justice_punish year if pais==15, connect(direct) lcolor(gs12))		///
		(line d_justice_punish year if pais==16, connect(direct) lcolor(gs12))		///
		(line d_justice_punish year if pais==17, connect(direct) lcolor(gs12))		///
		(line d_justice_punish year if pais==13, connect(direct) lcolor(maroon) mcolor(maroon) lpattern(dash)) if year<2020,		///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1)  		///
		legend(order(	11	"Confía que el sistema judicial castiga a los culpables, Chile") size(small) )
						
graph export "$graphs/LAPOP, confianza en la Justicia, Chile y LA tallarin.pdf", replace

*08		Plot Trust in elections trends
twoway	(line elections_trust year if pais==1, connect(direct) lcolor(gs12))		///
		(line elections_trust year if pais==8, connect(direct) lcolor(gs12))		///
		(line elections_trust year if pais==9, connect(direct) lcolor(gs12))		///
		(line elections_trust year if pais==10, connect(direct) lcolor(gs12))		///
		(line elections_trust year if pais==11, connect(direct) lcolor(gs12))		///
		(line elections_trust year if pais==12, connect(direct) lcolor(gs12))		///
		(line elections_trust year if pais==14, connect(direct) lcolor(gs12))		///
		(line elections_trust year if pais==15, connect(direct) lcolor(gs12))		///
		(line elections_trust year if pais==16, connect(direct) lcolor(gs12))		///
		(line elections_trust year if pais==17, connect(direct) lcolor(gs12))		///
		(line elections_trust year if pais==13, connect(direct) lcolor(maroon) mcolor(maroon) lpattern(dash)),		///
		graphregion(color(white)) ytitle("Nota") xtitle("") ylabel(1(1)7)  		///
		legend(order(	11	"Confía en las elecciones, Chile") size(small) )
						
graph export "$graphs/LAPOP, confianza en elecciones, Chile y LA tallarin.pdf", replace

*09		Plot Democracy Satisfacion trends
twoway	(line d_democ_satisf year if pais==1, connect(direct) lcolor(gs12))		///
		(line d_democ_satisf year if pais==8, connect(direct) lcolor(gs12))		///
		(line d_democ_satisf year if pais==9, connect(direct) lcolor(gs12))		///
		(line d_democ_satisf year if pais==10, connect(direct) lcolor(gs12))		///
		(line d_democ_satisf year if pais==11, connect(direct) lcolor(gs12))		///
		(line d_democ_satisf year if pais==12, connect(direct) lcolor(gs12))		///
		(line d_democ_satisf year if pais==14, connect(direct) lcolor(gs12))		///
		(line d_democ_satisf year if pais==15, connect(direct) lcolor(gs12))		///
		(line d_democ_satisf year if pais==16, connect(direct) lcolor(gs12))		///
		(line d_democ_satisf year if pais==17, connect(direct) lcolor(gs12))		///
		(line d_democ_satisf year if pais==13, connect(direct) lcolor(maroon) mcolor(maroon) lpattern(dash)),		///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1)  		///
		legend(order(	11	"Satisfacción con la Democracia, Chile") size(small) )
						
graph export "$graphs/LAPOP, satisfacción con la democracia, Chile y LA tallarin.pdf", replace
restore

************************************************
*           3. "Dif in Dif" in Trust		   *
************************************************
preserve
*00		Collapse region level
collapse (mean) justice_punish institutions_respect FFAA congress police political_parties elections_trust democ_satisf d_democ_satisf d_justice_punish, by(chile year)

*01		Dif Police-Congress
g d_police_congress = police-congress

*	Plot 
twoway 	(scatter d_police_congress year if chile==0, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(S))					///
		(scatter d_police_congress year if chile==1, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(Sh) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Diferencia en Nota") xtitle("") ylabel(-1(1)7)	///
		legend(order(1	"Diferencia Confianza Policía y Congreso, LAC"	2	"Diferencia Confianza Policía y Congreso, Chile") r(2))
						
graph export "$graphs/LAPOP, Diferencias policias y congreso.pdf", replace


*02		Dif Police-elections_trust
g d_police_elections = police-elections_trust

*	Plot 
twoway 	(scatter d_police_elections year if chile==0, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(S))					///
		(scatter d_police_elections year if chile==1, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(Sh) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Diferencia en Nota") xtitle("") ylabel(-1(1)7)	///
		legend(order(1	"Diferencia Confianza Policía e Institución Electoral, LAC"	2	"Diferencia Confianza Policía e Institución Electoral, Chile") r(2))
						
graph export "$graphs/LAPOP, Diferencias policias e instituciones electorales.pdf", replace
restore


************************************************
*   4. Bar graph of Police Time Responses	   *
************************************************

tempname lgc
tempfile response
postfile `lgc' tiempo mean pais year using `response', replace

foreach ctry in 1 8 9 10 11 12 13 14 15 16 17{
	foreach año in 2014 2017 2019{
		*Define N
		count if police_response !=. & pais==`ctry' & year==`año'
		local N = r(N)

		*Less than 10 Min
		count if police_response==1 & pais==`ctry' & year==`año'
		local value_1_`ctry' = r(N)/`N'

		*10 to 30 Min
		count if police_response==2 & pais==`ctry' & year==`año'
		local value_2_`ctry' = r(N)/`N'

		*Más de 30 Min y hasta una hora
		count if police_response==3 & pais==`ctry' & year==`año'
		local value_3_`ctry' = r(N)/`N'

		*Más de 1 hora y hasta 3 horas
		count if police_response==4 & pais==`ctry' & year==`año'
		local value_4_`ctry' = r(N)/`N'

		*Más de 3 horas
		count if police_response==5 & pais==`ctry' & year==`año'
		local value_5_`ctry' = r(N)/`N'

		*Filling temporal File
		foreach val in 1 2 3 4 5{
			post `lgc' (`val') (`value_`val'_`ctry'') (`ctry') (`año')
		}
	}
}

postclose `lgc'

use "`response'", clear

g chile=(pais==12)

*00			Collapse Region level
collapse (mean) mean, by(tiempo chile year)

*01			Label Mean values and rename
rename mean police_response

label def police	1 "Menos de 10 minutos" 2 "10 a 30 minutos" 3 "30 minutos a una hora"	///
					4 "Una a 3 horas" 5 "Más de 3 horas"
					
label val tiempo police

label def pais 0 "Promedio LA" 1 "Chile"
label val chile pais

twoway	(bar police_response tiempo if tiempo==1 & chile==1, fcolor(gs12) lcolor(gs12) by(year, rows(3) 		///
		note("")) plotregion(fcolor(white)))	///
		(bar police_response tiempo if tiempo==1 & chile==0, fcolor(none) lcolor(black) by(year) plotregion(fcolor(white)))	///
		(bar police_response tiempo if tiempo==2 & chile==1, by(year) fcolor(gs12) lcolor(gs12) plotregion(fcolor(white)))	///
		(bar police_response tiempo if tiempo==2 & chile==0, by(year) fcolor(none) lcolor(black) plotregion(fcolor(white)))	///
		(bar police_response tiempo if tiempo==3 & chile==1, by(year) fcolor(gs12) lcolor(gs12) plotregion(fcolor(white)))	///
		(bar police_response tiempo if tiempo==3 & chile==0, by(year) fcolor(none) lcolor(black) plotregion(fcolor(white)))	///
		(bar police_response tiempo if tiempo==4 & chile==1, by(year) fcolor(gs12) lcolor(gs12) plotregion(fcolor(white)))	///
		(bar police_response tiempo if tiempo==4 & chile==0, by(year) fcolor(none) lcolor(black) plotregion(fcolor(white)))	///
		(bar police_response tiempo if tiempo==5 & chile==1, by(year) fcolor(gs12) lcolor(gs12) plotregion(fcolor(white)))	///
		(bar police_response tiempo if tiempo==5 & chile==0, by(year) fcolor(none) lcolor(black) plotregion(fcolor(white))),	///
		ytitle("Proporción") xtitle("") 	xlabel(1 "Menos de 10 minutos" 2 "10 a 30 minutos" 3 "30 minutos a una hora" 4 "Una a 3 horas" 5 "Más de 3 horas", angle(45) labsize(small))	///
		legend(order(1	"Chile" 2 "Latinoamérica") ///
		size(vsmall) symxsize(*0.25) symysize(*0.45) r(1))  ///
		plotregion(fcolor(white)) 

graph export "$graphs/LAPOP, Police response time.pdf", replace
