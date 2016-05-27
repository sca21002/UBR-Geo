goog.provide('app_ubr_geo');

goog.require('ubrGeo');
goog.require('app.MainController');
goog.require('app.MapsController');
goog.require('app.MapdetailController');

/** @type {!angular.Module} **/
app.module = angular.module('ubrGeoApp', [
    ubrGeo.module.name, 
    'ui.bootstrap',
    'ngRoute'
]);

app.module.constant('ubrGeoServerURL', 'http://localhost:8888/');

app.module.config(['$routeProvider', function($routeProvider) {
    $routeProvider.when('/maps', {
        templateUrl: 'views/maps.html',
        controller: 'MapsController',
        controllerAs: 'mapsCtrl'
    }),
    $routeProvider.when('/map/:mapId', {
        templateUrl: 'views/mapdetail.html',
        controller: 'MapdetailController',
        controllerAs: 'mapdetailCtrl'
//    })
//    .otherwise({
//      redirectTo: '/map:mapId'
    });
}]);

app.module.controller('MainController', app.MainController);
app.module.controller('MapsController', app.MapsController);
app.module.controller('MapdetailController', app.MapdetailController);
