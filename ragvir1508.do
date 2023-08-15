clear all 
use GPA3.dta

*\ Computer exercise 1
*\ (a) Pooled OLS
reg trmgpa spring sat hsperc female black white tothrs crsgpa season

*\(c) 
reg ctrmgpa ctothrs cseason

********************
*\ Computer exercise 2
use "H:\traffic.dta", clear
reg fatal beertax if year==1982, robust
twoway (lfit fatal beertax if year==1982) (scatter fatal beertax if year==1982)

reg fatal beertax if year==1988
twoway (lfit fatal beertax if year==1982) (scatter fatal beertax if year==1982)

*\(2) One way Fixed effects
xtsum fatal beertax spircons unrate perincK state year // gives TV, BV and WV
xtreg fatal beertax spircons unrate perincK, fe // beer tax tilda as its demeaned


*\(3) Two way fixed effects
xi: xtreg fatal beertax spircons unrate perincK i.year, fe

test _Iyear_1983 _Iyear_1984 _Iyear_1985 _Iyear_1986 _Iyear_1987 _Iyear_1988


*\(4) One way Random effects - beetween estimator

xtreg fatal beertax spircons unrate perincK, be


*\(5) One way Random effects - pooled OLS

reg fatal beertax spircons unrate perincK


*\(6) One way Random effects - FGLS

xtreg fatal beertax spircons unrate perincK, re


*\(7) Hausman test FE vs RE

quietly xtreg fatal beertax spircons unrate perincK, fe

estimates store fix

quietly xtreg fatal beertax spircons unrate perincK, re

estimates store ran


hausman fix ran


