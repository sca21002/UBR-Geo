goog.provide('app.MapdetailController');

/**
 * This goog.require is needed because it provides 'ngeo-map' used in
 * the template.
 * @suppress {extraRequire}
 */
goog.require('ngeo.mapDirective');
goog.require('ol.Map');
goog.require('ol.View');
goog.require('ol.source.XYZ');
goog.require('ol.layer.Tile');
goog.require('ol.proj');
/** @suppress {extraRequire} */
goog.require('ubrGeo.Maps');
/** @suppress {extraRequire} */
goog.require('ubrGeo.Libraries');
/** @suppress {extraRequire} */
goog.require('ubrGeo.Digitool');

/**
 * @constructor
 * @ngInject
 */
app.MapdetailController = function(
  $location, $routeParams, ubrGeoMaps, ubrGeoLibraries, ubrGeoDigitool) {

  this.equatorLenght = 40075016.686
  this.mapId = $routeParams['mapId'];

  var extent3857 = [ 
    parseFloat($routeParams.x1), 
    parseFloat($routeParams.y1), 
    parseFloat($routeParams.x2), 
    parseFloat($routeParams.y2)
  ];


  var extent4326 = ol.proj.transformExtent(extent3857, 'EPSG:3857', 'EPSG:4326');

  var xCenter = extent3857[0] + ( extent3857[2] - extent3857[0]) /2;
  var yCenter = extent3857[1] + ( extent3857[3] - extent3857[1]) /2;


  // extent of the whole world in pseudo mercator projection
  // calculated from WGS 84 (lat: -180° .. 180° lon: -85° .. 85°)    
  var bounds3857 = ol.proj.transformExtent([-180,-85,180,85], 'EPSG:4326','EPSG:3857');

  // the origin of the map content is the upper left corner 
  var tileSize = 256; // [px]

  var filename;
  var coord = [];

  this.map = new ol.Map({
    layers: []    
  });  

  ubrGeoMaps.getTitle(this.mapId).then(function(data){  
    var pid = data['detail']['pid']; 
    var library = ubrGeoLibraries.getLibrary(data.detail.isil); 
    this.isbd = data['detail']['isbd']; 
    this.exemplar = data['detail']['exemplar']; 
    ubrGeoDigitool.getMapInfo(pid).then(function(data){
      filename = data.filename;
      var imgHeight = data['imgHeight'];    
      var imgWidth  = data['imgWidth'];
      var maxZoom   = data['maxZoom'];
      this.view = new ol.View({
        center: [0,0],
        zoom: 2,
        maxZoom: maxZoom
      });
      this.map.setView(this.view); 
      this.view.on('change:resolution', function() {
      }, this);
  
      ubrGeoMaps.getCoords(this.mapId, 
        extent4326[0], extent4326[1], extent4326[2], extent4326[3], '4326').then(
        function(data){
          var pixel = [];
          data['pixel'].forEach(function(coord) {
            pixel.push(parseFloat(coord));    
          });
          ubrGeoMaps.contains(this.mapId, xCenter, yCenter).then(function(data){

            // tile size is calculated from max zoom level and size of a single tile          
            var $tileSizeTot = Math.pow(2, maxZoom) * tileSize;
            
            var x1Map, y1Map, x2Map, y2Map;
            if (data['contains']) {
                x1Map = bounds3857[0] + (bounds3857[2] - bounds3857[0]) * pixel[0] / $tileSizeTot;
                y1Map = bounds3857[3] - (bounds3857[3] - bounds3857[1]) * pixel[1] / $tileSizeTot;
                x2Map = bounds3857[0] + (bounds3857[2] - bounds3857[0]) * pixel[2] / $tileSizeTot;
                y2Map = bounds3857[3] - (bounds3857[3] - bounds3857[1]) * pixel[3] / $tileSizeTot;
                coord = goog.array.clone([x1Map, y1Map, x2Map, y2Map]);
            } else {
                x2Map = bounds3857[0] + (bounds3857[2] - bounds3857[0]) * imgWidth  / $tileSizeTot;
                y1Map = bounds3857[3] - (bounds3857[3] - bounds3857[1]) * imgHeight / $tileSizeTot;
                coord = goog.array.clone([bounds3857[0], y1Map, x2Map, bounds3857[3]]);                  
            }
            var tile = new ol.layer.Tile({
              source: new ol.source.XYZ({
                url: 'http://digital.bib-bvb.de/ImageServer/mytile.jsp?filename=' +
                      filename +
                     '&zoom={z}&x={x}&y={y}&rotation=0',
                wrapX: false
              })
            });
            this.map.addLayer(tile);
            var size = /** @type {Array.<number>} */ (this.map.getSize());
            this.view.fit(coord, size);
          }.bind(this), function(error) {
                  alert('Ein Fehler ist aufgetreten: ' + error);
                  $location.path('/maps');
          });
        }.bind(this),
        function(error) {
          alert('Ein Fehler ist aufgetreten: ' + error);
          $location.path('/maps');
        } 
      );    
    }.bind(this));
  }.bind(this));

};
