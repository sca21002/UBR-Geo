use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Data::Dumper;

BEGIN {
    use_ok('UBR::Geo::GCP::FromFile') or exit;
}



my $gcp = UBR::Geo::GCP::FromFile ->new(
	file => path($Bin)->child(qw(input_files ubr05510_5776.tif.points)),
    srid => '4805'
);


my $gcps_expected = [
    {
      'x' => '43.5',
      'pixel' => '695',
      'line' => '550',
      'z' => '0',
      'info' => '',
      'id' => '',
      'y' => '45.75'
    },
    {
      'info' => '',
      'id' => '',
      'y' => '45.5',
      'z' => '0',
      'line' => '6470',
      'x' => '43.5',
      'pixel' => '659'
    },
    {
      'line' => '568',
      'x' => '44',
      'pixel' => '8932',
      'y' => '45.75',
      'id' => '',
      'info' => '',
      'z' => '0'
    },
    {
      'z' => '0',
      'y' => '45.5',
      'id' => '',
      'info' => '',
      'x' => '44',
      'pixel' => '8920',
      'line' => '6485'
    }
];

my $gcps = $gcp->gcps_as_href;

is_deeply($gcps, $gcps_expected, 'GCPs read');

done_testing();

