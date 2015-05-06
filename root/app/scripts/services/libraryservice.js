'use strict';

/**
 * @ngdoc service
 * @name ngMapApp.libraryService
 * @description
 * # libraryService
 * Factory in the ngMapApp.
 */
angular.module('ngMapApp')
  .factory('libraryService', function () {

    var libraries = [
      { isil: "",                 name: "alle Bibl." },
      { isil: "DE-355",           name: "UB Regensburg" },
      { isil: "DE-12",            name: "BSB" },
      { isil: "DE-70",            name: "LB Coburg" },
      { isil: "DE-Re13",          name: "IOS" },
      { isil: "DE-155",           name: "SB Regensburg" },
      { isil: "DE-29",            name: "UB Erlangen" },
    ];

    var factory = {};

    factory.load = function () {
      return libraries;         
    };

    factory.default = function () {
      return libraries[0];    
    };    

    return factory;
  });
