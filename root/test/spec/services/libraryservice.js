'use strict';

describe('Service: libraryService', function () {

  // load the service's module
  beforeEach(module('ubrGeoApp'));

  // instantiate service
  var libraryService;
  beforeEach(inject(function (_libraryService_) {
    libraryService = _libraryService_;
  }));

  it('should do something', function () {
    expect(!!libraryService).toBe(true);
  });

});
