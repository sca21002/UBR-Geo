'use strict';

/**
 * @ngdoc function
 * @name ubrGeoApp.controller:MapsCtrl
 * @description
 * # MapsCtrl
 * Controller of the ubrGeoApp
 */

/*global proj4, ol*/

angular.module('ubrGeoApp')
  .controller('MapsCtrl', function (
    $http, $location, $scope, helpers, searchParams, mapboxURL, mapservice, $routeParams, thumbnailURL) {

      $scope.name = 'MapsCtrl';

      var isValidExtent = helpers.isValidExtent;
      var center;

      if ($routeParams.project) {
          var project = $routeParams.project;
          searchParams.setProject(project);
          $scope.$emit('ChangedProject', project);
      }
      
      if ($routeParams.library) {
          var library = $routeParams.library;
          searchParams.setLibrary(library);
          $scope.$emit('ChangedLibrary', library);
      }

      if ($routeParams.search) {
          var search = $routeParams.search;
          searchParams.setSearch(search);
          $scope.$emit('ChangedSearch', search);
      }
  
      if ($routeParams.x && $routeParams.y) {
          var x = $routeParams.x;
          var y = $routeParams.y;
          proj4.defs('EPSG:31468','+proj=tmerc +lat_0=0 +lon_0=12 +k=1 +x_0=4500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs');
          var coord4326 = ol.proj.transform([x,y], 'EPSG:31468', 'EPSG:4326');        
          center = { lon: coord4326[0], lat: coord4326[1] };
          searchParams.setCenter(center);
      }

      if ($routeParams.name) {
          searchParams.setName($routeParams.name);
      }

      center        = searchParams.getCenter();
      
     
      angular.extend( $scope, {
      center : center,
      place  : searchParams.getName(),
      mapbox: { 
        source: {
          type: 'MapBox',
          mapId: 'sca21002.l80l365g',
          accessToken: 'pk.eyJ1Ijoic2NhMjEwMDIiLCJhIjoieWRaV0NrcyJ9.g6_31qK3mtTz_6gRrbuUGA',
          attributions: [
            new ol.Attribution({
              html: 'Tiles &copy; <a href="http://mapbox.com/">MapBox</a>'
            }),
            ol.source.OSM.ATTRIBUTION
          ]
        }
      },
      boundingbox: {
        source: {
          type: 'GeoJSON',
          geojson: {
            object: {
              type: 'FeatureCollection',
              features: [
                {
                  type: 'Feature',
                  geometry: {
                    type: 'Point',
                    coordinates: [ 0, 0 ] 
                  }
                } 
              ]
            },  
            projection: 'EPSG:3857'
          }
        }
      },
      attrib: { 
          collapsible: false
      },
      ovmap: {
          collapsed: false
      },
      defaults: {
          controls: { attribution: false }
      }
    });


    function getMaps() { 
        mapservice.getList().then(
             function(data){
                 $scope.maps = data.maps;
                 $scope.currentPage = data.page;
                 $scope.totalMaps = data.maps_total;
                 $scope.yearRange = data.maps_per_year;
                 $scope.yearExtent = searchParams.getYearExtent();
                 angular.forEach($scope.maps, function(map) {
                     map.icon = thumbnailURL(map.pid);
                 });    
             }
         );
    }
     
    $scope.$watch('center.bounds', function() {
        if (isValidExtent($scope.center.bounds)) {
            searchParams.setCenter(center);
            $scope.currentPage = 1;
            searchParams.setPage($scope.currentPage);
            getMaps();
        }
    });

    $scope.hover = function(map) {
        mapservice.getBoundary(map.map_id).then(
            function(geoJSON){ 
              $scope.boundingbox.source.geojson.object = geoJSON;
            }
        );
    };

    $scope.pageChanged = function() {
        if ( $scope.currentPage !== searchParams.getPage() ) {
            searchParams.setPage($scope.currentPage);
            getMaps();
        }    
    };


    $scope.yearExtentChanged = function(yearExtent) {

        var yearMin = $scope.yearRange[0].year;
        var yearMax = $scope.yearRange[$scope.yearRange.length -1].year;
        if (yearExtent[0] === yearMin &&  yearExtent[1] === yearMax) {
            return;
        }
        searchParams.setYearExtent(yearExtent);
        getMaps();
    };
    
    $scope.open = function(map) {
        var mapId = map.map_id;
        var extent = center.bounds;
        $location.path('/map/'+ mapId);
        $location.search({
            x1: extent[0], y1: extent[1], x2: extent[2], y2: extent[3]
        });
    };

    $scope.$on('ChangedProject', function () {
        $scope.currentPage = 1;
        searchParams.setPage($scope.currentPage);
        getMaps();
    });

    $scope.$on('ChangedLibrary', function () {
        $scope.currentPage = 1;
        searchParams.setPage($scope.currentPage);
        getMaps();
    });

    $scope.$on('ChangedSearch', function () {
        $scope.currentPage = 1;
        searchParams.setPage($scope.currentPage);
        getMaps();
    });

  });
