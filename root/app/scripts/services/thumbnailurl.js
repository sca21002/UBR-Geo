'use strict';

/**
 * @ngdoc service
 * @name ngMapApp.thumbnailURL
 * @description
 * # thumbnailURL
 * Factory in the ngMapApp.
 */
angular.module('ngMapApp')
  .factory('thumbnailURL', function () {
    return function (pid) {
        var url = 'http://digital.bib-bvb.de/webclient/DeliveryManager?pid=';
        url = url + pid + '&custom_att_2=thumbnailstream';
        return url;
    };
  });
