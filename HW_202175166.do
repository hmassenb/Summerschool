***********************
* Homework LSE 
***********************
* a)
clear all
cd "C:\Users\Hannah\Documents\LSE 2023\Part I Dr Marcia Schafgans"
use "FERTIL2.dta"
log using HW.log, replace 

***************************

* b)
gen kids = 0 
replace kids = 1 if children > 0 

des kids // for storage type and display format
sum kids // N, mean, std, min, max, optionally adding ,d for an even more detailed summary 
tab kids // Frequency, Percentage and Cumulative distribution of people with kids and without

/* mean of kids by sum is equal to percent of persons with kids in percentage by tab */


***************************
*c) 
gen age2 = age^2
reg kids educ age age2 urban electric tv
gen beduc = _b[educ]
tab beduc

test educ // F-test = 4,93 
ttest educ, by(kids) // t-test = 13,16
* -> educ is significant different from 0 

***************************
*d)
probit kids educ age age2 urban electric tv
gen pr_beduc = _b[educ]
tab pr_beduc //  -.0200778
test educ //  chi^2_(1) = 6.99, Prob > chi2 = 0.0082 => signi 


***************************
*e)
probit kids educ age age2 urban electric tv
estimates store unrestricted
gen ages = age + age2
constr define 1 ages=0
probit kids educ urban electric tv, constraint(1)
estimates store restricted
lrtest unrestricted restricted // LR = 1753.76

***************************
*f)
probit kids educ age age2 urban electric tv
* average marginal effect: 
margins, dydx(educ) // dy/dx = -.0039367, z=-2.64, P>|z|=0.008


***************************
*f) 2
 poisson children educ age age2 urban electric tv
margins , dydx(educ) // -.0552558  
margins , dydx(educ) atmeans // -.0373835 
margins , dydx(educ) at(educ=0) // -.061865 
margins , dydx(educ) at(educ=20) //  -.0380003  
margins , dydx(educ) at(educ=(0(1)20)) // observing that impact of additional year is decreasing the more education someone has






close log 