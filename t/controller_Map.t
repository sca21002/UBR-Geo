use strict;
use warnings;
use Test::More;


use Catalyst::Test 'UBR::Geo';
use UBR::Geo::Controller::Map;

ok( request('/map/list')->is_success, 'Request should succeed' );
is( request('/map/919/geotransform2?x1=14.210850215909936&y1=48.158122220884906&x2=15.115848995206813&y2=48.46409521840644&srid=4326&invers=1')->code, 404, 'Code 404');  
done_testing();
