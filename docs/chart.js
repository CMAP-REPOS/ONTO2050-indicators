function clearChart() {
    // Clear any existing elements from the #chart div
    d3.selectAll('div#chart > *').remove();
    return;
}

function createChart(chartSpec, chartWidth=776, chartHeight=450) {
    // Build a chart in the #chart div from the supplied JSON specification
    //console.log(chartSpec);
    /*
    Inspiration:
        - http://bl.ocks.org/jhubley/17aa30fd98eb0cc7072f
        - https://observablehq.com/@d3/line-chart-with-tooltip
        - https://observablehq.com/@d3/learn-d3-interaction?collection=@d3/learn-d3
        - https://bl.ocks.org/d3noob/a22c42db65eb00d4e369
        - https://bl.ocks.org/larsenmtl/e3b8b7c2ca4787f77d78f58d41c3da91
    */

    // Set some chart-specific parameters
    let mainTitle = chartSpec.mainTitle,
        xTitle = chartSpec.xTitle,
        yTitle = chartSpec.yTitle,
        csvUrl = chartSpec.csvUrl,
        xVar = chartSpec.xVar,
        yRangeManual = chartSpec.yRangeManual,
        yIsPercent = chartSpec.yIsPercent,
        yFormat = chartSpec.yFormat,
        labFormat = chartSpec.labFormat,
        yVars = [],
        yVarNames = [],
        actualColors = [],
        targetColors = [];

    chartSpec.yVars.forEach(d => {
        yVars.push(d.yVar);
        yVarNames.push(d.name);
        actualColors.push(d.actualColor);
        targetColors.push(d.targetColor);
    })
    //console.log(yVars, actualColors, targetColors);

    // Set the dimensions of the canvas / graph
    let margin = {top: 10, right: 20, bottom: 50, left: 80},
        width = chartWidth - margin.left - margin.right,
        height = chartHeight - margin.top - margin.bottom;

    // Time-handling functions
    let parseYear = d3.timeParse('%Y');
    let formatYear = d3.timeFormat('%Y');

    // Scale functions
    let scX = d3.scaleTime().range([0, width]);
    let scY = d3.scaleLinear().range([height, 0]);

    // Number formatters
    if (yFormat && yFormat.endsWith('s')) {
        // Replace "G" (giga) suffix with "B" for billions
        yFormatter = d => d3.format(yFormat)(d).replace('G', 'B');
    } else {
        yFormatter = d3.format(yFormat);
    };
    if (labFormat && labFormat.endsWith('s')) {
        // Replace "G" (giga) suffix with "B" for billions
        labFormatter = d => d3.format(labFormat)(d).replace('G', 'B');
    } else {
        labFormatter = d3.format(labFormat);
    };

    // Axis functions
    let xAxis = d3.axisBottom(scX)
        .ticks(5);
    let yAxis = d3.axisLeft(scY)
        .ticks(5)
        .tickFormat(yFormatter);

    // Clear any existing elements from the chart div
    clearChart();

    // Add the title
    let chart = d3.select('div#chart');
    let title = chart.append('h2')
        .attr('id', 'main-title')
        .text(mainTitle);

    // Add legend
    let legend = chart.append('div')
        .attr('id', 'legend');
    for (i = 0; i < yVars.length; i++) {
        yVar = yVars[i];
        yVarName = yVarNames[i];
        actualColor = actualColors[i];
        targetColor = targetColors[i];

        if (targetColor) {
            if (yVarName) {
                legend.append('div')
                    .attr('class', 'legend-item actual')
                    .attr('id', `${yVar}`)
                    .attr('style', `border-left: 18px solid ${actualColor}`)
                    .text(`${yVarName} (actual)`);
                legend.append('div')
                    .attr('class', 'legend-item target')
                    .attr('id', `${yVar}`)
                    .attr('style', `border-left: 18px solid ${targetColor}`)
                    .text(`${yVarName} (target)`);
            } else {
                legend.append('div')
                    .attr('class', 'legend-item actual')
                    .attr('id', `${yVar}`)
                    .attr('style', `border-left: 18px solid ${actualColor}`)
                    .text('Actual');
                legend.append('div')
                    .attr('class', 'legend-item target')
                    .attr('id', `${yVar}`)
                    .attr('style', `border-left: 18px solid ${targetColor}`)
                    .text('Target');
            };
        } else {
            if (yVarName) {
                legend.append('div')
                    .attr('class', 'legend-item actual')
                    .attr('id', `${yVar}`)
                    .attr('style', `border-left: 18px solid ${actualColor}`)
                    .text(`${yVarName}`);
            // } else {
            //     legend.append('div')
            //         .attr('class', 'legend-item actual')
            //         .attr('id', `${yVar}`)
            //         .attr('style', `border-left: 18px solid ${actualColor}`)
            //         .text('Actual');
            };
        };
    };

    // Add the svg canvas
    let svg = chart.append('svg')
            .attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom)
        .append('g')
            .attr('transform', `translate(${margin.left},${margin.top})`);

    // Get the data
    let allYVals = [];
    d3.csv(csvUrl).then(data => {
        data.forEach(d => {
            d[xVar] = parseYear(d[xVar]);
            for (v of yVars) {
                //console.log(v);
                if (d[v] != '') {
                    d[v] = +d[v];
                    if (yIsPercent) {
                        d[v] = d[v] / 100;
                    };
                    allYVals.push(d[v]);
                } else {
                    d[v] = null;
                }
                //console.log(`${formatYear(d[xVar])} (${d['ACTUAL_OR_TARGET']}): ${d[v]}`);
            };
        });
        //console.log(data);
        //console.log(allYVals);

        let lastActualYear = d3.max(
            data.filter(d => d['ACTUAL_OR_TARGET']==='Actual'),
            d => d[xVar]
        );
        //console.log(lastActualYear);

        // Scale the range of the data
        let xLims = d3.extent(data, d => d[xVar]);
        scX.domain(xLims); //.nice();

        let yLims;
        if (yRangeManual) {
            yLims = d3.extent(yRangeManual);
            scY.domain(yLims);
        } else {
            yLims = d3.extent(allYVals);
            let yBuffer = Math.abs(yLims[1] - yLims[0]) * 0.2;
            if (yIsPercent) {
                yLims = [Math.max(yLims[0] - yBuffer, 0), Math.min(yLims[1] + yBuffer, 1)];
            } else {
                yLims = [yLims[0] - yBuffer, yLims[1] + yBuffer];
            };
            scY.domain(yLims).nice();
        };
        //console.log(yLims[0], yLims[1]);

        // Add the axis titles
        svg.append('text')
            .attr('class', 'axis-title x-title')
            .attr('text-anchor', 'middle')
            .attr('x', (width / 2))  // Horizontal placement = center of plot
            .attr('y', height + margin.bottom)  // Vertical placement = bottom of canvas
            .attr('dy', '-7px')  // Vertical adjustment = nudge up
            .text(xTitle);
        svg.append('text')
            .attr('class', 'axis-title y-title')
            .attr('text-anchor', 'middle')
            .attr('transform', 'rotate(-90)')
            .attr('x', -(height / 2))  // Vertical placement, because of rotation = center of plot
            .attr('y', -margin.left)  // Horizontal placement, because of rotation = left edge of canvas
            .attr('dy', '14px')  // Horizontal adjustment, because of rotation = nudge right
            .text(yTitle);

        // Add horizontal gridlines
        svg.append('g')
            .attr('id', 'grid')
            .selectAll('line')
            .data(scY.ticks(5))
            .enter()
            .append('line')
            .attr('class', 'grid')
            .attr('x1', 0)
            .attr('x2', width)
            .attr('y1', d => scY(d))
            .attr('y2', d => scY(d))

        // Add the X/Y axes
        svg.append('g')
            .attr('class', 'axis')
            .attr('id', 'x-axis')
            .attr('transform', `translate(0,${height})`)
            .call(xAxis);
        svg.append('g')
            .attr('class', 'axis')
            .attr('id', 'y-axis')
            .call(yAxis);

        // Add data
        let yVar,
            yVarName,
            actualColor,
            targetColor;
        for (i = 0; i < yVars.length; i++) {
            yVar = yVars[i];
            yVarName = yVarNames[i];
            actualColor = actualColors[i];
            targetColor = targetColors[i];

            // Line-plotting function
            let plotLine = d3.line()
                .curve(d3.curveMonotoneX)  // Heisenberg says "relax"
                .x(d => scX(d[xVar]))
                .y(d => scY(d[yVar]));

            // Create a new group for each yVar's lines/points/labels
            svg.append('g')
                .attr('id', yVar)

            // Add the actual/target lines
            svg.select(`#${yVar}`)
                .append('path')
                .attr('style', `stroke: ${actualColor}`)
                .attr('d', plotLine(data.filter(d => d[xVar] <= lastActualYear && d[yVar] != null)));
            if (targetColor) {
                svg.select(`#${yVar}`)
                    .append('path')
                    .attr('style', `stroke: ${targetColor}; stroke-dasharray: 8,4;`)
                    .attr('d', plotLine(data.filter(d => d[xVar] >= lastActualYear && d[yVar] != null)));
            };

            // Add points for all observations (actual/target)
            svg.select(`#${yVar}`)
                .selectAll('circle')
                .data(data.filter(d => d[yVar] != null))
                .enter()
                .append('circle')
                .attr('style', (d => d[xVar] <= lastActualYear ? `fill: ${actualColor}` : `fill: ${targetColor}`))
                .attr('r', '3px')
                .attr('cx', d => scX(d[xVar]))
                .attr('cy', d => scY(d[yVar]))
                .append('title')  // Very basic tooltips
                .text(d => {
                    let yearText = `${formatYear(d[xVar])}`;
                    if (d[xVar] > lastActualYear) {
                        yearText = yearText + ' target';
                    };
                    if (yVarName === null) {
                        return `${yearText}: ${labFormatter(d[yVar])}`;
                    } else {
                        return `${yVarName}, ${yearText}: ${labFormatter(d[yVar])}`;
                    };
                });

            // Label the points
            /*let labBuffer = Math.abs(yLims[1] - yLims[0]) * 0.05;
            svg.select(`#${yVar}`)
                .selectAll(`text`)
                .data(data.filter(d => d[xVar] >= lastActualYear && d[yVar] != null))
                .enter()
                .append('text')
                .attr('class', 'label')
                .attr('id', yVar)
                .attr('style', (d => d[xVar] <= lastActualYear ? `fill: ${actualColor}` : `fill: ${targetColor}`))
                .attr('x', d => scX(d[xVar]))
                .attr('y', d => scY(d[yVar] + labBuffer))
                .attr('text-anchor', 'middle')
                .text(d => d3.format(labFormat)(d[yVar]));*/
        };
    });
};

function filterChartSpecs(json, key, value) {
    // Return subset of chart specifications where specified key has specified value
    let result = [];
    json.forEach(d => {
        if(d[key] === value) {
            result.push(d);
        };
    });
    //console.log(result);
    return result;
};

function getChapterIndicatorIds(json, chapterId) {
    // Return a list of chart IDs for indicators with a specific chapter id
    //console.log(chapterId);
    let result = [];
    filterChartSpecs(json, 'chapterId', chapterId).forEach(d => {
        result.push(d.chartId);
    });
    return result;
};

function getChartSpecById(json, chartId) {
    // Return the JSON chart specification for a specified chart ID
    return filterChartSpecs(json, 'chartId', chartId)[0];
};
