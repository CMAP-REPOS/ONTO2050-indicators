


# 1. Setup ----------------------------------------------------------------

## 1a. Background -----

# This script is a fully-automated tool for updating the ON TO 2050 indicators that are based solely on data from the American Community Survey. It uses the tidycensus library to download the relevant tables using the Census API and produces plots of each indicator over time.

# NOTE: Sometimes the API requests fail for no apparent reason, so it is strongly recommended that each chart be manually reviewed before exporting CSVs to verify that the data is correct and complete (i.e. all years are present.)

# Author(s): Claire Conzelmann, Sean Connelly



## 1b. Libraries and options -----

# Libraries
library(tidyverse)
library(tidycensus)
library(purrr)
library(blscrapeR)  # For obtaining inflation adjustment factors
library(blsR)
library(xts)
library(here) # For relative file paths

# Options
options(scipen = 1000, stringsAsFactors = FALSE, tigris_use_cache = TRUE)


bls_set_key("91638f97841d4dbaa1042bd47fad3e4f")

## 1c. Global variables -----

### 1c1. ACS and geographic variables -----

## IMPORTANT!!! 1-year ACS is NOT AVAILABLE FOR 2020, so post-2020 updates cannot
## use a continuous range (e.g. 2012:2021) for ACS_YEARS. Use c(2012:2019, 2021:20XX) instead.
ACS_YEARS <- c(2012:2019, 2021:2022)  # Update the end year with each new ACS release. API doesn't support pre-2012.
TARGET_YEARS <- seq(2010, 2050, 5)  # Sequence of year labels for charts showing targets.

#set fips/msas
IL_FIPS <- "17"
CMAP_7CO <- c("031", "043", "089", "093", "097", "111", "197")
CMAP_6CO <- c("031", "043", "089", "097", "111", "197")  # No Kendall
KENDALL <- c("093")
MSA <- "16980"  # GEOID for Chicago-Naperville-Elgin, IL-IN-WI Metropolitan Statistical Area
PEER_MSAS <- c(MSA, "14460", "31080", "31100", "35620", "47900")  # Chicago/Boston/LA/NYC/DC  (LA's ID changed in 2013)
MSA_PUMAS <- list(  # PUMAs whose majority population lives within 2013 OMB definition of Chicago MSA <https://usa.ipums.org/usa-action/variables/MET2013#description_section>
  IL="02601", IL="03005", IL="03007", IL="03008", IL="03009", IL="03102", IL="03105", IL="03106",
  IL="03107", IL="03108", IL="03202", IL="03203", IL="03204", IL="03205", IL="03207", IL="03208",
  IL="03209", IL="03306", IL="03307", IL="03308", IL="03309", IL="03310", IL="03401", IL="03407",
  IL="03408", IL="03409", IL="03410", IL="03411", IL="03412", IL="03413", IL="03414", IL="03415",
  IL="03416", IL="03417", IL="03418", IL="03419", IL="03420", IL="03421", IL="03422", IL="03501",
  IL="03502", IL="03503", IL="03504", IL="03520", IL="03521", IL="03522", IL="03523", IL="03524",
  IL="03525", IL="03526", IL="03527", IL="03528", IL="03529", IL="03530", IL="03531", IL="03532",
  IL="03601", IL="03602", IL="03700", IN="00101", IN="00102", IN="00103", IN="00104", IN="00200",
  WI="10000"
)  # ^^^ UPDATE THIS LIST FOR THE 2022 ACS TO USE THE 2020 PUMAS!!!!!! ^^^



### 1c2. Export location -----

# Output file paths
OUT_DIR <- here("02_script_outputs", "01_data", "development")
OUT_CSV_SUFFIX <- paste0("_", min(ACS_YEARS), "_", max(ACS_YEARS), ".csv")



# 2. BLS CPI data ---------------------------------------------------------

# Download CPI data from API
# bls_set_key("91638f97841d4dbaa1042bd47fad3e4f")
# Chicago MSA series is CUUSS23ASA0, but historically this project has used the national CPI-U series of CUUR0000SA0
cpi_raw_series <- get_n_series(series_ids = c("CUUR0000SA0"),
                               start_year = 2005,
                               end_year = 2024,
                               annualaverage = TRUE)

# Pull out data, restrict to annual average (month 13), format
cpi_clean <- data_as_table(cpi_raw_series[[1]]$data) %>% 
  filter(periodName == "Annual") %>% 
  select(year, "cpi_ann_avg" = value)
  


# 3. ACS download and clean -----------------------------------------------

## 3a. Non-SOV Travel (ACS table B08006) ---------------------------------------

#create empty table to append each year to
nonsov_travel <- tibble()

#loop through each year and generate data
for(ACS_YEAR in ACS_YEARS){
  # Get 1-year data for all counties but Kendall, which is often suppressed
  annual_data_raw_6co <- get_acs(geography="county", table="B08006", survey="acs1", year=ACS_YEAR, output="wide",
                                 state=IL_FIPS, county=CMAP_6CO, cache_table=TRUE)
  
  # Get 5-year data for Kendall instead
  annual_data_raw_kdl <- get_acs(geography="county", table="B08006", survey="acs5", year=ACS_YEAR, output="wide",
                                 state=IL_FIPS, county=KENDALL, cache_table=TRUE)
  
  # Combine the two tables
  annual_data_raw <- bind_rows(annual_data_raw_6co, annual_data_raw_kdl) %>%
    arrange(GEOID)
  
  #rename and select variables needed for non-SOV table
  annual_data_cleaned <- annual_data_raw %>%
    mutate(
      wrkrs_16plus = B08006_001E,   # Universe: Workers 16 years and over
      carpool = B08006_004E,        # Car, truck, or van: Carpooled
      pub_trans = B08006_008E,      # Public transportation (excluding taxicab)
      bike = B08006_014E,           # Bicycle
      walk = B08006_015E,           # Walked
      work_home = B08006_017E,      # Worked at home
      nonsov = carpool + pub_trans + bike + walk + work_home) %>%
    select(-starts_with("B08006"), -GEOID)
  
  # Calculate the region-level sums
  annual_data_cleaned_reg <- annual_data_cleaned %>%
    select(-NAME) %>%
    summarise_all(sum) %>%
    mutate(NAME = "CMAP Region")
  
  #calculate percentages of each variable
  annual_data_cleaned_reg <- annual_data_cleaned_reg %>%
    mutate(
      YEAR = ACS_YEAR,
      PCT_NONSOV_CARPOOL = (carpool / wrkrs_16plus)*100,
      PCT_NONSOV_TRANSIT = (pub_trans / wrkrs_16plus)*100,
      PCT_NONSOV_BIKE = (bike / wrkrs_16plus)*100,
      PCT_NONSOV_WALK = (walk / wrkrs_16plus)*100,
      PCT_NONSOV_HOME = (work_home / wrkrs_16plus) *100,
      PCT_NONSOV_TOTAL = (nonsov / wrkrs_16plus)*100) %>%
    select(NAME, YEAR, starts_with("PCT"))
  print(annual_data_cleaned_reg)  # Inspect derived data for current year
  
  # Append current year's region-level summary to final table of all years
  annual_summary <- annual_data_cleaned_reg %>%
    select(-NAME) %>%
    mutate(ACTUAL_OR_TARGET="Actual")
  nonsov_travel <- bind_rows(nonsov_travel, annual_summary)
}

print(nonsov_travel)  # Inspect final table (regional data by year)

## 3b. Workforce Participation (ACS table B23001) ------------------------------

#create empty table to append all the years to
workforce_participation <- tibble()

#loop through each year and generate data
for(ACS_YEAR in ACS_YEARS){
  annual_data_raw <- get_acs(geography="county", table="B23001", survey="acs1", year=ACS_YEAR, output="wide",
                             state=IL_FIPS, county=CMAP_7CO, cache_table=TRUE)
  
  #create universe of working population and labor force
  annual_data_cleaned <- annual_data_raw %>%
    mutate(
      pop_20_64 = B23001_010E + B23001_017E + B23001_024E + B23001_031E + B23001_038E + B23001_045E + 
        B23001_052E + B23001_059E + B23001_066E + B23001_096E + B23001_103E + B23001_110E + 
        B23001_117E + B23001_124E + B23001_131E + B23001_138E + B23001_145E + B23001_152E,
      in_lbr_frc = B23001_011E + B23001_018E + B23001_025E + B23001_032E + B23001_039E + 
        B23001_046E + B23001_053E + B23001_060E + B23001_067E + B23001_097E + B23001_104E + 
        B23001_111E + B23001_118E + B23001_125E + B23001_132E + B23001_139E + B23001_146E + B23001_153E) %>%
    select(NAME, pop_20_64, in_lbr_frc)
  
  # Inspect county-level data
  print(annual_data_cleaned)
  
  #filter out Kendall county as it may be suppressed and calculate workforce participation rate
  annual_data_cleaned <- annual_data_cleaned %>%
    filter(!is.na(pop_20_64)) %>% 
    summarise(pop_20_64 = sum(pop_20_64), in_lbr_frc = sum(in_lbr_frc))  %>%
    mutate(
      YEAR = ACS_YEAR,
      WORKFORCE_PARTIC_RATE = (in_lbr_frc / pop_20_64)*100,
      ACTUAL_OR_TARGET = "Actual") %>%
    select(YEAR, WORKFORCE_PARTIC_RATE, ACTUAL_OR_TARGET) 
  
  #append current year to data frame with all years
  workforce_participation <- bind_rows(workforce_participation, annual_data_cleaned)
  
  #inspect data for current year
  print(annual_data_cleaned)
}

# Inspect final table with all years
print(workforce_participation) 

## 3c. Workforce Participation by Race & Ethnicity (ACS table S2301) -----------

#create empty table to append years to
workforce_participation_re <- tibble()

#loop through each year and generate data
for(ACS_YEAR in ACS_YEARS){
  
  # Get 1-year MSA-level data for each race/ethnicity category of interest. Note that partial
  # lack of mutual exclusivity: black/asian data could include Hispanic/Latino people, and
  # Hispanic/Latino data could include people of any race.
  
  ### 2015+ VARIABLE ID'S ARE DIFFERENT THAN PRE-2015 DUE TO ADDED AGE BINS!!! ###
  if(ACS_YEAR >= 2015){
    race_vars = c("S2301_C02_001", "S2301_C02_013", "S2301_C02_015", "S2301_C02_019", "S2301_C02_020")
    annual_data_raw <- get_acs(geography = "metropolitan statistical area/micropolitan statistical area",
                               variables=race_vars, survey="acs1", year=ACS_YEAR, output="wide", cache_table=TRUE) %>%
      filter(GEOID == MSA)
    
    #rename variables
    annual_data_cleaned <- annual_data_raw %>%
      mutate(
        YEAR = ACS_YEAR,
        WORKFORCE_PARTIC_RATE_ALL = S2301_C02_001E,
        WORKFORCE_PARTIC_RATE_BLACK = S2301_C02_013E,
        WORKFORCE_PARTIC_RATE_ASIAN = S2301_C02_015E,
        WORKFORCE_PARTIC_RATE_HISPANIC = S2301_C02_019E,
        WORKFORCE_PARTIC_RATE_WHITE = S2301_C02_020E,
        ACTUAL_OR_TARGET = "Actual") %>%
      select(YEAR, WORKFORCE_PARTIC_RATE_ALL, WORKFORCE_PARTIC_RATE_BLACK, WORKFORCE_PARTIC_RATE_ASIAN, 
             WORKFORCE_PARTIC_RATE_HISPANIC, WORKFORCE_PARTIC_RATE_WHITE, ACTUAL_OR_TARGET)

  } 
  
  #generate data for years before 2015
  else {
    race_vars = c("S2301_C02_001", "S2301_C02_011", "S2301_C02_013", "S2301_C02_017", "S2301_C02_018")
    annual_data_raw <- get_acs(geography = "metropolitan statistical area/micropolitan statistical area",
                               variables=race_vars, survey="acs1", year=ACS_YEAR, output="wide", cache_table=TRUE) %>%
      filter(GEOID == MSA)
    
    #rename variables
    annual_data_cleaned <- annual_data_raw %>%
      mutate(
        YEAR = ACS_YEAR,
        WORKFORCE_PARTIC_RATE_ALL = S2301_C02_001E,
        WORKFORCE_PARTIC_RATE_BLACK = S2301_C02_011E,
        WORKFORCE_PARTIC_RATE_ASIAN = S2301_C02_013E,
        WORKFORCE_PARTIC_RATE_HISPANIC = S2301_C02_017E,
        WORKFORCE_PARTIC_RATE_WHITE = S2301_C02_018E,
        ACTUAL_OR_TARGET = "Actual") %>%
      select(YEAR, WORKFORCE_PARTIC_RATE_ALL, WORKFORCE_PARTIC_RATE_BLACK, WORKFORCE_PARTIC_RATE_ASIAN, 
             WORKFORCE_PARTIC_RATE_HISPANIC, WORKFORCE_PARTIC_RATE_WHITE, ACTUAL_OR_TARGET)
  }
  
  #append current year to rest of years
  workforce_participation_re <- bind_rows(workforce_participation_re, annual_data_cleaned)
  
  # Inspect derived data for current year
  print(annual_data_cleaned) 
}

# Inspect final table with all years
print(workforce_participation_re) 

## 3d. Unemployment Rate by Race & Ethnicity (ACS table S2301) -----------------

#create empty table to append years to
unemployment_re <- tibble()

#loop through each year and generate data
for(ACS_YEAR in ACS_YEARS){
  
  # Get 1-year MSA-level data for each race/ethnicity category of interest. Note that partial
  # lack of mutual exclusivity: black/asian data could include Hispanic/Latino people, and
  # Hispanic/Latino data could include people of any race.
  
  
  ### 2015+ VARIABLE ID'S ARE DIFFERENT THAN PRE-2015 DUE TO ADDED AGE BINS!!! ###
  if(ACS_YEAR >= 2015){
    race_vars = c("S2301_C04_001", "S2301_C04_013", "S2301_C04_015", "S2301_C04_019", "S2301_C04_020")
    annual_data_raw <- get_acs(geography = "metropolitan statistical area/micropolitan statistical area",
                               variables=race_vars, survey="acs1", year=ACS_YEAR, output="wide", cache_table=TRUE) %>%
      filter(GEOID == MSA)
    
    #rename variables
    annual_data_cleaned <- annual_data_raw %>%
      mutate(
        YEAR = ACS_YEAR,
        PCT_UNEMPLOYED_ALL = S2301_C04_001E,
        PCT_UNEMPLOYED_BLACK = S2301_C04_013E,
        PCT_UNEMPLOYED_ASIAN = S2301_C04_015E,
        PCT_UNEMPLOYED_HISPANIC = S2301_C04_019E,
        PCT_UNEMPLOYED_WHITE = S2301_C04_020E,
        ACTUAL_OR_TARGET = "Actual") %>%
      select(YEAR, PCT_UNEMPLOYED_ALL, PCT_UNEMPLOYED_BLACK, PCT_UNEMPLOYED_ASIAN, 
             PCT_UNEMPLOYED_HISPANIC, PCT_UNEMPLOYED_WHITE, ACTUAL_OR_TARGET)
  } 
  
  #generate data for years before 2015
  else {
    race_vars = c("S2301_C04_001", "S2301_C04_011", "S2301_C04_013", "S2301_C04_017", "S2301_C04_018")
    annual_data_raw <- get_acs(geography = "metropolitan statistical area/micropolitan statistical area",
                               variables=race_vars, survey="acs1", year=ACS_YEAR, output="wide", cache_table=TRUE) %>%
      filter(GEOID == MSA)
    
    #rename variables
    annual_data_cleaned <- annual_data_raw %>%
      mutate(
        YEAR = ACS_YEAR,
        PCT_UNEMPLOYED_ALL = S2301_C04_001E,
        PCT_UNEMPLOYED_BLACK = S2301_C04_011E,
        PCT_UNEMPLOYED_ASIAN = S2301_C04_013E,
        PCT_UNEMPLOYED_HISPANIC = S2301_C04_017E,
        PCT_UNEMPLOYED_WHITE = S2301_C04_018E,
        ACTUAL_OR_TARGET = "Actual") %>%
      select(YEAR, PCT_UNEMPLOYED_ALL, PCT_UNEMPLOYED_BLACK, PCT_UNEMPLOYED_ASIAN, 
             PCT_UNEMPLOYED_HISPANIC, PCT_UNEMPLOYED_WHITE, ACTUAL_OR_TARGET)
  }
  
  #append current year to data frame with all years
  unemployment_re <- bind_rows(unemployment_re, annual_data_cleaned)
  
  # Inspect derived data for current year
  print(annual_data_cleaned)  
}

# Inspect final table
print(unemployment_re)  

## 3e. Educational Attainment (ACS table B15003) -------------------------------

#create empty table to append each year to
educational_attainment <- tibble()

#loop through each year and generate data
for(ACS_YEAR in ACS_YEARS){
  annual_data_raw <- get_acs(geography="county", table="B15003", survey="acs1", year=ACS_YEAR, output="wide",
                             state=IL_FIPS, county=CMAP_7CO, cache_table=TRUE)
  
  #create universe of people 25+ and with associates degree or higher
  annual_data_cleaned <- annual_data_raw %>%
    mutate(
      pop_25plus = B15003_001E,
      assoc_plus = B15003_021E + B15003_022E + B15003_023E + B15003_024E + B15003_025E) %>%
    select(NAME, pop_25plus, assoc_plus)
  
  # Inspect county-level data
  print(annual_data_cleaned)  
  
  #filter out Kendall county since it has all NAs
  annual_data_cleaned <- annual_data_cleaned %>%
    filter(!is.na(pop_25plus)) %>%
    
    #aggregate counties
    summarise(pop_25plus = sum(pop_25plus), assoc_plus = sum(assoc_plus)) %>%
    #calculate educational attainment
    mutate(
      YEAR = ACS_YEAR,
      PCT_ASSOC_DEG_PLUS = (assoc_plus / pop_25plus)*100,
      ACTUAL_OR_TARGET = "Actual") %>%
    select(YEAR, PCT_ASSOC_DEG_PLUS, ACTUAL_OR_TARGET)
  
  #append current year to dataframe with all years
  educational_attainment <- bind_rows(educational_attainment, annual_data_cleaned)
  
  # Inspect derived data for current year
  print(annual_data_cleaned)  
}

# Inspect final table with all years
print(educational_attainment)  

## 3f. Educational Attainment by Race & Ethnicity (ACS B15002 tables) ----------

#create empty table to append each year to
educational_attainment_re <- tibble()

#loop through each year and generate data
for(ACS_YEAR in ACS_YEARS){
  # Get 1-year MSA-level data for each race/ethnicity category of interest -- these are stored in separate tables
  # and need to be combined. Note that partial lack of mutual exclusivity: black/asian tables could include
  # Hispanic/Latino people, and Hispanic/Latino table could include people of any race.
  
  #generate data for all races combined
  annual_data_raw_all <- get_acs(geography="metropolitan statistical area/micropolitan statistical area",
                                 table="B15002", survey="acs1", year=ACS_YEAR, output="wide", cache_table=TRUE) %>%
    filter(GEOID == MSA) %>%
    
    #calculate universe of people age 25+ and with associates degree or higher
    mutate(
      YEAR = ACS_YEAR,
      pop_25plus = B15002_001E,
      assoc_plus = B15002_014E + B15002_015E + B15002_016E + B15002_017E + B15002_018E +
        B15002_031E + B15002_032E + B15002_033E + B15002_034E + B15002_035E,
      
      #calculate pct with assoc. degree or higher
      PCT_ASSOC_DEG_PLUS_ALL = (assoc_plus/pop_25plus)*100,
      ACTUAL_OR_TARGET = "Actual") %>%
    select(YEAR, PCT_ASSOC_DEG_PLUS_ALL, ACTUAL_OR_TARGET)

  #generate data for race=Asian  
  annual_data_raw_asn <- get_acs(geography="metropolitan statistical area/micropolitan statistical area",
                                 table="B15002D", survey="acs1", year=ACS_YEAR, output="wide", cache_table=TRUE) %>%
    filter(GEOID == MSA) %>%
    
    #calculate universe of people age 25+ and with associates degree or higher
    mutate(
      YEAR = ACS_YEAR,
      pop_25plus = B15002D_001E,
      assoc_plus = B15002D_008E + B15002D_009E + B15002D_010E + B15002D_017E + B15002D_018E + B15002D_019E,
      PCT_ASSOC_DEG_PLUS_ASIAN = (assoc_plus/pop_25plus)*100,
      ACTUAL_OR_TARGET = "Actual") %>%
    select(YEAR, PCT_ASSOC_DEG_PLUS_ASIAN, ACTUAL_OR_TARGET)
  
  #generate data for race=Black
  annual_data_raw_blk <- get_acs(geography="metropolitan statistical area/micropolitan statistical area",
                                 table="B15002B", survey="acs1", year=ACS_YEAR, output="wide", cache_table=TRUE) %>%
    filter(GEOID == MSA) %>%
    
    #calculate universe of people age 25+ and with associates degree or higher
    mutate(
      YEAR = ACS_YEAR,
      pop_25plus = B15002B_001E,
      assoc_plus = B15002B_008E + B15002B_009E + B15002B_010E + B15002B_017E + B15002B_018E + B15002B_019E,
      
      #calculate pct with assoc. degree or higher
      PCT_ASSOC_DEG_PLUS_BLACK = (assoc_plus/pop_25plus)*100,
      ACTUAL_OR_TARGET = "Actual") %>%
    select(YEAR, PCT_ASSOC_DEG_PLUS_BLACK, ACTUAL_OR_TARGET)
  
  #generate data for Hispanic people
  annual_data_raw_hsp <- get_acs(geography="metropolitan statistical area/micropolitan statistical area",
                                 table="B15002I", survey="acs1", year=ACS_YEAR, output="wide", cache_table=TRUE) %>%
    filter(GEOID == MSA) %>%
    
    #calculate universe of people age 25+ and with associates degree or higher
    mutate(
      YEAR = ACS_YEAR,
      pop_25plus = B15002I_001E,
      assoc_plus = B15002I_008E + B15002I_009E + B15002I_010E + B15002I_017E + B15002I_018E + B15002I_019E,
      
      #calculate pct with assoc. degree or higher
      PCT_ASSOC_DEG_PLUS_HISPANIC = (assoc_plus/pop_25plus)*100,
      ACTUAL_OR_TARGET = "Actual") %>%
        select(YEAR, PCT_ASSOC_DEG_PLUS_HISPANIC, ACTUAL_OR_TARGET)
  
  #generate data for race=white
  annual_data_raw_wht <- get_acs(geography="metropolitan statistical area/micropolitan statistical area",
                                 table="B15002H", survey="acs1", year=ACS_YEAR, output="wide", cache_table=TRUE) %>%
    filter(GEOID == MSA) %>%
    
    #calculate universe of people age 25+ and with associates degree or higher
    mutate(
      YEAR = ACS_YEAR,
      pop_25plus = B15002H_001E,
      assoc_plus = B15002H_008E + B15002H_009E + B15002H_010E + B15002H_017E + B15002H_018E + B15002H_019E,
      
      #calculate pct with assoc. degree or higher
      PCT_ASSOC_DEG_PLUS_WHITE = (assoc_plus/pop_25plus)*100,
      ACTUAL_OR_TARGET = "Actual") %>%
    select(YEAR, PCT_ASSOC_DEG_PLUS_WHITE, ACTUAL_OR_TARGET)
  
  #merge all race tables together
  annual_data_cleaned <- list(annual_data_raw_all, annual_data_raw_blk, 
                              annual_data_raw_asn, annual_data_raw_wht, annual_data_raw_hsp) %>% 
    reduce(full_join, by = c("YEAR", "ACTUAL_OR_TARGET"))
  
  # Inspect MSA-level data
  print(annual_data_cleaned)  
  
  #append current year to all years
  educational_attainment_re <- bind_rows(educational_attainment_re, annual_data_cleaned)
  }

#rearrange table so variables match github table
educational_attainment_re <- educational_attainment_re[, c(1,2,5,4,7,6,3)]

# Inspect final table
print(educational_attainment_re)



## 3g. Median Household Income by Race & Ethnicity (ACS B19013 tables) ----------

# Median HH income CPI
# Set base year index
med_hh_base_year_index <- cpi_clean %>% filter(year == 2016) %>% pull(cpi_ann_avg)

# Calculate adjustment rate
cpi_clean <- cpi_clean %>% 
  mutate("med_hh_inflation_adj_factor" =  med_hh_base_year_index / cpi_ann_avg)

# Loop through ACS years
med_hh_inc_re <- map_df(
  .x = ACS_YEARS,
  .f = ~{
    # Get 1-year MSA-level data for each ,race/ethnicity category of interest -- these are stored in separate tables and need to be combined. Note the partial lack of mutual exclusivity: black/Asian tables could include Hispanic/Latino people, and Hispanic/Latino table includes people of any race (including white).
    
    # All populations
    annual_data_raw_all <- get_acs(geography = "metropolitan statistical area/micropolitan statistical area",
                                   table = "B19013",
                                   survey = "acs1",
                                   year = .x, 
                                   output = "wide",
                                   cache_table = TRUE) %>%
      filter(GEOID == MSA) %>%
      mutate("race_eth" = "All",
             "nominal_med_hh_inc" = B19013_001E) %>%
      select(NAME, race_eth, nominal_med_hh_inc)
    
    # Black/African-American
    annual_data_raw_blk <- get_acs(geography = "metropolitan statistical area/micropolitan statistical area",
                                   table = "B19013B",
                                   survey = "acs1", 
                                   year = .x,
                                   output = "wide",
                                   cache_table = TRUE) %>%
      filter(GEOID == MSA) %>%
      mutate("race_eth" = "Black",
             "nominal_med_hh_inc" = B19013B_001E) %>%
      select(NAME, race_eth, nominal_med_hh_inc)
    
    # Asian
    annual_data_raw_asn <- get_acs(geography = "metropolitan statistical area/micropolitan statistical area",
                                   table = "B19013D",
                                   survey = "acs1",
                                   year = .x,
                                   output = "wide",
                                   cache_table = TRUE) %>%
      filter(GEOID == MSA) %>%
      mutate("race_eth" = "Asian",
             "nominal_med_hh_inc" = B19013D_001E) %>%
      select(NAME, race_eth, nominal_med_hh_inc)
    
    # White
    annual_data_raw_wht <- get_acs(geography = "metropolitan statistical area/micropolitan statistical area",
                                   table = "B19013H",
                                   survey = "acs1",
                                   year = .x,
                                   output = "wide",
                                   cache_table = TRUE) %>%
      filter(GEOID == MSA) %>%
      mutate("race_eth" = "White (non-Hispanic)",
             "nominal_med_hh_inc" = B19013H_001E) %>%
      select(NAME, race_eth, nominal_med_hh_inc)
    
    # Hispanic
    annual_data_raw_hsp <- get_acs(geography = "metropolitan statistical area/micropolitan statistical area",
                                   table = "B19013I",
                                   survey = "acs1",
                                   year = .x,
                                   output = "wide",
                                   cache_table = TRUE) %>%
      filter(GEOID == MSA) %>%
      mutate("race_eth" = "Hispanic/Latino",
             "nominal_med_hh_inc" = B19013I_001E) %>%
      select(NAME, race_eth, nominal_med_hh_inc)
    
    # Combined data
    annual_data_cleaned <- bind_rows(annual_data_raw_all,
                                     annual_data_raw_blk,
                                     annual_data_raw_asn,
                                     annual_data_raw_wht,
                                     annual_data_raw_hsp) %>%
      # Join CPI data, adjust dollar values
      mutate("year" = .x) %>% 
      left_join(cpi_clean %>% 
                  select(year, 
                         "inflation_factor" = med_hh_inflation_adj_factor),
                by = "year") %>% 
      mutate("real_med_hh_inc" = round(nominal_med_hh_inc * inflation_factor, 0)) %>%
      select(year, race_eth, nominal_med_hh_inc, inflation_factor, real_med_hh_inc)
    
    # Output dataframe
    return(annual_data_cleaned)
    
  }
)

# Reshape, rename columns for export
med_hh_inc_re_export <- med_hh_inc_re %>%
  select(year, race_eth, real_med_hh_inc) %>%
  pivot_wider(names_from = race_eth,
              values_from = real_med_hh_inc) %>% 
  # Rename columns
  select("YEAR" = year,
         "MED_HH_INC_ALL" = All,
         "MED_HH_INC_ASIAN" = Asian,
         "MED_HH_INC_BLACK" = Black,
         "MED_HH_INC_HISPANIC" = `Hispanic/Latino`,
         "MED_HH_INC_WHITE" = `White (non-Hispanic)`) %>% 
  mutate("ACTUAL_OR_TARGET" = "Actual")



## 3h. Change in Real Mean HH Income of Quintiles (ACS table B19081) -----------

### 2006 mean incomes by quintile can be found at:
### <https://factfinder.census.gov/bkmk/table/1.0/en/ACS/06_EST/B19081/3100000US16980>

# Set base year index
hh_quintiles_base_year_index <- cpi_clean %>% filter(year == 2006) %>% pull(cpi_ann_avg)

# Calculate adjustment rate
cpi_clean <- cpi_clean %>% 
  mutate("hh_quintiles_inflation_adj_factor" =  hh_quintiles_base_year_index / cpi_ann_avg)

# Loop through years
hh_inc_quintiles <- map_df(
  .x = ACS_YEARS,
  .f = ~{
  
  # Get 1-year MSA-level data for each MSA.
  annual_data_raw <- get_acs(geography = "metropolitan statistical area/micropolitan statistical area",
                             table = "B19081",
                             survey="acs1", 
                             year = .x,
                             output = "wide",
                             cache_table = TRUE) %>%
    filter(GEOID == MSA)
  
  # Clean, adjust to real dollars
  annual_data_cleaned <- annual_data_raw %>%
    # Join CPI data, adjust dollar values
    mutate("year" = .x) %>% 
    left_join(cpi_clean %>% 
                select(year, 
                       "inflation_factor" = hh_quintiles_inflation_adj_factor),
              by = "year") %>% 
    # Convert mean HH income into real 2006 dollars
    mutate(YEAR = .x,
      "mean_hh_inc_q1_2006d" = B19081_001E * inflation_factor,
      "mean_hh_inc_q2_2006d" = B19081_002E * inflation_factor,
      "mean_hh_inc_q3_2006d" = B19081_003E * inflation_factor,
      "mean_hh_inc_q4_2006d" = B19081_004E * inflation_factor,
      "mean_hh_inc_q5_2006d" = B19081_005E * inflation_factor,
      "MEAN_INC_REL2006_QUINT1" = (mean_hh_inc_q1_2006d / 12594),  # Q1 2006 mean was $12,594
      "MEAN_INC_REL2006_QUINT2" = (mean_hh_inc_q2_2006d / 34594),  # Q2 2006 mean was $34,594
      "MEAN_INC_REL2006_QUINT3" = (mean_hh_inc_q3_2006d / 57316),  # Q3 2006 mean was $57,316
      "MEAN_INC_REL2006_QUINT4" = (mean_hh_inc_q4_2006d / 86906),  # Q4 2006 mean was $86,906
      "MEAN_INC_REL2006_QUINT5" = (mean_hh_inc_q5_2006d / 190120),  # Q5 2006 mean was $190,120
      ACTUAL_OR_TARGET = "Actual") %>%
    # Keep only variables in the github file
    select(-NAME, -GEOID, -inflation_factor, - year,
           -starts_with("B19081"), -ends_with("2006d"))
  
  }
)



## 3i. Gini Coefficient of Chicago and Peer MSAs (ACS table B19083) ------------

#create empty table to append each year to
gini <- tibble()

#loop through each year and generate data
for(ACS_YEAR in ACS_YEARS){
  
  # Get 1-year MSA-level data for each MSA.
  annual_data_raw <- get_acs(geography = "metropolitan statistical area/micropolitan statistical area",
                             table = "B19083",
                             survey = "acs1",
                             year = ACS_YEAR,
                             output = "wide",
                             cache_table = TRUE) %>%
    filter(GEOID %in% PEER_MSAS)
  
  #rename variables
  annual_data_cleaned <- annual_data_raw %>%
    mutate(
      GINI_COEFF = B19083_001E,
      YEAR = ACS_YEAR,
      region = case_when(
        GEOID == MSA ~ "CHI",
        GEOID == "14460" ~ "BOS",
        GEOID %in% c("31080", "31100") ~ "LA",  # LA's ID changed in 2013
        GEOID == "35620" ~ "NY",
        GEOID == "47900" ~ "WAS")) %>%
    select(YEAR, region, GINI_COEFF)
  
  #append current year to all years
  gini <- bind_rows(gini, annual_data_cleaned)
  
  # Inspect derived data for current year
  print(annual_data_cleaned) 
}

#reshape data so it is in the same format as github data
gini <- pivot_wider(gini,id_cols = YEAR, names_from = region,
                            values_from = GINI_COEFF, names_prefix = "GINI_COEFF_") 
gini <- mutate(gini, ACTUAL_OR_TARGET = "Actual")

#rearrange columns
gini <- gini[, c(1,3,2,4,5,6,7)]

# Inspect final table
print(gini)  

## 3j. Commute Time by Race & Ethnicity (ACS PUMS) -----------------------------

#create empty table to append years to
commute_time_re <- tibble()

#loop through each year and generate data
for(ACS_YEAR in ACS_YEARS){
  
  # set PUMS variables for years after 2019
  if (ACS_YEAR >= 2019) {
    pums_vars = c("RAC1P", "HISP", "JWTRNS", "JWMNP")
  } 
  
  # set PUMS variables for years before 2019
  else {
    pums_vars = c("RAC1P", "HISP", "JWTR", "JWMNP")
  }
  
  #Get 1-year PUMS data within MSA
  annual_data_raw <- get_pums(variables=pums_vars, state="multiple", puma=MSA_PUMAS,
                              year=ACS_YEAR, survey="acs1", show_call=TRUE)
  
  #rename JWTR code so it is the same across all years
  if (ACS_YEAR < 2019) { 
    annual_data_raw <- rename(annual_data_raw, JWTRNS = JWTR) 
    }
  
  #clean raw data
  annual_data_cleaned <- annual_data_raw %>%
    # Exclude non-workers (but include work-from-home)
    filter(!(JWTRNS %in% c("bb", "0", "00"))) %>%  
    #recode/create variables
    mutate(
      RAC1P = as.numeric(RAC1P),
      HISP = as.numeric(HISP),
      TRANTIME = ifelse(JWMNP == "bbb", 0, as.numeric(JWMNP)),
      TRANTIME_WT = TRANTIME * PWGTP,  # Travel minutes to work * person weight
      RACE_ETH = case_when(
        RAC1P==1 & HISP==1 ~ "WHITE",  # White (non-Hispanic)
        RAC1P==2 & HISP==1 ~ "BLACK",  # Black (non-Hispanic)
        RAC1P == 6 & HISP==1 ~ "ASIAN",  # Asian (non-Hispanic)
        (RAC1P %in% c(3:5,7:9)) & HISP==1 ~ "OTHER",  # Other or multiple races (non-Hispanic)
        HISP!=1 ~ "HISPANIC")) %>%  # Hispanic/Latino (any race)
    
    #calculate total person weight and transit time by race/ethnicity
    group_by(RACE_ETH) %>%
    summarize(
      OBS=n(),
      SUM_PWGTP = sum(PWGTP),
      SUM_TRANTIME_WT = sum(TRANTIME_WT)) %>%
    
    #calculate avg commute time by race/ethnicity
    mutate(
      YEAR = ACS_YEAR,
      MEAN_COMMUTE_MINS = SUM_TRANTIME_WT / SUM_PWGTP,
      ACTUAL_OR_TARGET = "Actual") %>%
    
    #select relevant variables to match github table
    select(YEAR, RACE_ETH, MEAN_COMMUTE_MINS, ACTUAL_OR_TARGET) %>%
    filter(RACE_ETH != "OTHER") %>%
    
    #reshape to match github table
    pivot_wider(names_from=RACE_ETH, values_from=MEAN_COMMUTE_MINS, names_prefix="COMMUTE_MINS_")
  
  #append current year to all years
  commute_time_re <- bind_rows(commute_time_re, annual_data_cleaned)
  
  # Inspect derived data for current year
  print(annual_data_cleaned)  
}

#rearrange columns to match github table
commute_time_re <- commute_time_re[, c(1,3,4,5,6,2)]

# Inspect final table
print(commute_time_re)  


# 4. Export data ----------------------------------------------------------


# Write to script output before overwriting dashboard inputs

# Non-SOV trips to work
write_csv(nonsov_travel, paste0(OUT_DIR, "/", "nonsov_travel", OUT_CSV_SUFFIX))

# Commute times by race/ethnicity
write_csv(commute_time_re, paste0(OUT_DIR, "/", "commute_time_by_race_eth", OUT_CSV_SUFFIX))

# Workforce participation
write_csv(workforce_participation, paste0(OUT_DIR, "/", "workforce_participation", OUT_CSV_SUFFIX))
write_csv(workforce_participation_re, paste0(OUT_DIR, "/", "workforce_participation_by_race_eth", OUT_CSV_SUFFIX))

# Unemployment
write_csv(unemployment_re, paste0(OUT_DIR, "/", "unemployment_by_race_eth", OUT_CSV_SUFFIX))

# Educational attainment
write_csv(educational_attainment, paste0(OUT_DIR, "/", "educational_attainment", OUT_CSV_SUFFIX))
write_csv(educational_attainment_re, paste0(OUT_DIR, "/", "educational_attainment_by_race_eth", OUT_CSV_SUFFIX))

# Median household income, change since 2006
write_csv(med_hh_inc_re_export, paste0(OUT_DIR, "/", "median_hh_income_by_race_eth", OUT_CSV_SUFFIX))
write_csv(hh_inc_quintiles, paste0(OUT_DIR, "/", "mean_hh_income_by_quintile", OUT_CSV_SUFFIX))

# Gini coefficient
write_csv(gini, paste0(OUT_DIR, "/", "gini_coefficient", OUT_CSV_SUFFIX))
