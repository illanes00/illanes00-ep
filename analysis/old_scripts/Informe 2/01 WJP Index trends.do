/*******************************************************************************
	Project:	Seguridad Pública EP
	
	Title:		01	WJP Index trends
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

*00		Opening 2016-2022 dataset, cleaning it and merge with ine projections
import excel using "$rawdata/FINAL_2022_wjp_rule_of_law_index_HISTORICAL_DATA_FILE (1)", firstr clear sheet("Historical data")

*01		Fixing years
replace Year="2017" if Year=="2017-2018"
replace Year="2013" if Year=="2012-2013"
destring Year, replace

************************************************
*        2.	Historical Trends v/s LAC		   *
************************************************

*00		Keep LAC and CHL Average
gen chile=(CountryCode=="CHL") if Region=="Latin America & Caribbean"

g zone= 1 if (CountryCode=="ARG" | CountryCode=="BOL" | CountryCode=="BRA" | CountryCode=="COL" | CountryCode=="ECU" | CountryCode=="MEX" | CountryCode=="PRY" | CountryCode=="PER" | CountryCode=="URY" | CountryCode=="VEN") 
replace zone= 2 if chile==1
replace zone= 3 if Region=="Latin America & Caribbean" & zone!=1 & chile==0
replace zone= 4 if Region=="EU + EFTA + North America" 

preserve
collapse (mean) WJPRuleofLawIndexOverallS-BE, by(chile Year)

*01		Corruption Variables
twoway	(scatter O Year if chile==0, connect(direct) symbol(O) lcolor(navy) mcolor(navy) msize(small))	///
		(scatter O Year if chile==1, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small))	///
		(scatter Q Year if chile==0, connect(direct) symbol(T) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter Q Year if chile==1, connect(direct) lpattern(dash) symbol(Th) lcolor(maroon) mcolor(maroon) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"Corrupción en Poder Judicial, promedio LAC" 			///
						2 	"Corrupción en Poder Judicial, Chile" 					///
						3	"Corrupción en Poder Legislativo, promedio LAC"			///
						4	"Corrupción en Poder Legislativo, Chile"			///
						) rows(4) size(small))
		
graph export "$graphs/WJP, Corruption, Chile & LAC.pdf", replace

*02		Order & Security Vars	
twoway	(scatter AG Year if chile==0, connect(direct) symbol(O) lcolor(navy) mcolor(navy) )	///
		(scatter AG Year if chile==1, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) )	///
		(scatter Z Year if chile==0, connect(direct) symbol(T) lcolor(maroon) mcolor(maroon) )	///
		(scatter Z Year if chile==1, connect(direct) lpattern(dash) symbol(Th) lcolor(maroon) mcolor(maroon) ),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"El crimen es controlado de manera efectiva, promedio LAC" 			///
						2 	"El crimen es controlado de manera efectiva, Chile"					///
						3 	"El derecho a la vida y seguridad de las personas está efectivamente garantizado, LAC"	///
						4 	"El derecho a la vida y seguridad de las personas está efectivamente garantizado, Chile") ///
						symxsize(*0.55) keygap(*0.5) size(small) rows(4))
		
graph export "$graphs/WJP, Order and Security, Chile & LAC.pdf", replace

*03		Criminal Justice Vars	
twoway	(scatter AY Year if chile==0, connect(direct) symbol(O) lcolor(navy) mcolor(navy) msize(small))	///
		(scatter AY Year if chile==1, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small))	///
		(scatter AZ Year if chile==0, connect(direct) symbol(T) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter AZ Year if chile==1, connect(direct) lpattern(dash) symbol(Th) lcolor(maroon) mcolor(maroon) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"El sistema de investigación criminal es efectivo, promedio LAC" 			///
						2 	"El sistema de investigación criminal es efectivo, Chile" 					///
						3	"El sistema de adjudicación penal es oportuno y eficaz, promedio LAC"			///
						4	"El sistema de adjudicación penal es oportuno y eficaz, Chile"				///
						) rows(4) symysize(*0.65) symxsize(*0.65) keygap(*0.8))
			
graph export "$graphs/WJP, Criminal Justice pt 1, Chile & LAC.pdf", replace

twoway	(scatter BB Year if chile==0, connect(direct) symbol(O) lcolor(navy) mcolor(navy) msize(small))	///
		(scatter BB Year if chile==1, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small))	///
		(scatter BC Year if chile==0, connect(direct) symbol(T) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter BC Year if chile==1, connect(direct) lpattern(dash) symbol(Th) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter BD Year if chile==0, connect(direct) symbol(D) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter BD Year if chile==1, connect(direct) lpattern(dash) symbol(Dh) lcolor(dkgreen) mcolor(dkgreen) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"El sistema criminal es imparcial, promedio LAC" 			///
						2 	"El sistema criminal es imparcial, Chile" 					///
						3	"El sistema criminal está libre de corrupción, promedio LAC"			///
						4	"El sistema criminal está libre de corrupción, Chile"				///
						5	"El sistema criminal está libre de influencia indebida del gobierno de turno, promedio LAC"			///
						6	"El sistema criminal está libre de influencia indebida del gobierno de turno, Chile"			///
						) rows(6) size(vsmall) symysize(*0.65) symxsize(*0.65) keygap(*0.8))
						
graph export "$graphs/WJP, Criminal Justice pt 2, Chile & LAC.pdf", replace						



*04		General Indexes
twoway	(scatter WJPRuleofLawIndexOverallS Year if chile==0, connect(direct) symbol(O) lcolor(navy) mcolor(navy) msize(small))	///
		(scatter WJPRuleofLawIndexOverallS Year if chile==1, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"Índice General, promedio LAC" 			///
						2 	"Índice General, Chile") 					/// 
						rows(2) size(vsmall) symysize(*0.65) symxsize(*0.65) keygap(*0.8))

graph export "$graphs/WJP, General Index, Chile & LAC.pdf", replace		

twoway	(scatter Factor2 Year if chile==0, connect(direct) symbol(O) lcolor(navy) mcolor(navy) msize(small))	///
		(scatter Factor2 Year if chile==1, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small))	///
		(scatter Factor5 Year if chile==0, connect(direct) symbol(T) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter Factor5 Year if chile==1, connect(direct) lpattern(dash) symbol(Th) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter Factor8 Year if chile==0, connect(direct) symbol(D) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter Factor8 Year if chile==1, connect(direct) lpattern(dash) symbol(Dh) lcolor(dkgreen) mcolor(dkgreen) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"Índice de Corrupción, promedio LAC"			///
						2	"Índice de Corrupción, Chile"				///
						3	"Índice de Orden y Seguridad, promedio LAC"			///
						4	"Índice de Orden y Seguridad, Chile"				///
						5	"Índice de Justicia Criminal, promedio LAC"			///
						6	"Índice de Justicia Criminal, Chile"			///
						) rows(6) size(vsmall) symysize(*0.65) symxsize(*0.65) keygap(*0.8))
						
graph export "$graphs/WJP, Corruption, Order & Security and Criminal Justice Indexes, Chile & LAC.pdf", replace		

restore

preserve
*05		By Regions
collapse (mean) WJPRuleofLawIndexOverallS-BE, by(zone Year)

*06		General Indexes
twoway	(scatter WJPRuleofLawIndexOverallS Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter WJPRuleofLawIndexOverallS Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter WJPRuleofLawIndexOverallS Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter WJPRuleofLawIndexOverallS Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"Índice General, promedio LA" 			///
						2	"Índice General, promedio Caribe" 			///	
						3	"Índice General, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"Índice General, Chile") 					/// 
						rows(4) size(small) symysize(*0.65) symxsize(*0.65) keygap(*0.8))

graph export "$graphs/WJP, General Index, Chile LA Caribe y developed.pdf", replace	


*07		Corruption Indexes
twoway	(scatter Factor2 Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter Factor2 Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter Factor2 Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter Factor2 Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"Índice de Corrupción, promedio LA" 			///
						2	"Índice de Corrupción, promedio Caribe" 			///	
						3	"Índice de Corrupción, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"Índice de Corrupción, Chile") 					/// 
						rows(4) size(small) symysize(*0.65) symxsize(*0.65) keygap(*0.8))

graph export "$graphs/WJP, Corruption Index, Chile LA Caribe y developed.pdf", replace	

*08		Order & Security Indexes
twoway	(scatter Factor5 Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter Factor5 Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter Factor5 Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter Factor5 Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"Índice de Orden y Seguridad, promedio LA" 			///
						2	"Índice de Orden y Seguridad, promedio Caribe" 			///	
						3	"Índice de Orden y Seguridad, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"Índice de Orden y Seguridad, Chile") 					/// 
						rows(4) size(small) symysize(*0.65) symxsize(*0.65) keygap(*0.8))

graph export "$graphs/WJP, Order & Security Index, Chile LA Caribe y developed.pdf", replace	

*08		Fundamental Rights Indexes
twoway	(scatter Factor4 Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter Factor4 Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter Factor4 Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter Factor4 Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"Índice de Derechos Fundamentales, promedio LA" 			///
						2	"Índice de Derechos Fundamentales, promedio Caribe" 			///	
						3	"Índice de Derechos Fundamentales, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"Índice de Derechos Fundamentales, Chile") 					/// 
						rows(4) size(small) symysize(*0.65) symxsize(*0.65) keygap(*0.8))

graph export "$graphs/WJP, Fundamental Rights Index, Chile LA Caribe y developed.pdf", replace	

*09		Criminal Justice Indexes
twoway	(scatter Factor8 Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter Factor8 Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter Factor8 Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter Factor8 Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"Índice de Justicia Criminal, promedio LA" 			///
						2	"Índice de Justicia Criminal, promedio Caribe" 			///	
						3	"Índice de Justicia Criminal, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"Índice de Justicia Criminal, Chile") 					/// 
						rows(4) size(small) symysize(*0.65) symxsize(*0.65) keygap(*0.8))

graph export "$graphs/WJP, Criminal Justice Index, Chile LA Caribe y developed.pdf", replace	

restore


*10		By Countries
collapse (mean) WJPRuleofLawIndexOverallS-BE zone , by(Country Year)

encode Country, gen(pais)


*11		Corruption Variables
*	Corruption in Judiciary 
preserve 
collapse (mean) WJPRuleofLawIndexOverallS-BE, by(zone Year)
twoway	(scatter O Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter O Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter O Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter O Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"Corrupción en Poder Judicial, promedio LA" 			///
						2	"Corrupción en Poder Judicial, promedio Caribe" 			///	
						3	"Corrupción en Poder Judicial, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"Corrupción en Poder Judicial, Chile") 					/// 
						rows(4) size(small) symysize(*0.65) symxsize(*0.65) keygap(*0.8))

graph export "$graphs/WJP, Corruption Judiciary Power, Chile LA Caribe y developed.pdf", replace
restore


twoway	(line O Year if pais==6, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line O Year if pais==15, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line O Year if pais==18, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line O Year if pais==26, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line O Year if pais==37, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line O Year if pais==82, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line O Year if pais==99, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line O Year if pais==100, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line O Year if pais==135, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line O Year if pais==137, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line O Year if pais==24, connect(direct) lpattern(dash) lcolor(navy) msize(small) lwidth(medthick)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1 	"Corrupción en Poder Judicial, LA" 	///			
						11	"Corrupción en Poder Judicial, Chile"			///
						) rows(2) size(small))
		
graph export "$graphs/WJP, Corruption Judiciary Power, Chile & LAC.pdf", replace


*	Corruption in legislative

preserve 
collapse (mean) WJPRuleofLawIndexOverallS-BE, by(zone Year)
twoway	(scatter Q Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter Q Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter Q Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter Q Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"Corrupción en Poder Legislativo, promedio LA" 			///
						2	"Corrupción en Poder Legislativo, promedio Caribe" 			///	
						3	"Corrupción en Poder Legislativo, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"Corrupción en Poder Legislativo, Chile") 					/// 
						rows(4) size(small) symysize(*0.65) symxsize(*0.65) keygap(*0.8))

graph export "$graphs/WJP, Corruption Legislative Power, Chile LA Caribe y developed.pdf", replace
restore

twoway	(line Q Year if pais==6, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Q Year if pais==15, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Q Year if pais==18, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Q Year if pais==26, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Q Year if pais==37, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Q Year if pais==82, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Q Year if pais==99, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Q Year if pais==100, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Q Year if pais==135, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Q Year if pais==137, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Q Year if pais==24, connect(direct) lpattern(dash) lcolor(navy) msize(small) lwidth(medthick)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1 	"Corrupción en Poder Legislativo, LA" 	///			
						11	"Corrupción en Poder Legislativo, Chile"			///
						) rows(2) size(small))
		
graph export "$graphs/WJP, Corruption Legislative Power, Chile & LAC.pdf", replace


*11		Order & Security Variables
*	Crime is effectively controlled
preserve 
collapse (mean) WJPRuleofLawIndexOverallS-BE, by(zone Year)
twoway	(scatter AG Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter AG Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter AG Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter AG Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"El crimen es controlado de manera efectiva, promedio LA" 			///
						2	"El crimen es controlado de manera efectiva, promedio Caribe" 			///	
						3	"El crimen es controlado de manera efectiva, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"El crimen es controlado de manera efectiva, Chile") 					/// 
						rows(4) size(small) symysize(*0.65) symxsize(*0.65) keygap(*0.8))

graph export "$graphs/WJP, O&S crimen controlado efectivamente, Chile LA Caribe y developed.pdf", replace
restore

twoway	(line AG Year if pais==6, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AG Year if pais==15, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AG Year if pais==18, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AG Year if pais==26, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AG Year if pais==37, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AG Year if pais==82, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AG Year if pais==99, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AG Year if pais==100, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AG Year if pais==135, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AG Year if pais==137, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AG Year if pais==24, connect(direct) lpattern(dash) lcolor(navy) msize(small) lwidth(medthick)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1 	"El crimen es controlado de manera efectiva, LA" 	///			
						11	"El crimen es controlado de manera efectiva, Chile"			///
						) rows(2) size(small))

graph export "$graphs/WJP, O&S crimen controlado efectivamente, Chile & LAC.pdf", replace

*12		Fundamental Rights Variables
*	Right to life and security is guaranteed
preserve 
collapse (mean) WJPRuleofLawIndexOverallS-BE, by(zone Year)
twoway	(scatter Z Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter Z Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter Z Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter Z Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"El derecho a la vida y seguridad de las personas está efectivamente garantizado, promedio LA" 			///
						2	"El derecho a la vida y seguridad de las personas está efectivamente garantizado, promedio Caribe" 			///	
						3	"El derecho a la vida y seguridad de las personas está efectivamente garantizado, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"El derecho a la vida y seguridad de las personas está efectivamente garantizado, Chile") 					/// 
						rows(4) size(vsmall) symysize(*0.65) symxsize(*0.35) keygap(*0.5))

graph export "$graphs/WJP, FR derecho a la vida y seguridad, Chile LA Caribe y developed.pdf", replace
restore

twoway	(line Z Year if pais==6, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Z Year if pais==15, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Z Year if pais==18, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Z Year if pais==26, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Z Year if pais==37, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Z Year if pais==82, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Z Year if pais==99, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Z Year if pais==100, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Z Year if pais==135, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Z Year if pais==137, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line Z Year if pais==24, connect(direct) lpattern(dash) lcolor(navy) msize(small) lwidth(medthick)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1 	"El derecho a la vida y seguridad de las personas está efectivamente garantizado, LA" 	///			
						11	"El derecho a la vida y seguridad de las personas está efectivamente garantizado, Chile"			///
						) rows(2) size(vsmall))

graph export "$graphs/WJP, FR derecho a la vida y seguridad, Chile & LAC.pdf", replace

*12		Criminal Justice Variables
*	Criminal investigation system is effective
preserve 
collapse (mean) WJPRuleofLawIndexOverallS-BE, by(zone Year)
twoway	(scatter AY Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter AY Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter AY Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter AY Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"El sistema de investigación criminal es efectivo, promedio LA" 			///
						2	"El sistema de investigación criminal es efectivo, promedio Caribe" 			///	
						3	"El sistema de investigación criminal es efectivo, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"El sistema de investigación criminal es efectivo, Chile") 					/// 
						rows(4) size(vsmall) symysize(*0.65) symxsize(*0.65) keygap(*0.8))

graph export "$graphs/WJP, CJ sistema de investigación criminal es efectivo, Chile LA Caribe y developed.pdf", replace
restore

twoway	(line AY Year if pais==6, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AY Year if pais==15, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AY Year if pais==18, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AY Year if pais==26, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AY Year if pais==37, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AY Year if pais==82, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AY Year if pais==99, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AY Year if pais==100, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AY Year if pais==135, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AY Year if pais==137, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AY Year if pais==24, connect(direct) lpattern(dash) lcolor(navy) msize(small) lwidth(medthick)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1 	"El sistema de investigación criminal es efectivo, LA" 	///			
						11	"El sistema de investigación criminal es efectivo, Chile"			///
						) rows(2) size(small))
		
graph export "$graphs/WJP, CJ sistema de investigación criminal es efectivo, Chile & LAC.pdf", replace

*	Criminal investigation system is effective
preserve 
collapse (mean) WJPRuleofLawIndexOverallS-BE, by(zone Year)
twoway	(scatter AZ Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter AZ Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter AZ Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter AZ Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"El sistema de adjudicación penal es oportuno y eficaz, promedio LA" 			///
						2	"El sistema de adjudicación penal es oportuno y eficaz, promedio Caribe" 			///	
						3	"El sistema de adjudicación penal es oportuno y eficaz, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"El sistema de adjudicación penal es oportuno y eficaz, Chile") 					/// 
						rows(4) size(vsmall) symysize(*0.65) symxsize(*0.65) keygap(*0.8))

graph export "$graphs/WJP, CJ sistema de adjudicación penal es oportuno y eficaz, Chile LA Caribe y developed.pdf", replace
restore

twoway	(line AZ Year if pais==6, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AZ Year if pais==15, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AZ Year if pais==18, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AZ Year if pais==26, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AZ Year if pais==37, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AZ Year if pais==82, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AZ Year if pais==99, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AZ Year if pais==100, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AZ Year if pais==135, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AZ Year if pais==137, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line AZ Year if pais==24, connect(direct) lpattern(dash) lcolor(navy) msize(small) lwidth(medthick)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1 	"El sistema de adjudicación penal es oportuno y eficaz, LA" 	///			
						11	"El sistema de adjudicación penal es oportuno y eficaz, Chile"			///
						) rows(2) size(small))
		
graph export "$graphs/WJP, CJ sistema de adjudicación penal es oportuno y eficaz, Chile & LAC.pdf", replace

*	Criminal investigation system is impartial
preserve 
collapse (mean) WJPRuleofLawIndexOverallS-BE, by(zone Year)
twoway	(scatter BB Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter BB Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter BB Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter BB Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"El sistema criminal es imparcial, promedio LA" 			///
						2	"El sistema criminal es imparcial, promedio Caribe" 			///	
						3	"El sistema criminal es imparcial, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"El sistema criminal es imparcial, Chile") 					/// 
						rows(4) size(vsmall) symysize(*0.65) symxsize(*0.65) keygap(*0.8))

graph export "$graphs/WJP, CJ sistema criminal es imparcial, Chile LA Caribe y developed.pdf", replace
restore

twoway	(line BB Year if pais==6, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BB Year if pais==15, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BB Year if pais==18, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BB Year if pais==26, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BB Year if pais==37, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BB Year if pais==82, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BB Year if pais==99, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BB Year if pais==100, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BB Year if pais==135, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BB Year if pais==137, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BB Year if pais==24, connect(direct) lpattern(dash) lcolor(navy) msize(small) lwidth(medthick)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1 	"El sistema criminal es imparcial, LA" 	///			
						11	"El sistema criminal es imparcial, Chile"			///
						) rows(2) size(small))

graph export "$graphs/WJP, CJ sistema criminal es imparcial, Chile & LAC.pdf", replace

*	Criminal system is free of corruption
preserve 
collapse (mean) WJPRuleofLawIndexOverallS-BE, by(zone Year)
twoway	(scatter BC Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter BC Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter BC Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter BC Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"El sistema criminal está libre de corrupción, promedio LA" 			///
						2	"El sistema criminal está libre de corrupción, promedio Caribe" 			///	
						3	"El sistema criminal está libre de corrupción, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"El sistema criminal está libre de corrupción, Chile") 					/// 
						rows(4) size(vsmall) symysize(*0.65) symxsize(*0.65) keygap(*0.8))

graph export "$graphs/WJP, CJ sistema criminal está libre de corrupción, Chile LA Caribe y developed.pdf", replace
restore

twoway	(line BC Year if pais==6, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BC Year if pais==15, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BC Year if pais==18, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BC Year if pais==26, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BC Year if pais==37, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BC Year if pais==82, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BC Year if pais==99, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BC Year if pais==100, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BC Year if pais==135, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BC Year if pais==137, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BC Year if pais==24, connect(direct) lpattern(dash) lcolor(navy) msize(small) lwidth(medthick)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1 	"El sistema criminal está libre de corrupción, LA" 	///			
						11	"El sistema criminal está libre de corrupción, Chile"			///
						) rows(2) size(small))
		
graph export "$graphs/WJP, CJ sistema criminal está libre de corrupción, Chile & LAC.pdf", replace


*	Criminal system is free from undue influence
preserve 
collapse (mean) WJPRuleofLawIndexOverallS-BE, by(zone Year)
twoway	(scatter BD Year if zone==1, connect(direct) symbol(T) lcolor(gold) mcolor(gold) msize(small))	///
		(scatter BD Year if zone==3, connect(direct) symbol(S) lcolor(dkgreen) mcolor(dkgreen) msize(small))	///
		(scatter BD Year if zone==4, connect(direct) symbol(D) lcolor(maroon) mcolor(maroon) msize(small))	///
		(scatter BD Year if zone==2, connect(direct) lpattern(dash) symbol(Oh) lcolor(navy) mcolor(navy) msize(small)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1	"El sistema criminal está libre de influencia indebida del gobierno de turno, promedio LA" 			///
						2	"El sistema criminal está libre de influencia indebida del gobierno de turno, promedio Caribe" 			///	
						3	"El sistema criminal está libre de influencia indebida del gobierno de turno, promedio EU + EFTA + EEUU + Canadá" 			///	
						4 	"El sistema criminal está libre de influencia indebida del gobierno de turno, Chile") 					/// 
						rows(4) size(vsmall) symysize(*0.65) symxsize(*0.35) keygap(*0.35))

graph export "$graphs/WJP, CJ sistema criminal libre de influencia indebida del gobierno de turno, Chile LA Caribe y developed.pdf", replace
restore

twoway	(line BD Year if pais==6, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BD Year if pais==15, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BD Year if pais==18, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BD Year if pais==26, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BD Year if pais==37, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BD Year if pais==82, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BD Year if pais==99, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BD Year if pais==100, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BD Year if pais==135, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BD Year if pais==137, connect(direct) lcolor(gs12) mcolor(gs12) msize(small))	///
		(line BD Year if pais==24, connect(direct) lpattern(dash) lcolor(navy) msize(small) lwidth(medthick)),	///
		graphregion(color(white)) ytitle("Índice") xtitle("") 	///
		ylab(0(0.25)1) 	///
		legend(order(	1 	"El sistema criminal está libre de influencia indebida del gobierno de turno, LA" 	///			
						11	"El sistema criminal está libre de influencia indebida del gobierno de turno, Chile"			///
						) rows(2) size(small))

graph export "$graphs/WJP, CJ sistema criminal libre de influencia indebida del gobierno de turno, Chile & LAC.pdf", replace
