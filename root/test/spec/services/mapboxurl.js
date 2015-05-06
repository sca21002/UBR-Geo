'use strict';

describe('Service: mapboxURL', function () {

  // load the service's module
  beforeEach(module('ngMapApp'));

  // instantiate service
  var mapboxURL;
  beforeEach(inject(function (_mapboxURL_) {
    mapboxURL = _mapboxURL_;
  }));

  it('should do something', function () {
    expect(!!mapboxURL).toBe(true);
  });

});
