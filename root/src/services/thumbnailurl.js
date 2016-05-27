goog.provide('ubrGeo.Thumbnail');

goog.require('ubrGeo');

/**
 * The thumbnail service builds a full URL
 * from a given pid
 * @constructor
 * @ngInject
 * @ngdoc service
 * @ngname ubrGeoThumbnailURL
 */
ubrGeo.Thumbnail = function() {};

/**
 * @param {string}  pid Digitool PID
 * @return {string} URL URL of thumbnail
 * @export
 */
ubrGeo.Thumbnail.prototype.getURL = function(pid) {
    var url = 'http://digipool.bib-bvb.de/bvb/delivery/tn_stream.fpl?pid=' + pid;
    return url;
};

ubrGeo.module.service('ubrGeoThumbnail', ubrGeo.Thumbnail);
