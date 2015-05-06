'use strict';

/**
 * @ngdoc service
 * @name ngMapApp.searchParams
 * @description
 * # searchParams
 * Factory in the ngMapApp.
 */
angular.module('ngMapApp')
  .factory('searchParams', function (projectService, libraryService) {

    var data = {
        extent:  [8.98,47.27,13.83,50.56],
        page: 1,
        project: projectService.default(),
        library: libraryService.default()
    };
    
    var factory = {};

    factory.getExtent = function() {
        return data.extent;
    };

    factory.setExtent = function(extent) {
        data.extent = extent;
    };

    factory.getPage = function() {
        return data.page;
    };

    factory.setPage = function(page) {
        data.page = page;
    };

    factory.getProject = function() {
        return data.project; 
    }    

    factory.setProject = function(project) {
        data.project = project;
    }    

    factory.getLibrary = function() {
        return data.library; 
    }    

    factory.setLibrary = function(library) {
        data.library = library;
    }
    
    return factory; 
  });
