use strict;
use warnings;

use UBR::Geo;

my $app = UBR::Geo->apply_default_middlewares(UBR::Geo->psgi_app);
$app;

