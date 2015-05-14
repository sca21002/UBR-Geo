'use strict';

/**
 * @ngdoc function$routeParams
 * @name ngMapApp.controller:MapdetailCtrl
 * @description
 * # MapdetailCtrl
 * Controller of the ngMapApp
 */
angular.module('ngMapApp')
  .controller('MapdetailCtrl', ['$scope', '$location', '$routeParams', function ($scope, $location, $routeParams) {
    $scope.mapId = $routeParams.mapId;  
  }]);
