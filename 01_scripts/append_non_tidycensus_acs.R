# 1. Setup ----------------------------------------------------------------

## 1a. Background -----

# This script fills in data gaps in the data downloaded from tidycensus by appending 2020 PUMAs data and pre tidycensus data

# Author(s): Claire Conzelmann


## 1b. Libraries and options -----

# Libraries
library(tidyverse)
library(here)

# 2. Load data ----------------------------------------------------------

#data directory for tidycensus data
DATA_DIR <- here("02_script_outputs", "01_data", "development")

# Read in tidycensus (tc) 2012-2022 development data
med_hh_inc_re_tc <- read_csv(paste0(DATA_DIR, "/", "median_hh_income_by_race_eth_2012_2022.csv"))
hh_inc_quintiles_tc <- read_csv(paste0(DATA_DIR, "/", "mean_hh_income_by_quintile_2012_2022.csv"))
nonsov_travel_tc <- read_csv(paste0(DATA_DIR, "/", "nonsov_travel_2012_2022.csv"))
workforce_participation_tc <- read_csv(paste0(DATA_DIR, "/", "workforce_participation_2012_2022.csv"))
workforce_participation_re_tc <- read_csv(paste0(DATA_DIR, "/", "workforce_participation_by_race_eth_2012_2022.csv"))
unemployment_re_tc <- read_csv(paste0(DATA_DIR, "/", "unemployment_by_race_eth_2012_2022.csv"))
educational_attainment_tc <- read_csv(paste0(DATA_DIR, "/", "educational_attainment_2012_2022.csv"))
educational_attainment_re_tc <- read_csv(paste0(DATA_DIR, "/", "educational_attainment_by_race_eth_2012_2022.csv"))
gini_tc <- read_csv(paste0(DATA_DIR, "/", "gini_coefficient_2012_2022.csv"))
commute_time_re_tc <- read_csv(paste0(DATA_DIR, "/", "commute_time_by_race_eth_2012_2022.csv"))

#read in data from github containing non-tidycensus data (2020, pre 2012 years)
med_hh_inc_re <- read_csv(here("household-income-race-ethnicity", "household-income-race-ethnicity.csv"))
hh_inc_quintiles <- read_csv(here("mean-household-income", "mean-household-income.csv"))
nonsov_travel <- read_csv(here("non-single-occupancy-modes", "non-single-occupancy-modes.csv"))
workforce_participation <- read_csv(here("workforce-participation", "workforce-participation.csv"))
workforce_participation_re <- read_csv(here("workforce-participation", "workforce-participation-race-ethnicity.csv"))
unemployment_re <- read_csv(here("unemployment-race-ethnicity", "unemployment-race-ethnicity.csv"))
educational_attainment <- read_csv(here("educational-attainment", "educational-attainment.csv"))
educational_attainment_re <- read_csv(here("educational-attainment", "educational-attainment-race-ethnicity.csv"))
gini <- read_csv(here("income-inequality", "income-inequality.csv"))
commute_time_re <- read_csv(here("commute-time-race-ethnicity", "commute-time-race-ethnicity.csv"))

# 3. Append 2020 and pre tidycensus years to tidycensus data -----------------------------------------------

# write function that subsets non-tidycensus data to keep 2020, target years, and pre-tidycensus data 
# and appends subsetted data to tidycensus data 
append_non_tidycensus <- function(nontidy_df, tidy_df) {
  # keep 2020, target years, and pre-tidycensus data 
  nontidy_df <- nontidy_df %>%
    subset(YEAR < 2012 | YEAR == 2020 | ACTUAL_OR_TARGET == "Target")
  
  # check if data frame subset is empty
  if (dim(nontidy_df)[1] == 0) {
    print("dataframe is empty, nothing to append")
    
    # since there is nothing to append, make tidy_df equal to appended_df so the export still works
    appended_df <- tidy_df
    
  } else{
    #if not empty, append to tidycensus data
    appended_df <- rbind(tidy_df, nontidy_df)
    
    #sort by year
    appended_df <- appended_df[order(appended_df$YEAR),]
  }
}

# 3a. Median household income
med_hh_inc_re_appended <- append_non_tidycensus(med_hh_inc_re, med_hh_inc_re_tc)

# 3b. Mean household income by quintile
hh_inc_quintiles_appended <- append_non_tidycensus(hh_inc_quintiles, hh_inc_quintiles_tc)

# 3c. Non-SOV travel modes
nonsov_travel_appended <- append_non_tidycensus(nonsov_travel, nonsov_travel_tc)

# 3d. Workforce participation 
workforce_participation_appended <- append_non_tidycensus(workforce_participation, workforce_participation_tc)

# 3e. Workforce participation by race/ethnicity
workforce_participation_re_appended <- append_non_tidycensus(workforce_participation_re, workforce_participation_re_tc)

# 3f. Unemployment rate by race/ethnicity
unemployment_re_appended <- append_non_tidycensus(unemployment_re, unemployment_re_tc)

# 3g. Educational attainment 
educational_attainment_appended <- append_non_tidycensus(educational_attainment, educational_attainment_tc)

# 3h. Educational attainment by race/ethnicity
educational_attainment_re_appended <- append_non_tidycensus(educational_attainment_re, educational_attainment_re_tc)

# 3i. Gini coefficient
gini_appended <- append_non_tidycensus(gini, gini_tc)

# 3j. Commute time by race/ethnicity
commute_time_re_appended <- append_non_tidycensus(commute_time_re, commute_time_re_tc)

# 4. Export data ----------------------------------------------------------
# write_csv(med_hh_inc_re_appended, here("household-income-race-ethnicity", "household-income-race-ethnicity.csv"))
# write_csv(hh_inc_quintiles_appended, here("mean-household-income", "mean-household-income.csv"))
# write_csv(nonsov_travel_appended, here("non-single-occupancy-modes", "non-single-occupancy-modes.csv"))
# write_csv(workforce_participation_appended, here("workforce-participation", "workforce-participation.csv"))
# write_csv(workforce_participation_re_appended, here("workforce-participation", "workforce-participation-race-ethnicity.csv"))
# write_csv(unemployment_re_appended, here("unemployment-race-ethnicity", "unemployment-race-ethnicity.csv"))
# write_csv(educational_attainment_appended, here("educational-attainment", "educational-attainment.csv"))
# write_csv(educational_attainment_re_appended, here("educational-attainment", "educational-attainment-race-ethnicity.csv"))
# write_csv(gini_appended, here("income-inequality", "income-inequality.csv"))
# write_csv(commute_time_re_appended, here("commute-time-race-ethnicity", "commute-time-race-ethnicity.csv"))
