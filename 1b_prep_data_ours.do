//// Calculate Incumbents ratios for 2004 ONLY — after manual correction! ////
import excel using "Data/Manual/Inc_manual.xlsx", clear firstrow 
drop K-M
drop if mi(country)
drop if election_year == 1999
drop party_1999 party_2004 
rename Any_party national_party
encode(national_party), gen(party)
gen one = 1
gen female_incumbent = incumbent==1&gender=="F"
gen male_incumbent = incumbent==1&gender=="M"


// Generate total number of incumbents by party and election year
bys party country election_year: egen incumb = total(incumbent) 
// Generate the total number of female incumbents
bys party country election_year: egen female_incumb = total(female_incumbent) 
// Generate the total number of male incumbents
bys party country election_year: egen male_incumb = total(male_incumbent) 
// Generate the total number of MEPs by party and election year
bys party country election_year: egen total_mep = total(one) 

// Calculate the share of incumbents in the total number of MEPs
gen rollover_rat_2004 = incumb/total_mep
// Calculate the share of female incumbents in the total number of MEPs
gen rollover_female_rat_2004 = female_incumb/total_mep
// Calculate the share of male incumbents in the total number of MEPs
gen rollover_male_rat_2004 = male_incumb/total_mep

collapse (mean) rollover_rat_2004 rollover_male_rat_2004 rollover_female_rat_2004 total_mep , by(national_party country election_year)
save Data/rollover_rat_2004, replace

***********************************************************************************************************************************
//// Use Polak 2024 database, incumbents for 2009/2014/2019 ////

import excel using "Data/MEPs_European Parliament Elections and Womens Representation_Polak.xlsx", clear firstrow 
egen mep_prty_id = group(surname name country)
sort national_party
encode(national_party), gen(party)
sort country
encode(country), gen(cntry)

// Set up panel data structure with MEP ID and election year
xtset mep_prty_id election_year
//1 if was MEP in previous cycle
gen previous_election = l5.mep_prty_id!=.

// Encode gender: 1 for female, 2 for male
encode(gender), gen(female) 
// Create variables to track incumbency based on gender
gen previous_election_fem = l5.mep_prty_id!=.& l5.female==1
gen previous_election_mal = l5.mep_prty_id!=.& l5.female==2

gen one = 1
// Calculate total MEPs, incumbents, female incumbents, and male incumbents by country, party, and election year
bys cntry party election_year: egen total_mep 	= total(one) 
bys cntry party election_year: egen incumb 		= total(previous_election) 
gen rollover_rat = incumb/total_mep
bys cntry party election_year: egen female_incumb = total(previous_election_fem) 
gen rollover_female_rat = female_incumb/total_mep
bys cntry party election_year: egen male_incumb = total(previous_election_mal) 
gen rollover_male_rat = male_incumb/total_mep


// Collapse data to country-party level
collapse (mean) rollover_female_rat rollover_rat rollover_male_rat (mean) total_mep , by(country national_party election_year)
replace country=lower(country)
replace national_party=lower(national_party)

preserve
	tempfile match_pt_cn
	keep if election_year == 2004
	merge 1:1 national_party country using Data/rollover_rat_2004
    // Merge with 2004 incumbency data.
	keep country election_year rollover_rat rollover_male_rat_2004 rollover_female_rat_2004 rollover_rat_2004 national_party
	save `match_pt_cn',replace
restore
merge 1:1 election_year country national_party using `match_pt_cn'
replace rollover_rat = rollover_rat_2004 if rollover_rat_2004>0&rollover_rat_2004!=.
replace rollover_female_rat = rollover_female_rat_2004 if rollover_female_rat_2004>0&rollover_female_rat_2004!=.
replace rollover_male_rat = rollover_male_rat_2004 if rollover_male_rat_2004>0&rollover_male_rat_2004!=.

drop rollover_rat_2004 rollover_female_rat_2004 rollover_male_rat_2004 _merge
save Data/parties, replace

//// Merging with other party-level variables ////

import excel using "Data/Parties_and_countries_combined_European Parliament Elections and Womens Representation_Polak.xlsx", clear firstrow 
replace country=lower(country)
replace national_party=lower(national_party)
merge 1:1 country national_party election_year using Data/parties

sort national_party
encode(national_party), gen(party)
sort country
encode(country), gen(cntry)
sort party cntry election_year 
drop if meps_party==1
save Data/parties_cntries, replace
