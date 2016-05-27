goog.provide('ubrGeo.Maps');

goog.require('ubrGeo');
goog.require('ol.proj');

/**
 * The Maps service uses the
 * ubrGeo backend to obtain maps
 * @constructor
 * @param {angular.$http} $http Angular http service.
 * @param {string} ubrGeoServerURL URL to the ubrGeo server
 * @ngInject
 * @ngdoc service
 * @ngname ubrGeoMaps
 */
ubrGeo.Maps = function($http, ubrGeoServerURL) {

    /**
    * @type {angular.$http}
    * @private
    */
    this.$http_ = $http;

    /**
    * @type {string}
    * @private
    */
    this.baseURL_ = ubrGeoServerURL;
};


/**
* @param {ol.Extent} extent extent (projection: 3857) for which maps are searched 
* @return {angular.$q.Promise} Promise.
* @export
*/
ubrGeo.Maps.prototype.getList = function(extent, page, yearExtent, library, search) {

    extent = ol.proj.transformExtent(extent, 'EPSG:3857', 'EPSG:4326');
    var url = this.baseURL_ + '/map/list?bbox=' + extent.join(',');
    if (page) { url += '&page=' + page; };
    if (yearExtent && yearExtent[0] && yearExtent[1]) {
        url += '&year_min=' + yearExtent[0] + '&year_max=' + yearExtent[1];
    }
    if (library) { url += '&isil=' + library; };
    if (search)  { url += '&search=' + search; }

    return this.$http_.get(url).then(
        this.handleGetData_.bind(this)
    );
};


/**
 * @param {angular.$http.Response} resp Ajax response.
 * @return {Object.<string, number>} The  object.
 * @private
 */
ubrGeo.Maps.prototype.handleGetData_ = function(resp) {
    return resp.data;
};


/**
* @param {string} mapId Id of the map
* @return {angular.$q.Promise} Promise.
* @export
*/
ubrGeo.Maps.prototype.getBoundary = function(mapId) {

  var url = this.baseURL_ + '/map/' + mapId + '/boundary';

  return this.$http_.get(url).then(
    this.handleGetData_.bind(this)
  );
};
  
/**
* @param {string} mapId Id of the map
* @return {angular.$q.Promise} Promise.
* @export
*/
ubrGeo.Maps.prototype.getTitle = function(mapId) {

  var url = this.baseURL_ + '/map/' + mapId + '/detail';

  return this.$http_.get(url).then(
    this.handleGetData_.bind(this)
  );
};
  
/**
* @param {string} mapId Id of the map
* @param {number} x1 x1
* @param {number} y1 y1
* @param {number} x2 x2
* @param {number} y2 y2
* @param {string} srid srid
* @return {angular.$q.Promise} Promise.
* @export
*/
ubrGeo.Maps.prototype.getCoords = function(mapId, x1, y1, x2, y2, srid) {

  var url = this.baseURL_ + '/map/' + mapId + '/geotransform2';
  url += '?x1=' + x1 + '&y1=' + y1;
  url += '&x2=' + x2 + '&y2=' + y2;
  url += '&srid=' + srid + '&invers=1';

  return this.$http_.get(url).then(
    this.handleGetData_.bind(this)
  );
};
  
/**
* @param {string} mapId Id of the map
* @param {number} x x
* @param {number} y y
* @return {angular.$q.Promise} Promise.
* @export
*/
ubrGeo.Maps.prototype.contains = function(mapId, x, y) {
      
  var url = this.baseURL_ + '/map/' + mapId + '/contains';
  url += '?x=' + x + '&y=' + y;

  return this.$http_.get(url).then(
    this.handleGetData_.bind(this)
  );
};
  
ubrGeo.module.service('ubrGeoMaps', ubrGeo.Maps);
