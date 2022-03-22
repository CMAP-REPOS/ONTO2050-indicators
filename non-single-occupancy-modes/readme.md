# [Percent of Trips to Work via Non-SOV Modes](https://www.cmap.illinois.gov/2050/indicators/non-single-occupancy-modes)

Encouraging multimodal travel makes the best use of the system, reduces greenhouse gas emissions, and improves quality of life. This measure tracks the share of trips to work by non-single occupancy vehicle (non-SOV) modes for trips to work. These modes include carpool, public transportation, walking, bicycling and telecommuting. Higher levels of non-SOV travel would yield numerous benefits: reduced congestion, better air quality, and healthier residents, to name a few.

**Note about 2020 data:** Due to data quality concerns arising from the COVID-19 pandemic, the Census Bureau will not publish 1-year ACS summary tables for 2020. To obtain a 2020 estimate, CMAP instead used the [2020 ACS 1-Year Public Use Microdata Sample with Experimental Weights](https://www.census.gov/programs-surveys/acs/data/experimental-data/2020-1-year-pums.html). Since this data is only available for Public Use Microdata Areas (PUMAs), the 2020 estimate represents the seven counties in the CMAP region plus Grundy County (which shares a PUMA with Kendall County).

### non-single-occupancy-modes.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`PCT_NONSOV_CARPOOL` | Percentage of workers carpooling to work
`PCT_NONSOV_TRANSIT` | Percentage of workers taking public transportation (excluding taxis) to work
`PCT_NONSOV_BIKE` | Percentage of workers bicycling to work
`PCT_NONSOV_WALK` | Percentage of workers walking to work
`PCT_NONSOV_HOME` | Percentage of workers working at home
`PCT_NONSOV_TOTAL` | Percentage of workers traveling to work by any non-SOV mode (`PCT_NONSOV_CARPOOL + PCT_NONSOV_TRANSIT + PCT_NONSOV_BIKE + PCT_NONSOV_WALK + PCT_NONSOV_HOME`)
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** CMAP analysis of the U.S. Census Bureau’s American Community Survey (ACS)

**Geography:** Seven-county CMAP region
