/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		02	Latinobarometer, Plots
	Author:		Lucas García
	Date:		March 01, 2023
	Version:	Stata 17

	Summary:	This dofile uses latinobarometer data base to plot the relevant
				trends.
				
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
*       1. Opening DB						   *
************************************************

*00		Opening 2020 dataset & cleaning
use "$usedata/latinobarometro", clear


************************************************
*       2. Non heterogeneous trends			   *
************************************************

*00		Collapse to keep means
preserve
collapse (mean) d_* , by(year chile)

*01		Plot FFAA & Police trust trends
twoway 	(scatter d_police year if chile==0, connect(direct) lcolor(navy) mcolor(navy) msymbol(O))					///
		(scatter d_police year if chile==1, connect(direct) lcolor(navy) mcolor(navy) msymbol(Oh) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(1	"Confianza en policías, LAC"	2	"Confianza en policías, Chile"))
						
graph export "$graphs/Latinobarometro, policias.pdf", replace

*02		Plot Congress, government and judiciary trust trends, & separately
twoway 	(scatter d_congress year if chile==0, connect(direct) lcolor(navy) mcolor(navy) msymbol(O))					///
		(scatter d_congress year if chile==1, connect(direct) lcolor(navy) mcolor(navy) msymbol(Oh) lpattern(dash))	///
		(scatter d_government year if chile==0, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(T))					///
		(scatter d_government year if chile==1, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(Th) lpattern(dash))	///
		(scatter d_judiciary year if chile==0, connect(direct) lcolor(dkgreen) mcolor(dkgreen) msymbol(D))					///
		(scatter d_judiciary year if chile==1, connect(direct) lcolor(dkgreen) mcolor(dkgreen) msymbol(Dh) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(	1	"Confianza en el Congreso, LAC"	2	"Confianza en el Congreso, Chile"	///
						3	"Confianza en el Gobierno, LAC"	4	"Confianza en el Gobierno, Chile"	///
						5	"Confianza en sistema judicial, LAC"	6	"Confianza en sistema judicial, Chile")	///
				size(small) symxsize(*0.75))
						
graph export "$graphs/Latinobarometro, congreso, gobierno y justicia.pdf", replace

twoway 	(scatter d_congress year if chile==0, connect(direct) lcolor(navy) mcolor(navy) msymbol(O))					///
		(scatter d_congress year if chile==1, connect(direct) lcolor(navy) mcolor(navy) msymbol(Oh) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(	1	"Confianza en el Congreso, LAC"	2	"Confianza en el Congreso, Chile")	///
				size(small) symxsize(*0.75))
						
graph export "$graphs/Latinobarometro, congreso.pdf", replace

twoway 	(scatter d_government year if chile==0, connect(direct) lcolor(navy) mcolor(navy) msymbol(D))					///
		(scatter d_government year if chile==1, connect(direct) lcolor(navy) mcolor(navy) msymbol(Dh) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(	1	"Confianza en el Gobierno, LAC"	2	"Confianza en el Gobierno, Chile")	///
				size(small) symxsize(*0.75))
						
graph export "$graphs/Latinobarometro, gobierno.pdf", replace

twoway 	(scatter d_judiciary year if chile==0, connect(direct) lcolor(dkgreen) mcolor(dkgreen) msymbol(D))					///
		(scatter d_judiciary year if chile==1, connect(direct) lcolor(dkgreen) mcolor(dkgreen) msymbol(Dh) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(1	"Confianza en sistema judicial, LAC"	2	"Confianza en sistema judicial, Chile")	///
				size(small) symxsize(*0.75))
						
graph export "$graphs/Latinobarometro, justicia.pdf", replace

*03		Plot Political Parties and Electoral institution trust trends
twoway 	(scatter d_political_parties year if chile==0, connect(direct) lcolor(navy) mcolor(navy) msymbol(O))					///
		(scatter d_political_parties year if chile==1, connect(direct) lcolor(navy) mcolor(navy) msymbol(Oh) lpattern(dash))	///
		(scatter d_electoral_institution year if chile==0, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(T))					///
		(scatter d_electoral_institution year if chile==1, connect(direct) lcolor(maroon) mcolor(maroon) msymbol(Th) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(	1	"Confianza en partidos políticos, LAC"	2	"Confianza en partidos políticos, Chile"	///
						3	"Confianza en SERVEL, LAC"	4	"Confianza en SERVEL, Chile") size(small)	///
						symxsize(*0.675))
						
graph export "$graphs/Latinobarometro, partidos y servel.pdf", replace

restore


*		By country
preserve
collapse (mean) d_* , by(year idenpa)

*04		Plot Police trust trends, by country (spaghetti plot)
twoway 	(line d_police year if idenpa==32, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==68, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==76, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==170, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==188, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==214, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==218, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==222, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==320, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==340, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==484, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==558, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==591, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==600, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==604, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==724, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==858, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==862, connect(direct) lcolor(gs12))					///
		(line d_police year if idenpa==152, connect(direct) lcolor(navy) mcolor(navy) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(19	"Confianza en policías, Chile"))
						
graph export "$graphs/Latinobarometro, policias, Chile y LAC tallarin.pdf", replace

*05		Plot Congress trust trends, by country (spaghetti plot)
twoway 	(line d_congress year if idenpa==32, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==68, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==76, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==170, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==188, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==214, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==218, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==222, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==320, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==340, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==484, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==558, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==591, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==600, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==604, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==724, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==858, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==862, connect(direct) lcolor(gs12))					///
		(line d_congress year if idenpa==152, connect(direct) lcolor(navy) mcolor(navy) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(19	"Confianza en el Congreso, Chile"))
						
graph export "$graphs/Latinobarometro, Congreso, Chile y LAC tallarin.pdf", replace

*06		Plot Judiciary trust trends, by country (spaghetti plot)
twoway 	(line d_judiciary year if idenpa==32, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==68, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==76, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==170, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==188, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==214, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==218, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==222, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==320, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==340, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==484, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==558, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==591, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==600, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==604, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==724, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==858, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==862, connect(direct) lcolor(gs12))					///
		(line d_judiciary year if idenpa==152, connect(direct) lcolor(navy) mcolor(navy) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(19	"Confianza en el Poder Judicial, Chile"))
						
graph export "$graphs/Latinobarometro, Poder Judicial, Chile y LAC tallarin.pdf", replace

*07		Plot Electoral Institutions trust trends, by country (spaghetti plot)
replace d_electoral_institution=. if year<2015
twoway 	(line d_electoral_institution year if idenpa==32, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==68, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==76, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==170, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==188, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==214, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==218, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==222, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==320, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==340, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==484, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==558, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==591, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==600, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==604, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==724, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==858, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==862, connect(direct) lcolor(gs12))					///
		(line d_electoral_institution year if idenpa==152, connect(direct) lcolor(navy) mcolor(navy) lpattern(dash)) if year>=2015,	///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(19	"Confianza en la institución electoral nacional, Chile"))
						
graph export "$graphs/Latinobarometro, Institución Electoral, Chile y LAC tallarin.pdf", replace

*08		Plot Gobernment trust trends, by country (spaghetti plot)
twoway 	(line d_government year if idenpa==32, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==68, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==76, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==170, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==188, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==214, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==218, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==222, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==320, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==340, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==484, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==558, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==591, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==600, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==604, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==724, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==858, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==862, connect(direct) lcolor(gs12))					///
		(line d_government year if idenpa==152, connect(direct) lcolor(navy) mcolor(navy) lpattern(dash)) if year>=2013,	///
		graphregion(color(white)) ytitle("Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(19	"Confianza en el gobierno, Chile"))
						
graph export "$graphs/Latinobarometro, Gobierno, Chile y LAC tallarin.pdf", replace
restore

************************************************
*       3. "Dif in Dif" in trust			   *
************************************************

*00		Collapse to keep means
preserve
collapse (mean) d_* , by(year chile)

*01		Dif Police-Congress
g d_police_congress = d_police-d_congress

*	Plot 
twoway 	(scatter d_police_congress year if chile==0, connect(direct) lcolor(navy) mcolor(navy) msymbol(O))					///
		(scatter d_police_congress year if chile==1, connect(direct) lcolor(navy) mcolor(navy) msymbol(Oh) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Diferencia en Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(1	"Diferencia Confianza Policía y Congreso, LAC"	2	"Diferencia Confianza Policía y Congreso, Chile") r(2))
						
graph export "$graphs/Latinobarometro, Diferencias policias y congreso.pdf", replace


*02		Dif Police-Governement
g d_police_government = d_police-d_government

*	Plot 
twoway 	(scatter d_police_government year if chile==0, connect(direct) lcolor(navy) mcolor(navy) msymbol(O))					///
		(scatter d_police_government year if chile==1, connect(direct) lcolor(navy) mcolor(navy) msymbol(Oh) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Diferencia en Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(1	"Diferencia Confianza Policía y Gobierno, LAC"	2	"Diferencia Confianza Policía y Gobierno, Chile") r(2))
						
graph export "$graphs/Latinobarometro, Diferencias policias y gobierno.pdf", replace


*03		Dif Police-Justice
g d_police_judiciary = d_police-d_judiciary

*	Plot 
twoway 	(scatter d_police_judiciary year if chile==0, connect(direct) lcolor(navy) mcolor(navy) msymbol(O))					///
		(scatter d_police_judiciary year if chile==1, connect(direct) lcolor(navy) mcolor(navy) msymbol(Oh) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Diferencia en Proporción") xtitle("") ylabel(0(0.1)1)	///
		legend(order(1	"Diferencia Confianza Policía y Poder Judicial, LAC"	2	"Diferencia Confianza Policía y Poder Judicial, Chile") r(2))
						
graph export "$graphs/Latinobarometro, Diferencias policias y poder judicial.pdf", replace


*04		Dif Police-Electoral Institutions
g d_police_electoral_institution = d_police-d_electoral_institution

*	Plot 
twoway 	(scatter d_police_electoral_institution year if chile==0, connect(direct) lcolor(navy) mcolor(navy) msymbol(O))					///
		(scatter d_police_electoral_institution year if chile==1, connect(direct) lcolor(navy) mcolor(navy) msymbol(Oh) lpattern(dash)),	///
		graphregion(color(white)) ytitle("Diferencia en Proporción") xtitle("") ylabel(-.2(0.1)1)	///
		legend(order(1	"Diferencia Confianza Policía e Institución Electoral, LAC"	2	"Diferencia Confianza Policía e Institución Electoral, Chile") r(2))
						
graph export "$graphs/Latinobarometro, Diferencias policias e institución electoral.pdf", replace
