'use strict';

/**
 * @ngdoc overview
 * @name ngMapApp
 * @description
 * # ngMapApp
 *
 * Main module of the application.
 */
angular
  .module('ngMapApp', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch',
    'ui.bootstrap'
    ])
  .config(['$routeProvider', function ($routeProvider) {
    $routeProvider
      .when('/about', {
        templateUrl: 'views/about.html',
        controller: 'AboutCtrl'
      })
      .when('/maps', {
        templateUrl: 'views/maps.html',
        controller: 'MapsCtrl'
      })
      .when('/map/:mapId', {
        templateUrl: 'views/mapdetail.html',
        controller: 'MapdetailCtrl'
      })
      .otherwise({
        redirectTo: '/maps'
      });
  }]);
