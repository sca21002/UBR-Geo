'use strict';

/**
 * @ngdoc function
 * @name ubrGeoApp.controller:MapsCtrl
 * @description
 * # MapsCtrl
 * Controller of the ubrGeoApp
 */
angular.module('ubrGeoApp')
  .controller('MapsCtrl', function ($scope, $http, $routeParams, $timeout) {

    var bbox_str = $routeParams.bbox; 
    var bbox     = bbox_str.split(',');
    $scope.extent = [];
    $scope.extent[0] = parseFloat(bbox[0]);
    $scope.extent[1] = parseFloat(bbox[1]);
    $scope.extent[2] = parseFloat(bbox[2]);
    $scope.extent[3] = parseFloat(bbox[3]);
    console.log('MapsCtrl: ', $scope.extent);

    $scope.currentPage = 1;
    //$scope.oldPage = 0;

    function getData(page, extent) {
        $http.get(
	    'http://pc1011406020.uni-regensburg.de:8888/map/list?bbox=' + 
                   extent.join(',') +
                   '&page=' + page 
        ).success(function(data) {  
            console.log('Got new data for: ', extent);
            $scope.maps = data.maps;
            $scope.totalMaps = data.maps_total;
            $scope.currentPage = parseInt(data.page);    
        });
    }  

    $scope.hover = function(map) {
        // console.log(map);
        var boundary_id = map.map_id;
        // console.log(boundary_id);


        $http.get('http://pc1011406020.uni-regensburg.de:8888/map/' + boundary_id + '/boundary').success(function( data ) {
           var vectorLayer = $scope.vectorLayer;
           var olMap = $scope.olMap;
            if ( typeof vectorLayer !== "undefined" ) {
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

      $scope.leave = function() {
          console.log('table left: ', $scope.extent);
          var extent_3857 = ol.proj.transformExtent($scope.extent, 'EPSG:4326', 'EPSG:3857');
          console.log('in leave: ', extent_3857);
          var olMap = $scope.olMap;
          var vectorLayer = $scope.vectorLayer;
          if ( typeof vectorLayer !== "undefined" ) {
              olMap.removeLayer(vectorLayer)
          }
          var view = olMap.getView();
          var size = olMap.getSize();
          view.fitExtent(extent_3857,size);
          extent_3857 = view.calculateExtent( size );
          console.log('fit extent (3857): ',  extent_3857); 
          var extent_4326 = ol.proj.transformExtent(extent_3857, 'EPSG:3857', 'EPSG:4326');
          var resolution = view.getResolution();
          console.log('fit extent: ', extent_4326, ' res: ', resolution);
      }

      $scope.pageChanged = function(newpage) {
          // console.log('current: ', $scope.currentPage);
          //if ($scope.currentPage !== newpage) {
              //getData(newpage,2.98,47.27,13.83,50.56);
              console.log('get new data in page_changed');
              getData(newpage,$scope.extent);
          //}
      } 

    $scope.mapEntered = function() {
    	console.log('Map entered');
        var olMap = $scope.olMap;
        var view  = olMap.getView();
        $scope.changekeyres = view.on('change:resolution', function(evt) {
            console.log('Resolution: ', view.getResolution() );
            console.log('Resolution(evt): ', evt.target.getResolution() ); 
            var extent_3857 = view.calculateExtent( olMap.getSize() );
            console.log('Extent (3857): ', extent_3857);
            $scope.extent = ol.proj.transformExtent(extent_3857, 'EPSG:3857', 'EPSG:4326');
            console.log('Resolution changed: ', $scope.extent);
            $scope.currentPage = 1;
            getData($scope.currentPage, $scope.extent)
        });
        $scope.changekeyctr = view.once('change:center', function(evt) {
            console.log('Center: ', view.getCenter() );
            console.log('Center(evt): ', evt.target.getCenter() ); 
            var extent_3857 = view.calculateExtent( olMap.getSize() );
            console.log('Extent (3857): ', extent_3857);
            $scope.extent = ol.proj.transformExtent(extent_3857, 'EPSG:3857', 'EPSG:4326');
            console.log('Center changed: ', $scope.extent);
            $scope.currentPage = 1;
            getData($scope.currentPage, $scope.extent);
        });
    }          

    $scope.mapLeft = function() {
        //console.log('mapleft');
        $scope.olMap.getView().unByKey($scope.changekeyres);
        $scope.olMap.getView().unByKey($scope.changekeyctr);
        console.log('unregister event');
    }


//    $scope.$watch('extent', function() {
//         console.log('Extent has changed: ', $scope.extent);
//         getData($scope.currentPage, $scope.extent);
//    });

  });
