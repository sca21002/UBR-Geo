'use strict';

/**
 * @ngdoc function
 * @name ubrGeoApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the ubrGeoApp
 */
angular.module('ubrGeoApp')
  .controller('MainCtrl', function ($scope) {
    $scope.getClass = function (path) {
      if(path === '/') {
          if($location.path() === '/') {
              return "active";
          } else {
              return "";
          }
      }
   
      if ($location.path().substr(0, path.length) === path) {
          return "active";
      } else {
          return "";
      }
    }
  });
