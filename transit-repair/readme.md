# [Transit Asset State of Good Repair](https://www.cmap.illinois.gov/2050/indicators/transit-repair)

Maintaining the existing transportation network and improving state of good repair are substantive priorities of ON TO 2050. In particular, recent investment in the transit system has been insufficient to keep system condition from declining. This indicator has three separate components.

---

## a) [Percentage of fixed-route buses that have met or exceeded their useful life](https://www.cmap.illinois.gov/2050/indicators/transit-repair#Buses)

This measures the percent of active revenue public transit buses that have exceeded their useful life. This represents the number of vehicles that have reached an age where maintenance cost and vehicle performance issues are likely to increase.

### transit-repair-a.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`CTA_BUSES_PAST_ULB` | Number of CTA buses that have met or exceeded their useful life (15 years)
`CTA_BUSES_TOTAL` | Total number of CTA buses
`PACE_BUSES_PAST_ULB` | Number of Pace buses that have met or exceeded their useful life (12 years)
`PACE_BUSES_TOTAL` | Total number of Pace buses
`PCT_BUSES_PAST_ULB` | Percentage of all buses (CTA and Pace) that have met or exceeded their useful life (`(CTA_BUSES_PAST_ULB + PACE_BUSES_PAST_ULB) / (CTA_BUSES_TOTAL + PACE_BUSES_TOTAL) * 100`)
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** CMAP analysis of Federal Transit Administration (FTA) National Transit Database (NTD)

**Geography:** Seven-county CMAP region

---

## b) [Percentage of rail vehicles that have met or exceeded their useful life](https://www.cmap.illinois.gov/2050/indicators/transit-repair#Railvehicles)

This measures the percent of active revenue public transit rail vehicles that have exceeded their useful life. This represents the number of vehicles that have reached an age where maintenance cost and vehicle performance issues are likely to increase.

### transit-repair-b.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`CTA_RAILVEH_PAST_ULB` | Number of CTA rail vehicles that have met or exceeded their useful life (34 years)
`CTA_RAILVEH_TOTAL` | Total number of CTA rail vehicles
`METRA_RAILVEH_PAST_ULB` | Number of Metra rail vehicles that have met or exceeded their useful life (30 years)
`METRA_RAILVEH_TOTAL` | Total number of Metra rail vehicles
`PCT_RAILVEH_PAST_ULB` | Percentage of all rail vehicles (CTA and Metra) that have met or exceeded their useful life (`(CTA_RAILVEH_PAST_ULB + METRA_RAILVEH_PAST_ULB) / (CTA_RAILVEH_TOTAL + METRA_RAILVEH_TOTAL) * 100`)
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** CMAP analysis of Federal Transit Administration (FTA) National Transit Database (NTD)

**Geography:** Seven-county CMAP region

---

## c) [Percentage of directional rail route miles with track performance restrictions](https://www.cmap.illinois.gov/2050/indicators/transit-repair#Directionalrailroute)

This measures the percent of transit rail track with performance restrictions. The CTA refers to these as “slow zones”, where trains are required to operate at slower than normal speeds. This could be the result of construction, power systems, signals, or other issues. Elimination of slow zones can help to make transit more competitive by decreasing travel times and improving reliability.

### transit-repair-c.csv

Header | Definition
-------|-----------
`YEAR` | Year of observation
`PCT_SLOW_ZONES` | Percentage of directional rail route miles with track performance restrictions
`ACTUAL_OR_TARGET` | `Actual` if the record is from observed data; `Target` if it is an ON TO 2050 target

**Source:** Chicago Transit Authority and Metra

**Geography:** Seven-county CMAP region
