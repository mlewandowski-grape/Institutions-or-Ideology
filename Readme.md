# README: Data Preparation and Analysis Workflow
This repository contains the replication files for the article titled "Institutions or Ideology? A Cross-Party and Cross-Country Analysis of Factors Influencing the Election of Women to the European Parliament."

## 1. Files `1aa` and `1ab`
These files prepare the necessary data to obtain incumbency information from the Comepelda database and integrate it into our analysis. STATA automatically exports a file called `Incumbents_automated`, which labels certain MEPs as incumbents.

### Key Notes:
- **Manual Review:** Due to inconsistencies in the spelling of names and surnames between our dataset and the Comepelda database, the automated assessment may not always be accurate. A manual review was conducted to correct these discrepancies. The corrected file can be found at:  
  `Data/Manual/incumbents.cor`.
  
- **Database Setup:** Before running these files, you need to manually download the Comepelda database and extract the files into the `Comepelda` folder.

---

## 2. File `1b`
This file generates the final dataset using MEP-level data. It calculates incumbency ratios for the 2009, 2014, and 2019 elections. The generated dataset is then merged with the `Incumbents_cor` file, which contains the corrected incumbency information for the 2004 election.

---

## 3. File `2a`
This file handles all the analyses, including the generation of tables, plots, and appendix tables for the project.

### Key Note:
The output tables exported to Word from the mixed-effects model (using the `mixed` procedure in STATA) may require manual formatting to match the presentation style used in the paper.

---

## 3. File `_main` 
Wraps up the analysis, creates the necessary folders.