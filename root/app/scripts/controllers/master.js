'use strict';

/**
 * @ngdoc function
 * @name ubrGeoApp.controller:MasterCtrl
 * @description
 * # MasterCtrl
 * Controller of the ubrGeoApp
 */
angular.module('ubrGeoApp')
  .controller('MasterCtrl', function ($scope, $route, libraryService, projectService, searchParams) {

    $scope.$route = $route;

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

  });
