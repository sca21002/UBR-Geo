'use strict';

/**
 * @ngdoc function
 * @name ubrGeoApp.controller:MapDetailCtrl
 * @description
 * # MapDetailCtrl
 * Controller of the ubrGeoApp
 */
angular.module('ubrGeoApp')
  .controller('MapDetailCtrl', function ($scope, $rootScope, $routeParams) {
   $scope.mapId = $routeParams.mapId;  
   $rootScope.mapId = $routeParams.mapId;
});
