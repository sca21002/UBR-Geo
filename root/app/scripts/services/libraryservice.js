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
      { isil: 'DE-355',           name: 'UB Regensburg' },
      { isil: 'DE-12',            name: 'BSB' },
      { isil: 'DE-70',            name: 'LB Coburg' },
      { isil: 'DE-Re13',          name: 'IOS' },
      { isil: 'DE-155',           name: 'SB Regensburg' },
      { isil: 'DE-29',            name: 'UB Erlangen' },
    ];

    var holding = { 
      'DE-355': {name: 'Universtätsbibliothek Regensburg', url: 'http://www.uni-regensburg.de/bibliothek/'},
      'DE-12':  {name: 'Bayerische Staatsbibliothek', url: 'https://www.bsb-muenchen.de/'},
      'DE-70':  {name: 'Landesbibliothek Coburg', url: 'http://www.landesbibliothek-coburg.de/'},
      'DE-Re13': {name: 'Institut für Ost- und Südosteuropaforschung', url: 'http://www.ios-regensburg.de/'},
      'DE-155': {name: 'Staatliche Bibliothek Regensburg', url: 'https://www.staatliche-bibliothek-regensburg.de/'},
      'DE-29':  {name: 'Universitätsbibliothek Erlangen-Nürnberg', url: 'http://www.ub.uni-erlangen.de/'},
    };

    var factory = {};

    factory.load = function () {
      return libraries;         
    };

    factory.default = function () {
      return '';    
    };    

    factory.getLibrary = function(isil) {
        return holding[isil];
    };    

    return factory;
  });
