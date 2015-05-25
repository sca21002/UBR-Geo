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
    var urlBase = 'http://pc1011406020.uni-regensburg.de/ubr/geo-srv';


    factory.getList = function () {

        // Creating a deffered object
        var deferred = $q.defer();

        var extent  = searchParams.getExtent();
        var page    = searchParams.getPage();
        var project = searchParams.getProject();
        var library = searchParams.getLibrary();

        var url = urlBase + '/map/list?bbox=' + extent.join(',');
        if (page) { url = url + '&page=' + page; }
        if (project) { url = url + '&project=' + project; }
        if (library) { url = url + '&isil=' + library; }


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

        var url = urlBase + '/map/' + mapId + '/boundary';

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
      
      var url = urlBase + '/map/' + mapId + '/detail';

      $http.get(url).success(function(data) {  
          //Passing data to deferred's resolve function on successful completion
          deferred.resolve(data);
        }).error(function(){
          //Sending a friendly error message in case of failure
          deferred.reject('An error occured while fetching the pid');
        });
        
      //Returning the promise object
      return deferred.promise;
    };

    factory.getCoord = function(mapId, x, y, srid) {
      // Creating a deffered object
      var deferred = $q.defer();
      
      var url = urlBase + '/map/' + mapId + '/geotransform?x=';
      url = url + x + '&y=' + y + '&srid=' + srid + '&invers=1';
      $http.get(url).success(function(data) {  
          //Passing data to deferred's resolve function on successful completion
          deferred.resolve(data);
        }).error(function(){
          //Sending a friendly error message in case of failure
          deferred.reject('An error occured while fetching coordinates');
        });
        
      //Returning the promise object
      return deferred.promise;
    };

    factory.getCoords = function(mapId, x1, y1, x2, y2, srid) {
      // Creating a deffered object
      var deferred = $q.defer();
      
      var url = urlBase + '/map/' + mapId + '/geotransform2';
      url = url + '?x1=' + x1 + '&y1=' + y1;
      url = url + '&x2=' + x2 + '&y2=' + y2;
      url = url + '&srid=' + srid + '&invers=1';
      $http.get(url).success(function(data) {  
          //Passing data to deferred's resolve function on successful completion
          deferred.resolve(data);
        }).error(function(){
          //Sending a friendly error message in case of failure
          deferred.reject('An error occured while fetching coordinates');
        });
        
      //Returning the promise object
      return deferred.promise;
    };

    factory.contains = function(mapId, x, y) {
      // Creating a deffered object
      var deferred = $q.defer();
      
      var url = urlBase + '/map/' + mapId + '/contains';
      url = url + '?x=' + x + '&y=' + y;
      $http.get(url).success(function(data) {  
          //Passing data to deferred's resolve function on successful completion
          deferred.resolve(data);
        }).error(function(){
          //Sending a friendly error message in case of failure
          deferred.reject('An error occured while processing contains');
        });
        
      //Returning the promise object
      return deferred.promise;
    };

    return  factory;
  }]);
