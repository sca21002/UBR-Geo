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
        $scope.$broadcast('ChangedProject', $scope.project);
    };    

    $scope.libraries = libraryService.load(); 
    $scope.library   = searchParams.getLibrary();

    $scope.libraryChanged = function() {
        searchParams.setLibrary($scope.library);
        $scope.$broadcast('ChangedLibrary', $scope.library);
    };

    $scope.search = searchParams.getSearch();
    
    $scope.searchChanged = function() {
        searchParams.setSearch($scope.search);
        $scope.$broadcast('ChangedSearch', $scope.search);
    };

    $scope.$on('ChangedProject', function (event, project) {
        $scope.project = project;
    });

    $scope.$on('ChangedLibrary', function (event, library) {
        $scope.library = library;
    });

    $scope.$on('ChangedSearch', function (event, search) {
        $scope.search = search;
    });

  });
