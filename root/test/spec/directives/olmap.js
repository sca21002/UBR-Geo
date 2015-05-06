'use strict';

describe('Directive: olMap', function () {

  // load the directive's module
  beforeEach(module('ngMapApp'));

  var element,
    scope;

  beforeEach(inject(function ($rootScope) {
    scope = $rootScope.$new();
  }));

  it('should make hidden element visible', inject(function ($compile) {
    element = angular.element('<ol-map></ol-map>');
    element = $compile(element)(scope);
    expect(element.text()).toBe('this is the olMap directive');
  }));
});
