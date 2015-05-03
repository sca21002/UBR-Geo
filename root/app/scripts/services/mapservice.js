'use strict';

/**
 * @ngdoc service
 * @name ubrGeoApp.mapservice
 * @description
 * # mapservice
 * Factory in the ubrGeoApp.
 */
angular.module('ubrGeoApp')
  .factory('mapservice', function () {
    // Service logic
    // ...

    var meaningOfLife = 42;

    // Public API here
    return {
      someMethod: function () {
        return meaningOfLife;
      }
    };
  });
