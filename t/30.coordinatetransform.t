use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('UBR::Geo::GCP::FromDB') or exit;
    use_ok('UBR::Geo::Geotransform') or exit;
}



my $gcp = UBR::Geo::GCP::FromDB ->new(
	filename => 'ubr15411_0134',
);


my $geotransform = UBR::Geo::Geotransform->new_from_gcps($gcp);

my ($x,$y) = $geotransform->transform_invers(12.053,48.941,4326); 

diag(Dumper($x,$y));

done_testing();
