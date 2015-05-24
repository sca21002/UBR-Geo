use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Test::Fatal;
use Data::Dumper;

BEGIN {
    use_ok('UBR::Geo::GCP::FromDB') or exit;
    use_ok('UBR::Geo::Geotransform::Simple') or exit;
    use_ok('UBR::Geo::Geotransform::FromGCP') or exit;
    use_ok('UBR::Geo::Geotransform::FromDB') or exit;
}

my $data = {
    'srid' => 3857,
    'scale_x' => '9.69337714583593',
    'scale_y' => '-9.90845267847448',
    'upperleft_x' => '1177955.03138243',
    'skew_x' => '0.0856560436283976',
    'skew_y' => '0.100762755250348',
    'upperleft_y' => '6361023.41352032'
};

my $geotransform = UBR::Geo::Geotransform::Simple->new($data);

my ($x,$y) = $geotransform->transform_invers(12.053,48.941,4326); 
is(sprintf("%.0f %.0f", $x, $y), '16809 9877', "pixel(x,y) = (16809, 9877)");


my $gcp = UBR::Geo::GCP::FromDB->new(
	filename => 'ubr15411_0134',
);

$geotransform = UBR::Geo::Geotransform::FromGCP->new({gcp => $gcp});

#diag Dumper($geotransform->as_href);

($x,$y) = $geotransform->transform_invers(12.053,48.941,4326); 
is(sprintf("%.0f %.0f", $x, $y), '16809 9877', "pixel(x,y) = (16809, 9877)");

$geotransform = UBR::Geo::Geotransform::FromDB ->new(
	map_id => 1301,
);

#diag Dumper($geotransform->as_href);

($x,$y) = $geotransform->transform_invers(12.053,48.941,4326); 
is(sprintf("%.0f %.0f", $x, $y), '16809 9877', "pixel(x,y) = (16809, 9877)");

$geotransform = UBR::Geo::Geotransform::FromDB ->new(
	map_id => 201,
);

($x,$y) = $geotransform->transform_invers(4503140,5421914,31468); 

is(sprintf("%.0f %.0f", $x, $y), '11348 3657', "pixel(x,y) = (11348, 3657)");

($x,$y) = $geotransform->transform_invers_test(4503140,5421914,31468);
is(sprintf("%.0f %.0f", $x, $y), '11348 3657', "pixel(x,y) = (11348, 3657)");

($x, $y) = $geotransform->transform_pixel(11348, 3657, 31468);
is(
    sprintf("%.0f %.0f", $x, $y), 
    '4503143 5421917', 
    "pixel(x,y) = (4503143, 5421917)"
);

($x, $y) = $geotransform->transform_pixel_test(11348, 3657, 31468);
is(
    sprintf("%.0f %.0f", $x, $y), 
    '4503143 5421917', 
    "pixel(x,y) = (4503143, 5421917)"
);

like(
    exception {
        ($x, $y) = $geotransform->transform_invers(-81.9, 6.9, 4326);
    },
    qr/RuntimeError latitude or longitude exceeded limits/,
    'caught exception in coordination transfomation'
);

done_testing();
