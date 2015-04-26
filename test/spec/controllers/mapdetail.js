'use strict';

describe('Controller: MapdetailctrlCtrl', function () {

  // load the controller's module
  beforeEach(module('ubrGeoApp'));

  var MapdetailctrlCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    MapdetailctrlCtrl = $controller('MapdetailctrlCtrl', {
      $scope: scope
    });
  }));

  it('should attach a list of awesomeThings to the scope', function () {
    expect(scope.awesomeThings.length).toBe(3);
  });
});
