use strict;
use warnings;

use UBR::Geo;
use Plack::Builder;
use Plack::Middleware::CrossOrigin;

my $app = UBR::Geo->apply_default_middlewares(UBR::Geo->psgi_app);

builder {
    enable 'CrossOrigin', origins => '*';
    $app;
};
