'use strict';

/**
 * @ngdoc service
 * @name ubrGeoApp.tileService
 * @description
 * # tileService
 * Factory in the ubrGeoApp.
 */
angular.module('ubrGeoApp')
  .factory('tileService', function ($http, $q) {
  
    var factory = {};
    
    factory.getInfo = function(pid) {
      
      // Creating a deffered object
      var deferred = $q.defer();
      
      $http.get(
        'http://digipool.bib-bvb.de/bvb/anwender/CORS/get_imageinfo.pl?pid=' + pid
        ).success(function(data) { 
          //Passing data to deferred's resolve function on successful completion
          deferred.resolve(data);
        }).error(function(){
          console.log('An error detected');
          //Sending a friendly error message in case of failure
          deferred.reject('Keine Infos zur Karte mit der PID "'+ pid + '"');
        });
        
      //Returning the promise object
      return deferred.promise;
    };

    return factory;
  });
