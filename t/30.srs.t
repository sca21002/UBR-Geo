use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('Geo::OSR') or exit;
#    use_ok('UBR::Geo::Geotransform') or exit;
}

my $sr = Geo::OSR::SpatialReference->create( EPSG => 4326 );

diag $sr->Export   ('WKT' );   

done_testing();

