/*     EC312: Advanced Econometrics         */
/*      Solutions to Computer Exercises     */
/*            Problem Set 3 Question 1      */    



/* Description: This do-file produces stata output for the solutions of computer 
exercises in Problem Set 3 of EC312. Outputs are also saved in a separate log file
with the same name as this do-file. Please make sure you change the current directory
appropriately by placing the path of your working directory after "cd" in the preamble below.
Also make sure the datasets used in the exercises are saved in your working directory
with the same names they appear on Moodle or change the names after the "use" commands 
accordingly.

eststo:    You may need to install st0085_2   Making regression tables simplified  */



// Preamble:

clear
set more off
capture log close
cd "" // insert your own directory to a folder containing airq.dta and baltagigriffin.dta
eststo clear


log using ps3_solutions.log, replace

/* Question 1 */

use "airq.dta"

/* Before anything, check description, browse, summary and correlation matrix */
des
browse
sum
corr

/* Part a */

/* In the first part we just run OLS to get a feel for the results at a first glance */

scatter airq coas
scatter airq dens
scatter airq medi
eststo rega: reg airq vala rain coas dens medi
esttab rega

/* All regressors apart from coas are not significant (at 5%), yet the F test is 
significant. Normally we suspect multicollinearity, but can 
also be heteroskedasticity, because that will invalidate the F test as well 
as t tests. */

/* Part b */

test medi

test vala rain coas dens medi

/* medi is an insignificant regressor at 5% significance. Together, the variables have 
explanatory power (at 5% significance). */

/* Part c */

/* For the GQ test, we need to run the OLS on the coastal and noncoastal
areas separately. Then for both of these regressions, we need to collect
the s^2. The test statistic is simply their ratio */

quietly reg airq vala rain dens medi if coas==1
scalar s2coas = e(rss)/e(df_r)
scalar dfcoas = e(df_r)
display dfcoas

quietly reg airq vala rain dens medi if coas==0
scalar s2nocoas = e(rss)/e(df_r) // s^2 = dividing RSS/degree of freedoms
scalar dfnocoas = e(df_r)
display dfnocoas

scalar Fc = s2coas/s2nocoas
display Fc

display Ftail(dfcoas,dfnocoas,Fc) // here it is tested how to achieve F-distribution, result in what p-value we need to reject 

/* The results show a clear rejection of the null hypothesis of homoskedasticity.*/

/* To correct the tests from b we should do the tests using robust standard errors 
or FGLS. Consider first the robust results, that don't require a specification of
the heteroskedasticity. */

reg airq vala rain coas dens medi, robust
test vala rain coas dens medi

/* Note that robust standard errors do not solve all issues. 
White standard errors are only consistent estimators, and our sample size is small. 
We will do FGLS later in the question. */


/* Part d */

/* To do the Breusch-Pagan test, we need to run OLS, store residuals, square them
and then run a regression of the residuals squared on coas, to check for
significance in the auxilliary regression wrt this variable */

quietly reg airq vala rain coas dens medi
estat hettest vala rain coas dens medi


/* The evidence for heteroskedasticity is less strong. */

/* Part e */

/* A White test can be done on STATA using the ``imtest, white'' command. */

quietly reg airq vala rain coas dens medi
imtest, white

/* To see the test in its stages, 
we need to square all variables, interact all variables and then run a large 
auxilliary regression */

quietly reg airq vala rain coas dens medi
predict resid, r
gen resid2 = resid^2

gen vala2 = vala^2
gen rain2 = rain^2
gen medi2 = medi^2
gen dens2 = dens^2

gen valarain = vala*rain
gen valamedi = vala*medi
gen valacoas = vala*coas
gen valadens = vala*dens
gen rainmedi = rain*medi
gen raincoas = rain*coas
gen raindens = rain*dens
gen coasmedi = coas*medi
gen coasdens = coas*dens
gen medidens = medi*dens

reg resid2 vala rain coas medi dens vala2 rain2 medi2 dens2 valarain valamedi valacoas valadens rainmedi raincoas raindens coasmedi coasdens medidens
scalar White = e(N)*e(r2)
display White
display chi2tail(19,White)

/* White test is not a wise idea here at all - we only have 30 observations 
and we are creating a large number of regressors, so have very low
degrees of freedom left */

/* Part f */

/* After log transforming the form of the variance, we obtain a regression 
of logged residuals on coas and medi. We can then use p*F as the test statistic */

gen lnresid2 = ln(resid2)
reg lnresid2 coas medi
scalar pFf = 2*e(F)
display chi2tail(2,pFf)

/* Again, further evidence for heteroskedasticity, if we believe the validity
of the test. */

/* Part g */

/* To do FGLS, we need first to create the weights, then generate the new 
variables, then run the OLS on the transformed model */

predict ss, xb			// Creates a new variable called ss which contains fitted value from the previous regression
gen sigma2hat = exp(ss)
gen sigmahat = sqrt(sigma2hat)

gen airqW = airq / sigmahat
gen MinusW = 1/sigmahat
gen valaW = vala / sigmahat
gen rainW = rain / sigmahat
gen coasW = coas / sigmahat
gen densW = dens / sigmahat
gen mediW = medi / sigmahat

reg airqW MinusW valaW rainW coasW densW mediW, nocons
test valaW rainW coasW densW mediW, nocons

/* Medi is almost significant at the 5% level now. Vala and rain remain 
insignificant. There are many potential reasons why: maybe they really
do not matter for air quality, maybe our sample size is too small,
maybe we have endogeneity problems / OVB, or maybe we have specified the 
heteroskedasticity still incorrectly. Econometrics is not always simple! */

/* Part h */

/* The R2 in g) is not comparable to that is say a) as the TSS has changed. Both
the TSS and RSS have made corrections for the differing variance of these two
subsamples. */

/* Question 2 */
clear

use baltagigriffin.dta


* Create country dummy variables;
tab country, gen (c)

* a)
reg lgaspcar lincomep lrpgm lcarpcap c2-c18

// later we will need residuals from this regression, so let's save them now
predict olsresid, r

// alternatively, just estimate the fixed effect model
// the parameter estimates (and standard errors) on lincomep and lrpgm are identical
xtset country2 year
xtreg lgaspcar lincomep lrpgm lcarpcap, fe

* b)

scatter olsresid country2

* c), d)

reg lgaspcar lincomep lrpgm lcarpcap c2-c18
testparm c2-c18, equal

// correction for general heteroskedasticity
reg lgaspcar lincomep lrpgm lcarpcap  c2-c18, robust
testparm c2-c18, equal


// correction for clustering by country (not merely heteroskedasticity)
reg lgaspcar lincomep lrpgm lcarpcap  c2-c18, vce(cluster country2)
testparm c2-c18, equal


* e)
// assume E(epsilon_it ^2)= = sigma_i^2

reg lgaspcar lincomep lrpgm lcarpcap  c2-c18
estat hettest c2-c18
estat imtest, white
robvar olsresid, by (country)

* f)

// first step of FGLS, allows us to estimate sigma2hat!
gen olsresid2 = olsresid^2
reg olsresid2 c1-c18, nocons
predict sigma2hat, xb

//second step of FGLS is a weighted least squares
gen olsweight=1/(sqrt(sigma2hat))
reg lgaspcar lincomep lrpgm lcarpcap c2-c18 [aweight=olsweight]

log close
translate ps3_solutions.log ps3_solutions.pdf, replace
