use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Data::Dumper;

BEGIN {
    use_ok( 'UBR::Geo::GCP' ) or exit;
}



my $gcp = UBR::Geo::GCP->new(
	file => path($Bin)->child(qw(input_files ubr05510_5764.tif.points)),
);


my $gcps = [
     {
       'pixelY' => '-623',
       'enable' => '1',
       'mapY' => '45.75',
       'pixelX' => '804',
       'mapX' => '37.5'
     },
     {
       'pixelY' => '-6570',
       'enable' => '1',
       'mapY' => '45.5',
       'mapX' => '37.5',
       'pixelX' => '757'
     },
     {
       'mapX' => '38',
       'pixelX' => '9090',
       'enable' => '1',
       'pixelY' => '-6588',
       'mapY' => '45.5'
     },
     {
       'mapX' => '38',
       'pixelX' => '9092',
       'pixelY' => '-638',
       'enable' => '1',
       'mapY' => '45.75'
     }
];

is_deeply($gcp->get_gcps, $gcps, 'GCPs read');

#diag Dumper($gcp->get_gcps);

done_testing();

