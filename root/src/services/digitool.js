goog.provide('ubrGeo.Digitool');

goog.require('ubrGeo');

/**
 * The Digitool service delivers map tiles  
 * @constructor
 * @param {angular.$http} $http Angular http service.
 * @ngInject
 * @ngdoc service
 * @ngname ubrGeoDigitool
 */
ubrGeo.Digitool = function($http) {

  /**
  * @type {angular.$http}
  * @private
  */
  this.$http_ = $http;

  /**
  * @type {string}
  * @private
  */
  this.baseURL_ = 'http://digipool.bib-bvb.de/';
}


/**
* @param {number} pid Digitool id Pid 
* @return {angular.$q.Promise} Promise.
* @export
*/
ubrGeo.Digitool.prototype.getMapInfo = function(pid) {

  var url = this.baseURL_ + 'bvb/anwender/CORS/get_imageinfo.pl?pid=' + pid;

  return this.$http_.get(url).then( 
      this.handleGetData_.bind(this)
  );
};

/**
 * @param {angular.$http.Response} resp Ajax response.
 * @return {Object.<string, number>} The  object.
 * @private
 */
ubrGeo.Digitool.prototype.handleGetData_ = function(resp) {
    return resp.data;
};

ubrGeo.module.service('ubrGeoDigitool', ubrGeo.Digitool);
