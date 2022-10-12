# [Access to Parks](https://www.cmap.illinois.gov/2050/indicators/access-to-parks)

This indicator measures [per capita access to parks](https://www.cmap.illinois.gov/2050/maps/parks) based on geographic proximity to recreational open space. Values are reported as the percentage of the regional population with access to at least four acres of parkland per 1,000 residents and at least ten acres per 1,000 residents. Generally, the four-acre standard is appropriate for denser communities, while the ten-acre standard is intended for less-dense areas.

### access-to-parks.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`PARK_ACCESS_4PLUS` | Percentage of population with access to at least 4 acres of parkland per 1,000 residents
`PARK_ACCESS_10PLUS` | Percentage of population with access to at least 10 acres of parkland per 1,000 residents
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** CMAP analysis of data from the CMAP Land Use Inventory and the U.S. Census Bureau’s 2010 Census

**Geography:** Seven-county CMAP region

---

# [Access to Parks in Disinvested or Economically Disconnected Areas](https://www.cmap.illinois.gov/2050/indicators/access-to-parks#InclusiveGrowth)

As a kindred indicator, ON TO 2050 will track access to parks for residents in [economically disconnected areas and disinvested areas (EDAs)](https://www.cmap.illinois.gov/2050/maps/eda). Disparities exist in access to parks between residents in EDAs and those in the remaining parts of the region. Residents in EDAs have lower access to parks regardless of development density.

### access-to-parks-in-edas.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`PARK_ACCESS_4PLUS_EDA` | Percentage of population in EDAs with access to at least 4 acres of parkland per 1,000 residents
`PARK_ACCESS_4PLUS_NOT_EDA` | Percentage of population *not* in EDAs with access to at least 4 acres of parkland per 1,000 residents
`PARK_ACCESS_10PLUS_EDA` | Percentage of population in EDAs with access to at least 10 acres of parkland per 1,000 residents
`PARK_ACCESS_10PLUS_NOT_EDA` | Percentage of population *not* in EDAs with access to at least 10 acres of parkland per 1,000 residents
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** CMAP analysis of data from the CMAP Land Use Inventory and the U.S. Census Bureau’s 2010 Census

**Geography:** Seven-county CMAP region (divided into EDAs vs. the rest of the region)
