//////////This dofile prepares the data for manual check of incumbents in 2004 ////////////
import excel using "Data/MEPs_European Parliament Elections and Womens Representation_Polak.xlsx", clear firstrow 
replace surname = lower(surname)
replace name = lower(name)
// Retain only the data for the 2004 election
keep if election_year==2004
keep election_year-gender
duplicates list name surname
// Merge with the 1999 election data to find incumbents
merge 1:1 country name surname using Data/datnames_1999
replace election_year = 1999 if mi(election_year)
replace national_party = party_1999 if mi(national_party)
// At least 248 incumbents have been identified; we will manually verify if they are indeed incumbents
// Manual checks will address potential issues of alternative name spelling conventions
replace country=lower(country)
replace national_party=lower(national_party)
replace party_1999=lower(party_1999)
// If election year is missing, it means the MEP wasn't matched (non-incumbent)
replace election_year = 1999 if mi(election_year)
drop ep_group


// Create a unified party variable (Any_party) based on national party or party from 1999
gen Any_party = national_party
replace Any_party=party_1999 if mi(Any_party)
rename national_party party_2004
order country Any_party party_1999 party_2004 name surname
sort country Any_party name surname 
// Mark incumbents where a match exists between 1999 and 2004
gen incumbent = 1 if _merge == 3
order country Any_party party_1999 party_2004 name surname election_year incumbent _merge gender
// Drop countries with no possibility of incumbency (those that joined the EU after 1999)
drop if country == "cyprus"
drop if country == "poland"
drop if country == "estonia"
drop if country == "hungary"
drop if country == "latvia"
drop if country == "lithuania"
drop if country == "slovenia"
drop if country == "slovakia"
drop if country == "romania"
drop if country == "czechia"
drop if country == "bulgaria"
// Identify the database source for each record
gen Database= "Polak Database" if _merge==1
replace Database = "Comepelda" if _merge==2
replace Database = "Both" if _merge==3
drop _merge
export excel using "Data/Incumbents_automated", firstrow(variables) replace
