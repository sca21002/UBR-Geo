'use strict';

/**
 * @ngdoc function
 * @name ngMapApp.controller:MapsCtrl
 * @description
 * # MapsCtrl
 * Controller of the ngMapApp
 */
angular.module('ngMapApp')
  .controller('MapsCtrl', 
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
        var map_id = map.map_id;
//        var olMap = $scope.olMap;
//        var view = olMap.getView();
//        var center = view.getCenter();
//        var x = center[0];
//        var y = center[1];
//        $http.get('http://pc1011406020.uni-regensburg.de:8888/map/' 
//                + map_id + '/geotransform' + '?x=' + x + '&y=' + y 
//                + '&invers=1&srid=3857'
//        ).success(function(data) {
//            $scope.pixel_x = data.pixel[0];
//            $scope.pixel_y = data.pixel[1];
//            var pid = map.pid;
//            $scope.pid = pid;
//            if (pid) {
//                var url = 'http://bvbm1.bib-bvb.de/webclient/DeliveryManager'
//                    + '?custom_att_2=simple_viewer&pid='
//                    + pid 
//                    + '&x=' + $scope.pixel_x + '&y=' + $scope.pixel_y +  '&res=2';
                $scope.$emit('ChangedMapId', map_id);     
                $location.path('/map/'+ map_id);
//            } else {
//               alert('Karte nicht online');
//            }
//        });
    }

    $scope.$on('ChangedProject', function (event, project) {
        $scope.getMaps();
    });

    $scope.$on('ChangedLibrary', function (event, library) {
        $scope.getMaps();
    });

  });
