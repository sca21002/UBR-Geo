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
   console.log('Detail - mapId: ', $scope.mapId);
   console.log('Map-ID: ', $routeParams.mapId);    
   $scope.mapId = $routeParams.mapId;  
   $rootScope.mapId = $routeParams.mapId;
});
