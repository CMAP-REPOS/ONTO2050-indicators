# [Water Demand](https://www.cmap.illinois.gov/2050/indicators/water-demand)

This indicator tracks total daily water demand, as well as per capita demand for residential water use. Total water demand includes water that is withdrawn, treated, and delivered to residential, industrial, commercial, governmental, and institutional users via public supply water systems, as well as industrial and commercial wells. Assessing long-range forecasted demands can inform the region on the sufficiency of water supply and encourage actions that conserve water, protect supply, and/or pursue alternative drinking water sources.

### water-demand.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`TOTAL_DEMAND_MGD` | Total daily water demand, in millions of gallons
`RES_DEMAND_GPCD` | Daily residential water demand per capita, in gallons
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** Illinois State Water Survey; Chicago Metropolitan Agency for Planning ON TO 2050 Regional Water Demand Forecast

**Geography:** Seven-county CMAP region

---

# [Lake Michigan Withdrawals](https://www.cmap.illinois.gov/2050/indicators/water-demand#lake-michigan)

In addition to overall water demand, water use from Lake Michigan is an area of interest for the CMAP region.  In response to a U.S. Supreme Court consent decree, the State of Illinois regulates Lake Michigan water use for those communities with an allocation for lake water.  This kindred indicator measures water use and levels of non-revenue water loss from community water suppliers in order to track conservation and water loss reduction efforts.

### lake-michigan.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`NET_PUMPAGE_MGD` | Average daily Lake Michigan pumpage, in millions of gallons
`LOSS_MGD` | Average daily water loss from Lake Michigan pumpage, in millions of gallons
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** Illinois Department of Natural Resources (IDNR) Office of Water

**Geography:** Seven-county CMAP region

---

# [Deep Bedrock Aquifer Withdrawals](https://www.cmap.illinois.gov/2050/indicators/water-demand#deep-bedrock)

In addition to reporting on overall water demand and the diversion of water from Lake Michigan, it will also be instructive to measure total annual groundwater withdrawals from deep bedrock aquifers (Ancell Unit of bedrock and deeper) in the CMAP region (measured in millions of gallons per day).  This will help provide a more complete assessment of water conservation in the region.

### deep-bedrock.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`DEEP_BEDROCK_MGD` | Average daily deep bedrock aquifer withdrawals, in millions of gallons
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** Illinois State Water Survey

**Geography:** Seven-county CMAP region
