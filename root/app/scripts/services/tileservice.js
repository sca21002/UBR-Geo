'use strict';

/**
 * @ngdoc service
 * @name ngMapApp.tileService
 * @description
 * # tileService
 * Factory in the ngMapApp.
 */
angular.module('ngMapApp')
  .factory('tileService', function ($http,$q) {
  
    var factory = {};
    
    factory.getInfo = function(pid) {
      
      // Creating a deffered object
      var deferred = $q.defer();
      
      $http.get(
        'http://digipool.bib-bvb.de/bvb/anwender/CORS/get_imageinfo.pl?pid='
            + pid
        ).success(function(data) {  
          //Passing data to deferred's resolve function on successful completion
          deferred.resolve(data);
        }).error(function(){
          //Sending a friendly error message in case of failure
          deferred.reject("An error occured while fetching items");
        });
        
      //Returning the promise object
      return deferred.promise;
    };

    return factory;

  });
