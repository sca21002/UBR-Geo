'use strict';

/**
 * @ngdoc service
 * @name ubrGeoApp.mapservice
 * @description
 * # mapservice
 * Factory in the ubrGeoApp.
 */
angular.module('ubrGeoApp')
  .factory('mapservice', function ($q, $http, searchParams) {

    var factory = {};
    var urlBase = 'http://pc1011406020.uni-regensburg.de/ubr/geo-srv';
//    var urlBase = 'http://pc1011406020.uni-regensburg.de:8888';

    factory.getList = function () {

        var extent = searchParams.getCenter().bounds;
        var page   = searchParams.getPage();
        var project = searchParams.getProject();
        var library = searchParams.getLibrary();
        var yearExtent = searchParams.getYearExtent();

        // Creating a deffered object
        var deferred = $q.defer();

        var url = urlBase + '/map/list?bbox=' + extent.join(',');
        if (page) { url = url + '&page=' + page; }
        if (project) { url = url + '&project=' + project; }
        if (library) { url = url + '&isil=' + library; }
        if (yearExtent && yearExtent[0] && yearExtent[1]) {
            console.log('YearExtent: ', yearExtent);
            url = url + '&year_min=' + yearExtent[0] + '&year_max=' + yearExtent[1];
        }

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

    factory.getYearRange = function() {
      // Creating a deffered object
      var deferred = $q.defer();
      
      var url = urlBase + '/statistics/maps-per-year';
      $http.get(url).success(function(data) {  
          //Passing data to deferred's resolve function on successful completion
          deferred.resolve(data);
        }).error(function(){
          //Sending a friendly error message in case of failure
          deferred.reject('An error occured while processing getYearRange');
        });
        
      //Returning the promise object
      return deferred.promise;
    };

    return  factory;
  });
