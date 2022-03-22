# [Workforce Participation](https://www.cmap.illinois.gov/2050/indicators/workforce-participation)

This indicator tracks the percentage of the regional population (age 20-64) that is either working or actively looking for work. An increase in workforce participation is generally viewed as a positive indicator of regional economic opportunity. Increased participation suggests a decrease in the number of discouraged workers -- individuals who are able to work but currently unemployed, and who have not searched for employment in the last four weeks due to a lack of suitable options or a lack of success through previous job applications.

However, workforce participation is a complex measure because it tracks both the number of employed persons and unemployed persons currently looking for work. Thus an increase in unemployment can register as an increase in workforce participation. Similarly, decreases in workforce participation may be due to an increase in the number of discouraged job seekers, or to an increase in the number of people choosing to retire early or leave the workforce for other reasons. Even with these caveats, an increase in workforce participation is generally indicative of a healthy economy.

**Note about 2020 data:** Due to data quality concerns arising from the COVID-19 pandemic, the Census Bureau will not publish 1-year ACS summary tables for 2020. To obtain a 2020 estimate, CMAP instead used the [2020 ACS 1-Year Public Use Microdata Sample with Experimental Weights](https://www.census.gov/programs-surveys/acs/data/experimental-data/2020-1-year-pums.html). Since this data is only available for Public Use Microdata Areas (PUMAs), the 2020 estimate represents the seven counties in the CMAP region plus Grundy County (which shares a PUMA with Kendall County).

### workforce-participation.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`WORKFORCE_PARTIC_RATE` | Workforce participation rate among population aged 20-64
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** CMAP analysis of data from the U.S. Census Bureau’s American Community Survey (ACS)

**Geography:** Seven-county CMAP region

---

# [Workforce Participation by Race and Ethnicity](https://www.cmap.illinois.gov/2050/indicators/workforce-participation#InclusiveGrowth)

As a secondary indicator, ON TO 2050 also tracks the share of the population in the Chicago metropolitan statistical area age 16 years and over that is either working or actively looking for work by race and ethnicity. Demographic groups participate in the workforce at differing rates. Black residents participate in the workforce at significantly lower rates than residents of other races or ethnicities.

**Note about 2020 data:** Due to data quality concerns arising from the COVID-19 pandemic, the Census Bureau will not publish 1-year ACS summary tables for 2020. To obtain a 2020 estimate, CMAP instead used the [2020 ACS 1-Year Public Use Microdata Sample with Experimental Weights](https://www.census.gov/programs-surveys/acs/data/experimental-data/2020-1-year-pums.html). Since this data is only available for Public Use Microdata Areas (PUMAs), the 2020 estimate represents the closest possible approximation of the Chicago-Naperville-Elgin, IL-IN-WI Metropolitan Statistical Area (MSA): the Illinois and Wisconsin portions are accurately represented, but the Indiana counties of Jasper and Newton were omitted because they share a PUMA with the slightly more populous counties of Fulton, Pulaski and Starke, which are not part of the MSA.

### workforce-participation-race-ethnicity.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`WORKFORCE_PARTIC_RATE_ALL` | Workforce participation rate among entire population aged 16+
`WORKFORCE_PARTIC_RATE_BLACK` | Workforce participation rate among Black population aged 16+
`WORKFORCE_PARTIC_RATE_ASIAN` | Workforce participation rate among Asian population aged 16+
`WORKFORCE_PARTIC_RATE_HISPANIC` | Workforce participation rate among Hispanic/Latino population aged 16+
`WORKFORCE_PARTIC_RATE_WHITE` | Workforce participation rate among White (non-Hispanic) population aged 16+
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** CMAP analysis of data from the U.S. Census Bureau’s American Community Survey (ACS)

**Geography:** Chicago-Naperville-Elgin, IL-IN-WI Metropolitan Statistical Area
