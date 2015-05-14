'use strict';

/**
 * @ngdoc service
 * @name ngMapApp.mapService
 * @description
 * # mapService
 * Factory in the ngMapApp.
 */
angular.module('ngMapApp')
  .factory('mapService', [ '$http', '$q', 'searchParams', 
          function($http, $q, searchParams) {

    var factory = {};
    var url_base = 'http://pc1011406020.uni-regensburg.de:8888';


    factory.getList = function () {

        // Creating a deffered object
        var deferred = $q.defer();

        var extent  = searchParams.getExtent();
        var page    = searchParams.getPage();
        var project = searchParams.getProject();
        var library = searchParams.getLibrary();

        var url = url_base + '/map/list?bbox=' 
                  + extent.join(',') + '&page=' + page + '&project=' + project.short
                  + '&isil=' + library.isil;


        $http.get(url).success(function(data) {  
          //Passing data to deferred's resolve function on successful completion
          deferred.resolve(data);
        }).error(function( ){
          //Sending a friendly error message in case of failure
          deferred.reject('An error occured while fetching maps');
        });
        
        //Returning the promise object
        return deferred.promise;
    };

    factory.getBoundary = function (mapId) {

        // Creating a deffered object
        var deferred = $q.defer();

        var url = url_base + '/map/' + mapId + '/boundary';

        $http.get(url).success(function(data) {  
          //Passing data to deferred's resolve function on successful completion
          deferred.resolve(data);
        }).error(function( ){
          //Sending a friendly error message in case of failure
          deferred.reject('An error occured while fetching maps');
        });
        
        //Returning the promise object
        return deferred.promise;
    };

    factory.getTitle = function(mapId) {
      // Creating a deffered object
      var deferred = $q.defer();
      
      var url = url_base + '/map/' + mapId + '/detail';

      $http.get(url).success(function(data) {  
          //Passing data to deferred's resolve function on successful completion
          deferred.resolve(data);
        }).error(function(){
          //Sending a friendly error message in case of failure
          deferred.reject("An error occured while fetching the pid");
        });
        
      //Returning the promise object
      return deferred.promise;
    }

    factory.getCoord = function(mapId, x, y, srid) {
      // Creating a deffered object
      var deferred = $q.defer();
      
      var url = url_base + '/map/' + mapId + '/geotransform?x='
          + x + '&y=' + y + '&srid=' + srid + '&invers=1';
      $http.get(url).success(function(data) {  
          //Passing data to deferred's resolve function on successful completion
          deferred.resolve(data);
        }).error(function(){
          //Sending a friendly error message in case of failure
          deferred.reject("An error occured while fetching coordinates");
        });
        
      //Returning the promise object
      return deferred.promise;
    }

    return  factory;
  }]);
