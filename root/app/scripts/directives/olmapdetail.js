'use strict';

/**
 * @ngdoc directive
 * @name ngMapApp.directive:olMapDetail
 * @description
 * # olMapDetail
 */
angular.module('ngMapApp')
  .directive('olMapDetail', function ($routeParams, mapService, tileService) {
    return {
      template: '<div></div>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        mapService.getPid(scope.mapId).then(function(data){ 
          var pid = data.detail.pid;
          tileService.getInfo(pid).then(function(data){
            var imgHeight = data.imgHeight;
            var imgWidth  = data.imgWidth;
            var maxZoom   = data.maxZoom;
            var filename = data.filename;
            var img_projection = new ol.proj.Projection({
              code: 'pixel',
              units: 'm',
            });
            var layer = new ol.layer.Tile({
              source: new ol.source.XYZ({
                url : 'http://digital.bib-bvb.de/ImageServer/mytile.jsp?filename='
                  + filename                    
                  + '&zoom={z}&x={x}&y={y}&rotation=0',
                wrapX: false,
                crossOrigin: null
              })
            });
            var map = new ol.Map({
              target: element[0],
              layers: [
                layer
              ],
              view: new ol.View({
                zoom: maxZoom
              })
            });
           
            console.log('RouteParams: ', $routeParams);
            var tileSize = 256; // [px]
            var mapSize = map.getSize();  // The size in pixels of the map in the DOM.
            var view = map.getView();      // The view that controls this map.
            // extent of the whole world in pseudo mercator projection
            // calculated from WGS 84 (lat: -180° .. 180° lon: -85° .. 85°)    
            var extent = ol.proj.transformExtent([-180,-85,180,85], 'EPSG:4326','EPSG:3857');
          
            // the origin of the map content is the upper left corner 
            // tile size is calculated from max zoom level and size of a single tile          
            var $tileSizeTot = Math.pow(2, maxZoom) * tileSize;
          
            var $mapWidth  = (extent[2] - extent[0]) * imgWidth  / $tileSizeTot;
            var $mapHeight = (extent[3] - extent[1]) * imgHeight / $tileSizeTot;
  
            // map center 
            var xCenter = extent[0] + $mapWidth  / 2;
            var yCenter = extent[3] - $mapHeight / 2;
  
            // calculate extent of the map  
            extent[2] = extent[0] + $mapWidth;
            extent[1] = extent[3] - $mapHeight;
           
            view.fitExtent(extent, mapSize);
            view.setCenter([xCenter,yCenter]);
            map.on('pointermove', function(event) {
              var coord3857 = event.coordinate;
              var coord4326 = ol.proj.transform(coord3857, 'EPSG:3857', 'EPSG:4326');
              $('#mouse3857').text(ol.coordinate.toStringXY(coord3857, 2));
              $('#mouse4326').text(ol.coordinate.toStringXY(coord4326, 4));
            });
          });
        });
      }
    };
  });
