goog.provide('ubrGeo.Libraries');

goog.require('ubrGeo');


/**
 * The Libraries service provide informations about institutions
 * whch are holding the maps
 * @constructor
 * @ngInject
 * @ngdoc service
 * @ngname ubrGeoLibraries
 */
ubrGeo.Libraries = function() {

  this.libraries_ = /** ubrGeox.Libraries */ [
    { isil: 'DE-355',           name: 'UB Regensburg' },
    { isil: 'DE-12',            name: 'BSB' },
    { isil: 'DE-70',            name: 'LB Coburg' },
    { isil: 'DE-Re13',          name: 'IOS' },
    { isil: 'DE-155',           name: 'SB Regensburg' },
    { isil: 'DE-29',            name: 'UB Erlangen' },
  ];

  this.holding_ = { 
    'DE-355': {name: 'Universtätsbibliothek Regensburg', url: 'http://www.uni-regensburg.de/bibliothek/'},
    'DE-12':  {name: 'Bayerische Staatsbibliothek', url: 'https://www.bsb-muenchen.de/'},
    'DE-70':  {name: 'Landesbibliothek Coburg', url: 'http://www.landesbibliothek-coburg.de/'},
    'DE-Re13': {name: 'Institut für Ost- und Südosteuropaforschung', url: 'http://www.ios-regensburg.de/'},
    'DE-155': {name: 'Staatliche Bibliothek Regensburg', url: 'https://www.staatliche-bibliothek-regensburg.de/'},
    'DE-29':  {name: 'Universitätsbibliothek Erlangen-Nürnberg', url: 'http://www.ub.uni-erlangen.de/'},
  };
};

 
/**
* @return {Array.<Object>} List of Libraries
* @export
*/
ubrGeo.Libraries.prototype.getList = function() {
  return this.libraries_;
};

/**
 * @param {string} isil Isil
* @return {Object} Library info
* @export
*/
ubrGeo.Libraries.prototype.getLibrary = function(isil) {
  return this.holding_[isil];
};

ubrGeo.module.service('ubrGeoLibraries', ubrGeo.Libraries);
