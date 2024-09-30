// Set the graph scheme for visuals
set scheme burd
//Import the data
use Data/parties_cntries, clear
//Naming convention for models
rename election_year year
rename pct_women_party ofwomen
rename total_mep mepsparty
// Drop observations with missing values in key variables (euposition, GAL-TAN scale, etc.)
drop if mi(euposition)
// Drop parties that only have one MEP
drop if mepsparty == 1

// Create an indicator for open ballot (open + STV systems), where 0 = closed lists
gen ballot_open = ballottype != 2 
// Create an indicator for at least some gender quotas
gen quota_cntry 		= quota != 3

gen l_gdp = log(gdp)
replace ofwomen = ofwomen*100
hist ofwomen, bin(10) freq xtitle("% of women")
graph export "Graphs/basic_hist.png", replace
graph export "Graphs/basic_hist.pdf", replace
gr close


//Table 1: Model 1
mixed ofwomen  i.cntry  ///
	 euposition  leftrightscale galtanscale   ///
	 i.CEE#c.euposition   i.CEE#c.leftrightscale   i.CEE#c.galtanscale mepsparty ///
	  quota_cntry  zipping ballot_open  ///
	    || party: 	
outreg2 using Results_outputs/paper_final_model , word stats(coef se)  alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,^) replace

//Table 1: Model 2
mixed ofwomen  i.cntry  ///
	 euposition  leftrightscale galtanscale   ///
	 i.CEE#c.euposition   i.CEE#c.leftrightscale   i.CEE#c.galtanscale mepsparty ///
	  quota_cntry  zipping ballot_open  ///
	   trad_secular surv_selfexp    || party: 	
		
outreg2 using Results_outputs/paper_final_model , word stats(coef se)  alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,^)  append


//Table 1: Model 3
mixed ofwomen  i.cntry  ///
	  rollover_female_rat rollover_male_rat ///
	  euposition  leftrightscale galtanscale   ///
	 i.CEE#c.euposition   i.CEE#c.leftrightscale   i.CEE#c.galtanscale mepsparty  ///
	  quota_cntry  zipping ballot_open  ///
	   l_gdp trad_secular surv_selfexp  i.year  ///
	 || party: 	 

outreg2 using Results_outputs/paper_final_model , word stats(coef se)  alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,^)  append


//Figures 4
order cntry CEE 
foreach var of varlist  ofwomen - l_gdp{

	egen m_`var'	= mean(`var') , by(cntry) 
	gen de_`var'	= `var' - m_`var'
}


/*
Due to numerical considerations the demeaned MLE model may produce slightly different estimates compared to our baseline model with country fixed effects. 
However, when country fixed effects are added to the demeaned model, the estimates become identical to the one with fixed effects only.

The purpose of figures with predictive margins is to visually present the estimates of Model 3 while emphasizing the relative (demeaned) nature of the independent variables. 
Therefore, we apply the demeaned model with country fixed effects, even though the fixed effects themselves are not needed from theoretical standpoint. 
This approach guarantees that the estimates used in the visualizations are consistent with those from the main Model 3, providing the same values for calculating predictive margins on the demeaned variables.
*/


mixed de_ofwomen   ///
	  de_rollover_female_rat de_rollover_male_rat ///
	  de_euposition  de_leftrightscale de_galtanscale   ///
	 i.CEE#c.de_euposition   i.CEE#c.de_leftrightscale   i.CEE#c.de_galtanscale de_mepsparty  ///
	  de_quota_cntry  de_zipping de_ballot_open  ///
	   de_surv_selfexp de_trad_secular de_l_gdp  i.year ///
	 || party: 	 
estimates store de_model
mixed de_ofwomen  i.cntry  ///
	  de_rollover_female_rat de_rollover_male_rat ///
	  de_euposition  de_leftrightscale de_galtanscale   ///
	 i.CEE#c.de_euposition   i.CEE#c.de_leftrightscale   i.CEE#c.de_galtanscale de_mepsparty  ///
	  de_quota_cntry  de_zipping de_ballot_open  ///
	   de_surv_selfexp de_trad_secular de_l_gdp  i.year ///
	 || party: 		 
estimates store de_model_i_cntry  

//slight divergence//
estimates table de_model de_model_i_cntry ,  b(%7.4f) p varw(50) model(20)

mixed de_ofwomen  i.cntry  ///
	  de_rollover_female_rat de_rollover_male_rat ///
	  de_euposition  de_leftrightscale de_galtanscale   ///
	 i.CEE#c.de_euposition   i.CEE#c.de_leftrightscale   i.CEE#c.de_galtanscale de_mepsparty  ///
	  de_quota_cntry  de_zipping de_ballot_open  ///
	   de_surv_selfexp de_trad_secular de_l_gdp  i.year ///
	 || party: 		 

sum de_galtanscale
local mini = `r(min)'
local interv = (`r(max)' - `r(min)')/8
margins CEE, at(de_galtanscale = (`r(min)'(`interv')`r(max)'))
marginsplot, legend(order(1 "" 2 "")) title("Predictive Margins") xtitle("Relative party position on GAL-TAN scale; 0 = country average", size(*0.8))  ytitle("% of women from a party; 0 = country average", size(*0.8))  ///
addplot((hist de_galtanscale if CEE ==0 ,bcolor(blue%20) freq yaxis(2) yscale(alt axis(2)) below width(0.5) legend(order(2 "Central and Eastern Europe" 1 "Non Central and Eastern Europe"))start(`mini')) ///
		(hist de_galtanscale if CEE ==1 ,bcolor(red%20) freq yaxis(2) yscale( axis(2))  width(0.5)  start(`mini') ytitle("Frequency of parties" , axis(2) size(*0.8))  ), xlabel(#6)  )
		
graph export "Graphs/margins_galtan_i.png", replace
graph export "Graphs/margins_galtan_i.pdf", replace

		
sum de_euposition
local mini = `r(min)'
local interv = (`r(max)' - `r(min)')/8
margins CEE, at(de_euposition = (`r(min)'(`interv')`r(max)'))
marginsplot, legend(order(1 "" 2 ""))  title("Predictive Margins") xtitle("Party European integration stance; 0 = country average", size(*0.8))  ytitle("% of women from a party; 0 = country average", size(*0.8)) ///
 addplot((hist de_euposition if CEE ==0 ,bcolor(blue%20) freq yaxis(2) yscale(alt axis(2)) below width(0.5) legend(order(2 "Central and Eastern Europe" 1 "Non Central and Eastern Europe")) start(`mini' )) ///
(hist de_euposition if CEE ==1 ,bcolor(red%20) freq yaxis(2) yscale( axis(2))  width(0.5)  start( `mini') ytitle("Frequency of parties" , axis(2) size(*0.8))   ), xlabel(#4) )


graph export "Graphs/margins_eupos_i.png", replace
graph export "Graphs/margins_eupos_i.pdf", replace

sum de_leftright
local mini = `r(min)'
local interv = (`r(max)' - `r(min)')/8
margins CEE, at(de_leftright = (`r(min)'(`interv')`r(max)'))
marginsplot, legend(order(1 "" 2 ""))  title("Predictive Margins") xtitle("Relative party position on LEFT-RIGHT scale; 0 = country average", size(*0.8))  ytitle("% of women from a party; 0 = country average", size(*0.8)) ///
 addplot((hist de_leftright if CEE ==0 ,bcolor(blue%20) freq yaxis(2) yscale(alt axis(2)) below width(0.5) legend(order(2 "Central and Eastern Europe" 1 "Non Central and Eastern Europe")) start(`mini' )) ///
(hist de_leftright if CEE ==1 ,bcolor(red%20) freq yaxis(2) yscale( axis(2))  width(0.5)  start( `mini') ytitle("Frequency of parties" , axis(2) size(*0.8))   ), xlabel(#4) )

graph export "Graphs/left_right_i.png", replace
graph export "Graphs/left_right_i.pdf", replace
gr close


//////////////////////MODELS FOR APPENDIX/////////////////////
///APPENDIX A
mixed ofwomen  i.cntry  ///
	  rollover_female_rat rollover_male_rat ///
	  euposition  leftrightscale galtanscale   ///
	 i.CEE#c.euposition   i.CEE#c.leftrightscale   i.CEE#c.galtanscale mepsparty  ///
	  quota_cntry  zipping ballot_open  ///
	   l_gdp trad_secular surv_selfexp  i.year  ///
	 || party: 	, vce(cl party)
estimates store cl_party
outreg2 using Results_outputs/appendix_model_A , word stats(coef se)  alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,^)  replace

mixed ofwomen  i.cntry  ///
	  rollover_female_rat rollover_male_rat ///
	  euposition  leftrightscale galtanscale   ///
	 i.CEE#c.euposition   i.CEE#c.leftrightscale   i.CEE#c.galtanscale mepsparty  ///
	  quota_cntry  zipping ballot_open  ///
	   l_gdp trad_secular surv_selfexp  i.year  ///
	 || party: 	, vce(cl cntry)
estimates store cl_cntry
outreg2 using Results_outputs/appendix_model_A , word stats(coef se)  alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,^)  append

mixed ofwomen  i.cntry  ///
	  rollover_female_rat rollover_male_rat ///
	  euposition  leftrightscale galtanscale   ///
	 i.CEE#c.euposition   i.CEE#c.leftrightscale   i.CEE#c.galtanscale mepsparty  ///
	  quota_cntry  zipping ballot_open  ///
	   l_gdp trad_secular surv_selfexp  i.year  ///
	  || party: euposition  leftrightscale galtanscale	
estimates store cl_slopes
estimates table cl_party cl_cntry cl_slopes,  b(%7.4f) p varw(50) model(20)
outreg2 using Results_outputs/appendix_model_A , word stats(coef se)  alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,^)  append

///APPENDIX B
mixed ofwomen  i.cntry  ///
	 euposition  leftrightscale galtanscale   ///
	 i.CEE#c.euposition   i.CEE#c.leftrightscale   i.CEE#c.galtanscale mepsparty ///
	  quota_cntry  zipping ballot_open  ///
	    || party: 	
outreg2 using Results_outputs/appendix_model_B , word stats(coef se)  alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,^)  replace

mixed ofwomen  i.cntry  ///
	 rollover_female_rat rollover_male_rat ///
	 euposition  leftrightscale galtanscale   ///
	 i.CEE#c.euposition   i.CEE#c.leftrightscale   i.CEE#c.galtanscale mepsparty ///
	  quota_cntry  zipping ballot_open  ///
	    || party: 		
outreg2 using Results_outputs/appendix_model_B , word stats(coef se)  alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,^)  append


///APPENDIX C
tab ballot_open
mixed ofwomen  i.cntry  ///
	rollover_female_rat rollover_male_rat ///
	  euposition  leftrightscale galtanscale   ///
	 i.ballot_open#c.euposition   i.ballot_open#c.leftrightscale   i.ballot_open#c.galtanscale mepsparty i.ballot_open#c.mepsparty  ///
	  quota_cntry  zipping ballot_open  ///
	   l_gdp trad_secular surv_selfexp  i.year ///
	 || party: 	 
outreg2 using Results_outputs/appendix_model_C , word stats(coef se)  alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,^)  replace


///////////For Variance calculation
meglm de_ofwomen i.cntry  ///
	  de_rollover_female_rat de_rollover_male_rat ///
	  de_euposition  de_leftrightscale de_galtanscale   ///
	 i.CEE#c.de_euposition   i.CEE#c.de_leftrightscale   i.CEE#c.de_galtanscale de_mepsparty  ///
	  de_quota_cntry  de_zipping de_ballot_open  ///
	   de_surv_selfexp de_trad_secular de_l_gdp  i.year ///
	 || party: 		 
	
matrix ab=e(b)
local dim (`=colsof(ab)') 
di `dim'
matrix list ab
global V_model = ab[1,  `dim']
local cols = `dim' -1
constraint 1  _b[/var(_cons[party])]=ab[1,`cols' ]
meglm  de_ofwomen  i.cntry  || party:   , constraints(1 )
matrix null=e(b)
matrix list null
local dim (`=colsof(null)') 
global Vnull = null[1,`dim']
global All_but_control = ($Vnull - $V_model)/$Vnull
di $All_but_control
