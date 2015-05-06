'use strict';

describe('Service: thumbnailURL', function () {

  // load the service's module
  beforeEach(module('ngMapApp'));

  // instantiate service
  var thumbnailURL;
  beforeEach(inject(function (_thumbnailURL_) {
    thumbnailURL = _thumbnailURL_;
  }));

  it('should do something', function () {
    expect(!!thumbnailURL).toBe(true);
  });

});
