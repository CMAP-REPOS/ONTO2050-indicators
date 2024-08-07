# ON TO 2050 Indicators

With its many partners and stakeholders, the Chicago Metropolitan Agency for Planning ([CMAP](http://www.cmap.illinois.gov/about)) began to develop the [ON TO 2050](https://www.cmap.illinois.gov/2050) comprehensive plan in 2015. The three-year process was highly transparent, featuring extensive research, analysis, and public engagement. The resulting plan was adopted on October 10, 2018, and builds on the agency’s first comprehensive regional plan, [GO TO 2040](http://www.cmap.illinois.gov/about/2040), which was released in 2010 and updated in 2014. Adoption of the plan guides transportation investments and frames regional priorities on development, the environment, the economy, and other issues affecting quality of life.

Where possible, each ON TO 2050 recommendation is tracked by one or more [indicators](https://www.cmap.illinois.gov/2050/indicators) to set targets and monitor progress. Because changes to patterns of development or mobility take time, the plan designates targets for both 2025 and 2050. Most important, these targets are not simple forecasts of current trends; they instead represent optimistic, but achievable, outcomes that assume the implementation of ON TO 2050. To provide consistency over time, many indicators have been carried forward from [GO TO 2040](https://www.cmap.illinois.gov/about/2040), the predecessor to this plan, with some improved data sources or analytical approaches. Read more in the [ON TO 2050 Indicators Appendix Update](https://cmap.illinois.gov/wp-content/uploads/ON-TO-2050-Update-Indicators-Appendix.pdf).

This repository includes subfolders with the ON TO 2050 indicator final data in CSV format. Each CSV is in a folder with a `readme.md` file containing relevant context and metadata. The data provided is generally only the final indicator values, not any underlying source data (which is often very large and/or restricted). Each indicator will be updated as new source data becomes available, in order to track the implementation progress of the plan. Unless otherwise noted, each indicator represents the seven Illinois counties composing the CMAP region: Cook, DuPage, Kane, Kendall, Lake, McHenry and Will.

This repository's `docs` folder includes code for a [dashboard website](https://cmap-repos.github.io/ONTO2050-indicators/) that dynamically generates charts for each indicator directly from their CSV files.

---

### List of data, script, and dashboard folders

Folder | Indicator(s)
---|---
[`01_scripts`](01_scripts) | Code for downloading, cleaning, and visualizing indicator data
[`02_script_outputs`](02_script_outputs) | Script outputs, mainly the exported CSVs from scripts stored in [`01_data/development`](02_script_outputs/01_data/development).<br><br>Once these are reviewed, these data are copied to [`01_data/production`](02_script_outputs/01_data/production) and then used to overwrite the final, production data in the indicator sub-folders.<br><br>Static plots used for presentations and other forums are saved in [`02_plots`](02_script_outputs/02_plots).
[`docs`](docs) | Code for the [indicator dashboard](https://cmap-repos.github.io/ONTO2050-indicators/)

---

### List of indicator folders

**Note:** Indicators in *italics* are secondary indicators, which do not have any future targets associated with them.

Folder | Indicator(s)
---|---
[`access-to-parks`](access-to-parks) | &bull; Access to Parks<br />&bull; *Access to Parks in Disinvested and Economically Disconnected Areas*
[`board-member-training`](board-member-training) | &bull; Local Governments That Train Appointed Board Members
[`bridge-condition`](bridge-condition) | &bull; Percentage of Roadway Bridge Area in “Poor” Condition
[`commute-time-race-ethnicity`](commute-time-race-ethnicity) | &bull; *Average Journey to Work Time by Race and Ethnicity*
[`conserved-land-acres`](conserved-land-acres) | &bull; Acres of Conserved Land<br />&bull; *Protected Share of CMAP Conservation Areas Layer*
[`educational-attainment`](educational-attainment) | &bull; Educational Attainment<br />&bull; *Educational Attainment by Race and Ethnicity*
[`farmland-acres`](farmland-acres) | &bull; Acres of Farmland Used to Harvest Produce for Direct Human Consumption
[`greenhouse-gas-emissions`](greenhouse-gas-emissions) | &bull; Greenhouse Gas Emissions
[`highway-congestion-hours`](highway-congestion-hours) | &bull; Average Congested Hours of Weekday Travel for Limited Access Highways
[`household-income-race-ethnicity`](household-income-race-ethnicity) | &bull; *Real Median Household Income by Race and Ethnicity*
[`housing-transportation-percent-income`](housing-transportation-percent-income) | &bull; Percentage of Income Spent on Housing and Transportation by Moderate- and Low-Income Households<br />&bull; *Percentage of Income Spent on Housing and Transportation by Moderate- and Low-Income Households, by Race and Ethnicity*
[`impervious-area`](impervious-area) | &bull; Acres of Impervious Area
[`income-inequality`](income-inequality) | &bull; *Gini Coefficient*
[`infill-development`](infill-development) | &bull; Share of Post-2015 Development Occurring in Infill Supportive Areas<br />&bull; *Share of Post-2015 Infill Development Occurring in Disinvested and Economically Disconnected Areas*
[`manufacturing-exports`](manufacturing-exports) | &bull; *Manufacturing Exports*
[`mean-household-income`](mean-household-income) | &bull; *Change in Mean Household Income Since 2006 by Quintile*
[`non-residential-market-value`](non-residential-market-value) | &bull; *Change in Non-Residential Market Value in Disinvested and Economically Disconnected Areas Since 2010*
[`non-single-occupancy-modes`](non-single-occupancy-modes) | &bull; Percentage of Trips to Work via Non-SOV Modes
[`patenting-activity`](patenting-activity) | &bull; Patenting Activity
[`pavement-condition`](pavement-condition) | &bull; Percentage of Highway Pavement in “Not Acceptable” Condition
[`population-jobs-transit-availability`](population-jobs-transit-availability) | &bull; Population and Jobs with at Least “Moderately High” Transit Availability
[`rail-crossing-delay`](rail-crossing-delay) | &bull; Motorist Delay at Highway-Rail Grade Crossings
[`regional-trails`](regional-trails) | &bull; Percentage of Regional Greenways and Trails Plan Completed
[`reliable-interstate-travel`](reliable-interstate-travel) | &bull; Percentage of Person-Miles Traveled on the Interstate System with Reliable Travel Time
[`state-revenue-disbursement`](state-revenue-disbursement) | &bull; Municipalities with Per Capita State Revenue Disbursement Below 80 Percent of Regional Median
[`stem-employment`](stem-employment) | &bull; Employment in STEM Occupations
[`terminal-carload-transit`](terminal-carload-transit) | &bull; Chicago Terminal Carload Transit Time
[`traffic-fatalities`](traffic-fatalities) | &bull; Number of Traffic Fatalities
[`traffic-signals`](traffic-signals) | &bull; Number of Intersections with Transit Priority or Queue Jumping
[`transit-preference`](transit-preference) | &bull; Miles of Roadway with Transit Preference
[`transit-repair`](transit-repair) | &bull; Transit Asset State of Good Repair
[`unemployment-race-ethnicity`](unemployment-race-ethnicity) | &bull; *Unemployment by Race and Ethnicity*
[`unlinked-transit-trips`](unlinked-transit-trips) | &bull; Annual Unlinked Transit Trips
[`venture-capital-funding`](venture-capital-funding) | &bull; Venture Capital Funding
[`walkable-areas`](walkable-areas) | &bull; Population and Jobs Located in Highly Walkable Areas
[`water-demand`](water-demand) | &bull; Water Demand<br />&bull; *Lake Michigan Withdrawals*<br />&bull; *Deep Bedrock Aquifer Withdrawals*
[`watersheds-low-imperviousness`](watersheds-low-imperviousness) | &bull; Regional Land in Watersheds Below 25 Percent Impervious Coverage
[`workforce-participation`](workforce-participation) | &bull; Workforce Participation<br />&bull; *Workforce Participation by Race and Ethnicity*

