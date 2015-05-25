'use strict';

/**
 * @ngdoc directive
 * @name ngMapApp.directive:olMapDetail
 * @description
 * # olMapDetail
 */

/*global ol, Spinner, alert*/

angular.module('ngMapApp')
  .directive('olMapDetail', [ '$routeParams', 'mapService', 'tileService', 
          'libraryService',
          function ($routeParams, mapService, tileService, libraryService) {
    return {
      template: '<div></div>',
      restrict: 'E',
      link: function postLink(scope, element) {
        var opts = {
          lines: 13, // The number of lines to draw
          length: 20, // The length of each line
          width: 10, // The line thickness
          radius: 30, // The radius of the inner circle
          corners: 1, // Corner roundness (0..1)
          rotate: 0, // The rotation offset
          direction: 1, // 1: clockwise, -1: counterclockwise
          color: '#000', // #rgb or #rrggbb or array of colors
          speed: 1, // Rounds per second
          trail: 60, // Afterglow percentage
          shadow: false, // Whether to render a shadow
          hwaccel: false, // Whether to use hardware acceleration
          className: 'spinner', // The CSS class to assign to the spinner
          zIndex: 2e9, // The z-index (defaults to 2000000000)
          top: '50%', // Top position relative to parent
          left: '50%' // Left position relative to parent
        };
        var target = document.getElementById('map-container');
        var spinner = new Spinner(opts).spin(target);
        mapService.getTitle(scope.mapId).then(function(data){ 
          var pid = data.detail.pid;
          var library = libraryService.getLibrary(data.detail.isil);
          scope.isbd = data.detail.isbd;
          scope.exemplar = data.detail.exemplar;
          tileService.getInfo(pid).then(function(data){
            var imgHeight = data.imgHeight;
            var imgWidth  = data.imgWidth;
            var maxZoom   = data.maxZoom;
            var filename = data.filename;
            var url = 'http://digital.bib-bvb.de/ImageServer/mytile.jsp?filename=';
            url = url + filename + '&zoom={z}&x={x}&y={y}&rotation=0';
            var source = new ol.source.XYZ({
              url : url,
              wrapX: false,
              crossOrigin: null,
              attributions: [
                  new ol.Attribution({
                      html: 'Kacheln: <a href="http://www.bib-bvb.de/">Bibliotheksverbund Bayern,</a>'
                  }),
                  new ol.Attribution({
                      html: 'Karte: <a href="'+ library.url + '">' + library.name + '</a>'
                  }),
              ],
            });
            var layer = new ol.layer.Tile({
              source: source,
            });
            var map = new ol.Map({
              target: element[0],
              layers: [
                layer
              ],
              controls: [
                  new ol.control.Zoom(),
                  new ol.control.Attribution({
                      collapsed: false,
                  }),
              ],
              view: new ol.View({
                maxZoom: maxZoom
              })
            });
            source.on('tileloadend', function() {
              spinner.stop();  
            });
            // console.log('RouteParams: ', $routeParams);
            // extent of the whole world in pseudo mercator projection
            // calculated from WGS 84 (lat: -180° .. 180° lon: -85° .. 85°)    
            var extent = ol.proj.transformExtent([-180,-85,180,85], 'EPSG:4326','EPSG:3857');
          
            // the origin of the map content is the upper left corner 
            // tile size is calculated from max zoom level and size of a single tile          
            var tileSize = 256; // [px]
            var $tileSizeTot = Math.pow(2, maxZoom) * tileSize;
            var mapSize = map.getSize();  // The size in pixels of the map in the DOM.
            var view = map.getView();      // The view that controls this map.

            console.log('maxZoom: ',maxZoom);
            console.log('maxZoom: ', view.getProperties());
            if ($routeParams.x && $routeParams.y) {
                // console.log('Parameter x gefunden');
                var xPixel = $routeParams.x;
                var yPixel = $routeParams.y;
                // console.log('Extent: ', extent);
                // console.log('tileSizeTot ', $tileSizeTot);
                var xMap = extent[0] + (extent[2] - extent[0]) * xPixel / $tileSizeTot;
                var yMap = extent[3] - (extent[3] - extent[1]) * yPixel / $tileSizeTot;
                // console.log('Map: ', xMap, yMap);
                view.setCenter([xMap, yMap]);
                view.setZoom(maxZoom - 1);
            } else if (
                    $routeParams.x1 && $routeParams.y1 && $routeParams.x2 && $routeParams.y2 && $routeParams.contains === 'true'
                    ) {
                var x1Pixel = $routeParams.x1;
                var y1Pixel = $routeParams.y1;
                var x2Pixel = $routeParams.x2;
                var y2Pixel = $routeParams.y2;
                // console.log('Extent: Pixel: ', [x1Pixel,y1Pixel,x2Pixel,y2Pixel]);
                // console.log('Map: Pixel: ', imgWidth, imgHeight);
                // console.log('Extent: ', extent);
                // console.log('tileSizeTot ', $tileSizeTot);
                var x1Map = extent[0] + (extent[2] - extent[0]) * x1Pixel / $tileSizeTot;
                var y1Map = extent[3] - (extent[3] - extent[1]) * y1Pixel / $tileSizeTot;
                var x2Map = extent[0] + (extent[2] - extent[0]) * x2Pixel / $tileSizeTot;
                var y2Map = extent[3] - (extent[3] - extent[1]) * y2Pixel / $tileSizeTot;
                // console.log('Extent: Map: ', [x1Map,y1Map,x2Map,y2Map]);
                view.fitExtent([x1Map,y1Map,x2Map,y2Map], mapSize);
//                console.log('Zoom: ', view.getZoom());
            } else {
            
              var $mapWidth  = (extent[2] - extent[0]) * imgWidth  / $tileSizeTot;
              var $mapHeight = (extent[3] - extent[1]) * imgHeight / $tileSizeTot;
    
              // map center
              

              var xCenter, yCenter;
//              if ($routeParams.x1 && $routeParams.y1 && $routeParams.x2 && $routeParams.y2) {
//                var x1Pixel = $routeParams.x1;
//                var y1Pixel = $routeParams.y1;
//                var x2Pixel = $routeParams.x2;
//                var y2Pixel = $routeParams.y2;
//                console.log('Extent: Pixel: ', [x1Pixel,y1Pixel,x2Pixel,y2Pixel]);
//                console.log('Map: Pixel: ', imgWidth, imgHeight);
//                xCenter = parseFloat(x1Pixel) + (parseFloat(x2Pixel) - parseFloat(x1Pixel))/2;                 
//                yCenter = parseFloat(y1Pixel) - (parseFloat(y1Pixel) - parseFloat(y2Pixel))/2;
//                console.log('Center: ', xCenter, yCenter);    
//                
//                xCenter = extent[0] + (extent[2] - extent[0]) * xCenter / $tileSizeTot;
//                yCenter = extent[3] - (extent[3] - extent[1]) * yCenter / $tileSizeTot;
//                console.log('Center: ', xCenter, yCenter);    
//              } else {
                xCenter = extent[0] + $mapWidth  / 2;
                yCenter = extent[3] - $mapHeight / 2;
//              }    
     
              // calculate extent of the map  
              extent[2] = extent[0] + $mapWidth;
              extent[1] = extent[3] - $mapHeight;
             
              view.fitExtent(extent, mapSize);
              view.setCenter([xCenter,yCenter]);
            }  
//            map.on('pointermove', function(event) {
//              var coord3857 = event.coordinate;
//              var coord4326 = ol.proj.transform(coord3857, 'EPSG:3857', 'EPSG:4326');
//              $('#mouse3857').text(ol.coordinate.toStringXY(coord3857, 2));
//              $('#mouse4326').text(ol.coordinate.toStringXY(coord4326, 4));
//            });
            view.on('change:resolution', function() { 
                console.log('Zoom: ', view.getZoom());
            }); 

          }, function(error){
            console.log('ERRROR: ', error);
            alert('Fehler: ' + error);
          });
        });
      }
    };
  }]);
