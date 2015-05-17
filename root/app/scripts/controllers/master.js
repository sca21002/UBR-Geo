'use strict';

/**
 * @ngdoc function
 * @name ngMapApp.controller:MasterCtrl
 * @description
 * # MasterCtrl
 * Controller of the ngMapApp
 */
angular.module('ngMapApp')
  .controller('MasterCtrl', [ 
          '$scope', 'projectService', 'libraryService', 'searchParams',
          function ($scope, projectService, libraryService, searchParams) {

    $scope.map = { mapId: 1 };              
    $scope.$on('ChangedMap', function (event, mapId) {
          $scope.mapId = mapId;
    });


    $scope.projects = projectService.load(); 
    $scope.project = searchParams.getProject();

    $scope.projectChanged = function() {
        searchParams.setProject($scope.project);
        $scope.$broadcast('ChangedProject',$scope.project);
    };    

    $scope.libraries = libraryService.load(); 
    $scope.library   = libraryService.getLibrary();

    $scope.libraryChanged = function() {
        searchParams.setLibrary($scope.library);
        $scope.$broadcast('ChangedLibrary',$scope.library);
    };

    $scope.$on('ChangedProject', function (event, project) {
        $scope.project = project;
    });

    $scope.$on('ChangedLibrary', function (event, library) {
        $scope.library = library;
    });

}]);
