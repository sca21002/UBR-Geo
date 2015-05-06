'use strict';

describe('Controller: MapdetailCtrl', function () {

  // load the controller's module
  beforeEach(module('ngMapApp'));

  var MapdetailCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    MapdetailCtrl = $controller('MapdetailCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
