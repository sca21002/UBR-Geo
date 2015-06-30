'use strict';

/**
 * @ngdoc function
 * @name ubrGeoApp.controller:MapdetailCtrl
 * @description
 * # MapdetailCtrl
 * Controller of the ubrGeoApp
 */
angular.module('ubrGeoApp')
  .controller('MapdetailCtrl', function ($scope, $q, $routeParams, libraryService, mapservice, tileService, usSpinnerService) {

    $scope.name = 'MapdetailCtrl';

    var mapId = $routeParams.mapId; 

    var extent4326 = [ 
      parseFloat($routeParams.x1), 
      parseFloat($routeParams.y1), 
      parseFloat($routeParams.x2), 
      parseFloat($routeParams.y2)
    ];
    var extent3857 = ol.proj.transformExtent(extent4326, 'EPSG:4326','EPSG:3857');
    
    var xCenter = extent3857[0] + ( extent3857[2] - extent3857[0]) /2;
    var yCenter = extent3857[1] + ( extent3857[3] - extent3857[1]) /2;

    // extent of the whole world in pseudo mercator projection
    // calculated from WGS 84 (lat: -180° .. 180° lon: -85° .. 85°)    
    var bounds3857 = ol.proj.transformExtent([-180,-85,180,85], 'EPSG:4326','EPSG:3857');

    // the origin of the map content is the upper left corner 
    var tileSize = 256; // [px]

    var filename;
    var coord = [];
    mapservice.getTitle(mapId).then(function(data){  
        var pid = data.detail.pid; 
        var library = libraryService.getLibrary(data.detail.isil); 
        $scope.isbd = data.detail.isbd; 
        $scope.exemplar = data.detail.exemplar; 
        tileService.getInfo(pid).then(function(data){
            filename = data.filename;
            var imgHeight = data.imgHeight;    
            var imgWidth  = data.imgWidth;
            var maxZoom   = data.maxZoom;

            mapservice.getCoords(mapId, 
                extent4326[0], extent4326[1], extent4326[2], extent4326[3], 4326).then(
                function(data){
                    var pixel = [];
                    angular.forEach(data.pixel, function(coord) {
                        this.push(parseFloat(coord));    
                    }, pixel);
                    mapservice.contains(mapId, xCenter, yCenter).then(function(data){
            
                        // tile size is calculated from max zoom level and size of a single tile          
                        var $tileSizeTot = Math.pow(2, maxZoom) * tileSize;
                        
                        if (data.contains) {
                            var x1Map = bounds3857[0] + (bounds3857[2] - bounds3857[0]) * pixel[0] / $tileSizeTot;
                            var y1Map = bounds3857[3] - (bounds3857[3] - bounds3857[1]) * pixel[1] / $tileSizeTot;
                            var x2Map = bounds3857[0] + (bounds3857[2] - bounds3857[0]) * pixel[2] / $tileSizeTot;
                            var y2Map = bounds3857[3] - (bounds3857[3] - bounds3857[1]) * pixel[3] / $tileSizeTot;
                            angular.copy([x1Map, y1Map, x2Map, y2Map], coord);
                        } else {
                            var x2Map = bounds3857[0] + (bounds3857[2] - bounds3857[0]) * imgWidth  / $tileSizeTot;
                            var y1Map = bounds3857[3] - (bounds3857[3] - bounds3857[1]) * imgHeight / $tileSizeTot;
                            angular.copy([bounds3857[0], y1Map, x2Map, bounds3857[3]], coord);                  
                        }
                        $scope.myextent.coord = coord;
                        $scope.bvb.visible = true;
                        $scope.bvb.source.library = library;    
                        $scope.bvb.source.filename = filename;
                        $scope.bvb.source.maxZoom = maxZoom; // seems as if it doesn't work
                    }, function(error) {
                            alert('Ein Fehler ist aufgetreten!');
                    });
            });    
        });
    });

    angular.extend($scope, {
        myextent: {
                coord: [-20026376.39, -20048966.10, 20026376.39, 20048966.10],
                projection: 'EPSG:3857'
        },
        bvb: {
            visible: false,
            source: {
                type: 'BVB',
                filename: 'L21lZGllbl9idmIvZGlnaXRvb2xfbmFzcm9vdC92b2xfQkxPXzAwMDEvMjAwOS8xMC8xNC9maWxlXzEvMjMzNjAy',
                library: {
                    url: 'test.de',
                    name: 'Test',
                },
                maxZoom: 7
            }
        },
        attrib: {
            collapsed: false
        },
        defaults: {
            view: {
                center: [0,0],
                zoom: 6,
            },
            interactions: {
                mouseWheelZoom: true
            },
            events: {
                map: [ 'pointermove', 'singleclick' ]
            },
        },
        mouseposition: {},
        projection: 'EPSG:3857'
    });

    $scope.$on('openlayers.map.pointermove', function(event, data) {
        $scope.$apply(function() {
            if ($scope.projection === data.projection) {
                $scope.mouseposition = data.coord;
            } else {
                var p = ol.proj.transform([ data.coord[0], data.coord[1] ], data.projection, $scope.projection);
                $scope.mouseposition = {
                    lat: p[1],
                    lon: p[0],
                    projection: $scope.projection
                }
            }
        });
    });


    $scope.$on('openlayers.map.singleclick', function(event, data) {
        $scope.$apply(function() {
            if ($scope.projection === data.projection) {
                $scope.mouseclickposition = data.coord;
            } else {
                var p = ol.proj.transform([ data.coord[0], data.coord[1] ], data.projection, $scope.projection);
                $scope.mouseclickposition = {
                    lat: p[1],
                    lon: p[0],
                    projection: $scope.projection
                }
            }
        });
    });

    $scope.$on('openlayers.bvb.tileloadend', function(event, data) {
        $scope.$apply(function() {
            console.log('Tile loaded');
            usSpinnerService.stop('spinner-1');
        });
    });
  });
