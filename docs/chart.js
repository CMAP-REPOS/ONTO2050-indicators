function clearChart() {
    // Clear any existing elements from the chart div
    d3.selectAll('div#chart > *').remove();
    return;
}

function createChart(chartSpec) {
    //console.log(chartSpec);
    /*
    Read <http://bl.ocks.org/jhubley/17aa30fd98eb0cc7072f> for inspiration
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
        actualColors = [],
        targetColors = [];

    chartSpec.yVars.forEach(d => {
        yVars.push(d.yVar);
        actualColors.push(d.actualColor);
        targetColors.push(d.targetColor);
    })
    //console.log(yVars, actualColors, targetColors);


    // Set the dimensions of the canvas / graph
    let margin = {top: 50, right: 30, bottom: 50, left: 80},
        width = 800 - margin.left - margin.right,
        height = 450 - margin.top - margin.bottom;

    // Time-handling functions
    let parseYear = d3.timeParse('%Y');
    let formatYear = d3.timeFormat('%Y');

    // Scale functions
    let scX = d3.scaleTime().range([0, width]);
    let scY = d3.scaleLinear().range([height, 0]);

    // Axis functions
    let xAxis = d3.axisBottom(scX)
        .ticks(5);
    let yAxis = d3.axisLeft(scY)
        .ticks(5)
        .tickFormat(d3.format(yFormat));

    // Clear any existing elements from the chart div
    clearChart();

    // Add the svg canvas
    let svg = d3.select('div#chart')
        .append('svg')
            .attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom)
        .append('g')
            .attr('transform', `translate(${margin.left},${margin.top})`);

    // Get the data
    let allYVals = [];
    d3.csv(csvUrl).then(data => {
        data.forEach(d => {
            d[xVar] = parseYear(d[xVar]);
            for (yVar of yVars) {
                //console.log(v);
                d[yVar] = +d[yVar];
                if (yIsPercent) {
                    d[yVar] = d[yVar] / 100;
                };
                allYVals.push(d[yVar]);
                //console.log(`${formatYear(d[xVar])} (${d['ACTUAL_OR_TARGET']}): ${d[yVar]}`);
            };
        });
        //console.log(allYVals);

        let lastActualYear = d3.max(
            data.filter(d => d['ACTUAL_OR_TARGET']==='Actual'),
            d => d[xVar]
        );
        //console.log(lastActualYear);

        // Scale the range of the data
        let xLims = d3.extent(data, d => d[xVar]);
        scX.domain(xLims).nice();

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

        // Add the main title
        svg.append('text')
            .attr('class', 'main-title')
            .attr('text-anchor', 'middle')
            .attr('x', (width / 2))  // Horizontal placement = center of plot
            .attr('y', 0 - (margin.top / 2))
            .text(mainTitle);

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

        let yVar,
            actualColor,
            targetColor;
        for (i = 0; i < yVars.length; i++) {
            yVar = yVars[i];
            actualColor = actualColors[i];
            targetColor = targetColors[i];

            // Line-plotting function
            let plotLine = d3.line()
                .curve(d3.curveCardinal.tension(0.5))  // Heisenberg says "relax"
                .x(d => scX(d[xVar]))
                .y(d => scY(d[yVar]));

            // Create a new group for each yVar's lines/points/labels
            svg.append('g').attr('id', yVar)

            // Add the actual/target lines
            svg.select(`#${yVar}`)
                .append('path')
                .attr('style', `stroke: ${actualColor}`)
                .attr('d', plotLine(data.filter(d => d[xVar] <= lastActualYear)));
            if (targetColor) {
                svg.select(`#${yVar}`)
                    .append('path')
                    .attr('style', `stroke: ${targetColor}; stroke-dasharray: 8,4;`)
                    .attr('d', plotLine(data.filter(d => d[xVar] >= lastActualYear)));
            };

            // Add points for the final actual value and any targets
            svg.select(`#${yVar}`)
                .selectAll(`circle`)
                .data(data.filter(d => d[xVar] >= lastActualYear))
                .enter()
                .append('circle')
                .attr('style', (d => d[xVar] === lastActualYear ? `fill: ${actualColor}` : `fill: ${targetColor}`))
                .attr('r', 5)
                .attr('cx', d => scX(d[xVar]))
                .attr('cy', d => scY(d[yVar]));

            // Label the points
            let labBuffer = Math.abs(yLims[1] - yLims[0]) * 0.05;
            svg.select(`#${yVar}`)
                .selectAll(`text`)
                .data(data.filter(d => d[xVar] >= lastActualYear))
                .enter()
                .append('text')
                .attr('class', 'label')
                .attr('id', yVar)
                .attr('style', (d => d[xVar] === lastActualYear ? `fill: ${actualColor}` : `fill: ${targetColor}`))
                .attr('x', d => scX(d[xVar]))
                .attr('y', d => scY(d[yVar] + labBuffer))
                .attr('text-anchor', 'middle')
                .text(d => d3.format(labFormat)(d[yVar]));
        };

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
    });
};
