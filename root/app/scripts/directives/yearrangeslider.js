'use strict';

/**
 * @ngdoc directive
 * @name ubrGeoApp.directive:yearRangeSlider
 * @description
 * # yearRangeSlider
 */
angular.module('ubrGeoApp')
  .directive('yearRangeSlider', function ($window, d3) {
    
    var draw = function(svg, width_tot, height_tot, scope){

        var data = [];
        angular.copy(scope.data,data); 

        var margin = {top: 20, right: 20, bottom: 40, left: 40},
        width  = width_tot  - margin.left - margin.right,
        height = height_tot - margin.top  - margin.bottom;

      var yearFormat = d3.time.format('%Y'); 
    
      var x = d3.time.scale().range([0, width]),
          y = d3.scale.linear().range([height, 0]);
      
      var xAxis = d3.svg.axis().scale(x).orient('bottom');

      var brush;

      function brushend() {
          var yearExtent = brush.empty() ? x.domain() : brush.extent();
          yearExtent = yearExtent.map(function(d){return parseFloat(yearFormat(d)); });
          // this next 3 lines are important for clicking on brush background = clearing brush
          scope.yearmin = yearExtent[0];
          scope.yearmax = yearExtent[1];
          scope.$apply();
          scope.action({ newExtent: yearExtent });
      }

      function brushmove() {
          if (brush.empty()) {
              return;
          }
          var yearExtent = brush.extent();
          yearExtent = yearExtent.map(function(d){return yearFormat(d); });
          scope.yearmin = yearExtent[0];
          scope.yearmax = yearExtent[1];
          scope.$apply();
      }

      brush = d3.svg.brush()
          .x(x)
          .extent([0,1])
          .on('brush', brushmove)
          .on('brushend', brushend);


      var year_min = d3.min(data.map(function(d) { return d.year; }));
      var year_max = d3.max(data.map(function(d) { return d.year; }));
      
      if (scope.extent && scope.extent.length === 2) {
        scope.yearmin = scope.extent[0];
        scope.yearmax = scope.extent[1];
        var x0 = ( scope.extent[0] - year_min ) / ( year_max - year_min);
        var x1 = ( scope.extent[1] - year_min ) / ( year_max - year_min); 
        brush.extent([x0,x1]);
      } else {
        scope.yearmin = year_min;
        scope.yearmax = year_max;
      }


      svg.attr('width',  width  + margin.left + margin.right)
         .attr('height', height + margin.top  + margin.bottom);
      
      var context = svg.select('.data')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');


      data.forEach(function(d) {d.year = yearFormat.parse(d.year.toString()); });      
      x.domain(d3.extent(data.map(function(d) { return d.year; })));
      y.domain([0, d3.max(data.map(function(d) { return d.count; }))]);

      var barWidth = width / (year_max - year_min); 

      context.selectAll('g').remove();
      var bar = context.selectAll('g')
          .data(data)
          .enter().append('g')
          .attr('transform', function(d) { 
              return 'translate(' + (x(d.year) -  barWidth/2) + ',0)'; 
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


      scope.redrawExtent = function(newExtent) {
        if (newExtent[0] === year_min && newExtent[1] === year_max) {
            brush.clear();
        } else {
            var yearExtent = newExtent.map(function(d) { 
                return yearFormat.parse(d.toString()); 
            });
            brush.extent(yearExtent);
        }    
        svg.select('.brush').call(brush);  // redraw brush
      };

    };

    return {
      restrict: 'E',
      scope: {
          data: '=',
          extent: '=',
          action: '&'    
      },
      templateUrl: 'views/yearrangeslider.html',
      compile: function (element) {
        // Create a SVG root element
        var svg = d3.select(element[0]).append('svg');

        svg.append('g').attr('class', 'data');
        svg.append('g').attr('class', 'axis x-axis');

        // Define the dimensions for the slider
        var height = 140;

        
        // Return the link function
        return function(scope, element) { 
      
          // Watch the data attribute of the scope
          scope.$watch('data', function(newVal, oldVal, scope) {
  
              // Update the slider
              if (angular.isArray(scope.data)) {
                var width = element.parent().width();
                draw(svg, width, height, scope);
              }
          }, true);

          scope.yearChanged = function() {
              scope.yearmin = parseFloat(scope.yearmin);
              scope.yearmax = parseFloat(scope.yearmax);

                var year_min = d3.min(scope.data.map(function(d) { return d.year; }));
                var year_max = d3.max(scope.data.map(function(d) { return d.year; }));
                

                if (isNaN(scope.yearmin) || scope.yearmin < year_min) {
                    scope.yearmin = year_min;
                }
                if (isNaN(scope.yearmax) || scope.yearmax > year_max) {
                    scope.yearmax = year_max;
                }
                if (scope.extent[0] !== scope.yearmin || scope.extent[1] !== scope.yearmax ) {
                    var newExtent = [scope.yearmin, scope.yearmax];
                    scope.action({ newExtent: newExtent });
                    scope.redrawExtent(newExtent);
                }
          };

          angular.element($window).bind('resize', function () {
              if (angular.isArray(scope.data)) {
                var width = element.parent().width();
                draw(svg, width, height, scope);
              }
          });  
        
        };
      }
    };
  });
