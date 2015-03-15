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

diag Dumper(map {  $_->{GCPX}, $_->{GCPY}  }  @{$gcp->gcps});

done_testing();

