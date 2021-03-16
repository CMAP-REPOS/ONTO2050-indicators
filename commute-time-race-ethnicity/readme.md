# [Average Journey to Work Time by Race and Ethnicity](https://www.cmap.illinois.gov/2050/indicators/commute-time-race-ethnicity)

This indicator measures the average one-way commute time of workers in the Chicago metropolitan statistical area by race and ethnicity, inclusive of all modes of transportation. Longer commute times decrease the productivity of workers and hinder their ability to connect to available and attainable employment opportunities. Local and regional planning should emphasize improving commute times and options for residents facing long commutes by providing high-quality transportation options that are cost efficient and increase residential access to fruitful economic opportunities. This will require shifts in transportation, land use, and economic development planning and policy.

**Note:** The methodology for this indicator has been slightly modified from what was included in ON TO 2050. The original version used the [IPUMS USA](https://usa.ipums.org/usa) version of the ACS 5-year sample data, whereas it now uses the Census Bureau version of the ACS 1-year sample PUMS. The "other race" and "two or more races" categories have been dropped, as they were based on a small number of observations and therefore fluctuated quite dramatically from year to year.

### commute-time-race-ethnicity.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`COMMUTE_MINS_ASIAN` | Average journey to work time in minutes for Asian workers
`COMMUTE_MINS_BLACK` | Average journey to work time in minutes for Black workers
`COMMUTE_MINS_HISPANIC` | Average journey to work time in minutes for Hispanic/Latino workers
`COMMUTE_MINS_WHITE` | Average journey to work time in minutes for White (non-Hispanic) workers
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

 **Source:** CMAP analysis of the U.S. Census Bureau's American Community Survey (ACS) Public Use Microdata Sample (PUMS)

 **Geography:** The collection of [Public Use Microdata Areas (PUMAs)](https://www.census.gov/programs-surveys/geography/guidance/geo-areas/pumas.html) for which the majority of the 2010 population lived within the Chicago-Naperville-Elgin, IL-IN-WI Metropolitan Statistical Area
