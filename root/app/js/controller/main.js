goog.provide('app.MainController');

/** @suppress {extraRequire} */
goog.require('ubrGeo.Libraries');

/**
 * @constructor
 * @ngInject
 */
app.MainController = function($scope, ubrGeoLibraries) {

  /**
   * @export
   */
  this.libraries = ubrGeoLibraries.getList();
  this.scope = $scope;
  /**
   * @export
   */
  this.library = '';
  /**
   * @export
   */
  this.search;
};


/**
 * @export
 */
app.MainController.prototype.libraryChanged = function() {
  this.scope.$broadcast('ChangedLibrary', this.library);
}

/**
 * @export
 */
app.MainController.prototype.searchChanged = function() {
  this.scope.$broadcast('ChangedSearch', this.search);
}
