'use strict';

/**
 * @ngdoc service
 * @name ubrGeoApp.searchParams
 * @description
 * # searchParams
 * Factory in the ubrGeoApp.
 */
angular.module('ubrGeoApp')
  .factory('searchParams', ['projectService', 'libraryService', 
          function (projectService, libraryService) {

    var data = {
        center:  {
            lon:   12.053,
            lat:   48.941,
            zoom:  10,
            'bounds': []
        },
        name: undefined,
        page: 1,
        project: projectService.default(),
        library: libraryService.default(),
        yearExtent: [],
        search: undefined
    };
    
    var factory = {};

    factory.getCenter = function() {
        return data.center;
    };

    factory.setCenter = function(center) {
        angular.extend(data.center, center);
    };

    factory.getName = function() {
        return data.name;
    };

    factory.setName = function(name) {
        data.name = name;
    };

    factory.getPage = function() {
        return data.page;
    };

    factory.setPage = function(page) {
        data.page = page;
    };

    factory.getProject = function() {
        return data.project; 
    };    

    factory.setProject = function(project) {
        data.project = project;
    };    

    factory.getLibrary = function() {
        return data.library; 
    };    

    factory.setLibrary = function(library) {
        data.library = library;
    };

    factory.getSearch = function() {
        return data.search; 
    };    

    factory.setSearch = function(search) {
        data.search = search;
    };

    factory.getYearExtent = function() {
        return data.yearExtent; 
    };    

    factory.setYearExtent = function(yearExtent) {
        angular.copy(yearExtent, data.yearExtent);
    };
    
    return factory; 
  }]);
