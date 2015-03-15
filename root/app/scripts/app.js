'use strict';

/**
 * @ngdoc overview
 * @name ubrGeoApp
 * @description
 * # ubrGeoApp
 *
 * Main module of the application.
 */
var ubrGeoApp = angular
  .module('ubrGeoApp', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch',
    'angularUtils.directives.dirPagination'   // pagination
  ])
  .config(function ($routeProvider) {
    $routeProvider
      .when('/', {
        templateUrl: 'views/main.html',
        controller: 'MainCtrl'
      })
      .when('/about', {
        templateUrl: 'views/about.html',
        controller: 'AboutCtrl'
      })
      .when('/maps', {
        templateUrl: 'views/maps.html',
        controller: 'MapsCtrl'
      })
      .otherwise({
        redirectTo: '/'
      });
  });

// Template for pagination
ubrGeoApp.config(function(paginationTemplateProvider) {
    paginationTemplateProvider.setPath('bower_components/angular-utils-pagination/dirPagination.tpl.html');
});

ubrGeoApp.directive('olMap', function() {
    var MAP_DOM_ELEMENT_ID = 'map';
    return {
        template: '<div id="' + MAP_DOM_ELEMENT_ID + '"></div>',
        // restrict to elements, seems necessary, contrary to the docs
        restrict: 'E',
        link: function postLink(scope, element, attrs) {
          scope.olMap = new ol.Map({
            target: 'map',
            layers: [
              new ol.layer.Tile({
                source: new ol.source.XYZ({
                    url: 'http://api.tiles.mapbox.com/v4/sca21002.l80l365g/{z}/{x}/{y}.png?access_token=pk.eyJ1Ijoic2NhMjEwMDIiLCJhIjoieWRaV0NrcyJ9.g6_31qK3mtTz_6gRrbuUGA',
                    //url : "http://pc1011406020.uni-regensburg.de/tiles/osm-bright/{z}/{x}/{y}.png",
                    crossOrigin: null
                })
              })
            ],
            controls: [
                new ol.control.Zoom(),
                new ol.control.OverviewMap({
                    collapsed: false
                })
            ],
            view: new ol.View({
              center: ol.proj.transform([12.053, 48.941], 'EPSG:4326', 'EPSG:3857'),
              zoom: 2
            })
          });
          console.log('map directive: ', scope.extent);
          var extent_3857 = ol.proj.transformExtent(scope.extent, 'EPSG:4326', 'EPSG:3857');
          console.log('init extent (3857): ', extent_3857);
          var olMap = scope.olMap;
          var view = olMap.getView();
          var size = olMap.getSize();
          view.fitExtent(extent_3857, size);
          extent_3857 = view.calculateExtent( size );
          console.log('fit extent (3857): ',  extent_3857); 
          scope.extent = ol.proj.transformExtent(extent_3857, 'EPSG:3857', 'EPSG:4326');
          scope.resolution = view.getResolution();
          console.log('fit extent: ', scope.extent, ' res: ', scope.resolution);
          scope.changeres = view.on('change:resolution', function(evt) {
              console.log('Resolution: ', view.getResolution() );
              var extent_3857 = view.calculateExtent( olMap.getSize() );
              console.log('Extent (3857): ', extent_3857);
              scope.extent = ol.proj.transformExtent(extent_3857, 'EPSG:3857', 'EPSG:4326');
              console.log('Resolution changed: ', scope.extent);
              scope.currentPage = 1;
              scope.getData(scope.currentPage, scope.extent);
          });     
          olMap.on('moveend', function(evt) {
              var map = evt.map;
              var extent_3857 = map.getView().calculateExtent(map.getSize()); 
              console.log('Extent (3857): ', extent_3857);
              scope.extent = ol.proj.transformExtent(extent_3857, 'EPSG:3857', 'EPSG:4326');
              console.log('Center changed: ', scope.extent);
              scope.currentPage = 1;
              scope.getData(scope.currentPage, scope.extent);
          });
        }
    };
});
