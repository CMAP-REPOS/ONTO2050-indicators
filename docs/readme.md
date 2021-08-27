# ON TO 2050 Indicators Dashboard Code

Rather than containing data for a specific indicator, this folder contains the code behind the [dashboard website](https://cmap-repos.github.io/ONTO2050-indicators), which dynamically generates charts for each indicator directly from its CSV file. The purpose of each file is described below.

### chart.js

JavaScript functions for dynamically generating SVG charts from the indicator CSV files stored in other folders of this repository, relying heavily on the [D3 library](https://d3js.org).

### chart_specs.json

JSON file defining the specifications used by the *chart.js* functions to generate the chart for each individual indicator. Contains a single array, where each element is an indicator-specific object with the following structure:

```json
{
    "chartId": (string) Unique indicator ID,
    "chapterId": (string) Indicator's chapter ID,
    "mainTitle": (string) Main title to display above chart (i.e. indicator's full name),
    "xTitle": (string) Text to display along x-axis (typically "Year"),
    "xVar": (string) Name of CSV variable containing x-axis values (typically "YEAR"),
    "yTitle": (string) Text to display along chart y-axis (units of measurement),
    "csvUrl": "https://raw.githubusercontent.com/CMAP-REPOS/ONTO2050-indicators/master/{{{path to indicator CSV file}}}",
    "yVars": [
        {
            "name": (string or null) Variable name to appear in legend,
            "yVar": (string) Name of CSV variable containing y-axis values,
            "actualColor": (string) Hexadecimal color code for observed data line/points,
            "targetColor": (string or null) Hexadecimal color code for target data line/points
        },
        {
            (OPTIONAL) Additional specifications for other variables
        }
    ],
    "yRangeManual": (array or null) Try null first and if the default y-axis range is unacceptable specify an array of the minimum and maximum desired values,
    "yIsPercent": (true or false) true if yVar values represent percentages,
    "yFormat": (string or null) Number format spec for y-axis labels to pass to d3.format(),
    "labFormat": (string or null) Number format spec for data point labels to pass to d3.format(),
    "targetBaseYear": (number or null) Year of latest observed data available when the targets were established,
    "planRecs": [
        {
            "text": (string) Name of related ON TO 2050 recommendation,
            "url": "https://www.cmap.illinois.gov/2050/{{{path to recommendation}}}"
        },
        {
            (OPTIONAL) Additional specifications for other recommendations
        }
    ]
}
```

### index.html

HTML file defining the structure of the dashboard webpage. Also contains the introductory text and a small amount of JavaScript for calling the functions defined in *chart.js* whenever a new indicator is selected. Uses [Bootstrap](https://getbootstrap.com) to create a responsive layout.

### style.css

CSS file defining the visual styles to be applied to the dashboard webpage, including the generic aspects of each chart not specified in *chart_specs.json*.
