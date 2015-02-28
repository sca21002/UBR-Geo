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

    function getData(page,xmin,ymin,xmax,ymax) {
        $http.get(
	    'http://pc1011406020.uni-regensburg.de:8888/map/list?bbox='  
                   + xmin + ','
                   + ymin + ','
                   + xmax + ','
                   + ymax + 
                   '&page=' + page 
        ).success(function(data) {  
            $scope.maps = data.maps;
            $scope.totalMaps = data.maps_total;
            $scope.currentPage = data.page;    
        });
    }  
    //getData(1,2.98,47.27,13.83,50.56);
    getData(1,-27,18,89,64);


      $scope.hover = function(map) {
        // console.log(map);
        var boundary_id = map.map_id;
        // console.log(boundary_id);


        $http.get('http://pc1011406020.uni-regensburg.de:8888/map/' + boundary_id + '/boundary').success(function( data ) {
           var vectorLayer = $scope.vectorLayer;
           var olMap = $scope.olMap;
            if ( typeof vectorLayer != "undefined" ) {
                olMap.removeLayer(vectorLayer)
            }
            // console.log(data);
            var geojsonSource = new ol.source.GeoJSON({
                projection: 'EPSG:3857',
                'object': data
            });
            vectorLayer = new ol.layer.Vector({
                source: geojsonSource
            });
            olMap.addLayer(vectorLayer);
            var extent = geojsonSource.getExtent();
            olMap.getView().fitExtent(extent, olMap.getSize());
            $scope.vectorLayer = vectorLayer;
        });
      }

      $scope.pageChanged = function(newpage) {
          console.log('current: ', $scope.currentPage);
          console.log('In page_changed: ',newpage);
          if ($scope.currentPage != newpage) {
              //getData(newpage,2.98,47.27,13.83,50.56);
              getData(newpage,-27,18,89,64);
          }
      } 


  });
