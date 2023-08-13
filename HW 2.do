******************
** Second computer exercise
************************************
clear all
cd "C:\Users\Hannah\Documents\LSE 2023\Part ll Tatiana"
use "C:\Users\Hannah\Documents\LSE 2023\Part ll Tatiana\AJR2001.dta"

************************************
* a)
reg loggdp risk 

* b) 
reg loggdp risk latitude africa asia other


* c) 
eststo first1: reg risk logmort0 
predict yhat1
* Second stage
eststo second1: ivregress 2sls loggdp (risk = logmort0)
* Alternative way to ivregress 2sls
reg loggdp yhat1 
* Output table 
esttab first1 second1


*d) 
* First stage 
eststo first: reg risk logmort0 latitude africa asia other
predict yhat

* Second stage
eststo second: ivregress 2sls loggdp latitude africa asia other (risk = logmort0)

* Alternative way to ivregress 2sls
reg loggdp yhat latitude africa asia other

* Output table 
esttab first second
