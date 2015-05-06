'use strict';

/**
 * @ngdoc service
 * @name ngMapApp.projectService
 * @description
 * # projectService
 * Factory in the ngMapApp.
 */
angular.module('ngMapApp')
  .factory('projectService', function () {

    var projects = [
      { short: "",           name: "alle Karten" },
      { short: "BLO",        name: "BLO" },
      { short: "GeoPortOst", name: "GeoPortOst" },
    ];
              
    var factory = {};

    factory.load = function () {
      return projects;         
    };

    factory.default = function () {
      return projects[0];    
    };    

    return factory;
  });
