'use strict';

/**
 * @ngdoc function
 * @name ubrGeoApp.controller:MapsCtrl
 * @description
 * # MapsCtrl
 * Controller of the ubrGeoApp
 */
angular.module('ubrGeoApp')
  .controller('MapsCtrl', function ($scope, $http, $routeParams, $window, $location) {

    var bbox_str = $routeParams.bbox;
    if (!bbox_str) {
        bbox_str = '8.98,47.27,13.83,50.56';
    }
    var bbox     = bbox_str.split(',');
    $scope.extent = [];
    $scope.extent[0] = parseFloat(bbox[0]);
    $scope.extent[1] = parseFloat(bbox[1]);
    $scope.extent[2] = parseFloat(bbox[2]);
    $scope.extent[3] = parseFloat(bbox[3]);

    $scope.projects = [
      { short: "",       name: "alle Karten" },
      { short: "BLO",        name: "Bayerischer Landesbibliothek Online" },
      { short: "GeoPortOst", name: "GeoPortOst" },
    ];
    $scope.project = $scope.projects[0]; // alle
    
    $scope.getData = function getData(page, extent, project) {
        console.log('Projekt: ', project);
        $http.get(
	    'http://pc1011406020.uni-regensburg.de:8888/map/list?bbox=' + 
                   extent.join(',') +
                   '&page=' + page
                   + '&project=' + project.short
        ).success(function(data) {  
            $scope.maps = data.maps;
            $scope.totalMaps = data.maps_total;
            $scope.currentPage = parseInt(data.page);    
        });
    }  

    $scope.hover = function(map) {
         var boundary_id = map.map_id;
         $http.get('http://pc1011406020.uni-regensburg.de:8888/map/' + boundary_id + '/boundary').success(function( data ) {
            var vectorLayer = $scope.vectorLayer;
            var olMap = $scope.olMap;
             if ( typeof vectorLayer !== "undefined" ) {
                 olMap.removeLayer(vectorLayer)
             }
             var geojsonSource = new ol.source.GeoJSON({
                 projection: 'EPSG:3857',
                 'object': data
             });
             vectorLayer = new ol.layer.Vector({
                 source: geojsonSource
             });
             olMap.addLayer(vectorLayer);
             $scope.vectorLayer = vectorLayer;
         });
       }

    $scope.leave = function() {
        var vectorLayer = $scope.vectorLayer;
        var olMap = $scope.olMap;
        if ( typeof vectorLayer !== "undefined" ) {
            olMap.removeLayer(vectorLayer)
        }
    }

    $scope.open = function(map) {
        var map_id = map.map_id;
        var olMap = $scope.olMap;
        var view = olMap.getView();
        var center = view.getCenter();
        var x = center[0];
        var y = center[1];
        $http.get('http://pc1011406020.uni-regensburg.de:8888/map/' 
                + map_id + '/geotransform' + '?x=' + x + '&y=' + y 
                + '&invers=1&srid=3857'
        ).success(function(data) {
            $scope.pixel_x = data.pixel[0];
            $scope.pixel_y = data.pixel[1];
            var pid = map.pid;
            $scope.pid = pid;
            if (pid) {
                var url = 'http://bvbm1.bib-bvb.de/webclient/DeliveryManager'
                    + '?custom_att_2=simple_viewer&pid='
                    + pid 
                    + '&x=' + $scope.pixel_x + '&y=' + $scope.pixel_y +  '&res=2';
                $location.path('/map/'+ map_id);
            } else {
               alert('Karte nicht online');
            }
        });
    }

    $scope.pageChanged = function(newpage) {
        $scope.getData(newpage,$scope.extent,$scope.project);
    } 
    $scope.pageChanged(1);

//    $scope.change = function() {
//        console.log('Changed: ', $scope.project);
//        $scope.getData(1, $scope.extent,$scope.project);
//    }
//    $scope.$watch($scope.Data, function() {
//        console.log('Data in maps: ', $scope.Data.project);    
//    });

//
//    $scope.mapEntered = function() {
//    	console.log('Map entered');
//        var olMap = $scope.olMap;
//        var view  = olMap.getView();
//        $scope.changekeyres = view.on('change:resolution', function(evt) {
//            console.log('Resolution: ', view.getResolution() );
//            console.log('Resolution(evt): ', evt.target.getResolution() ); 
//            var extent_3857 = view.calculateExtent( olMap.getSize() );
//            console.log('Extent (3857): ', extent_3857);
//            $scope.extent = ol.proj.transformExtent(extent_3857, 'EPSG:3857', 'EPSG:4326');
//            console.log('Resolution changed: ', $scope.extent);
//            $scope.currentPage = 1;
//            getData($scope.currentPage, $scope.extent)
//        });
//        $scope.changekeyctr = view.once('change:center', function(evt) {
//            console.log('Center: ', view.getCenter() );
//            console.log('Center(evt): ', evt.target.getCenter() ); 
//            var extent_3857 = view.calculateExtent( olMap.getSize() );
//            console.log('Extent (3857): ', extent_3857);
//            $scope.extent = ol.proj.transformExtent(extent_3857, 'EPSG:3857', 'EPSG:4326');
//            console.log('Center changed: ', $scope.extent);
//            $scope.currentPage = 1;
//            getData($scope.currentPage, $scope.extent);
//        });
//    }          
//
//    $scope.mapLeft = function() {
//        //console.log('mapleft');
//        $scope.olMap.getView().unByKey($scope.changekeyres);
//        $scope.olMap.getView().unByKey($scope.changekeyctr);
//        console.log('unregister event');
//    }
//

//    $scope.$watch('extent', function() {
//         console.log('Extent has changed: ', $scope.extent);
//         getData($scope.currentPage, $scope.extent);
//    });

  });
