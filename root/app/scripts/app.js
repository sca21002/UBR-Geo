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
    'ngTouch'
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

ubrGeoApp.directive('olMap', function() {
    var MAP_DOM_ELEMENT_ID = 'map';
    return {
        template: '<div id="' + MAP_DOM_ELEMENT_ID + '"></div>',
        // restrict to elements, seems necessary, contrary to the docs
        restrict: 'E',
        link: function postLink(scope, element, attrs) {
          scope.ol_map = new ol.Map({
            target: 'map',
            layers: [
              new ol.layer.Tile({
                source: new ol.source.OSM({
                    attributions : [ol.source.OSM.DATA_ATTRIBUTION],
                    url : "http://pc1011406020.uni-regensburg.de/tiles/osm-bright/{z}/{x}/{y}.png",
                    crossOrigin: null
                })
              })
            ],
            controls: ol.control.defaults({
                attributionOptions: /** @type {olx.control.AttributionOptions} */ ({
                    collapsible: false
                })
            }),
            view: new ol.View({
              center: ol.proj.transform([12.053, 48.941], 'EPSG:4326', 'EPSG:3857'),
              zoom: 13
            })
          });
        }
    };
});
