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
	file => path($Bin)->child(qw(input_files ubr05510_5776.tif.points)),
);


my $gcps_expected = [
    {
      'GCPX' => '43.5',
      'GCPPixel' => '695',
      'GCPLine' => '-550',
      'GCPZ' => '0',
      'Info' => '',
      'Id' => '',
      'GCPY' => '45.75'
    },
    {
      'Info' => '',
      'Id' => '',
      'GCPY' => '45.5',
      'GCPZ' => '0',
      'GCPLine' => '-6470',
      'GCPX' => '43.5',
      'GCPPixel' => '659'
    },
    {
      'GCPLine' => '-568',
      'GCPX' => '44',
      'GCPPixel' => '8932',
      'GCPY' => '45.75',
      'Id' => '',
      'Info' => '',
      'GCPZ' => '0'
    },
    {
      'GCPZ' => '0',
      'GCPY' => '45.5',
      'Id' => '',
      'Info' => '',
      'GCPX' => '44',
      'GCPPixel' => '8920',
      'GCPLine' => '-6485'
    }
];

my $gcps = $gcp->gcps_as_href;

is_deeply($gcps, $gcps_expected, 'GCPs read');

done_testing();

