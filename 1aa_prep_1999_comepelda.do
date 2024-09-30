////// PREPARE NAMES AND SURNAMES OF MEPs FROM THE 1999 ELECTIONS //////
import delimited "comepelda/COMEPELDA_aggregate_v1.00.csv", varnam(1) encoding("UTF-8") clear
keep if elyear==1999
keep idpty pname
// Extract unique party IDs and party names for the 1999 parliament
collapse (first) pname, by(idpty)
rename idpty idptylag
save comepelda/pty_id, replace


import delimited comepelda/COMEPELDA_meps_v1.00.csv, varnam(1) encoding("UTF-8") clear
replace lastname = lower(lastname)
replace firstname = lower(firstname)
rename lastname surname
rename firstname name

// Retain only those elected in 1999
keep if  elyearlag==1999 
// Merge with party data from 1999 elections
merge m:1 idptylag using comepelda/pty_id
// Drop entries where no MEPs could be associated with a particular party
keep if _merge !=2
rename pname party_1999
rename cname country
// Standardize country name to match the Polak database conventions
replace country = "United Kingdom" if country== "Great Britain"
keep surname name party_1999 country
// Name surname identify each obs uniqely
duplicates list name surname
save Data/datnames_1999, replace