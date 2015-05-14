'use strict';

/**
 * @ngdoc function
 * @name ngMapApp.controller:MapsCtrl
 * @description
 * # MapsCtrl
 * Controller of the ngMapApp
 */
angular.module('ngMapApp')
  .controller('MapsCtrl', ['$scope', '$routeParams', '$location',
        'mapService', 'searchParams', 'thumbnailURL',                    
    function (
        $scope, $routeParams, $location, mapService, 
        searchParams, thumbnailURL ) {

    // get the bounding box paramter and build an array of coords 
    var bboxStr = $routeParams.bbox;
    var bbox = [];
    if (bboxStr) {
        bbox  = bboxStr.split(',');
        bbox = bbox.map(function(coord){
            return parseFloat(coord);
        });
        searchParams.setExtent(bbox);
    }
   

    $scope.getMaps = function(){
      mapService.getList().then(
          function(data){ 
              $scope.maps = data.maps;
              $scope.currentPage = data.page;
              $scope.totalMaps = data.maps_total;
              angular.forEach($scope.maps, function(map) {
                  map.icon = thumbnailURL(map.pid);
              });    
          }
      );
    } 

    $scope.pageChanged = function() {
        searchParams.setPage($scope.currentPage);
        $scope.getMaps();
    }

    $scope.hover = function(map) {
        mapService.getBoundary(map.map_id).then(
            function(geoJSON){ 
                $scope.addVectorLayer(geoJSON)   
        });
    }

    $scope.leave = function() {
        $scope.removeVectorLayer();
    }
    
    $scope.open = function(map) {
        var mapId = map.map_id;
        $scope.$emit('ChangedMap', mapId); 
        console.log('Search: ', $location.search());
        var searchObj = $location.search();
        if (searchObj.x && searchObj.y) {
          mapService.getCoord(mapId,searchObj.x,searchObj.y,31468).then(
            function(data){
              console.log(data);
              var pixel = data.pixel;
              $location.path('/map/'+ mapId); 
              $location.search({ x: pixel[0], y: pixel[1] });
              console.log($location.absUrl());
            }
          );
            
        } else {
            $location.path('/map/'+ mapId);
        }
    }

    $scope.$on('ChangedProject', function (event, project) {
        $scope.getMaps();
    });

    $scope.$on('ChangedLibrary', function (event, library) {
        $scope.getMaps();
    });

  }]);
