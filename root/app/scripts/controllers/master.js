'use strict';

/**
 * @ngdoc function
 * @name ngMapApp.controller:MasterCtrl
 * @description
 * # MasterCtrl
 * Controller of the ngMapApp
 */
angular.module('ngMapApp')
  .controller('MasterCtrl', [ '$scope', 'projectService', 'libraryService', 'searchParams', 
          function ($scope, projectService, libraryService, searchParams) {
    $scope.map = { mapId: 1 };              
    $scope.$on('ChangedMap', function (event, mapId) {
          $scope.mapId = mapId;
    });

    $scope.projects = projectService.load(); 
    $scope.project  = projectService.default();

    $scope.projectChanged = function() {
        searchParams.setProject($scope.project);
        $scope.$broadcast('ChangedProject',$scope.project)
    }    

    $scope.libraries = libraryService.load(); 
    $scope.library   = libraryService.default();

    $scope.libraryChanged = function() {
        searchParams.setLibrary($scope.library);
        $scope.$broadcast('ChangedLibrary',$scope.library)
    }
  }]);
