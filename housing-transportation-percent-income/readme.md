# [Percentage of Income Spent on Housing and Transportation by Moderate- and Low-Income Residents](https://www.cmap.illinois.gov/2050/indicators/housing-transportation-percent-income)

This measure estimates the share of household income spent on housing and transportation (H+T) costs for moderate- and low-income households. For analysis purposes, any households with incomes below 80 percent of the regional median family income are defined as low- and moderate-income. Data are from the Consumer Expenditure Survey (CES), which the U.S. Bureau of Labor Statistics (BLS) conducts annually. The survey collects information on household income and expenditures, including those for housing and transportation.

### housing-transportation-percent-income.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`PCT_INCOME_H` | Percentage of income spent on housing by low- and moderate-income households
`PCT_INCOME_T` | Percentage of income spent on transportation by low- and moderate-income households
`PCT_INCOME_HT` | Percentage of income spent on housing and transportation by low- and moderate-income households (`PCT_INCOME_H + PCT_INCOME_T`)
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** CMAP analysis of public-use microdata from the Bureau of Labor Statistics Consumer Expenditure Survey

**Geography:** Chicago-Naperville-Elgin, IL-IN-WI Metropolitan Statistical Area

---

# [Percent of Income Spent on Housing and Transportation by Moderate- and Low-Income Households, by Race and Ethnicity](https://www.cmap.illinois.gov/2050/indicators/housing-transportation-percent-income#InclusiveGrowth)

As a kindred indicator, ON TO 2050 will track the share of household income spent on housing and transportation costs for moderate- and low-income households by race and ethnicity. The share of household income spent on housing and transportation costs for moderate- and low-income households differs by race and ethnicities.

**Note:** Stratifying the source data by race and ethnicity yields relatively small sample sizes, so there may be significant year-over-year fluctuation (a.k.a. "noise") in the indicator values. Racial/ethnic groups other than black, white and Hispanic have such small samples that they have been excluded from this dataset.

### housing-transportation-percent-income-race-ethnicity.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`PCT_INCOME_HT_ALL` | Percentage of income spent on housing by all low- and moderate-income households
`PCT_INCOME_HT_HISPANIC` | Percentage of income spent on housing by low- and moderate-income Hispanic households
`PCT_INCOME_HT_WHITE` | Percentage of income spent on housing by low- and moderate-income white (non-Hispanic) households
`PCT_INCOME_HT_BLACK` | Percentage of income spent on housing by low- and moderate-income black households
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** CMAP analysis of public-use microdata from the Bureau of Labor Statistics (BLS) Consumer Expenditure Survey

**Geography:** Chicago-Naperville-Elgin, IL-IN-WI Metropolitan Statistical Area
