capture mkdir Results_outputs
capture mkdir Graphs
capture mkdir Comepelda

////// Prepare names and surnames of meps from the 1999 elections (Comepelda database)  //////
do 1aa_prep_1999_comepelda

////// Merge the Polak database with the Comepelda database to prepare data for the manual review of incumbents in 2004 //////
do 1ab_manual_check

////// Prepare the final database using (1) the file containing 2004 incumbents after manual review, and (2) the Polak database  //////
do 1b_prep_data_ours

////// Estimate models and generate the plots //////
do 2a_model_mixed

