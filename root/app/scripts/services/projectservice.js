'use strict';

/**
 * @ngdoc service
 * @name ubrGeoApp.projectService
 * @description
 * # projectService
 * Factory in the ubrGeoApp.
 */
angular.module('ubrGeoApp')
  .factory('projectService', function () {

    var projects = [
      { short: 'BLO',        name: 'BLO' },
      { short: 'GeoPortOst', name: 'GeoPortOst' },
    ];
              
    var factory = {};

    factory.load = function () {
      return projects;         
    };

    factory.default = function () {
      return '';    
    };    

    return factory;
  });
