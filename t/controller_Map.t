use strict;
use warnings;
use Test::More;


use Catalyst::Test 'UBR::Geo';
use UBR::Geo::Controller::Map;

ok( request('/map/list')->is_success, 'Request should succeed' );
done_testing();
