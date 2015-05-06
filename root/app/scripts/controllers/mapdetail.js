'use strict';

/**
 * @ngdoc function
 * @name ngMapApp.controller:MapdetailCtrl
 * @description
 * # MapdetailCtrl
 * Controller of the ngMapApp
 */
angular.module('ngMapApp')
  .controller('MapdetailCtrl', function ($scope, $location, $routeParams) {
    $scope.mapId = $routeParams.mapId;  
  });
