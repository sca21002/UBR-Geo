goog.provide('ubrGeo.yearRangeSliderDirective');

goog.require('ubrGeo');
goog.require('ubrGeo.yearRangeSlider');

/**
 * Provides a directive used to insert a slider for years range
 * in the DOM
 *
 * @htmlAttribute {?Object} ubr-geo-year-range-slider The maps per years data.
 * @htmlAttribute {ubrGeox.yearRangeSlider.options} ubr-geo-year-range-slider-options The options.
 * @htmlAttribute {?Array} ubr-geo-year-range-slider-extent The year extent.
 * @return {angular.Directive} Directive Definition Object.
 * @ngInject
 * @ngdoc directive
 * @ngname ubrGeoYearRangeSliderDirective
 *
 */
ubrGeo.yearRangeSliderDirective = function() {
  return {
    restrict: 'A',
    templateUrl: 'views/yearrangeslider.html',
    link:
      /**
       * @param {angular.Scope} scope Scope.
       * @param {angular.JQLite} element Element.
       * @param {angular.Attributes} attrs Attributes.
       */
      function(scope, element, attrs) {
        var selection = d3.select(element[0]);

        var optionsAttr = attrs['ubrGeoYearRangeSliderOptions'];
        goog.asserts.assert(optionsAttr !== undefined);


        var yearRangeSlider;
        var mapsPerYear;
        var yearExtent;
        var options;

        scope.$watchCollection(optionsAttr, function(newVal) {

          options = /** @type {ubrGeox.yearRangeSlider.options} */
              (goog.object.clone(newVal));

          if (options !== undefined) {
              
            if (options.brushendCallback !== undefined) {
              var origBrushendCallback = options.brushendCallback;
              options.brushendCallback = function() {
                origBrushendCallback.apply(null, arguments);
                scope.$applyAsync();
              };
            }

            options.brushmoveCallback = function(yearMin, yearMax) {
              scope['yearMin'] = yearMin;
              scope['yearMax'] = yearMax;
              scope.$applyAsync();
            };

            yearRangeSlider = ubrGeo.yearRangeSlider(element[0], options);
            refreshData();
          }
        });

        scope.$watch(attrs['ubrGeoYearRangeSliderExtent'], function(newVal, oldVal) {
          if (newVal === undefined) {
            return;
          }
          yearExtent = newVal;
          refreshData();
        });

        scope.$watch(attrs['ubrGeoYearRangeSlider'], function(newVal, oldVal) {
          if (newVal === undefined) {
            return;
          }
          mapsPerYear = newVal;
          refreshData();
        });

        scope.yearChanged = function() {
          options.brushendCallback(scope['yearMin'], scope['yearMax']);
        }

        function refreshData() {
          if (yearRangeSlider !== undefined) {
            selection.datum(mapsPerYear).call(yearRangeSlider, yearExtent);
          }
        }
      }
  }
}

ubrGeo.module.directive('ubrGeoYearRangeSlider', ubrGeo.yearRangeSliderDirective);
