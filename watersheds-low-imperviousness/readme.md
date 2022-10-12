# [Regional Land in Watersheds Below 25 Percent Impervious Coverage](https://www.cmap.illinois.gov/2050/indicators/watersheds-low-imperviousness)

This indicator tracks the change in impervious surface by watershed catchment throughout the region as an indicator of health and integrity of aquatic resources. Specifically, it tracks the total percentage of the region’s land area located in watersheds with 25 percent or less impervious coverage (i.e. the watersheds classified as "sensitive" or "impacted" in the [watershed integrity local strategy map](https://www.cmap.illinois.gov/2050/maps/watershed)).

Many of the region’s water resources are not meeting all goals of the Clean Water Act, and many waterbodies—especially small headwater streams—have not yet been assessed. Given this lack of data, this indicator uses the impervious cover model to understand watershed health and water quality.

Research has shown that small watersheds with less than 10 percent impervious cover tend to be associated with healthy streams. Further increases of impervious cover (up to 25 percent) can lead to impacted streams that could be restored with intervention. Small watersheds with increases in impervious coverage (up to 60 percent) are considered non-supporting, and when impervious coverage exceeds 60 percent, full restoration of urban drainage systems to pre-development habitat quality may not be possible.

### watersheds-low-imperviousness.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`PCT_WS_AREA_LT10_IMP` | Percentage of land in "sensitive" watersheds (below 10% impervious)
`PCT_WS_AREA_10_25_IMP` | Percentage of land in "impacted" watersheds (between 10-25% impervious)
`PCT_WS_AREA_25_60_IMP` | Percentage of land in "non-supporting" watersheds (between 25-60% impervious)
`PCT_WS_AREA_GT60_IMP` | Percentage of land in "urban drainage" watersheds (above 60% impervious)
`PCT_WS_AREA_LT25_IMP` | Percentage of land in "sensitive" and "impacted" watersheds (`PCT_WS_AREA_LT10_IMP + PCT_WS_AREA_10_25_IMP`)
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** CMAP analysis of data from the United States Geological Survey (USGS) National Land Cover Database (NLCD) and the United States Environmental Protection Agency (EPA) National Hydrography Dataset Plus (NHDPlus)

**Geography:** Seven-county CMAP region
