/* EC312: Advanced Econometrics */
/*  LSE Summmer School 2012 Session 3  */
/*   Solutions to Computer Exercises   */
/*           Part 2 Problem Set 3           */

/* Description: This do-file produces stata output for the solutions of computer
exercise 1 on 2SLS in EC312. Outputs are also saved in a separate log file
with the same name as this do-file. Please make sure you change the current directory
appropriately by placing the path of your working directory after "cd" in the preamble below.
eststo: You may need to install st0085_2   Making regression tables simplified  */


// Preamble:
clear
set more off
capture log close



log using ps3_solutions.log, replace

/* Computer exercise 1 on 2SLS */

 use "H:\FERTIL2.DTA"

*******************
* Question (a)
reg children educ age agesq urban
eststo ols: reg children educ age agesq urban, robust
* effect of educ on children = negative, significant, one additional year holding all else equal (controlling for age and urban) reduce number of children by 0.8 oc not possible to cut kids in pieces but 0.8 is avg value (conditional mean reduction)
. di 100*_b[educ]
* -8.3447192
* educ is endo bc its likely that epsilon has unobserved factors in it, s.a. 
* SES, Marriage (married women have lower years of educ but liklz more kids)


*******************
* Question (b)
reg educ age agesq urban frsthalf, robust 
// 1st stage, frsthalf signi -> relevance check
* simulteanity, joint determination, endogenously determined within system -> theoretical issue
= threads to identification of causal effects (econ) aka inconsistency concern (stats)


*******************
* Question (c)
eststo IV: ivregress 2sls children age agesq urban (educ=frsthalf), robust
* educ still signi but marginally less (through inflated errors from 1st stage) 
* larger in magnitude almost double, but sign same 

esttab ols IV
* less significance
* changes in magnitude

*******************
* Question (d)
eststo olsd: reg children educ age agesq urban electric tv bicycle, robust
eststo ivd: ivregress 2sls children  age agesq urban electric tv bicycle (educ=frsthalf), robust

esttab olsd ivd
* educ: remains almost the same except that significance decrease in d) model as additional covariates absorb a bit of explanatory power. Sign remains same. 

* exog covariates: Exogeneous covariates lose signi as well going from ols to iv, as bad apple phenomenon grasps
* tv: negative, probly endo issue having more money implies having more likely tv and in meantime more money decreases number of children








log close  
