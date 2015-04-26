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
	filename => 'ubr05510_5776',
);


my $gcps_expected = [
    {
      'x' => '43.5',
      'pixel' => '695',
      'line' => '550',
      'z' => '0',
      'info' => '',
      'id' => '529',
      'y' => '45.75'
    },
    {
      'info' => '',
      'id' => '530',
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
      'id' => '531',
      'info' => '',
      'z' => '0'
    },
    {
      'z' => '0',
      'y' => '45.5',
      'id' => '532',
      'info' => '',
      'x' => '44',
      'pixel' => '8920',
      'line' => '6485'
    }
];

my $gcps = $gcp->gcps_as_href;

is_deeply($gcps, $gcps_expected, 'GCPs read');

my $geotransform = UBR::Geo::Geotransform->new_from_gcps($gcp);

is(sprintf("%.2f %.2f", $geotransform->transform_pixel(695 ,550, 4805 )), '43.50 45.75', 'Point 1');
is(sprintf("%.2f %.2f", $geotransform->transform_pixel(8920,6485, 4805 )), '44.00 45.50', 'Point 2');   


is(sprintf("%.0f %.0f", $geotransform->transform_invers(43.5003639272711, 45.7500322254507, 4805)),
    '695 550', 'transform_invers 1');
is(sprintf("%.0f %.0f", $geotransform->transform_invers(44.00,45.50, 4805)), '8914 6486', 'transform_invers 2');
is(sprintf("%.0f %.0f", $geotransform->transform_invers(43.50,45.50, 4805)), '665 6469', 'transform_invers 3');

done_testing();
