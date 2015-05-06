'use strict';

describe('Directive: olMapDetail', function () {

  // load the directive's module
  beforeEach(module('ngMapApp'));

  var element,
    scope;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
  }));

  it('should make hidden element visible', inject(function ($compile) {
    element = angular.element('<ol-map-detail></ol-map-detail>');
    element = $compile(element)(scope);
    expect(element.text()).toBe('this is the olMapDetail directive');
  }));
});
