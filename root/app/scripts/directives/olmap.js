'use strict';

/**
 * @ngdoc directive
 * @name ngMapApp.directive:olMap
 * @description
 * # olMap
 */
angular.module('ngMapApp')
  .directive('olMap', function (searchParams, mapboxURL) {
    return {
      template: '<div></div>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        var view = new ol.View({
            center: ol.proj.transform([12.053, 48.941], 'EPSG:4326', 'EPSG:3857'),
            zoom: 2
        });
        var map = new ol.Map({
          target: element[0],
          layers: [
            new ol.layer.Tile({
              source: new ol.source.XYZ({
                  url: mapboxURL,
                  crossOrigin: null,
                  attributions: [
                    new ol.Attribution({
                      html: "Tiles &copy; <a href='http://mapbox.com/'>MapBox</a>"
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
              new ol.control.Attribution(),              
          ],
          view: view
        });
        
        var extent4326 = searchParams.getExtent();
        var setExtent3857 = ol.proj.transformExtent(extent4326, 'EPSG:4326', 'EPSG:3857');
        var size = map.getSize();
        view.fitExtent(setExtent3857, size);
           
        var getMaps = function(){
            var actualExtent3857 = view.calculateExtent( map.getSize() );
            var actualExtent4326 = ol.proj.transformExtent(actualExtent3857, 'EPSG:3857', 'EPSG:4326');
            searchParams.setExtent(actualExtent4326);
            scope.getMaps();
        }

        view.on('change:resolution', function(evt) { getMaps() }); 

        map.on('moveend', function() { getMaps() });

        var vectorLayer;
        scope.addVectorLayer = function(geoJSON) {
          if ( typeof vectorLayer !== "undefined" ) {
            map.removeLayer(vectorLayer)
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
          if ( typeof vectorLayer !== "undefined" ) {
              map.removeLayer(vectorLayer)
          }
        }

        getMaps();
      }   
    };
  });
