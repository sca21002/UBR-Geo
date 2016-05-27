goog.provide('ubrGeo.yearRangeSlider');


/**
 * Provides a D3js component to be used to draw a block chart
 * with slider bars
 * 
 *
 *
 * @constructor
 * @return {Object} D3js component.
 * @param {angular.JQLite} element Element.
 * @export
 */
ubrGeo.yearRangeSlider = function(element, options) {

  /**
   * brushmove callback function.
   * @type {function(string, string)}
   */
  var brushmoveCallback = options.brushmoveCallback !== undefined ?
      options.brushmoveCallback : goog.nullFunction;

  /**
   * brushend callback function.
   * @type {function(string, string)}
   */
  var brushendCallback = options.brushendCallback !== undefined ?
      options.brushendCallback : goog.nullFunction;

  var margin = {top: 20, right: 20, bottom: 40, left: 40};

  /**
   * svg root element
   * @type {Object}
   */
  var svg = d3.select(element).append('svg');

  // g element grouping bar chart elements
  svg.append('g').attr('class', 'data');
  // g element for x-axis
  svg.append('g').attr('class', 'axis x-axis');

  /**
   *  time formated as 4-digit year
   */  
  var yearFormat = d3.time.format('%Y'); 

  /**
   * Width of chart in pixel
   */ 
  var width;

  /**
   * Height of chart in pixel
   */ 
  var height;

  /**
   * D3 x scale
   */
  var x;

  /**
   * D3 y scale
   */
  var y;

  /**
   * x-Axis
   */
  var xAxis;

  /**
   * lower limit of year
   */
  var yearMin;

  /**
   * upper limit of year
   */
  var yearMax;    

  /**
   * width of the bar element
   */
  var barWidth;

  /**
   * bars of the bar chart
   */
  var bar;

  var brush;

  var yearRangeSlider = function(selection, extent) {
    selection.each(function(data) {

      width  = this.clientWidth - margin.left - margin.right,
      height = this.clientHeight - margin.top  - margin.bottom;

      x = d3.time.scale().range([0, width]);
      y = d3.scale.linear().range([height, 0]);

      function brushend() {
        var yearExtent = brush.empty() ? x.domain() : brush.extent();
        yearExtent = yearExtent.map(function(d){return parseFloat(yearFormat(d)); });
        brushendCallback(yearExtent[0], yearExtent[1]);
      }

      function brushmove() {
        if (brush.empty()) {
          return;
        }
        var yearExtent = brush.extent();
        yearExtent = yearExtent.map(function(d){return yearFormat(d); });
        brushmoveCallback(yearExtent[0], yearExtent[1]);
      }
  
      xAxis = d3.svg.axis().scale(x).orient('bottom');

      svg.attr('width',  width  + margin.left + margin.right)
         .attr('height', height + margin.top  + margin.bottom);


      
      var context = svg.select('.data')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

      context.selectAll('g').remove();

      if (data === undefined) { 
        return; 
      }

      yearMin = d3.min(data.map(function(d) { return d.year; }));
      yearMax = d3.max(data.map(function(d) { return d.year; }));


      data.forEach(function(d) {d.date = yearFormat.parse(d.year.toString()); });      

      x.domain(d3.extent(data.map(function(d) { return d.date; })));
      y.domain([0, d3.max(data.map(function(d) { return d.count; }))]);


      brush = d3.svg.brush()
        .x(x)
//        .extent([yearFormat.parse(yearMin.toString()), yearFormat.parse(yearMax.toString())])
        .on('brush', brushmove)
        .on('brushend', brushend);

      if (extent && extent.length === 2) {
        var y1 = yearFormat.parse(extent[0].toString());
        var y2 = yearFormat.parse(extent[1].toString());
        brush.extent([y1, y2]);
      } else {
        brush.extent([yearFormat.parse(yearMin.toString()), yearFormat.parse(yearMax.toString())])
        brushmoveCallback(yearMin, yearMax);
      }

      barWidth = width / (yearMax - yearMin); 

      bar = context.selectAll('g')
          .data(data)
          .enter().append('g')
          .attr('transform', function(d) { 
              return 'translate(' + (x(d.date) - barWidth/2) + ', 0)'; 
          });
    
      bar.append('rect')
        .attr('y', function(d) { return y(d.count); })
        .attr('height', function(d) { return height - y(d.count); })
        .attr('width', barWidth - 0.5 );
    
      svg.select('.x-axis')
          .attr('transform', 'translate(' + margin.left + ',' + (height + margin.top) + ')')
          .call(xAxis);        

      var brushg = context.append('g')
        .attr('class', 'x brush')
          .call(brush);
          
       brushg.selectAll('rect')
          .attr('y', -6)
          .attr('height', height + 7);
      

       brushg.selectAll('.resize.e')
        .append('rect')
          .attr('x', 0)
          .attr('y', -10)
          .attr('width', 14)
          .attr('height', height + 16)
          .attr('rx', 5)
          .attr('ry', 5)
          .attr('fill', 'rgb(70,130,180)');


      var data_e = [
        { cx:4, cy:height/2-10 },
        { cx:10, cy:height/2-10 },
        { cx:4, cy:height/2-2 },
        { cx:10, cy:height/2-2 },
        { cx:4, cy:height/2+6 },
        { cx:10, cy:height/2+6 }
      ]; 

      brushg.selectAll('.resize.e')
          .selectAll('circle').data(data_e)
          .enter()
          .append('circle')
          .attr('r', 2)
          .attr('cx', function(d) { return d.cx; })
          .attr('cy', function(d) { return d.cy; })
          .style('fill', 'white');

       brushg.selectAll('.resize.w')
        .append('rect')
          .attr('x', -14)
          .attr('y', -10)
          .attr('width', 14)
          .attr('height', height + 16)
          .attr('rx', 5)
          .attr('ry', 5)
          .attr('fill', 'rgb(70,130,180)');
      
      var data_w = [
        { cx:-10, cy:height/2-10 },
        { cx:-4, cy:height/2-10 },
        { cx:-10, cy:height/2-2 },
        { cx:-4, cy:height/2-2 },
        { cx:-10, cy:height/2+6 },
        { cx:-4, cy:height/2+6 }
      ]; 

      brushg.selectAll('.resize.w')
          .selectAll('circle').data(data_w)
          .enter()
          .append('circle')
          .attr('r', 2)
          .attr('cx', function(d) { return d.cx; })
          .attr('cy', function(d) { return d.cy; })
          .style('fill', 'white');

    });  
  };

  return yearRangeSlider;
}
