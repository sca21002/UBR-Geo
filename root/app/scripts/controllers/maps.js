'use strict';

/**
 * @ngdoc function
 * @name ubrGeoApp.controller:MapsCtrl
 * @description
 * # MapsCtrl
 * Controller of the ubrGeoApp
 */
angular.module('ubrGeoApp')
  .controller('MapsCtrl', function ($scope, $http) {
      $http.get('http://pc1011406020.uni-regensburg.de:8888/map/list').success(function(data) {  
              $scope.maps = data.maps;
              $scope.totalMaps = data.maps_total;
              $scope.currentPage = 1;    
      });

      $scope.hover = function(map) {
        console.log(map);
        var boundary_id = map.map_id;
        console.log(boundary_id);
        $http.get('http://pc1011406020.uni-regensburg.de:8888/map/' + boundary_id + '/boundary').success(function( data ) {
           var ol_map = $scope.ol_map;
           var vectorLayer = $scope.vectorLayer;
            if ( typeof vectorLayer != "undefined" ) {
                ol_map.removeLayer(vectorLayer)
            }
            console.log(data);
            var geojsonSource = new ol.source.GeoJSON({
                projection: 'EPSG:3857',
                'object': data
            });
            vectorLayer = new ol.layer.Vector({
                source: geojsonSource
            });
            ol_map.addLayer(vectorLayer);
            var extent = geojsonSource.getExtent();
            ol_map.getView().fitExtent(extent, ol_map.getSize());
            $scope.vectorLayer = vectorLayer;
        });
      }


  });
