'use strict';

/**
 * @ngdoc service
 * @name ngMapApp.mapService
 * @description
 * # mapService
 * Factory in the ngMapApp.
 */
angular.module('ngMapApp')
  .factory('mapService', function($http, $q, searchParams) {

    var factory = {};

    factory.getList = function () {

        // Creating a deffered object
        var deferred = $q.defer();

        var extent  = searchParams.getExtent();
        var page    = searchParams.getPage();
        var project = searchParams.getProject();
        var library = searchParams.getLibrary();

        var url = 'http://pc1011406020.uni-regensburg.de:8888/map/list?bbox=' 
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

        var url = 'http://pc1011406020.uni-regensburg.de:8888/map/' + mapId + '/boundary';

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

    factory.getPid = function(mapId) {
      // Creating a deffered object
      var deferred = $q.defer();
      
      $http.get(
        'http://pc1011406020.uni-regensburg.de:8888/map/' +  
         + mapId + '/detail'    
        ).success(function(data) {  
          //Passing data to deferred's resolve function on successful completion
          deferred.resolve(data);
        }).error(function(){
          //Sending a friendly error message in case of failure
          deferred.reject("An error occured while fetching the pid");
        });
        
      //Returning the promise object
      return deferred.promise;
    }

    return  factory;
  });
