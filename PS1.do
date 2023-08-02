/* EC312: Advanced Econometrics */
/*  LSE Summmer School 2018 Session 4  */
/*   Solutions to Computer Exercises   */
/*           Problem Set 1            */

/* Description: This do-file produces stata output for the solutions of computer
exercises in Problem Set 1 of EC312. Outputs are also saved in a separate log file
with the same name as this do-file. Please make sure you change the current directory
appropriately by placing the path of your working directory after "cd" in the preamble below. */

// Preamble:
clear
set more off
capture log close
cd "" /* Insert the directory where you saved the data set, e.g. "H:\Summer School\EC312\Problem Sets\PS1" */
eststo clear
log using ps1_solutions.log, replace


* Problem Set I.1
* Exercise 2.2 (Individual Wages) in Verbeek

use "wages1.dta"


* Question (a)

tab male, su(wage)

sum wage if male==1                                        /* Calculating average hourly wages for males */
scalar average_male=r(mean)
display "The average hourly wages for men is " %-9.2f average_male

sum wage if male==0                                        /* Calculating average hourly wages for females */
scalar average_female=r(mean)
display "The average hourly wages for women is " %-9.2f average_female
display "The difference between both averages is " %-9.2f average_male-average_female


*Questions (b) i., (b) ii., (b) iii.

regress wage male                                                 /* Simple Regression of wages on male dummy */


* Question (b) iv.

gen female=abs(1-male)                                      /* Generating the female dummy */
regress wage male female                                    /* Proposed regression (dummy trap) */

reg wage female 											/* Alternative regression specification: female, no male */
reg wage female male, nocons								/* Alternative regression specification: female and male but no constant */
drop female                                                 /* Dropping the female dummy from our data set */


* Questions (b) v. and (b) vi.
regress wage male

test male																		/* F statistic*/
		/* If instead we want to do a t-test for a one-sided hypothesis we need to do it manually: */																		
local sign_bm = sign(_b[male])													/* sign of coefficient*/
display "Ho: coef <= 0  p-value = " %9.4f ttail(r(df_r),`sign_bm'*sqrt(r(F))) 	/* p-value for one sided alternative b>0*/


* Question (c) i., 
gen logwage = log(wage)
reg logwage male exper school

* Question (c) ii. 

test male exper school                                                /* Testing H0: male=exper=school=0 */

* Question (c) iii.

gen educ_male = male*school                                        /* Generating `cross' effects */
regress logwage male exper school educ_male                           /* Extending the model to meet the criticism */
test educ_male

* Question (d) i. and (d) ii.

// gen exper2 = exper^2                                                  /* Generating squared effects */
reg logwage male exper school exper2

test exper2							/* F statistic*/
local sign_ba2 = sign(_b[exper2])					/* sign of coefficient*/
display "Ho: coef >= 0  p-value = " %9.4f 1-ttail(r(df_r),`sign_ba2'*sqrt(r(F))) /* p-value for one sided alternative b>0*/

pwcorr exper2 exper male school, star(.01)

log close  

translate "ps1_solutions.log" "ps1_solutions.pdf"
