/*******************************************************************************
El Colegio de Mexico
Centro de Estudios Demograficos Urbanos y Ambientales - CEDUA
Título: Desigualdades sociodemográficas en el auto reporte de síntomas por COVID-19 de las personas mayores bolivianas, por condición étnica.

Objectivos:
1) Determinar la asociación entre las variables sociodemográficas y los síntomas auto reportados por COVID-19 de personas mayores.
2) Investigar la desigualdad de esta relación por condición étnica.

Variable dependiente: Auto reporte de síntomas por COVID-19 en personas mayores
Independent variables: Ocupación, Arreglo residencial, Logro educativo, Afiliación a seguro
Control variables: Género, estado laboral actual, área de residencia, condicióon étnica 

Base de datos: Encuesta de Hogares 2020.

Muestra analítica n = 4 248

Date created:14/ene/2022
Last modification: 11/oct/2022

Ubicación de la base de datos: http://anda.ine.gob.bo/index.php/catalog/88
*******************************************************************************/

*La base de datos original se encuentra en formato SPSS.
*Nota: reemplace el directorio de trabajo por el suyo.

*Una vez descargada la base de dattos, se importa a la extensión de Stata
import spss using "C:\Users\Vladimir Pinto\Documents\Base de datos\Bolivia\EH Bolivia\2020\EH2020_Persona.sav", clear

*Guardar el archivo
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\ALAP propuesta\Base_de_datos\EH2020_Persona.dta"


************************************************
****************Bolivia 2020********************
************************************************
clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\ALAP propuesta\Base_de_datos\EH2020_Persona.dta", clear
set more off

*Adultos mayores en el hogar
by folio, sort: egen numadm = total(inrange(s01a_03,60,112))
label variable numadm "numero de adultos mayores en el hogar"

*Crear variable de año
generate int year:YEAR = 2020
label variable year "year"


**# Bookmark #1
*********************************************************************
*****VARIABLE DEPENDIENTE: Auto reporte de síntomas por COVID-19*****
*********************************************************************

recode s02a_02 ///
	(1 = 1 "Con_síntomas") ///
	(2 = 0 "Sin_síntomas") ///
	, gen (covid) label (covid)
label variable covid "Autoreporte de síntomas por COVID-19"
tab covid, missing


*********************************************************************
********************VARIABLES INDEPENDIENTES*************************
*********************************************************************

**# Bookmark #2
***********Logro educativo
*Conversion de la variable aestudio a la variable education para estandarizar el logro educativo.
recode aestudio ///
	(0/6 . = 1 "Primaria") ///
	(7/11 = 2 "Menos de secundaria completa") ///
	(12 = 3 "Secundaria completa") ///
	(13/23 = 4 "Superior") ///
	, gen (educacion) label (educacion)
label variable educacion "Logro educativo"

**# Bookmark #3
***********Condición étnica

***A) Pertenencia Étnica - PE
tab s01a_08, mi

*Conversión variable s03a_04 a pertenencia étnica
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?

recode s01a_08 ///
	(1 = 1 "Pertenece") ///
	(2 = 0 "No_pertenece") ///
	, gen (PE) label (PE)
label variable PE "Pertenencia étnica"
replace PE=. if PE == 3
tab PE, missing

***B) Idioma que habla - IH
*B.1) Primer idioma
tab s01a_06_1,mi
*Conversión variable s01a_06_1 a Idioma que habla
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°

recode s01a_06_1 ///
	(2 10/33 = 1 "Idioma originario") ///
	(6 = 0 "Castellano") ///
	(41/996 = 3 "Otro") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Idioma que habla 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Segundo idioma
tab s01a_06_2,mi
*Conversión variable s01a_06_2 a Idioma que habla
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°

recode s01a_06_2 ///
	(1/4 7/34 39 = 1 "Idioma originario") ///
	(6 = 0 "Castellano") ///
	(41/70 = 3 "Otro") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Idioma que habla 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Conversión a la variable Idioma que Habla
// .f = fill - llena aquellas variables para cuidar que exista missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Solo español" ///
1 "Idioma originario sin castellano" ///
2 "Idioma originario con castellano"
label values IH IH
label variable IH "Idioma que habla"
tab IH, missing

***C) Lengua materna - LM
tab s01a_07,mi
*Conversión variable s01a_07 a Lengua materna
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?

recode s01a_07 ///
	(2 4 7/33 = 1 "Originaria") ///
	(6 34/60  = 0 "No_originaria") ///
	, gen (LM) label (LM)
label variable LM "Lengua materna"
tab LM, missing

*Creación variable Condición Étnico Linguistica - CEL
*Conversión a la variable CEL
// .f = fill - genera un vector con valores para que exista missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Cohorte de indígena/no indígena
recode CEL ///
	(0 1 = 1 "Condición étnica nula") ///
	(2 3 = 2 "Cohorte por condición linguistica") ///
	(4 = 3 "Cohorte por pertenencia") ///
	(5/7 = 4 "Plena condición étnica") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohortes de condición étnica"
tab cohorte_cel, missing

**# Bookmark #4
*Condición étnica: indígena/no indígena
recode cohorte_cel ///
	(1 .f = 0 "No_indígena") ///
	(2/4 = 1 "Indígena") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Condición étnica"

**# Bookmark #5 
***********Ocupación
*Conversión variable cob_op a ocupación
recode cob_op ///
	(5/9 = 1 "Trabajador manual") ///
	(0/4 = 2 "Directivo, Profesional y técnico, Administrativo") ///
	(. = 3 "No trabaja") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Ocupación"


**# Bookmark #6
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s01a_03
destring (edad),replace

****Age groups
recode edad ///
	(0/4 = 1 "0-4") ///
	(5/9 = 2 "5-9") ///
	(10/14 = 3 "10-14") ///
	(15/19 = 4 "15-19") ///
	(20/24 = 5 "20-24") ///
	(25/29 = 6 "25-29") ///
	(30/34 = 7 "30-34") ///
	(35/39 = 8 "35-39") ///
	(40/44 = 9 "40-44") ///
	(45/49 = 10 "45-49") ///
	(50/54 = 11 "50-54") ///
	(55/59 = 12 "55-59") ///
	(60/64 = 13 "60-64") ///
	(65/69 = 14 "65-69") ///
	(70/74 = 15 "70-74") ///
	(75/79 = 16 "75-79") ///
	(80/84 = 17 "80-84") ///
	(85/89 = 18 "85-89") ///
	(90/94 = 19 "90-94") ///
	(95/98 = 20 "95-98") ///
	, gen (edad_piramide) label (edad_piramide)
label variable edad_piramide "Edad quinquenal"


*********************************************************************
********************VARIABLES DE CONTROL*****************************
*********************************************************************

**# Bookmark #7
***********Sexo
*Recodificación de la variable s01a_02 a sexo
tab s01a_02, mi

recode s01a_02 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Sexo"
tab sex,mi

**# Bookmark #8
***********Estado laboral actual
*Recodificación de la variable s06a_01 a Esatdo laboral actual
recode s04a_01 ///
	(1 = 1 "Trabaja") ///
	(2 = 0 "No_trabaja") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Estado laboral actual"
tab condicion_laboral,mi


**# Bookmark #9
***********Área de residencia 
*Recodificación de la variable area en urban
tab area, mi
recode area ///
	(1 = 1 "Urbana") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "Área de residencia "
tab urban,mi


**# Bookmark #10
***********Arreglo residencial
*Hogar Unipersonal: conformado por una sola persona, que por definición es clasificada como el jefe o jefa de hogar.
*Hogar nuclear completo con/sin hijos: compuesto por el jefe de hogar, cónyuge e hijos (de tenerlos).
*Hogar compuesto: compuesto por el hogar nuclear o extendido con o sin otros no familiares.

*Conversion de la variable s01a_05 a p_parentescor
sort folio
clonevar p_parentescor=s01a_05

*Crea vectores con cada relación familiar
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Crea nuevos vectores agrupándolos por cada relación familiar
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*Se asigna un valor a cada relación familiar para el osterior cálculo del arreglo residencial.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*La variable totreco se genera con el valor total del arreglo residencial.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*La variable totrecon se recodifica con los arreglos residenciales.
recode totreco ///
	(1 33= 1 "Unipersonal") ///
	(5 7 37 39 3 35= 2 "Nuclear con/sin hijos") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Compuesto con/sin familiares") ///
	(0 = 4 "Otros") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Arreglo residencial"


**# Bookmark #11
***********Servicios de salud
*Recodificación de la variable s02a_01a en seguro
clonevar seguro = s02a_01a
destring (seguro),replace
label variable seguro "Afiliación seguro"
tab seguro, missing

*Recodificación de la variable seguro en afiliación seguro.
recode seguro ///
	(1 2 3 = 1 "Público") ///
	(4 5 = 2 "Privado") ///
	(6 = 3 "Ninguno") ///
	, gen (afiliacion_salud) label (afiliacion_salud)
label variable afiliacion_salud "Afiliación seguro"
tab afiliacion_salud, missing

*** Elaboración datos para Pirámides del autoreporte total
tab edad_piramide sex if covid == 1 [iw=factor] 

*** Elaboración datos para Pirámides población total
tab edad_piramide sex [iw=factor] 

*** Elaboración datos para Pirámides del autoreporte por condición étnica
bysort condic_etnica: tab edad_piramide sex if covid == 1 [iw=factor] 

*** Elaboración datos para Pirámides por condición étnica
bysort condic_etnica: tab edad_piramide sex [iw=factor] 

*** Edad media de la población autoreportada con covid
*Hombre
by condic_etnica: summ edad if covid==1 & sex==0
*Mujer
by condic_etnica: summ edad if covid==1 & sex==1

**# Bookmark #12
***Muestra con el grupo de edad de interés: 60-98
mark univ if inrange(edad,60,98)

tab univ, mi
keep if univ

**# Bookmark #13
*********************************************************************
*****Selección de la base de datos con las variables del estudio*****
*********************************************************************

keep factor numadm year covid educacion condic_etnica ocupacion sex urban tipo_hogar condicion_laboral afiliacion_salud

**# Bookmark #14
*********************************************************************
********************ANÁLISIS BIVARIADO*******************************
*********************************************************************

**# Bookmark #15
***********logro educativo
***Total
tab educacion, gen(educacion)
tab1 educacion1 educacion2 educacion3 educacion4, mi
*Appendix A
tab educacion covid [iw=factor] , row nofreq
*tab educacion covid

***Condición étnica
*Appendix A
bysort condic_etnica: tab educacion covid [iw=factor] , row nofreq
*bysort condic_etnica: tab educacion covid

**# Bookmark #16
***********Condición étnica
tab condic_etnica, gen(condic_etnica)
tab1 condic_etnica1 condic_etnica2, mi
*Appendix A
tab condic_etnica covid [iw=factor] , row nofreq
*tab condic_etnica covid

**# Bookmark #17
***********Ocupación
tab ocupacion, gen(ocupacion)
tab1 ocupacion1 ocupacion2 ocupacion3, mi
*Appendix A
tab ocupacion covid [iw=factor] , row nofreq
*tab ocupacion covid

***COndición étnica
*Appendix A
bysort condic_etnica: tab ocupacion covid [iw=factor] , row nofreq
*bysort condic_etnica: tab ocupacion covid

**# Bookmark #18
***********Condición laboral
tab condicion_laboral, gen(condicion_laboral)
tab1 condicion_laboral1 condicion_laboral2, mi
*Appendix A
tab condicion_laboral covid [iw=factor] , row nofreq
*tab condicion_laboral covid

***Condición étnica
*Appendix A
bysort condic_etnica: tab condicion_laboral covid [iw=factor] , row nofreq
*bysort condic_etnica: tab condicion_laboral covid

**# Bookmark #19
**************afiliacion_salud
tab afiliacion_salud, gen(afiliacion_salud)
tab1 afiliacion_salud1 afiliacion_salud2 afiliacion_salud3, mi
*Appendix A
tab afiliacion_salud covid [iw=factor] , row nofreq
*tab afiliacion_salud covid

***Condición étnica
*Appendix A
bysort condic_etnica: tab afiliacion_salud covid [iw=factor] , row nofreq
*bysort condic_etnica: tab afiliacion_salud covid

**# Bookmark #20
***********Sexo
tab sex, gen(sex)
tab1 sex1 sex2, mi
*Appendix A
tab sex covid [iw=factor] , row nofreq
*tab sex covid

***Condición étnica
*Appendix A
bysort condic_etnica: tab sex covid [iw=factor] , row nofreq
*bysort condic_etnica: tab sex covid

**# Bookmark #21
***********Área de residencia
tab urban, gen(urban)
tab1 urban1 urban2, mi
*Appendix A
tab urban covid [iw=factor] , row nofreq
*tab urban covid

***Condición étnica
*Appendix A
bysort condic_etnica: tab urban covid [iw=factor] , row nofreq
*bysort condic_etnica: tab urban covid

**# Bookmark #22
***********Arreglo residencial
tab tipo_hogar, gen(tipo_hogar)
tab1 tipo_hogar1 tipo_hogar2 tipo_hogar3, mi
*Appendix A
tab tipo_hogar covid [iw=factor] , row nofreq
*tab tipo_hogar covid

***Condición étnica
*Appendix A
bysort condic_etnica: tab tipo_hogar covid [iw=factor] , row nofreq
*bysort condic_etnica: tab tipo_hogar covid


**# Bookmark #24
*********************************************************************
**************************MODELAJE***********************************
********************ANÁLISIS BIVARIADO*******************************
*********************************************************************

***Establecer categorías de referencia
fvset base 3 ocupacion
fvset base 1 tipo_hogar
fvset base 2 educacion
fvset base 1 afiliacion_salud
fvset base 1 sex
fvset base 0 condicion_laboral
fvset base 0 urban
fvset base 0 condic_etnica


logit covid i.ocupacion, or
estat ic

logit covid i.tipo_hogar, or
estat ic

logit covid i.educacion, or
estat ic

logit covid i.afiliacion_salud, or
estat ic

logit covid i.condic_etnica, or
estat ic

logit covid i.sex, or
estat ic

logit covid i.condicion_laboral, or
estat ic

logit covid i.urban, or
estat ic

**# Bookmark #25

*********************************************************************
**************************MODELO 1************************************
*********************************************************************

***Establecer categorías de referencia
fvset base 3 ocupacion
fvset base 1 tipo_hogar
fvset base 2 educacion
fvset base 1 afiliacion_salud
fvset base 1 sex
fvset base 0 condicion_laboral
fvset base 0 urban
fvset base 0 condic_etnica


***Modelo basal interactuado por condición étnica - Odds Ratio
logit covid i.ocupacion /// 
	i.tipo_hogar ///
	i.educacion ///
	i.afiliacion_salud ///
	i.sex ///
	i.condicion_laboral ///
	i.urban, or
estat ic



/*
-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
           . |      4,248  -1606.348  -1555.466      13   3136.931   3219.536
-----------------------------------------------------------------------------

*/

**# Bookmark #26
*********************************************************************
**************************MODELO 2************************************
*********************************************************************

***Establecer categorías de referencia
fvset base 3 ocupacion
fvset base 1 tipo_hogar
fvset base 2 educacion
fvset base 1 afiliacion_salud
fvset base 1 sex
fvset base 0 condicion_laboral
fvset base 0 urban
fvset base 0 condic_etnica

***Modelo basal interactuado por condición étnica - Odds Ratio
logit covid i.ocupacion /// 
	i.tipo_hogar ///
	i.educacion ///
	i.afiliacion_salud ///
	i.sex ///
	i.condicion_laboral ///
	i.urban ///
	i.condic_etnica, or
estat ic


/*
-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
           . |      4,248  -1606.348  -1553.612      14   3135.224   3224.183
-----------------------------------------------------------------------------

*/

**# Bookmark #27
*********************************************************************
**************MODEL 3: COMPLETAMENTE INTERACTUADO********************
*********************************************************************

***Establecer categorías de referencia
fvset base 3 ocupacion
fvset base 1 tipo_hogar
fvset base 2 educacion
fvset base 1 afiliacion_salud
fvset base 1 sex
fvset base 0 condicion_laboral
fvset base 0 urban
fvset base 0 condic_etnica

***Modelo basal interactuado por condición étnica - Odds Ratio
logit covid i.ocupacion /// 
	i.tipo_hogar ///
	i.educacion ///
	i.afiliacion_salud ///
	i.sex ///
	i.condicion_laboral ///
	i.urban ///
	i.condic_etnica ///
	i.ocupacion#condic_etnica /// 
	i.tipo_hogar#condic_etnica ///
	i.educacion#condic_etnica ///
	i.afiliacion_salud#condic_etnica ///
	i.sex#condic_etnica ///
	i.condicion_laboral#condic_etnica ///
	i.urban#condic_etnica, or
estat ic

/*
						
-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
           . |      4,248  -1606.348  -1544.873      26   3141.745   3306.954
-----------------------------------------------------------------------------

*/

**# Bookmark #28
*********************************************************************
**************************CHOW TEST**********************************
*********************************************************************

*Install chowtest module
*Qunyong Wang, 2020. "CHOWTEST: Stata module to perform Chow test for structural break," Statistical Software Components S458875, Boston College Department of Economics.
*https://ideas.repec.org/c/boc/bocode/s458875.html

ssc install chowtest

********Chow test by ethnicity
chowtest covid ocupacion1 ocupacion2 /// 
	tipo_hogar2 tipo_hogar3 ///
	educacion1 educacion3 educacion4 ///
	afiliacion_salud2 afiliacion_salud3 ///
	sex2 ///
	condicion_laboral1 ///
	condic_etnica2 ///
	urban2, group(condic_etnica)

*************************************************************************

gen ocupacion1_et = ocupacion1*condic_etnica
gen ocupacion2_et = ocupacion2*condic_etnica
gen tipo_hogar2_et = tipo_hogar2*condic_etnica
gen tipo_hogar3_et = tipo_hogar3*condic_etnica
gen educacion1_et = educacion1*condic_etnica
gen educacion3_et = educacion3*condic_etnica
gen educacion4_et = educacion4*condic_etnica
gen afiliacion_salud2_et = afiliacion_salud2*condic_etnica
gen afiliacion_salud3_et = afiliacion_salud3*condic_etnica
gen sex1_et = sex1*condic_etnica
gen condicion_laboral2_et = condicion_laboral2*condic_etnica
gen urban2_et = urban2*condic_etnica


logit covid ocupacion1 ocupacion2 /// 
	tipo_hogar2 tipo_hogar3 ///
	educacion1 educacion3 educacion4 ///
	afiliacion_salud2 afiliacion_salud3 ///
	sex1 ///
	condicion_laboral2 ///
	urban2 ///
	condic_etnica ///
	ocupacion1_et ocupacion2_et /// 
	tipo_hogar2_et tipo_hogar3_et ///
	educacion1_et educacion3_et educacion4_et ///
	afiliacion_salud2_et afiliacion_salud3_et ///
	sex1_et ///
	condicion_laboral2_et ///
	urban2_et, or
estat ic

lincom ocupacion1+ocupacion1_et, or
lincom ocupacion2+ocupacion2_et, or
lincom tipo_hogar2+tipo_hogar2_et, or
lincom tipo_hogar3+tipo_hogar3_et, or
lincom educacion1+educacion1_et, or
lincom educacion3+educacion3_et, or
lincom educacion4+educacion4_et, or
lincom afiliacion_salud2+afiliacion_salud2_et, or
lincom afiliacion_salud3+afiliacion_salud3_et, or
lincom sex1+sex1_et, or
lincom condicion_laboral2+condicion_laboral2_et, or
lincom urban2+urban2_et, or

