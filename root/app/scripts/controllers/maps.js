'use strict';

/**
 * @ngdoc function
 * @name ngMapApp.controller:MapsCtrl
 * @description
 * # MapsCtrl
 * Controller of the ngMapApp
 */

/*global ol, proj4*/

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

    if ($routeParams.project) {
        var project = $routeParams.project;
        searchParams.setProject(project);
        $scope.$emit('ChangedProject', project);
    }
    
    if ($routeParams.library) {
        var library = $routeParams.library;
        searchParams.setLibrary(library);
        $scope.$emit('ChangedLibrary', library);
    }

    if ($routeParams.x && $routeParams.y) {
        var x = $routeParams.x;
        var y = $routeParams.y;
        console.log('x: ', x, ' y: ', y);
        proj4.defs('EPSG:31468','+proj=tmerc +lat_0=0 +lon_0=12 +k=1 +x_0=4500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs');
        var coord3857 = ol.proj.transform([x,y], 'EPSG:31468', 'EPSG:3857');        
        console.log(coord3857);
        searchParams.setCenter(coord3857);
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
    }; 

    $scope.pageChanged = function() {
        searchParams.setPage($scope.currentPage);
        $scope.getMaps();
    };

    $scope.hover = function(map) {
        mapService.getBoundary(map.map_id).then(
            function(geoJSON){ 
                $scope.addVectorLayer(geoJSON);   
        });
    };

    $scope.leave = function() {
        $scope.removeVectorLayer();
    };
    
    $scope.open = function(map) {
        var mapId = map.map_id;
        $scope.$emit('ChangedMap', mapId); 
        var extent4326 = searchParams.getExtent();
        console.log('Extent(4326): ', extent4326);
        mapService.getCoords(mapId, 
                extent4326[0], extent4326[1], extent4326[2], extent4326[3], 
                4326).then(
            function(data){
                console.log(data);
                var pixel = data.pixel;
                $location.path('/map/'+ mapId);
                $location.search({ 
                    x1: pixel[0], y1: pixel[1], x2: pixel[2], y2: pixel[3] 
                });
                console.log($location.absUrl());
            }
        );
//        var searchObj = $location.search();
//        if (searchObj.x && searchObj.y) {
//          mapService.getCoord(mapId, searchObj.x, searchObj.y, 31468).then(
//            function(data){
//              console.log(data);
//              var pixel = data.pixel;
//              $location.path('/map/'+ mapId); 
//              $location.search({ x: pixel[0], y: pixel[1] });
//              console.log($location.absUrl());
//            }
//          );
//            
//        } else {
//            $location.path('/map/'+ mapId);
//        }
    };

    $scope.$on('ChangedProject', function () {
        $scope.getMaps();
    });

    $scope.$on('ChangedLibrary', function () {
        $scope.getMaps();
    });

  }]);
