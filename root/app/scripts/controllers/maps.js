'use strict';

/**
 * @ngdoc function
 * @name ubrGeoApp.controller:MapsCtrl
 * @description
 * # MapsCtrl
 * Controller of the ubrGeoApp
 */
angular.module('ubrGeoApp')
  .controller('MapsCtrl', function ($scope, $http) {
      $http.get('http://pc1011406020.uni-regensburg.de:8888/maps').success(function(data) {  
              $scope.maps = data.maps;
              $scope.totalMaps = data.maps_total;
              $scope.currentPage = 1;    
      });
  });
