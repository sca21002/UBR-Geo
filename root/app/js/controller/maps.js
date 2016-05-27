goog.provide('app.MapsController');

/**
 * This goog.require is needed because it provides 'ngeo-map' used in
 * the template.
 * @suppress {extraRequire}
 */
goog.require('ngeo.mapDirective');
 /** @suppress {extraRequire} */
goog.require('ubrGeo.yearRangeSliderDirective');
goog.require('ol.Map');
goog.require('ol.View');
goog.require('ol.layer.Tile');
goog.require('ol.layer.Vector');
goog.require('ol.source.XYZ');
goog.require('ol.source.Vector');
goog.require('ol.control.Attribution');
goog.require('ol.Attribution');
goog.require('ol.format.GeoJSON');
goog.require('ol.source.OSM');
goog.require('ubrGeo.Maps');
goog.require('ubrGeo.Thumbnail');
goog.require('ol.control.OverviewMap');

/**
 * @param {ubrGeo.Maps} ubrGeoMaps service 
 * @param {ubrGeo.Thumbnail} ubrGeoThumbnail service 
 * @constructor
 * @ngInject
 */
app.MapsController = function($location, $routeParams, $scope, ubrGeoThumbnail, ubrGeoMaps) {

  this.ubrGeoMaps = ubrGeoMaps;
  this.location = $location;
  this.center = ol.proj.transform(
        [12.053, 48.941], 'EPSG:4326', 'EPSG:3857'
  );

  if ($routeParams.x && $routeParams.y) {
      var x = $routeParams.x;
      var y = $routeParams.y;
      proj4.defs('EPSG:31468','+proj=tmerc +lat_0=0 +lon_0=12 +k=1 +x_0=4500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs');
      this.center = ol.proj.transform([x,y], 'EPSG:31468', 'EPSG:3857');        
  }

  this.fetchedPage = 0;

  this.boundarySource = new ol.source.Vector({
    features: []
  })

  var overviewMapControl = new ol.control.OverviewMap({
    collapsed: false
  });

  var customAttribution = new ol.control.Attribution({
    collapsed: false
  });

  /**
  * @type {ol.Map}
  * @export
  */
  this.map = new ol.Map({
    layers: [
      new ol.layer.Tile({
        source: new ol.source.XYZ({
          tileSize: [512, 512],
          url: 'http://api.tiles.mapbox.com/v4/sca21002.l80l365g/' +
            '{z}/{x}/{y}@2x.png?access_token=pk.eyJ1Ijoic2NhMjEw' +
            'MDIiLCJhIjoieWRaV0NrcyJ9.g6_31qK3mtTz_6gRrbuUGA',
          attributions: [
            new ol.Attribution({
              html: 'Tiles &copy; <a href="http://mapbox.com/">MapBox</a>'
            }),
            ol.source.OSM.ATTRIBUTION
          ]
        })
      }),
      new ol.layer.Vector({
        source: this.boundarySource
      })
    ],
    view: new ol.View({
      center: this.center,
      zoom: 10
    }),
    controls:  ol.control.defaults({ attribution: false }).extend([customAttribution])
  });

  this.getExtent = function() {
    var extent =  this.map.getView().calculateExtent(
      /** @type {ol.Size} */
      (this.map.getSize())
    );    
    return extent;
  };


  this.updateList = function() {
    var extent = this.getExtent();
    ubrGeoMaps.getList(extent, this.page, this.yearExtent, this.library, this.search).then(function(data){
      /**
       *  @type {Array.<Object>}
       *  @export
      */
      this.maps = data.maps;
      /**
       *  @type {number}
       *  @export
      */
      this.page = data.page;
      /**
       *  @type {number}
       *  @export
      */
      this.totalMaps = data["maps_total"];
      /**
       *  @type {Array.<Object>}
       *  @export
      */
      this.mapsPerYear = data["maps_per_year"];
      
      this.maps.forEach(function(map) {
        /**
         *  @type {string}
         *  @export
        */
        map.icon = ubrGeoThumbnail.getURL(map["pid"]);
      });    
      this.fetchedPage = this.page;
    }.bind(this));
  }; 

  var brushendCallback = function(yearmin, yearmax) {
    /**
     *  @type {Array.<string>}
     *  @export
    */
    this.yearExtent = [yearmin, yearmax];
    this.updateList();
  }.bind(this);

  /**
   * @type {Object}
   * @export
   */
  this.sliderOptions = {
    brushendCallback: brushendCallback
  };


  ol.events.listen(this.map, ol.MapEventType.MOVEEND,
      function() {
          this.updateList(); 
          this.map.addControl(overviewMapControl);
          $scope.$apply();
      }, this
  );

  $scope.$on('ChangedLibrary', function (event, library) {
    /**
     * @type {string}
     * @export
     */
    this.library = library;
    this.page = 1;
    this.updateList();
  }.bind(this));

  $scope.$on('ChangedSearch', function (event, search) {
    /**
     * @type {string}
     * @export
     */
    this.search = search;
    this.page = 1;
    this.updateList();
  }.bind(this));

}


/**
 * @export
 */
app.MapsController.prototype.pageChanged = function() {
    if (this.page !== this.fetchedPage) {
      this.updateList();
    }

/**
 * @export
 */
app.MapsController.prototype.yearExtentChanged = function(yearExtent) {


//        var yearMin = $scope.yearRange[0].year;
//        var yearMax = $scope.yearRange[$scope.yearRange.length -1].year;
//        if (yearExtent[0] === yearMin &&  yearExtent[1] === yearMax) {
//            return;
//        }
//        searchParams.setYearExtent(yearExtent);
//        getMaps();
   };
};

/**
 * @param {Object} map Map.
 * @export
 */
app.MapsController.prototype.hover = function(map) {
  var mapId = map['map_id'];
  this.ubrGeoMaps.getBoundary(mapId).then(function(geojson) {
    var geojsonFormat = new ol.format.GeoJSON();
    var features = geojsonFormat.readFeatures(geojson);
    this.boundarySource.clear();        
    this.boundarySource.addFeatures(features);
  }.bind(this));
};


/**
 * @param {Object} map Map.
 * @export
 */
app.MapsController.prototype.open = function(map) {
  var mapId = map['map_id'];
  var extent = this.getExtent();
  this.location.path('/map/'+ mapId);
  this.location.search({
      x1: extent[0], y1: extent[1], x2: extent[2], y2: extent[3]
  });
};
