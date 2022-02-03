# [Share of Post-2015 Development Occurring in Infill Supportive Areas](https://www.cmap.illinois.gov/2050/indicators/infill-development)

This indicator uses the Northeastern Illinois Development Database (NDD) to measure the cumulative share of development that occurs in the region’s [highly and partially infill supportive areas](https://datahub.cmap.illinois.gov/dataset/on-to-2050-snapshot-data-infill-and-tod). This measure addresses a critical element of ON TO 2050: encouraging development in existing communities where infrastructure to support it is already in place while also avoiding the expansion of new infrastructure with long-term maintenance costs. Developments that are completed or under construction will be tracked. For this indicator, the term “development” is used in a general sense to include both new development and redevelopment of existing uses. Residential and non-residential development will be tracked separately.

### infill-development.csv

Header | Definition
-------|-----------
`YEAR_RANGE` | Range of observation years
`END_YEAR` | Last year of observation range
`PCT_RES_UNITS_INFILL` | Percentage of new residential units developed since 2015 located within highly and partially infill supportive areas
`PCT_NONRES_SQFT_INFILL` | Percentage of new non-residential square footage developed since 2015 located within highly and partially infill supportive areas
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** CMAP’s Northeastern Illinois Development Database (NDD)

**Geography:** Seven-county CMAP region

---

# [Share of Post-2015 Infill Development Occurring in Disinvested and Economically Disconnected Areas](https://www.cmap.illinois.gov/2050/indicators/infill-development#InclusiveGrowth)

Infill development and land use patterns are crucial to promoting economic growth in many [economically disconnected and disinvested areas (EDAs)](https://www.cmap.illinois.gov/2050/maps/eda) and in connecting the region’s EDA residents to economic opportunity. As a kindred indicator, ON TO 2050 will track the share of new infill development occurring in EDAs. Roughly forty percent of the region’s population lives in EDAs. However, EDAs received a disproportionately low share of new infill development between 2000 and 2015. CMAP recommends increased infill development in EDAs to increase efficient use of limited resources and help these communities grow.

### infill-development-in-edas.csv

Header | Definition
-------|-----------
`YEAR_RANGE` | Range of observation years
`END_YEAR` | Last year of observation range
`PCT_RES_UNITS_INFILL_EDA` | Share of new infill residential units within EDAs
`PCT_RES_UNITS_INFILL_NOT_EDA` | Share of new infill residential units *not* within EDAs
`PCT_NONRES_SQFT_INFILL_EDA` | Share of new infill non-residential square footage within EDAs
`PCT_NONRES_SQFT_INFILL_NOT_EDA` | Share of new infill non-residential square footage *not* within EDAs
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** CMAP’s Northeastern Illinois Development Database (NDD)

**Geography:** Seven-county CMAP region (divided into EDAs vs. the rest of the region)
