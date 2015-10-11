'use strict';

/**
 * @ngdoc directive
 * @name ngMapApp.directive:olMap
 * @description
 * # olMap
 */

/*global ol*/

angular.module('ubrGeoApp')
  .directive('olMap', ['searchParams', 'mapboxURL', 
    function (searchParams, mapboxURL) {
    return {
      template: '',
      restrict: 'E',
      link: function postLink(scope, element) {
        var view = new ol.View({
            center: ol.proj.transform([12.053, 48.941], 'EPSG:4326', 'EPSG:3857'),
            zoom: 6,
        });
        var map = new ol.Map({
          target: element[0],
          layers: [
            new ol.layer.Tile({
              source: new ol.source.XYZ({
                  url: mapboxURL,
                  wrapX: false,
                  crossOrigin: null,
                  attributions: [
                    new ol.Attribution({
                      html: 'Tiles &copy; <a href="http://mapbox.com/">MapBox</a>'
                    }),
                    ol.source.OSM.ATTRIBUTION
                  ]
              }),
            })
          ],
          controls: [
              new ol.control.Zoom(),
              new ol.control.OverviewMap({
                  collapsed: false
              }),
              new ol.control.Attribution({
                  collapsible: false,
              }),
          ],
        view: new ol.View({
          center: ol.proj.transform([37.41, 8.82], 'EPSG:4326', 'EPSG:3857'),
          zoom: 4
        })
//          view: view,
        });

        var center = searchParams.getCenter();

        if (center.length>0) {
            view.setCenter(center);
            view.setZoom(10);
        } else {
            var extent4326 = searchParams.getExtent();
            var setExtent3857 = ol.proj.transformExtent(extent4326, 'EPSG:4326', 'EPSG:3857');
            var widthDelta  = (setExtent3857[2] - setExtent3857[0]) * 0.05; 
            var heightDelta = (setExtent3857[3] - setExtent3857[1]) * 0.05;
            setExtent3857[0] = setExtent3857[0] + widthDelta;
            setExtent3857[1] = setExtent3857[1] + heightDelta;
            setExtent3857[2] = setExtent3857[2] - widthDelta;
            setExtent3857[3] = setExtent3857[3] - heightDelta;

            var actualExtent3857 = view.calculateExtent( map.getSize() );
            var actualExtent4326 = ol.proj.transformExtent(actualExtent3857, 'EPSG:3857', 'EPSG:4326');
            searchParams.setExtent(actualExtent4326);
        }
           
        var getMaps = function(){
            var actualExtent3857 = view.calculateExtent( map.getSize() );
            var actualExtent4326 = ol.proj.transformExtent(actualExtent3857, 'EPSG:3857', 'EPSG:4326');
            searchParams.setExtent(actualExtent4326);
            var boundingbox = [];
            angular.forEach(actualExtent4326, function(coord) {
                this.push(Number(coord.toFixed(1)));
            }, boundingbox);
            scope.boundingbox = boundingbox.join(', ');
            scope.getMaps();

        };
        
         
        view.on('change:resolution', function() { getMaps(); }); 

        map.on('moveend', function() { getMaps(); });

        var vectorLayer;
        scope.addVectorLayer = function(geoJSON) {
          if ( typeof vectorLayer !=='undefined' ) {
            map.removeLayer(vectorLayer);
          }
          var geojsonSource = new ol.source.GeoJSON({
            projection: 'EPSG:3857',
            object: geoJSON 
          });
          vectorLayer = new ol.layer.Vector({
            source: geojsonSource
          });
          map.addLayer(vectorLayer);
        };

        scope.removeVectorLayer = function() {
          if ( typeof vectorLayer !== 'undefined' ) {
              map.removeLayer(vectorLayer);
          }
        };

//        getMaps();
      }   
    };
  }]);
