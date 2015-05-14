'use strict';

/**
 * @ngdoc function
 * @name ngMapApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the ngMapApp
 */
angular.module('ngMapApp')
  .controller('MainCtrl', ['$scope', function ($scope) {
    $scope.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];
  }]);
