'use strict';

/**
 * @ngdoc overview
 * @name ubrGeoApp
 * @description
 * # ubrGeoApp
 *
 * Main module of the application.
 */
var ubrGeoApp = angular
  .module('ubrGeoApp', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch',
    'angularUtils.directives.dirPagination'   // pagination
  ])
  .config(function ($routeProvider) {
    $routeProvider
      .when('/maps/list', {
        templateUrl: 'views/maps.html',
        controller: 'MapsCtrl'
      })
      .when('/map/:mapId', {
        templateUrl: 'views/map_detail.html',
        controller: 'MapDetailCtrl',
      })
      .when('/about', {
        templateUrl: 'views/about.html',
        controller: 'AboutCtrl'
      })
      .when('/', {
        templateUrl: 'views/main.html',
        controller: 'MainCtrl'
      })
      .otherwise({
        redirectTo: '/'
      });
  });

// Template for pagination
ubrGeoApp.config(function(paginationTemplateProvider) {
    paginationTemplateProvider.setPath('bower_components/angular-utils-pagination/dirPagination.tpl.html');
});

ubrGeoApp.directive('olMap', function() {
    var MAP_DOM_ELEMENT_ID = 'map';
    return {
        template: '<div id="' + MAP_DOM_ELEMENT_ID + '"></div>',
        // restrict to elements, seems necessary, contrary to the docs
        restrict: 'E',
        link: function postLink(scope, element, attrs) {
          scope.olMap = new ol.Map({
            target: 'map',
            layers: [
              new ol.layer.Tile({
                source: new ol.source.XYZ({
                    url: 'http://api.tiles.mapbox.com/v4/sca21002.l80l365g/{z}/{x}/{y}.png?access_token=pk.eyJ1Ijoic2NhMjEwMDIiLCJhIjoieWRaV0NrcyJ9.g6_31qK3mtTz_6gRrbuUGA',
                    //url : "http://pc1011406020.uni-regensburg.de/tiles/osm-bright/{z}/{x}/{y}.png",
                    crossOrigin: null
                })
              })
            ],
            controls: [
                new ol.control.Zoom(),
                new ol.control.OverviewMap({
                    collapsed: false
                })
            ],
            view: new ol.View({
              center: ol.proj.transform([12.053, 48.941], 'EPSG:4326', 'EPSG:3857'),
              zoom: 2
            })
          });
          console.log('map directive: ', scope.extent);
          var extent_3857 = ol.proj.transformExtent(scope.extent, 'EPSG:4326', 'EPSG:3857');
          console.log('init extent (3857): ', extent_3857);
          var olMap = scope.olMap;
          var view = olMap.getView();
          var size = olMap.getSize();
          view.fitExtent(extent_3857, size);
          extent_3857 = view.calculateExtent( size );
          console.log('fit extent (3857): ',  extent_3857); 
          scope.extent = ol.proj.transformExtent(extent_3857, 'EPSG:3857', 'EPSG:4326');
          scope.resolution = view.getResolution();
          console.log('fit extent: ', scope.extent, ' res: ', scope.resolution);
          scope.changeres = view.on('change:resolution', function(evt) {
              console.log('Resolution: ', view.getResolution() );
              var extent_3857 = view.calculateExtent( olMap.getSize() );
              console.log('Extent (3857): ', extent_3857);
              scope.extent = ol.proj.transformExtent(extent_3857, 'EPSG:3857', 'EPSG:4326');
              console.log('Resolution changed: ', scope.extent);
              scope.currentPage = 1;
              scope.getData(scope.currentPage, scope.extent);
          });     
          olMap.on('moveend', function(evt) {
              var map = evt.map;
              var extent_3857 = map.getView().calculateExtent(map.getSize()); 
              console.log('Extent (3857): ', extent_3857);
              scope.extent = ol.proj.transformExtent(extent_3857, 'EPSG:3857', 'EPSG:4326');
              console.log('Center changed: ', scope.extent);
              scope.currentPage = 1;
              scope.getData(scope.currentPage, scope.extent);
          });
        }
    };
});


ubrGeoApp.directive('olMapDetail', function(tileserver,mapdetail) {
  var MAP_DOM_ELEMENT_ID = 'mapDetail';
  return {
    template: '<div id="' + MAP_DOM_ELEMENT_ID + '"></div>',
    // restrict to elements, seems necessary, contrary to the docs
    restrict: 'E',
    link: function postLink(scope, element, attrs) {
      console.log('in directivein directive Map-Id: ',scope.mapId);
      mapdetail.getPid(scope.mapId).then(function(data){ 
        console.log('Detail: ', data);  
        var pid = data.detail.pid;
        console.log('pid: ', pid);
        tileserver.getInfo(pid).then(function(data){
          console.log('Karte: ',data); 
          var imgHeight = data.imgHeight;
          var imgWidth  = data.imgWidth;
          var maxZoom   = data.maxZoom;
          var filename = data.filename;
          var img_projection = new ol.proj.Projection({
            code: 'pixel',
            units: 'm',
            //extent: [0,0,6886,6333]  
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
            target: 'mapDetail',
            layers: [
              layer
            ],
            view: new ol.View({
              // center: [10000000,10000000],
              zoom: maxZoom
            })
          });
          
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
        },
        function(errorMessage){
          $scope.error=errorMessage;
        }); 
      },
      function(errorMessage){
        $scope.error=errorMessage;
      }); 
    }
  };    
});    

ubrGeoApp.factory('tileserver', function($http,$q) {
  return { 
    getInfo: function(pid) {
      // Creating a deffered object
      var deferred = $q.defer();
      
      $http.get(
        'http://digipool.bib-bvb.de/bvb/anwender/CORS/get_imageinfo.pl?pid='
            + pid
        ).success(function(data) {  
          //Passing data to deferred's resolve function on successful completion
          console.log('Got new data for: ', data);
          deferred.resolve(data);
        }).error(function(){
          //Sending a friendly error message in case of failure
          deferred.reject("An error occured while fetching items");
        });
        
      //Returning the promise object
      return deferred.promise;
    }
  }
});

ubrGeoApp.factory('mapdetail', function($http,$q) {
  return { 
    getPid: function(mapId) {
      // Creating a deffered object
      var deferred = $q.defer();
      
      $http.get(
        'http://pc1011406020.uni-regensburg.de:8888/map/' +  
         + mapId + '/detail'    
        ).success(function(data) {  
          //Passing data to deferred's resolve function on successful completion
          console.log('Got new data for: ', data);
          deferred.resolve(data);
        }).error(function(){
          //Sending a friendly error message in case of failure
          deferred.reject("An error occured while fetching PID");
        });
        
      //Returning the promise object
      return deferred.promise;
    }
  }
});
