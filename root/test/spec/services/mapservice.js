'use strict';

describe('Service: mapservice', function () {

  // load the service's module
  beforeEach(module('ubrGeoApp'));

  // instantiate service
  var mapservice;
  beforeEach(inject(function (_mapservice_) {
    mapservice = _mapservice_;
  }));

  it('should do something', function () {
    expect(!!mapservice).toBe(true);
  });

});
